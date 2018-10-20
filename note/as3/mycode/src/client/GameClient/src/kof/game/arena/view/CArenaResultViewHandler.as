//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/7/18.
 */
package kof.game.arena.view {

import kof.game.common.view.resultWin.CMultiplePVPResultViewHandler;
import kof.game.fightui.compoment.CSkillViewHandler;
import kof.game.lobby.CLobbySystem;

/**
 * 竞技场结算界面
 */
public class CArenaResultViewHandler extends CMultiplePVPResultViewHandler {

    public function CArenaResultViewHandler( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override protected function _exitInstance():void
    {
        var skillViewHandler:CSkillViewHandler = system.stage.getSystem(CLobbySystem).getHandler(CSkillViewHandler) as CSkillViewHandler;
        if(skillViewHandler)
        {
            skillViewHandler.showAllSkillItems();
        }

        super._exitInstance();
    }
}
}
