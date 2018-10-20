//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/7/17.
 * Time: 20:29
 */
package kof.game.hook.net.data {

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/7/17
     */
    public class CGetExpData {
        /**本次加的经验*/
        public var exp : int = 1;
        /**
         * 两个key:heroId,exp
         * 挂机英雄累积经验
         * */
        public var hangUpExp : Array = [];

        public function CGetExpData() {
        }

        public function decode( data : Object ) : void {
            this.exp = data.exp;
            this.hangUpExp = data.hangUpExp;
        }
    }
}
