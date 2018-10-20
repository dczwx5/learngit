//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2016/9/26.
 */
package preview.game.levelServer.trigger.handler {

import QFLib.Framework.CObject;
import QFLib.Math.CVector3;

import flash.geom.Point;
import flash.geom.Rectangle;

import kof.game.core.CGameObject;
import kof.game.core.ITransform;
import kof.game.levelCommon.info.base.CTrunkConditionInfo;
import kof.game.scene.CSceneSystem;

import preview.game.levelServer.trigger.AbsLevelServerTrigger;
import preview.game.levelServer.trigger.AbsLevelTriggerBase;

public class CTriggerCondHandleZoneMove extends CTriggerCondHandleBase {

    private var _enterPointX:int;
    private var _enterPointY:int;

    private var _isEnter:Boolean;

    private var _distance:int;

    public function CTriggerCondHandleZoneMove(trigger:AbsLevelTriggerBase) {
        super(trigger);
    }

    override public virtual function handler(cond:CTrunkConditionInfo,triggerFilter:Array):Boolean {
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

            var Pos2D: CVector3 = CObject.get2DPositionFrom3D( playerTransform.x, playerTransform.z, playerTransform.y );

            if (!_isEnter && Pos2D.x >= zoneRect.x - zoneRect.width/2  && Pos2D.x <= zoneRect.x + zoneRect.width/2 && Pos2D.y <= zoneRect.y + zoneRect.height/2 && Pos2D.y >= zoneRect.y - zoneRect.height/2) {
                _isEnter = true;
                _enterPointX = Pos2D.x;
                _enterPointY = Pos2D.y;
            }

            if(_isEnter && (_enterPointX != int(Pos2D.x) || _enterPointY != int(Pos2D.y)))
            {
//                _distance += Vector2D.dist(new Vector2D(Pos2D.x, Pos2D.y), new Vector2D(_enterPointX,_enterPointY));

                if(_distance >= cond.distance)
                {
                    return true;
                }

                _enterPointX = Pos2D.x;
                _enterPointY = Pos2D.y;
            }

            if(Pos2D.x < zoneRect.x - zoneRect.width / 2 || Pos2D.x > zoneRect.x + zoneRect.width / 2 || Pos2D.y > zoneRect.y + zoneRect.height / 2 || Pos2D.y < zoneRect.y - zoneRect.height / 2)
            {
                _isEnter = false;
                _distance = 0;
                _enterPointX = 0;
                _enterPointY = 0;
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
