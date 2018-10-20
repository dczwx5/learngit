//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/10/23.
 */
package kof.game.endlessTower.data {

import kof.data.CObjectData;

/**
 * 无尽之塔关卡数据
 */
public class CEndlessTowerLayerData extends CObjectData {

    public static const LayerId:String = "layerId";
    public static const Type:String = "type";
    public static const DataArr:String = "dataArr";

    public function CEndlessTowerLayerData()
    {
        super();
    }

    public function get layerId() : int { return _data[LayerId]; }
    public function get type() : int { return _data[Type]; }// EEndlessTowerLayerDataType
    public function get dataArr() : Array { return _data[DataArr]; }// ElementType:CEndlessTowerHeroData/CEndlessTowerBoxData

    public function set layerId(value:int):void
    {
        _data[LayerId] = value;
    }

    public function set type(value:int):void
    {
        _data[Type] = value;
    }

    public function set dataArr(value:Array):void
    {
        _data[DataArr] = value;
    }
}
}
