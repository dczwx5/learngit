//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.framework {

import flash.events.TimerEvent;
import flash.utils.Timer;

public class CAppSystemTester {

    private static const FPS : Number = 1.0 / 60;
    // Use as "ENTER_FRAME" tick.
    private var m_pTimer : Timer;
    private var m_pCurStage : CAppStage;

    public function CAppSystemTester() {

    }

    [Before]
    public function runBeforeEveryTest() : void {
        m_pTimer = new Timer( FPS );
        m_pTimer.addEventListener( TimerEvent.TIMER, _onTimer, false, 0, true );
        m_pTimer.start();

        m_pCurStage = new CAppStage();
        try {
            m_pCurStage.initWithStage( null );
        } catch ( e : * ) {
        }
    }

    [After]
    public function runAfterEveryTest() : void {
        if ( m_pTimer ) {
            m_pTimer.removeEventListener( TimerEvent.TIMER, _onTimer );
            m_pTimer.stop();
        }
        m_pTimer = null;

        if ( m_pCurStage ) {
            m_pCurStage.dispose();
        }
        m_pCurStage = null;
    }

    /** @private */
    private function _onTimer( e : TimerEvent ) : void {
        m_pCurStage.tickUpdate( Number( 0.001 * m_pTimer.delay ) );
    }

    [Test(async)]
    public function testStartUpWithNoChildren() : void {
        
    }

}
}
