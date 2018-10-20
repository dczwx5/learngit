/**
 * Created by auto on 2016/8/8.
 */
package kof.game.scenario.timeline.part {
import QFLib.Framework.CPostEffects;

import kof.framework.CAppSystem;
import kof.game.levelCommon.CLevelLog;
import kof.game.scenario.CScenarioSystem;
import kof.game.scenario.CScenarioViewHandler;
import kof.game.scenario.enum.EScenarioPartType;
import kof.game.scenario.info.CScenarioPartInfo;
import kof.game.scenario.info.CScenarioPartTriggerActionInfo;

public class CScenarioPartDialogPlay extends CScenarioPartBase {
    public function CScenarioPartDialogPlay(partInfo:CScenarioPartInfo, system:CAppSystem) {
        super (partInfo, system);
    }
    public override function dispose() : void {
        _dialog = null;
    }
    public override function start() : void {
        // 调用剧情对话接口
        // 监听事件
        _actionValue = false;
        if (_info.type == EScenarioPartType.DIALOG_PLAY) {
            _dialog = this.getActor() as CScenarioViewHandler;
            if (!_dialog) {
                CLevelLog.addDebugLog("info.id : " + info.id + ", actorID is error...", true);
                _dialog = (_system.getBean(CScenarioViewHandler) as CScenarioViewHandler);
            };
            var dialogID:int = _info.params["id"];
            _isOpiton = false;
            //如果是对话选项
            if(_info.params.hasOwnProperty("isDialogOption")){
                _isOpiton = _info.params["isDialogOption"];
                if(_isOpiton){
                    var optionIdA:int = _info.params["optionIdA"];
                    triggerIdA = _info.params["triggerIdA"];
                    var optionIdB:int = _info.params["optionIdB"];
                    triggerIdB = _info.params["triggerIdB"];
                    var args:Array = [{optionA:optionIdA,triggerA:triggerIdA},{optionB:optionIdB,triggerB:triggerIdB}];
                }
            }

            // var isAutoPlay:Boolean = true;
            _dialog.showScenarioDialog(dialogID, _onDialogFinish, _isOpiton, _isOpiton == true?args:null);
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
    public override function isActionFinish() : Boolean {
        return _actionValue;
    }
    private function _onDialogFinish( actionId:int = 0 ) : void {
        if( info != null ){
            //如果对话已经完成，duration持续时间要设置-1（否则要等会对话持续时间结 shi束）
            info.duration = -1;
            var partType:int = 0;

            var trigger:CScenarioPartTriggerActionInfo = null;
            if(_isOpiton){
                //如果是对话选项
                trace(info.hasTriggerEvent());
                if(!info.hasTriggerEvent()){
                    var triggerObj:Object = new Object();
                    triggerObj.id = actionId;
                    triggerObj.delay = 0;
                    trigger = new CScenarioPartTriggerActionInfo(triggerObj);
                    if(info.triggerAction == null){
                        info.triggerAction = new Array();
                    }
                    info.triggerAction.push(trigger);
                    _removeDialogOption(actionId);

                }else{
                    CLevelLog.addDebugLog("[CScenarioPartDialogPlay] "+(info.id)+" 该动作为选项对话，其触发动作ID有误，请检查json", true);
                }
            }else{
                for each (trigger in info.triggerAction) {
                    partType = _scenarioManager.scenarioInfo.getPartTypeById( trigger.id );
                    if(partType == EScenarioPartType.DIALOG_PLAY){
                        //这里逻辑处理有点坑啊
                        trigger.delay = 0;
                    }
                }
            }
        }
        this._actionValue = true;
    }

    private function _removeDialogOption(triggerId:int):void {
        var partInfo:CScenarioPartInfo = null;
        if(triggerId == triggerIdA){
            //如果选择的是A,移除B
            partInfo = _scenarioManager.scenarioInfo.getPartById(triggerIdB);
        }else{
            //如果选择的是B,移除A
            partInfo = _scenarioManager.scenarioInfo.getPartById(triggerIdA);
        }
        _scenarioManager.removeDialogOption(partInfo);
    }

    private var _dialog:CScenarioViewHandler;
    private var _isOpiton:Boolean = false;

    private var optionIdA:int = 0;
    private var triggerIdA:int = 0;
    private var optionIdB:int = 0;
    private var triggerIdB:int = 0;
}
}
