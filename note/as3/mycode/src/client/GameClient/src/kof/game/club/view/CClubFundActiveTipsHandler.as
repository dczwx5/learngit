//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/6/13.
 */
package kof.game.club.view {

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.game.club.CClubManager;
import kof.game.club.data.CClubConst;
import kof.game.common.view.CViewExternalUtil;
import kof.game.item.view.part.CRewardItemListView;
import kof.table.ClubConstant;
import kof.table.ClubUpgradeBasic;
import kof.ui.IUICanvas;
import kof.ui.master.club.ClubFundActiveTipsUI;

import morn.core.components.View;

public class CClubFundActiveTipsHandler extends CViewHandler {
    
    private var clubFundActiveTipsUI:ClubFundActiveTipsUI;
    private var m_tipsObj:View;
    private var activeIndex : int;
    private var m_viewExternal:CViewExternalUtil;

    public function CClubFundActiveTipsHandler() {
        super( false );
    }
    override public function get viewClass() : Array {
        return [ ClubFundActiveTipsUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if(!clubFundActiveTipsUI)
            clubFundActiveTipsUI = new ClubFundActiveTipsUI();

        return Boolean( clubFundActiveTipsUI );
    }

    public function addDisplay(tipsObj:View) : void {
        m_tipsObj = tipsObj;
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
    public function _addToDisplay( ):void {
        activeIndex = int( m_tipsObj.dataSource ) ;
        var pTable : IDataTable;
        pTable = _pCDatabaseSystem.getTable( KOFTableConstants.CLUBCONSTANT );
        var clubConstant : ClubConstant =  pTable.findByPrimaryKey(1);

        clubFundActiveTipsUI.reward_title_txt.text = "建设值达到" + clubConstant.getActiveRewardValue[activeIndex] + "可以领取奖励";
        var getActiveRewardSign : int = _pClubManager.selfClubFundData.getActiveRewardSign[activeIndex];
        if( getActiveRewardSign == CClubConst.GOT_FUND_ACTIVE ){
            clubFundActiveTipsUI.txt_state.text = "已领取";
        }else if( _pClubManager.selfClubFundData.activeValue >= clubConstant.getActiveRewardValue[activeIndex] ){
            clubFundActiveTipsUI.txt_state.text = "可领取";
        }else{
            clubFundActiveTipsUI.txt_state.text = "未达成";
        }
        if(!m_viewExternal)
            m_viewExternal = new CViewExternalUtil(CRewardItemListView, this, clubFundActiveTipsUI);
        m_viewExternal.show();
        pTable = _pCDatabaseSystem.getTable( KOFTableConstants.CLUBUPGRADEBASIC );
        var clubUpgradeBasic : ClubUpgradeBasic =  pTable.findByPrimaryKey( _pClubManager.clubLevel );

        m_viewExternal.setData( clubUpgradeBasic.activeValueReward[activeIndex]);
        m_viewExternal.updateWindow();

        App.tip.addChild(clubFundActiveTipsUI);
    }
    public function hideTips():void{
        clubFundActiveTipsUI.remove();
    }

    private function get _pCDatabaseSystem():CDatabaseSystem{
        return system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }
    private function get _pClubManager(): CClubManager{
        return system.getBean( CClubManager ) as CClubManager;
    }

}
}
