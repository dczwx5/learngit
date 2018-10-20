//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/6/7.
 */
package kof.game.endlessTower.data {

import kof.data.CObjectListData;

/**
 * 层级宝箱奖励领取信息
 */
public class CLayerBoxRewardTakeInfoListData extends CObjectListData {
    public function CLayerBoxRewardTakeInfoListData()
    {
        super(CLayerBoxRewardTakeInfoData, CLayerBoxRewardTakeInfoData.Layer);
    }

    public function getData(layer:int) : CLayerBoxRewardTakeInfoData
    {
        var rankData:CLayerBoxRewardTakeInfoData = this.getByPrimary(layer) as CLayerBoxRewardTakeInfoData;
        return rankData;
    }

}
}
