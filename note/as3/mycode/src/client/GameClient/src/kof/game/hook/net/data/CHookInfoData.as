//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/7/17.
 * Time: 20:09
 */
package kof.game.hook.net.data {

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/7/17
     */
    public class CHookInfoData {
        /**开始挂机时间戳，0表示没有挂机，客户端计算累计时长*/
        public var hangUpTime : Number = 0;
        /**累计经验奖励key:heroId,exp*/
        public var heroExp : Array = []; //已废弃 2017/9/27版本
        /**累计道具奖励key:itemId,count*/
        public var dropItem : Array = [];
        /**新增收益 itemId，count*/
        public var addDrop : Array = [];
        /**当日累计道具奖励key:itemId,count*/
        public var todayDropItem : Array = [];
        /**挂机状态*/
        public var hangUpState : int = 0;
        /**是否凌晨12点*/
        public var isMidnight : Boolean = false;

        public function CHookInfoData() {
        }

        public function clearData() : void {
            hangUpTime = 0;
            dropItem = [];
            addDrop = [];
        }

        public function decode( data : Object ) : void {
            this.hangUpTime = data.hangUpTime;
//            this.heroExp = data.heroExp;
            this.dropItem = data.dropItem;
            this.addDrop = data.addDrop;
            this.isMidnight = data.isMidnight;
            this.todayDropItem = data.todayDropItem;
        }

        public function decodeCancleData( data : Object ) : void {
            this.dropItem = data.dropItem;
        }
    }
}
