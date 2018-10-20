/**
 * Created by auto on 2016/5/30.
 */
package preview.game.levelServer.trunkState {
import QFLib.Framework.CObject;
import QFLib.Math.CVector3;

import flash.geom.Point;
import flash.geom.Rectangle;

import kof.game.character.handler.CPlayHandler;
import kof.game.core.CECSLoop;
import kof.game.core.CTransform;
import kof.game.core.ITransform;
import kof.game.level.CLevelManager;
import kof.game.level.CLevelSystem;

import preview.game.levelServer.CLevelServer;

public class CLevelTrunkActiveState extends CLevelTrunkState {
    public function CLevelTrunkActiveState(server:CLevelServer) {
        super(_ACTIVE, server);
    }

    protected override function inState():void {
        super.inState();
        if (_server.curTrunkData.isChildrenFinish) {
            // 子trunk回到父trunk阶段, 这个阶段不处理初始化
        } else {
            // 处理activeEvents, 在第一个trunk会激活触发器
            _server.sender.sendActiveTrunk(_server.curTrunkData.trunkInfo.ID);
            _server.serverEnventManager.handlerTrunkEvent(_server.curTrunkData.trunkInfo, this._state);
        }

    }

    public override function checkNextState():CLevelTrunkState {
        if (_server.curTrunkData.isChildrenFinish) {
            // 子trunk回到父trunk阶段, 这个阶段不作其他处理, 直接进入下个阶段
            return new CLevelTrunkEnterState(_server);
        } else {
            // 处理enter
            // 需要人物坐标
            var plaHandler:CPlayHandler = (_server.system.stage.getSystem(CECSLoop).getBean(CPlayHandler) as CPlayHandler);
            if (plaHandler && plaHandler.hero && plaHandler.hero.isRunning) {
                var playerTransform:ITransform = plaHandler.hero.transform;
                var zoneRect:Rectangle = (_server.system.stage.getSystem(CLevelSystem).getBean(CLevelManager) as CLevelManager).gameLevel.getTrunkAreaData(_server.curTrunkData.trunkInfo.ID);
                var Pos2D : CVector3 = CObject.get2DPositionFrom3D( playerTransform.x, playerTransform.z, playerTransform.y );

                if (Pos2D.x >= zoneRect.x && Pos2D.x <= zoneRect.x + zoneRect.width  && Pos2D.y >= zoneRect.y && Pos2D.y <= zoneRect.y + zoneRect.height) {
                    // in zone
                    return new CLevelTrunkEnterState(_server); // 选简单的跳过enter事件
                }
            }
            return this;
        }
    }
}
}
