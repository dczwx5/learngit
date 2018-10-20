/**
 * Created by auto on 2016/5/30.
 */
package preview.game.levelServer.trunkState {

import kof.game.levelCommon.Enum.ELevelEventType;
import preview.game.levelServer.CLevelServer;
import preview.game.levelServer.event.map.CTrunkMonsterDeadEvent;


public class CLevelTrunkEnterState extends CLevelTrunkState {
    public function CLevelTrunkEnterState(server:CLevelServer) {
        super(_ENTER, server);
    }
    protected override function inState() : void {
        super.inState();
        if (_server.curTrunkData.isChildrenFinish) {
            // 子trunk回到父trunk阶段, 这个阶段不处理初始化
        } else {
            _server.sender.sendEnterTrunk(_server.curTrunkData.trunkInfo.ID);
            _server.serverEnventManager.handlerTrunkEvent(_server.curTrunkData.trunkInfo, this._state);
        }
    }

    public override function checkNextState():CLevelTrunkState {
        if (_server.curTrunkData.isChildrenFinish) {
            // 子trunk回到父trunk阶段, 这个阶段不作其他处理, 直接进入下个阶段
            return new CLevelTrunkPassState(_server);
        } else {
            // 处理enter
            // return null;
            if (_server.checkPass()) {
                return new CLevelTrunkPassState(_server);
            }
            return this; // 要判断是否pass了
        }

    }
}
}
