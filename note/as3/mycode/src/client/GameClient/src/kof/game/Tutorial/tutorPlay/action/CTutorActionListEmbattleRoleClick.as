//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.Tutorial.tutorPlay.action {

import QFLib.Foundation;

import flash.events.MouseEvent;

import kof.framework.events.CEventPriority;

import kof.game.Tutorial.CTutorSystem;
import kof.game.Tutorial.data.CTutorActionInfo;
import kof.game.embattle.CEmbattleHandler;
import kof.game.embattle.CEmbattleSystem;
import kof.game.embattle.CEmbattleViewHandler;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CEmbattleListData;
import kof.util.CAssertUtils;
import morn.core.components.Component;
import morn.core.components.List;

/**
 * 新手引导：布阵出阵
 *
 * @author auto (auto@qifun.com)
 */
public class CTutorActionListEmbattleRoleClick extends CTutorActionBase {

    public function CTutorActionListEmbattleRoleClick(pInfo : CTutorActionInfo, pSystem : CTutorSystem ) {
        super( pInfo, pSystem );
    }

    override public function dispose() : void {
        if (_pButton) {
            (_pButton).removeEventListener( MouseEvent.CLICK, _target_mouseClickEventHandler );
            _pButton = null;
        }
        var pEmbattleViewHandler:CEmbattleViewHandler = _system.stage.getSystem(CEmbattleSystem ).getBean(CEmbattleViewHandler);
        if (pEmbattleViewHandler) {
            pEmbattleViewHandler.forceStopDragHero = false;
        }
        super.dispose();
    }

    override protected virtual function startByUIComponent( comp : Component ) : void {
        super.startByUIComponent( comp );

        var pList : List = comp as List;
        if ( !pList ) {
            Foundation.Log.logErrorMsg("布阵引导动作的目标UI类型不是List");
        }

        CAssertUtils.assertNotNull( pList );

        var indexOfList:int = (int)(_info.actionParams[0]);
        indexOfList--;
        var pCellItem : Component;
        if (pList.cells && pList.cells.length > indexOfList) {
            pCellItem = pList.getCell( indexOfList );
        }
        if (!pCellItem) {
            pCellItem = pList.getCell( 0 );
        }

        if (pCellItem) {
            var pButton : Component = pCellItem as Component;
            if ( pButton ) {
                var pEmbattleViewHandler:CEmbattleViewHandler = _system.stage.getSystem(CEmbattleSystem ).getBean(CEmbattleViewHandler);
                if (pEmbattleViewHandler) {
                    pEmbattleViewHandler.forceStopDragHero = true;
                }
                _pButton = pButton;
                pButton.addEventListener( MouseEvent.CLICK, _target_mouseClickEventHandler, false, CEventPriority.BINDING, true );
            }
            this.holeTarget = pButton;
        }

    }

    private function _target_mouseClickEventHandler( event : MouseEvent ) : void {
        (event.currentTarget as Component).removeEventListener( event.type, _target_mouseClickEventHandler );
        this._actionValue = true;
    }

    override public function update( delta : Number ) : void {
        super.update( delta );

        var pEmbattleSystem:CEmbattleSystem = _tutorManager.system.stage.getSystem(CEmbattleSystem) as CEmbattleSystem;
        if (pEmbattleSystem) {
            var pEmbattleHandler:CEmbattleHandler = pEmbattleSystem.getHandler(CEmbattleHandler) as CEmbattleHandler;
            if (pEmbattleHandler) {
                var pPlayerSystem:CPlayerSystem = pEmbattleSystem.stage.getSystem(CPlayerSystem) as CPlayerSystem;
                var embattleListData:CEmbattleListData = pPlayerSystem.playerData.embattleManager.getByType(pEmbattleHandler.type);
                if (embattleListData) {
                    var indexOfList:int = (int)(_info.actionParams[0]);
                    var needHeroCount:int = indexOfList;
                    var heroCountInEmbattle:int = embattleListData.getHeroCount();
                    if (heroCountInEmbattle >= needHeroCount) {
                        _actionValue = true;
                    }
                }
            }
        }
    }

    private var _pButton:Component;
}
}
