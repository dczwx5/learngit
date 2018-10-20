//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/6.
 */
package kof.game.player.childrenEvent {

import kof.game.player.CPlayerChildrenEventDispatcher;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.subData.CSubTaskData;
import kof.game.player.event.CPlayerEvent;

public class CPlayerTaskEventProcess extends CPlayerChildrenEventProcess {
    public function CPlayerTaskEventProcess(childrenEventDispatcher:CPlayerChildrenEventDispatcher) {
        super(childrenEventDispatcher, CPlayerEvent.PLAYER_TASK);
    }

    public override function process(newDataObject:Object, oldPlayerData:CPlayerData) : void {
        if(newDataObject.hasOwnProperty(CSubTaskData._dailyQuestActiveValue)) {
            _isChange = oldPlayerData.taskData.dailyQuestActiveValue != newDataObject[CSubTaskData._dailyQuestActiveValue];
        }
        if (!_isChange && newDataObject.hasOwnProperty(CSubTaskData._dailyQuestActiveRewards)) {
            _isChange = oldPlayerData.taskData.dailyQuestActiveRewards != newDataObject[CSubTaskData._dailyQuestActiveRewards];
        }
    }
}
}
