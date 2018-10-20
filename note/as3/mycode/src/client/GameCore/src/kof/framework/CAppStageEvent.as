//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun CNetwork Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.framework {

import flash.events.Event;

/**
 * A event object for CAppStage.
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CAppStageEvent extends Event {
    public static const ENTER:String = "AppStage_Enter";
    public static const EXIT:String = "AppStage_Exit";

    public function CAppStageEvent(type:String, appStage:CAppStage, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this.appStage = appStage;
    }

    public var appStage:CAppStage;

}
}
