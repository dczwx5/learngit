//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Maniac on 2017/8/17.
 */
package kof.game.limitActivity.data {

import QFLib.Foundation.CMap;

import kof.data.CObjectData;
/**
 * 商店售卖物品信息
 */
public class CLimitScoreRankItemData extends CObjectData{

    public function CLimitScoreRankItemData() {
        super();
        _data = new CMap();
    }

    public function set roleID(value:Number) : void {
        _data[_roleID] = value;
    }
    public function set roleName(value:String) : void {
        _data[_roleName] = value;
    }
    public function set roleScore(value:int) : void {
        _data[_roleScore] = value;
    }
    public function set roleRank(value:int) : void {
        _data[_roleRank] = value;
    }


    public function get roleID() : Number { return _data[_roleID]; }
    public function get roleName() : String { return _data[_roleName]; }
    public function get roleScore() : int { return _data[_roleScore]; }
    public function get roleRank() : int { return _data[_roleRank]; }

    public static const _roleID:String = "id";// 玩家ID
    public static const _roleName:String = "name";//玩家名称
    public static const _roleScore:String = "score";//玩家积分
    public static const _roleRank:String = "rank";//玩家排名

}
}
