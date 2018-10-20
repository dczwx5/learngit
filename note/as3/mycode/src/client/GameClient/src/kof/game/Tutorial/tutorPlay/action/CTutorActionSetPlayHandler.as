//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/7/3.
 */
package kof.game.Tutorial.tutorPlay.action {

import kof.framework.events.CEventPriority;
import kof.game.Tutorial.CTutorSystem;
import kof.game.Tutorial.data.CTutorActionInfo;
import kof.game.character.NPC.CNPCEvent;
import kof.game.character.handler.CPlayHandler;
import kof.game.core.CECSLoop;
import kof.game.npc.INpcFacade;

/**
 * 设置playHandle
 *
 * @author auto (auto@qifun.com)
 */
public class CTutorActionSetPlayHandler extends CTutorActionGuideClick {

    public function CTutorActionSetPlayHandler(pInfo : CTutorActionInfo, pSystem : CTutorSystem ) {
        super( pInfo, pSystem );
    }

    override public function dispose() : void {
        super.dispose();
    }

    override public virtual function start() : void {
        var sParma:String = _info.actionParams[0] as String;
        var isEnable:Boolean = true;
        if (sParma.toLocaleLowerCase() == "false") {
            isEnable = false;
        }

        var pECSLoop : CECSLoop = _system.stage.getSystem( CECSLoop ) as CECSLoop;
        if ( pECSLoop ) {
            var pPlayHandler : CPlayHandler = pECSLoop.getHandler( CPlayHandler ) as CPlayHandler;
            if ( pPlayHandler ) {
                pPlayHandler.setEnable(isEnable);
            }
        }

        super.start();

        _actionValue = true;
    }
}
}
