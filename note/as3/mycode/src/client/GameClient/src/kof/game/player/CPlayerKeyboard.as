//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Administrator on 2016/9/26.
 */
package kof.game.player {

import QFLib.Foundation.CKeyboard;

import flash.events.Event;

import flash.events.MouseEvent;
import flash.ui.Keyboard;
import kof.framework.CAbstractHandler;
import kof.framework.IDatabase;
import kof.game.bag.CBagSystem;
import kof.game.instance.CInstanceSystem;
import kof.game.level.CLevelSystem;
import kof.game.playerTeam.CPlayerTeamSystem;

// test only
public class CPlayerKeyboard extends CAbstractHandler {
    public function CPlayerKeyboard() {

    }
    public override function dispose() : void {
        super.dispose();
        m_pKeyboard.unregisterKeyCode(true, Keyboard.C, _onKeyDown); // auto test

        m_pKeyboard.dispose();
        m_pKeyboard = null;
    }
    override protected function onSetup():Boolean {
        m_pKeyboard = new CKeyboard(system.stage.flashStage);
        m_pKeyboard.registerKeyCode(true, Keyboard.B, _onKeyDown); // auto test
        m_pKeyboard.registerKeyCode(true, Keyboard.N, _onKeyDown); // auto test
        m_pKeyboard.registerKeyCode(true, Keyboard.M, _onKeyDown); // auto test
        m_pKeyboard.registerKeyCode(true, Keyboard.V, _onKeyDown); // auto test

//        system.stage.flashStage.addEventListener(MouseEvent.CLICK, _onClick);
        return true;
    }
    private function _onClick(e:Event) : void {
        var a:int = 1;
        a = a+1;
        a = a+2;
        trace(a);
    }
    private function _onKeyDown(keyCode:uint):void {
        switch ( keyCode ) {
            case Keyboard.B:

                break;
            case Keyboard.N:
                break;
            case Keyboard.M:

                break;
            case Keyboard.V:
//                    var playerSystem:CPlayerTeamSystem = system.stage.getSystem(CPlayerTeamSystem) as CPlayerTeamSystem;
//                playerSystem.uiHandler.hideCreateTeam();
//                    playerSystem.uiHandler.showCreateTeam();
                break;
        }
    }


    private function get _databaseSystem() : IDatabase {
        return system.stage.getSystem(IDatabase) as IDatabase;
    }
    private function get _bagSystem() : CBagSystem {
        return system.stage.getSystem(CBagSystem) as CBagSystem;
    }
    private function get _instanceSystem() : CInstanceSystem {
        return system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
    }
    private function get _levelSystem() : CLevelSystem {
        return system.stage.getSystem(CLevelSystem) as CLevelSystem;
    }
    private var m_pKeyboard:CKeyboard;

}
}
