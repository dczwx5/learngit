//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/5.
 */
package kof.game.player.childrenEvent {

import kof.game.player.CPlayerChildrenEventDispatcher;
import kof.game.player.data.CPlayerBaseData;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.subData.CVipData;
import kof.game.player.event.CPlayerEvent;

public class CPlayerVipLevelUpEventProcess extends CPlayerChildrenEventProcess {
    public function CPlayerVipLevelUpEventProcess(childrenEventDispatcher:CPlayerChildrenEventDispatcher) {
        super(childrenEventDispatcher, CPlayerEvent.PLAYER_VIP_LEVEL);
    }

    public override function process(newDataObject:Object, oldPlayerData:CPlayerData) : void {
        if(newDataObject.hasOwnProperty(CVipData._vipLv)){
            //vip等级是否有变化更新
            _isChange = oldPlayerData.vipData.vipLv != newDataObject[CVipData._vipLv];
        }
    }
}
}
