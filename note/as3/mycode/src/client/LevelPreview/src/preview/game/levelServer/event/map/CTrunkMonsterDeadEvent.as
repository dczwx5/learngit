/**
 * Created by auto on 2016/7/30.
 */
package preview.game.levelServer.event.map {
import flash.events.Event;

public class CTrunkMonsterDeadEvent extends Event{

    public function CTrunkMonsterDeadEvent(type:String, rEntityType:int, rMonsterID:int, rUniID:int) {
        super(type,false,false);
        entityType = rEntityType;
        monsterID = rMonsterID;
        uniID = rUniID;

    }

    public var entityType:int; // 物件类型
    public var monsterID:int; // 物体id, 非惟一ID, 非entityID, 是具体的怪物id,
    public var uniID:int; // 惟一ID
}
}
