//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/2/5.
 */
package kof.game.common.view {


import morn.core.components.ProgressBar;

public class CProgressBarMovie {
    // barBottom : 有底, 在最下层
    // barMiddle : 白色进度效果, 中间层, 无底
    // barTop : 无底, 用于遮挡白色进度的前段部分
    // valueLast : 变化之前的值
    // valueNew : 变化最后的值
    // isLevelUp : 是否有升级
    // playTime : 单位秒
    // levelUpCallback : 如果有升级, 播放到升级时回调
    // finishcallback : 播放完回调
    public function CProgressBarMovie(barBottom:ProgressBar, barMiddle:ProgressBar, barTop:ProgressBar,
                                      valueLast:Number, valueNew:Number, isLevelUp:Boolean, playTime:Number = 1.0,
                                      levelUpCallback:Function = null, finishCallback:Function = null) {

        _barBottom = barBottom;
        _barMiddle = barMiddle;
        _barTop = barTop;
        _valueLast = valueLast;
        _valueNew = valueNew;
        _isLevelUp = isLevelUp;
        _playTime = playTime;
        _callback = finishCallback;
        _levelUpCallback = levelUpCallback;

        start();
    }

    public function start() : void {
        _barBottom.value = _valueLast;
        _barTop.value = _valueLast;
        _barMiddle.value = _valueLast;

        if (_isLevelUp) {
            tween(_barMiddle, 1.0, _playTime/2, function () : void {
                _barBottom.value = 0.0;
                _barTop.value = 0.0;
                _barMiddle.value = 0.0;
                if (_levelUpCallback) {
                    _levelUpCallback();
                }
                tween(_barMiddle, _valueNew, _playTime/2, _callback);
            });
        } else {
            tween(_barMiddle, _valueNew, _playTime, _callback);
        }
    }

    private function tween(bar:ProgressBar, targetValue:Number, playTime:Number, callback:Function = null) : void {
        new BarMovie(bar, targetValue, playTime, callback);
    }


    private var _barBottom:ProgressBar; // 有底, 显示变化之前的经验
    private var _barMiddle:ProgressBar; // white 无底, 用于显示经验增长动画
    private var _barTop:ProgressBar; // 无底. 用于遮挡white

    private var _valueLast:Number;
    private var _valueNew:Number;
    private var _isLevelUp:Boolean;

    private var _playTime:Number;
    private var _callback:Function;
    private var _levelUpCallback:Function;
}
}

import flash.display.Stage;
import flash.events.Event;
import flash.utils.getTimer;

import morn.core.components.ProgressBar;

class BarMovie {
    private var _bar:ProgressBar;
    private var _targetValue:Number;
    private var _callback:Function;
    private var _startTime:int;
    private var _playTotalTime:Number; // second
    public function BarMovie(bar:ProgressBar, targetValue:Number, playTotalTime:Number, callback:Function = null) {
        var flashStage : Stage = bar.stage;
        if ( !flashStage ) {
            return;
        }

        _bar = bar;
        _targetValue = targetValue;
        _callback = callback;
        _playTotalTime = playTotalTime;
        if (_playTotalTime <= 0) {
            bar.value = targetValue;
            if (callback) {
                callback();
            }
        } else {
            _startTime = getTimer();
            flashStage.addEventListener( Event.ENTER_FRAME, _onUpdate );
        }
    }



    private function _onUpdate(e:Event) : void {
        var flashStage : Stage = _bar.stage;
        var startValue:Number = _bar.value;
        var subValue:Number = _targetValue - _bar.value;

        var curTime:int = getTimer();
        var timePercent:Number = (curTime - _startTime)/(_playTotalTime * 1000);

        var curValue:Number = startValue + timePercent * subValue;
        if (curValue >= _targetValue) {
            flashStage.removeEventListener( Event.ENTER_FRAME, _onUpdate );
            curValue = _targetValue;
            _bar.value = curValue;
            if (_callback) {
                _callback();
            }
            // end
        } else {
            _bar.value = curValue;
        }

    }
}
