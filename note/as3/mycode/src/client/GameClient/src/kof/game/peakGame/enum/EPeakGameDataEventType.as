//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/7.
 */
package kof.game.peakGame.enum {

public class EPeakGameDataEventType {
    public static const DATA:String = "data"; // all data change
    public static const MATCHING:String = "matching"; // matching data change, 是否正在匹配
    public static const MATCH_DATA:String = "match_data"; // match_data data change, 匹配对手数据
    public static const RANK:String = "rank"; // rank data change
    public static const LOADING:String = "loading"; // loading data change
    public static const REPORT:String = "report"; // report data change
    public static const HONOUR:String = "honour"; // honour data change
    public static const SETTLEMENT:String = "settlement"; // 结算
    public static const ENTER_ERROR:String = "enterError"; // 进入报错

    public static const DATA_LEVEL_CHANGE:String = "data_level_change"; // data_level_change


}
}
