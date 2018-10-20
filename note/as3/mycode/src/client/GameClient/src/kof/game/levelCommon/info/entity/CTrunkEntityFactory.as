/**
 * Created by auto on 2016/7/3.
 */
package kof.game.levelCommon.info.entity {
import kof.game.levelCommon.Enum.ETrunkEntityType;
import kof.game.levelCommon.info.base.CTrunkEntityBaseData;
import kof.game.levelCommon.info.entity.CTrunkTriggerTimerData;

public class CTrunkEntityFactory {
    public static function createTrunkEntity(data:Object) : CTrunkEntityBaseData {
        var entity:CTrunkEntityBaseData;
        var type:int = data["type"];
        switch (type) {
            case ETrunkEntityType.MAP_OBJ:
                entity = new CTrunkEntityMapObject(data);
                break;
            case ETrunkEntityType.MONSTER:
                entity = new CTrunkEntityMonster(data);
                break;
            case ETrunkEntityType.TRIGGER:
                entity = new CTrunkEntityTriggerSpawn(data);
                break;
            case ETrunkEntityType.TIMER_HURT_TRIGGER:
                entity = new CTrunkEntityTimeHurtTriggerData(data);
                break;
            //case ETrunkEntityType.PORTAL:
            //    entity = new CTrunkEntityTriggerPortal(data);
            //    break;
            case ETrunkEntityType.TIMER_TRIGGER:
                entity = new CTrunkTriggerTimerData(data);
                break;
            //case ETrunkEntityType.SPELL_AGENT:
            //    entity = new CTrunkEntitySpellAgent(data);
                break;
            //case ETrunkEntityType.SPECIAL_POINT:
            //    entity = new CTrunkEntitySpecialPoint(data);
            //    break;
            case ETrunkEntityType.GLOBAL_MONSTER:
                entity = new CTrunkEntityTriggerGlobalMonster(data);
                break;
            case ETrunkEntityType.RANDOM_TRIGGER:
                entity = new CTrunkEntityTriggerRandom(data);
                break;
            //case ETrunkEntityType.SPECIAL_ZONE:
            //   entity = new CTrunkEntitySpecialZone(data);
             //   break;
        }
        return entity;
    }

}
}
