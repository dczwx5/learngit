//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/6/14.
 */
package kof.game.club.view.welfarebag {

import kof.SYSTEM_ID;
import kof.data.CDataTable;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.club.CClubHandler;
import kof.game.club.CClubManager;
import kof.game.club.data.CClubConst;
import kof.game.common.view.CViewExternalUtil;
import kof.game.item.CItemSystem;
import kof.game.item.view.part.CRewardItemListView;
import kof.game.item.view.tips.CItemTipsView;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.reciprocation.CReciprocalSystem;
import kof.game.shop.CShopSystem;
import kof.table.Currency;
import kof.table.DropPackage;
import kof.table.LuckyBagConfig;
import kof.ui.CUISystem;
import kof.ui.IUICanvas;
import kof.ui.master.club.ClubWelfareBagSendItemViewUI;
import kof.ui.master.club.ClubWelfareBagSendViewUI;

import morn.core.components.Component;
import morn.core.components.Dialog;
import morn.core.handlers.Handler;

public class CClubBagSendInfoViewHandler extends CViewHandler {

    private var _clubWelfareBagSendViewUI : ClubWelfareBagSendViewUI;

    private var _selectedIndex : int;

    private var m_viewExternal:CViewExternalUtil;

    public function CClubBagSendInfoViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }
    override public function get viewClass() : Array {
        return [ ClubWelfareBagSendViewUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }
    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if( !_clubWelfareBagSendViewUI ){
            _clubWelfareBagSendViewUI = new ClubWelfareBagSendViewUI();

            _clubWelfareBagSendViewUI.list.renderHandler = new Handler( renderItem );
            _clubWelfareBagSendViewUI.list.selectHandler = new Handler( selectItemHandler );
            _clubWelfareBagSendViewUI.list.dataSource = [];

            _clubWelfareBagSendViewUI.closeHandler = new Handler( _onClose );
        }

        return Boolean( _clubWelfareBagSendViewUI );
    }

    private function renderItem(item:Component, idx:int):void {
        if ( !(item is ClubWelfareBagSendItemViewUI) ) {
            return;
        }
        var pClubWelfareBagSendItemViewUI : ClubWelfareBagSendItemViewUI = item as ClubWelfareBagSendItemViewUI;
        if ( pClubWelfareBagSendItemViewUI.dataSource ) {
            var luckyBagConfig : LuckyBagConfig = pClubWelfareBagSendItemViewUI.dataSource as LuckyBagConfig;
            for( var index : int = CClubConst.BAG_GOLD_TYPE ; index <= CClubConst.BAG_ITEM_TYPE ; index++ ){
                pClubWelfareBagSendItemViewUI['box_' + index ].visible =
                        pClubWelfareBagSendItemViewUI['img_icon_' + index ].visible =
                                pClubWelfareBagSendItemViewUI['img_iconI_' + index ].visible = luckyBagConfig.subtype == index;
                pClubWelfareBagSendItemViewUI['img_iconI_' + index ].toolTip = '';
            }
            pClubWelfareBagSendItemViewUI.clip_lv.index = luckyBagConfig.tab - 1;
            pClubWelfareBagSendItemViewUI.box_vip.visible = luckyBagConfig.isNeedVipToBuy > 0;
            if( pClubWelfareBagSendItemViewUI.box_vip.visible )
                pClubWelfareBagSendItemViewUI.clip_vip.index = luckyBagConfig.isNeedVipToBuy;
            var h : int = Math.floor( luckyBagConfig.timeOfDuration / 60 );
            var m : int = luckyBagConfig.timeOfDuration % 60;
            var timeStr :String = '';
            if( h > 0 ) timeStr = h + '小时';
            if( m > 0 ) timeStr = m + '分';
            pClubWelfareBagSendItemViewUI.txt_timeOfDuration.text = timeStr;
//            pClubWelfareBagSendItemViewUI.kofnum_counts.num = luckyBagConfig.counts;
            pClubWelfareBagSendItemViewUI.txt_consumeValue.text = String( luckyBagConfig.consumeValue );
            pClubWelfareBagSendItemViewUI.txt_counts.text = String( luckyBagConfig.counts );
            var pTable : IDataTable ;
            if( luckyBagConfig.subtype == CClubConst.BAG_GOLD_TYPE || luckyBagConfig.subtype == CClubConst.BAG_DIAMONDS_TYPE ){
                pClubWelfareBagSendItemViewUI.txt_totalValue.text =  String( luckyBagConfig.totalValue );
//                pClubWelfareBagSendItemViewUI.reward.visible = true;
//                pClubWelfareBagSendItemViewUI.reward_list_1.visible = false;
                pTable = _pCDatabaseSystem.getTable( KOFTableConstants.CURRENCY );
                var currency : Currency =   pTable.findByPrimaryKey( luckyBagConfig.subtype );
//                pClubWelfareBagSendItemViewUI.reward.icon_img.url = _pCShopSystem.getIconPath( currency.source );
            }else {
                pClubWelfareBagSendItemViewUI.txt_totalValue.text = String( luckyBagConfig.counts );
//                pClubWelfareBagSendItemViewUI.reward.visible = false;
//                pClubWelfareBagSendItemViewUI.reward_list_1.visible = true;

//                m_viewExternal = new CViewExternalUtil(CRewardItemListView, this, pClubWelfareBagSendItemViewUI);
//                (m_viewExternal.view as CRewardItemListView).ui = pClubWelfareBagSendItemViewUI.reward_list_1;
//                m_viewExternal.show();
//                m_viewExternal.setData( luckyBagConfig.totalValue );
//                m_viewExternal.updateWindow();

                var packageTable:CDataTable = _pCDatabaseSystem.getTable(KOFTableConstants.DROP_PACKAGE) as CDataTable;
                var packageData:DropPackage = packageTable.findByPrimaryKey( luckyBagConfig.totalValue ) as DropPackage;
                pClubWelfareBagSendItemViewUI.img_icon_3.toolTip = new Handler( showTips, [ packageData.resourceID1 ] );
            }


            m_viewExternal = new CViewExternalUtil(CRewardItemListView, this, pClubWelfareBagSendItemViewUI);
            m_viewExternal.show();
            m_viewExternal.setData( luckyBagConfig.buyLuckyBagReward );
            m_viewExternal.updateWindow();

            pClubWelfareBagSendItemViewUI.btn_send.clickHandler = new Handler( _onSendBagHandler,[luckyBagConfig]);
        }
    }
    private function showTips( id : int ) : void {
        (system.stage.getSystem(CItemSystem) as CItemSystem).addTips(CItemTipsView,null,[id]);
    }
    private function selectItemHandler( index : int ) : void {
        var pClubWelfareBagSendItemViewUI : ClubWelfareBagSendItemViewUI = _clubWelfareBagSendViewUI.list.getCell( index ) as ClubWelfareBagSendItemViewUI;
        if ( !pClubWelfareBagSendItemViewUI )
            return;

    }
    private function _onSendBagHandler(...args):void{
        var luckyBagConfig : LuckyBagConfig = args[0] as LuckyBagConfig;
        var dName : String = '';
        luckyBagConfig.subtype == CClubConst.BAG_GOLD_TYPE ? dName = '绑钻': dName = '钻石';
        if( luckyBagConfig.subtype == CClubConst.BAG_GOLD_TYPE ){
            _pCUISystem.showMsgBox( '需要消耗' + luckyBagConfig.consumeValue + dName + '，确定继续吗？',okFun,null,true,null,null,true,"COST_BIND_D");
        }else{
            _pCUISystem.showMsgBox( '需要消耗' + luckyBagConfig.consumeValue + dName + '，确定继续吗？',okFunII,null,true,null,null,true,"COST_DIAMOND" );
        }

        function okFun():void{
            (system.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem).showCostBdDiamondMsgBox( luckyBagConfig.consumeValue, onRefreshCallUpRequest );
        }
        function okFunII():void{
            if( _playerData.currency.blueDiamond < luckyBagConfig.consumeValue ){
//                _pCUISystem.showMsgBox( '钻石不足！' );

                var bundleCtx2:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
                var systemBundle2:ISystemBundle = bundleCtx2.getSystemBundle(SYSTEM_ID(KOFSysTags.PAY));
                bundleCtx2.setUserData(systemBundle2, CBundleSystem.ACTIVATED, true);
                (system.stage.getSystem(IUICanvas) as IUICanvas).showMsgAlert("很抱歉，您的钻石不足，请前往获得");

            }else{
                onRefreshCallUpRequest();
            }
        }
        function onRefreshCallUpRequest():void{
            var luckyBagConfig : LuckyBagConfig = args[0] as LuckyBagConfig;
            _pClubHandler.onSendLuckyBagRequest( luckyBagConfig.ID );
        }
    }

    public function addDisplay( selectedIndex : int ) : void {
        _selectedIndex = selectedIndex;
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
        _clubWelfareBagSendViewUI.clip_title.index = _selectedIndex - 1;
        _addEventListeners();
        _clubWelfareBagSendViewUI.list.dataSource = _pClubManager.getUserBagListByType( _selectedIndex );
        uiCanvas.addPopupDialog( _clubWelfareBagSendViewUI );
    }
    public function removeDisplay() : void {
        if ( _clubWelfareBagSendViewUI ) {
            _clubWelfareBagSendViewUI.close( Dialog.CLOSE );
        }
    }
    private function _addEventListeners():void{
        _removeEventListeners();
    }
    private function _removeEventListeners():void{
    }

    private function _onClose( type : String ) : void {
        switch ( type ) {
            default:
                break;
        }
        _removeEventListeners();
    }

    private function get _pClubHandler() : CClubHandler {
        return system.getBean( CClubHandler ) as CClubHandler;
    }
    private function get _pClubManager() : CClubManager {
        return system.getBean( CClubManager ) as CClubManager;
    }
    private function get _pCShopSystem() : CShopSystem {
        return system.stage.getBean( CShopSystem ) as CShopSystem;
    }
    private function get _pCDatabaseSystem():CDatabaseSystem{
        return system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }
    private function get _pCUISystem():CUISystem{
        return system.stage.getSystem( CUISystem ) as CUISystem;
    }
    private function get _playerData() : CPlayerData {
        return ( _playerSystem.getBean( CPlayerManager ) as CPlayerManager ).playerData;
    }
    private function get _playerSystem() : CPlayerSystem {
        return system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }


}
}
