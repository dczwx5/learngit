package QFLib.Worker
{
    import QFLib.Foundation;
    import QFLib.Foundation.CMap;
    import QFLib.Worker.Event.CStartEvent;
    import QFLib.Worker.Event.CEvent;
    import QFLib.Worker.Event.CStartedEvent;
    import QFLib.Worker.Event.CStopEvent;
    import QFLib.Worker.Event.CStoppedEvent;

    import flash.concurrent.Mutex;

    import flash.events.Event;
    import flash.system.MessageChannel;
    import flash.system.Worker;
    import flash.system.WorkerDomain;
    import flash.utils.ByteArray;
    import flash.utils.getQualifiedClassName;

    public class CWorkerRef
	{
        public static const STATE_NEW : int = 0;
        public static const STATE_STARTING : int = 1;
        public static const STATE_STARTED : int = 2;
        public static const STATE_STOPPING : int = 3;
        public static const STATE_STOPPED : int = 4;

		public function CWorkerRef()
		{
		}

        public virtual function dispose() : void
        {
            m_mapMessageCallbacks.clear();
            m_mapMessageClasses.clear();

            m_fnOnWorkerStartFinished = null;

            if( m_theToWorkerChannel )
            {
                m_theToWorkerChannel.close();
                m_theToWorkerChannel = null;
            }
            if( m_theFromWorkerChannel )
            {
                m_theFromWorkerChannel.removeEventListener( Event.CHANNEL_MESSAGE, _onMessageReceived );
                m_theFromWorkerChannel.close();
                m_theFromWorkerChannel = null;
            }

            m_theToWorkerMutex = m_theFromWorkerMutex = null;

            if( m_theWorker != null )
            {
                m_theWorker.removeEventListener( Event.WORKER_STATE, _onWorkerStateChanged );
                m_theWorker.terminate();
                m_theWorker = null;
            }
        }

        public function get name() : String { return m_sName; }
        public function get filename() : String { return m_sFilename }
        public function get state() : int { return m_iState; }

        //
        // function onXXXEventReceived( theWorkerRef : CWorkerRef, event : CXXXEvent ) : void
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

        public function start() : void
        {
            if( m_iState != STATE_NEW && m_iState != STATE_STOPPED ) return ;

            m_theWorker.start();
            m_iState = STATE_STARTING;
        }
        public function stop( bTerminateImmediately : Boolean = false ) : void
        {
            if( bTerminateImmediately )
            {
                m_theWorker.removeEventListener( Event.WORKER_STATE, _onWorkerStateChanged );
                m_theWorker.terminate();
                m_iState = STATE_STOPPED;
            }
            else
            {
                this.send( new CStopEvent() );
                m_iState = STATE_STOPPING;
            }
        }

        public function send( event : CEvent ) : void
        {
            if( m_iState != STATE_STARTED )
            {
                Foundation.Log.logErrorMsg( "CWorkerRef Error: State is not started for send..." );
                return;
            }

            event.eventIndex = ++m_iSendEventIndexCounter;
            if( m_iSendEventIndexCounter == int.MAX_VALUE ) m_iSendEventIndexCounter = 0;

            var aBytes : ByteArray = event.serialize();
            //Foundation.Log.logMsg( "CWorkerRef send: jsonObject index: " + event.eventIndex + ", jsonObject class: " + event.eventClassName );

            m_theToWorkerMutex.lock();

            m_theToWorkerChannel.send( aBytes, -1 );
            var iNum : int = event.eventNumByteArrays;
            for( var i : int = 0; i < iNum; i++ ) // send attached byte arrays if existed
            {
                m_theToWorkerChannel.send( event.getByteArray( i ), -1 );
            }

            m_theToWorkerMutex.unlock();
        }

        internal function _initialize( sName : String, sFilename : String, aBytes : ByteArray, fnOnWorkerStartFinished : Function ) : Boolean
        {
            m_sName = sName;
            m_sFilename = sFilename;
            m_fnOnWorkerStartFinished = fnOnWorkerStartFinished;

            m_theWorker = WorkerDomain.current.createWorker( aBytes );
            if( m_theWorker == null ) return false;

            m_theToWorkerChannel = Worker.current.createMessageChannel( m_theWorker );
            m_theWorker.setSharedProperty( "ToWorker_" + sName, m_theToWorkerChannel );
            m_theFromWorkerChannel = m_theWorker.createMessageChannel( Worker.current );
            m_theWorker.setSharedProperty( "FromWorker_" + sName, m_theFromWorkerChannel );
            m_theToWorkerMutex = new Mutex();
            m_theWorker.setSharedProperty( "ToWorker_Mutex_" + sName, m_theToWorkerMutex );
            m_theFromWorkerMutex = new Mutex();
                m_theWorker.setSharedProperty( "FromWorker_Mutex_" + sName, m_theFromWorkerMutex );

            m_theWorker.addEventListener( Event.WORKER_STATE, _onWorkerStateChanged );
            m_theFromWorkerChannel.addEventListener( Event.CHANNEL_MESSAGE, _onMessageReceived );

            this.registerMessageHandler( CStartedEvent, _onStartedEventReceived );
            this.registerMessageHandler( CStoppedEvent, _onStoppedEventReceived );

            return true;
        }

        private function _onWorkerStateChanged( event : Event ) : void
        {
            if( m_theWorker.state == "running" )
            {
                m_iState = STATE_STARTED;
                send( new CStartEvent( m_sName, m_sFilename ) );
            }
            else if( m_theWorker.state == "terminated" )
            {
                m_iState = STATE_STOPPED;
            }
            //Foundation.Log.logMsg( "m_theWorker.state: " + m_theWorker.state );
        }

        private function _onMessageReceived( event : Event ) : void
        {
            if( event.target != m_theFromWorkerChannel )
            {
                Foundation.Log.logErrorMsg( "CWorkerRef Error: target incorrect..." );
                return;
            }

            m_theFromWorkerMutex.lock();

            var obj : Object;
            while( m_theFromWorkerChannel.messageAvailable )
            {
                obj = m_theFromWorkerChannel.receive();
                m_listMessages.push( obj );
            }

            m_theFromWorkerMutex.unlock();

            //Foundation.Log.logMsg( "CWorkerRef: There're " + m_listMessages.length + " messages to handle..." );
            for( var i : int = 0; i < m_listMessages.length; i++ )
            {
                var aBytes : ByteArray = m_listMessages[ i ] as ByteArray;
                if( aBytes == null )
                {
                    Foundation.Log.logErrorMsg( "CWorkerRef Error: Receive a non-ByteArray object..." );
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
                    if( fnCallback != null ) fnCallback( this, m_theReceivingEvent );
                    m_theReceivingEvent = null;
                }
            }
            else
            {
                var jsonObject : Object = CEvent.unSerialize( aBytes );
                if( jsonObject == null )
                {
                    Foundation.Log.logErrorMsg( "CWorkerRef Error: Read object failed..." );
                    return;
                }

                //Foundation.Log.logMsg( "CWorkerRef received: jsonObject index: " + jsonObject.eventInfoIndex + ", jsonObject class: " + jsonObject.eventInfoClassName );
                clazz = m_mapMessageClasses.find( jsonObject.eventInfoClassName );
                if( clazz != null )
                {
                    var theEvent : CEvent = new clazz();
                    theEvent.jsonObject = jsonObject;

                    if( m_iLastReceivedEventIndex > 0 && theEvent.eventIndex != m_iLastReceivedEventIndex + 1 )
                    {
                        Foundation.Log.logErrorMsg( "CWorkerRef Error: theEvent.eventIndex error, last index: " + m_iLastReceivedEventIndex +
                                                    ", current index: " + theEvent.eventIndex );
                        return ;
                    }
                    m_iLastReceivedEventIndex = theEvent.eventIndex;

                    if( theEvent.eventNumByteArrays > 0 )
                    {
                        m_theReceivingEvent = theEvent;
                    }
                    else
                    {
                        fnCallback = m_mapMessageCallbacks.find( clazz );
                        if( fnCallback != null ) fnCallback( this, theEvent );
                    }
                }
                else
                {
                    Foundation.Log.logErrorMsg( "CWorkerRef Error: find no event class for : " + jsonObject.eventInfoClassName );
                }
            }
        }

        private function _onStartedEventReceived( theWorkerRef : CWorkerRef, event : CStartedEvent ) : void
        {
            m_fnOnWorkerStartFinished( m_sName, m_sFilename, this, 0 );
            //Foundation.Log.logMsg( "worker started: " + event.name );
        }

        private function _onStoppedEventReceived( theWorkerRef : CWorkerRef, event : CStoppedEvent ) : void
        {
            m_theWorker.removeEventListener( Event.WORKER_STATE, _onWorkerStateChanged );
            m_theWorker.terminate();
            m_iState = STATE_STOPPED;
            //Foundation.Log.logMsg( "worker stopped and terminated" );
        }

        //
        private var m_sName : String = null;
        private var m_sFilename : String = null;

        private var m_theWorker : Worker = null;
        private var m_theToWorkerChannel : MessageChannel = null;
        private var m_theFromWorkerChannel : MessageChannel = null;
        private var m_theToWorkerMutex : Mutex = null;
        private var m_theFromWorkerMutex : Mutex = null;

        private var m_mapMessageCallbacks : CMap = new CMap();
        private var m_mapMessageClasses : CMap = new CMap();
        private var m_listMessages : Vector.<Object> = new Vector.<Object>();

        private var m_fnOnWorkerStartFinished : Function = null;
        private var m_iState : int = STATE_NEW;
        private var m_iSendEventIndexCounter : uint = 0;
        private var m_iLastReceivedEventIndex : uint = 0;

        private var m_theReceivingEvent : CEvent = null;
    }
}