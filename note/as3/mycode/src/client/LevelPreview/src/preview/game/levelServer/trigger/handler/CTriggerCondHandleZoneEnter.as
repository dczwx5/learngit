/**
 * Created by auto on 2016/9/13.
 */
package preview.game.levelServer.trigger.handler {
import QFLib.Framework.CObject;
import QFLib.Math.CVector2;
import QFLib.Math.CVector3;

import flash.geom.Point;
import flash.geom.Rectangle;

import kof.game.character.handler.CPlayHandler;
import kof.game.core.CECSLoop;
import kof.game.core.CGameObject;
import kof.game.core.ITransform;
import kof.game.levelCommon.CLevelLog;
import kof.game.levelCommon.info.base.CTrunkConditionInfo;
import preview.game.levelServer.trigger.AbsLevelServerTrigger;
import kof.game.scene.CSceneHandler;
import kof.game.scene.CSceneObjectLists;
import kof.game.scene.CSceneSystem;

public class CTriggerCondHandleZoneEnter extends CTriggerCondHandleBase {
    private var m_isEnter:Boolean;
    public function CTriggerCondHandleZoneEnter(trigger:AbsLevelServerTrigger) {
        super (trigger);
    }

    public override function handler(cond:CTrunkConditionInfo,triggerFilter:Array) : Boolean {
        var playerTransform:ITransform;
        var all : Object = ((_trigger as AbsLevelServerTrigger).server.system.stage.getSystem( CSceneSystem ) as CSceneSystem).allGameObjectIterator;
        for each (var gameObj:CGameObject in all){
            for each ( var obj:Object in triggerFilter){
                if(gameObj.isRunning && gameObj.data.campID == obj.tribeID && gameObj.data.objectID == obj.objectID){
                    playerTransform = gameObj.transform;
                }
            }
        }

        // 需要人物坐标
        if (playerTransform) {

            var zoneRect:Rectangle = _getCenterZoneRect();

            var Pos2D : CVector3 = CObject.get2DPositionFrom3D( playerTransform.x, playerTransform.z, playerTransform.y );

            if (!m_isEnter && Pos2D.x >= zoneRect.x - zoneRect.width/2  && Pos2D.x <= zoneRect.x + zoneRect.width/2 && Pos2D.y <= zoneRect.y + zoneRect.height/2 && Pos2D.y >= zoneRect.y - zoneRect.height/2) {
                // in zone
                CLevelLog.Log("in zone.");
                m_isEnter = true;
                return true;

            }

            if(m_isEnter && Pos2D.x < zoneRect.x - zoneRect.width / 2 || Pos2D.x > zoneRect.x + zoneRect.width / 2 || Pos2D.y > zoneRect.y + zoneRect.height / 2 || Pos2D.y < zoneRect.y - zoneRect.height / 2)
            {
                m_isEnter = false;
            }
        }
        return false;
    }
    // x,y 为矩形的中心
    private function _getCenterZoneRect() : Rectangle {
        if (!_trigger.triggerData) return null;
        var rect:Rectangle = new Rectangle();
        var zonePos:Point = new Point(_trigger.triggerData.location.x, _trigger.triggerData.location.y);

        rect.width = _trigger.triggerData.size.x;
        rect.height = _trigger.triggerData.size.y;
        rect.x = zonePos.x;
        rect.y = zonePos.y;
        return rect;

    }
}
}
