/**
 * Created by user on 2016/12/3.
 */
package kof.game.scenario.timeline.part {

import kof.framework.CAppSystem;
import kof.game.core.CGameObject;
import kof.game.core.CGameObject;
import kof.game.levelCommon.CLevelLog;
import kof.game.scenario.CScenarioViewHandler;
import kof.game.scenario.enum.EScenarioPartType;
import kof.game.scenario.info.CScenarioPartInfo;
/*冒泡对话*/
public class CScenarioPartDialogBubbles extends CScenarioPartBase {
    private var _dialog:CScenarioViewHandler;

    public function CScenarioPartDialogBubbles( partInfo : CScenarioPartInfo, system : CAppSystem ) {
        super( partInfo, system );
    }
    public override function dispose() : void {
        _dialog = null;
    }
    public override function start() : void {
        // 调用剧情对话接口
        // 监听事件
        _actionValue = false;
        if (_info.type == EScenarioPartType.DIALOG_BUBBLES) {
            _dialog = this.getActor() as CScenarioViewHandler;
            if (!_dialog) {
                CLevelLog.addDebugLog("info.id : " + info.id + ", actorID is error...", true);
                _dialog = (_system.getBean(CScenarioViewHandler) as CScenarioViewHandler);
            };
            var dialogID:int = _info.params["id"];
            // var isAutoPlay:Boolean = true;
            var actor:CGameObject = _scenarioManager.actorManager.getActor( _info.params["target"]) as CGameObject;
            _dialog.showDialogBubbles(actor,dialogID,_info.params["x"],_info.params["y"], _info.params["direction"],_onDialogFinish);
        } else {
            _actionValue = true;
        }

    }
    public override function end() : void {
        // 去掉监听事件
        _actionValue = false;
    }

    public override function stop() : void {
        super.stop();
        if (_dialog) {
            _dialog.hideScenarioDialog();
        }
    }

    public override function update(delta:Number) : void {
        super.update(delta);
    }
    private function _onDialogFinish( actionId:int = 0 ) : void {
        this._actionValue = true;
    }
    public override function isActionFinish() : Boolean {
        return _actionValue;
    }
}
}
