//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/9/26.
 */
package kof.game.item {

import kof.game.common.view.CViewManagerHandler;
import kof.game.item.data.CRewardListData;
import kof.game.item.enum.EItemWndType;
import kof.game.item.view.CRewardFullView;
import kof.game.item.view.tips.CItemPackageTipsView;
import kof.game.item.view.tips.CItemTipsView;


public class CItemUIHandler extends CViewManagerHandler {

    public function CItemUIHandler() {
    }
    public override function dispose() : void {
        super.dispose();

    }

    override protected function onSetup():Boolean {
        var ret : Boolean = super.onSetup();
        this.registTips(CItemPackageTipsView); // 纵向奖励
        this.registTips(CItemTipsView); // 横向奖励

        this.addViewClassHandler(EItemWndType.TYPE_REWARD_FULL, CRewardFullView);

        return ret;
    }

    public function showRewardFull(data:CRewardListData) : void {
        this.show(EItemWndType.TYPE_REWARD_FULL, null, null, data);
    }
    public function hideRewardFull() : void {
        this.hide(EItemWndType.TYPE_REWARD_FULL);
    }

}
}
