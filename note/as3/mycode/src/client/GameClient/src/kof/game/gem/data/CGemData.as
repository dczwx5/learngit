//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/6/26.
 */
package kof.game.gem.data {

import kof.data.CObjectData;
import kof.framework.IDatabase;

/**
 * 宝石数据
 */
public class CGemData extends CObjectData {

    public static const AllPointInfos:String = "allPointInfos";// 全部宝石页宝石槽信息
    public static const GemWarehouse:String = "gemWarehouse";// 该宝石页宝石槽信息

    public function CGemData(database:IDatabase)
    {
        super();
        setToRootData(database);

        addChild(CGemPageListData);
        addChild(CGemBagListData);
    }

    public function get allPointInfos() : Array { return _data[AllPointInfos]; }
    public function get gemWarehouse() : Array { return _data[GemWarehouse]; }

    public function set allPointInfos(value:Array):void
    {
        _data[AllPointInfos] = value;
    }

    public function set gemWarehouse(value:Array):void
    {
        _data[GemWarehouse] = value;
    }

    /**
     * 宝石页数据
     */
    public function get pageListData():CGemPageListData
    {
        return getChild(0) as CGemPageListData;
    }

    /**
     * 宝石包数据
     */
    public function get bagListData():CGemBagListData
    {
        return getChild(1) as CGemBagListData;
    }
}
}
