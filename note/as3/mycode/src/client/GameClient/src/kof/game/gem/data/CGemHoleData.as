//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/6/26.
 */
package kof.game.gem.data {

import kof.data.CObjectData;

/**
 * 单个宝石孔数据
 */
public class CGemHoleData extends CObjectData {

    public static const GemPointConfigID:String = "gemPointConfigID";// 宝石槽配置表ID
    public static const State:String = "state";// 宝石槽状态：1已开启未镶嵌 2已镶嵌
    public static const GemConfigID:String = "gemConfigID";// 镶嵌的宝石配置表ID

    public function CGemHoleData()
    {
        super();
    }

    public function get gemPointConfigID() : int { return _data[GemPointConfigID]; }
    public function get state() : int { return _data[State]; }
    public function get gemConfigID() : int { return _data[GemConfigID]; }

    public function set gemPointConfigID(value:int):void
    {
        _data[GemPointConfigID] = value;
    }

    public function set state(value:int):void
    {
        _data[State] = value;
    }

    public function set gemConfigID(value:int):void
    {
        _data[GemConfigID] = value;
    }
}
}
