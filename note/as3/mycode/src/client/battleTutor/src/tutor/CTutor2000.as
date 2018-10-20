//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/7.
 */
package tutor {

import action.CActionBase;
import action.CActionCommon;
import config.CPathConfig;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

import kof.game.character.ai.CAIHandler;
import kof.game.common.CLang;
import kof.game.fightui.CFightViewHandler;
import kof.game.fightui.compoment.CInstanceProcessViewHandler;
import kof.game.lobby.CLobbySystem;
import morn.core.components.Component;
import morn.core.handlers.Handler;

// 强制自动战斗
public class CTutor2000 extends CTutorBase {
    public function CTutor2000() {

    }

    protected override function onInitialize() : void {
        battleTutor.instanceHelper.uploadData(CPathConfig.STEP_490);
        var fightViewHandler:CInstanceProcessViewHandler;

        // 播放特效
        var isPlayEffectFinish:Boolean = false;
        var isEffectPlayFinished:Function = function () : Boolean {
            return isPlayEffectFinish;
        };
        var playEffectHandler:Function = function () : Boolean {
            battleTutor.viewHelper.autoFightEffect.visible = true;
            battleTutor.viewHelper.autoFightEffect.playFromTo(null, null, new Handler(function () : void {
                isPlayEffectFinish = true;
                battleTutor.viewHelper.autoFightEffect.visible = false;
                battleTutor.viewHelper.autoFightEffect.stop();

            }));

            return true;
        };

        var unSetForceAutoFight:Function = function() : void {
            fightViewHandler = system.stage.getSystem(CLobbySystem).getBean(CFightViewHandler).getBean(CInstanceProcessViewHandler);
            if (fightViewHandler) {
                fightViewHandler.setForceAutoFight(false);
            }
        };
        // ==========================resize事件
        var onClickStage:Function = function (e:Event) : void {
            if(battleTutor)
                battleTutor.systemHelper.uiSystem.showMsgAlert(CLang.Get("battle_tutor_can_not_fight_tips"));
        };
        var onStageResize:Function = function (e:Event) : void {
            var fullMask:Sprite = App.stage.getChildByName("tutor2000Mask") as Sprite;
            if (fullMask) {
                renderFullMask(fullMask);
            }

            fullMask = App.stage.getChildByName("tutor2000MaskWithHole") as Sprite;
            if (fullMask) {
                renderFullMask(fullMask, battleTutor.viewHelper.autoFightBtn);
            }
        };
        var listenStageResize:Function = function () : Boolean {
            App.stage.addEventListener(Event.RESIZE, onStageResize);
            App.stage.addEventListener(Event.ENTER_FRAME, onStageResize);
            return true;
        };
        var unListenStageResize:Function = function () : Boolean {
            App.stage.removeEventListener(Event.RESIZE, onStageResize);
            App.stage.removeEventListener(Event.ENTER_FRAME, onStageResize);
            return true;
        };
        // ======================================聚集效果
        var renderFullMask:Function = function (fullMask:Sprite, holeTarget:Component = null) : Boolean {
            if (fullMask) {
                fullMask.graphics.clear();
                fullMask.graphics.beginFill(0, 0.01);
                fullMask.graphics.drawRect(0, 0, App.stage.stageWidth, App.stage.stageHeight);
                if (holeTarget) {
                    fullMask.graphics.drawCircle(holeTarget.x + holeTarget.width/2, holeTarget.y + holeTarget.height/2, holeTarget.width/2);
                }
                fullMask.graphics.endFill();
            }
            return true;
        };
        var setFullMaskWithHole:Function = function () : Boolean {
            var fullMaskWithHole:Sprite = new Sprite();
            renderFullMask(fullMaskWithHole, battleTutor.viewHelper.autoFightBtn);
            fullMaskWithHole.name = "tutor2000MaskWithHole";
            App.stage.addChild(fullMaskWithHole);
            return true;
        };
        var removeFullMaskWithHole:Function = function () : Boolean {
            var fullMaskWithHole:DisplayObject = App.stage.getChildByName("tutor2000MaskWithHole");
            if (fullMaskWithHole) {
                fullMaskWithHole.parent.removeChild(fullMaskWithHole);
            }
            return true;
        };

        // ======================================自动按钮点击处理
//        var listenAutoFightClick:Function = function () : Boolean {
//            battleTutor.viewHelper.autoFightBtn.addEventListener(MouseEvent.CLICK, onClickAutoFight);
//            return true;
//        };
//        var removeListenAutoFightClick:Function = function () : Boolean {
//            battleTutor.viewHelper.autoFightBtn.removeEventListener(MouseEvent.CLICK, onClickAutoFight);
//            return true;
//        };
//
//        var onClickAutoFight:Function = function(e:Event) : void {
//            var fightViewHandler:CInstanceProcessViewHandler = system.stage.getSystem(CLobbySystem).getBean(CFightViewHandler).getBean(CInstanceProcessViewHandler);
//            if (fightViewHandler) {
//                fightViewHandler.setForceAutoFight(true);
//                removeListenAutoFightClick();
//            }
//        };
//        var isForceAutoFight:Function = function (act:CActionBase)  : Boolean {
//
//            var fightViewHandler:CInstanceProcessViewHandler = system.stage.getSystem(CLobbySystem).getBean(CFightViewHandler).getBean(CInstanceProcessViewHandler);
//            if (fightViewHandler) {
//                if (act.passTime > 5000 && fightViewHandler.getForceAutoFight() == false) {
//                    battleTutor.viewHelper.autoFightBtn.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
//                    return true;
//                }
//                return fightViewHandler.getForceAutoFight();
//            }
//
//            return true;
//        };

        var isAutoFight:Function = function (act:CActionBase)  : Boolean {
            var aiHandler:CAIHandler = (battleTutor.systemHelper.escLoop.getBean(CAIHandler) as CAIHandler);
            if (aiHandler) {
                if (act.passTime > 5000 && aiHandler.bAutoFight == false) {
                    battleTutor.viewHelper.autoFightBtn.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
                    return true;
                }
                return aiHandler.bAutoFight;
            }

            return true;
        };


        // =======================================全屏mask处理
//        var setFullMask:Function = function () : Boolean {
//            var fullMask:Sprite = new Sprite();
//            renderFullMask(fullMask);
//            fullMask.name = "tutor2000Mask";
//            App.stage.addChild(fullMask);
//            App.stage.addEventListener(MouseEvent.CLICK, onClickStage);
//            App.stage.addEventListener(KeyboardEvent.KEY_UP, onClickStage);
//            return true;
//        };
//        var removeFullMask:Function = function () : Boolean {
//            var fullMask:DisplayObject = App.stage.getChildByName("tutor2000Mask");
//            if (fullMask) {
//                fullMask.parent.removeChild(fullMask);
//            }
//            App.stage.removeEventListener(MouseEvent.CLICK, onClickStage);
//            App.stage.removeEventListener(KeyboardEvent.KEY_UP, onClickStage);
//
//            return true;
//        };

        // ==================================================结束判断
        var isTargetFinish:Function = function () : Boolean {
            var mId:Number = 110102202;
            return battleTutor.condHelper.isActorDead(mId);
        };

        // ==========================================Action=====================================
        // ==========================================Action=====================================
        // ==========================================Action=====================================
        var stopZHandler:Function = function () : Boolean {
            var fightViewHandler:CInstanceProcessViewHandler = system.stage.getSystem(CLobbySystem).getBean(CFightViewHandler).getBean(CInstanceProcessViewHandler);
            if (fightViewHandler) {
                fightViewHandler.forceStopZ = true;
            }
            return true;
        };
        var unStopZHandler:Function = function () : Boolean {
            var fightViewHandler:CInstanceProcessViewHandler = system.stage.getSystem(CLobbySystem).getBean(CFightViewHandler).getBean(CInstanceProcessViewHandler);
            if (fightViewHandler) {
                fightViewHandler.forceStopZ = false;
            }
            return true;
        };

        // 禁止按Z
        var stopZKeyAct:CActionBase = new CActionCommon();
        stopZKeyAct.addStartHandler(new Handler(stopZHandler));
        this.addAction(stopZKeyAct);

        var listerStageResizeAct:CActionBase = new CActionCommon();
        listerStageResizeAct.addStartHandler(new Handler(listenStageResize));
        this.addAction(listerStageResizeAct);

        // 暂停
//        var slowAct:CActionBase = new CActionCommon();
//        slowAct.addStartHandler(new Handler(battleTutor.actorHelper.slowGame));
//        this.addAction(slowAct);

        // 聚圈
        var focusToAutoFightAct:CActionBase = new CActionCommon();
        focusToAutoFightAct.addStartHandler(new Handler(setFullMaskWithHole));
        this.addAction(focusToAutoFightAct);

        // 播放特效
        var playEffectAct:CActionBase = new CActionCommon();
        playEffectAct.addStartHandler(new Handler(playEffectHandler));
        playEffectAct.addPassHandler(new Handler(isEffectPlayFinished));
        this.addAction(playEffectAct);

        // 显示气泡框
        var showAutoFightTipsAct:CActionBase = new CActionCommon();
        showAutoFightTipsAct.addStartHandler(new Handler(battleTutor.viewHelper.showAutoFightTips));
        this.addAction(showAutoFightTipsAct);

        // 开启按Z
        var unStopZKeyAct:CActionBase = new CActionCommon();
        unStopZKeyAct.addStartHandler(new Handler(unStopZHandler));
        this.addAction(unStopZKeyAct);

        // 等待点击
//        var waitClickAutoAct:CActionBase = new CActionCommon();
//        waitClickAutoAct.addStartHandler(new Handler(listenAutoFightClick));
//        waitClickAutoAct.addStartHandler(new Handler(waitClickAutoAct.resetStartTime));
//        waitClickAutoAct.addPassHandler(new Handler(isForceAutoFight, [waitClickAutoAct]));
//        waitClickAutoAct.addFinishHandler(new Handler(removeListenAutoFightClick));
//        waitClickAutoAct.addFinishHandler(new Handler(battleTutor.instanceHelper.uploadData, [CPathConfig.STEP_492]));
        var waitClickAutoAct:CActionBase = new CActionCommon();
        waitClickAutoAct.addStartHandler(new Handler(waitClickAutoAct.resetStartTime));
        waitClickAutoAct.addPassHandler(new Handler(isAutoFight, [waitClickAutoAct]));
        waitClickAutoAct.addFinishHandler(new Handler(battleTutor.instanceHelper.uploadData, [CPathConfig.STEP_492]));

        this.addAction(waitClickAutoAct);

        // 隐藏气泡框
        var hideAutoFightTipsAct:CActionBase = new CActionCommon();
        hideAutoFightTipsAct.addStartHandler(new Handler(battleTutor.viewHelper.hideAutoFightTips));
        this.addAction(hideAutoFightTipsAct);

        // 去掉聚圈
        var unFocusToAutoFightAct:CActionBase = new CActionCommon();
        unFocusToAutoFightAct.addStartHandler(new Handler(removeFullMaskWithHole));
        this.addAction(unFocusToAutoFightAct);

        // 设置全屏mask, 提示无法点击
//        var setFullMaskAct:CActionBase = new CActionCommon();
//        setFullMaskAct.addStartHandler(new Handler(setFullMask));
//        this.addAction(setFullMaskAct);

        // 关闭战斗引导关掉的AI
//        var openAiAct:CActionBase = new CActionCommon();
//        openAiAct.addStartHandler(new Handler(openAI));
//        this.addAction(openAiAct);

        // 等待结束
//        var waitFinishAct:CActionBase = new CActionCommon();
//        waitFinishAct.addPassHandler(new Handler(isTargetFinish));
//        waitFinishAct.addFinishHandler(new Handler(battleTutor.instanceHelper.uploadData, [CPathConfig.STEP_494]));
//
//        this.addAction(waitFinishAct);

        // 还原mask
//        var removeFullMaskAct:CActionBase = new CActionCommon();
//        removeFullMaskAct.addStartHandler(new Handler(removeFullMask));
//        this.addAction(removeFullMaskAct);

        // 移除resize事件
        var unListerStageResizeAct:CActionBase = new CActionCommon();
        unListerStageResizeAct.addStartHandler(new Handler(unListenStageResize));
        this.addAction(unListerStageResizeAct);

        // 移除强制引导
        var unSetForceAutoFightAct:CActionBase = new CActionCommon();
//        unSetForceAutoFightAct.addStartHandler(new Handler(unSetForceAutoFight));
        unSetForceAutoFightAct.addFinishHandler(new Handler(battleTutor.instanceHelper.uploadData, [CPathConfig.STEP_496]));
        this.addAction(unSetForceAutoFightAct);
    }
}
}
