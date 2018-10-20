//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/28.
 */
package tutor.actionPackage {

import action.CActionBase;
import action.CActionCommon;
import action.EKeyCode;

import kof.ui.master.BattleTutor.BTKeyDescUI;
import kof.util.CAssertUtils;

import morn.core.handlers.Handler;

import view.CKeyDescViewHandler;

public class CKeyDescPackage extends CActionPackageBase {
    public function CKeyDescPackage() {

    }

    public override function buildAction() : CActionBase {
        CAssertUtils.assertNotNull(contentList);
        CAssertUtils.assertNotNull(keyList);

        var battleTutor:CBattleTutor = tutorBase.battleTutor;
        var showKeyDescAction:CActionCommon = new CActionCommon();
        var setUI:Function = function() : Boolean {
            var ui:BTKeyDescUI = battleTutor.viewHelper.keyDesc.ui;
            if (ui) {
                ui.desc.text = content1;
                if (key1 != EKeyCode.SPACE) {
                    ui.key.index = EKeyCode.getIndexByKey(key1);
                    ui.space.visible = false;
                    ui.key.visible = true;
                } else {
                    ui.space.visible = true;
                    ui.key.visible = false;
                }
            }
            return true;
        };

        showKeyDescAction.addStartHandler(new Handler(battleTutor.viewHelper.showView, [CKeyDescViewHandler]));
        showKeyDescAction.addPassHandler(new Handler(battleTutor.condHelper.isViewShowed, [CKeyDescViewHandler]));
        showKeyDescAction.addPassHandler(new Handler(battleTutor.actionHelper.resetStartTime, [showKeyDescAction]));
        showKeyDescAction.addPassHandler(new Handler(setUI));
        showKeyDescAction.addPassHandler(new Handler(battleTutor.condHelper.isPassTime, [showKeyDescAction, 3000]));
        showKeyDescAction.addFinishHandler(new Handler(battleTutor.viewHelper.hideView, [CKeyDescViewHandler]));

        return showKeyDescAction;
    }
}
}
