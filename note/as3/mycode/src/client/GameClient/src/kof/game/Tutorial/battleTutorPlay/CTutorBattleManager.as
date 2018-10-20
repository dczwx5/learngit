//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/8.
 */
package kof.game.Tutorial.battleTutorPlay {

import QFLib.Foundation;
import QFLib.ResourceLoader.CResource;
import QFLib.ResourceLoader.CResourceLoaders;
import QFLib.ResourceLoader.CSwfLoader;

import kof.framework.CAbstractHandler;
import kof.framework.CAppStage;
import kof.game.Tutorial.CTutorSystem;
import kof.game.Tutorial.event.CTutorEvent;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.event.CInstanceEvent;
import kof.ui.IUICanvas;

public class CTutorBattleManager extends CAbstractHandler {

    public function CTutorBattleManager() {

    }

    public override function dispose():void {
        super.dispose();
        _system.unListenEvent(_onTutorNetEvent);

        clear();

        if (_battleTutor) {
            _battleTutor.dispose();
            _battleTutor = null;
        }
    }

    public function clear() : void {
        if (_battleTutor) {
            _battleTutor.unListenEvent(_onBattleTutorEvent);
        }
    }

    override protected function onSetup():Boolean {
        var ret:Boolean =  super.onSetup();

        _system.listenEvent(_onTutorNetEvent);

        return ret;
    }
    override protected function enterStage(stage:CAppStage) : void {
        super.enterStage(stage);

        var instacneSystem:CInstanceSystem = _system.stage.getSystem(CInstanceSystem) as CInstanceSystem;

        // func
        var funcOnLoadBattleTutorSwfCompleted:Function = function ( pLoader : CSwfLoader, idError : int ) : void {
            if ( idError == 0 ) {
                var pResourceRef : CResource = pLoader.createResource();
                _battleTutor = pResourceRef.theObject as IBattleTutorFacade;
                _battleTutor.stage = _system.stage.flashStage;
                _battleTutor.system = system;
                _battleTutor.initialize();
                if (_needToStart) {
                    _needToStart = false;
                    _startB();
                }
            } else {
                // 加载失败, 不再处理引导
                _closeTutor = true;
                Foundation.Log.logErrorMsg("can't find battleTutor.swf");
            }
        };
        var funcOnInstanceData:Function = function (e:CInstanceEvent) : void {
            instacneSystem.removeEventListener(CInstanceEvent.INSTANCE_DATA, funcOnInstanceData);
            if (instacneSystem.instanceData.scenarioInstancePassCount < 6 || instacneSystem.instanceData.eliteInstancePassCount < 1) {
                // 需要战斗引导
                var url:String = "assets/bin/battleTutor.swf";
//                "../../client/battleTutor/bin/battleTutor.swf"; // "assets/bin/battleTutor.swf"; // ; // "assets/module/battleTutor.swf";
                CResourceLoaders.instance().startLoadFile( url, funcOnLoadBattleTutorSwfCompleted );
            } else {
                _closeTutor = true;
            }
        };

        // process
        if (instacneSystem) {
            if (false == instacneSystem.instanceData.hasInitialByServer) {
                // 副本数据还没请求回来
                instacneSystem.addEventListener(CInstanceEvent.INSTANCE_DATA, funcOnInstanceData);
            } else {
                funcOnInstanceData(null);
            }
        }
    }

    // ===================event====================
    private function _onTutorNetEvent(e:CTutorEvent) : void {
        switch (e.type) {
            // 战斗引导
            case CTutorEvent.NET_EVENT_START_BATTLE_TUTOR :
                var tutorID:int = e.data["tutorID"] as int;
                var controlType:int = e.data["force"] as int;
                _battleTutorData = new CBattleTutorData(tutorID, controlType);
                _onStartTutor();
                break;
        }
    }
    private function _onStartTutor() : void {
//        clear();

        if (_battleTutor == null) {
            if (_closeTutor) {
                if (_battleTutorData) {
                    if (_battleTutorData.isFreeType() == false) {
                        _system.netHandler.sendBattleTutorFinish(_battleTutorData.tutorID);
                    }
                }
            } else {
                _needToStart = true;
            }
        } else {
            if (_battleTutor.playing()) {
                _battleTutor.stop();
            }
            _battleTutor.unListenEvent(_onBattleTutorEvent);

            _startB();
        }
    }

    private function _startB() : void {
        _system.sendEvent(new CTutorEvent(CTutorEvent.BATTLE_TUTOR_PREPARE, null, _battleTutorData.tutorID));
        _battleTutor.listenEvent(_onBattleTutorEvent);
        _battleTutor.start(_battleTutorData);
    }

    private function _onBattleTutorEvent(e:CBattleTutorEvent) : void {
        var tutorData:CBattleTutorData;
        if (e.type == CBattleTutorEvent.EVENT_START) {
            tutorData = e.data as CBattleTutorData;
            _system.sendEvent(new CTutorEvent(CTutorEvent.BATTLE_TUTOR_STARTED, null, tutorData.tutorID));
        } else if (e.type == CBattleTutorEvent.EVENT_FINISH) {
            tutorData = e.data as CBattleTutorData;
            _battleTutor.unListenEvent(_onBattleTutorEvent);
            _system.sendEvent(new CTutorEvent(CTutorEvent.BATTLE_TUTOR_END, null, tutorData.tutorID));
            if (tutorData.isFreeType() == false) {
                _system.netHandler.sendBattleTutorFinish(tutorData.tutorID);
            }
        } else if (e.type == CBattleTutorEvent.EVENT_STEP_CHANGE) {
            var guideStep:int = e.data as int;
            _system.netHandler.saveBattleTutorStep(guideStep);
        }
    }

    [Inline]
    public function get isPlaying() : Boolean {
        if (_battleTutor) {
            return _battleTutor.playing();
        }
        return false;
    }

    // ===================get/set====================
    [Inline]
    private function get _uiSystem() : IUICanvas {
        return system.stage.getSystem(IUICanvas) as IUICanvas;
    }

    [Inline]
    private function get _system() : CTutorSystem {
        return system as CTutorSystem;
    }

    private var _battleTutor:IBattleTutorFacade;
    private var _battleTutorData:CBattleTutorData;

    private var _needToStart:Boolean = false;
    private var _closeTutor:Boolean = false;

}
}