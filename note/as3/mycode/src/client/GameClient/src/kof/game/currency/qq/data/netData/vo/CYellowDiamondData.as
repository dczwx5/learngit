//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/6/29.
 * Time: 20:36
 */
package kof.game.currency.qq.data.netData.vo {

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/6/29
     */
    public class CYellowDiamondData {
        public var yellowFreshGift : Boolean;
        public var yellowLevelGift : Array = [];
        public var yellowDailyGift : Array = [];

        public function setData( obj : Object ) : void {
            this.yellowFreshGift = obj.yellowFreshGift;
            this.yellowLevelGift = obj.yellowLevelGift;
            this.yellowDailyGift = obj.yellowDailyGift;
        }
    }
}
