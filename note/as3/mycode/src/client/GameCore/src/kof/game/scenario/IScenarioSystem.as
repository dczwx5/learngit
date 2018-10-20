//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/9/5.
 */
package kof.game.scenario {
public interface IScenarioSystem {

    // listen scenario start/ready/end event(CScenarioEvent.EVENT_SCENARIO_START)
    // callback(CScenarioEvent) : void
    function listenEvent(callback:Function) : void;
    function unListenEvent(callback:Function) : void;

    function playScenario(scenarioID:int, controlType:int, scenarioOverCallback:Function, isShowStartMask:Boolean = true, isShowEndMask:Boolean = true, levelStartScenarioID:int = -1) : void;//isShowStartMask是否显示剧情开场黑屏

    function stopScenario() : void;
}
}
