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

import kof.ui.master.BattleTutor.BTPromptUI;
import kof.util.CAssertUtils;

import morn.core.handlers.Handler;

import view.CKeyPressViewHandler;
import view.CViewRenderUtil;

public class CKeyPressPackage extends CActionPackageBase {
    public function CKeyPressPackage() {

    }

    public override function buildAction() : CActionBase {
        CAssertUtils.assertNotNull(contentList);
        CAssertUtils.assertNotNull(keyList);

        var battleTutor:CBattleTutor = tutorBase.battleTutor;
        var keyPressAct:CActionCommon = new CActionCommon();
        var _onViewUpdate:Function = function () : Boolean {
            var ui:BTPromptUI = battleTutor.viewHelper.keyPress.ui;
            if (ui) {
                ui.desc0.text = content1;
                ui.desc1.text = content2;
                ui.desc2.text = content3;
                if (key1 != EKeyCode.SPACE) {
                    ui.key.index = EKeyCode.getIndexByKey(key1);
                    ui.space.visible = false;
                    ui.key.visible = true;
                } else {
                    ui.space.visible = true;
                    ui.key.visible = false;
                }
                CViewRenderUtil.renderSkillItem(battleTutor.system, key1, battleTutor.actorHelper.getSkillIDByKey(key1), ui.skill);
            }
            return true;
        };

        keyPressAct.addStartHandler(new Handler(battleTutor.viewHelper.showView, [CKeyPressViewHandler]));
        keyPressAct.addPassHandler(new Handler(battleTutor.condHelper.isViewShowed, [CKeyPressViewHandler]));
        keyPressAct.addPassHandler(new Handler(_onViewUpdate));
        keyPressAct.addPassHandler(new Handler(battleTutor.actionHelper.resetStartTime, [keyPressAct]));
        keyPressAct.addPassHandler(new Handler(battleTutor.condHelper.isPassTime, [keyPressAct, 500]));

        return keyPressAct;
    }
}
}
