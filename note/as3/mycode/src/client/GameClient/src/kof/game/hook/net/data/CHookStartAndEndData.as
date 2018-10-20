//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/7/17.
 * Time: 20:24
 */
package kof.game.hook.net.data {

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/7/17
     */
    public class CHookStartAndEndData {
        /**挂机时间点*/
        public var hangUpTime : Number = 1;
        /**挂机英雄掉落*/
        public var hangUpDrop : Array = [];
        /**挂机状态*/
        public var hangUpState : Boolean = true;

        public function CHookStartAndEndData() {
        }

        public function decode( data : Object ) : void {
            this.hangUpTime = data.hangUpTime;
            this.hangUpDrop = data.hangUpDrop;
            this.hangUpState = data.hangUpState;
        }
    }
}
