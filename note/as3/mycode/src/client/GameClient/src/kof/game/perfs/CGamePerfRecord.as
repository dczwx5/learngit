package kof.game.perfs
{

import flash.system.System;

import kof.framework.CAbstractHandler;
import kof.framework.IAppTimer;

public class CGamePerfRecord extends CAbstractHandler {

    /** @private */
    private var m_pTimer : IAppTimer;
    CONFIG::debug {
        private var m_theFrameRates : Vector.<Number>;
    }
    private var m_fMinFrameRate : Number;
    private var m_fMaxFrameRate : Number;
    private var m_fFrameRateIns : Number;

    CONFIG::debug {
        private var m_theMemUsages : Vector.<Number>;
    }
    private var m_fMinMemUsage : Number;
    private var m_fMaxMemUsage : Number;
    private var m_fMemUsageIns : Number;

    public function CGamePerfRecord() {
        super();
    }

    override public function dispose() : void {
        super.dispose();
    }

    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        if ( ret ) {
            m_pTimer = system.stage.timer as IAppTimer;

            CONFIG::debug {
                m_theFrameRates = new <Number>[];
                m_theMemUsages = new <Number>[];
            }
        }

        return ret;
    }

    override protected function onShutdown() : Boolean {
        var ret : Boolean = super.onShutdown();

        m_pTimer = null;

        CONFIG::debug {
            if ( m_theFrameRates )
                m_theFrameRates.splice( 0, m_theFrameRates.length );
            m_theFrameRates = null;

            if ( m_theMemUsages )
                m_theMemUsages.splice( 0, m_theMemUsages.length );
            m_theMemUsages = null;
        }

        return ret;
    }

    public function get maxFrameRate() : Number { return m_fMaxFrameRate; }
    public function get minFrameRate() : Number { return m_fMinFrameRate; }
    public function get avgFrameRate() : Number {
        if ( !isNaN( m_fFrameRateIns ) && m_theFrameRates.length )
            return m_fFrameRateIns / m_theFrameRates.length;
        else if ( !isNaN( m_fMinFrameRate) && !isNaN( m_fMaxFrameRate ) )
            return ( m_fMinFrameRate + m_fMaxFrameRate ) / 2;
        return 0;
    }

    public function get maxMemUsage() : Number { return m_fMaxMemUsage; }
    public function get minMemUsage() : Number { return m_fMinMemUsage; }
    public function get avgMemUsage() : Number {
        if ( !isNaN( m_fMemUsageIns ) && m_theMemUsages.length )
            return m_fMemUsageIns / m_theMemUsages.length;
        else if ( !isNaN( m_fMinMemUsage ) && !isNaN( m_fMaxMemUsage) )
            return ( m_fMinMemUsage + m_fMaxMemUsage ) / 2;
        return 0;
    }

    final public function get empty() : Boolean {
        return isNaN( m_fFrameRateIns );
    }

    public function snapshot() : void {
        if ( isNaN( m_fFrameRateIns ) ) m_fFrameRateIns = 0.0;
        if ( isNaN( m_fMinFrameRate ) ) m_fMinFrameRate = system.stage.flashStage.frameRate;
        if ( isNaN( m_fMaxFrameRate ) ) m_fMaxFrameRate = 0.0;

        if ( m_pTimer ) {
            var fps : Number = m_pTimer.frameRate;
            CONFIG::debug {
                m_theFrameRates.push( fps ); // FrameRate.
            }
            m_fFrameRateIns += fps;

            m_fMaxFrameRate = Math.max( m_fMaxFrameRate, fps );
            m_fMinFrameRate = Math.min( m_fMinFrameRate, fps );
        }

        if ( isNaN( m_fMaxMemUsage ) ) m_fMaxMemUsage = M( System.totalMemory );
        if ( isNaN( m_fMinMemUsage ) ) m_fMinMemUsage = M( System.totalMemory );
        if ( isNaN( m_fMemUsageIns ) ) m_fMemUsageIns = 0.0;

        m_fMinMemUsage = Math.min( m_fMinMemUsage, M( System.totalMemory ) );
        m_fMaxMemUsage = Math.max( m_fMaxMemUsage, M( System.totalMemory ) );

        CONFIG::debug {
            m_theMemUsages.push( M( System.totalMemory ) ); // mem usages.
        }
        m_fMemUsageIns += M( System.totalMemory );
    }

    protected function M( byte : uint ) : uint {
        return Math.round( byte / 1048576 );
    }

    public function clear() : void {
        m_fFrameRateIns = NaN;
        m_fMinFrameRate = NaN;
        m_fMaxFrameRate = NaN;

        m_fMemUsageIns = NaN;
        m_fMinMemUsage = NaN;
        m_fMaxMemUsage = NaN;

        CONFIG::debug {
            if ( m_theFrameRates ) m_theFrameRates.length = 0;
            else m_theFrameRates = new <Number>[];
            if ( m_theMemUsages ) m_theMemUsages.length = 0;
            else m_theMemUsages = new <Number>[];
        }
    }

} // class CGamePerfRecord
} // package kof.game.perfs
