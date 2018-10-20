//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character {

import flash.display.Shape;
import flash.events.Event;
import flash.utils.getTimer;

import kof.game.core.CGameObject;
import kof.game.core.CECSLoop;

public class CTargetTester {

    static private var m_pGameSystem : CECSLoop;
    static private var m_pShape : Shape;
    static private var m_fLastTime : Number;

    private var m_pObj : CGameObject;

    public function CTargetTester() {

    }

    [BeforeClass]
    static public function runBeforeClass() : void {
        // CGameObject run need CECSLoop.
        m_pGameSystem = new CECSLoop();
        m_pShape = new Shape();

        m_pShape.addEventListener( Event.ENTER_FRAME, _onEnterFrame );
        m_pGameSystem.start();
    }

    [AfterClass]
    static public function runAfterClass() : void {
        // dispose CECSLoop.
        m_pGameSystem.dispose();

        m_pShape = null;
        m_pGameSystem = null;
    }

    static private function _onEnterFrame( e : Event ) : void {
        var delta : Number = 0;
        if ( !isNaN( m_fLastTime ) ) {
            delta = getTimer() - m_fLastTime;
        }

        m_fLastTime = getTimer();
        m_pGameSystem.update( delta );
    }

    [Before]
    public function runBeforeEveryTest() : void {
        m_pObj = new CGameObject();
        m_pGameSystem.addObject( m_pObj );
    }

    [After]
    public function runAfterEveryTest() : void {
        m_pObj.dispose();
        m_pGameSystem.removeObject( m_pObj );
    }

    [Test]
    public function testAdded() : void {
        m_pObj.addComponent( new CTarget() );
    }

}
}
