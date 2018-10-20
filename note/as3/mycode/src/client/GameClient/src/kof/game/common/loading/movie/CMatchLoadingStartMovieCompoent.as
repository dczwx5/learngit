//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/4/18.
 */
package kof.game.common.loading.movie {

import com.greensock.TweenLite;
import kof.game.common.uiMovie.CMovieCompoentBase;
import kof.game.common.uiMovie.CMovieAction;
import kof.game.common.view.CViewBase;

import morn.core.components.Component;
public class CMatchLoadingStartMovieCompoent extends CMovieCompoentBase {

    private var _black:Component;
    private var _left:Component;
    private var _right:Component;
    private var _vsBlack:Component;
    private var _vsWhite:Component;
    private var _vsRed:Component;
    private var _vs:Component;
    private var _bg1:Component;
    private var _bg2:Component;
    public function CMatchLoadingStartMovieCompoent(dispatcher:CViewBase, componentList:Vector.<Component>, endFunc:Function) {
        super (dispatcher, componentList, endFunc);

        _black = componentList[0];
        _left = componentList[1];
        _right = componentList[2];
        _vsBlack = componentList[3];
        _vsWhite = componentList[4];
        _vsRed = componentList[5];
        _vs = componentList[6];
        _bg1 = componentList[7];
        _bg2 = componentList[8];

    }
    public override function dispose() : void {
        super.dispose();
    }

    protected override function _initial() : void {
        // start
        _imageList[1].setPosition(_basePosList[1].x - 600, _basePosList[1].y);
        _imageList[2].setPosition(_basePosList[2].x + 600, _basePosList[2].y);

        // action列表
        _actionList.push(new CMovieAction(_actionHideBlack, 0.1));
        _actionList.push(new CMovieAction(_actionMove1, 0.2));
        _actionList.push(new CMovieAction(_actionMove2, 0.1));
        _actionList.push(new CMovieAction(_actionMove3, 0.1));
        _actionList.push(new CMovieAction(_showVSBlack, 0.03));
        _actionList.push(new CMovieAction(_showVSWhite, 0.03));
        _actionList.push(new CMovieAction(_showVSRed, 0.03));
        _actionList.push(new CMovieAction(_showVS, 0.03));
        _actionList.push(new CMovieAction(_scaleVSDown, 0.01));
        _actionList.push(new CMovieAction(_scaleVSUp, 0.01));

    }

    private function _actionHideBlack(action:CMovieAction) : void {
        var fun:Function = function() : void {
            _black.visible = false;
            _nextAction(action);
        };
        delayCall(fun, action.duringTime);
    }
    private function _actionMove1(action:CMovieAction) : void {
        _left.visible = true;
        _right.visible = true;
        _bg1.visible = true;
        _bg2.visible = true;
        var deltaX:int = 250;
        var count:int = 0;
        var isFinish:Boolean = false;
        TweenLite.to(_left, action.duringTime, {x:_basePosList[1].x + deltaX, onComplete:function () : void {
            count++;
            if (count == 2 && isFinish == false) {
                isFinish = true;
                _nextAction(action);
            }
        }});
        TweenLite.to(_right, action.duringTime, {x:_basePosList[2].x - deltaX, onComplete:function () : void {
            count++;
            if (count == 2 && isFinish == false) {
                isFinish = true;
                _nextAction(action);
            }
        }});
    }
    private function _actionMove2(action:CMovieAction) : void {
        var deltaX:int = 200;
        var count:int = 0;
        var isFinish:Boolean = false;
        TweenLite.to(_left, action.duringTime, {x:_basePosList[1].x - deltaX, onComplete:function () : void {
            count++;
            if (count == 2 && isFinish == false) {
                isFinish = true;
                _nextAction(action);
            }
        }});
        TweenLite.to(_right, action.duringTime, {x:_basePosList[2].x + deltaX, onComplete:function () : void {
            count++;
            if (count == 2 && isFinish == false) {
                isFinish = true;
                _nextAction(action);
            }
        }});
    }
    private function _actionMove3(action:CMovieAction) : void {
        var deltaX:int = 0;
        var count:int = 0;
        var isFinish:Boolean = false;
        TweenLite.to(_left, action.duringTime, {x:_basePosList[1].x - deltaX, onComplete:function () : void {
            count++;
            if (count == 2 && isFinish == false) {
                isFinish = true;
                _nextAction(action);
            }
        }});
        TweenLite.to(_right, action.duringTime, {x:_basePosList[2].x + deltaX, onComplete:function () : void {
            count++;
            if (count == 2 && isFinish == false) {
                isFinish = true;
                _nextAction(action);
            }
        }});
    }
    private function _showVSBlack(action:CMovieAction) : void {
        _vsBlack.visible = true;
        var fun:Function = function() : void {
            _vsBlack.visible = false;
            _nextAction(action);
        };
        delayCall(fun, action.duringTime);
    }
    private function _showVSWhite(action:CMovieAction) : void {
        _vsWhite.visible = true;
        var fun:Function = function() : void {
            _nextAction(action);
        };
        delayCall(fun, action.duringTime);
    }
    private function _showVSRed(action:CMovieAction) : void {
        var count:int = 0;
        var isFinish:Boolean = false;
        var fun:Function = function() : void {
            _vsRed.visible = false;
            _vsWhite.visible = false;
            _nextAction(action);
        };
        TweenLite.to(_vsWhite, action.duringTime/2, {scale:0.5, onComplete:function () : void {
            count++;
            if (count == 2 && isFinish == false) {
                isFinish = true;
                fun();
            }
        }});

        _vsRed.visible = true;
        var redFun:Function = function() : void {
            count++;
            if (count == 2 && isFinish == false) {
                isFinish = true;
                fun();
            }
        };
		delayCall(redFun, action.duringTime);    }
    private function _showVS(action:CMovieAction) : void {
        _vs.visible = true;
        var fun:Function = function() : void {
            _nextAction(action);
        };
        delayCall(fun, action.duringTime);
    }
    private function _scaleVSDown(action:CMovieAction) : void {
        _vs.visible = true;
        TweenLite.to(_vs, action.duringTime, {scale:0.5, onComplete:function () : void {
            _nextAction(action);
        }});
    }
    private function _scaleVSUp(action:CMovieAction) : void {
        TweenLite.to(_vs, action.duringTime, {scale:1, onComplete:function () : void {
            _nextAction(action);
        }});
    }
}
}
