//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/23.
 */
package kof.game.player.data {

import kof.data.CObjectListData;
import kof.game.player.data.property.CHeroEquipProperty;

public class CHeroEquipListData extends CObjectListData {
    public function CHeroEquipListData() {
        super (CHeroEquipData, CHeroEquipData._baseID);
    }

    public function toArray() : Array {
        var ret:Array = [
            getByPart(CHeroEquipData.POS_WEAPON), getByPart(CHeroEquipData.POS_CLOTHES),
            getByPart(CHeroEquipData.POS_TROUSERS), getByPart(CHeroEquipData.POS_SHOES),
            getByPart(CHeroEquipData.POS_BADGES), getByPart(CHeroEquipData.POS_BOOK)];
        return ret;
    }

    // 所有装备属性
    public function getAllEquipProperty() : CHeroEquipProperty {
        var list:Array = this.childList;
        var propertyData:CHeroEquipProperty = new CHeroEquipProperty();
        for each (var equipData:CHeroEquipData in list) {
            propertyData.add(equipData.currentProperty);
        }
        propertyData = propertyData.calcFinalProperty();

        return propertyData;
    }
    public function getByPart(part:int) : CHeroEquipData {
        return this.getByKey(CHeroEquipData._part, part) as CHeroEquipData;
    }

}
}
