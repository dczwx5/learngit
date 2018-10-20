//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/4/29.
 */
package kof.game.instance.mainInstance.view.result.winMovie {

import QFLib.Utils.FilterUtil;

import com.greensock.TweenLite;
import flash.events.IEventDispatcher;

import kof.game.common.uiMovie.CMovieCompoentBase;

import kof.game.common.uiMovie.CMovieAction;
import kof.game.common.view.CViewBase;
import kof.game.instance.mainInstance.view.result.CInstanceWinMovieProcess;

import morn.core.components.Component;
import morn.core.components.FrameClip;
import morn.core.components.Label;
import morn.core.handlers.Handler;

public class CInstanceWinShowRoleMovieCompoent extends CMovieCompoentBase {
    private var roleUI:Component;
    private var role1:Component;
    private var role2:Component;
    private var role3:Component;
    private var winBox:Component;
    private var line1:Component;
    private var line2:Component;
    private var win:Component;
    private var winEffect:Component;
    private var roleWhite:Component;
    private var say1:Component;
    private var sayBg:Component;
    private var sayBgWhite:Component;
    private var sayMask1:Component;
    private var say2:Component;
    private var sayMask2:Component;
    private var _rootView:CInstanceWinMovieProcess;

    public function CInstanceWinShowRoleMovieCompoent(dispatcher:CViewBase, componentList:Vector.<Component>, endFunc:Function, rootView:CInstanceWinMovieProcess) {
        super (dispatcher, componentList, endFunc);

        _rootView = rootView;

        roleUI = componentList[0];
        role1 = componentList[1];
        role2 = componentList[2];
        role3 = componentList[3];
        winBox = componentList[4];
        line1 = componentList[5];
        line2 = componentList[6];
        win = componentList[7];
        winEffect = componentList[8];
        roleWhite = componentList[9];
        say1 = componentList[10];
        sayBg = componentList[11];
        sayBgWhite = componentList[12];
        sayMask1 = componentList[13];
        say2 = componentList[14];
        sayMask2 = componentList[15];


    }
    public override function dispose() : void {
        super.dispose();
    }
    protected override function _initial() : void {
        if (_rootView.isForceStop) {
            forceFinish();
            return
        }

        role2.x = roleUI.width + 500;
        role3.x = -500;
        _actionList.push(new CMovieAction(_actionHeroMove, 3));
    }
    private function _actionHeroMove(action:CMovieAction) : void {
        if (_rootView.isForceStop) {
            forceFinish();
            return
        }

        role1.visible = false;
        roleWhite.visible = false;
        roleUI.visible = true;

        var count:int = 0;
        var isFinish:Boolean = false;
        var checkFunc:Function = function () : void {
            count++;
            if (count == 5 && isFinish == false) {
                isFinish = true;
                _nextAction(action);
            }
        };


        _teamHeroMove(action, checkFunc);
        _teamerMove(action, checkFunc);
    }
    private function _teamHeroMove(action:CMovieAction, finishFunc:Function) : void {
        if (_rootView.isForceStop) {
            forceFinish();
            return
        }

        var role2ToX:int = _basePosList[2].x;
        var role3ToX:int = _basePosList[3].x;

        // 队友出现
        TweenLite.to(role2, action.duringTime*0.14, {x:role2ToX, onComplete:function () : void {
            finishFunc();
        }});

        TweenLite.to(role3, action.duringTime*0.14, {x:role3ToX, onComplete:function () : void {
            finishFunc();
        }});
    }
    private function _teamerMove(action:CMovieAction, finishFunc:Function) : void {
        if (_rootView.isForceStop) {
            forceFinish();
            return
        }

        // 队长出来
        var showRole1:Function = function () : void {
            role1.visible = true;
            role1.scale *= 2;
            // 大变小
            TweenLite.to(role1, action.duringTime*0.05, {scale : 1, onComplete : function () : void {
//                roleWhite.visible = true;
//                roleWhite.filters = FilterUtil.ALL_WHITE_FILTER;
//                roleWhite.alpha = 1.0;
//                roleWhite.scale = 1;
//                // 滤镜变大
//                TweenLite.to(roleWhite, action.duringTime * 0.1, {alpha : 0, scale:1.1, onComplete : function () : void {
//                    roleWhite.filters = null;
//                    roleWhite.visible = false;
//                    finishFunc();
//                }});
                finishFunc();

                // 红线出来
                // var toX:int =
                winBox.visible = true;
                _moveLine1(action, finishFunc);
                _playWinEffect(action, finishFunc);
            }});
        };
        delayCall(showRole1, action.duringTime*0.1);
    }

    // 左边线出来
    private function _moveLine1(action:CMovieAction, finishFunc:Function) : void {
        line1.visible = true;
        line1.x =  - line1.width;
        TweenLite.to(line1, action.duringTime * 0.07, {x : _basePosList[5].x, onComplete : function () : void {
            finishFunc();
        }});
    }
    // 播放胜利动画
    private function _playWinEffect(action:CMovieAction, finishFunc:Function) : void {
        if (_rootView.isForceStop) {
            forceFinish();
            return
        }

        winEffect.visible = true;

        var effectFinish:Function = function () : void {
            winEffect.visible = false;
            (winEffect as FrameClip).stop();
            line2.visible = true;
            win.visible = true;

            // finishFunc(); 胜利动作完成太久了
        };

        // 胜利动画
        (winEffect as FrameClip).playFromTo(null, null, new Handler(effectFinish));

        // 说话
        delayCall(_sayStep, action.duringTime*0.2, action, finishFunc);
    }

    private function _sayStep(action:CMovieAction, finishFunc:Function) : void {
        if (_rootView.isForceStop) {
            forceFinish();
            return
        }

        sayBg.visible = true;
        sayBg.alpha = 0;
        // 背景从透明变成不透明
        TweenLite.to(sayBg, action.duringTime * 0.04, {alpha : 1, onComplete : function () : void {
            // 背景滤镜从白色到透明
            sayBgWhite.visible = true;
            sayBgWhite.filters = FilterUtil.ALL_WHITE_FILTER;
            sayBgWhite.alpha = 1;
            TweenLite.to(sayBgWhite, action.duringTime * 0.03, {alpha : 0, onComplete : function () : void {
                sayBgWhite.filters = null;
                sayBgWhite.visible = false;
                // 出字
                _sayStepB(action, finishFunc);
            }});
        }});
    }
    private function _sayStepB(action:CMovieAction, finishFunc:Function) : void {
        sayMask1.width = 1;
        sayMask2.width = 1;
        say1.visible = true;
        say2.visible = true;

        var say2Txt:Label = say2 as Label;
        if (say2Txt.text && say2Txt.text.length > 0) {
            TweenLite.to(sayMask1, action.duringTime * 0.20, {width : say1.width + 20, onComplete : function () : void {
                TweenLite.to(sayMask2, action.duringTime * 0.20, {width : say2.width + 20, onComplete : function () : void {
                    finishFunc();
                }});
            }});
        } else {
            TweenLite.to(sayMask1, action.duringTime * 0.20, {width : say1.width + 20, onComplete : function () : void {
                finishFunc();
            }});
        }

    }
}
}
