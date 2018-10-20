//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Administrator on 2017/8/9.
 */
package kof.game.activityHall.data {

public class CActivityHallActivityType {
    //所有活动类型——Activity表中
    public static const CONSUME : int = 1;//累计消费
    public static const CHARGE : int = 2;//累计充值
    public static const DISCOUNT : int = 4;//特惠商店
    public static const LIMIT : int = 5;//限时消费榜
    public static const ROULETTE : int = 6;//幸运轮盘
    public static const RECRUIT : int = 7;//招募狂欢
    public static const ACTIVE_TASK : int = 8;//活跃任务
    public static const HERO_TREASURE :int = 9;//格斗家宝藏
    public static const LOTTERY : int = 10;//超级抽抽乐
    public static const ACTIVITY_TREASURE :int = 11;//挖宝大行动（影二的修行）
    public static const ACTIVITY_PREVIEW : int = 999;//活动预览

    public static const ACTIVITY_TYPE_LIST : Array = [ CONSUME, CHARGE, DISCOUNT, ACTIVE_TASK ];

    //限购类型
    public static const SERVER_LIMIT : int = 1;
    public static const PERSON_LIMIT : int = 2;
    public static const NO_LIMIT : int = 3;
}
}
