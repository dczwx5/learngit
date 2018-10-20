//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/7/28.
 * Time: 10:55
 */
package kof.game.globalBoss.datas.vo {

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/7/28
     */
    public class CWBData {
        //主界面
        public var level : int = 0;// 世界boss等级
        public var name : String = "";// 上次伤害最高玩家姓名
        public var state : int = 0;// 当前世界boss状态， 0 准备阶段， 1 战斗阶段， 2 封印成功
        public var startTime : Number = 0;// boss降临时间(时间戳，单位ms)
        public var rankRewardedTimes : int = 0;// 已领取几次排名奖励
        public var lastFinaLDamagePlayer:String = "";
        //探宝
        public var remainderTimes : int = 0;//  探宝剩余次数
        public var alreadyBuyTimes : int = 2;//  已经购买次数
        public var totalTimes : int = 3;//  累计次数
        //抽奖
        public var index : int = 0;// 抽到的物品序号
        //能否参与战斗
        public var startFight : Boolean = false;// 是否开启战斗， false 不开启, true 开启
        public var goldInspireTimes : int = 0;// 金币鼓舞次数
        public var diamondInsoireTimes : int = 0;// 钻石鼓舞次数
        public var diamondReviveTimes:int=0;// 钻石复活次数
        //封印成功奖励信息
        public var rank : int = 1;//排名
        public var damage : Number = 0;//伤害
        public var lastDamage : Boolean = false;//是否最后一击玩家

        public function CWBData() {
        }
    }
}
