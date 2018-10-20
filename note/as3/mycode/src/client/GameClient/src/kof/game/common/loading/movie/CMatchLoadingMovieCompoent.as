//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/4/18.
 */
package kof.game.common.loading.movie {

import com.greensock.TweenLite;
import flash.geom.Point;

import kof.game.common.uiMovie.CMovieCompoentBase;

import kof.game.common.uiMovie.CMovieAction;
import kof.game.common.view.CViewBase;

import morn.core.components.Component;

public class CMatchLoadingMovieCompoent extends CMovieCompoentBase {
    private var _heroBox:Component;
    public function CMatchLoadingMovieCompoent(dispatcher:CViewBase, componentList:Vector.<Component>, endFunc:Function) {
        super (dispatcher, componentList, endFunc);
        _heroBox = componentList[3];
    }
    public override function dispose() : void {
        super.dispose();
    }

    protected override function _initial() : void {
        // start
        _imageList[0].filters = null;
        _imageList[1].filters = null;
        _imageList[2].filters = null;
        _imageList[0].setPosition(_basePosList[1].x, _basePosList[0].y - 600);
        _imageList[1].setPosition(_basePosList[2].x, _basePosList[0].y - 600);
        _imageList[2].setPosition(_basePosList[0].x, _basePosList[0].y - 600);

        // 掉下来的顺序列表
        step1DownList = new Vector.<Component>(3);
        step1DownList[0] = _imageList[1];
        step1DownList[1] = _imageList[0];
        step1DownList[2] = _imageList[2];

        _actionList.push(new CMovieAction(_actionDown1, 0.2));
        _actionList.push(new CMovieAction(_actionDownUp1, 0.02));
        _actionList.push(new CMovieAction(_actionDown2, 0.1));
        _actionList.push(new CMovieAction(_actionDown3, 0.1));
        _actionList.push(new CMovieAction(_actionDownUp3, 0.02));
    }

    private function _actionDown1(action:CMovieAction) : void {
        _heroBox.visible = true;
        _actionDownB(action, 0, _basePosList[2]);
    }
    private function _actionDown2(action:CMovieAction) : void {
        _actionDownB(action, 1, _basePosList[1]);
    }
    private function _actionDown3(action:CMovieAction) : void {
        _actionDownB(action, 2, _basePosList[0]);
    }
    private function _actionDownB(action:CMovieAction, index:int, tarPos:Point) : void {
        var toY:int = tarPos.y;
        if (index == 0 || index == 2) {
            toY += 30;
        }
        TweenLite.to(step1DownList[index], action.duringTime, {y:toY, onComplete:function () : void {
            _nextAction(action);
        }});
    }
    private function _actionDownUp1(action:CMovieAction) : void {
        _actionDownUp(action, 0);
    }
    private function _actionDownUp3(action:CMovieAction) : void {
        _actionDownUp(action, 2);
    }
    private function _actionDownUp(action:CMovieAction, index:int) : void {
        var toY:int = _basePosList[2-index].y;
        TweenLite.to(step1DownList[index], action.duringTime, {y:toY, onComplete:function () : void {
            _nextAction(action);
        }});
    }

    private var step1DownList:Vector.<Component>; // 顺序列表
}
}
