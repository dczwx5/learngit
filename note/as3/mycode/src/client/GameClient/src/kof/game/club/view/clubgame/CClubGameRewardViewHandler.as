//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/12/4.
 */
package kof.game.club.view.clubgame {

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.game.common.view.CViewExternalUtil;
import kof.game.item.view.part.CRewardItemListView;
import kof.table.SpecialReward;
import kof.ui.master.club.clubgame.ClubGamePoolViewUI;
import kof.ui.master.club.clubgame.ClubGameRewardItemUI;

import morn.core.components.Component;

import morn.core.components.Dialog;
import morn.core.handlers.Handler;

public class CClubGameRewardViewHandler extends CViewHandler {

    private var _clubGameRewardUI : ClubGamePoolViewUI;

    private var m_viewExternal:CViewExternalUtil;

    public function CClubGameRewardViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array {
        return [ ClubGamePoolViewUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !_clubGameRewardUI ) {
            _clubGameRewardUI = new ClubGamePoolViewUI();

            _clubGameRewardUI.list.renderHandler = new Handler( renderItem );
        }

        return Boolean( _clubGameRewardUI );
    }

    public function addDisplay() : void {
        this.loadAssetsByView( viewClass, _showDisplay );
    }

    protected function _showDisplay() : void {
        if ( onInitializeView() ) {
            invalidate();
            callLater( _addToDisplay );
        } else {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    public function _addToDisplay() : void {

        var pTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.SPECIALREWARD );
        _clubGameRewardUI.list.dataSource = pTable.toArray();

        uiCanvas.addPopupDialog( _clubGameRewardUI );
    }

    public function removeDisplay() : void {
        if ( _clubGameRewardUI ) {
            _clubGameRewardUI.close( Dialog.CLOSE );
        }
    }

    //待接受任务列表
    private function renderItem(item:Component, idx:int):void {
        if ( !(item is ClubGameRewardItemUI) ) {
            return;
        }
        var clubGameRewardItemUI : ClubGameRewardItemUI = item as ClubGameRewardItemUI;
        if ( clubGameRewardItemUI.dataSource ) {
           var specialReward : SpecialReward = clubGameRewardItemUI.dataSource as SpecialReward;
            clubGameRewardItemUI.clip_num.index = specialReward.imgCounts - 1;
            m_viewExternal = new CViewExternalUtil(CRewardItemListView, this, clubGameRewardItemUI);
            m_viewExternal.show();
            ( m_viewExternal.view as CRewardItemListView ).forceAlign = 1;
            ( m_viewExternal.view as CRewardItemListView ).updateLayout();
            m_viewExternal.setData( specialReward.rewardID );
            m_viewExternal.updateWindow();
        }
    }

    private function get _pCDatabaseSystem():CDatabaseSystem{
        return system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }
}
}
