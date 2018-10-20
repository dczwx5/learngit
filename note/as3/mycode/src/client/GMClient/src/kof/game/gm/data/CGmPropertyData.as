//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/2/10.
 */
package kof.game.gm.data {

import kof.game.common.CLang;
import kof.game.gm.enum.EGmPropertyType;

public class CGmPropertyData {
    public function CGmPropertyData() {
        propertyList = new Array(3);
        propertyList[0] = CLang.Get("property_type_hp") + "|" + EGmPropertyType.TYPE_HP;
        propertyList[1] = CLang.Get("property_type_attack") + "|" + EGmPropertyType.TYPE_ATTACK;
        propertyList[2] = CLang.Get("property_type_defend") + "|" + EGmPropertyType.TYPE_DEFEND;
    }

    public function getTypeByItem(item:String) : int {
        if (item == null || item.length == 0) return -1;
        var list:Array = item.split("|");
        if (list.length > 0) {
            var type:int = list[list.length-1];
            return type;
        }
        return -1;
    }

    public function isDataVaild(propertyType:int, value:*) : Boolean {
        // 目前先简单判断
        if (propertyType <= 0) return false;
        if (value is int && value > 0) return true;
        return false;
    }


    public var propertyList:Array;
}
}
