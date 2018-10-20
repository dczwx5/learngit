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
 * NPC对话
 *     屏蔽玩家操作和指令玩家
 *     屏蔽地面点击
 * or
 *     点npc dialog的确定按钮
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CTutorActionNpcDialogOrClick extends CTutorActionGuideClick {

    public function CTutorActionNpcDialogOrClick(pInfo : CTutorActionInfo, pSystem : CTutorSystem ) {
        super( pInfo, pSystem );
    }

    override public function dispose() : void {
        if ( _system ) {
            var pNpcSys : INpcFacade = _system.stage.getSystem( INpcFacade ) as INpcFacade;
            if ( pNpcSys && pNpcSys.eventDelegate ) {
//                pNpcSys.eventDelegate.removeEventListener( CNPCEvent.NPC_OPEN, _npcSys_onNpcOpenEventHandler );
                pNpcSys.eventDelegate.removeEventListener( CNPCEvent.NPC_TASKOVER, _npcSys_onNpcTaskOverEventHandler );
            }
            var pECSLoop : CECSLoop = _system.stage.getSystem( CECSLoop ) as CECSLoop;
            if ( pECSLoop ) {
                var pPlayHandler : CPlayHandler = pECSLoop.getHandler( CPlayHandler ) as CPlayHandler;
                if ( pPlayHandler ) {
                    pPlayHandler.setEnable(true);
                }
            }
        }


        super.dispose();
    }

    override public virtual function start() : void {
        // 移动到NPC，等待出发一系列NPC对话事件
        var pNpcSys : INpcFacade = _system.stage.getSystem( INpcFacade ) as INpcFacade;
        if ( pNpcSys && pNpcSys.eventDelegate ) {
//            pNpcSys.eventDelegate.addEventListener( CNPCEvent.NPC_OPEN, _npcSys_onNpcOpenEventHandler, false, CEventPriority.BINDING, true );
            pNpcSys.eventDelegate.addEventListener( CNPCEvent.NPC_TASKOVER, _npcSys_onNpcTaskOverEventHandler, false, CEventPriority.BINDING, true );
        }

        var pECSLoop : CECSLoop = _system.stage.getSystem( CECSLoop ) as CECSLoop;
        if ( pECSLoop ) {
            var pPlayHandler : CPlayHandler = pECSLoop.getHandler( CPlayHandler ) as CPlayHandler;
            if ( pPlayHandler ) {
                pPlayHandler.setEnable(false);
            }
        }

        super.start();
        this.maskAlpha = 0.1;
        this.holeTarget = null;
        this.playAudio();
    }

    private function _npcSys_onNpcTaskOverEventHandler( event : CNPCEvent ) : void {
        var pECSLoop : CECSLoop = _system.stage.getSystem( CECSLoop ) as CECSLoop;
        if ( pECSLoop ) {
            var pPlayHandler : CPlayHandler = pECSLoop.getHandler( CPlayHandler ) as CPlayHandler;
            if ( pPlayHandler ) {
                pPlayHandler.setEnable(true);
            }
        }

        _actionValue = true;
    }

    override public function update( delta : Number ) : void {
        super.update( delta );
    }

}
}
