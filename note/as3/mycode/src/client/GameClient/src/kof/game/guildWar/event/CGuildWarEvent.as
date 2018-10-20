//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/4/24.
 */
package kof.game.guildWar.event {

import flash.events.Event;

public class CGuildWarEvent extends Event {

    public static const InitBaseInfo:String = "InitBaseInfo";// 初始化公会战基本信息数据
    public static const UpdateBaseInfo:String = "UpdateBaseInfo";// 更新公会战基本信息数据
    public static const UpdateStationInfo:String = "UpdateStationInfo";// 更新公会战空间站信息
    public static const UpdateMatchInfo:String = "UpdateMatchInfo";// 更新匹配信息
    public static const UpdateProgressInfo:String = "UpdateProgressInfo";// 更新进度信息
    public static const FIRST_UPDATE_VIEW:String = "firstUpdateView";// 更新进度信息
    public static const CancelMatch:String = "CancelMatch";// 取消匹配
    public static const UpdateClubRankInfo:String = "UpdateClubRankInfo";// 公会战某个空间站俱乐部排行数据更新
    public static const UpdateRoleRankInfo:String = "UpdateRoleRankInfo";// 公会战某个空间站个人排行数据更新
    public static const UpdateTotalScoreRankInfo:String = "UpdateTotalScoreRankInfo";// 公会战总能源排行数据更新
    public static const UpdateStationTotalScoreRankInfo:String = "UpdateStationTotalScoreRankInfo";// 公会战空间站能源排行数据更新
    public static const ObtainSpaceShowInfo:String = "ObtainSpaceShowInfo";// 活动结束后占领的空间站展示信息
    public static const UpdateFightReportInfo:String = "UpdateFightReportInfo";// 更新战报信息
    public static const UpdateBuffInfo:String = "UpdateBuffInfo";// 更新战斗激活信息
    public static const UpdateBuffResponseInfo:String = "UpdateBuffResponseInfo";// 更新战斗激活反馈信息
    public static const UpdateStationBoxRewardInfo:String = "UpdateStationBoxRewardInfo";// 更新已占领的空间站宝箱奖励和保底奖励信息
    public static const UpdateGiftBagAllocateInfo:String = "UpdateGiftBagAllocateInfo";// 更新礼包分配信息
    public static const UpdateGiftBagRecordInfo:String = "UpdateGiftBagRecordInfo";// 更新礼包分配记录信息

    public var data:Object;

    public function CGuildWarEvent(type:String, data:Object, bubbles:Boolean = false, cancelable:Boolean = false)
    {
        super(type, bubbles, cancelable);
        this.data = data;
    }
}
}
