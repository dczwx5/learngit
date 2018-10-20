//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2016/11/10.
 */
package preview.game.levelServer.event.map {
import flash.events.Event;

public class CTrunkMonsterRemoveEvent extends Event {
    public function CTrunkMonsterRemoveEvent(type:String, removeArr:Array) {
        super(type);
        removeArray = removeArr;
    }

    public var removeArray:Array;
}
}
