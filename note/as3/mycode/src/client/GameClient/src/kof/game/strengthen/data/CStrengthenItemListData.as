//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/6/28.
 */
package kof.game.strengthen.data {

import QFLib.Foundation.CMap;

import kof.data.CObjectListData
import kof.table.StrengthItem;

public class CStrengthenItemListData extends CObjectListData {
    public function CStrengthenItemListData() {
        super (CStrengthenItemData, "ID");
    }

    public override function updateDataByData(data:Object) : void {
        super.updateDataByData(data);
    }
    public function getItem(configID:int) : CStrengthenItemData {
        return super.getByPrimary(configID) as CStrengthenItemData;
    }

    public function getListByType(type:int) : Array {
        var ret:Array = new Array();
        for each (var itemData:CStrengthenItemData in childList) {
            if (itemData.type == type) {
                ret[ret.length] = itemData.itemRecord;
            }
        }
        return ret;
    }
    // 子项的itemList
    public function getChildrenListByType(type:int, childGroup:int) : Array {
        var ret:Array = new Array();
        for each (var itemData:CStrengthenItemData in childList) {
            if (itemData.type == type && itemData.itemRecord.childGroup == childGroup) {
                ret[ret.length] = itemData.itemRecord;
            }
        }
        return ret;
    }
    public function getChildTabListByType(type:int) : Array {
        var saveObject:CMap = new CMap();
        var allList:Array = getListByType(type);
        for (var i:int = 0; i < allList.length; i++) {
            var itemRecord:StrengthItem = allList[i];
            if (saveObject.find(itemRecord.childGroup) == null) {
                saveObject.add(itemRecord.childGroup, itemRecord);
            }
        }
        var ret:Array = saveObject.toArray();
        return ret;
    }
}
}
