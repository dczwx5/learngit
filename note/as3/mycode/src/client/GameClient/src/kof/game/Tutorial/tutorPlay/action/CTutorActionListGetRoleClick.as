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
import kof.game.player.view.playerNew.CHeroListViewHandler;
import kof.util.CAssertUtils;

import morn.core.components.Component;

import morn.core.components.Component;

import morn.core.components.Component;
import morn.core.components.List;
import morn.core.components.List;


/**
 * 新手引导：获取格斗家（招募）
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CTutorActionListGetRoleClick extends CTutorActionBase {

    public function CTutorActionListGetRoleClick(pInfo : CTutorActionInfo, pSystem : CTutorSystem ) {
        super( pInfo, pSystem );
    }

    override public function dispose() : void {
        if (_system) {
            var pPlayerSystem:CPlayerSystem = _system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
            if (pPlayerSystem) {
                var heroListView:CHeroListViewHandler = (pPlayerSystem.getHandler(CHeroListViewHandler) as CHeroListViewHandler);
                if (heroListView) {
                    heroListView.scrollEnable = true;
                }
            }
        }

        super.dispose();
    }

    public override function start() : void { // 开始
        super.start();

        var pPlayerSystem:CPlayerSystem = _system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
        if (pPlayerSystem) {
            var heroListView:CHeroListViewHandler = (pPlayerSystem.getHandler(CHeroListViewHandler) as CHeroListViewHandler);
            if (heroListView) {
                heroListView.scrollEnable = false;
            }
        }
    }

    override protected virtual function startByUIComponent( comp : Component ) : void {
        super.startByUIComponent( comp );

        var pList : List = comp as List;
        if ( !pList ) {
            Foundation.Log.logErrorMsg("格斗家招募引导动作的目标UI类型不是List");
        }

        CAssertUtils.assertNotNull( pList );

        // 默认取第一个
        var pCellItem : Component = pList.getCell( 0 );

        var pButton : Component = pCellItem.getChildByName('btn_zhaomu') as Component;
        if ( pButton ) {
            pButton.addEventListener( MouseEvent.CLICK, _target_mouseClickEventHandler, false, CEventPriority.BINDING, true );
        }
        this.holeTarget = pButton; // img_hero
    }

    private function _target_mouseClickEventHandler( event : MouseEvent ) : void {
        event.currentTarget.removeEventListener( event.type, _target_mouseClickEventHandler );
        this._actionValue = true;
    }

}
}
