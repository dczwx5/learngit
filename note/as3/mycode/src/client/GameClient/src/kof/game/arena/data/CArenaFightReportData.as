//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/7/27.
 */
package kof.game.arena.data {

import kof.data.CObjectData;

/**
 * 竞技场战报数据
 */
public class CArenaFightReportData extends CObjectData {

    public static const Rank:String = "rank";// 排名
    public static const RoleId:String = "roleId";// 对手角色ID
    public static const RoleName:String = "roleName";// 对手战队名
    public static const HeroId:String = "heroId";// 对手展示的格斗家ID
    public static const BattleValue:String = "battleValue";// 对手战力
    public static const Result:String = "result";// 结果 0：失败 1：成功 2：完胜
    public static const Type:String = "type";// 0：进攻 1：防守
    public static const Time:String = "time";// 时间
    public static const SelfHeroList:String = "selfHeroList";// 己方格斗机列表
    public static const EnemyheroList:String = "heroList";// 敌方格斗机列表

    public function CArenaFightReportData()
    {
        super();
    }

//    public static function createObjectData(rank:int, roleId:Number, roleName:String, heroId:int, battleValue:int,
//                                            result:int, type:int, time:Number) : Object
//    {
//        return {rank:challengeNumber, buyNumber:buyNumber, freeNumber:freeNumber};
//    }

    public function get rank() : int { return _data[Rank]; }
    public function get roleId() : Number { return _data[RoleId]; }
    public function get roleName() : String { return _data[RoleName]; }
    public function get heroId() : int { return _data[HeroId]; }
    public function get battleValue() : int { return _data[BattleValue]; }
    public function get result() : int { return _data[Result]; }
    public function get type() : int { return _data[Type]; }
    public function get time() : Number { return _data[Time]; }
    public function get selfHeroList() : Array { return _data[SelfHeroList]; }
    public function get enemyheroList() : Array { return _data[EnemyheroList]; }
}
}
