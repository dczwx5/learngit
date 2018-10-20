//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/5/5.
 */
package kof.game.guildWar.data.giftBag {

import kof.data.CObjectData;

/**
 * 礼包分配记录数据
 */
public class CGiftBagRecordData extends CObjectData {

    public static const SpaceId:String = "spaceId";
    public static const Position:String = "position";
    public static const Name:String = "name";
    public static const Time:String = "time";

    public function CGiftBagRecordData()
    {
        super();
    }

    public function get spaceId():int {return _data[SpaceId];}
    public function get position():int {return _data[Position];}
    public function get name():String {return _data[Name];}
    public function get time():Number {return _data[Time];}

    public function set spaceId(value:int):void
    {
        _data[SpaceId] = value;
    }

    public function set position(value:int):void
    {
        _data[Position] = value;
    }

    public function set name(value:String):void
    {
        _data[Name] = value;
    }

    public function set time(value:Number):void
    {
        _data[Time] = value;
    }
}
}
