/**
 * Created by auto on 2016/7/3.
 */
package kof.game.levelCommon.info.entity {
import kof.game.levelCommon.info.base.CTrunkTriggerData;

/**
 * 随机触发器
 */
public class CTrunkEntityTriggerRandom extends CTrunkTriggerData {
    public var randomType:int;
    public var randomAttribute:int;
    public function CTrunkEntityTriggerRandom(data:Object) {
        super (data);

        randomType = data["randomType"];
        randomAttribute = data["randomAttribute"];
    }
}
}
