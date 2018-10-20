/**
 * Created by auto on 2016/5/30.
 */
package preview.game.levelServer.trunkState {
import preview.game.levelServer.CLevelServer;

public class CLevelTrunkPassState extends CLevelTrunkState  {
    public function CLevelTrunkPassState(server:CLevelServer) {
        super(_PASS, server);
    }
    protected override function inState() : void {
        super.inState();
        if (_server.curTrunkData.isChildrenFinish) {
            // 子trunk回到父trunk阶段, 这个阶段不处理初始化
        } else {
            _server.serverEnventManager.handlerTrunkEvent(_server.curTrunkData.trunkInfo, this._state);
        }
    }
    public override function checkNextState():CLevelTrunkState {
        if (_server.serverEnventManager.hasDelayCall) {
            // 等待delay call 的事件处理完， 再进入完成
            return this;
        }
        if (_server.curTrunkData.isChildrenFinish || _server.curTrunkData.nextTrunk == null) {
            // 子trunk回到父trunk阶段, 这个阶段不作其他处理, 直接进入下个阶段
            return new CLevelTrunkCompleteState(_server);
        } else {
            // 检测pass
            if (!_server.curTrunkData.isChildren && !_server.curTrunkData.nextTrunk.isChildren) {
                // 没有子trunk的节点, 按正常来走
                return new CLevelTrunkCompleteState(_server);
            } else {
                // 父->子, 子->子, 子->父, 直接从pass转去下一个的active
                _server.nextTrunk();
                return new CLevelTrunkActiveState(_server); // 如果 有子trunk或者子trunk还有下一个trunk, 则passEvent会激活下一个trunk
            }

        }


        return new CLevelTrunkCompleteState(_server); // 如果 没子trunk, 则complete
    }
}
}
