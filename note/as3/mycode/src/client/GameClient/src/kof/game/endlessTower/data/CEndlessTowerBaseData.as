//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/10/10.
 */
package kof.game.endlessTower.data {

import kof.data.CObjectData;

/**
 * 无尽之塔基本数据
 */
public class CEndlessTowerBaseData extends CObjectData {

    public static const MaxPassedLayer:String = "maxPassedLayer";// 最高通关层
//    public static const BoxHasTakeArr:String = "maxPassedLayerBoxRewardObtainedArr";// 最高通关层的宝箱已领取哪几个
    public static const DayRewardTakeLayer:String = "everydayRewardObtainedLayer";// 每日奖励已领取层数
    public static const LayerInfoArr:String = "layerInfoArr";// 层级宝箱奖励领取信息

    public function CEndlessTowerBaseData()
    {
        super();
        this.addChild(CEndlessTowerResultData);
        this.addChild(CLayerBoxRewardTakeInfoListData);
    }

    override public function updateDataByData(value:Object):void
    {
        super.updateDataByData(value);

        if(value.hasOwnProperty(LayerInfoArr))
        {
            boxTakeInfoListData.updateDataByData(layerInfoArr);
        }
    }

    public function updateResultData(dataObj:Object) : void {
        resultData.updateDataByData(dataObj);
    }

    public function get maxPassedLayer() : int { return _data[MaxPassedLayer]; }
//    public function get boxHasTakeArr() : Array { return _data[BoxHasTakeArr]; }
    public function get dayRewardTakeLayer() : int { return _data[DayRewardTakeLayer]; }
    public function get layerInfoArr() : Array { return _data[LayerInfoArr]; }

    public function get resultData() : CEndlessTowerResultData { return this.getChild(0) as CEndlessTowerResultData; }
    public function get boxTakeInfoListData() : CLayerBoxRewardTakeInfoListData { return this.getChild(1) as CLayerBoxRewardTakeInfoListData; }

    public function set maxPassedLayer(value:int):void
    {
        _data[MaxPassedLayer] = value;
    }

//    public function set boxHasTakeArr(value:Array):void
//    {
//        _data[BoxHasTakeArr] = value;
//    }

    public function set dayRewardTakeLayer(value:int):void
    {
        _data[DayRewardTakeLayer] = value;
    }


}
}
