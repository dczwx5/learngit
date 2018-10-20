//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Maniac on 2017/8/16.
 */
package kof.game.limitActivity {

import kof.game.switching.ISwitchingTrigger;
import kof.game.switching.triggers.CAbstractSwitchingTrigger;
import kof.game.switching.triggers.CSwitchingTriggerBridge;
import kof.game.switching.triggers.CSwitchingTriggerEvent;

public class CLimitActivityTrigger extends CAbstractSwitchingTrigger implements ISwitchingTrigger{
    public function CLimitActivityTrigger( system : CLimitActivitySystem)
    {
        super();
        m_pSystem = system;
    }
    private var m_pSystem : CLimitActivitySystem;

    override public function dispose() : void {
        super.dispose();
    }

    public function notifyUpdated() : void {
        var evt : CSwitchingTriggerEvent = new CSwitchingTriggerEvent( CSwitchingTriggerBridge.EVENT_TRIGGERED );
        notifier.dispatchEvent( evt );
    }
}
}
