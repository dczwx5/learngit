/**
 * Created by auto on 2016/5/20.
 */
package kof.game.levelCommon.Enum {

// 对应 unity SceneTriggerObjectType
public class ETrunkEntityType {

    public static const PLAYER:int = 0; // 玩家
    public static const MAP_OBJ:int = 1; // 物件
    public static const MONSTER:int = 2; // 刷怪点
    public static const TRIGGER:int = 3; // 事件触发器
    public static const TIMER_TRIGGER:int = 4; // 定时触发器
    public static const GLOBAL_MONSTER:int = 5; // 怪物全局触发器
    public static const RANDOM_TRIGGER:int = 6; // 随机触发器
    public static const TIMER_HURT_TRIGGER:int = 7; // 定时伤害触发器
    public static const COUNT:int = TIMER_HURT_TRIGGER+1; // 总数, 当数量增加时, 应修改
}
}