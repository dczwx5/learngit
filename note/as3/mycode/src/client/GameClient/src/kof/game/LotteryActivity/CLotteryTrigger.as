//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2018/6/28.
 */
package kof.game.LotteryActivity {

import kof.game.switching.ISwitchingTrigger;
import kof.game.switching.triggers.CAbstractSwitchingTrigger;
import kof.game.switching.triggers.CSwitchingTriggerBridge;
import kof.game.switching.triggers.CSwitchingTriggerEvent;

public class CLotteryTrigger extends CAbstractSwitchingTrigger implements ISwitchingTrigger{
    public function CLotteryTrigger() {
        super();
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
