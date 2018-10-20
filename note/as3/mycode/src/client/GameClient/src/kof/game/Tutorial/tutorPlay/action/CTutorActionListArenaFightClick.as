//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.Tutorial.tutorPlay.action {

import QFLib.Foundation;

import flash.events.MouseEvent;

import kof.framework.events.CEventPriority;

import kof.game.Tutorial.CTutorSystem;
import kof.game.Tutorial.data.CTutorActionInfo;
import kof.ui.master.arena.ArenaRoleViewUI;
import kof.util.CAssertUtils;
import morn.core.components.Button;
import morn.core.components.Component;


/**
 * 新手引导：竞技场挑战
 *
 * @author auto (auto@qifun.com)
 */
public class CTutorActionListArenaFightClick extends CTutorActionBase {

    public function CTutorActionListArenaFightClick(pInfo : CTutorActionInfo, pSystem : CTutorSystem ) {
        super( pInfo, pSystem );
    }

    override public function dispose() : void {
        super.dispose();

        if (_pButton) {
            _pButton.removeEventListener( MouseEvent.CLICK, _target_mouseClickEventHandler );
            _pButton = null;
        }
    }

    override protected virtual function startByUIComponent( comp : Component ) : void {
        super.startByUIComponent( comp );

        var pArenaRoleView : ArenaRoleViewUI = comp as ArenaRoleViewUI;
        if ( !pArenaRoleView ) {
            Foundation.Log.logErrorMsg("竞技场挑战引导动作的目标UI类型不是ArenaRoleViewUI");
        }

        CAssertUtils.assertNotNull( pArenaRoleView );


        var pCellItem : Button = pArenaRoleView.btn_tz;
        if (!pCellItem) {
            _actionValue = true;
        } else {
            _pButton = pCellItem;
            pCellItem.addEventListener( MouseEvent.CLICK, _target_mouseClickEventHandler, false, CEventPriority.BINDING, true );
            this.holeTarget = pCellItem;
        }
    }

    private function _target_mouseClickEventHandler( event : MouseEvent ) : void {
        (event.currentTarget as Component).removeEventListener( event.type, _target_mouseClickEventHandler );
        this._actionValue = true;
    }

    private var _pButton:Component;

}
}
