//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/5.
 */
package kof.game.Tutorial.enum {


public class ETutorActionType {
    public static const GUIDE_CLICK:int = 1001; // 指引点击
    public static const SHOP_ITEM_CLICK:int = 1002; // 点击物品

    public static const PLAY_SCENARIO:int = 2001; // 播放剧情对话

    public static const NPC_TRACK:int = 3001; // 找NPC
    public static const NPC_DIALOG:int = 3002; // NPC对话
    public static const NPC_DIALOG_OR_CLICK:int = 3003; // NPC对话, 或点击对话框的确定按钮, 因为和npc对话会有两种可能

    public static const ROLE_TEAM_CREATION:int = 4001; // 战队创建
    public static const ROLE_TEAM_UPGRADE:int = 4002; // 战队升级

    public static const SYSTEM_BUNDLE_SET_ACTIVED:int = 5001; // 打开/关闭系统界面
    public static const SYSTEM_BUNDLE_ACTIVITY_VALUE:int = 5002; // 判断系统界面打开或关闭
    public static const SYSTEM_BUNDLE_GUIDE_CLICK:int = 5003; // 主界面系统功能指引点击

    public static const HERO_GOT:int = 6001; // 格斗家招募
    public static const EMBATTLE_HERO:int = 6002; // 格斗家布阵
    public static const HERO_CLICK:int = 6003; // 选择格斗家

    public static const INSTANCE_FIGHT_CLICK:int = 7001; // 点击副本, 并进入副本, 有两种异常可能, 副本界面未打开和调出了detail界面
    public static const INSTANCE_CHANGE_CHAPTER:int = 7002; //
    public static const FINISH_WHEN_RETURN_MAIN_CITY:int = 7003; // 再次回到主城完成

    public static const ACTIVITY_NEW_SERVER_GET_REWARD:int = 8001; // 第一天的七天新服活动领奖
    public static const DAILY_TASK_REWARD_LIST:int = 8002; // 每日任务领取奖励
    public static const ARENA_ENEMY_FIGHT:int = 8003; // 竞技场挑战
    public static const TALENT_ITEM_CLICK:int = 8004; // 斗魂点击第一个item
    public static const TALENT_SELECT_LIST_CLICK:int = 8005; // 斗魂镶嵌宝石

    public static const CARNIVAL_SELECT_DAY:int = 8100; // 选择天
    public static const CARNIVAL_SELECT_TAB:int = 8101; // 选择tab
    public static const CARNIVAL_CLICK_REWARD:int = 8102; // 点击领取

    public static const TEACHING_SELECT_TAB:int = 8200; // 选择tab
    public static const TEACHING_CLICK_FIGHT:int = 8201; // 点击挑战



    public static const SHOW_FIRST_RECHARGE_TIPS:int = 9997; // 显示首充tips
    public static const SET_PLAY_HANDLE:int = 9998; // 设置playHandle, 直接通过
    public static const DO_NOTHING:int = 9999; // 无所事事动作, 通过条件配置完成条件 ActionFinishCondID
    public static const TEST_PRESS_P:int = 10000; // 按p通过当前步骤

}
}
