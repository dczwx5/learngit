/**
 * Created by auto on 2016/5/24.
 * update by auto on 2016/9/12.
 * 用于服务器 刷怪区域
 */
package preview.game.levelServer.trigger {

import flash.geom.Point;
import flash.geom.Rectangle;

import kof.game.levelCommon.Enum.ELevelTriggerConditionType;
import kof.game.levelCommon.info.base.CTrunkEntityBaseData;
import kof.game.levelCommon.info.trunk.CTrunkConfigInfo;
import preview.game.levelServer.CLevelServer;
import preview.game.levelServer.trigger.handler.CTriggerCondHandleZoneEnter;
import preview.game.levelServer.trigger.handler.CTriggerCondHandleZoneMove;
import preview.game.levelServer.trigger.handler.CTriggerCondHandleZoneOut;
import preview.game.levelServer.trigger.handler.CTriggerCondHandleZoneStand;

public class CTriggerZone extends AbsLevelServerTrigger {
    public function CTriggerZone(server:CLevelServer, trunkInfo:CTrunkConfigInfo, trunkEntityInfo:CTrunkEntityBaseData) {
        super(server, trunkInfo, trunkEntityInfo, 1);
        this.addHandler(ELevelTriggerConditionType.TRIGGER_ZONE_ENTER, CTriggerCondHandleZoneEnter);

        this.addHandler(ELevelTriggerConditionType.TRIGGER_ZONE_OUT, CTriggerCondHandleZoneOut);
        this.addHandler(ELevelTriggerConditionType.TRIGGER_ZONE_STAND, CTriggerCondHandleZoneStand);
        this.addHandler(ELevelTriggerConditionType.TRIGGER_ZONE_MOVE, CTriggerCondHandleZoneMove);
    }

    // x, y为矩形的左上角
    public function getLTZoneRect() : Rectangle {
        if (!_trunkEntityInfo) return null;
        var rect:Rectangle = new Rectangle();
        var zonePos:Point = new Point(_trunkEntityInfo.location.x, _trunkEntityInfo.location.y); // CSceneGridHandler.grid2Pixel(_trunkEntityInfo.position.x, _trunkEntityInfo.position.y);

        rect.width = _trunkEntityInfo.size.x;
        rect.height = _trunkEntityInfo.size.y;

        rect.x = zonePos.x - rect.width/2;
        rect.y = zonePos.y-rect.height/2; // + yFixed;
        return rect;

    }
}
}
