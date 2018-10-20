//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/28.
 */
package tutor.actionPackage {

import action.CActionBase;
import action.CActionCommon;

import flash.events.MouseEvent;
import flash.ui.Keyboard;
import kof.util.CAssertUtils;
import morn.core.components.Component;
import morn.core.components.Image;
import morn.core.handlers.Handler;
import view.CBattleTutorViewHandlerBase;
public class CIntroPackage extends CActionPackageBase {
    public function CIntroPackage() {

    }

    public override function buildAction() : CActionBase {
        CAssertUtils.assertNotEquals(totalPressCount, 0);
        CAssertUtils.assertNotNull(_viewClass);

        var battleTutor:CBattleTutor = tutorBase.battleTutor;
        var viewHandler:CBattleTutorViewHandlerBase = battleTutor.system.getBean(_viewClass) as CBattleTutorViewHandlerBase;

        var introAct:CActionCommon = new CActionCommon();
        var onInitialize:Function = function () : Boolean {
            pressCount = 0;
            return true;
        };
        var setUI:Function = function(step:int) : Boolean {
            var ui:Component = viewHandler.getUI();
            if (ui) {
                var img:Image;
                for (var i:int = 0; i < totalPressCount; i++) {
                    img = ui["img" + (i+1)];
                    if (img) {
                        if (step == (i+1)) {
                            img.visible = true;
                        } else {
                            img.visible = false;
                        }
                    }
                }
            }
            return true;
        };
        var listenOkBtn:Function = function () : Boolean {
            var ui:Component = viewHandler.getUI();
            if (ui) {
//                var okBtn:Button = ui["ok_btn"];
//                if (okBtn) {
//                    okBtn.clickHandler = new Handler(onOkClick);
//                }
                ui.addEventListener(MouseEvent.CLICK, onOkClick);
            }
            return true;
        };
        var unListenOkBtn:Function = function () : Boolean {
            var ui:Component = viewHandler.getUI();
            if (ui) {
//                var okBtn:Button = ui["ok_btn"];
//                if (okBtn) {
//                    okBtn.clickHandler = null;
//                }
                ui.removeEventListener(MouseEvent.CLICK, onOkClick);
            }
            return true;
        };
        var setCountDown:Function = function () : Boolean {
            viewHandler.startCountDown(function () : void {
                pressCount++;
            });
            return true;
        };
        var onKeyPress:Function = function (pressKeyCode:uint):Boolean {
            pressCount++;
            return true;
        };
        var onOkClick:Function = function () : void {
            pressCount++;
        };
        var checkPressCount:Function = function (checkCount:int) : Boolean {
            return pressCount >= checkCount;
        };
        var setPressCount:Function = function (value:int) : Boolean {
            pressCount = value;
            return true;
        };

        introAct.addStartHandler(new Handler(battleTutor.viewHelper.showView, [_viewClass]));
        introAct.addPassHandler(new Handler(battleTutor.condHelper.isViewShowed, [_viewClass]));

        introAct.addPassHandler(new Handler(onInitialize));

//        introAct.addPassHandler(new Handler(battleTutor.actionHelper.resetStartTime, [introAct]));
        for (var i:int = 0; i < totalPressCount; i++) {
            introAct.addPassHandler(new Handler(setPressCount, [i]));
            introAct.addPassHandler(new Handler(listenOkBtn));
            introAct.addPassHandler(new Handler(setCountDown));
            introAct.addPassHandler(new Handler(battleTutor.keyPressHelper.listenKey, [Keyboard.SPACE, onKeyPress]));
//            introAct.addPassHandler(new Handler(battleTutor.keyPressHelper.listenKey, [Keyboard.SPACE, onKeyPress]));

            introAct.addPassHandler(new Handler(setUI, [i+1]));

            if (i+1 == 1) {
                introAct.addPassHandler(new Handler(battleTutor.instanceHelper.playAudio, [_audioID]));
            } else if (i+1 ==2) {
                introAct.addPassHandler(new Handler(battleTutor.instanceHelper.playAudio, [_audioID2]));
            } else if (i+1 == 3) {
                introAct.addPassHandler(new Handler(battleTutor.instanceHelper.playAudio, [_audioID3]));
            }

            introAct.addPassHandler(new Handler(checkPressCount, [i+1]));


            if (i == 0) {
                introAct.addPassHandler(new Handler(battleTutor.instanceHelper.uploadData, [_uploadGuideStep1]));
            } else if (i == 1) {
                introAct.addPassHandler(new Handler(battleTutor.instanceHelper.uploadData, [_uploadGuideStep2]));
            } else if (i == 2) {
                introAct.addPassHandler(new Handler(battleTutor.instanceHelper.uploadData, [_uploadGuideStep3]));
            }

            introAct.addPassHandler(new Handler(unListenOkBtn));
            introAct.addPassHandler(new Handler(battleTutor.keyPressHelper.unListenKey, [Keyboard.SPACE, onKeyPress]));

        }
//        introAct.addPassHandler(new Handler(battleTutor.condHelper.isPassTime, [introAct, 2000]));
        introAct.addFinishHandler(new Handler(battleTutor.viewHelper.hideView, [_viewClass]));

        return introAct;
    }
}
}
