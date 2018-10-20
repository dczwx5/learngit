//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.switching {

import flash.events.IEventDispatcher;

import kof.game.switching.triggers.CSwitchingTriggerBridge;

public interface ISwitchingTrigger extends IEventDispatcher {

    function bridgeAttached( cSwitchingTriggerBridge : CSwitchingTriggerBridge ) : void;

    function bridgeDetached( cSwitchingTriggerBridge : CSwitchingTriggerBridge ) : void;

}
}
