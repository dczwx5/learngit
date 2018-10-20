/**
 * Created by auto on 2016/9/21.
 */
package preview.game.levelServer.data {
import QFLib.Foundation.CMap;

// 所有数量初始数据, 用于monsterTrigger
public class CLevelSceneObjectAllCountStartData {
    public function CLevelSceneObjectAllCountStartData() {
        clear();
    }
    public function clear() : void {
        allMonsterCountData = null;
        monsterCountDataMap = null;
    }

    public function getMonsterCountData(monsterID:int) : CLevelSceneObjectCountData {
        var data:CLevelSceneObjectCountData = monsterCountDataMap[monsterID];
        return data;
    }
    public var allMonsterCountData:CLevelSceneObjectCountData;
    public var monsterCountDataMap:CMap; // data is CLevelSceneObjectCountData
}
}
