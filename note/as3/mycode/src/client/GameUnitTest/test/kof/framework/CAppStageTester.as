//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.framework {

import flash.events.Event;
import flash.events.TimerEvent;
import flash.utils.Timer;

import flexunit.framework.Assert;

import kof.util.CAssertUtils;

import org.flexunit.async.Async;

/**
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CAppStageTester {

    private static var m_pTimer : Timer;

    public function CAppStageTester() {

    }

    [Before]
    public function setUp() : void {
        m_pTimer = new Timer( Number( 1.0 / 30 ) );
    }

    [After]
    public function tearDown() : void {
        if ( m_pTimer )
            m_pTimer.stop();

        m_pTimer = null;
    }

    private function newStage() : CAppStage {
        var pStage : CAppStage = new CAppStage();

        try {
            pStage.initWithStage( null, null );
        } catch ( e : Error ) {
            // ignore.
        }
        return pStage;
    }

    [Test]
    public function testCreation() : void {
        var pStage : CAppStage = this.newStage();

        CAssertUtils.assertNull( pStage.timer );
        CAssertUtils.assertNull( pStage.configuration );
        CAssertUtils.assertNull( pStage.flashStage );
        CAssertUtils.assertNull( pStage.vfs );
        CAssertUtils.assertTrue( pStage.isInitialized );
    }

    [Test(async)]
    public function runStageWithNothing() : void {
        var pStage : CAppStage = this.newStage();

        // Call start.
        pStage.start();

        // start the timer and advanced the stage.
        m_pTimer.addEventListener( TimerEvent.TIMER, _onTimer, false, 0, true );
        m_pTimer.start();

        function _onTimer( event : TimerEvent ) : void {
            pStage.tickUpdate( m_pTimer.delay );
            if ( pStage.isStarted || pStage.isFailed ) {
                m_pTimer.dispatchEvent( new TimerEvent( TimerEvent.TIMER_COMPLETE ) );
            }
        }

        Async.proceedOnEvent( this, m_pTimer, TimerEvent.TIMER_COMPLETE );
    }

    [Test(async, timeout="1000")]
    public function runStageWithSingleSimpleAppSystem() : void {
        var pStage : CAppStage = this.newStage();
        var pSystem : CAppSystem = new CTestSimpleSystem();

        pStage.addSystem( pSystem );
        pStage.start();

        var nTickCount : int = 0;

        // start the timer and advanced the stage.
        m_pTimer.addEventListener( TimerEvent.TIMER, _onTimer, false, 0, true );
        m_pTimer.start();

        function _onTimer( event : TimerEvent ) : void {
            nTickCount++;
            pStage.tickUpdate( m_pTimer.delay );

            if ( nTickCount >= 1 && nTickCount < 4 ) {
                // first: pStage: doStart => pSystem: addSeq(start).
                Assert.assertTrue( pStage.isStarting );
                Assert.assertTrue( !pStage.isStarted );
                Assert.assertTrue( pStage.isRunning );

                Assert.assertTrue( pSystem.isStarting );
                Assert.assertTrue( !pSystem.isStarted );
                Assert.assertTrue( pSystem.isRunning );
            } else if ( nTickCount >= 4 ) {
                Assert.assertTrue( pSystem.isRunning );
                Assert.assertTrue( pSystem.isStarted );
                Assert.assertFalse( pSystem.isStarting );

                Assert.assertTrue( pStage.isRunning );
                Assert.assertFalse( pStage.isStarting );
                Assert.assertTrue( pStage.isStarted );
            }

            if ( pSystem.isStarted || pSystem.isFailed ) {
                Assert.assertEquals( 4, nTickCount );
                if ( pStage.isStarted || pStage.isFailed ) {
                    Assert.assertEquals( 4, nTickCount );
                    Assert.assertEquals( pStage, pSystem.stage );
                    Assert.assertNotNull( m_pTimer );
                    m_pTimer.dispatchEvent( new TimerEvent( TimerEvent.TIMER_COMPLETE ) );
                }
            }
        }

        Async.proceedOnEvent( this, pStage, CAppStageEvent.ENTER );
        Async.proceedOnEvent( this, pSystem, Event.COMPLETE );
        Async.proceedOnEvent( this, m_pTimer, TimerEvent.TIMER_COMPLETE );
    }

}
}

import flash.events.Event;

import kof.framework.CAppStage;
import kof.framework.CAppSystem;

/**
 * @author Jeremy (jeremy@qifun.com)
 */
class CTestSimpleSystem extends CAppSystem {

    function CTestSimpleSystem() {
        super();
    }

    override protected function enterStage( appStage : CAppStage ) : void {
        super.enterStage( appStage );

        dispatchEvent( new Event( Event.COMPLETE ) );
    }

}
