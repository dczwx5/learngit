/**
 * Created by auto on 2016/7/30.
 */
package kof.game.levelCommon.info.goal {
import kof.game.common.CCreateListUtil;

public class CTrunkGoalTargetInfo {
    public var object:Array; // CTrunkGoalTargetEntityInfo
    public var total:int; // 目标数量
    public function CTrunkGoalTargetInfo(data:Object) {
        object = CCreateListUtil.createArrayData(data["entity"], CTrunkGoalTargetEntityInfo);
        total = data["total"];
    }
}
}
