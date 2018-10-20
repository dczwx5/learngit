//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/6/19.
 */
package kof.game.title.data {

import kof.data.CObjectData;
import kof.table.TitleConfig;

public class CTitleItemData extends CObjectData {
    public function CTitleItemData() {
    }

    public override function updateDataByData(data:Object) : void {
        super.updateDataByData(data);

    }
    [Inline]
    public function get configId() : int { return _data[_configId]; } // 配表id
    [Inline]
    public function get isComplete() : Boolean { return _data[_isComplete]; } // 是否完成,. 是否拥有称号
    [Inline]
    public function get invalidTick() : Number { return _data[_invalidTick]; } // 失效时间

    public static const _configId:String = "configId";
    public static const _isComplete:String = "isComplete";
    public static const _invalidTick:String = "invalidTick";
    public static const _type:String = "type";

    public function get type() : int {
        return itemRecord.type;
    }

    public function get itemRecord() : TitleConfig {
        if (!_itemRecord) {
            _itemRecord = (rootData as CTitleData).itemTable.findByPrimaryKey(configId);
        }
        return _itemRecord;
    }
    private var _itemRecord:TitleConfig;
}
}
