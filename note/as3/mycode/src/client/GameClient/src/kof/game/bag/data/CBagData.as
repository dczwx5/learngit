//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2016/10/10.
 */
package kof.game.bag.data {

import QFLib.Foundation.CMap;

import kof.data.CObjectData;
import kof.game.item.CItemData;
import kof.table.Item;

public class CBagData extends CItemData {


    public var item:Item;

    public function CBagData() {
        _data = new CMap();
    }


    public function get uid() : Number { return _data[_uid]; }
    public function get itemID() : int { return _data[_itemID]; }
//    public function get num() : int { return _data[_num]; }
//
//    public function set num(value : int) : void { _data[_num] = value; }


    public static function createObjectData(uid:Number, itemID:int, num:int) : Object {
        return {uid:uid, itemID:itemID, num:num}
    }

    public static const _uid:String = "uid";
    public static const _itemID:String = "itemID";
    public static const _num:String = "num";

}
}
