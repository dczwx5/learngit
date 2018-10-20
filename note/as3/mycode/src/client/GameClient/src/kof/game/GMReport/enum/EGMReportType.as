//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/12/9.
 */
package kof.game.GMReport.enum {

public class EGMReportType {

    /** 建议反馈 */
    public static const Type_Suggestion:int = 1;
    /** 错误反馈 */
    public static const Type_Error:int = 2;
    /** 盗号受理 */
    public static const Type_Hacking:int = 3;
    /** 充值问题 */
    public static const Type_Charge:int = 4;
    /** 游戏问题咨询 */
    public static const Type_Advisory:int = 5;
    /** 游戏活动相关 */
    public static const Type_Activity:int = 6;
    /** 充值盗号 */
    public static const Type_ChargeHacking:int = 7;
    /** 外挂作弊 */
    public static const Type_Cheat:int = 8;
    /** 虚假欺骗 */
    public static const Type_Fake:int = 9;
    /** 拉人骚扰 */
    public static const Type_Harass:int = 10;
    /** Bug反馈 */
    public static const Type_BugFeedBack:int = 11;
    /** 其他 */
    public static const Type_Other:int = 12;

    public function EGMReportType()
    {
    }
}
}
