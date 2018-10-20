//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.Tutorial.tutorPlay.action {

import QFLib.Foundation;

import flash.events.MouseEvent;

import kof.framework.events.CEventPriority;

import kof.game.Tutorial.CTutorSystem;
import kof.game.Tutorial.data.CTutorActionInfo;
import kof.game.talent.CTalentSystem;
import kof.game.talent.talentFacade.talentSystem.enums.ETalentPointStateType;
import kof.ui.demo.talentSys.TalentIcoUI;
import kof.util.CAssertUtils;
import morn.core.components.Component;


/**
 * 新手引导：点击斗魂第一个item, 开启item
 *
 * @author auto (auto@qifun.com)
 */
public class CTutorActionListTalentItemClick extends CTutorActionBase {

    public function CTutorActionListTalentItemClick(pInfo : CTutorActionInfo, pSystem : CTutorSystem ) {
        super( pInfo, pSystem );
    }

    override public function dispose() : void {
        if (_pButton) {
            _pButton.removeEventListener( MouseEvent.CLICK, _target_mouseClickEventHandler );
            _pButton = null;
        }
    }

    override protected virtual function startByUIComponent( comp : Component ) : void {
        super.startByUIComponent( comp );

        var pTalentItem : TalentIcoUI = comp as TalentIcoUI;
        if ( !pTalentItem ) {
            Foundation.Log.logErrorMsg("斗魂item引导动作的目标UI类型不是TalentIcoUI");
        }

        CAssertUtils.assertNotNull( pTalentItem );

//        var pTalentSystem:CTalentSystem = _tutorManager.system.stage.getSystem(CTalentSystem) as CTalentSystem;
//        var isOpen:Boolean = pTalentSystem.getTalentPointState(1) != ETalentPointStateType.NOT_OPEN;
//        if (isOpen) {
//            _actionValue = true;
//            return ;
//        }

        // 默认取第一个
        var pButton : Component = pTalentItem.btn;
        if ( pButton ) {
            _pButton = pButton;
            pButton.addEventListener( MouseEvent.CLICK, _target_mouseClickEventHandler, false, CEventPriority.BINDING, true );
        }
        this.holeTarget = pButton;
    }

    private function _target_mouseClickEventHandler( event : MouseEvent ) : void {
        event.currentTarget.removeEventListener( event.type, _target_mouseClickEventHandler );
        this._actionValue = true;
    }

    private var _pButton:Component;
}
}
