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

import kof.ui.master.BattleTutor.BTMultiKeyDescUI;
import kof.ui.master.BattleTutor.BTSkillItemUI;
import kof.util.CAssertUtils;
import morn.core.components.Clip;
import morn.core.handlers.Handler;
import view.CMultiKeyDescViewHandler;
import view.CViewRenderUtil;

public class CMultiKeyDescPackage extends CActionPackageBase {
    public function CMultiKeyDescPackage() {

    }

    public override function buildAction() : CActionBase {
        CAssertUtils.assertNotNull(contentList);
        CAssertUtils.assertNotNull(keyList);

        var battleTutor:CBattleTutor = tutorBase.battleTutor;
        var showKeyDescAction:CActionCommon = new CActionCommon();
        var setUI:Function = function() : Boolean {
            var ui:BTMultiKeyDescUI = battleTutor.viewHelper.multiKeyDesc.ui;
            if (ui) {
                ui.desc.text = content1;
                for (var i:int = 0; i < keyList.length; i++) {
                    var key:String = keyList[i];
                    var skillItem:BTSkillItemUI = ui["skill" + (i+1)];
                    CViewRenderUtil.renderSkillItem(battleTutor.system, key, battleTutor.actorHelper.getSkillIDByKey(key), skillItem);
                }
            }
            return true;
        };

        showKeyDescAction.addStartHandler(new Handler(battleTutor.viewHelper.showView, [CMultiKeyDescViewHandler]));
        showKeyDescAction.addPassHandler(new Handler(battleTutor.condHelper.isViewShowed, [CMultiKeyDescViewHandler]));
        showKeyDescAction.addPassHandler(new Handler(battleTutor.actionHelper.resetStartTime, [showKeyDescAction]));
        showKeyDescAction.addPassHandler(new Handler(setUI));
        showKeyDescAction.addPassHandler(new Handler(battleTutor.condHelper.isPassTime, [showKeyDescAction, 2000]));
        showKeyDescAction.addFinishHandler(new Handler(battleTutor.viewHelper.hideView, [CMultiKeyDescViewHandler]));

        return showKeyDescAction;
    }
}
}
