//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/6/17.
 */
package kof.game.playerCard.data {

import kof.data.CObjectData;
import kof.game.item.CItemData;

public class CPlayerCardData extends CObjectData {

    public static const RoleId:String = "display";// 展示的格斗家id(可为空)
    public static const ItemId:String = "itemID";// 抽到的物品ID(普通物品或整卡)
    public static const Count:String = "itemNum";// 数量
    public static const Star:String = "star";// 星级

    private var m_pItemData:CItemData;

    public function CPlayerCardData()
    {
        super();
    }

    public function get roleId() : int { return _data[RoleId]; }
    public function get itemId() : int { return _data[ItemId]; }
    public function get count() : int { return _data[Count]; }
    public function get star() : int { return _data[Star]; }

    public function get itemData():CItemData
    {
        if(m_pItemData == null)
        {
            if(itemId)
            {
                var itemData:CItemData = new CItemData();
                itemData.databaseSystem = _databaseSystem;
                itemData.updateDataByData(CItemData.createObjectData(itemId));
                m_pItemData = itemData;
            }
        }

        return m_pItemData;
    }

    public function set star(value:int):void
    {
        _data[Star] = value;
    }
}
}
