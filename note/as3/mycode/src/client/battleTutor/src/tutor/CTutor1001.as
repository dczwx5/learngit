//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/8.
 */
package tutor {

import QFLib.Math.CVector2;
import QFLib.Math.CVector3;
import action.CActionCommon;
import action.EKeyCode;
import config.CPathConfig;
import flash.ui.Keyboard;
import kof.ui.master.BattleTutor.BTKeyboardUI;
import morn.core.components.Box;
import morn.core.components.FrameClip;
import morn.core.handlers.Handler;
import view.CWSADViewHandler;

//
public class CTutor1001 extends CTutorBase {
    public function CTutor1001() {

    }

    protected override function onInitialize() : void {
        battleTutor.instanceHelper.uploadData(CPathConfig.STEP_100);

        var wsadView:CWSADViewHandler = battleTutor.viewHelper.WSADView;
        var act:CActionCommon = new CActionCommon();
        wsadView._targetPos = new CVector3( 810, 2004, 0); // new CVector3( 1177, 2004, 0);
        wsadView._startHeroPos = battleTutor.actorHelper.hero.transform.position.clone();


        var initialView:Function = function () : Boolean {
            var ui:BTKeyboardUI = battleTutor.viewHelper.WSADView.ui;
            ui.w_box.visible = ui.a_box.visible = ui.s_box.visible = ui.d_box.visible = true;
            ui.d_effect.visible = false;
            ui.d_img.visible = false;
            ui.wasd_img.visible = true;
            ui.visible = true;
            // 改成wasd一出来就能动
            battleTutor.instanceProcess.addVaildKeyList([Keyboard.W, Keyboard.A, Keyboard.S, Keyboard.D]);
            battleTutor.actorHelper.markPlayerControlValue();
            battleTutor.actorHelper.openPlayerControl();

            return true;
        };
        var setKeyPressView:Function = function () : Boolean {
            var activteClip:FrameClip = battleTutor.viewHelper.WSADView.ui.d_effect; // 字特效
            var hideBox:Box = battleTutor.viewHelper.WSADView.ui.d_box; // 背面的字
            activteClip.visible = true;
            activteClip.autoPlay = true;
            activteClip.play();
            hideBox.visible = false;

            var ui:BTKeyboardUI = battleTutor.viewHelper.WSADView.ui;
            if (ui) {
                ui.d_img.visible = true;
                ui.wasd_img.visible = false;
            }
            return true;
        };
        var showEffect:Function = function () : Boolean {
            wsadView.uiCanvas.rootContainer.addChild(wsadView._circleClip);
            wsadView.uiCanvas.rootContainer.addChild(wsadView._posTargetClip);
            battleTutor.viewHelper.WSADView.uiCanvas.rootContainer.addChild(wsadView._arrowClip);

            wsadView._circleClip.playFromTo(null, null, new Handler(function () : void {
                if (!act.isFinish) {
                    if (wsadView._circleClip && wsadView._circleClip.parent) wsadView._circleClip.parent.removeChild(wsadView._circleClip);
                }
            }));


            return true;
        };
        var updateView:Function = function () : Boolean {
            var screenPos:CVector2;
            if (wsadView._posTargetClip && wsadView._posTargetClip.parent) {
                screenPos = battleTutor.viewHelper.scene3dToScreen(wsadView._targetPos);
                wsadView._posTargetClip.setPosition(screenPos.x, screenPos.y);
            }
            if (wsadView._circleClip && wsadView._circleClip.parent) {
                if (screenPos == null) {
                    screenPos = battleTutor.viewHelper.scene3dToScreen(wsadView._targetPos);
                }
                wsadView._circleClip.setPosition(screenPos.x, screenPos.y);
            }
            return true;
        };

        var setDetailUnVisible:Function = function () : Boolean {
            battleTutor.viewHelper.WSADView.ui.visible = false;
            return true;
        };
        var setUpdatehandler:Function = function () : Boolean {
            battleTutor.viewHelper.WSADView.updateHandler = new Handler(setDetailUnVisible);
            return true;
        };
        var setUpdateHandlerNone:Function = function () : Boolean {
            battleTutor.viewHelper.WSADView.updateHandler = null;
            return true;
        };

        act.addStartHandler(new Handler(setUpdatehandler));


        act.addStartHandler(new Handler(battleTutor.viewHelper.showView, [CWSADViewHandler]));
        act.addPassHandler(new Handler(battleTutor.condHelper.isViewShowed, [CWSADViewHandler]));
        act.addPassHandler(new Handler(battleTutor.instanceHelper.uploadData, [CPathConfig.STEP_105]));
        act.addPassHandler(new Handler(act.resetStartTime));
        act.addPassHandler(new Handler(initialView));

        act.addPassHandler(new Handler(setKeyPressView));
        act.addPassHandler(new Handler(battleTutor.instanceHelper.uploadData, [CPathConfig.STEP_110]));

        act.addPassHandler(new Handler(battleTutor.instanceHelper.playAudio, [CPathConfig.AUDIO_3]));
        act.addPassHandler(new Handler(showEffect));

        // 等待15s, 如果超15秒没按D.就自动跑。跑的过程如果按D会中断自动跑
        var passTimeHandler:Handler = new Handler(battleTutor.condHelper.isPassTime, [act, 15000]); // 15s算通过
        var runHandler:Handler = new Handler(battleTutor.condHelper.checkHeroRunTo, [EKeyCode.D, battleTutor.actorHelper.hero, wsadView._startHeroPos, false]); // 一按D就完成,WASD步骤
        var isPassTimeOrRunD:Function = function() : Boolean {
            var pass1:Boolean = passTimeHandler.method.apply(null, passTimeHandler.args);
            var pass2:Boolean = runHandler.method.apply(null, runHandler.args);
            if (pass1) {
                // 自动跑
                battleTutor.actorHelper.moveTo(hero, wsadView._targetPos.x, wsadView._targetPos.y, null);
            }
            return pass1 || pass2;
        };
        act.addPassHandler(new Handler(isPassTimeOrRunD)); //  一按D就完成 or 15s没按D

        act.addPassHandler(new Handler(battleTutor.condHelper.checkHeroRunTo, [EKeyCode.D, battleTutor.actorHelper.hero, wsadView._targetPos, true])); // 检测到目的的
        act.addUpdateHandler(new Handler(updateView));
        act.addFinishHandler(new Handler(battleTutor.viewHelper.hideView, [CWSADViewHandler]));
        act.addFinishHandler(new Handler(battleTutor.actorHelper.setPlayerControlValueByMark));
        act.addFinishHandler(new Handler(setUpdateHandlerNone));
        act.addPassHandler(new Handler(battleTutor.instanceHelper.uploadData, [CPathConfig.STEP_120]));

        this.addAction(act);
    }
    public override function start() : void {
        super.start();
    }
}
}
