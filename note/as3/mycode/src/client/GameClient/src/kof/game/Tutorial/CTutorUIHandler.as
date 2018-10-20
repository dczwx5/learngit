//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/5/5.
 */
package kof.game.Tutorial {

import kof.game.Tutorial.control.CTutorControler;
import kof.game.Tutorial.data.CTutorActionInfo;
import kof.game.Tutorial.data.CTutorData;
import kof.game.Tutorial.enum.ETutorDataEventType;
import kof.game.Tutorial.enum.ETutorWndType;
import kof.game.Tutorial.event.CTutorEvent;
import kof.game.Tutorial.view.CTutorArrowView;
import kof.game.Tutorial.view.CTutorDialogView;
import kof.game.Tutorial.view.CTutorView;
import kof.game.common.view.CViewBase;
import kof.game.common.view.CViewManagerHandler;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;


public class CTutorUIHandler extends CViewManagerHandler {

    public function CTutorUIHandler() {
        isNotHideByAuto = true;
    }

    public override function dispose() : void {
        super.dispose();
        _tutorSystem.unListenEvent(_onTutorDataEvent);
    }

    override public virtual function onEvtEnable() : void {
        super.onEvtEnable();
    }

    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        this.addViewClassHandler(ETutorWndType.WND_TUTOR, CTutorView, CTutorControler);
        this.addViewClassHandler(ETutorWndType.WND_DIALOG_TUTOR, CTutorDialogView);
        this.addViewClassHandler(ETutorWndType.WND_TUTOR_ARROW, CTutorArrowView);

        _tutorSystem.listenEvent(_onTutorDataEvent); // 由于在没有打开界面的时候。也需要处理事件，(levelUpView, 所以不能放到onEvtEnable处理)
        return ret;
    }

    // ================================== event ==================================
    private function _onTutorDataEvent(e:CTutorEvent) : void {
        if (CTutorEvent.DATA_EVENT != e.type) return ;

        var win:CViewBase;
        var subEvent:String = e.subEvent;
        var tutorData:CTutorData = _tutorData;
        var playerData:CPlayerData = _playerData;

        switch (subEvent) {
            case ETutorDataEventType.DATA :
                break;
        }
    }

    // =================================================================================
    public function showTutor(callback:Function = null) : void {
        show(ETutorWndType.WND_TUTOR, null, callback, [_tutorData, _playerData]);
    }
    public function hideTutor() : void {
        hide(ETutorWndType.WND_TUTOR);
    }
    public function showDialogTutor(actionInfo:CTutorActionInfo) : void {
        show(ETutorWndType.WND_DIALOG_TUTOR, [actionInfo], null, [_tutorData, _playerData]);
    }
    public function hideDialogTutor() : void {
        hide(ETutorWndType.WND_DIALOG_TUTOR);
    }
    public function showTutorArrow(callback:Function = null) : void {
        show(ETutorWndType.WND_TUTOR_ARROW, null, callback, [_tutorData, _playerData]);
    }
    public function hideTutorArrow() : void {
        hide(ETutorWndType.WND_TUTOR_ARROW);
    }
    // ================================== common data ==================================
    [Inline]
    private function get _tutorSystem() : CTutorSystem {
        return system as CTutorSystem;
    }
    [Inline]
    private function get _playerData() : CPlayerData {
        return (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
    }
    [Inline]
    private function get _tutorData() : CTutorData {
        return _tutorSystem.tutorData;
    }
}
}
