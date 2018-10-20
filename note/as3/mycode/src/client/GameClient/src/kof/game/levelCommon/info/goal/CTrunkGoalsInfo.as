/**
 * Created by auto on 2016/5/28.
 * trunk目标 还没应用上去
 */
package kof.game.levelCommon.info.goal {

import kof.game.common.CCreateListUtil;

public class CTrunkGoalsInfo {
    public var targetType:int; // ETrunkGoalType 目标类型
    public var target:Array; // 目标对象

    public function CTrunkGoalsInfo(data:Object) {
        this.targetType = data["targetType"];
        target = CCreateListUtil.createArrayData(data["target"], CTrunkGoalTargetInfo)
    }


}
}
