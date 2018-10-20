//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/6/19.
 */
package kof.game.title.data {

import kof.data.CObjectData;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.table.TitleTypeConfig;

public class CTitleData extends CObjectData {
    public function CTitleData( database : IDatabase ) {
        setToRootData( database );

        this.addChild(CTitleItemListData);
    }

    // ===========================data
    public function initialData( data : Object ) : void {
        isServerData = true;
        updateDataByData( data );
    }

    public override function updateDataByData(data:Object) : void {
        super.updateDataByData(data);
        if (data.hasOwnProperty(_titleInfos)) {
            itemListData.updateDataByData(data[_titleInfos]);
        }
    }

    // 更新和info协议的数据格式不一致
    public function updateItemData( data : Object ) : void {
        itemListData.updateDataByData(data);
    }

    // 穿戴
    public function updateByWear( data : Object ) : void {
        _data[_curTitle] = data as int;
    }

    [Inline]
    public function get itemListData() : CTitleItemListData {
        return getChild(0) as CTitleItemListData;
    }
    [Inline]
    public function get curTitleID()  : int {
        return _data[_curTitle];
    }
    public function get curTitleItem() : CTitleItemData {
        return itemListData.getItem(curTitleID);
    }

    public static const _titleInfos:String = "titleInfos";
    public static const _curTitle:String = "curTitle";

    public function getTypeRecord(type:int) : TitleTypeConfig {
        return typeTable.findByPrimaryKey(type) as TitleTypeConfig;
    }

    public function get itemTable() : IDataTable {
        if (_itemTable == null) {
            _itemTable = _databaseSystem.getTable(KOFTableConstants.TitleConfig);
        }
        return _itemTable;
    }

    public function get typeTable() : IDataTable {
        if (_typeTable == null) {
            _typeTable = _databaseSystem.getTable(KOFTableConstants.TitleTypeConfig);
        }
        return _typeTable;
    }

    private var _itemTable:IDataTable;
    private var _typeTable:IDataTable;

}
}
