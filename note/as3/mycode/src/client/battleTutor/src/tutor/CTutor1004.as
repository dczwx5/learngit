//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/19.
 */
package tutor {

import action.CActionBase;
import action.CActionCommon;
import action.EKeyCode;

import config.CPathConfig;

import morn.core.handlers.Handler;
import tutor.actionPackage.CActionPackageBase;
import tutor.actionPackage.CActionPackageBuilder;
import tutor.actionPackage.CDescPackage;
import tutor.actionPackage.CFlyUIPackage;
import tutor.actionPackage.CHeroMoveToPackage;
import tutor.actionPackage.CIntroPackage;
import tutor.actionPackage.CQtePackage;

import view.CAbilityIntroViewHandler;

import view.CQTEViewHandler;
// UIO 一章一关 -> 改为放大招
public class CTutor1004 extends CTutorBase {
    public function CTutor1004() {

    }
    protected var _key:String;

    protected override function onInitialize() : void {
        battleTutor.instanceHelper.uploadData(CPathConfig.STEP_400);

        _key = EKeyCode.SPACE;

        // 跑向目标点
        var buildHeroMovePackage:CActionPackageBase = CActionPackageBuilder.build(CHeroMoveToPackage, this, null, null, false);
        var obj:Object = battleTutor.instanceHelper.getSingPoins(1);
        buildHeroMovePackage.toX = obj.x;
        buildHeroMovePackage.toY = obj.y;
        buildHeroMovePackage.srcObject = hero;
        buildHeroMovePackage.isMovePixel = true;
        var moveAct:CActionBase = buildHeroMovePackage.buildAction();
        this.addAction(moveAct);

        var pauseAct:CActionBase = new CActionCommon();
        pauseAct.addStartHandler(new Handler(battleTutor.actorHelper.slowGame));
        this.addAction(pauseAct);

        var packageDesc:CDescPackage = CActionPackageBuilder.build(CDescPackage, this, null, null, false) as CDescPackage;
        packageDesc._audioID = CPathConfig.AUDIO_11;
        packageDesc._uploadGuideStep1 = CPathConfig.STEP_405;
        packageDesc._descIndex = 4;
        var keyDescAct:CActionBase = packageDesc.buildAction();
        this.addAction(keyDescAct);

        // 加怒气
        var addPowerAction:CActionBase = new CActionCommon();
        addPowerAction.addStartHandler(new Handler(battleTutor.actorHelper.setRagePowerFull));
        this.addAction(addPowerAction);

        var forcePressKey:Boolean = true;
        var qtePackage:CQtePackage = CActionPackageBuilder.build(CQtePackage, this, [_key], null, forcePressKey) as CQtePackage;
        qtePackage.totalPressCount = 1;
        qtePackage._audioID = CPathConfig.AUDIO_17;
        qtePackage._uploadGuideStep1 = CPathConfig.STEP_410;
        qtePackage._showSpaceClip = true;
        var qteAct:CActionBase = qtePackage.buildAction();
        this.addAction(qteAct);


        var flyPackage:CActionPackageBase = CActionPackageBuilder.build(CFlyUIPackage, this, [_key], null, forcePressKey);
        flyPackage._uploadGuideStep1 = CPathConfig.STEP_420;
        var flyAct:CActionBase = flyPackage.buildAction();
        flyAct.addFinishHandler(new Handler(battleTutor.viewHelper.hideView, [CQTEViewHandler]));
        this.addAction(flyAct);

//        var packageIntro:CActionPackageBase = CActionPackageBuilder.build(CIntroPackage, this, null, null, false);
//        packageIntro.totalPressCount = 1;
////        packageIntro._audioID = CPathConfig.AUDIO_10;
//        packageIntro._viewClass = CAbilityIntroViewHandler;
//        packageIntro._uploadGuideStep1 = CPathConfig.STEP_430;
//        packageIntro._uploadGuideStep2 = CPathConfig.STEP_440;
//        var introAct:CActionBase = packageIntro.buildAction();
//        introAct.addFinishHandler(new Handler(battleTutor.instanceHelper.uploadData, [CPathConfig.STEP_450]));
//        this.addAction(introAct);

        // 去掉所有图片引导
        var introAct:CActionBase = new CActionCommon();
        introAct.addFinishHandler(new Handler(battleTutor.instanceHelper.uploadData, [CPathConfig.STEP_450]));
        this.addAction(introAct);
    }

    // 原1004 uio
//    protected override function onInitialize2() : void {
//        battleTutor.instanceHelper.uploadData(CPathConfig.STEP_400);
//
////        var monsterID:Number = 110101201;
//        _keyList = [EKeyCode.U, EKeyCode.I, EKeyCode.O];
//
//        var buildHeroMovePackage:CActionPackageBase = CActionPackageBuilder.build(CHeroMoveToPackage, this, null, null, false);
//        var obj:Object = battleTutor.instanceHelper.getSingPoins(1);
//        buildHeroMovePackage.toX = obj.x;
//        buildHeroMovePackage.toY = obj.y;
//        buildHeroMovePackage.srcObject = hero;
//        buildHeroMovePackage.isMovePixel = true;
//        var moveAct:CActionBase = buildHeroMovePackage.buildAction();
//        this.addAction(moveAct);
//
//
//
//        var pauseAct:CActionBase = new CActionCommon();
//        pauseAct.addStartHandler(new Handler(battleTutor.actorHelper.slowGame));
//        this.addAction(pauseAct);
//
//        var packageDesc:CDescPackage = CActionPackageBuilder.build(CDescPackage, this, null, null, false) as CDescPackage;
//        packageDesc._uploadGuideStep1 = CPathConfig.STEP_405;
//        packageDesc._audioID = CPathConfig.AUDIO_8;
//        packageDesc._descIndex = 3;
//        var keyDescAct:CActionBase = packageDesc.buildAction();
//        this.addAction(keyDescAct);
//
//
//        var forcePressKey:Boolean = true;
//        var qtePackage:CActionPackageBase = CActionPackageBuilder.build(CQtePackage, this, _keyList, null, forcePressKey);
//        qtePackage._autoPlayKey2WaitTime = 0;
//        qtePackage._autoPlayKey3WaitTime = 0;
//        qtePackage._uploadGuideStep1 = CPathConfig.STEP_410;
//        qtePackage._uploadGuideStep2 = CPathConfig.STEP_420;
//        qtePackage._uploadGuideStep3 = CPathConfig.STEP_430;
//        qtePackage._UIO = true;
//        var qteAct:CActionBase = qtePackage.buildAction();
//
//        qteAct.addFinishHandler(new Handler(battleTutor.instanceHelper.playAudio, [CPathConfig.AUDIO_9]));
//        this.addAction(qteAct);
//
//        var flyPackage:CActionPackageBase = CActionPackageBuilder.build(CFlyUIPackage, this, [EKeyCode.I, EKeyCode.O], null, forcePressKey);
//        flyPackage._uploadGuideStep1 = CPathConfig.STEP_440;
//        var flyAct:CActionBase = flyPackage.buildAction();
//        flyAct.addFinishHandler(new Handler(battleTutor.viewHelper.hideView, [CQTEViewHandler]));
//        flyAct.addFinishHandler(new Handler(battleTutor.instanceHelper.uploadData, [CPathConfig.STEP_450]));
//        this.addAction(flyAct);
//
//    }

    protected var _keyList:Array;
    protected var _keyDescContent:String;

}
}
