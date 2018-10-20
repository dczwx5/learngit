/**
 * Created by auto on 2016/9/12.
 */
package preview.game.levelServer.trigger {
import kof.game.levelCommon.Enum.ELevelEventType;
import kof.game.levelCommon.info.base.CTrunkEntityBaseData;
import kof.game.levelCommon.info.trunk.CTrunkConfigInfo;
import preview.game.levelServer.trigger.AbsLevelTriggerBase;
import preview.game.levelServer.CLevelServer;

public class AbsLevelServerTrigger extends AbsLevelTriggerBase {
    public function AbsLevelServerTrigger(server:CLevelServer, trunkInfo:CTrunkConfigInfo, trunkEntityInfo:CTrunkEntityBaseData, handleConditionRate:int) {
        _server = server;
        super(trunkInfo, trunkEntityInfo, handleConditionRate);
    }

    public override function dispose() : void {
        super.dispose();
        _server = null;
    }

    // =================================================================================
    protected override function _onStartTrigger() : void {
        // override , 每次触发器开始一次条件处理时调用
    }
    // override, 只有一开始激活时，或reset会调用
    protected override  function _onActive() : void {
        _processStateEvent(ELevelEventType.EVENT_ACTIVE);
    }
    // override to handler other envent
    protected override function _onTrigger() : void {
        _processStateEvent(ELevelEventType.TRIGGER_EVENT_TRIGGER);
    }
    // override
    protected override  function _onCompleted() : void {
        _processStateEvent(ELevelEventType.TRIGGER_EVENT_COMPLETED);
    }
    private function _processStateEvent(eventType:String) : void {
        var processEvent:Array = _trunkEntityInfo[eventType];
        if (processEvent != null && processEvent.length > 0) {
            _server.serverEnventManager.handlerEvent(_trunkInfo.ID, processEvent);
        }
    }

    // ======================================================================================
    final public function get server() : CLevelServer {
        return this._server;
    }

    // ======================================================================================
    protected var _server:CLevelServer;
}
}
