package QFLib.Worker
{
    import QFLib.Foundation;
    import QFLib.Foundation.CMap;
    import QFLib.Worker.Event.CEvent;
    import QFLib.Worker.Event.CStartEvent;
    import QFLib.Worker.Event.CStartedEvent;
    import QFLib.Worker.Event.CStopEvent;
    import QFLib.Worker.Event.CStoppedEvent;

    import flash.concurrent.Mutex;

    import flash.events.Event;
    import flash.system.MessageChannel;
    import flash.system.Worker;
    import flash.utils.ByteArray;
    import flash.utils.getQualifiedClassName;

    public class CWorker
	{
		public function CWorker( sName : String )
		{
            m_theFromMainChannel = Worker.current.getSharedProperty( "ToWorker_" + sName );
            m_theToMainChannel = Worker.current.getSharedProperty( "FromWorker_" + sName );
            m_theFromMainMutex = Worker.current.getSharedProperty( "ToWorker_Mutex_" + sName );
            m_theToMainMutex = Worker.current.getSharedProperty( "FromWorker_Mutex_" + sName );
            //Foundation.Log.logMsg( "CWorker(): Worker.current.state: " + Worker.current.state );

            this.registerMessageHandler( CStartEvent, _onStartEventReceived );
            this.registerMessageHandler( CStopEvent, _onStopEventReceived );

            m_theFromMainChannel.addEventListener( Event.CHANNEL_MESSAGE, _onMessageReceived );
        }

        public function dispose() : void
        {
            m_mapMessageCallbacks.clear();
            m_mapMessageClasses.clear();

            m_theFromMainMutex = m_theToMainMutex = null;

            m_theFromMainChannel.removeEventListener( Event.CHANNEL_MESSAGE, _onMessageReceived );

            if( m_theToMainChannel != null )
            {
                m_theToMainChannel.close();
                m_theToMainChannel = null;
            }

            if( m_theFromMainChannel != null )
            {
                m_theFromMainChannel.close();
                m_theFromMainChannel = null;
            }
        }

        //
        // function onXXXEventReceived( event : CXXXEvent ) : void
        //
        public function registerMessageHandler( clazz : Class, fnCallback : Function, bReplaceExistedHandler : Boolean = false ) : void
        {
            if( fnCallback == null ) return ;

            var sClassName : String = getQualifiedClassName( clazz );
            m_mapMessageClasses.add( sClassName, clazz, bReplaceExistedHandler );
            m_mapMessageCallbacks.add( clazz, fnCallback, bReplaceExistedHandler );
        }
        public function unregisterMessageHandler( clazz : Class ) : void
        {
            var sClassName : String = getQualifiedClassName( clazz );
            m_mapMessageClasses.remove( sClassName );
            m_mapMessageCallbacks.remove( clazz );
        }

        public function send( event : CEvent ) : void
        {
            event.eventIndex = ++m_iSendEventIndexCounter;
            if( m_iSendEventIndexCounter == int.MAX_VALUE ) m_iSendEventIndexCounter = 0;

            var aBytes : ByteArray = event.serialize();
            //Foundation.Log.logMsg( "CWorker send: jsonObject index: " + event.eventIndex + ", jsonObject class: " + event.eventClassName );

            m_theToMainMutex.lock();

            m_theToMainChannel.send( aBytes, -1 );
            var iNum : int = event.eventNumByteArrays;
            for( var i : int = 0; i < iNum; i++ ) // send attached byte arrays if existed
            {
                m_theToMainChannel.send( event.getByteArray( i ), -1 );
            }

            m_theToMainMutex.unlock();
        }

        public function sendQuit() : void
        {
            this.send( new CStoppedEvent() );
        }

        //
        private function _onMessageReceived( event : Event ) : void
        {
            if( event.target != m_theFromMainChannel )
            {
                Foundation.Log.logErrorMsg( "CWorker Error: target incorrect..." );
                return;
            }

            m_theFromMainMutex.lock();

            var obj : Object;
            while( m_theFromMainChannel.messageAvailable )
            {
                obj = m_theFromMainChannel.receive();
                m_listMessages.push( obj );
            }

            m_theFromMainMutex.unlock();

            //Foundation.Log.logMsg( "CWorker: There're " + m_listMessages.length + " messages to handle..." );
            for( var i : int = 0; i < m_listMessages.length; i++ )
            {
                var aBytes : ByteArray = m_listMessages[ i ] as ByteArray;
                if( aBytes == null )
                {
                    Foundation.Log.logErrorMsg( "CWorker Error: Receive a non-ByteArray object..." );
                    return;
                }

                _handleMessage( aBytes );
            }
            m_listMessages.length = 0;
        }
        private function _handleMessage( aBytes : ByteArray ) : void
        {
            var clazz : Class;
            var fnCallback : Function;

            if( m_theReceivingEvent != null )
            {
                m_theReceivingEvent.setByteArray( m_theReceivingEvent.getNumByteArrays(), aBytes );
                if( m_theReceivingEvent.getNumByteArrays() == m_theReceivingEvent.eventNumByteArrays )
                {
                    clazz = m_mapMessageClasses.find( m_theReceivingEvent.eventClassName );
                    fnCallback = m_mapMessageCallbacks.find( clazz );
                    if( fnCallback != null ) fnCallback( m_theReceivingEvent );
                    m_theReceivingEvent = null;
                }
            }
            else
            {
                var jsonObject : Object = CEvent.unSerialize( aBytes );
                if( jsonObject == null )
                {
                    Foundation.Log.logErrorMsg( "CWorker Error: Read object failed..." );
                    return;
                }

                //Foundation.Log.logMsg( "CWorker received: jsonObject index: " + jsonObject.eventInfoIndex + ", jsonObject class: " + jsonObject.eventInfoClassName );
                clazz = m_mapMessageClasses.find( jsonObject.eventInfoClassName );
                if( clazz != null )
                {
                    var theEvent : CEvent = new clazz();
                    theEvent.jsonObject = jsonObject;

                    if( m_iLastReceivedEventIndex > 0 && theEvent.eventIndex != m_iLastReceivedEventIndex + 1 )
                    {
                        Foundation.Log.logErrorMsg( "CWorker Error: theEvent.eventIndex error, last index: " + m_iLastReceivedEventIndex +
                                                    ", current index: " + theEvent.eventIndex );
                        return;
                    }
                    m_iLastReceivedEventIndex = theEvent.eventIndex;

                    if( theEvent.eventNumByteArrays > 0 )
                    {
                        m_theReceivingEvent = theEvent;
                    }
                    else
                    {
                        fnCallback = m_mapMessageCallbacks.find( clazz );
                        if ( fnCallback != null ) fnCallback( theEvent );
                    }
                }
                else
                {
                    Foundation.Log.logErrorMsg( "CWorker Error: find no event class for : " + jsonObject.eventInfoClassName );
                }
            }
        }

        private function _onStartEventReceived( event : CStartEvent ) : void
        {
            this.m_sName = event.name;
            this.m_sFilename = event.filename;

            this.send( new CStartedEvent( this.m_sName ) );
            //Foundation.Log.logMsg( "start event received: " + event.name );
        }
        private function _onStopEventReceived( event : CStopEvent ) : void
        {
            this.send( new CStoppedEvent() );
            //Foundation.Log.logMsg( "stop event received: " );
        }

        //
        protected var m_sName : String = null;
        protected var m_sFilename : String = null;

        protected var m_theToMainChannel : MessageChannel = null;
        protected var m_theFromMainChannel : MessageChannel = null;
        protected var m_theFromMainMutex : Mutex = null;
        protected var m_theToMainMutex : Mutex = null;

        protected var m_mapMessageCallbacks : CMap = new CMap();
        protected var m_mapMessageClasses : CMap = new CMap();
        protected var m_listMessages : Vector.<Object> = new Vector.<Object>();

        protected var m_iSendEventIndexCounter : uint = 0;
        protected var m_iLastReceivedEventIndex : uint = 0;

        private var m_theReceivingEvent : CEvent = null;
	}
}