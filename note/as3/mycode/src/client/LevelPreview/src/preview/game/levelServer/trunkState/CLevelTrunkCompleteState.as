/**
 * Created by auto on 2016/5/30.
 */
package preview.game.levelServer.trunkState {

import flash.geom.Point;
import flash.geom.Rectangle;

import preview.game.levelServer.CLevelServer;
import preview.game.levelServer.CLevelServerTrunkData;

public class CLevelTrunkCompleteState extends CLevelTrunkState {
    public function CLevelTrunkCompleteState(server:CLevelServer) {
        super(_COMPLETE, server);
    }
    protected override function inState() : void {
        super.inState();
        // complete阶段, 不管isChildrenFinish的值, 因为第一阶段与第二阶段一共只会执行一次complete
        _server.sender.sendCleanTrunk(_server.curTrunkData.trunkInfo.ID);
        _server.serverEnventManager.handlerTrunkEvent(_server.curTrunkData.trunkInfo, this._state);
    }
    public override function checkNextState():CLevelTrunkState {
        // if (_server.isPlayingScenario) return this ; // 如果正在播放剧情, 则不能完成trunk

        if (_server.isPlayingScenario) {
            return this;
        }

        // pass过了.而且能到这里, 肯定是完成了, 不管是从pass到这里，还是从子trunk回到这里的, 都算complete了
        var lastTrunkData:CLevelServerTrunkData = _server.curTrunkData;
        _server.nextTrunk();
        if (_server.curTrunkData == null) {
            if(lastTrunkData.trunkInfo.passEvents && lastTrunkData.trunkInfo.passEvents.length){
                return null;
            }else{
                return new CLevelTrunkPortalState(_server);
            }

        } else {
            // 解trunk
            var curTrunkData:CLevelServerTrunkData = _server.curTrunkData;
            if (curTrunkData && lastTrunkData) {
                var lastRect:Rectangle = lastTrunkData.trunkInfo.getTrunkRect();
                var curRect:Rectangle = curTrunkData.trunkInfo.getTrunkRect();
                var topPoint:Point = new Point(lastRect.x, lastRect.y);
                var bottomPoint:Point = new Point(curRect.x + curRect.width, curRect.y + curRect.height);

                _server.sender.lockTrunks(topPoint, bottomPoint);
            }
            return new CLevelTrunkActiveState(_server);
        }
    }
}
}
