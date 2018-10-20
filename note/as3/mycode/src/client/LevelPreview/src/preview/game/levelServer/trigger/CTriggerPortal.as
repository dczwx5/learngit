/**
 * Created by auto on 2016/5/24.
 * 用于服务器 刷怪区域
 */
package preview.game.levelServer.trigger {

import QFLib.Framework.CObject;
import QFLib.Interface.IDisposable;
import QFLib.Interface.IUpdatable;
import QFLib.Math.CVector3;

import avmplus.getQualifiedClassName;

import flash.geom.Point;
import flash.geom.Rectangle;


import kof.game.character.handler.CPlayHandler;
import kof.game.core.CECSLoop;
import kof.game.core.ITransform;
import kof.game.levelCommon.Interface.ITriggerIsEnd;
import kof.game.levelCommon.info.entity.CTrunkEntityTriggerPortal;
import kof.game.levelCommon.CLevelLog;

import preview.game.levelServer.CLevelServer;

// not trigger
public class CTriggerPortal implements IDisposable, IUpdatable, ITriggerIsEnd {
    private var _server:CLevelServer;
    private var _portalInfo:CTrunkEntityTriggerPortal;
    public function CTriggerPortal(server:CLevelServer, trunkEntity:CTrunkEntityTriggerPortal) {
        _portalInfo = trunkEntity;
        _server = server;
    }
    public function dispose() : void {
        super.dispose();
    }
    public function isEnd() : Boolean { return _isEnd; }

    public function update(delta:Number) : void {
        if (this._test()) {
            _isEnd = true;
        }
    }

    private function _test() : Boolean {
        // 需要人物坐标
        var gameSystem:CECSLoop =  _server.system.stage.getSystem(CECSLoop) as CECSLoop;
        var playHandler:CPlayHandler = (gameSystem.getBean(CPlayHandler) as CPlayHandler)
        if (playHandler && playHandler.hero) {
            var playerTransform:ITransform = playHandler.hero.transform;

            var zoneRect:Rectangle = getLTZoneRect();
            var Pos2D : CVector3 = CObject.get2DPositionFrom3D( playerTransform.x, playerTransform.z, playerTransform.y );

            if (Pos2D.x >= zoneRect.x && Pos2D.x <= zoneRect.x + zoneRect.width  && Pos2D.y >= zoneRect.y && Pos2D.y <= zoneRect.y + zoneRect.height) {
                // in zone
                CLevelLog.Log(getQualifiedClassName(this) + " : in zone.");
                return true;

            }
        }


        return false;
    }

    // x,y 为矩形的中心
    private function _getCenterZoneRect() : Rectangle {
        if (!_portalInfo) return null;
        var rect:Rectangle = new Rectangle();
        var zonePos:Point = new Point(_portalInfo.location.x, _portalInfo.location.y);// CSceneGridHandler.grid2Pixel(_portalInfo.position.x, _portalInfo.position.y);

        rect.width = _portalInfo.size.x;
        rect.height = _portalInfo.size.y;

        rect.x = zonePos.x;
        rect.y = zonePos.y;

        return rect;

    }
    // x, y为矩形的左上角
    public function getLTZoneRect() : Rectangle {
        if (!_portalInfo) return null;
        var rect:Rectangle = new Rectangle();
        var zonePos:Point = new Point(_portalInfo.location.x, _portalInfo.location.y);// CSceneGridHandler.grid2Pixel(_trunkEntityInfo.position.x, _trunkEntityInfo.position.y);

        rect.width = _portalInfo.size.x;
        rect.height = _portalInfo.size.y;

        rect.x = zonePos.x - rect.width/2;
        rect.y = zonePos.y-rect.height/2; // + yFixed;
        return rect;

    }

    private var _isEnd:Boolean = false;
}
}
