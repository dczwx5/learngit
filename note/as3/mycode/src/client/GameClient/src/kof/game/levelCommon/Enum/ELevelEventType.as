/**
 * Created by auto on 2016/6/4.
 */
package kof.game.levelCommon.Enum {
public class ELevelEventType {
    public static const MONSTER_DIE:String = "monster_dead";
//    public static const EVENT_LEVEL_LOAD_COMPLETED:String = "loadLevelCompleted";
    public static const MONSTER_REMOVE:String = "monster_remove";

    // normal event
    public static const EVENT_ACTIVE:String = "activeEvents";
    public static const EVENT_ENTER:String = "enterEvents";
    public static const EVENT_PASS:String = "passEvents";
    public static const EVENT_COMPLETED:String = "completeEvents";

    // trigger Event
    public static const TRIGGER_EVENT_ACTIVE:String = EVENT_ACTIVE;
    public static const TRIGGER_EVENT_TRIGGER:String = "triggerEvents";
    public static const TRIGGER_EVENT_COMPLETED:String = EVENT_COMPLETED;

}
}
