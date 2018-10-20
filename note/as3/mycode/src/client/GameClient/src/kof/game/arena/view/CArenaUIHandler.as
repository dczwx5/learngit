//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/8/9.
 */
package kof.game.arena.view {

import kof.game.common.view.CViewManagerHandler;

public class CArenaUIHandler extends CViewManagerHandler {
    public function CArenaUIHandler()
    {
        super();
    }

    override protected function onSetup():Boolean
    {
        var ret : Boolean = super.onSetup();
        this.registTips(CArenaRoleEmbattleTipsView);

        return ret;
    }

    public override function dispose() : void {
        super.dispose();

    }
}
}
