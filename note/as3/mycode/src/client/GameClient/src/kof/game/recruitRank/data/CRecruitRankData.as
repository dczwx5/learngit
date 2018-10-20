//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Lune on 2018/5/16.
 * 招募排行榜数据
 */
package kof.game.recruitRank.data {

import QFLib.Foundation.CMap;

import kof.data.CObjectData;
import kof.table.RecruitRankActivityRankConfig;

public class CRecruitRankData extends CObjectData{

    private var _lenth:int;
    private var _limitTimes:Array;
    public function CRecruitRankData() {
        super();
    }
    override public function updateDataByData( data : Object ) : void
    {
        if (!data) return ;
        resetData();
        for each(var obj:Object in data)
        {
            var itemData:CRecruitRankItemData = new CRecruitRankItemData();
            itemData.updateDataByData(obj);
            _data[itemData.roleRank] = itemData;
        }
    }
    public function set LimitTimes(value:Array):void
    {
        _limitTimes = [];
        for(var i:int = 0; i < value.length; i++)
        {
            _limitTimes.push(value[i].needTimes);
        }
        _limitTimes.sort(Array.NUMERIC|Array.DESCENDING);
        lenth = _limitTimes.length;
        resetData();
    }
    public function get rankInfos() : Array {
        return _data.toArray();
    }

    public function resetData():void{
        _data = new CMap();
        for(var i:int = 1; i <= _lenth; i++){
            var data:CRecruitRankItemData = new CRecruitRankItemData();
            data.roleID = 0;
            data.roleName = "";
            data.roleRank = i;
            data.roleTimes = 0;
            data.limitTimes = _limitTimes[i-1];
            _data[i] = data;
        }
    }
    public function get lenth() : int {
        return _lenth;
    }

    public function set lenth( value : int ) : void {
        _lenth = value;
    }
}
}
