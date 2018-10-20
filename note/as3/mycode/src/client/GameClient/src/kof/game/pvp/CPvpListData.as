//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2016/10/26.
 */
package kof.game.pvp {


public class CPvpListData {
    public var roomId:int;

    public var roomType:int;

    public var roomState:int;

    public var leftArr:Array;

    public var rightArr:Array;

    public var createrInfo:Object;
    public function CPvpListData(obj:Object) {
        roomId = obj.roomId;
        roomType = obj.roomType;

        leftArr = obj.left;
        rightArr = obj.right;

        createrInfo = obj.createrInfo;
        roomState = obj.roomState;
    }
}
}
