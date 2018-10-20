//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.Tutorial.tutorPlay.action {

import QFLib.Foundation.CKeyboard;
import flash.ui.Keyboard;
import kof.framework.CAppSystem;
import kof.game.Tutorial.data.CTutorActionInfo;

public class CTutorActionTestPressP extends CTutorActionBase {

    public function CTutorActionTestPressP(actionInfo : CTutorActionInfo, system : CAppSystem ) {
        super( actionInfo, system );
    }

    override public function dispose() : void {
        super.dispose();

        if (m_pKeyboard) {
            m_pKeyboard.unregisterKeyCode(true, Keyboard.P, _onKeyDown);

            m_pKeyboard.dispose();
            m_pKeyboard = null;
        }
    }

    override public function start() : void {
        super.start();

        m_pKeyboard = new CKeyboard(_system.stage.flashStage);
        m_pKeyboard.registerKeyCode(true, Keyboard.P, _onKeyDown);

    }

    private function _onKeyDown(keyCode:uint):void {
        switch ( keyCode ) {
            case Keyboard.P:
                _actionValue = true;
                break;
        }
    }

    private var m_pKeyboard:CKeyboard;

}
}

