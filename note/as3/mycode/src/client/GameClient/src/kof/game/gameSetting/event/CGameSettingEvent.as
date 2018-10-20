//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/11/17.
 */
package kof.game.gameSetting.event {

import flash.events.Event;

public class CGameSettingEvent extends Event {

    public static const UpdateAllSettings:String = "UpdateAllSettings";
    public static const OpenOrCloseSound:String = "OpenOrCloseSound";
    public static const SoundSynchUpdate:String = "SoundSynchUpdate";
    public static const PeakPkSynchUpdate:String = "PeakPkSynchUpdate";

    public var data:Object;

    public function CGameSettingEvent(type:String, data:Object, bubbles:Boolean = false, cancelable:Boolean = false)
    {
        super(type, bubbles, cancelable);
        this.data = data;
    }
}
}
