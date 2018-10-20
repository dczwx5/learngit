//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Administrator on 2017/9/6.
 */
package kof.game.activityHall.event {

import kof.game.switching.ISwitchingTrigger;
import kof.game.switching.triggers.CAbstractSwitchingTrigger;
import kof.game.switching.triggers.CSwitchingTriggerBridge;
import kof.game.switching.triggers.CSwitchingTriggerEvent;

public class CActivityHallTrigger extends CAbstractSwitchingTrigger implements ISwitchingTrigger {
    public function CActivityHallTrigger() {
    }

    override public function dispose() : void {
        super.dispose();
    }
    public function notifyUpdated() : void {
        var evt : CSwitchingTriggerEvent = new CSwitchingTriggerEvent( CSwitchingTriggerBridge.EVENT_TRIGGERED );
        notifier.dispatchEvent( evt );
    }
}
}
