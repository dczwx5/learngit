//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/7/13.
 */
package kof.game.equipCard.data {

import kof.data.CObjectData;
import kof.game.item.CItemData;

public class CEquipCardData extends CObjectData {

    public static const RoleId:String = "display";// 展示的格斗家id(可为空)
    public static const ItemId:String = "itemID";// 抽到的物品ID(普通物品或整卡)
    public static const Count:String = "itemNum";// 数量

    private var m_pItemData:CItemData;

    public function CEquipCardData()
    {
        super();
    }

    public static function createObjectData(roleId:int, itemId:int, count:int, timestamp:Number) : Object
    {
        return {display:roleId, itemID:itemId, count:count,timestamp:timestamp};
    }

    public function get roleId() : int { return _data[RoleId]; }
    public function get itemId() : int { return _data[ItemId]; }
    public function get count() : int { return _data[Count]; }

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
}
}
