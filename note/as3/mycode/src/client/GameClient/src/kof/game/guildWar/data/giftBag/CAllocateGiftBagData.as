//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/5/4.
 */
package kof.game.guildWar.data.giftBag {

import kof.data.CObjectData;

/**
 * 已分配的礼包数据
 */
public class CAllocateGiftBagData extends CObjectData {

    public static const SpaceId:String = "spaceId";
    public static const AlreadyAllocateRewardBagCount:String = "alreadyAllocateRewardBagCount";

    public function CAllocateGiftBagData() {
        super();
    }

    public function get spaceId():int {return _data[SpaceId];}
    public function get alreadyAllocateRewardBagCount():int {return _data[AlreadyAllocateRewardBagCount];}

    public function set spaceId(value:int):void
    {
        _data[SpaceId] = value;
    }

    public function set alreadyAllocateRewardBagCount(value:int):void
    {
        _data[AlreadyAllocateRewardBagCount] = value;
    }
}
}
