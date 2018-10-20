//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/5/4.
 */
package kof.game.guildWar.data.giftBag {

import kof.data.CObjectListData;

/**
 * 已分配的礼包列表数据
 */
public class CAllocateGiftBagListData extends CObjectListData {
    public function CAllocateGiftBagListData()
    {
        super( CAllocateGiftBagData, CAllocateGiftBagData.SpaceId );
    }

    public function getDataBySpaceId(spaceId:int):CAllocateGiftBagData
    {
        var rankData:CAllocateGiftBagData = this.getByPrimary(spaceId) as CAllocateGiftBagData;
        return rankData;
    }
}
}
