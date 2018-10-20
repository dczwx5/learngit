//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/5/5.
 */
package kof.game.Tutorial {

import QFLib.Interface.IUpdatable;
import kof.framework.CAbstractHandler;
import kof.framework.IDatabase;
import kof.game.Tutorial.data.CTutorGroupInfo;
import kof.game.Tutorial.enum.ETutorWndType;
import kof.game.Tutorial.tutorPlay.CTutorPlay;
import kof.game.Tutorial.data.CTutorData;
import kof.game.Tutorial.event.CTutorEvent;
import kof.game.Tutorial.view.CTutorArrowView;
import kof.game.Tutorial.view.CTutorDialogView;
import kof.game.Tutorial.view.CTutorView;
import kof.game.common.view.CViewBase;
import kof.game.instance.CInstanceSystem;
import kof.ui.IUICanvas;

import morn.core.handlers.Handler;

public class CTutorManager extends CAbstractHandler implements IUpdatable {
    public function CTutorManager() {

    }

    // ===================initial====================
    public override function dispose():void {
        super.dispose();

        clear();

        _tutorPlay.dispose();
    }

    public function clear() : void {
        _tutorPlay.clear();
    }

    override protected function onSetup():Boolean {
        var ret:Boolean =  super.onSetup();
        _tutorData = new CTutorData(system.stage.getSystem(IDatabase) as IDatabase);
        _tutorPlay = new CTutorPlay(this);

        return ret;
    }

    public function update(delta : Number) : void {
        if (_tutorPlay && _tutorPlay.isStart) {
            var pInstanceSystem:CInstanceSystem = system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
            var isInMainCity:Boolean = false;
            if (pInstanceSystem) {
                isInMainCity = pInstanceSystem.isMainCity;
            }
            if (isInMainCity) {
                _tutorPlay.update(delta);
                if (_tutorPlay.isFinish) {
                    _tutorPlay.dispose();
                    _system.sendEvent(new CTutorEvent(CTutorEvent.TUTOR_END, null));
                }
            }
        }
    }
    public function hideTutorView() : void {
        if (_tutorPlay && _tutorPlay.isStart) {
            _tutorPlay.hideView();
        }
    }
    // ===================operator====================
    private var _isLoadingTutorView:Boolean = false;
    public function startTutor(groupID:int) : void {
        if (_isLoadingTutorView) return ; // 拒绝GM指令这种情况进入

        _system.addSequential(new Handler(_loadTutorViewB, null), _hasLoadTutorView);
        _system.addSequential(new Handler(_startB, [groupID]), null);
    }
    private function _loadTutorViewB() : Boolean {
        if (_hasLoadTutorView() == false) {
            // 确保tutorPlay里面UI资源已经加载
            _isLoadingTutorView = true;
            _system.uiHandler.showDialogTutor(null);
            _system.uiHandler.showTutor();
            _system.uiHandler.showTutorArrow();
            hideTutorView();
        }
        return true;
    }
    private function _hasLoadTutorView() : Boolean {
        var view:CViewBase = _system.uiHandler.getWindow(ETutorWndType.WND_TUTOR);
        if (!view || view.isLoadResourceFinish == false) {
            return false;
        }
        view = _system.uiHandler.getWindow(ETutorWndType.WND_DIALOG_TUTOR);
        if (!view || view.isLoadResourceFinish == false) {
            return false;
        }
        view = _system.uiHandler.getWindow(ETutorWndType.WND_TUTOR_ARROW);
        if (!view || view.isLoadResourceFinish == false) {
            return false;
        }
        return true;
    }
    private function _startB(groupID:int) : Boolean {
        _isLoadingTutorView = false;

        // 初始隐藏, 调用hideTutorView有问题, 内部的对象还没初始化
        var view:CViewBase = _system.uiHandler.getWindow(ETutorWndType.WND_TUTOR);
        (view as CTutorView).visible = false;
        view = _system.uiHandler.getWindow(ETutorWndType.WND_DIALOG_TUTOR);
        (view as CTutorDialogView).visible = false;
        view = _system.uiHandler.getWindow(ETutorWndType.WND_TUTOR_ARROW);
        (view as CTutorArrowView).visible = false;


        clear();
        _system.sendEvent(new CTutorEvent(CTutorEvent.TUTOR_PREPARE, null, groupID));

        _tutorPlay.start(groupID);

        _system.sendEvent(new CTutorEvent(CTutorEvent.TUTOR_STARTED, null, groupID));
        return true;
    }

    public function stopTutor() : void {
        if ( _tutorPlay ) {
            _tutorPlay.stop();
        }
    }

    public function get isPlaying() : Boolean {
        return _tutorPlay && _tutorPlay.isPlaying;
    }
    public function saveGroupActionToServer(vGroupInfo:CTutorGroupInfo) : void {
        if (_tutorPlay) {
            _tutorPlay.saveGroupActionToServer(vGroupInfo);
        }
    }
    // ===================get/set====================
    [Inline]
    private function get _uiSystem() : IUICanvas {
        return system.stage.getSystem(IUICanvas) as IUICanvas;
    }

    [Inline]
    public function get tutorData() : CTutorData {
        return _tutorData;
    }

    [Inline]
    private function get _system() : CTutorSystem {
        return system as CTutorSystem;
    }

    private var _tutorData:CTutorData;
    private var _tutorPlay:CTutorPlay;
    public function get tutorPlay():CTutorPlay {
        return _tutorPlay;
    }
}
}
