//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/21.
 */
package kof.game.streetFighter.event {

import flash.events.Event;
public class CStreetFighterEvent extends Event {
    // net event
    public static const NET_EVENT_DATA:String = "netStreetFighterData"; // 初始数据
    public static const NET_EVENT_UPDATE_DATA:String = "netStreetFighterUpdateData"; // 更新数据
    public static const NET_EVENT_RANK_DATA:String = "netStreetFighterRankData"; // 排行榜
    public static const NET_EVENT_LOADING_PROGRESS_SYNC_DATA:String = "netStreetFighterLoadingProgressSyncData"; // 进度数据
    public static const NET_EVENT_LOADING_DATA:String = "netStreetFighterLoadingData"; // 服务器告诉客户端要进loaing
    public static const NET_EVENT_REPORT_DATA:String = "netStreetFighterReportData"; // 战报数据
    public static const NET_EVENT_MATCHING:String = "netStreetFighterMatching"; // 匹配状态改变(是否正在匹配)
    public static const NET_EVENT_MATCH_DATA:String = "netStreetFighterMatchData"; // 匹配对手数据
    public static const NET_EVENT_SETTLEMENT_DATA:String = "netStreetFighterSettlementData"; // 整场结算
    public static const NET_EVENT_ENTER_ERROR:String = "netStreetFighterEnterError"; // 匹配进入副本之间报错
    public static const NET_EVENT_SELECTED_HERO:String = "netStreetFighterSelectedHero"; // 选择人物
    public static const NET_EVENT_NOTIFY_CLIENT_REFRESH:String = "netStreetFighterNotifyClientRefresh"; // 通知客户端重新请求数据
    public static const NET_EVENT_GAME_PROMT:String = "netStreetFighterGamePromt"; // 错误码
    public static const NET_EVENT_GET_REWARD:String = "netStreetFighterGetReward"; //
    public static const NET_EVENT_SELECT_HERO_READY:String = "netStreetFighterSelectHeroReady"; // 所有人都确定了。
    public static const NET_EVENT_SELECT_HERO_SYNC:String = "netStreetFighterEnemySelectHeroSync"; // 同步对方的选择人物

    // data event
    public static const DATA_EVENT:String = "streetFighterDataEvent"; // 数据改变, 具体什么数据改变, 由subEvent确定

    public function CStreetFighterEvent( type:String, subEevent:String = null, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this.data = data;
        this.subEvent = subEevent;
    }

    public var data:Object;
    public var subEvent:String;
}
}
