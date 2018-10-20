//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/1/19.
 */
package kof.framework {

import flash.geom.Point;

public class CShowDialogTweenData {
    public static const TYPE_DEFAULT:int = 0;

    public function CShowDialogTweenData(startPos:Point) {
        if (startPos) {
            startX = startPos.x;
            startY = startPos.y;
        }
    }

    public var tweenType:int;
    public var startX:int = -1;
    public var startY:int = -1;
    public var systemTag:String;
    public var size:Point;

}
}
