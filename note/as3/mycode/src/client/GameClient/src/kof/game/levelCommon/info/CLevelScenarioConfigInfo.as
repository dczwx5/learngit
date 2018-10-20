/**
 * Created by auto on 2016/7/21.
 */
package kof.game.levelCommon.info {
import kof.game.common.CCreateListUtil;
import kof.game.levelCommon.info.levelScenario.CLevelScenarioScenarioInfo;

// 关卡剧情文件配置
public class CLevelScenarioConfigInfo {
    public var scenarios:Array;
    public function CLevelScenarioConfigInfo(data:Object) {
        if (data == null) return ;
        scenarios = CCreateListUtil.createArrayData(data["scenarios"], CLevelScenarioScenarioInfo);
    }

    public function hasScenario() : Boolean {
        return scenarios && scenarios.length > 0;
    }
}
}
