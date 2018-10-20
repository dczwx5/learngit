//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.lobby.view {

import flash.events.Event;
import flash.events.MouseEvent;

import kof.SYSTEM_ID;
import kof.framework.CViewHandler;
import kof.framework.events.CEventPriority;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.CSystemBundleContext;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.hero.CHeroEmbattleListView;
import kof.game.common.system.CProcedureHandler;
import kof.game.embattle.CEmbattleEvent;
import kof.game.embattle.CEmbattleSystem;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.IInstanceFacade;
import kof.game.instance.enum.EInstanceType;
import kof.game.instance.mainInstance.enum.EInstanceWndType;
import kof.game.instance.mainInstance.view.instanceScenario.CInstanceScenarioView;

import morn.core.components.List;
import morn.core.handlers.Handler;

/**
 * @author Jeremy (jeremy@qifun.com)
 */
public class CEmBattleInLobbyViewHandler extends CViewHandler {

    /** @private */
    private var m_pEmList : List;

    private var _heroEmbattleList:CHeroEmbattleListView;

    /** Creates a new CEmBattleInLobbyViewHandler */
    public function CEmBattleInLobbyViewHandler() {
        super();
    }

    override public function dispose() : void {
        super.dispose();
        m_pEmList = null;
    }

    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        if ( ret ) {
            var pEmBattleSys : CEmbattleSystem = system.stage.getSystem( CEmbattleSystem ) as CEmbattleSystem;
            pEmBattleSys.addEventListener( CEmbattleEvent.EMBATTLE_DATA, _embattleSys_dataEventHandler, false,
                    CEventPriority.DEFAULT, true );
        }
        return ret;
    }

    public function initWith( pList : List ) : Boolean {
        m_pEmList = pList;

        if (_heroEmbattleList == null) {
            m_pEmList.addEventListener( MouseEvent.CLICK, _emlist_mouseClickEventHandler, false, CEventPriority.DEFAULT,
                    true );
            _heroEmbattleList = new CHeroEmbattleListView(system, m_pEmList, EInstanceType.TYPE_MAIN, new Handler(_emlist_mouseClickEventHandler, [null]));
        }
        _heroEmbattleList.updateWindow();
        return Boolean( m_pEmList );
    }

    /** @private */
    final private function _embattleSys_dataEventHandler( event : Event ) : void {
        // embattle data updated.
        resoleEmBattleData();
    }

    /** @private */
    final private function _emlist_mouseClickEventHandler(e:Event) : void {
        var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as
                ISystemBundleContext;
        if ( pSystemBundleCtx ) {
            var pSystemBundle : ISystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.INSTANCE ) );
            if ( pSystemBundle && pSystemBundleCtx.getSystemBundleState( pSystemBundle ) == CSystemBundleContext.STATE_STARTED ) {
                pSystemBundleCtx.setUserData( pSystemBundle, CBundleSystem.ACTIVATED, true );

                procedureManager.addSequential(_waitInstanceViewShow);
                procedureManager.addSequential(_openInstanceEmbattleView);
            }
        }
    }

    private function _waitInstanceViewShow(theProcedureTags:Object) : Boolean {
        if (CProcedureHandler.isLastProcedureTagFail(theProcedureTags)) {
            return false;
        }

        theProcedureTags.isProcedureFinished = function () : Boolean {
            var isOk:Boolean;
            var pInstanceSystem:IInstanceFacade = system.stage.getSystem(IInstanceFacade) as IInstanceFacade;
            if (pInstanceSystem) {
                isOk = pInstanceSystem.isViewShow(EInstanceWndType.WND_INSTANCE_SCENARIO);
            }
            return isOk;
        };

        return true;
    }
    private function _openInstanceEmbattleView(theProcedureTags:Object) : Boolean {
        if (CProcedureHandler.isLastProcedureTagFail(theProcedureTags)) {
            return false;
        }

        var pInstanceSystem:CInstanceSystem = system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if (pInstanceSystem) {
            var pView:CInstanceScenarioView = pInstanceSystem.uiHandler.getWindow(EInstanceWndType.WND_INSTANCE_SCENARIO) as CInstanceScenarioView;
            if (pView && pView.isShowState) {
                pView.openEmbattleView();
            }
        }

        return true;
    }



    protected function resoleEmBattleData() : void {
        invalidateData();

    }

    override protected function updateData() : void {
        super.updateData();

        if (_heroEmbattleList) {
            _heroEmbattleList.updateWindow();
        }
    }

}
}

// vi: ft=as3 ts=4 sw=4 tw=120 expandtab
