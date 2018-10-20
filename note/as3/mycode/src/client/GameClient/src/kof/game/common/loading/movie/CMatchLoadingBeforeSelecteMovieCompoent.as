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

public class CMatchLoadingBeforeSelecteMovieCompoent extends CMovieCompoentBase {

    private var _blackSort:Component;
    private var _whiteSort:Component;
    private var _sort:Component;
    private var _leftSelect:Component;
    private var _rightSelect:Component;
    private var _selectBlack:Component;
    private var _selectBlack2:Component;
    public function CMatchLoadingBeforeSelecteMovieCompoent(dispatcher:CViewBase, componentList:Vector.<Component>, endFunc:Function) {
        super (dispatcher, componentList, endFunc);

        _blackSort = componentList[0];
        _whiteSort = componentList[1];
        _sort = componentList[2];
        _leftSelect = componentList[3];
        _rightSelect = componentList[4];
        _selectBlack = componentList[5];
        _selectBlack2 = componentList[6];


    }
    public override function dispose() : void {
        super.dispose();
    }

    protected override function _initial() : void {
        // start
        _imageList[3].setPosition(_basePosList[3].x - 600, _basePosList[3].y);
        _imageList[4].setPosition(_basePosList[4].x + 600, _basePosList[4].y);

        // action列表
        _actionList.push(new CMovieAction(_actionMove, 0.3));
        _actionList.push(new CMovieAction(_actionBlack, 0.1));
        _actionList.push(new CMovieAction(_actionHideBlack, 0.1));
    }

    private function _actionMove(action:CMovieAction) : void {
        var count:int = 0;
        var isFinish:Boolean = false;
        var checkFunc:Function  = function () : void {
            if (count == 3 && isFinish == false) {
                isFinish = true;
                _nextAction(action);
            }
        };

        _whiteSort.visible = true;
        var sortFunc1:Function = function() : void {
            _whiteSort.visible = false;

            _blackSort.visible = true;
            var sortFunc2:Function = function() : void {
                _sort.visible = true;
                count++;
                checkFunc();
            };
            delayCall(sortFunc2, action.duringTime/5);
        };
        delayCall(sortFunc1, action.duringTime/5);

        _leftSelect.visible = _rightSelect.visible = true;
        // 左右两个select移动
        TweenLite.to(_leftSelect, action.duringTime, {x:_basePosList[3].x + 100, onComplete:function () : void {
            count++;
            checkFunc();
        }});
        TweenLite.to(_rightSelect, action.duringTime, {x:_basePosList[4].x - 100, onComplete:function () : void {
            count++;
            checkFunc();
        }});
    }
    private function _actionBlack(action:CMovieAction) : void {
        _selectBlack.visible = true;
        _selectBlack2.visible = true;
        _leftSelect.x = _basePosList[3].x;
        _rightSelect.x = _basePosList[4].x;
        var fun:Function = function() : void {
            _nextAction(action);
        };

        delayCall(fun, action.duringTime);
    }
    private function _actionHideBlack(action:CMovieAction) : void {
        _selectBlack.visible = false;
        _selectBlack2.visible = false;
        _nextAction(action);
    }
}
}
