//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.Tutorial.tutorPlay.action {

import QFLib.Foundation;

import flash.events.MouseEvent;

import kof.framework.events.CEventPriority;

import kof.game.Tutorial.CTutorSystem;
import kof.game.Tutorial.data.CTutorActionInfo;
import kof.game.player.CPlayerSystem;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerHeroData;
import kof.table.ShopItem;
import kof.ui.imp_common.ShopItemUI;
import kof.util.CAssertUtils;

import morn.core.components.Box;

import morn.core.components.Component;

import morn.core.components.Component;

import morn.core.components.Component;
import morn.core.components.List;
import morn.core.components.List;


/**
 * 新手引导：选择物品购买
 *
 * @author auto (auto@qifun.com)
 */
public class CTutorActionListShopItemClick extends CTutorActionBase {

    public function CTutorActionListShopItemClick(pInfo : CTutorActionInfo, pSystem : CTutorSystem ) {
        super( pInfo, pSystem );
    }

    override public function dispose() : void {
        super.dispose();

        if (_pButton) {
            _pButton.removeEventListener(MouseEvent.CLICK, _target_mouseClickEventHandler);
            _pButton = null;
        }
        if (_pList) {
            _pList.removeEventListener(MouseEvent.CLICK, _target_mouseClickEventHandler);
            _pList = null;
        }

    }
    override protected virtual function startByUIComponent( comp : Component ) : void {
        super.startByUIComponent( comp );

        var pList : List = comp as List;
        if ( !pList ) {
            Foundation.Log.logErrorMsg("购买物品引导动作的目标UI类型不是List");
        }

        CAssertUtils.assertNotNull( pList );
        _pList = pList;

        var listIndex:int = (int)(info.actionParams[0]);
        if (listIndex < 0) {
            _actionValue = true;
            return ;
        }

        var pCellItem : ShopItemUI = null;
        var startIndex:int = pList.startIndex;
        if ( pList.cells.length > listIndex) {
            pCellItem = pList.getCell(listIndex + startIndex) as ShopItemUI;
        } else {
            pCellItem = pList.getCell(startIndex + 0) as ShopItemUI;
        }


        _pList.addEventListener( MouseEvent.CLICK, _target_mouseClickEventHandler, false, CEventPriority.BINDING, true );

        if (pCellItem) {
            _pButton = pCellItem.btn_buy;
            _pButton.addEventListener( MouseEvent.CLICK, _target_mouseClickEventHandler, false, CEventPriority.BINDING, true );
            this.holeTarget = _pButton;
        } else {
            _actionValue = true;
        }
    }

    private function _target_mouseClickEventHandler( event : MouseEvent ) : void {
        _pButton.removeEventListener( event.type, _target_mouseClickEventHandler );
        _pList.removeEventListener( event.type, _target_mouseClickEventHandler );
        this._actionValue = true;
    }

    private var _pButton:Component;
    private var _pList:List;

}
}
