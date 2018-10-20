//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/7/17.
 * Time: 20:33
 */
package kof.game.hook.net.data {

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/7/17
     */
    public class CGetDropData {
        /**挂机英雄累积道具*/
        public var hangUpDrop : Array = [];

        public function CGetDropData() {
        }

        public function decode( data : Object ) : void {
            this.hangUpDrop = data.hangUpDrop;
        }
    }
}
