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

import flash.events.KeyboardEvent;

import flash.ui.Keyboard;

import kof.game.instance.CInstanceSystem;

import kof.game.instance.event.CInstanceEvent;

import morn.core.components.FrameClip;

import morn.core.handlers.Handler;

// QE 二章一关
public class CTutor4001 extends CTutorBase {
    public function CTutor4001() {

    }
    protected override function onInitialize() : void {
        battleTutor.instanceHelper.uploadData(CPathConfig.STEP_700);

        var openKeyAct:CActionBase = new CActionCommon();
        openKeyAct.addPassHandler(new Handler(battleTutor.instanceProcess.addVaildKeyList,
                [[Keyboard.Q, Keyboard.E]])); // 激活开放按键, 只是不会阻止 这些按键
        this.addAction(openKeyAct);

        var qeEffect:FrameClip = battleTutor.viewHelper.qeEffect;
        var pInstanceSystem:CInstanceSystem = battleTutor.systemHelper.instanceSystem;
        // 不按QE离开副本, 清理现场
        var onEnterNextLevelHandler:Function = function (e:CInstanceEvent = null) : Boolean {
            pInstanceSystem.removeEventListener(CInstanceEvent.ENTER_INSTANCE, onEnterNextLevelHandler);
            pInstanceSystem.removeEventListener(CInstanceEvent.LEVEL_ENTER, onEnterNextLevelHandler);
            cleanEffectHandler();
        };
        // 关掉指引
        var cleanEffectHandler:Function = function () : Boolean {
            if (qeEffect) {
                qeEffect.stop();
                qeEffect.visible = false;
            }

            // 避免离开副本时, 对象销毁了
            App.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyPress);

            // 隐藏特效
            return true;
        };

        // 播放指引特效
            // 副本退出 关指引
        var playQEffectHandler:Function = function () : Boolean {
            App.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyPress);

            // 处理一直不按QE
            pInstanceSystem.addEventListener(CInstanceEvent.ENTER_INSTANCE, onEnterNextLevelHandler);
            pInstanceSystem.addEventListener(CInstanceEvent.LEVEL_ENTER, onEnterNextLevelHandler);

            // 显示特效
            if (qeEffect) {
                qeEffect.play();
                qeEffect.visible = true;
            }
            return true;
        };

        // 按了QE关特效
        var onKeyPress:Function = function (e:KeyboardEvent):Boolean {
            if (e.keyCode == Keyboard.Q || e.keyCode == Keyboard.E) {
                App.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyPress);

                pInstanceSystem.removeEventListener(CInstanceEvent.ENTER_INSTANCE, onEnterNextLevelHandler);
                pInstanceSystem.removeEventListener(CInstanceEvent.LEVEL_ENTER, onEnterNextLevelHandler);
                cleanEffectHandler();
            }
            return true;
        };

        var introAct:CActionBase = new CActionCommon();
        introAct.addPassHandler(new Handler(playQEffectHandler));
        introAct.addFinishHandler(new Handler(battleTutor.instanceHelper.uploadData, [CPathConfig.STEP_715]));
        introAct.addFinishHandler(new Handler(battleTutor.instanceHelper.uploadData, [CPathConfig.STEP_715]));


        this.addAction(introAct);

    }
//    protected override function onInitialize() : void {
//        battleTutor.instanceHelper.uploadData(CPathConfig.STEP_700);
//
//        var pauseAct:CActionBase = new CActionCommon();
//        pauseAct.addStartHandler(new Handler(battleTutor.actorHelper.slowGame));
//        this.addAction(pauseAct);
//
//        var openKeyAct:CActionBase = new CActionCommon();
//        openKeyAct.addPassHandler(new Handler(battleTutor.instanceProcess.addVaildKeyList,
//                [[Keyboard.Q, Keyboard.E]])); // 激活开放按键, 只是不会阻止 这些按键
//        this.addAction(openKeyAct);
//
//        var packageIntro:CActionPackageBase = CActionPackageBuilder.build(CIntroPackage, this, null, null, false);
//        packageIntro.totalPressCount = 3;
//        packageIntro._uploadGuideStep1 = CPathConfig.STEP_705;
//        packageIntro._uploadGuideStep2 = CPathConfig.STEP_710;
//        packageIntro._uploadGuideStep3 = CPathConfig.STEP_715;
//        packageIntro._audioID2 = CPathConfig.AUDIO_13;
//        packageIntro._viewClass = CQEIntroViewHandler;
//        var introAct:CActionBase = packageIntro.buildAction();
//        introAct.addFinishHandler(new Handler(battleTutor.actorHelper.unSlowGame));
//        introAct.addFinishHandler(new Handler(battleTutor.instanceHelper.uploadData, [CPathConfig.STEP_720]));
//
//        this.addAction(introAct);
//
//    }
}
}
