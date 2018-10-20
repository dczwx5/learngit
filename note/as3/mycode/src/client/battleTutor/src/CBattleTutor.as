//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package {

import QFLib.Foundation.CMap;

import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;

import helper.CActionHelper;

import helper.CCondHelper;
import helper.CInstanceHelper;
import helper.CKeyPressHelper;

import helper.CViewHelper;

import kof.framework.CAppSystem;
import kof.game.Tutorial.battleTutorPlay.CBattleTutorData;
import kof.game.Tutorial.battleTutorPlay.CBattleTutorEvent;
import kof.game.Tutorial.battleTutorPlay.IBattleTutorFacade;
import tutor.CBattleTutorCreater;
import tutor.CTutorBase;
import helper.CActorHelper;
import helper.CSystemHelper;

import view.CAbilityIntroViewHandler;
import view.CAutoFightIntroViewHandler;

import view.CBattleTutorViewHandlerBase;
import view.CDefend1IntroViewHandler;
import view.CDefend2IntroViewHandler;
import view.CDescViewHandler;

import view.CKeyDescViewHandler;
import view.CKeyPressViewHandler;
import view.CMaskViewHandler;
import view.CMultiKeyDescViewHandler;
import view.CMultiKeyPressViewHandler;
import view.CQEIntroViewHandler;
import view.CQTEViewHandler;
import view.CUIOIntroViewHandler;

import view.CWSADViewHandler;

public class CBattleTutor extends Sprite implements IBattleTutorFacade {

    public function CBattleTutor() {
    }

    public function dispose() : void {
        _clear();
        _pSystem = null;
        _listenerList = null;

        actorHelper.dispose();
        actorHelper = null;
        systemHelper.dispose();
        systemHelper = null;
        viewHelper.dispose();
        viewHelper = null;
        condHelper.dispose();
        condHelper = null;
        keyPressHelper.dispose();
        keyPressHelper = null;
        instanceProcess.dispose();
        instanceProcess = null;
        actionHelper.dispose();
        actionHelper = null;

    }
    private function _clear() : void {
        var filterFunc:Function = function (bean:*) : Boolean {
            return bean is CBattleTutorViewHandlerBase;
        };
        var viewList:Vector.<Object> = system.getBeans(filterFunc);
        for each (var tutorView:CBattleTutorViewHandlerBase in viewList) {
            if (tutorView) {
                tutorView.removeDisplay();
            }
        }

        if (_listenerList) {
            for (var key:* in _listenerList) {
                unListenEvent(key);
                delete _listenerList[key];
            }
        }
        if (_curTutor) {
            _curTutor.dispose();
            _curTutor = null;
        }

        keyPressHelper.stop();
    }

    public function initialize() : void {
        _listenerList = new CMap();
        this.system.addBean(new CWSADViewHandler());
        this.system.addBean(new CKeyDescViewHandler());
        this.system.addBean(new CKeyPressViewHandler());
        this.system.addBean(new CQTEViewHandler());
        this.system.addBean(new CMultiKeyDescViewHandler());
        this.system.addBean(new CMultiKeyPressViewHandler());
        this.system.addBean(new CAbilityIntroViewHandler());
        this.system.addBean(new CDefend1IntroViewHandler());
        this.system.addBean(new CDefend2IntroViewHandler());
        this.system.addBean(new CAutoFightIntroViewHandler());
        this.system.addBean(new CUIOIntroViewHandler());

        this.system.addBean(new CQEIntroViewHandler());

        this.system.addBean(new CDescViewHandler());
        this.system.addBean(new CMaskViewHandler());


        actorHelper = new CActorHelper(this);
        systemHelper = new CSystemHelper(this);
        viewHelper = new CViewHelper(this);
        condHelper = new CCondHelper(this);
        keyPressHelper = new CKeyPressHelper(this);
        actionHelper = new CActionHelper(this);
        instanceHelper = new CInstanceHelper(this);

        instanceProcess = new CInstanceProcess(this);

        instanceProcess.initialize();
        log("|---------------battle Tutor initialize");
    }

    public function start(data:CBattleTutorData) : void {
        _pData = data;

        keyPressHelper.start();
        log("|----------battleTutor-------------| battle tutor started -> ID : " + _pData.tutorID);

        _curTutor = CBattleTutorCreater.createTutor(this, _pData, _pSystem);
        if (_curTutor) {
            _curTutor.addEventListener(Event.COMPLETE, _onTutorCompleted);
            _curTutor.start();
            this.dispatchEvent(new CBattleTutorEvent(CBattleTutorEvent.EVENT_START, _pData));
            this.addEventListener(Event.ENTER_FRAME, _onUpdate);
        } else {
            this.dispatchEvent(new CBattleTutorEvent(CBattleTutorEvent.EVENT_START, _pData));
            this.dispatchEvent(new CBattleTutorEvent(CBattleTutorEvent.EVENT_FINISH, _pData));
        }
    }

    protected function _onUpdate(e:Event) : void {
        if (_curTutor && _curTutor.isStart) {
            _curTutor.update();
        }
    }

    public function hide() : void {

    }

    public function stop() : void {
        // todo : stop process
        if (_curTutor && _curTutor.isStart) {
            _curTutor.stop();
            _onTutorCompleted(null);
        }
    }
    protected function _onTutorCompleted(e:Event) : void {
        _curTutor.removeEventListener(Event.COMPLETE, _onTutorCompleted);
        this.dispatchEvent(new CBattleTutorEvent(CBattleTutorEvent.EVENT_FINISH, _pData));
        log("|-----------------------| battle tutor Finish -> ID : " + _pData.tutorID);
        _clear();

    }


    // ====================event==========================
    public function listenEvent(func:Function) : void {
        if (func == null) return ;
        unListenEvent(func);

        _listenerList[func] = func;

        this.addEventListener(CBattleTutorEvent.EVENT_START, func);
        this.addEventListener(CBattleTutorEvent.EVENT_FINISH, func);
        this.addEventListener(CBattleTutorEvent.EVENT_STEP_CHANGE, func);
    }
    public function unListenEvent(func:Function) : void {
        if (null == func) return ;
        if (_listenerList) {
            if (func in _listenerList) {
                delete _listenerList[func];
            }
        }

        this.removeEventListener(CBattleTutorEvent.EVENT_START, func);
        this.removeEventListener(CBattleTutorEvent.EVENT_FINISH, func);
        this.removeEventListener(CBattleTutorEvent.EVENT_STEP_CHANGE, func);
    }


    // ===================getset
    [Inline]
    public function get system() : CAppSystem {
        return _pSystem;
    }
    [Inline]
    public function set system(v:CAppSystem) : void {
        _pSystem = v;
    }
    [Inline]
    public function playing() : Boolean {
        return _curTutor && _curTutor.isStart;
    }

    private var _listenerList:CMap;
    private var _pData:CBattleTutorData;
    private var _curTutor:CTutorBase;

    private var _pSystem:CAppSystem;

    public var actionHelper:CActionHelper;
    public var actorHelper:CActorHelper;
    public var systemHelper:CSystemHelper;
    public var viewHelper:CViewHelper;
    public var condHelper:CCondHelper;
    public var keyPressHelper:CKeyPressHelper;
    public var instanceHelper:CInstanceHelper;

    public var instanceProcess:CInstanceProcess;

    [Inline]
    public override function get stage():Stage { return _pStage;  }
    [Inline]
    public function set stage(value:Stage):void { _pStage = value; }
    private var _pStage:Stage;
}
}
