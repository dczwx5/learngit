//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/9/30.
 */
package kof.game.instance.event {

import flash.events.Event;
public class CInstanceEvent extends Event {
    // 业务事件
    public static const INSTANCE_DATA_INITIAL:String = "instanceDataInitial";
    public static const INSTANCE_DATA:String = "instanceData";
    public static const INSTANCE_SWEEP_DATA:String = "sweepData";
    public static const CHAPTER_REWARD:String = "chapterReward";
    public static const INSTANCE_PASS_REWARD:String = "instancePassReward";
    public static const INSTANCE_MODIFY:String = "instanceModify";
    public static const INSTANCE_BUY_COUNT:String = "instanceBuyCount";
    public static const INSTANCE_GET_EXTENDS_REWARD:String = "instanceGetExtendsReward"; // 宝箱
    public static const INSTANCE_GET_ONE_KEY_REWARD:String = "instanceGetOneKeyReward"; // 一键

    public static const INSTANCE_FIRST_PASS:String = "instanceFirstPass"; // 副本首次通关
    public static const INSTANCE_CHAPTER_FINISH:String = "instanceChapterFinish"; // 章节结束
    public static const INSTANCE_CHAPTER_OPEN:String = "instanceChapterOpen"; // 开新章节

    // 流程事件
    public static const ENTER_INSTANCE:String = "ENTER_INSTANCE"; // 收到进入副本协议

    public static const LEVEL_ENTER:String = "levelEnter";　// 收到关卡开始, 此时只是加载好关卡配置等
    public static const LEVEL_ENTERED:String = "levelEntered"; // 开场剧情开始之后, 看到场景了
    public static const LEVEL_STARTED:String = "levelStarted"; // ready go 之后, 关卡开始, 此时可以开始战斗
    public static const LEVEL_PLAYER_READY:String = "levelPlayerLevelReady"; // levelStarted->playerReady
    public static const LEVEL_EXIT:String = "levelExit"; // levelExit

    public static const END_INSTANCE:String = "END_INSTANCE"; // 副本结束
    public static const EXIT_INSTANCE:String = "EXIT_INSTANCE"; // 接收到副本退出反馈
    public static const STOP_INSTANCE:String = "STOP_INSTANCE"; // 中途退出副本反馈
    public static const INSTANCE_ALL_GAME_OBJECT_FINISH_OR_TIME_OUT:String = "instanceStartWaitAllGameObjectFinish"; // 副本所有动作都停止了

    public static const SCENARIO_START:String = "scenarioStart"; // 剧情开始,
    public static const SCENARIO_END:String = "scenarioEnd"; // 剧情结束, 一次关卡会出现多个事件

    public static const WINACTOR_STRAT:String = "WINACTOR_STRAT"; // 胜利动作开始
    public static const WINACTOR_END:String = "WINACTOR_END"; // 胜利动作结束
    public static const INSTANCE_UPDATE_TIME:String = "updateTime"; // 更新时间
    public static const LEVEL_PROCESS_READY_GO_BY_OTHER:String = "levelProcessReadGoByOther"; // 由其他系统处理readyGo

    public static const CHARACTOR_DIE:String = "charactorDie";


    // NetEvent
    public static const NET_EVENT_INSTANCE_ENTER:String = "netEventEnterInstance";
    public static const NET_EVENT_LEVEL_ENTER:String = "netEventEnterLevel"; // 开始进入
    public static const NET_EVENT_LEVEL_ENTERED:String = "netEventLevelEntered"; // 进入关卡完成
    public static const NET_EVENT_LEVEL_START:String = "netEventLevelStart";
    public static const NET_EVENT_LEVEL_PORTAL_START:String = "netEventLevelPortalStart"; // 开始传送
    public static const NET_EVENT_UPDATE_TIME:String = "netEventUpdateTime";
    public static const NET_EVENT_INSTANCE_OVER:String = "netEventInstanceOver";

    public static const NET_EVENT_STOP_INSTANCE:String = "netEventStopInstance";

    public static const BOSS_CHALLENGE_OVER:String = "bossChallengeOver";//boss挑战结束
    public static const WIN : String = "win";
    public static const LOSE : String = "lose";
    public static const ASSERT : String = "assert";


    public function CInstanceEvent(type:String, data:Object, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        // trace("________________________INSTANCE_EVENT : " +  type);
        this.data = data;
    }

    public var data:Object;
}
}
