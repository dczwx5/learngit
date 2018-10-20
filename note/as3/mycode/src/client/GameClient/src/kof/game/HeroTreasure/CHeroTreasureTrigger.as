//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Maniac on 2017/8/16.
 */
package kof.game.HeroTreasure {

import kof.game.switching.ISwitchingTrigger;
import kof.game.switching.triggers.CAbstractSwitchingTrigger;
import kof.game.switching.triggers.CSwitchingTriggerBridge;
import kof.game.switching.triggers.CSwitchingTriggerEvent;

public class CHeroTreasureTrigger extends CAbstractSwitchingTrigger implements ISwitchingTrigger{
    public function CHeroTreasureTrigger( system : CHeroTreasureSystem)
    {
        super();
        m_pSystem = system;
    }
    private var m_pSystem : CHeroTreasureSystem;

    override public function dispose() : void {
        super.dispose();
    }

    public function notifyUpdated() : void {
        var evt : CSwitchingTriggerEvent = new CSwitchingTriggerEvent( CSwitchingTriggerBridge.EVENT_TRIGGERED );
        notifier.dispatchEvent( evt );
    }
}
}
