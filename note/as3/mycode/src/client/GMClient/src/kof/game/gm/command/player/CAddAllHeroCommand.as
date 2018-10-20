//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/7/10.
 */
package kof.game.gm.command.player {

import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;

/**
 * 一键招募所有格斗家
 */
public class CAddAllHeroCommand extends CAbstractConsoleCommand {
    public function CAddAllHeroCommand( name : String = null, desc : String = null, label : String = null )
    {
        super( name, desc, label );

        this.name = "add_all_hero";
        this.description = "一键招募所有格斗家，Usage：" + this.name;
        this.label = "一键招募所有格斗家";

        this.syncToServer = true;
    }
}
}
