//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/6/7.
 */
package kof.game.endlessTower.data {

import kof.data.CObjectData;

/**
 * 层级宝箱奖励领取信息
 */
public class CLayerBoxRewardTakeInfoData extends CObjectData {

    public static const Layer:String = "layer";// 第几层
    public static const ObtainedArr:String = "obtainedArr";// 领取了哪几个的数据，从0开始，没领为空

    public function CLayerBoxRewardTakeInfoData()
    {
        super();
    }

    public function get layer() : int { return _data[Layer]; }
    public function get obtainedArr() : Array { return _data[ObtainedArr]; }

    public function set layer(value:int):void
    {
        _data[Layer] = value;
    }

    public function set obtainedArr(value:Array):void
    {
        _data[ObtainedArr] = value;
    }

}
}
