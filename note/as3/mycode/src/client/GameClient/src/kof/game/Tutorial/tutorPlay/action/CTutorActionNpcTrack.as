//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.Tutorial.tutorPlay.action {

import QFLib.Framework.CScene;

import kof.framework.CAppSystem;
import kof.game.Tutorial.data.CTutorActionInfo;
import kof.game.character.NPC.CNPCByPlayer;
import kof.game.character.handler.CPlayHandler;
import kof.game.core.CECSLoop;
import kof.game.core.CGameObject;
import kof.game.scene.CSceneEvent;
import kof.game.scene.CSceneRendering;
import kof.game.scene.CSceneSystem;
import kof.game.scene.ISceneFacade;

public class CTutorActionNpcTrack extends CTutorActionBase {

    public function CTutorActionNpcTrack(actionInfo : CTutorActionInfo, system : CAppSystem ) {
        super( actionInfo, system );
    }

    override public function dispose() : void {
        if (_system) {
            var pSceneFacade : ISceneFacade = _system.stage.getSystem(ISceneFacade) as ISceneFacade;
            if (pSceneFacade) {
                pSceneFacade.removeEventListener(CSceneEvent.HERO_INIT, _onHeroReady);
            }
        }

        super.dispose();

    }

    override public function start() : void {
        super.start();

        var npcID : String = _info.actionParams[0] as String;

        if (npcID && npcID.length > 0) {
            var pCSceneSystem : CSceneSystem = _system.stage.getSystem(CSceneSystem) as CSceneSystem;
            var hero:CGameObject = (pCSceneSystem.stage.getSystem(CECSLoop).getBean(CPlayHandler) as CPlayHandler).hero;
            if (hero && hero.isRunning) {
                _movetoNpc();
            } else {
                var pSceneFacade : ISceneFacade = _system.stage.getSystem(ISceneFacade) as ISceneFacade;
                pSceneFacade.addEventListener(CSceneEvent.HERO_INIT, _onHeroReady);
            }
        } else {
            _actionValue = true;
        }


    }

    private function _onHeroReady(e:CSceneEvent = null) : void {
        if (_system) {
            var pSceneFacade : ISceneFacade = _system.stage.getSystem(ISceneFacade) as ISceneFacade;
            pSceneFacade.removeEventListener(CSceneEvent.HERO_INIT, _onHeroReady);
        }
        _movetoNpc();
    }

    private function _movetoNpc() : void {
        var npcID : String = _info.actionParams[0] as String;
        var pCSceneSystem : CSceneSystem = _system.stage.getSystem(CSceneSystem) as CSceneSystem;
        var pCGameObject : CGameObject = pCSceneSystem.findNPCByPrototypeID(Number(npcID));
        if (pCGameObject && pCGameObject.transform) {
            var hero:CGameObject = (pCSceneSystem.stage.getSystem(CECSLoop).getBean(CPlayHandler) as CPlayHandler).hero;
            var npc:CNPCByPlayer = hero.getComponentByClass(CNPCByPlayer, false) as CNPCByPlayer;
            var scene:CScene = ((_system.stage.getSystem(CSceneSystem) as CSceneSystem).getBean(CSceneRendering) as CSceneRendering).scene;
            npc.moveToNPC(pCGameObject,scene, _onNpcTrackFinish);

        } else {
            _actionValue = true;
        }
    }

    private function _onNpcTrackFinish() : void {
        _actionValue = true;
    }
}
}

