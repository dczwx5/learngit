/**
 * Created by auto on 2016/5/30.
 */
package preview.game.levelServer.trunkState {

import kof.game.levelCommon.info.entity.CTrunkEntityTriggerPortal;

import preview.game.levelServer.CLevelServer;
import preview.game.levelServer.trigger.CTriggerPortal;

public class CLevelTrunkPortalState extends CLevelTrunkState {
    public function CLevelTrunkPortalState(server:CLevelServer) {
        super(_PORTAL, server);
    }
    public override function dispose() : void {
        super.dispose();
        _triggers = null;
    }
    protected override function inState() : void {
        super.inState();

        _server.sender.sendInstanceOver();
        // 只有所有trunk事件都完成了。关卡通关 了。才会进入这里
        if (_server.levelInfo.portal && _server.levelInfo.portal.length > 0) {
            _triggers = new Vector.<CTriggerPortal>(_server.levelInfo.portal.length);
            for (var i:int = 0; i < _triggers.length; i++) {
                _triggers[i] = new CTriggerPortal(_server, _server.levelInfo.portal[i] as CTrunkEntityTriggerPortal);
            }
            _server.sender.activePortal();
        }
    }
    public override function checkNextState():CLevelTrunkState {
        if (_triggers && _triggers.length) {
            for (var i:int = 0; i < _triggers.length; i++) {
                _triggers[i].update(0.1);
                if (_triggers[i].isEnd()) {
                    // 随便走进一个传送门就算完了
                    _triggers = null;
                    return new CLevelTrunkOverState(_server);
                }

            }
            return this;
        } else {
            return new CLevelTrunkOverState(_server);
            _triggers = null;
        }
    }

    public function get triggers() : Vector.<CTriggerPortal> {
        return _triggers;
    }
    private var _triggers:Vector.<CTriggerPortal>;
}
}
