/**
 * Created by auto on 2016/8/1.
 */
package kof.game.level {
import kof.game.character.CCharacterDataDescriptor;
import kof.game.levelCommon.Enum.ETrunkEntityType;

// 类型转换
public class CLevelTypeExchange {

    /*
     * 暂只支持怪物和npc与player
     */
    public static function ExchangeCharacterTypeToEntityType(type:int) : int {
        switch (type) {
            case CCharacterDataDescriptor.TYPE_MAP_OBJECT:
                return ETrunkEntityType.MAP_OBJ;
            case CCharacterDataDescriptor.TYPE_MONSTER:
                return ETrunkEntityType.MONSTER;
            case CCharacterDataDescriptor.TYPE_PLAYER:
                return ETrunkEntityType.PLAYER;
        }
        return -1;
    }
}
}
