//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------------------------
// (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Craeted by Leo.Li 2018/5/31
//----------------------------------------------------------------------------------------------------------------------
package kof.game.effort.view {

import kof.game.arena.view.CArenaRoleEmbattleTipsView;
import kof.game.common.view.CViewManagerHandler;

/**
 * @author Leo.Li
 * @date 2018/5/31
 */
public class CEffortUIHandler extends CViewManagerHandler {
    public function CEffortUIHandler() {
        super();
    }

    override protected function onSetup():Boolean
    {
        var ret : Boolean = super.onSetup();
        this.registTips(CEffortTipViewHandler);

        return ret;
    }

    public override function dispose() : void {
        super.dispose();

    }
}
}
