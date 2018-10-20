//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/7/28.
 */
package kof.game.instance {

import kof.framework.CAbstractHandler;
import kof.game.character.ai.CAIHandler;
import kof.game.character.handler.CPlayHandler;
import kof.game.core.CECSLoop;
import kof.game.fightui.CFightViewHandler;
import kof.game.fightui.compoment.CSkillViewHandler;
import kof.game.lobby.CLobbySystem;

// 提供外部接口
public class CInstanceOtherUtil extends CAbstractHandler {

    private var _pInstanceSystem:CInstanceSystem;
    public function CInstanceOtherUtil(pInstanceSystem:CInstanceSystem) {
        _pInstanceSystem = pInstanceSystem;
    }


    public function setPlayEnable(enabled:Boolean):void {
        if (enabled) {
            if (!_pInstanceSystem.isStart || _pInstanceSystem.isEnd) {
                return ;
            }
        }

        var pLoop:CECSLoop = system.stage.getSystem(CECSLoop) as CECSLoop;
        if (pLoop) {
            var pPlayerHandler:CPlayHandler = pLoop.getBean(CPlayHandler) as CPlayHandler;
            if (pPlayerHandler) {
                pPlayerHandler.setEnable(enabled);
            }
        }
    }

    public function setAiEnable(v:Boolean) : void {
        var aiHandler:CAIHandler = system.stage.getSystem(CECSLoop).getBean(CAIHandler) as CAIHandler;
        return aiHandler.setEnable(v);
    }

    public function aiState():Boolean {
        var aiHandler:CAIHandler = system.stage.getSystem(CECSLoop).getBean(CAIHandler) as CAIHandler;
        return aiHandler.enabled;
    }

    public function setSkillUIEnable( v : Boolean ) : void {
        var fightViewHld : CFightViewHandler = system.stage.getSystem(CLobbySystem ).getBean( CFightViewHandler ) as CFightViewHandler;
        var skillViewHld : CSkillViewHandler;
        if( fightViewHld )
                skillViewHld = fightViewHld.getBean( CSkillViewHandler ) as CSkillViewHandler;
        if( skillViewHld )
                skillViewHld.m__useSkillEnable = v;
    }

    public function resetAIState(bool:Boolean):void {
        var aiHandler:CAIHandler = system.stage.getSystem(CECSLoop).getBean(CAIHandler) as CAIHandler;
        aiHandler.setEnable(bool);
    }
}
}
