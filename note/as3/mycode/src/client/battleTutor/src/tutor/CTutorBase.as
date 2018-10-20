//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/8.
 */
package tutor {

import action.CActionBase;

import config.CPathConfig;


import flash.events.Event;
import flash.events.EventDispatcher;
import flash.utils.getQualifiedClassName;

import kof.framework.CAppSystem;

import kof.game.Tutorial.battleTutorPlay.CBattleTutorData;
import kof.game.character.ai.CAIEvent;
import kof.game.character.ai.CAIHandler;
import kof.game.character.handler.CPlayHandler;
import kof.game.core.CGameObject;
import kof.util.CAssertUtils;

public class CTutorBase extends EventDispatcher {
    public function CTutorBase() {
        _unOpenActionList = new Vector.<CActionBase>();
        _playingActionList = new Vector.<CActionBase>();
    }

    public function dispose() : void {
        log(getQualifiedClassName(this), "end");

        stop();

        _unOpenActionList = null;
        _playingActionList = null;
        _pHero = null;
        _pTutorData = null;
        _pBattleTutor = null;
        _pSystem = null;

    }
    public function stop() : void {
        for each (var act:CActionBase in _playingActionList) {
            if (act) {
                act.removeEventListener(Event.COMPLETE, _onActionCompleted);
                act.dispose();
            }
        }
        this._pBattleTutor.actorHelper.unSlowGame();

        _playingActionList.length = 0;
        _unOpenActionList.length = 0;
        _isStart = false;
        _isFinish = true;

        var aiHandler:CAIHandler = (_pBattleTutor.systemHelper.escLoop.getBean(CAIHandler) as CAIHandler);
        if (aiHandler) {
            aiHandler.removeEventListener(CAIEvent.REASET_AI_STATE, _onAiStateChange);
        }

        var playHandler:CPlayHandler = (_pBattleTutor.systemHelper.escLoop.getBean(CPlayHandler) as CPlayHandler);
        if (playHandler) {
            playHandler.removeEventListener("resetPlayState", _onPlayStateChange);
        }
    }

    public function initialize() : void {
        onInitialize();
    }
    // override me
    protected virtual function onInitialize() : void {
        throw new Error("must override CTutorBase.onSetup...")
    }

    public function start() : void {
        CAssertUtils.assertFalse(_isStart);
        _isStart = true;
        _isFinish = false;
        battleTutor.viewHelper.hideFightUI();

        if (_needStopAll) {
            _pBattleTutor.actorHelper.pauseActor();

            // 引导开始之后, 把ai关掉, 但是可能有其他地方会把AI打开, 这里监听ai改变, 如果ai被打开了, 就关掉
            var aiHandler:CAIHandler = (_pBattleTutor.systemHelper.escLoop.getBean(CAIHandler) as CAIHandler);
            aiHandler.addEventListener(CAIEvent.REASET_AI_STATE, _onAiStateChange);
            // 同上
            var playHandler:CPlayHandler = (_pBattleTutor.systemHelper.escLoop.getBean(CPlayHandler) as CPlayHandler);
            playHandler.addEventListener("resetPlayState", _onPlayStateChange);
        }
        _pBattleTutor.actorHelper.markPlayerControlValue();
        _pBattleTutor.systemHelper.autoFightHandler.setForcePause(true);

        log(getQualifiedClassName(this), "start");
        _startNextAction();
    }

    // 特殊需求打开AI
    public function openAI() : Boolean {
        var aiHandler:CAIHandler = (_pBattleTutor.systemHelper.escLoop.getBean(CAIHandler) as CAIHandler);
        aiHandler.removeEventListener(CAIEvent.REASET_AI_STATE, _onAiStateChange);
        _pBattleTutor.actorHelper.openAI();
        return true;
    }

    public function update() : void {
        if (_isFinish) return ;
        if (!_isStart) return ;

        for each (var act:CActionBase in _playingActionList) {
            if (act) {
                act.update();
            }
        }

        if (_unOpenActionList.length == 0 && _playingActionList.length == 0) {
            _isStart = false;
            _isFinish = true;
            _onFinish();
        }
    }

    private function _onAiStateChange(e:CAIEvent) : void {
        // 引导开始之后, 把ai关掉, 但是可能有其他地方会把AI打开, 这里监听ai改变, 如果ai被打开了, 就关掉
        if (_needStopAll && _pBattleTutor.actorHelper._needLockAI) {
            if (e.type == CAIEvent.REASET_AI_STATE) {
                var aiHandler:CAIHandler = (_pBattleTutor.systemHelper.escLoop.getBean(CAIHandler) as CAIHandler);
                if (aiHandler.enabled) {
                    aiHandler.setEnable(false);
                }
            }
        }
    }
    private function _onPlayStateChange(e:Event) : void {
        if (_needStopAll && _pBattleTutor.actorHelper._needLockPlayControl) {
            if (e.type == "resetPlayState") {
                var playHandler:CPlayHandler = (_pBattleTutor.systemHelper.escLoop.getBean(CPlayHandler) as CPlayHandler);
                if (playHandler.enabled) {
                    playHandler.setEnable(false);
                }
            }
        }

    }
    [Inline]
    public function get hero() : CGameObject {
        if (_pHero == null) {
            _pHero = _pBattleTutor.actorHelper.hero;
        }
        return _pHero;
    }

    // action
    public function addAction(act:CActionBase) : void {
        act.battleTutor = battleTutor;
        act.tutorData = tutorData;
        act.system = system;
        act.index = _unOpenActionList.length + 1;
        _unOpenActionList[_unOpenActionList.length] = act;
    }
    public function removeAction(act:CActionBase) : void {
        if (act == null) return ;

        act.removeEventListener(Event.COMPLETE, _onActionCompleted);
        var index:int = _playingActionList.indexOf(act);
        if (-1 != index) {
            _playingActionList.splice(index, 1);
        }
        act.dispose();
    }
    private function _onActionCompleted(e:Event) :  void {
        var act:CActionBase = e.currentTarget as CActionBase;
        log("actionCompleted : index : " + act.index);

        removeAction(act);

        _startNextAction();
    }
    private function _startNextAction() : void {
        var act:CActionBase = _nextAction();
        if (act) {
            act.addEventListener(Event.COMPLETE, _onActionCompleted);
            act.start();
        }
    }
    private function _nextAction() : CActionBase {
        log("nextAction");
        if (_unOpenActionList.length > 0) {
            var act:CActionBase = _playingActionList[_playingActionList.length] = _unOpenActionList.shift();
            return act;
        }
        return null;
    }
    private function _onFinish() : void {
        battleTutor.viewHelper.showFightUI();
        _pBattleTutor.systemHelper.autoFightHandler.setForcePause(false);
        log("tutor finish");
        if (_needStopAll) {
            this._pBattleTutor.actorHelper.continueActor();
        }
        stop();
        this.dispatchEvent(new Event(Event.COMPLETE));
    }

    private function get _needStopAll() : Boolean {
        return true; // return _pTutorData.isFreeType() == false;
    }

    [Inline]
    public function get tutorData():CBattleTutorData { return _pTutorData; }
    [Inline]
    public function set tutorData(value:CBattleTutorData):void { _pTutorData = value; }
    [Inline]
    public function get battleTutor():CBattleTutor { return _pBattleTutor; }
    [Inline]
    public function set battleTutor(value:CBattleTutor):void { _pBattleTutor = value; }
    [Inline]
    public function get system() : CAppSystem { return _pSystem; }
    [Inline]
    public function set system(value : CAppSystem) : void { _pSystem = value; }
    [Inline]
    public function get isStart():Boolean { return _isStart; }

    protected var _pHero:CGameObject;
    private var _pTutorData:CBattleTutorData;
    private var _pBattleTutor:CBattleTutor;
    private var _pSystem:CAppSystem;

    protected var _unOpenActionList:Vector.<CActionBase>;
    protected var _playingActionList:Vector.<CActionBase>;

    private var _isFinish:Boolean;
    private var _isStart:Boolean;

}
}
