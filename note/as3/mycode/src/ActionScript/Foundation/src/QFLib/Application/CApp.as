//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/1/29
//----------------------------------------------------------------------------------------------------------------------

package QFLib.Application
{
    import QFLib.Foundation;
    import QFLib.Foundation.CMap;
    import QFLib.Foundation.CSet;
    import QFLib.Foundation.CTime;
    import QFLib.Foundation.CTimer;

    import flash.events.TimerEvent;
    import flash.utils.Timer;

    //
    //
    //
    public class CApp
    {
        public const DEFAULT_RPS : Number = 30.0;
        public const RUN_CTRL_INTERVAL : Number = 30.0;

        public function CApp()
        {
        }

        public function isInitialized() : Boolean { return m_bInitialized; }
        public function initialize() : Boolean
        {
            if( m_bInitialized ) return true;
            m_bInitialized = _initialize();

            for each( var app : CApp in m_setChildApps )
            {
                if( app.initialize() == false ) return false;
            }

            return m_bInitialized;
        }
        public function appName() : String { return _appName(); } // identify itself
        public function unInitialize() : void
        {
            if( m_bInitialized == false ) return;

            for each( var app : CApp in m_setChildApps ) app.unInitialize();

            _unInitialize();
            m_bInitialized = false;
        }

        public function getParentApp() : CApp { return m_theParentApp; }
        public function getChildAppSet() : CSet { return m_setChildApps; }

        public function get dumpMemInfo() : Boolean { return m_bDumpMemInfo; }
        public function set dumpMemInfo( bDump : Boolean ) : void { m_bDumpMemInfo = bDump; }

        public function get quit() : Boolean { return m_bQuit; }
        public function set quit( bQuit : Boolean ) : void { m_bQuit = bQuit; } // exit the run loop

        public function get returnCode() : int { return m_iReturnCode; }
        public function set returnCode( iReturnCode : int ) : void { m_iReturnCode = iReturnCode; }

        public function get maxRPS() : Number { return m_fMaxRPS; }
        public function set maxRPS( fMaxRPS : Number ) : void
        {
            m_fMaxRPS = fMaxRPS;
            if( m_fMaxRPS <= 0.0 ) m_fIntervalPerRun = 0.0;
            else m_fIntervalPerRun = 1.0 / m_fMaxRPS;
        }

        public function get currentRPS() : Number { return m_fRPS; }

        public virtual function registerChildApp( theChildApp : CApp ) : void
        {
            m_setChildApps.add( theChildApp );
            if( theChildApp != null )
            {
                theChildApp._setParentApp( this );
                //theChildApp._SetMain( m_theMain );
            }
        }
        public virtual function unregisterChildApp( theChildApp : CApp ) : void
        {
            m_setChildApps.remove( theChildApp );
            if( theChildApp != null )
            {
                theChildApp._setParentApp( null );
                //theChildApp._SetMain( null );
            }
        }

        public function setDumpSystemInfoInterval( bEnable : Boolean, fSeconds : Number ) : void
        {
            m_bDumpSystemInfo = bEnable;

            m_fTimerControlInterval = fSeconds;
            m_RunOnceTimerControl.interval = fSeconds;

            /*for( var i : int = 0; i < NUM_TIMERS; i++ )
            {
                if( m_aTimers[ i ] != null ) m_aTimers[ i ].SetTimerControlInterval( fSeconds );
            }*/
        }

        public virtual function dumpSystemInfo() : void
        {
            _dumpTimerInfo();

            if( m_bDumpMemInfo )
            {
            }

            var iCount : int = 0;
            for each( var app : CApp in m_setChildApps )
            {
                app.dumpSystemInfo();

                iCount++;
                if( iCount == 4 )
                {
                    if( m_setChildApps.count > iCount ) Foundation.Log.logMsg( "CApp::DumpAllTimerRPS: Display only " + iCount + " of " + m_setChildApps.count + " Apps" );
                    break;
                }
            }
        }

        public function bindTimer( fFPS : Number, theCallback : Function = null, fMaxTimePass : Number = -1.0, bSearchFromHead : Boolean = true ) : int
        {
            var fOneFrame : Number;
            if( fFPS <= 0.0 )
            {
                fOneFrame = 0.0;
                fMaxTimePass = 0.0;
            }
            else
            {
                fOneFrame = 1.0 / fFPS;
                if( ( fMaxTimePass >= 0 ) && ( fMaxTimePass < fOneFrame ) ) fMaxTimePass = fOneFrame;
            }

            if( theCallback == null ) theCallback = onTimer; // call default

            var i : int;
            if( bSearchFromHead )
            {
                for( i = 0; i < NUM_TIMERS; i++ )
                {
                    if( m_aTimers[ i ] == null )
                    {
                        m_aTimers[ i ] = new CSyncTimer( i );
                        m_aTimers[ i ].bind( fFPS, theCallback, fMaxTimePass );
                        return i;
                    }
                }
            }
            else
            {
                for( i = NUM_TIMERS - 1; i >= 0; i-- )
                {
                    if( m_aTimers[ i ] == null )
                    {
                        m_aTimers[ i ] = new CSyncTimer( i );
                        m_aTimers[ i ].bind( fFPS, theCallback, fMaxTimePass );
                        return i;
                    }
                }
            }

            return -1;
        }

        public function unbindTimer( iTimerID : int ) : void
        {
            if( iTimerID < 0 || iTimerID >= NUM_TIMERS ) return;
            if( m_aTimers[ iTimerID ] != null )
            {
                m_aTimers[ iTimerID ].unbind();
                m_aTimers[ iTimerID ] = null;
            }
        }

        public function getTimer( iTimerID : int ) : CSyncTimer
        {
            if( iTimerID < 0 || iTimerID >= NUM_TIMERS ) return null;
            return m_aTimers[ iTimerID ];
        }

        public virtual function runOnce() : void
        {
            // each timer's run once will be called by their own timer, so comment this section
            /*for( var i : int = 0; i < NUM_TIMERS; i++)
            {
                if( m_aTimers[i] != null ) m_aTimers[i].runOnce();
            }*/

            for each( var app : CApp in m_setChildApps )
            {
                app.runOnce();
            }

            // Increase run times
            ++m_iRuns;

            // Calculate RPS
            var fTimePeriod : Number = m_RunOnceTimerControl.seconds();
            if( fTimePeriod > 0.1 )
            {
                m_fRPS = ( Number( m_iRuns ) ) / fTimePeriod;
            }

            // Reset timer if on time
            if( fTimePeriod >= m_RunOnceTimerControl.interval )
            {
                if( m_bDumpSystemInfo && getParentApp() == null )
                {
                    // Show system time & RPS
                    Foundation.Log.logMsg( "" );

                    var fRPSTime : Number = 0.0;
                    if( m_fRPS > 0.0 ) fRPSTime = 1.0 / m_fRPS;

                    Foundation.Log.logMsg( "** RPS:" + m_fRPS.toFixed( 2 ) +
                                           "/" + fRPSTime.toFixed( 3 ) + "s" );

                    dumpSystemInfo();
                    Foundation.Log.flush();
                }

                m_RunOnceTimerControl.reset();
                m_iRuns = 0;
            }
        }

        public function run() : void
        {
            if( m_bInitialized == false ) return;

            m_theRunTimer = new Timer( m_fIntervalPerRun * 1000.0 );
            m_theRunTimer.addEventListener( TimerEvent.TIMER, OnRun );
            m_theRunTimer.start();

            function OnRun() : void
            {
                if( m_bQuit )
                {
                    m_theRunTimer.removeEventListener( TimerEvent.TIMER, OnRun );
                    m_theRunTimer.stop();
                    m_theRunTimer = null;

                    unInitialize();
                }
                else
                {
                    try
                    {
                        // Do run
                        runOnce();
                    }
                    catch( e : Error )
                    {
                        Foundation.Log.logErrorMsg( "Exception caught by Application.CApp.Run" );
                        Foundation.Log.logErrorMsg( e.toString() );
                    }
                }

            }
        }

        public virtual function onTimer( iTimerID : int, fTimePass : Number ) : void {}

        //
        // for user to overwrite
        //
        protected virtual function _initialize() : Boolean { return false; }
        protected virtual function _appName() : String { return "Unnamed"; } // identify itself
        protected virtual function _unInitialize() : void {} // override this to release resources

        protected function _setParentApp( theParentApp : CApp ) : void { m_theParentApp = theParentApp; }

        private function _dumpTimerInfo() : void
        {
            var sContent : String = "";

            for( var i : int = 0; i < NUM_TIMERS; i++ )
            {
                if( m_aTimers[ i ] != null )
                {
                    sContent += m_aTimers[ i ].dumpFPS();
                }
            }

            Foundation.Log.logMsg( sContent );
        }

        //
        //
        private var m_setChildApps : CSet = new CSet(); // child Apps
        private var m_theParentApp : CApp = null;

        private const NUM_TIMERS : int = 4;
        private var m_aTimers : Vector.<CSyncTimer> = new Vector.<CSyncTimer>( NUM_TIMERS );

        private var m_fTimerControlInterval : Number = RUN_CTRL_INTERVAL;
        private var m_RunOnceTimerControl : CTimer = new CTimer( m_fTimerControlInterval );

        private var m_fMaxRPS : Number = DEFAULT_RPS;               // maximum rps
        private var m_fIntervalPerRun : Number = 1.0 / m_fMaxRPS;   // interval per run
        private var m_fRPS : Number = 0.0;                          // current run per second
        //private var m_fStartTimestamp : Number = CTime.getCurrentTimestamp();

        private var m_iReturnCode : int = 0;
        private var m_bDumpSystemInfo : Boolean = true;
        private var m_bDumpMemInfo : Boolean = true;
        private var m_bInitialized : Boolean = false;
        private var m_bQuit : Boolean = false;

        //
        private var m_iRuns : int = 0;

        private var m_theRunTimer : Timer = null;
    }


}