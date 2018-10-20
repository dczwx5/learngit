/**
 * Created by auto on 2016/7/22.
 */
package kof.game.scenario.event {
import flash.events.Event;

public class CScenarioEvent extends Event{
    public static const EVENT_SCENARIO_ENTER:String = "scenario_enter"; // step 1
    public static const EVENT_SCENARIO_START:String = "scenario_start"; // step 2, 加载好剧情需要的东西, 同时黑屏也完成了
    public static const EVENT_SCENARIO_END:String = "scenario_end"; // step 3
    public static const EVENT_SCENARIO_END_B:String = "scenario_end_b"; // step 3, end step 2. END事件后, 处理完剧情的东西, 发起
    public static const EVENT_SCENARIO_END_C:String = "scenario_end_c"; // step 3, end step 3. END事件后, 处理完剧情的东西, 发起

    public function CScenarioEvent(type:String, rScenarioID:int, rControlType:int, risFail:Boolean, returnLevel:Boolean = true) {
        super(type, bubbles, cancelable);
//        trace("________________________CScenarioEvent : " +  type);

        scenarioID = rScenarioID;
        controlType = rControlType;
        isFail = risFail;
        this.returnLevel = returnLevel;
    }

    public var scenarioID:int;
    public var controlType:int;
    public var isFail:Boolean; // 是否加载失败
    public var returnLevel:Boolean; // 剧情完毕是否回关卡, EVENT_SCENARIO_END事件用到
}
}
