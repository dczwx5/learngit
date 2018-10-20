//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/10/13.
 */
package kof.game.common.view.component {

import com.greensock.TweenLite;
import flash.events.Event;

import kof.game.common.view.CViewBase;

import morn.core.components.Box;
import morn.core.components.List;

public class CListItemShowEffectCompoent extends CUICompoentBase {

    public function CListItemShowEffectCompoent(view:CViewBase, list:List, startFunc:Function, endFunc:Function, playTime:Number = 1.0) {
        super(view);
        _list = list;
        _playTime = playTime;
        _startFunc = startFunc;
        _endFunc = endFunc;
        _curIndex = 0;
        _isPlaying = false;
        for each (var item:Box in _list.cells) {
            item.alpha = 0.0;
        }

        if (_playTime > 0 == false) {
            if (_startFunc) _startFunc.apply(null, null);
            if (_endFunc) _endFunc.apply(null, null);
        } else {
            if (_startFunc) _startFunc.apply(null, null);
            _onTick(null);
        }
    }
    public override function dispose() : void {
        super.dispose();
        _list = null;
    }
    public override function clear() : void {
        super.clear();

    }

    private function _onTick(e:Event) : void {
        if (_isFinish) return ;

        if (_isPlaying == false) {
            var cell:Box = _list.cells[_curIndex];
            _isPlaying = true;
            TweenLite.to(cell, 0.1, {alpha:1, onComplete:function () : void {
                _curIndex++;
                _isPlaying = false;
                if (_curIndex >= _list.repeatX) {
                    _end();
                } else {
                    _onTick(null);
                }
            }});
        }

    }

    private function _end() : void {
        _isFinish = true;
        if (_endFunc) _endFunc.apply(null, null);
    }

    private var _curIndex:int;
    private var _isPlaying:Boolean;
    private var _isFinish:Boolean;
    private var _list:List;
    private var _playTime:Number;
    private var _startFunc:Function; // function (idx:int);
    private var _endFunc:Function; // function (idx:int);

    // private var _timer:Timer;

}
}
