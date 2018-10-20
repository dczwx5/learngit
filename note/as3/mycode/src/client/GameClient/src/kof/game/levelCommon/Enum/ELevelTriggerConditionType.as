/**
 * Created by auto on 2016/9/12.
 */
package kof.game.levelCommon.Enum {
public class ELevelTriggerConditionType {
    // zone
    public static const TRIGGER_ZONE_ENTER:String = "enter";
    public static const TRIGGER_ZONE_OUT:String = "out";
    public static const TRIGGER_ZONE_STAND:String = "stand";
    public static const TRIGGER_ZONE_MOVE:String = "move";

    // timer
    public static const TRIGGER_TIMER:String = "timer";

    // monster
    public static const TRIGGER_MONSTER_COUNT_CHANGE:String = "countChange";
    public static const TRIGGER_MONSTER_PROPERTY_CHANGE:String = "propertyChange";
}
}
