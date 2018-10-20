//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package QFLib.Foundation
{

import QFLib.Interface.IDisposable;
import QFLib.Interface.IUpdatable;

import flash.utils.getTimer;

/**
 *
 */
public class CTimeDog implements IUpdatable, IDisposable
{

    private var m_fElapsedTime : Number;
    private var m_fStartTime : Number;
    private var m_fDuration : Number;

    private var m_pFnTimeEnd : Function;
    private var m_pFnStop : Function;

    private var m_bRunning : Boolean;

    /**
     * Creates an new CTimeDog.
     *
     * @param pfnTimeEnd Function callback by time end.
     * @param pfnStop Function callback by stop.
     */
    public function CTimeDog( pfnTimeEnd : Function = null, pfnStop : Function = null )
    {
        super();

        m_pFnTimeEnd = pfnTimeEnd;
        m_pFnStop = pfnStop;
        m_bRunning = false;
        m_fElapsedTime = m_fStartTime = NaN;
    }

    final public function get running() : Boolean {
        return m_bRunning;
    }

    public function dispose() : void
    {
        m_pFnTimeEnd = null;
        m_pFnStop = null;
    }

    public function start( fDuration : Number = NaN ) : void
    {
        m_bRunning = true;
        m_fStartTime = Number( getTimer() / 1000.0 );
        m_fElapsedTime = m_fStartTime;
        if ( !isNaN( fDuration ) )
            m_fDuration = fDuration;
    }

    public function stop() : void
    {
        m_bRunning = false;
        m_fStartTime = NaN;
        m_fElapsedTime = NaN;

        if ( m_pFnStop )
            m_pFnStop();
    }

    public function update( delta : Number ) : void
    {
        if ( !m_bRunning )
            return;

        m_fElapsedTime += delta;

        if ( m_fElapsedTime - m_fStartTime >= m_fDuration )
        {
            // hit.
            if ( null != m_pFnTimeEnd )
                m_pFnTimeEnd();
            this.stop();
        }
    }

}
}
