//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/2/4
//----------------------------------------------------------------------------------------------------------------------

package QFLib.Foundation
{
    import flash.utils.getTimer;

    //
    //
    //
    public class CTimer
    {
        public function CTimer( fTimeIntervl : Number = -1.0 )
        {
            m_fInterval = fTimeIntervl;
            reset();
        }

        public function reset() : void
        {
            m_iLastTime = getTimer();
        }
        public function seconds() : Number
        {
            var iTime : int = getTimer() - m_iLastTime;
            return Number( iTime ) / 1000.0;
        }

        public function isOnTime() : Boolean
        {
            if( m_bEnable == false ) return false;

            if( m_fInterval < 0.0 ) return false;
            else if( m_fInterval == 0.0 ) return true;
            else
            {
                if( seconds() < m_fInterval ) return false;
                else return true;
            }
        }

        public function get enabled() : Boolean
        {
            return m_bEnable;
        }
        public function set enabled( bEnable : Boolean ) : void
        {
            m_bEnable = bEnable;
        }
        public function get interval() : Number
        {
            return m_fInterval;
        }

        public function set interval( fIntervalInSec : Number ) : void
        {
            m_fInterval = fIntervalInSec;
        }

        //
        //
        private var m_iLastTime : int = 0.0;
        private var m_fInterval : Number = 0.0;
        private var m_bEnable : Boolean = true;
    }
    ;


}