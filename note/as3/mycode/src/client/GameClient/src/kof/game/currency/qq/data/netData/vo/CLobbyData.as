//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/6/29.
 * Time: 20:39
 */
package kof.game.currency.qq.data.netData.vo {

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/6/29
     */
    public class CLobbyData {
        public var lobbyLevelGift : Array = [];
        public var lobbyFreshGift : Boolean;
        public var lobbyDailyGift : Boolean;

        public function setData( obj : Object ) : void {
            this.lobbyLevelGift = obj.lobbyLevelGift;
            this.lobbyFreshGift = obj.lobbyFreshGift;
            this.lobbyDailyGift = obj.lobbyDailyGift;
        }
    }
}
