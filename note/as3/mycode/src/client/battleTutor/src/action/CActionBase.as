//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/8.
 */
package action {

import QFLib.Foundation.CMap;

import avmplus.getQualifiedClassName;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.utils.getTimer;

import kof.framework.CAppSystem;
import kof.game.Tutorial.battleTutorPlay.CBattleTutorData;

import kof.game.core.CGameObject;

import morn.core.handlers.Handler;

public class CActionBase extends EventDispatcher {

    public function CActionBase() {
        externData = new CMap();
    }

    public virtual function dispose() : void {
        _pBattleTutor = null;
        _pHero = null;
        _pTutorData = null;
        _isStart = false;

        _passHandlerList = null;
        _startHandlerList = null;
        _updateHandlerList = null;

        if (_finishHandlerList) {
            for (var i:int = 0; i < _finishHandlerList.length; i++) {
                _finishHandlerList[i].execute();
            }
            _finishHandlerList = null;
        }
    }

    public virtual function start() : void {
        log(getQualifiedClassName(this), "start : index : " + index);
        _isStart = true;
        _startTime = getTimer();

        if (_startHandlerList) {
            for (var i:int = 0; i < _startHandlerList.length; i++) {
                _startHandlerList[i].execute();
            }
        }
    }
    public function update() : void {
        if (!_isStart || _isFinish) {
            return ;
        }

        if (_updateHandlerList && _updateHandlerList.length) {
            for (var i:int = 0; i < _updateHandlerList.length; i++) {
                _updateHandlerList[i].execute();
            }
        }

        if (_passHandlerList && _passHandlerList.length > 0) {
            if (_passHandlerList[0].method.apply(null, _passHandlerList[0].args)) {
                if (_passHandlerList) {
                    _passHandlerList.shift();
                }
            }
        }
        if (_passHandlerList == null || _passHandlerList.length == 0) {
            _isFinish = true;
        }

        if (_isFinish) {
            this.end();
        }
    }
    // 所有动作找时机调用end, 结束动作
    public function end() : void {
        log(getQualifiedClassName(this), "end");
        // 主动调用结束
        this.dispatchEvent(new Event(Event.COMPLETE));
    }

    [Inline]
    public function get hero() : CGameObject {
        if (_pHero == null) {
            _pHero = _pBattleTutor.actorHelper.hero;
        }
        return _pHero;
    }

    public function get passTime() : int {
        return getTimer() - _startTime;
    }
    public function resetStartTime() : Boolean {
        _startTime = getTimer();
        return true;
    }

    public function addStartHandler(handler:Handler) : void {
        if (!_startHandlerList) _startHandlerList = new Vector.<Handler>();
        _startHandlerList[_startHandlerList.length] = handler;
    }
    public function addFinishHandler(handler:Handler) : void {
        if (!_finishHandlerList) _finishHandlerList = new Vector.<Handler>();
        _finishHandlerList[_finishHandlerList.length] = handler;
    }
    public function addPassHandler(handler:Handler) : void {
        if (!_passHandlerList) _passHandlerList = new Vector.<Handler>();
        _passHandlerList[_passHandlerList.length] = handler;
    }
    public function addUpdateHandler(handler:Handler) : void {
        if (!_updateHandlerList) _updateHandlerList = new Vector.<Handler>();
        _updateHandlerList[_updateHandlerList.length] = handler;
    }

    [Inline]
    public function get system() : CAppSystem { return _pSystem; }
    [Inline]
    public function set system(value : CAppSystem) : void { _pSystem = value; }
    [Inline]
    public function get tutorData() : CBattleTutorData { return _pTutorData; }
    [Inline]
    public function set tutorData(value : CBattleTutorData) : void { _pTutorData = value; }
    [Inline]
    public function get battleTutor():CBattleTutor { return _pBattleTutor; }
    [Inline]
    public function set battleTutor(value:CBattleTutor):void { _pBattleTutor = value; }

    protected var _isStart:Boolean;
    private var _pHero:CGameObject;
    protected var _isFinish:Boolean;

    public function get isFinish():Boolean {
        return _isFinish;
    }

    private var _pSystem:CAppSystem;
    private var _pTutorData:CBattleTutorData;
    private var _pBattleTutor:CBattleTutor;

    protected var _startTime:int;
//    public var passHandlerList:Handler;
//    public var startHandler:Handler;
//    public var finishHandler:Handler;

    private var _startHandlerList:Vector.<Handler>;
    private var _finishHandlerList:Vector.<Handler>;
    private var _passHandlerList:Vector.<Handler>;
    private var _updateHandlerList:Vector.<Handler>;

    public var externData:CMap;


    public var key:String;
    public var index:int;
}
}
