//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/3/9
//----------------------------------------------------------------------------------------------------------------------

package QFLib.Application
{
    import QFLib.Foundation;
    import QFLib.Foundation.CMap;
    import QFLib.Foundation.CTime;
    import QFLib.Foundation.CTimer;

    import flash.events.TimerEvent;
    import flash.system.System;
    import flash.utils.Timer;

    //
    //
    //
    public class CSyncTimer
    {
        public function CSyncTimer( iID : int )
        {
            m_iTimerID = iID;
        }

        public function bind( fFrameRate : Number, theCallback : Function, fMaxTimePass : Number = -1.0 ) : void
        {
            m_fIntervalPerRun = 1.0 / fFrameRate;
            m_theCallback = theCallback;
            m_fMaxTimePass = fMaxTimePass;

            m_theRunTimer = new Timer( m_fIntervalPerRun * 1000.0 );
            m_theRunTimer.addEventListener( TimerEvent.TIMER, _onTimer );
            m_theRunTimer.start();
        }
        public function unbind() : void
        {
            m_theRunTimer.removeEventListener( TimerEvent.TIMER, _onTimer );
            m_theRunTimer.stop();
            m_theRunTimer = null;
        }

        public function get currentRPS() : Number { return m_fCurrentFPS; }

        public function runOnce() : void
        {
            var fTime : Number = m_Timer.seconds();
            var fTimeDiff : Number = fTime - m_fLastTime;

            if( m_fMaxTimePass > 0.0 )
            {
                if( fTimeDiff > m_fMaxTimePass ) fTimeDiff = m_fMaxTimePass;
            }

            if( fTime > m_fResetInterval )
            {
                m_Timer.reset();
                m_iRunCounter = 0;

                m_fLastTime = 0.0;
            }
            else
            {
                m_iRunCounter++;
                m_fLastTime = fTime;

                if( fTime > 0.5 )
                {
                    m_fCurrentFPS = Number( m_iRunCounter / fTime );
                }
            }

            if( m_theCallback != null ) m_theCallback( m_iTimerID, fTimeDiff );
        }

        public function dumpFPS() : String
        {
            return " ST:" + m_iTimerID + "(" + m_fCurrentFPS.toFixed( 2 ) + "fps), ";
        }

        private function _onTimer( event : TimerEvent ) : void
        {
            runOnce();
            //if( m_theCallback != null ) m_theCallback( m_iTimerID, m_fIntervalPerRun );
        }

        //
        //
        private var m_iTimerID : int = -1;
        private var m_iRunCounter : int = 0;
        private var m_fCurrentFPS : Number = 0.0;
        private var m_fIntervalPerRun : Number = 0.0;

        private var m_fResetInterval : Number = 5.0;
        private var m_fLastTime : Number = 0.0;
        private var m_fMaxTimePass : Number = -1.0;
        private var m_Timer : CTimer = new CTimer( m_fResetInterval );
        private var m_theRunTimer : Timer = null;
        private var m_theCallback : Function = null;


   }


}