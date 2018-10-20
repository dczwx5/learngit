//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2016/10/28.
 */
package kof.game.gm.command.bag {

import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;


public class CBagAddItemExpCommand extends CAbstractConsoleCommand {
    public function CBagAddItemExpCommand( ) {
        super( );


        name = "add_item";
        description = "增加玩家背包道具，Usage：" + this.name + " ietmID addValue";
        this.label = "增加物品";

        this.syncToServer = true;
    }
}
}
