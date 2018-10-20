//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/30.
 */
package kof.game.Tutorial.enum {

public class ETutorFinsinCondType {
    public static const COND_DEFAULT:int = 0; // 直接通过
    public static const COND_INSTANCE_COMPLETED:int = 1002;
    public static const COND_HAS_HERO:int = 1003;
    public static const COND_TASK_FINISH:int = 1004;
    public static const COND_IS_OPEN_SYSTEM_BUNDLE:int = 1005; // bundle界面是否打开
    public static const COND_IS_SELECT_EQUIP_CAN_UPGRADE_QUALITY:int = 1006;
    public static const COND_IS_CHAPTER_REWARD_HAS_GETTED:int = 1007;
//    public static const COND_7_DAY_NEW_SERVER_:int = 1007;

    public static const COND_ARTIFACT_1_IS_UNLOCK:int = 1009; // 神器已解锁
    public static const COND_IS_VIEW_CLOSE:int = 1011; // 非bundle界面是否关闭
    public static const COND_IS_CLOSE_SYSTEM_BUNDLE:int = 1012; // bundle界面 是否关闭
    public static const COND_IS_PLAYER_READY:int = 1013; // 等待playerReady
    public static const COND_SCENARIO_EMBATTLE_COUNT:int = 1014; // 剧情副本上阵格斗家数量
    public static const COND_7_DAY_NEW_SERVER_IS_CLOSED:int = 1015; // 七天新服活动是否结束
    public static const COND_7_DAY_NEW_SERVER_IS_SELECT_TAB1:int = 1016; // 七天新服活动是否选中第一个tab
    public static const COND_IS_VIEW_SHOW:int = 1017; // 非bundle界面是否打开
    public static const COND_IS_SELECT_TAB:int = 1018; // 是否显示指定tab, 参数1:TUTOR_TAB_ID, 参数2 : tab index
    public static const COND_IS_CARNIVAL_CLOSED:int = 1019; // 新服狂欢是否结束

}
}
