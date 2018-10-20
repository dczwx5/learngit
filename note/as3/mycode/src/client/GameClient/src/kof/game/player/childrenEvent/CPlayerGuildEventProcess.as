//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/30.
 */
package kof.game.player.childrenEvent {

import kof.game.player.CPlayerChildrenEventDispatcher;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.subData.CGuildData;
import kof.game.player.event.CPlayerEvent;

public class CPlayerGuildEventProcess extends CPlayerChildrenEventProcess {
    public function CPlayerGuildEventProcess(childrenEventDispatcher:CPlayerChildrenEventDispatcher) {
        super(childrenEventDispatcher, CPlayerEvent.PLAYER_GUILD_DATA);
    }

    public override function process(newDataObject:Object, oldPlayerData:CPlayerData) : void {
        if(newDataObject.hasOwnProperty(CGuildData._clubID)) {
            _isChange = oldPlayerData.guideData.clubID != newDataObject[CGuildData._clubID];
        }
        if(newDataObject.hasOwnProperty(CGuildData._clubName)) {
            _isChange = oldPlayerData.guideData.clubName != newDataObject[CGuildData._clubName];
        }
        if(newDataObject.hasOwnProperty(CGuildData._societyCoin)) {
            _isChange = oldPlayerData.guideData.societyCoin != newDataObject[CGuildData._societyCoin];
        }
    }
}
}
