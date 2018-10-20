//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/11/3.
 */
package kof.game.artifact {
import flash.events.Event;

public class CArtifactEvent extends Event {

    public static const ARTIFACTUPDATE : String = "ArtifactUpdate";
    public static const ARTIFACT_SOUL_UNLOCK_SUCCESS : String = "artifactSoulUnlockSuccess";
    public function CArtifactEvent( type:String, data:Object, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this.data = data;
    }
    public var data:Object;
}
}
