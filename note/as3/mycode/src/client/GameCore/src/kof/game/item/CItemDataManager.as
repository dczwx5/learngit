//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/12/8.
 */
package kof.game.item {

import kof.data.CObjectListData;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;

public class CItemDataManager extends CObjectListData {
    public function CItemDataManager(database:IDatabase) {
        super (CItemData, CItemData.ITEM_ID);
        this.setToRootData(database);
        _itemTable = _databaseSystem.getTable(KOFTableConstants.ITEM);
    }

    public function getItem(itemID:int) : CItemData {
        var itemData:CItemData = this.getByPrimary(itemID) as CItemData;
        if (itemData == null) {
            itemData = this.adddData(CItemData.createObjectData(itemID)) as CItemData;
        }
        return itemData;
    }

    private var _itemTable:IDataTable;
}
}
