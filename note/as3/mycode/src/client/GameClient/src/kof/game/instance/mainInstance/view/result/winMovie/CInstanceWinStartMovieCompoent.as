//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/4/29.
 */
package kof.game.instance.mainInstance.view.result.winMovie {

import com.greensock.TweenLite;

import kof.game.common.uiMovie.CMovieCompoentBase;

import kof.game.common.uiMovie.CMovieAction;
import kof.game.common.view.CViewBase;

import morn.core.components.Component;

public class CInstanceWinStartMovieCompoent extends CMovieCompoentBase {
    private var _up:Component;
    private var _down:Component;
    public function CInstanceWinStartMovieCompoent(dispatcher:CViewBase, componentList:Vector.<Component>, endFunc:Function) {
        super (dispatcher, componentList, endFunc);
        _up = componentList[0];
        _down = componentList[1];
    }
    public override function dispose() : void {
        super.dispose();
    }
    protected override function _initial() : void {
        _actionList.push(new CMovieAction(_actionDownUp, 0.3));
    }
    private function _actionDownUp(action:CMovieAction) : void {
        var count:int = 0;
        var isFinish:Boolean = false;
        var checkFunc:Function = function () : void {
            if (count == 2 && isFinish == false) {
                isFinish = true;
                _nextAction(action);
            }
        };

        _up.visible = true;
        _down.visible = true;
        var upToY:int = _up.y + _up.height;
        var downToY:int = _down.y - _down.height;
        TweenLite.to(_up, action.duringTime, {y:upToY, onComplete:function () : void {
            count++;
            checkFunc();
        }});

        TweenLite.to(_down, action.duringTime, {y:downToY, onComplete:function () : void {
            count++;
            checkFunc();
        }});
    }
}
}
