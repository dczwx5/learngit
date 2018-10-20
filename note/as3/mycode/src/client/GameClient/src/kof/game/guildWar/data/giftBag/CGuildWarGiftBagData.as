//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/5/4.
 */
package kof.game.guildWar.data.giftBag {

import kof.data.CObjectData;

/**
 * 公会战礼包数据
 */
public class CGuildWarGiftBagData extends CObjectData {

    public static const WinnerSpacesAllocateDatas:String = "winnerSpacesAllocateDatas";
    public static const ClubRankDatas:String = "clubRankDatas";

    public function CGuildWarGiftBagData()
    {
        super();

        this.addChild(CAllocateGiftBagListData);
        this.addChild(CGiftBagRankListData);
    }

    override public function updateDataByData(value:Object):void
    {
        super.updateDataByData(value);

        if(value && value.hasOwnProperty(WinnerSpacesAllocateDatas))
        {
            allocateGiftBagListData.clearAll();
            allocateGiftBagListData.updateDataByData(winnerSpacesAllocateDatas);
        }

        if(value && value.hasOwnProperty(ClubRankDatas))
        {
            giftBagRankListData.clearAll();
            giftBagRankListData.updateDataByData(clubRankDatas);
        }
    }

    public function get winnerSpacesAllocateDatas():Array {return _data[WinnerSpacesAllocateDatas];}
    public function get clubRankDatas():Array {return _data[ClubRankDatas];}

    public function get allocateGiftBagListData():CAllocateGiftBagListData
    {
        return this.getChild(0) as CAllocateGiftBagListData;
    }

    public function get giftBagRankListData():CGiftBagRankListData
    {
        return this.getChild(1) as CGiftBagRankListData;
    }

}
}
