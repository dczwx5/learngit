//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/6/27.
 */
package kof.game.gem.data {

import kof.data.CObjectData;

/**
 * 宝石包数据
 */
public class CGemBagData extends CObjectData {

    public static const GemConfigID:String = "gemConfigID";// 宝石配置表ID
    public static const GemNum:String = "gemNum";// 宝石数量

    public function CGemBagData()
    {
        super();
    }

    public function get gemConfigID() : int { return _data[GemConfigID]; }
    public function get gemNum() : int { return _data[GemNum]; }

    public function set gemConfigID(value:int):void
    {
        _data[GemConfigID] = value;
    }

    public function set gemNum(value:int):void
    {
        _data[GemNum] = value;
    }
}
}
