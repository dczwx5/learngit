//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/6/21.
 */
package kof.game.story.view.CStoryWinView {

import QFLib.Utils.FilterUtil;

import com.greensock.TweenLite;

import kof.framework.CAppSystem;

import kof.game.audio.IAudio;

import kof.game.common.uiMovie.CMovieCompoentBase;

import kof.game.common.uiMovie.CMovieAction;
import kof.game.common.view.CViewBase;
import kof.game.instance.config.CInstancePath;

import morn.core.components.Component;
import morn.core.components.FrameClip;
import morn.core.components.Label;
import morn.core.handlers.Handler;

public class CStoryWinShowRoleMovieCompoent extends CMovieCompoentBase {
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
    private var _rootView:CStoryWinMovieProcess;
    private var sayBox:Component;

    public function CStoryWinShowRoleMovieCompoent( dispatcher:CViewBase, componentList:Vector.<Component>, endFunc:Function, rootView:CStoryWinMovieProcess) {
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
        sayBox = componentList[16];


    }
    public override function dispose() : void {
        super.dispose();
    }
    protected override function _initial() : void {
        if (_rootView.isForceStop) {
            forceFinish();
            return
        }

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

        _teamerMove(action, checkFunc);
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
                finishFunc();

                // 红线出来
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
                    delayCall(_teamerMoveLeft, action.duringTime*0.06, action, finishFunc); // 主角左移
                    trace("________________________主角左移_____________1")
                }});
            }});
        } else {
            TweenLite.to(sayMask1, action.duringTime * 0.20, {width : say1.width + 20, onComplete : function () : void {
                finishFunc();
                delayCall(_teamerMoveLeft, action.duringTime*0.06, action, finishFunc); // 主角左移
                trace("________________________主角左移_____________2")
            }});
        }
    }

    private function _teamerMoveLeft(action:CMovieAction, finishFunc:Function) : void {
        if (_rootView.isForceStop) {
            forceFinish();
            return
        }

        // 人物移动
        var tox:int = _basePosList[1].x - 200;
        trace("________________________tox : " + tox);
        TweenLite.to(role1, action.duringTime*0.10, {x:tox, onComplete:function () : void {
            finishFunc();        trace("________________________role1.x : " + role1.x);

        }});
        var audio:IAudio = (viewBase.uiCanvas as CAppSystem).stage.getSystem(IAudio) as IAudio;
        audio.playAudioByPath(CInstancePath.getAudioPath(CInstancePath.PVE_RESULT_ROLE_AUDIO_NAME), 1);

        // 对话隐藏
        sayBox.alpha = 1;
        TweenLite.to(sayBox, action.duringTime*0.10, {alpha:0, onComplete:function () : void {
            finishFunc();
        }});

    }
}
}
