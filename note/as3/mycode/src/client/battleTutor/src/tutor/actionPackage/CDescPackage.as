//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/7/3.
 */
package tutor.actionPackage {

import action.CActionBase;
import action.CActionCommon;
import kof.ui.master.BattleTutor.BTDescUI;
import kof.util.CAssertUtils;
import morn.core.handlers.Handler;

import view.CDescViewHandler;

public class CDescPackage extends CActionPackageBase {
    public function CDescPackage() {

    }

    public override function buildAction() : CActionBase {

        var battleTutor:CBattleTutor = tutorBase.battleTutor;
        var descAction:CActionCommon = new CActionCommon();
        var setUI:Function = function() : Boolean {
            var ui:BTDescUI = battleTutor.viewHelper.descView.ui;
            if (ui) {
                ui.visible = true;

                ui.desc1.visible = false;
                ui.desc2.visible = false;
                ui.desc3.visible = false;
                ui.desc4.visible = false;
                if (1 == _descIndex) {
                    ui.desc1.visible = true;
                } else if (2 == _descIndex) {
                    ui.desc2.visible = true;
                } else if (3 == _descIndex) {
                    ui.desc3.visible = true;
                } else if (4 == _descIndex) {
                    ui.desc4.visible = true;
                }
            }
            return true;
        };

        var setDetailUnVisible:Function = function () : Boolean {
            battleTutor.viewHelper.descView.ui.visible = false;
            return true;
        };
        var setUpdatehandler:Function = function () : Boolean {
            battleTutor.viewHelper.descView.updateHandler = new Handler(setDetailUnVisible);
            return true;
        };
        var setUpdateHandlerNone:Function = function () : Boolean {
            battleTutor.viewHelper.descView.updateHandler = null;
            return true;
        };
        descAction.addStartHandler(new Handler(setUpdatehandler));

        descAction.addStartHandler(new Handler(battleTutor.viewHelper.showView, [CDescViewHandler]));
        descAction.addPassHandler(new Handler(battleTutor.condHelper.isViewShowed, [CDescViewHandler]));
        descAction.addPassHandler(new Handler(battleTutor.instanceHelper.uploadData, [_uploadGuideStep1]));
        descAction.addPassHandler(new Handler(battleTutor.actionHelper.resetStartTime, [descAction]));
        descAction.addPassHandler(new Handler(setUI));
        descAction.addPassHandler(new Handler(battleTutor.instanceHelper.playAudio, [_audioID]));

        descAction.addPassHandler(new Handler(battleTutor.condHelper.isPassTime, [descAction, 1000]));
        descAction.addFinishHandler(new Handler(battleTutor.viewHelper.hideView, [CDescViewHandler]));
        descAction.addFinishHandler(new Handler(setUpdateHandlerNone));

        return descAction;
    }
}
}
