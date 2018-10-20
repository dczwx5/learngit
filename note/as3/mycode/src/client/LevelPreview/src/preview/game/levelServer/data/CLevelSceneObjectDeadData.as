/**
 * Created by auto on 2016/7/30.
 */
package preview.game.levelServer.data {
public class CLevelSceneObjectDeadData {
    public function CLevelSceneObjectDeadData(rMonsterID:int, rCount:int) {
        monsterID = rMonsterID;
        count = rCount;
    }

    public var monsterID:int; // 非entityID, 而是具体的怪物ID, 物件ID
    public var count:int;
}
}
