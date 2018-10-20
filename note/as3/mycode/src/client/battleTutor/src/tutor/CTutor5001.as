//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/30.
 */
package tutor {

import action.CActionBase;
import action.CActionCommon;
import action.EKeyCode;

import config.CPathConfig;

import flash.ui.Keyboard;

import morn.core.handlers.Handler;

import tutor.actionPackage.CActionPackageBase;
import tutor.actionPackage.CActionPackageBuilder;
import tutor.actionPackage.CIntroPackage;

import view.CDefend1IntroViewHandler;
// 受身 精英1关
public class CTutor5001 extends CTutorBase {
    public function CTutor5001() {

    }

    protected override function onInitialize() : void {
        battleTutor.instanceHelper.uploadData(CPathConfig.STEP_800);

        var pauseAct:CActionBase = new CActionCommon();
        pauseAct.addStartHandler(new Handler(battleTutor.actorHelper.slowGame));
        this.addAction(pauseAct);

        var openKeyAct:CActionBase = new CActionCommon();
        openKeyAct.addPassHandler(new Handler(battleTutor.instanceProcess.addVaildKeyList,
                [[Keyboard.L]])); // 激活开放按键, 只是不会阻止 这些按键
        this.addAction(openKeyAct);

        var packageIntro:CActionPackageBase = CActionPackageBuilder.build(CIntroPackage, this, null, null, false);
        packageIntro.totalPressCount = 2;
        packageIntro._uploadGuideStep1 = CPathConfig.STEP_805;
        packageIntro._uploadGuideStep2 = CPathConfig.STEP_810;
        packageIntro._audioID = CPathConfig.AUDIO_14;
        packageIntro._viewClass = CDefend1IntroViewHandler;
        var introAct:CActionBase = packageIntro.buildAction();
        introAct.addFinishHandler(new Handler(battleTutor.actorHelper.unSlowGame));

        introAct.addFinishHandler(new Handler(battleTutor.instanceProcess.addVaildKey, [EKeyCode.getKeyCodeByKey(EKeyCode.L)]));
        introAct.addFinishHandler(new Handler(battleTutor.instanceProcess.updateView));

        introAct.addFinishHandler(new Handler(battleTutor.instanceHelper.uploadData, [CPathConfig.STEP_820]));

        this.addAction(introAct);

    }
}
}
