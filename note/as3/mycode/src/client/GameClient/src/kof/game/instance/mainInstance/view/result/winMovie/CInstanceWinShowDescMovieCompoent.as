//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/4/29.
 */
package kof.game.instance.mainInstance.view.result.winMovie {

import com.greensock.TweenLite;
import com.greensock.easing.Bounce;

import flash.events.IEventDispatcher;
import flash.geom.Point;

import kof.framework.CAppSystem;

import kof.game.audio.IAudio;

import kof.game.common.uiMovie.CMovieCompoentBase;

import kof.game.common.uiMovie.CMovieAction;
import kof.game.common.view.CViewBase;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.config.CInstancePath;
import kof.game.instance.enum.EInstanceType;
import kof.game.instance.mainInstance.view.result.CInstanceWinMovieProcess;
import kof.game.instance.mainInstance.view.result.CInstanceWinView;

import morn.core.components.Component;

public class CInstanceWinShowDescMovieCompoent extends CMovieCompoentBase {
    private var role1:Component;
    private var role2:Component;
    private var role3:Component;
    private var sayBox:Component;
    private var descUI:Component;
    private var condEffect1:Component;
    private var condEffect2:Component;
    private var condEffect3:Component;
    private var starEffect1:Component;
    private var starEffect2:Component;
    private var starEffect3:Component;
    private var condItem1:Component;
    private var condItem2:Component;
    private var condItem3:Component;
    private var starBox:Component;
    private var _rootView:CInstanceWinMovieProcess;

    public function CInstanceWinShowDescMovieCompoent(dispatcher:CViewBase, componentList:Vector.<Component>, endFunc:Function, rootView:CInstanceWinMovieProcess) {
        super (dispatcher, componentList, endFunc);

        _rootView = rootView;

        role1 = componentList[0];
        role2 = componentList[1];
        role3 = componentList[2];
        sayBox = componentList[3];
        descUI = componentList[4];

        condEffect1 = componentList[6];
        condEffect2 = componentList[7];
        condEffect3 = componentList[8];
        starEffect1 = componentList[9];
        starEffect2 = componentList[10];
        starEffect3 = componentList[11];
        condItem1 = componentList[12];
        condItem2 = componentList[13];
        condItem3 = componentList[14];
        starBox = componentList[15];
    }
    public override function dispose() : void {
        super.dispose();
    }
    protected override function _initial() : void {
        if (_rootView.isForceStop) {
            forceFinish();
            return ;
        }

        _actionList.push(new CMovieAction(_actionMove, 3));
    }
    private function _actionMove(action:CMovieAction) : void {
        if (_rootView.isForceStop) {
            forceFinish();
            return
        }

        var count:int = 0;
        var isFinish:Boolean = false;
        var checkFunc:Function = function () : void {
            count++;
            if (count == 9 && isFinish == false) {
                isFinish = true;
                _nextAction(action);
            }
        };

        _teamHeroMove(action, checkFunc);
    }
    private function _teamHeroMove(action:CMovieAction, finishFunc:Function) : void {
        if (_rootView.isForceStop) {
            forceFinish();
            return
        }

        var role2ToX:int = _basePosList[1].x - 600;
        var role3ToX:int = _basePosList[2].x + 600;

        // 队友出现
        TweenLite.to(role2, action.duringTime*0.10, {x:role2ToX, onComplete:function () : void {
            role2.visible = false;
            finishFunc();
        }});

        TweenLite.to(role3, action.duringTime*0.10, {x:role3ToX, onComplete:function () : void {
            role3.visible = false;
            finishFunc();
        }});
        delayCall(_teamerMove, action.duringTime*0.06, action, finishFunc);
    }
    private function _teamerMove(action:CMovieAction, finishFunc:Function) : void {
        if (_rootView.isForceStop) {
            forceFinish();
            return
        }

        // 人物移动
        var tox:int = _basePosList[0].x - 200;
        TweenLite.to(role1, action.duringTime*0.10, {x:tox, onComplete:function () : void {
            finishFunc();
        }});
        var audio:IAudio = (viewBase.uiCanvas as CAppSystem).stage.getSystem(IAudio) as IAudio;
        audio.playAudioByPath(CInstancePath.getAudioPath(CInstancePath.PVE_RESULT_ROLE_AUDIO_NAME), 1);

        // 对话隐藏
        sayBox.alpha = 1;
        TweenLite.to(sayBox, action.duringTime*0.10, {alpha:0, onComplete:function () : void {
            finishFunc();
        }});

        // 详细信息出现
         delayCall(_shpwDesc, action.duringTime*0.03, action, finishFunc);
    }
    private function _shpwDesc(action:CMovieAction, finishFunc:Function) : void {
        if (_rootView.isForceStop) {
            forceFinish();
            return
        }

        descUI.visible = true;
        finishFunc();

        var win : CInstanceWinView = _dispatcher as CInstanceWinView;
        var pInstanceSystem : CInstanceSystem = win.system.stage.getSystem( CInstanceSystem ) as CInstanceSystem;
        var needShowStarEffect : Boolean = !(EInstanceType.isMainExtra( pInstanceSystem.instanceType ));
        if (needShowStarEffect) {
            // 需要显示星星
            delayCall(_showStar, action.duringTime*0.06, action, finishFunc);
        } else {
            // 不需要显示星星
            finishFunc();
            finishFunc();
            finishFunc();
            finishFunc();
        }

    }

    private function _showStar(action:CMovieAction, finishFunc:Function) : void {
        if (_rootView.isForceStop) {
            forceFinish();
            return
        }

        starBox.visible = true;
        starBox.x = 1550;
        TweenLite.to(starBox, action.duringTime*0.06, {x:_basePosList[15].x, onComplete:function () : void {
            finishFunc();
        }});
        delayCall(_showCond1, action.duringTime*0.025, action, finishFunc);
        delayCall(_showCond2, action.duringTime*0.06, action, finishFunc);
        delayCall(_showCond3, action.duringTime*0.085, action, finishFunc);
    }
    private function _showCond1(action:CMovieAction, finishFunc:Function) : void {
        condItem1.visible = true;
        condItem1.x = 1550;
        TweenLite.to(condItem1, action.duringTime*0.06, {x:_basePosList[12].x, onComplete:function () : void {
            finishFunc();
        }, ease:Bounce.easeOut});
    }
    private function _showCond2(action:CMovieAction, finishFunc:Function) : void {
        condItem2.visible = true;
        condItem2.x = 1550;
        TweenLite.to(condItem2, action.duringTime*0.06, {x:_basePosList[13].x, onComplete:function () : void {
            finishFunc();
        }, ease:Bounce.easeOut});
    }
    private function _showCond3(action:CMovieAction, finishFunc:Function) : void {
        condItem3.visible = true;
        condItem3.x = 1550;
        TweenLite.to(condItem3, action.duringTime*0.05, {x:_basePosList[14].x, onComplete:function () : void {
            finishFunc();
        }, ease:Bounce.easeOut});
    }
}
}
