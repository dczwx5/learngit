//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.Tutorial.tutorPlay.action {

import kof.framework.CAppSystem;
import kof.game.Tutorial.data.CTutorActionInfo;
import kof.game.instance.CInstanceSystem;

public class CTutorActionFinishWhenReturnMainCity extends CTutorActionBase {

    public function CTutorActionFinishWhenReturnMainCity(actionInfo : CTutorActionInfo, system : CAppSystem ) {
        super( actionInfo, system );
    }

    override public function dispose() : void {
        super.dispose();

    }

    override public function start() : void {
        super.start();

        var pInstanceSystem:CInstanceSystem = _tutorManager.system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
        pInstanceSystem.addExitProcess(null, null, _onFinish, null, 1);
    }

    private function _onFinish() : void {
        _actionValue = true;
    }

}
}

