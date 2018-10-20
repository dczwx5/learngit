//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/11/15.
 * Time: 17:13
 */
package kof.game.gm.command.currency {

import kof.game.gm.command.gmaeCore.CAbstractCommandHandler;


public class CCurrencyCommandHandler extends CAbstractCommandHandler {
    public function CCurrencyCommandHandler() {
        super();
    }

    override public function dispose() : void {
        super.dispose();
    }

    override protected virtual function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        ret = ret && this.registerConsoleCommand(new CAddVitCommand());
        ret = ret && this.registerConsoleCommand(new CAddBlueDiamondCommand());
        ret = ret && this.registerConsoleCommand(new CAddGoldCommand());
        ret = ret && this.registerConsoleCommand(new CAddPurpleDiamondCommand());
        ret = ret && this.registerConsoleCommand(new CAddCurrencyCommand());

        return ret;
    }
}
}
