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
import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.property.CCharacterProperty;
import kof.game.core.CGameObject;
import kof.game.scene.CSceneSystem;
import kof.ui.master.BattleTutor.BTTopTipsUI;
import morn.core.components.Box;
import morn.core.handlers.Handler;
import tutor.actionPackage.CActionPackageBase;
import tutor.actionPackage.CActionPackageBuilder;
import tutor.actionPackage.CDescPackage;
import tutor.actionPackage.CFlyUIPackage;
import tutor.actionPackage.CHeroMoveToPackage;
import tutor.actionPackage.CQtePackage;
import view.CQTEViewHandler;

// UUU -> 改成UIO
public class CTutor1003 extends CTutorBase {
    protected var _keyList:Array;

    public function CTutor1003() {

    }

    protected override function onInitialize() : void {
        battleTutor.instanceHelper.uploadData(CPathConfig.STEP_300);

        _keyList = [EKeyCode.U, EKeyCode.I, EKeyCode.O];

        var buildHeroMovePackage:CActionPackageBase = CActionPackageBuilder.build(CHeroMoveToPackage, this, null, null, false);
        var obj:Object = battleTutor.instanceHelper.getSingPoins(0);
        buildHeroMovePackage.toX = obj.x;
        buildHeroMovePackage.toY = obj.y;
        buildHeroMovePackage.srcObject = hero;
        buildHeroMovePackage.isMovePixel = true;
        var moveAct:CActionBase = buildHeroMovePackage.buildAction();
        moveAct.addFinishHandler(new Handler(battleTutor.actorHelper.turnRight));

        this.addAction(moveAct);

        var waitAct:CActionBase = new CActionCommon();
        waitAct.addStartHandler(new Handler(waitAct.resetStartTime));
        waitAct.addFinishHandler(new Handler(battleTutor.condHelper.isPassTime, [waitAct, 1000]));
        this.addAction(waitAct);


        var pauseAct:CActionBase = new CActionCommon();
        pauseAct.addStartHandler(new Handler(battleTutor.actorHelper.slowGame));
        this.addAction(pauseAct);

        var packageDesc:CDescPackage = CActionPackageBuilder.build(CDescPackage, this, null, null, false) as CDescPackage;
        packageDesc._uploadGuideStep1 = CPathConfig.STEP_305;
        packageDesc._audioID = CPathConfig.AUDIO_8;
        packageDesc._descIndex = 3;
        var keyDescAct:CActionBase = packageDesc.buildAction();
        this.addAction(keyDescAct);


        var forcePressKey:Boolean = true;
        var qtePackage:CActionPackageBase = CActionPackageBuilder.build(CQtePackage, this, _keyList, null, forcePressKey);
        qtePackage._autoPlayKey2WaitTime = 2000;
        qtePackage._autoPlayKey3WaitTime = 2000;
        qtePackage._uploadGuideStep1 = CPathConfig.STEP_310;
        qtePackage._uploadGuideStep2 = CPathConfig.STEP_320;
        qtePackage._uploadGuideStep3 = CPathConfig.STEP_330;
        qtePackage._showUIOClip = true;
        qtePackage._UIO = true;
        var qteAct:CActionBase = qtePackage.buildAction();
        qteAct.addFinishHandler(new Handler(battleTutor.instanceHelper.playAudio, [CPathConfig.AUDIO_9]));
        this.addAction(qteAct);



        var flyPackage:CActionPackageBase = CActionPackageBuilder.build(CFlyUIPackage, this, [EKeyCode.U, EKeyCode.I, EKeyCode.O], null, forcePressKey);
        flyPackage._uploadGuideStep1 = CPathConfig.STEP_340;
        var flyAct:CActionBase = flyPackage.buildAction();
        flyAct.addFinishHandler(new Handler(battleTutor.viewHelper.hideView, [CQTEViewHandler]));
        this.addAction(flyAct);

//        var packageIntro:CActionPackageBase = CActionPackageBuilder.build(CIntroPackage, this, null, null, false);
//        packageIntro.totalPressCount = 1;
//        packageIntro._viewClass = CUIOIntroViewHandler;
//        packageIntro._uploadGuideStep1 = CPathConfig.STEP_343;
//        var introAct:CActionBase = packageIntro.buildAction();
//        introAct.addStartHandler(new Handler(battleTutor.instanceProcess.addVaildKeyList, [[Keyboard.SPACE]])); // 暂时 放开空格键
//        introAct.addFinishHandler(new Handler(battleTutor.instanceHelper.uploadData, [CPathConfig.STEP_346]));
//        introAct.addFinishHandler(new Handler(battleTutor.instanceHelper.uploadData, [CPathConfig.STEP_350]));
//        introAct.addFinishHandler(new Handler(battleTutor.instanceProcess.removeVaildKeyList, [[Keyboard.SPACE]])); //锁上开空格键
//        introAct.addFinishHandler(new Handler(_showUIOTips));
//        this.addAction(introAct);
        // 去掉所有图片引导
        var introAct:CActionBase = new CActionCommon();
        introAct.addFinishHandler(new Handler(battleTutor.instanceHelper.uploadData, [CPathConfig.STEP_350]));
        introAct.addFinishHandler(new Handler(_showUIOTips));
        this.addAction(introAct);

    }
    private function _showUIOTips() : Boolean {
        var box:Box = battleTutor.viewHelper.battleTutorBoxInFightView;
        if (box) {
            box.visible = true;
            // ui表现
            box.removeAllChild();
            var btTipsUI:BTTopTipsUI = new BTTopTipsUI();
            box.addChild(btTipsUI);

            // 退出副本, 关闭box, 避免异常
            battleTutor.systemHelper.instanceSystem.addExitProcess(null, null, _endShowTips, [{box:box}], 1);

            // 查找敌人, 这个只支持只有一个敌人
            var sceneSystem:CSceneSystem = battleTutor.systemHelper.sceneSystem as CSceneSystem;
            var pHero:CGameObject = battleTutor.actorHelper.hero;
            var heroCampID:int = CCharacterDataDescriptor.getCampID(pHero.data);
            var allMonsters:Vector.<Object> = sceneSystem.findAllMonster();
            var findEnemy:CGameObject;
            for each (var obj:CGameObject in allMonsters) {
                var mCampID:int = CCharacterDataDescriptor.getCampID(obj.data);
                if (heroCampID != mCampID) {
                    findEnemy = obj;
                    break;
                }
            }
            if (findEnemy) {
                var pBattleTutor:CBattleTutor = battleTutor; // battleTutor已清除
                // 怪物死亡 -> 结束
                var isFindEnemyDeadHandler:Function = function () : Boolean {
                    var objID:int = (findEnemy.getComponentByClass(CCharacterProperty, false) as CCharacterProperty).prototypeID;
                    return pBattleTutor.condHelper.isActorDead(objID);
                };
                battleTutor.systemHelper.instanceSystem.addSequential(null, isFindEnemyDeadHandler);
                battleTutor.systemHelper.instanceSystem.addSequential(new Handler(_endShowTips, [{box:box}]), null);
            }
        }
        return true;
    }

    private function _endShowTips(extendsData:Object = null) : Boolean {
        var box:Box = extendsData["box"] as Box; // battleTutor.viewHelper.battleTutorBoxInFightView;
        if (box) {
            box.visible = false;
            box.removeAllChild();
        }
        return true;
    }
// 原本的1003 uuu
//    protected override function onInitialize() : void {
//        battleTutor.instanceHelper.uploadData(CPathConfig.STEP_300);
//
//        _key = EKeyCode.U;
//
//        var buildHeroMovePackage:CActionPackageBase = CActionPackageBuilder.build(CHeroMoveToPackage, this, null, null, false);
//        var obj:Object = battleTutor.instanceHelper.getSingPoins(0);
//        buildHeroMovePackage.toX = obj.x;
//        buildHeroMovePackage.toY = obj.y;
//        buildHeroMovePackage.srcObject = hero;
//        buildHeroMovePackage.isMovePixel = true;
//        var moveAct:CActionBase = buildHeroMovePackage.buildAction();
//        this.addAction(moveAct);
//
//        var pauseAct:CActionBase = new CActionCommon();
//        pauseAct.addStartHandler(new Handler(battleTutor.actorHelper.slowGame));
//        this.addAction(pauseAct);
//
//        var packageDesc:CDescPackage = CActionPackageBuilder.build(CDescPackage, this, null, null, false) as CDescPackage;
//        packageDesc._audioID = CPathConfig.AUDIO_2;
//        packageDesc._uploadGuideStep1 = CPathConfig.STEP_305;
//        packageDesc._descIndex = 2;
//        var keyDescAct:CActionBase = packageDesc.buildAction();
//        this.addAction(keyDescAct);
//
//        var openAI:CActionBase = new CActionCommon();
//        openAI.addPassHandler(new Handler(battleTutor.actorHelper.openAI));
//        this.addAction(openAI);
//
//        var forcePressKey:Boolean = false;
//        var qtePackage:CQtePackage = CActionPackageBuilder.build(CQtePackage, this, [_key], null, forcePressKey) as CQtePackage;
//        qtePackage._audioID = CPathConfig.AUDIO_6;
//        qtePackage._autoPlayKey2WaitTime = 0;
//        qtePackage._autoPlayKey3WaitTime = 0;
//        qtePackage._uploadGuideStep1 = CPathConfig.STEP_310;
////        qtePackage._uploadGuideStep2 = CPathConfig.STEP_320;
////        qtePackage._uploadGuideStep3 = CPathConfig.STEP_330;
//        var qteAct:CActionBase = qtePackage.buildAction();
//        this.addAction(qteAct);
//
//        var flyPackage:CActionPackageBase = CActionPackageBuilder.build(CFlyUIPackage, this, [_key], null, forcePressKey);
//        flyPackage._uploadGuideStep1 = CPathConfig.STEP_340;
//        var flyAct:CActionBase = flyPackage.buildAction();
//        flyAct.addFinishHandler(new Handler(battleTutor.instanceHelper.playAudio, [CPathConfig.AUDIO_16]));
//        flyAct.addFinishHandler(new Handler(battleTutor.viewHelper.hideView, [CQTEViewHandler]));
//        flyAct.addFinishHandler(new Handler(battleTutor.instanceHelper.uploadData, [CPathConfig.STEP_350]));
//
//        this.addAction(flyAct);
//    }
}
}
