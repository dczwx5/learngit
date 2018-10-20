//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/7.
 */
package kof.game.player.childrenEvent {

import kof.game.player.CPlayerChildrenEventDispatcher;
import kof.game.player.data.CGlobalPropertyData;
import kof.game.player.data.CPlayerData;
import kof.game.player.event.CPlayerEvent;

public class CPlayerHeroEventProcess extends CPlayerChildrenEventProcess {
    public function CPlayerHeroEventProcess(childrenEventDispatcher:CPlayerChildrenEventDispatcher) {
        super(childrenEventDispatcher, CPlayerEvent.PLAYER_HERO_DATA);
    }

    public override function process(newDataObject:Object, oldPlayerData:CPlayerData) : void {
        if(newDataObject.hasOwnProperty(CGlobalPropertyData._artifactProperty)) {
            _isChange = true;
        }
        if(!_isChange && newDataObject.hasOwnProperty(CGlobalPropertyData._talentProperty)) {
            _isChange = true;
        }

        if(!_isChange && newDataObject.hasOwnProperty(CGlobalPropertyData._cardProperty)) {
            _isChange = true;
        }
    }
}
}
