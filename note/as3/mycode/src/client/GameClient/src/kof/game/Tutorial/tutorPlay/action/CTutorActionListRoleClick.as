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
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.view.playerNew.CHeroListViewHandler;
import kof.util.CAssertUtils;
import morn.core.components.Box;
import morn.core.components.Component;
import morn.core.components.List;


/**
 * 新手引导：选择格斗家
 *
 * @author auto (auto@qifun.com)
 */
public class CTutorActionListRoleClick extends CTutorActionBase {

    public function CTutorActionListRoleClick(pInfo : CTutorActionInfo, pSystem : CTutorSystem ) {
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

        if (_pButton) {
            _pButton.removeEventListener( MouseEvent.CLICK, _target_mouseClickEventHandler );
            _pButton = null;
        }
        if (_pList) {
            _pList.removeEventListener( MouseEvent.CLICK, _target_mouseClickEventHandler );
            _pList = null;
        }

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

        _pList = pList;

        CAssertUtils.assertNotNull( pList );

        var heroID:int = (int)(info.actionParams[0]);
        if (heroID <= 0) {
            _actionValue = true;
            return ;
        }

        var cellList:Vector.<Box> = pList.cells;
        var pCellItem : Component = null;
        if (cellList) {
            for (var i:int = 0; i < cellList.length; i++) {
                var cell:Box = cellList[i];
                if (cell && cell.dataSource) {
                    var heroData:CPlayerHeroData = cell.dataSource as CPlayerHeroData;
                    if (heroData.prototypeID == heroID) {
                        pCellItem = cell;
                        if (i > 5) {
                            // 超过2行了
                            pCellItem = pList.getCell(0);
                        }
                        break;
                    }
                }
            }
        }

        pList.addEventListener( MouseEvent.CLICK, _target_mouseClickEventHandler, false, CEventPriority.BINDING, true );

        if (pCellItem) {
            var pButton : Component = pCellItem.getChildByName('clip_bg') as Component;
            if ( pButton ) {
                _pButton = pButton;
                pButton.addEventListener( MouseEvent.CLICK, _target_mouseClickEventHandler, false, CEventPriority.BINDING, true );
            }
            this.holeTarget = pButton;
        } else {
            _actionValue = true;
        }
    }

    private function _target_mouseClickEventHandler( event : MouseEvent ) : void {
        if (_pButton) {
            _pButton.removeEventListener( event.type, _target_mouseClickEventHandler );
        }
        if (_pList) {
            _pList.removeEventListener( event.type, _target_mouseClickEventHandler );
        }
        this._actionValue = true;
    }

    public override function update(delta:Number) : void {
        super.update(delta);

        var pPlayerSystem:CPlayerSystem = _system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
        if (pPlayerSystem.isHeroMainNewShow()) {
            _actionValue = true;
        }
    }

    private var _pList:List;
    private var _pButton:Component;

}
}
