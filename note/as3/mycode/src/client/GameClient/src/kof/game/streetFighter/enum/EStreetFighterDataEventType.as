//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/21.
 */
package kof.game.streetFighter.enum {

public class EStreetFighterDataEventType {
    public static const DATA:String = "data"; // all data change
    public static const MATCHING:String = "matching"; // matching data change, 是否正在匹配
    public static const MATCH_DATA:String = "match_data"; // match_data data change, 匹配对手数据
    public static const RANK:String = "rank"; // rank data change
    public static const LOADING_PROGRESS_SYNC:String = "loadingProgressSync"; // loading data change
    public static const LOADING:String = "loading"; // loading data change
    public static const REPORT:String = "report"; // report data change
    public static const SETTLEMENT:String = "settlement"; // 结算
    public static const ENTER_ERROR:String = "enterError"; // 进入报错
    public static const SELECT_HERO:String = "selectHero"; // 对手选择格斗家
    public static const GET_REWARD:String = "getReward"; // 进入报错
    public static const SELECT_HERO_READY:String = "select_hero_ready"; // 两边选择人物界面都准备好了
    public static const ENEMY_SELECT_HERO_SYNC:String = "enemy_select_hero_sync"; // 同步对方选择的人

    public static const DATA_LEVEL_CHANGE:String = "data_level_change"; // data_level_change


}
}
