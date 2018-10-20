//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/4/26.
 */
package kof.game.guildWar.data {

import kof.data.CObjectData;

/**
 * 某个空间站俱乐部排行总数据(列表+个人)
 */
public class CStationClubRankData extends CObjectData {

    public static const SpaceId:String = "spaceId";

    public function CStationClubRankData()
    {
        super();

        addChild(CClubRankCellListData);
        addChild(CClubRankCellData);
    }

    override public function updateDataByData(value:Object):void
    {
        super.updateDataByData( value );

        if ( value.hasOwnProperty( "clubRankDatas" ) )
        {
            rankListData.clearAll();
            rankListData.updateDataByData( data[ "clubRankDatas" ] );
        }

        if ( value.hasOwnProperty( "myClubRankData" ) )
        {
            myRankData.updateDataByData( data[ "myClubRankData" ] );
        }
    }

    public function get spaceId() : int { return _data[SpaceId]; }

    public function set spaceId(value:int):void
    {
        _data[SpaceId] = value;
    }

    public function get rankListData():CClubRankCellListData
    {
        return getChild(0) as CClubRankCellListData;
    }

    public function get myRankData():CClubRankCellData
    {
        return getChild(1) as CClubRankCellData;
    }
}
}
