//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/30.
 */
package tutor {

import action.CActionBase;
import action.CActionCommon;

import config.CPathConfig;

import kof.game.core.CGameObject;

import morn.core.handlers.Handler;

import tutor.actionPackage.CActionPackageBase;
import tutor.actionPackage.CActionPackageBuilder;
import tutor.actionPackage.CHeroMoveToPackage;
import tutor.actionPackage.CIntroPackage;
import tutor.actionPackage.CSpellSkillPackage;

import view.CDefend2IntroViewHandler;
// 格档 一章三关
public class CTutor3001 extends CTutorBase {
    public function CTutor3001() {

    }

    protected override function onInitialize() : void {
        battleTutor.instanceHelper.uploadData(CPathConfig.STEP_600);

        var mId:Number = 110103202;



//        if (monster) {
//            var buildHeroMovePackage:CActionPackageBase = CActionPackageBuilder.build(CHeroMoveToPackage, this, null, null, false);
//            var obj:Object = battleTutor.instanceHelper.getSingPoins(0);
//            if (obj) {
//                buildHeroMovePackage.toX = obj.x;
//                buildHeroMovePackage.toY = obj.y;
//                buildHeroMovePackage.srcObject = monster;
//                buildHeroMovePackage.isMovePixel = true;
//                var moveAct:CActionBase = buildHeroMovePackage.buildAction();
//                this.addAction(moveAct);
//            }
//        }



        var waitMonsterRunningAct:CActionBase = new CActionCommon();
        waitMonsterRunningAct.addFinishHandler(new Handler(function () : Boolean {
            var monster:CGameObject = battleTutor.actorHelper.getMonsterByID(mId);
            return monster.isRunning;
        }));
        this.addAction(waitMonsterRunningAct);

        // delay 1秒
        var waitDelayFinish:Function = function (act:CActionBase) : Boolean {
            return act.passTime > 1000;
        };
        var delay1SecondAct:CActionBase = new CActionCommon();
        delay1SecondAct.addStartHandler(new Handler(delay1SecondAct.resetStartTime));
        delay1SecondAct.addPassHandler(new Handler(waitDelayFinish, [delay1SecondAct]));
        this.addAction(delay1SecondAct);

        var packageUseSkill:CActionPackageBase = CActionPackageBuilder.build(CSpellSkillPackage, this, null, null, false);
        packageUseSkill.skillIDList = [127201]; // [127011, 127021, 127031];
        packageUseSkill.srcObject = battleTutor.actorHelper.getMonsterByID(mId);
        packageUseSkill.totalPressCount = 1;
        var useSkillAct:CActionBase = packageUseSkill.buildAction();

        useSkillAct.addFinishHandler(new Handler(battleTutor.actorHelper.slowGame));
        this.addAction(useSkillAct);


        var pauseAct:CActionBase = new CActionCommon();
        pauseAct.addPassHandler(new Handler(battleTutor.condHelper.isPassTime, [pauseAct, 1000]));
        this.addAction(pauseAct);

        var packageIntro:CActionPackageBase = CActionPackageBuilder.build(CIntroPackage, this, null, null, false);
        packageIntro.totalPressCount = 2;
        packageIntro._uploadGuideStep1 = CPathConfig.STEP_605;
        packageIntro._uploadGuideStep2 = CPathConfig.STEP_610;
        packageIntro._audioID2 = CPathConfig.AUDIO_12;
        packageIntro._viewClass = CDefend2IntroViewHandler;
        var introAct:CActionBase = packageIntro.buildAction();
        introAct.addFinishHandler(new Handler(battleTutor.actorHelper.unSlowGame));
        introAct.addFinishHandler(new Handler(battleTutor.instanceHelper.uploadData, [CPathConfig.STEP_620]));

        this.addAction(introAct);

    }


}
}
