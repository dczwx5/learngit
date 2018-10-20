//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/4/27.
 */
package kof.game.guildWar.data {

import kof.data.CObjectData;

/**
 * 某个空间站个人排行总数据(列表+个人)
 */
public class CStationRoleRankData extends CObjectData {

    public static const SpaceId:String = "spaceId";

    public function CStationRoleRankData()
    {
        super();

        addChild(CRoleRankCellListData);
        addChild(CRoleRankCellData);
    }

    override public function updateDataByData(value:Object):void
    {
        super.updateDataByData( value );

        if ( value.hasOwnProperty( "roleRankDatas" ) )
        {
            rankListData.clearAll();
            rankListData.updateDataByData( data[ "roleRankDatas" ] );
        }

        if ( value.hasOwnProperty( "myRoleRankData" ) )
        {
            myRankData.updateDataByData( data[ "myRoleRankData" ] );
        }
    }

    public function get spaceId() : int { return _data[SpaceId]; }

    public function set spaceId(value:int):void
    {
        _data[SpaceId] = value;
    }

    public function get rankListData():CRoleRankCellListData
    {
        return getChild(0) as CRoleRankCellListData;
    }

    public function get myRankData():CRoleRankCellData
    {
        return getChild(1) as CRoleRankCellData;
    }
}
}
