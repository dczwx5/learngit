//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/8/16.
 */
package kof.game.Tutorial.tutorPlay.action {

import kof.framework.CAppSystem;
import kof.game.KOFSysTags;
import kof.game.Tutorial.data.CTutorActionInfo;
import kof.game.Tutorial.tutorPlay.CTutorUtil;
import kof.game.common.view.CViewBase;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.mainInstance.data.CChapterInstanceData;
import kof.game.instance.mainInstance.enum.EInstanceWndType;
import kof.game.instance.event.CInstanceEvent;
import kof.game.instance.mainInstance.view.instanceScenario.CInstanceScenarioView;
import kof.message.Instance.EnterInstanceResponse;

import morn.core.components.Component;

// 指向副本头像, 和指向二级界面
public class CTutorActionInstanceFightClick extends CTutorActionGuideClick {

    public function CTutorActionInstanceFightClick(actionInfo : CTutorActionInfo, system : CAppSystem ) {
        super( actionInfo, system );
    }

    public override function dispose() : void {
        var pInstanceSystem:CInstanceSystem = _system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if (pInstanceSystem) {
            pInstanceSystem.removeEventListener(CInstanceEvent.ENTER_INSTANCE, _onEnterInstance);
        }

        super.dispose();

        _pInstanceData = null;
        _pHoleTargetSave = null;

    }

    private var _isElite:Boolean = false;
    public override function start() : void { // 开始
        super.start();

        var type:String = _info.actionParams[0] as String;
        if (type == "1") {
            _isElite = true;
        }

        var pInstanceSystem:CInstanceSystem = _system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
        var instanceID:int = (int)(_info.actionParams[2]);
        if (pInstanceSystem && instanceID > 0) {
            var pInstanceData:CChapterInstanceData = pInstanceSystem.getInstanceByID(instanceID);
            _pInstanceData = pInstanceData;
            pInstanceSystem.addEventListener(CInstanceEvent.ENTER_INSTANCE, _onEnterInstance);
        }

        // _pInstanceData.chapterID
    }

    private function _onEnterInstance(e:CInstanceEvent) : void {
        var pInstanceSystem:CInstanceSystem = _system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if (pInstanceSystem) {
            pInstanceSystem.removeEventListener(CInstanceEvent.ENTER_INSTANCE, _onEnterInstance);
        }
        var response:EnterInstanceResponse = e.data as EnterInstanceResponse;
        if (response) {
            // 进入副本之后不会处理逻辑, 在点击进入副本之后需要强制执行一次update, 进入下一步引导
            var targetInstanceID:int = (int)(_info.actionParams[2]);
            if (response.instanceID == targetInstanceID) {
                _isPassInstance = true;
                _actionValue = true;
                _tutorPlay.update(0.3);
            }
        }
    }

    private function get _systemTag() : String {
        return _isElite ? KOFSysTags.ELITE : KOFSysTags.INSTANCE;
    }
    private function get _detailType() : int {
        return _isElite ? EInstanceWndType.WND_INSTANCE_ELITE_DETAIL : EInstanceWndType.WND_INSTANCE_SCENARIO_DETAIL;
    }
    private function get _detailOkTag() : String {
        return _isElite ? "INSTANCE_ELITE_DETAIL_FIGHT" : "INSTANCE_DETAIL_FIGHT";
    }
    private function get _wndType() : int {
        return _isElite ? EInstanceWndType.WND_INSTANCE_ELITE : EInstanceWndType.WND_INSTANCE_SCENARIO;
    }

    public override function update(delta:Number) : void { // 更新
        super.update(delta);

        if (_isPassInstance) return ;
        var pInstanceSystem:CInstanceSystem = _system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if (pInstanceSystem) {
            if (pInstanceSystem.currentIsPrelude == false &&pInstanceSystem.isMainCity == false) {
                _isInFB = true;
            }
        }

        if (!_hasProcessDetailView) {
            var detailView:CViewBase = pInstanceSystem.uiHandler.getWindow(_detailType);
            if (detailView && detailView.isShowState) {
                _hasProcessDetailView = true;
                _setHoleToDetailView();
            }
        }


        if (_pInstanceData) {
            var view:CInstanceScenarioView = pInstanceSystem.uiHandler.getWindow(_wndType) as CInstanceScenarioView;
            if (view && view.curChapterData) {
                if (view.curChapterData.chapterID != _pInstanceData.chapterID) {
                    if (holeTarget) {
                        _pHoleTargetSave = holeTarget;
                        holeTarget = null;
                    }
                } else {
                    if (_pHoleTargetSave) {
                        holeTarget = _pHoleTargetSave;
                    }
                }
            }
        }

        if (_pInstanceData.isCompleted) {
            // 如果完成. 就不再引导该步
            _isPassInstance = true;
            _actionValue = true;
        }

    }

    // 如果不小心打开了二级界面
    private var _hasProcessDetailView:Boolean = false;
    private function _setHoleToDetailView() : void {
        CTutorUtil.GetComponent(_system, _detailOkTag, _startByDefault)
    }
    private function _startByDefault(comp:Component) : void {
        this.holeTarget = comp;
    }

    public override function get needRollback() : Boolean {
        return false; // 这步rollback会死循环, 因为不是点击了就通过

        var bRollback:Boolean = super.needRollback;
        return bRollback;
    }
    override protected function get otherCondition() : Boolean {
        return _isPassInstance || _isInFB; // 进了副本或副本已通关, 则通过
    }

    private var _isInFB:Boolean = false;// fb == 副本
    private var _isPassInstance:Boolean = false;
    private var _pInstanceData:CChapterInstanceData;
    private var _pHoleTargetSave:Component;
}
}

// vim:ft=as3 tw=120 ts=4 sw=4 expandtab
