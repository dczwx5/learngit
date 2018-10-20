//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2018/5/4.
 */
package kof.game.welfarehall.data {

import kof.message.ForeverRecharge.ForeverRechargeInfoResponse;
import kof.message.ForeverRecharge.ReceiveRechargeRewardResponse;

public class CRechargeWelfareData {
    public function CRechargeWelfareData() {
    }

    public function updateData(response:ForeverRechargeInfoResponse) : void {

        receiveRechargeRecord = response.receiveRechargeRecord;
        totalRechargeDiamond = response.totalRechargeDiamond;
    }

    public function updateDataRecharge(response:ReceiveRechargeRewardResponse) : void {

        receiveRechargeRecord = response.receiveRechargeRecord;
        totalRechargeDiamond = response.totalRechargeDiamond;
        rechargeValue = response.rechargeValue;
    }

    /**
     * 查找是否领取了对应的奖励
     * */
    public function isGetReward(value:int) : Boolean {
        for(var i:int = 0;i<receiveRechargeRecord.length;i++)
        {
            if(receiveRechargeRecord[i] == value)
            {
                return true;
            }
        }
        return false;
    }
    /**
     * 充值奖励领取数据
     * */
    public var receiveRechargeRecord:Array = [];
    /**
     * 累计充值钻石
     * */
    public var totalRechargeDiamond:int;
    /**
     * 领取充值奖励的钻石额度
     * */
    public var rechargeValue:int;
}
}
