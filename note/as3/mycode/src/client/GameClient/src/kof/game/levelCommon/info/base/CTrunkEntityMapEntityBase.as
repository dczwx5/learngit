/**
 * Created by auto on 2016/7/7.
 */
package kof.game.levelCommon.info.base {
public class CTrunkEntityMapEntityBase extends CTrunkObjectEventData{
    public var tribe:String; // 副本阵营关系类型 , 不理
    public var tribeID:int; // 副本阵营关系类型 , 不理
    public var objectID:int; // 物件类型
    private var _spawnID:int; // 怪物ID
    public var ori:int; //方向 : 0 : 自动, -1 : 始终朝左, 1 : 始终朝右

    public function CTrunkEntityMapEntityBase(data:Object) {
        super (data);

        tribe = data["tribe"];
        tribeID = data["tribeID"];
        objectID = data["objectID"];
        _spawnID = data["spawnID"];
        ori = data["ori"];
    }

    public function get spawnID() : int {
        return _spawnID;
    }

}
}
