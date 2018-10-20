//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/21.
 */
package kof.game.common.view.component {


import flash.utils.getTimer;

import kof.game.common.view.CViewBase;

import morn.core.components.Button;

import morn.core.components.Label;

public class CCountDownCompoent extends CUICompoentBase {
    // coundDownBox - 显示倒计时文本的组件, 可以是label or btn
    // prefix, suffix - coundDown text 的前缀和后缀内容
    public function CCountDownCompoent(view:CViewBase, coundDownBox:*, millisecond:int, endFunc:Function, prefix:String = null, suffix:String = null) {
        super (view);
        _countDown = coundDownBox;
        _endFunc = endFunc;
        _millisecond = millisecond;
        _prefix = prefix;
        _suffix = suffix;
        _startTime = getTimer();
        _isEnd = false;
    }
    public override function dispose() : void {
        super.dispose();
    }
    public function tick() : void {
        if (_isEnd) return ;

        var passTime:int = getTimer() - _startTime;
        passTime /= 1000;

        var countDown:int = _millisecond/1000 - passTime;
        var text:String = countDown.toString();
        if (_prefix) text = _prefix + text;
        if (_suffix) text += _suffix;

        if (_countDown is Label) {
            var txt:Label = _countDown as Label;
            txt.text = text;
        } else if (_countDown is Button) {
            var btn:Button = _countDown as Button;
            btn.btnLabel.text = text;
        }


        if (countDown < 0) {
            if (_countDown) _countDown.visible = false;
            _isEnd = true;
            if (_endFunc) _endFunc();
        } else {
            if (_countDown) _countDown.visible = true;
        }
    }

    private var _countDown:*;
    private var _startTime:int;
    private var _isEnd:Boolean;
    private var _millisecond:int;
    private var _prefix:String;
    private var _suffix:String;

    private var _endFunc:Function; // function (idx:int);

}
}
