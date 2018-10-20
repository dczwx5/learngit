//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/7/10.
 */
package kof.game.gm.command.player {

import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;

public class CAddSingleHeroCommand extends CAbstractConsoleCommand {
    public function CAddSingleHeroCommand( name : String = null, desc : String = null, label : String = null )
    {
        super( name, desc, label );

        this.name = "add_hero";
        this.description = "招募单个格斗家，Usage：" + this.name + " roleId";
        this.label = "招募单个格斗家";

        this.syncToServer = true;
    }
}
}
