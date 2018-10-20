//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.Tutorial.tutorPlay.action {

import QFLib.Foundation;

import flash.events.MouseEvent;

import kof.framework.events.CEventPriority;

import kof.game.Tutorial.CTutorSystem;
import kof.game.Tutorial.data.CTutorActionInfo;
import kof.util.CAssertUtils;
import morn.core.components.Component;
import morn.core.components.List;


/**
 * 新手引导：选中镶嵌宝石
 *
 * @author auto (auto@qifun.com)
 */
public class CTutorActionListTalentSelectStoneClick extends CTutorActionBase {

    public function CTutorActionListTalentSelectStoneClick(pInfo : CTutorActionInfo, pSystem : CTutorSystem ) {
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

        var pList : List = comp as List;
        if ( !pList ) {
            Foundation.Log.logErrorMsg("斗魂item引导动作的目标UI类型不是List");
        }

        CAssertUtils.assertNotNull( pList );

        // 默认取第一个
        var pItem:Component = pList.getCell(0);
        var pButton : Component = pItem.getChildByName("btn") as Component;
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
