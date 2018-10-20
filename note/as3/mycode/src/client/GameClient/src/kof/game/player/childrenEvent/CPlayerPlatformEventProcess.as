//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/5.
 */
package kof.game.player.childrenEvent {

import kof.game.player.CPlayerChildrenEventDispatcher;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.subData.CSubPlatformData;
import kof.game.player.event.CPlayerEvent;

public class CPlayerPlatformEventProcess extends CPlayerChildrenEventProcess {
    public function CPlayerPlatformEventProcess( childrenEventDispatcher:CPlayerChildrenEventDispatcher) {
        super(childrenEventDispatcher, CPlayerEvent.PLAYER_PLATFORM);
    }

    public override function process(newDataObject:Object, oldPlayerData:CPlayerData) : void {
        if(newDataObject.hasOwnProperty(CSubPlatformData._platformInfo)) {
            _isChange = true;
        }
        if (!_isChange && newDataObject.hasOwnProperty(CSubPlatformData._platform)) {
            _isChange = oldPlayerData.platformData.platform != newDataObject[CSubPlatformData._platform];
        }

    }
}
}
