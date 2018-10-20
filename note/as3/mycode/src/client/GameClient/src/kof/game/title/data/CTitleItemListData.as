//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/6/19.
 */
package kof.game.title.data {

import kof.data.CObjectListData

public class CTitleItemListData extends CObjectListData {
    public function CTitleItemListData() {
        super (CTitleItemData, CTitleItemData._configId);
    }

    public override function updateDataByData(data:Object) : void {
        super.updateDataByData(data);
    }
    public function getItem(configID:int) : CTitleItemData {
        return super.getByPrimary(configID) as CTitleItemData;
    }

    public function getListByType(type:int) : Array {
        return super.getListByKey(CTitleItemData._type, type);
    }

//    public function hasHero(heroID:int) : Boolean {
//        var list:Array = childList;
//         for each (var data:IObjectData in list) {
//            if (data[CTitleItemData._heroID] == heroID) {
//                return true;
//            }
//        }
//        return false;
//    }
}
}
