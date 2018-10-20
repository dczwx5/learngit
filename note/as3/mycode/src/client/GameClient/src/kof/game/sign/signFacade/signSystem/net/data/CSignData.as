//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/6/3.
 * Time: 14:40
 */
package kof.game.sign.signFacade.signSystem.net.data {

    import kof.message.SignIn.UpdateSignInSystemResponse;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/6/3
     */
    public class CSignData {
        /**当前的月数*/
        public var month : int = 0;
        /**累积的天数*/
        public var totalSignInDays : int = 0;
        /**实际连续签到天数*/
        public var sumDays : int = 0;
        /**各个累积天数领奖的状态*/
        public var totalSignInDaysReward : Array = [];
        /**当天签到状态 0未签 1已签*/
        public var signInState : int = 0;
        /**获得vip奖励状态 0未领 1已领*/
        public var getVipRewardState : int = 0;
        /**是否是新服签到奖励*/
        public var isNewServer : Boolean = false;

        //提示码
        public var gamePromptID : int = 0;

        public function CSignData() {
        }

        public function setSignData( obj : UpdateSignInSystemResponse ) : void {
            this.month = obj.dataMap.month;
            this.sumDays = obj.dataMap.sumDays;
            this.totalSignInDays = obj.dataMap.totalSignInDays;
            this.totalSignInDaysReward = obj.dataMap.totalSignInDaysReward;
            this.signInState = obj.dataMap.signInState;
            this.getVipRewardState = obj.dataMap.getVipRewardState;
            this.isNewServer = obj.dataMap.isNewServer;
        }
    }
}
