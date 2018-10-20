/**
 * Created by auto on 2016/7/30.
 */
package kof.game.levelCommon.info.goal {
public class CTrunkGoalTargetEntityInfo {
    public var entityType:int; // ETrunkEntityType
    public var entityID:int; // entityID. 刷怪点点ID, 而非具体的刷怪点, 最终需要得到怪物ID来处理
    public function CTrunkGoalTargetEntityInfo(data:Object) {
        entityType = data["entityType"];
        entityID = data["entityID"];
    }
}
}
