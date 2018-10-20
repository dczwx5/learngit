//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/4/19.
 */
package kof.game.common.uiMovie {

import flash.geom.Point;
import kof.game.common.view.CViewBase;
import kof.game.common.view.component.CUICompoentBase;

import morn.core.components.Component;
public class CMovieCompoentBase extends CUICompoentBase {


    public function CMovieCompoentBase(dispatcher:CViewBase, componentList:Vector.<Component>, endFunc:Function) {
        super (dispatcher);
        _dispatcher = dispatcher;
        _endFunc = endFunc;
        _imageList = componentList;
        _basePosList = new Vector.<Point>(componentList.length);
        for (var i:int = 0; i < componentList.length; i++) {
            _basePosList[i] = new Point(componentList[i].x, componentList[i].y);
        }
        _actionList = new Vector.<CMovieAction>();
    }
    public override function dispose() : void {
        super.dispose();
        _dispatcher = null;
        _endFunc = null;
        _basePosList = null;
        _curAction = null;
        _actionList = null;
        _isDisposed = true;
    }

    protected virtual function _initial() : void {
        // add action
        // init object
        throw new Error("need to override _initial");
    }
    public function start() : void {
        if (_isDisposed) return ;

        _initial();
        for (var i:int = 0; i < _actionList.length; i++) {
            if (i+1 < _actionList.length) {
                _actionList[i].next = _actionList[i+1];
            } else {
                _actionList[i].next = null;
            }
        }

        _curAction = _actionList.shift();

        _curAction.call();
    }

    protected function _normalAction(action:CMovieAction) : void {
        var fun:Function = function() : void {
            _nextAction(action);
        };
        delayCall(fun, action.duringTime);
    }

    protected function _nextAction(action:CMovieAction) : void {
        _curAction = action.next;
        if (_curAction) {
            _curAction.call();
        } else {
            if (_endFunc) _endFunc.apply();
        }
    }

    public function forceFinish() : void {
        if (_endFunc) {
            _endFunc.apply();
        }
    }
    protected var _endFunc:Function;
    protected var _imageList:Vector.<Component>;
    protected var _basePosList:Vector.<Point>;
    protected var _actionList:Vector.<CMovieAction>;
    protected var _curAction:CMovieAction;
    protected var _dispatcher:CViewBase;

    protected var _isDisposed:Boolean;
}
}
