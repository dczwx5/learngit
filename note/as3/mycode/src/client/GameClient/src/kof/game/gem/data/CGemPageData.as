//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/6/26.
 */
package kof.game.gem.data {

import kof.data.CObjectData;

/**
 * 单页的宝石孔信息数据
 */
public class CGemPageData extends CObjectData {

    public static const PageType:String = "pageType";// 页号
    public static const PointInfos:String = "pointInfos";// 该宝石页宝石槽信息

    public function CGemPageData()
    {
        super();

        addChild(CGemHoleListData);
    }

    public override function updateDataByData(data:Object) : void
    {
        super.updateDataByData( data );

        if ( data.hasOwnProperty( PointInfos ) )
        {
//            gemHoleListData.clearAll();
            gemHoleListData.updateDataByData( data[ PointInfos ] );
        }
    }

    public function get pageType() : int { return _data[PageType]; }
    public function get pointInfos() : Array { return _data[PointInfos]; }

    public function set pageType(value:int):void
    {
        _data[PageType] = value;
    }

    public function get gemHoleListData():CGemHoleListData
    {
        return getChild(0) as CGemHoleListData;
    }
}
}
