//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/8/4.
 */
package kof.game.gm.command.currency {

import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;

public class CAddCurrencyCommand extends CAbstractConsoleCommand {
    public function CAddCurrencyCommand( name : String = null, desc : String = null, label : String = null ) {

        super( name, desc );
        this.name = "add_currency";
        this.description = "添加货币，Usage：" + this.name + " type count";
        this.label = "添加货币";

        this.syncToServer = true;
    }
}
}
