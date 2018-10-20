//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/6.
 */
package kof.game.peak1v1.event {

import flash.events.Event;
public class CPeak1v1Event extends Event {
    // net event
    public static const NET_EVENT_DATA:String = "netPeak1v1Data"; // 初始数据
    public static const NET_EVENT_UPDATE_DATA:String = "netPeak1v1UpdateData"; // 更新数据
    public static const NET_ENEMY_PROGRESS_DATA:String = "netPeak1v1EnemyPgrogressData"; // 对手进度

    public static const NET_RESULT_DATA:String = "netPeak1v1ResultData"; // 结算
    public static const NET_REPORT_DATA:String = "netPeak1v1ReportData"; // 战报
    public static const NET_RANKING_DATA:String = "netPeak1v1RankingData"; // 排行
    public static const NET_DOWN_SINGLE_DATA:String = "netPeak1v1DownSingleData"; // 落单
    public static const NET_MATCH_DATA:String = "netPeak1v1MatchData"; // 匹配反馈

    // data event
    public static const DATA_EVENT:String = "peak1v1DataEvent"; // 数据改变, 具体什么数据改变, 由subEvent确定

    public function CPeak1v1Event(type:String, subEevent:String = null, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this.data = data;
        this.subEvent = subEevent;
    }

    public var data:Object;
    public var subEvent:String;
}
}
