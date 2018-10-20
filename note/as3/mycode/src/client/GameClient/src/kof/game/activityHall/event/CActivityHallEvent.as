//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Administrator on 2017/7/31.
 */
package kof.game.activityHall.event {

import flash.events.Event;

public class CActivityHallEvent extends Event {

    //活动状态变更
    public static const ActivityStateChanged : String = "ActivityStateChanged";
    //登录时的活动状态
    public static const ActivityStateInit : String = "ActivityStateInit";

    //活动大厅的活动状态变更
    public static const ActivityHallActivityStateChanged : String = "ActivityHallActivityStateChanged";

    //累计消费
    public static const ConsumeActivityResponse : String = "ConsumeActivityResponse";
    public static const ReceiveConsumeActivityResponse : String = "ReceiveConsumeActivityResponse";

    //累计充值
    public static const TotalRechargeResponse : String = "TotalRechargeResponse";
    public static const TotalRechargeRewardResponse : String = "TotalRechargeRewardResponse";

    //特惠商店
    public static const DiscounterResponse : String = "DiscounterResponse";
    public static const BuyDiscountGoodsResponse : String = "BuyDiscountGoodsResponse";

    //活跃任务
    public static const ActiveTaskResponse : String = "ActiveTaskResponse";
    public static const ActiveTaskRewardResponse : String = "ActiveTaskRewardResponse";
    public static const ActiveTaskUpdateEvent : String = "ActiveTaskUpdateEvent";
    //活动预览相关
    public static const ACTIVITYPREVIEWDATA : String =  "ActivityPreviewData";

    public function CActivityHallEvent( type : String, data : Object = null ) {
        super( type );
        this.data = data;
    }

    public var data : Object;
}
}
