/**
 * Created by auto on 2016/7/3.
 */
package kof.game.levelCommon.info.entity {
import kof.game.levelCommon.info.base.CTrunkTriggerData;

/**
 * 刷怪区域
 */
public class CTrunkEntityTriggerSpawn extends CTrunkTriggerData { // CTrunkAreaEventData {
    // filter : 目标类型筛选, 不理
    // tag : 触发器额外标记, 不知道有什么用
    // outEvent
    // deactiveEvents

    public function CTrunkEntityTriggerSpawn(data:Object) {
        super (data);
    }
}
}
