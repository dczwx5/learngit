//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/3.
 */
package kof.game.level.event {

import flash.events.Event;

public class CLevelEvent extends Event {

    public static const ENTER:String = "enter"; // 开始进入关卡发出, 准备开始关卡
    public static const ENTERED : String = "entered"; // 进入完毕, 显示关卡内容

    public static const SCENARIO_START:String = "scenarioStart";
    public static const SCENARIO_END:String = "scenarioEnd";

    public static const READY_GO:String = "readyGO";
    public static const START:String = "start"; // 关卡真正开始, 可以控制了

    public static const EACHGAME_END:String = "eachGameEnd"; // 单回合结算
    public static const WINACTOR_END:String = "winActorEnd";
    public static const WINACTOR_START:String = "winActorStart";

    public static const INSTANCE_EXIT:String = "instanceExit";

    public static const ROLE_DIE:String = "roleDie";
    public static const PLAYER_READY:String = ""; // 玩家创建好 levelStart->playerReady
    public static const WHEEL_WAR_HERO_STATUS_LIST:String = "WheelWarHeroStatusList"; // 车轮战格斗家状态列表

    public static const ACTIVE_TRUNK:String = "activeTrunk";//激活trunk
    public static const ENTER_TRUNK:String = "enterTrunk";//进入trunk

    public static const EXIT:String = "exit"; // ready enter


//    public static const BOSS_COMING_END:String = "bossComing_end"; //BOSS来袭结束

    public function CLevelEvent(type : String, data:Object, bubbles : Boolean = false, cancelable : Boolean = false) {
        super(type, bubbles, cancelable);
//        trace("________________________CLevelEvent : " +  type);

        _data = data;
    }

    public function get data() : Object {
        return _data;
    }
    private var _data:Object;
}
}
