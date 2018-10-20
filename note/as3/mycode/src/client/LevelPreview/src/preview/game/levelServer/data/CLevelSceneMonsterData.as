/**
 * Created by user on 2016/11/24.
 */
package preview.game.levelServer.data {
import flash.utils.Dictionary;

public class CLevelSceneMonsterData extends CLevelSceneObjectData {
    public var HP:int;
    public var attackPower:int;
    public var defensePower:int;

    public var updateTime:Dictionary = new Dictionary();
    public function CLevelSceneMonsterData() {
        super();
    }

}
}
