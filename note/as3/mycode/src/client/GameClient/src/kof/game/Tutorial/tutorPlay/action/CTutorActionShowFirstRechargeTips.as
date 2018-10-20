//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.Tutorial.tutorPlay.action {

import kof.framework.CAppSystem;
import kof.game.Tutorial.data.CTutorActionInfo;
import kof.game.recharge.firstRecharge.CFirstRechargeSystem;
import kof.game.recharge.firstRecharge.CTipsViewHandler;

public class CTutorActionShowFirstRechargeTips extends CTutorActionBase {

    public function CTutorActionShowFirstRechargeTips(actionInfo : CTutorActionInfo, system : CAppSystem ) {
        super( actionInfo, system );
    }

    override public function dispose() : void {
        super.dispose();

    }

    override public function start() : void {
        super.start();
        var pFirstRechargeSystem:CFirstRechargeSystem = _system.stage.getSystem(CFirstRechargeSystem) as CFirstRechargeSystem;
        if (pFirstRechargeSystem) {
            var pTipsViewHandler:CTipsViewHandler = pFirstRechargeSystem.getBean(CTipsViewHandler) as CTipsViewHandler;
            if (pTipsViewHandler.isViewShow == false) {
                pTipsViewHandler.showActiveTips(5);
            }
        }

        _actionValue = true;
    }

}
}

