//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/6/28.
 */
package kof.game.strengthen.data {

import kof.data.CObjectData;
import kof.table.StrengthItem;

public class CStrengthenItemData extends CObjectData {
    public function CStrengthenItemData() {
    }

    public override function updateDataByData(data:Object) : void {
        super.updateDataByData(data);

    }
    public static function buildData(configID:int) : Object {
        return {ID:configID};
    }
    public function get ID() : int { return _data["ID"]; } // 配表id
    public function get isChildren() : Boolean { return itemRecord.groupLevel > 0; }
    public function get type() : int {
        return itemRecord.type;
    }
    public function get jumpToSysTag() : String {
        return itemRecord.jumpSysTag;
    }

    public function get itemRecord() : StrengthItem {
        if (!_itemRecord) {
            _itemRecord = (rootData as CStrengthenData).itemTable.findByPrimaryKey(ID);
        }
        return _itemRecord;
    }
    private var _itemRecord:StrengthItem;
}
}
