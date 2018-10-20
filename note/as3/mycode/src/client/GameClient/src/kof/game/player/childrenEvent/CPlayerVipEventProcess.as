//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/5.
 */
package kof.game.player.childrenEvent {

import kof.game.player.CPlayerChildrenEventDispatcher;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.subData.CVipData;
import kof.game.player.event.CPlayerEvent;

public class CPlayerVipEventProcess extends CPlayerChildrenEventProcess {
    public function CPlayerVipEventProcess(childrenEventDispatcher:CPlayerChildrenEventDispatcher) {
        super(childrenEventDispatcher, CPlayerEvent.PLAYER_VIP);
    }

    public override function process(newDataObject:Object, oldPlayerData:CPlayerData) : void {
        if(newDataObject.hasOwnProperty(CVipData._vipLv)){
            _isChange = oldPlayerData.vipData.vipLv != newDataObject[CVipData._vipLv];
        }
        if (!_isChange && newDataObject.hasOwnProperty(CVipData._vipExp)) {
            _isChange = oldPlayerData.vipData.vipExp != newDataObject[CVipData._vipExp];
        }
        if (!_isChange && newDataObject.hasOwnProperty(CVipData._vipGifts)) {
            _isChange = oldPlayerData.vipData.vipGifts != newDataObject[CVipData._vipGifts];
        }
        if (!_isChange && newDataObject.hasOwnProperty(CVipData._vipReward)) {
            _isChange = oldPlayerData.vipData.vipRewards != newDataObject[CVipData._vipReward];
        }
        if (!_isChange && newDataObject.hasOwnProperty(CVipData._superVip)) {
            _isChange = oldPlayerData.vipData.superVip != newDataObject[CVipData._superVip];
        }
        if (!_isChange && newDataObject.hasOwnProperty(CVipData._singleRecharge)) {
            _isChange = oldPlayerData.vipData.singleRecharge != newDataObject[CVipData._singleRecharge];
        }
        if (!_isChange && newDataObject.hasOwnProperty(CVipData._totalRecharge)) {
            _isChange = oldPlayerData.vipData.totalRecharge != newDataObject[CVipData._totalRecharge];
        }
    }
}
}
