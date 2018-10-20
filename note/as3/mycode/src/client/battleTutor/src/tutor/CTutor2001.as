//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/28.
 */
package tutor {

import action.CActionBase;
import action.CActionCommon;
import config.CPathConfig;
import flash.events.Event;
import flash.events.MouseEvent;
import kof.game.character.ai.CAIHandler;
import kof.game.core.CECSLoop;
import morn.core.handlers.Handler;

// 大招 一章2关 - 这个不用了
public class CTutor2001 extends CTutorBase {
    protected var _key:String;

    public function CTutor2001() {

    }

    protected override function onInitialize() : void {
//        battleTutor.instanceHelper.uploadData(CPathConfig.STEP_650);

//        var pauseAct:CActionBase = new CActionCommon();
//        pauseAct.addStartHandler(new Handler(battleTutor.actorHelper.slowGame));
//        this.addAction(pauseAct);

//        var packageIntro:CActionPackageBase = CActionPackageBuilder.build(CIntroPackage, this, null, null, false);
//        packageIntro.totalPressCount = 2;
//        packageIntro._uploadGuideStep1 = CPathConfig.STEP_655;
//        packageIntro._uploadGuideStep2 = CPathConfig.STEP_660;
////        packageIntro._audioID = CPathConfig.AUDIO_14;
//        packageIntro._viewClass = CAutoFightIntroViewHandler;
//        var introAct:CActionBase = packageIntro.buildAction();
//        introAct.addFinishHandler(new Handler(battleTutor.actorHelper.unSlowGame));
//        introAct.addFinishHandler(new Handler(battleTutor.instanceProcess.updateView));
//        introAct.addFinishHandler(new Handler(battleTutor.instanceHelper.uploadData, [CPathConfig.STEP_670]));
//        introAct.addFinishHandler(new Handler(function () : Boolean {
//            battleTutor.systemHelper.autoFightHandler.lastForcePauseState = false; // 由于上一关。最后的状态是自动战斗, 这要里改掉
//            // 模拟点击， 切回手动状态
//            var aiHandler:CAIHandler = system.stage.getSystem(CECSLoop).getBean(CAIHandler) as CAIHandler;
//            if (aiHandler.bAutoFight) {
//                battleTutor.viewHelper.autoFightBtn.dispatchEvent(new Event(MouseEvent.CLICK));
//            }
//            return true;
//        }));
//        this.addAction(introAct);
        // 去掉图片引导 整个引导只做恢复自动战斗。不做功能, 不恢复自动战斗了
        var introAct:CActionBase = new CActionCommon();
//        introAct.addFinishHandler(new Handler(battleTutor.actorHelper.unSlowGame));
//        introAct.addFinishHandler(new Handler(battleTutor.instanceProcess.updateView));
////        introAct.addFinishHandler(new Handler(battleTutor.instanceHelper.uploadData, [CPathConfig.STEP_670]));
//        introAct.addFinishHandler(new Handler(function () : Boolean {
//            battleTutor.systemHelper.autoFightHandler.lastForcePauseState = false; // 由于上一关。最后的状态是自动战斗, 这要里改掉
//            // 模拟点击， 切回手动状态
//            var aiHandler:CAIHandler = system.stage.getSystem(CECSLoop).getBean(CAIHandler) as CAIHandler;
//            if (aiHandler.bAutoFight) {
//                battleTutor.viewHelper.autoFightBtn.dispatchEvent(new Event(MouseEvent.CLICK));
//            }
//            return true;
//        }));
        this.addAction(introAct);

    }

    // 原2001
//    protected override function onInitialize() : void {
//        battleTutor.instanceHelper.uploadData(CPathConfig.STEP_500);
//
//        _key = EKeyCode.SPACE;
//
//        var pauseAct:CActionBase = new CActionCommon();
//        pauseAct.addStartHandler(new Handler(battleTutor.actorHelper.slowGame));
//        this.addAction(pauseAct);
//
//        var packageDesc:CDescPackage = CActionPackageBuilder.build(CDescPackage, this, null, null, false) as CDescPackage;
//        packageDesc._audioID = CPathConfig.AUDIO_11;
//        packageDesc._uploadGuideStep1 = CPathConfig.STEP_505;
//        packageDesc._descIndex = 4;
//        var keyDescAct:CActionBase = packageDesc.buildAction();
//        this.addAction(keyDescAct);
//
//        // 加怒气
//        var addPowerAction:CActionBase = new CActionCommon();
//        addPowerAction.addStartHandler(new Handler(battleTutor.actorHelper.setRagePowerFull));
//        this.addAction(addPowerAction);
//
//        var forcePressKey:Boolean = true;
//        var qtePackage:CQtePackage = CActionPackageBuilder.build(CQtePackage, this, [_key], null, forcePressKey) as CQtePackage;
//        qtePackage.totalPressCount = 1;
//        qtePackage._audioID = CPathConfig.AUDIO_17;
//        qtePackage._uploadGuideStep1 = CPathConfig.STEP_510;
//        var qteAct:CActionBase = qtePackage.buildAction();
//        this.addAction(qteAct);
//
//
//        var flyPackage:CActionPackageBase = CActionPackageBuilder.build(CFlyUIPackage, this, [_key], null, forcePressKey);
//        flyPackage._uploadGuideStep1 = CPathConfig.STEP_520;
//        var flyAct:CActionBase = flyPackage.buildAction();
//        flyAct.addFinishHandler(new Handler(battleTutor.viewHelper.hideView, [CQTEViewHandler]));
//        this.addAction(flyAct);
//
//        var packageIntro:CActionPackageBase = CActionPackageBuilder.build(CIntroPackage, this, null, null, false);
//        packageIntro.totalPressCount = 1;
//        packageIntro._audioID = CPathConfig.AUDIO_10;
//        packageIntro._viewClass = CAbilityIntroViewHandler;
//        packageIntro._uploadGuideStep1 = CPathConfig.STEP_530;
//        packageIntro._uploadGuideStep2 = CPathConfig.STEP_540;
//        var introAct:CActionBase = packageIntro.buildAction();
//        introAct.addFinishHandler(new Handler(battleTutor.instanceHelper.uploadData, [CPathConfig.STEP_560]));
//        this.addAction(introAct);
//
//    }
}
}
