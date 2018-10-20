/**
 * Created by auto on 2016/8/1.
 */
package preview.game.levelServer.data {
import kof.game.core.CGameObject;

public class CLevelSceneObjectData {
    public var uniID:Number; // uniqID
    public var gameObjectType:int; // sceneObjectType : 1:player, 2:monster, 3:object
    public var objectID:int; // monsterID
    public var entityID:int; // entityID
    public var mapObject:CGameObject; //
    public var entityType:int; // 关卡实体类型

    public var campID:int; //阵营ID
    public var objectTypeID:int //对象类别ID

    // use by trigger. record info...
    public var hpByStart:int;
    public var hpAddByStart:int;
    public var hpReduceByStart:int;

    public function CLevelSceneObjectData() {

    }
}
}
