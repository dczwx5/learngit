//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/6/29.
 * Time: 20:34
 */
package kof.game.currency.qq.data.netData.vo {

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/6/29
     */
    public class CBlueDiamondData {
        public var blueDailyGift : Array = [];
        public var blueLevelGift : Array = [];
        public var blueFreshGift : Boolean;

        public function setData( obj : Object ) : void {
            this.blueDailyGift = obj.blueDailyGift;
            this.blueLevelGift = obj.blueLevelGift;
            this.blueFreshGift = obj.blueFreshGift;
        }
    }
}
