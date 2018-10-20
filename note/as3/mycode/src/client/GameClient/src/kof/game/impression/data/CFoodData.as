//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/5/27.
 */
package kof.game.impression.data {

import kof.game.item.CItemData;

public class CFoodData extends CItemData {

    public static const ITEM_ID:String = "ID";
    public static const ITEM_NUM:String = "num";

    public function CFoodData() {
        super();
    }

    public static function createObjectData(itemId:int, itemNum:int) : Object {
        return {ID:itemId, num:itemNum}
    }

    public function get itemID() : int { return _data[ITEM_ID]; }
//    public function get num() : int { return _data[ITEM_NUM]; }
//
//    public function set num(value : int) : void { _data[ITEM_NUM] = value; }
}
}
