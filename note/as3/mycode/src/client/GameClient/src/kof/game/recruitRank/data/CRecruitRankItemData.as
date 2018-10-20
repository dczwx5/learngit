//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Lune on 2018/5/16.
 * 招募排行榜单条数据
 */
package kof.game.recruitRank.data {

import QFLib.Foundation.CMap;

import kof.data.CObjectData;

public class CRecruitRankItemData extends CObjectData{
    public function CRecruitRankItemData() {
        super();
        _data = new CMap();
    }
    public function set roleID(value:Number) : void {
        _data[_roleID] = value;
    }
    public function set roleName(value:String) : void {
        _data[_roleName] = value;
    }
    public function set roleTimes(value:int) : void {
        _data[_roleTimes] = value;
    }
    public function set roleRank(value:int) : void {
        _data[_roleRank] = value;
    }
    public function set limitTimes(value:int) : void{
        _data[_limitTimes] = value;
    }



    public function get roleID() : Number { return _data[_roleID]; }
    public function get roleName() : String { return _data[_roleName]; }
    public function get roleTimes() : int { return _data[_roleTimes]; }
    public function get roleRank() : int { return _data[_roleRank]; }
    public function get limitTimes() : int { return _data[_limitTimes]; }

    public static const _roleID:String = "id";// 玩家ID
    public static const _roleName:String = "name";//玩家名称
    public static const _roleTimes:String = "times";//玩家次数
    public static const _roleRank:String = "rank";//玩家排名
    public static const _limitTimes:String = "limittimes";//玩家次数
}
}
