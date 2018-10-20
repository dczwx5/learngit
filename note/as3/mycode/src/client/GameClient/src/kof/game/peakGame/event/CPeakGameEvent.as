//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/6.
 */
package kof.game.peakGame.event {

import flash.events.Event;
public class CPeakGameEvent extends Event {
    // net event
    public static const NET_EVENT_DATA:String = "netPeakGameData"; // 初始数据
    public static const NET_EVENT_UPDATE_DATA:String = "netPeakGameUpdateData"; // 更新数据
    public static const NET_EVENT_RANK_DATA:String = "netPeakGameRankData"; // 排行榜
    public static const NET_EVENT_LOADING_DATA:String = "netPeakGameLoadingData"; // 进度数据
    public static const NET_EVENT_REPORT_DATA:String = "netPeakGameReportData"; // 战报数据
    public static const NET_EVENT_HONOUR_DATA:String = "netPeakGameHonourData"; // 荣耀殿堂数据
    public static const NET_EVENT_MATCHING:String = "netPeakGameMatching"; // 匹配状态改变(是否正在匹配)
    public static const NET_EVENT_MATCH_DATA:String = "netPeakGameMatchData"; // 匹配对手数据
    public static const NET_EVENT_SETTLEMENT_DATA:String = "netPeakGameSettlementData"; // 整场结算
    public static const NET_EVENT_ENTER_ERROR:String = "netPeakGameEnterError"; // 匹配进入副本之间报错
    public static const NET_EVENT_NOTIFY_CLIENT_REFRESH:String = "netPeakGameNotifyClientRefresh"; // 通知客户端重新请求数据
    // data event
    public static const DATA_EVENT:String = "peakGameDataEvent"; // 数据改变, 具体什么数据改变, 由subEvent确定

    public function CPeakGameEvent(type:String, subEevent:String = null, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this.data = data;
        this.subEvent = subEevent;
    }

    public var data:Object;
    public var subEvent:String;
}
}
