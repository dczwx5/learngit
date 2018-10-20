//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/7/20.
 */
package kof.game.rank.data {

public class CRankConst {
    public function CRankConst() {
    }

    //排行榜类型
    static public const POWER_RANK : int = 1;//战力榜
    static public const FIGHTER_RANK : int = 2;//最强格斗家榜
    static public const CLUB_RANK : int = 3;//俱乐部榜
    static public const FIGHTER_NUM_RANK : int = 4;//格斗家数量榜
    static public const ROLE_LEVEL_RANK : int = 5;//战队等级榜
    static public const ENDLESS_TOWER_RANK : int = 6;//无尽塔
    static public const HERO_TOTAL_STAR_RANK : int = 7;//格斗家总星级榜
    static public const ARTIFACT_TOTAL_BATTLE_VALUE_RANK : int = 8;//神器战力榜



    static public const TITLE_ARY : Array = [
        ['排名','战队名称','战斗力'],
        ['排名','战队名称','格斗家名字'],
        ['排名','俱乐部名称                  成员','总战斗力'],
        ['排名','战队名称','格斗家数量'],
        ['排名','战队名称','战队等级'],
        ['排名','战队名称','层数'],
        ['排名','战队名称','格斗家总星级'],
        ['排名','战队名称','神器总战力']];






}
}
