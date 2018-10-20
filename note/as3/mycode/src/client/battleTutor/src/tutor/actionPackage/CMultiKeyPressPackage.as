//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/27.
 */
package tutor.actionPackage {

import action.CActionBase;
import action.CActionCommon;
import action.EKeyCode;

import kof.ui.master.BattleTutor.BTMultiKeyPressUI;

import kof.ui.master.BattleTutor.BTPromptUI;
import kof.ui.master.BattleTutor.BTSkillItemUI;
import kof.util.CAssertUtils;

import morn.core.components.Clip;

import morn.core.handlers.Handler;

import view.CMultiKeyPressViewHandler;

import view.CViewRenderUtil;

public class CMultiKeyPressPackage extends CActionPackageBase {
    public function CMultiKeyPressPackage() {

    }

    public override function buildAction() : CActionBase {
        CAssertUtils.assertNotNull(contentList);
        CAssertUtils.assertNotNull(keyList);

        var battleTutor:CBattleTutor = tutorBase.battleTutor;
        var keyPressAct:CActionCommon = new CActionCommon();
        var _onViewUpdate:Function = function () : Boolean {
            var ui:BTMultiKeyPressUI = battleTutor.viewHelper.multiKeyPress.ui;
            if (ui) {
                ui.desc.text = content1;
                for (var i:int = 0; i < keyList.length; i++) {
                    var key:String = keyList[i];
                    var skillItem:BTSkillItemUI = ui["skill" + (i+1)];
                    var keyClip:Clip = ui["key" + (i+1)];
                    keyClip.index = EKeyCode.getIndexByKey(key);
                    CViewRenderUtil.renderSkillItem(battleTutor.system, key, battleTutor.actorHelper.getSkillIDByKey(key), skillItem);
                }
            }
            return true;
        };

        keyPressAct.addStartHandler(new Handler(battleTutor.viewHelper.showView, [CMultiKeyPressViewHandler]));
        keyPressAct.addPassHandler(new Handler(battleTutor.condHelper.isViewShowed, [CMultiKeyPressViewHandler]));
        keyPressAct.addPassHandler(new Handler(_onViewUpdate));
        keyPressAct.addPassHandler(new Handler(battleTutor.actionHelper.resetStartTime, [keyPressAct]));
        keyPressAct.addPassHandler(new Handler(battleTutor.condHelper.isPassTime, [keyPressAct, 500]));

        return keyPressAct;
    }
}
}
