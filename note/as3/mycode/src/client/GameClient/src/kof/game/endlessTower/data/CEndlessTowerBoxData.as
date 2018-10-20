//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/10/21.
 */
package kof.game.endlessTower.data {

import kof.data.CObjectData;

/**
 * 无尽之塔宝箱数据
 */
public class CEndlessTowerBoxData extends CObjectData {

    public static const LayerId:String = "layerId";// 哪一层
    public static const BoxRewardId:String = "boxRewardId";// 宝箱奖励

    public function CEndlessTowerBoxData()
    {
        super();
    }

    public function get layerId() : int { return _data[LayerId]; }
    public function get boxRewardId() : int { return _data[BoxRewardId]; }

    public function set layerId(value:int):void
    {
        _data[LayerId] = value;
    }

    public function set boxRewardId(value:int):void
    {
        _data[BoxRewardId] = value;
    }
}
}
