//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2018/1/3.
 */
package kof.game.invest {

import flash.events.Event;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.game.KOFSysTags;
import kof.game.common.view.CTweenViewHandler;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.player.event.CPlayerEvent;
import kof.message.Invest.InvestDataResponse;
import kof.message.Invest.InvestObtainRewardResponse;
import kof.message.Invest.InvestResponse;
import kof.table.InvestConst;
import kof.table.InvestRewardConfig;
import kof.ui.CUISystem;
import kof.ui.master.invest.InvestItemUI;
import kof.ui.master.invest.InvestUI;

import morn.core.components.Component;

import morn.core.components.Dialog;
import morn.core.events.UIEvent;
import morn.core.handlers.Handler;

public class CInvestViewHandler extends CTweenViewHandler {

    private var m_bViewInitialized : Boolean;
    
    private var m_investUI : InvestUI;

    private var m_pCloseHandler : Handler;

    public function CInvestViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }

    override public function dispose() : void {
        super.dispose();

        removeDisplay();
        m_investUI = null;
    }
    override public function get viewClass() : Array {
        return [ InvestUI ];
    }
    override protected function get additionalAssets() : Array {
        return [
            "invest.swf"
        ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !m_bViewInitialized ) {
            if ( !m_investUI ) {
                m_investUI = new InvestUI();

                m_investUI.btn_invest.clickHandler = new Handler( _onInvestRequest );
                m_investUI.btn_lookView.clickHandler = new Handler( _onLookView );
                m_investUI.btn_return.clickHandler = new Handler( _onReturn );
                m_investUI.list.renderHandler = new Handler( renderItem );
                m_investUI.list.addEventListener( UIEvent.ITEM_RENDER, _onListData );

                m_investUI.closeHandler = new Handler( _onClose );

                _initList();

                m_bViewInitialized = true;
            }
        }

        return m_bViewInitialized;
    }


    public function get closeHandler() : Handler {
        return m_pCloseHandler;
    }

    public function set closeHandler( value : Handler ) : void {
        m_pCloseHandler = value;
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
    private function _addToDisplay() : void {
        _addEventListeners();
        _pInvestHandler.onInvestDataRequest();
    }
    public function removeDisplay() : void {
        closeDialog();
    }
    public function _removeDisplayB() : void {
        if ( m_investUI ) {
            _removeEventListeners();
        }
    }

    private function _onClose( type : String ) : void {
        switch ( type ) {
            default:
                if ( this.closeHandler ) {
                    this.closeHandler.execute();
                }
                break;
        }
        _removeEventListeners();
    }

    private function renderItem( item : Component, idx : int ) : void {
        if ( !(item is InvestItemUI) ) {
            return;
        }
        var pInvestItemUI : InvestItemUI = item as InvestItemUI;
        if( pInvestItemUI.dataSource ){
            var investRewardConfig : InvestRewardConfig = pInvestItemUI.dataSource as InvestRewardConfig;
            pInvestItemUI.txt_pre.text = int( investRewardConfig.ratio * 100 ) + "%";
            pInvestItemUI.txt_condition_0.visible = investRewardConfig.level == 0;
            pInvestItemUI.box_condition.visible = investRewardConfig.level != 0;
            pInvestItemUI.txt_condition.text = String( investRewardConfig.level );
            pInvestItemUI.txt_value.text = String( investRewardConfig.num );
//            pInvestItemUI.img_d_2.visible = investRewardConfig.currencyType == 2;
//            pInvestItemUI.img_d_3.visible = investRewardConfig.currencyType == 3;
            pInvestItemUI.btn_get.clickHandler = new Handler( _onItemCkHandler,[investRewardConfig])
        }
    }
    private function _onListData( evt : UIEvent = null ):void{
        var pInvestItemUI : InvestItemUI;
        for each ( pInvestItemUI in m_investUI.list.cells ){
            if( pInvestItemUI.dataSource ){
                pInvestItemUI.img_redPoint.visible = false;
                var investRewardConfig : InvestRewardConfig = pInvestItemUI.dataSource as InvestRewardConfig;
                var obj : Object = _pInvestManager.getObtainedObjById( investRewardConfig.ID );
                if( obj && obj.obtained == true ){
                    pInvestItemUI.btn_get.visible = false;
                    pInvestItemUI.img_got.visible = true;
                }else{
                    pInvestItemUI.btn_get.visible = true;
                    pInvestItemUI.img_got.visible = false;
                    if( _pInvestManager.m_hasPut && _playerData.teamData.level >= investRewardConfig.level ){
                        pInvestItemUI.img_redPoint.visible = true;
                    }
                }
            }
        }
    }

    //打开界面初始数据返回
    private function _onInvestInitDataHandler( evt : CInvestEvent ):void{
        var response : InvestDataResponse = evt.data as InvestDataResponse;
        _onViewInit( response.hadPut );
        _onListData();
        if ( m_investUI && !m_investUI.parent ) {
//            uiCanvas.addDialog( m_investUI );
            setTweenData(KOFSysTags.INVEST);
            showDialog(m_investUI);
        }
    }

    private function _onViewInit( hadPut : Boolean ):void{
        if( hadPut ){//已经投资
            m_investUI.img_before.visible = false;
            m_investUI.btn_lookView.visible = false;
            m_investUI.btn_return.visible = false;
            m_investUI.box_invest.visible = false;
            m_investUI.box_afterInvest.visible = true;
            m_investUI.box_list.visible = true;
        }else {//未投资
            m_investUI.btn_lookView.visible = true;
            m_investUI.btn_return.visible = false;
            m_investUI.img_before.visible = true;
            m_investUI.box_list.visible = false;
            m_investUI.box_invest.visible = true;
            m_investUI.box_afterInvest.visible = false;
        }
    }
    private function _initList( evt : CPlayerEvent = null ):void{
        var pTable : IDataTable;
        pTable = _pCDatabaseSystem.getTable( KOFTableConstants.INVESTREWARDCONFIG );
        m_investUI.list.dataSource = pTable.toArray();


//        var investRewardConfig : InvestRewardConfig = pTable.findByPrimaryKey(1);
//        m_investUI.txt_lv0Award.text = String( investRewardConfig.num );
//        m_investUI.img_d_2.visible = investRewardConfig.currencyType == 2;
//        m_investUI.img_d_3.visible = investRewardConfig.currencyType == 3;

        pTable = _pCDatabaseSystem.getTable( KOFTableConstants.INVESTCONST );
        var investConst : InvestConst = pTable.findByPrimaryKey( 1 );
        m_investUI.txt_condittion.text = "( <font color='#f2ff88'>" + investConst.levelLimit + "</font> 级及以下玩家可购买,还差 <font color='#f2ff88'>"
                + ( investConst.levelLimit -_playerData.teamData.level ) + " </font>级就无法购买了 )";


    }

    //投资请求
    private function _onInvestRequest():void{
        var pTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.INVESTCONST );
        var investConst : InvestConst = pTable.findByPrimaryKey( 1 );

        _pCUISystem.showMsgBox( '确定花费' + investConst.inputNum + '钻石投资吗？投资后将获得超值回报。',okFun,null,true,null,null,true,"COST_DIAMOND");
        function okFun():void{
            _pInvestHandler.onInvestRequest();
        }
    }

    //投资之后数据返回
    private function _onInvestDataHandler( evt : CInvestEvent ):void {
        var response : InvestResponse = evt.data as InvestResponse;
        _onViewInit( _pInvestManager.m_hasPut );
        _onListData();
    }
    //领取奖励请求
    private function _onItemCkHandler( ...args ):void{
        var investRewardConfig : InvestRewardConfig = args[0] as InvestRewardConfig;
        if( _pInvestManager.m_hasPut == false ){
            _onInvestRequest();
        }else{
            if( _playerData.teamData.level >= investRewardConfig.level ){
                _pInvestHandler.onInvestObtainRewardRequest( investRewardConfig.ID );
            }else{
                _pCUISystem.showMsgAlert( '等级尚未达到' );
            }

        }
    }
    //领取奖励返回
    private function _onInvestGetAwardHandler( evt : CInvestEvent ):void {
        var response : InvestObtainRewardResponse = evt.data as InvestObtainRewardResponse;

        _onListData();
        _pCUISystem.showMsgAlert( '领取奖励成功' );
    }


    private function _onLookView():void{

        m_investUI.btn_lookView.visible = false;
        m_investUI.btn_return.visible = true;

        m_investUI.img_before.visible = false;
        m_investUI.box_list.visible = true;
    }
    private function _onReturn():void{

        m_investUI.btn_lookView.visible = true;
        m_investUI.btn_return.visible = false;

        m_investUI.img_before.visible = true;
        m_investUI.box_list.visible = false;
    }

    private function _updateData( evt : CPlayerEvent ):void {
        _onListData();
    }

    private function _addEventListeners():void {
        _removeEventListeners();
        system.addEventListener( CInvestEvent.SHOW_INVEST_VIEW, _onInvestInitDataHandler );
        system.addEventListener( CInvestEvent.INVEST_DATA_RESPONSE, _onInvestDataHandler );
        system.addEventListener( CInvestEvent.INVEST_GET_AWARD_RESPONSE, _onInvestGetAwardHandler );

        _playerSystem.addEventListener( CPlayerEvent.PLAYER_TEAM ,_updateData );
        _playerSystem.addEventListener( CPlayerEvent.PLAYER_LEVEL_UP ,_initList );
    }
    private function _removeEventListeners():void{
        system.removeEventListener( CInvestEvent.SHOW_INVEST_VIEW ,_onInvestInitDataHandler );
        system.removeEventListener( CInvestEvent.INVEST_DATA_RESPONSE ,_onInvestDataHandler );
        system.removeEventListener( CInvestEvent.INVEST_GET_AWARD_RESPONSE ,_onInvestGetAwardHandler );


        _playerSystem.removeEventListener( CPlayerEvent.PLAYER_TEAM ,_updateData );
        _playerSystem.addEventListener( CPlayerEvent.PLAYER_LEVEL_UP ,_initList );
    }

    private function get _pInvestHandler():CInvestHandler{
        return system.getBean( CInvestHandler ) as CInvestHandler;
    }
    private function get _pInvestManager():CInvestManager{
        return system.getBean( CInvestManager ) as CInvestManager;
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

    public function get investUI() : InvestUI {
        return m_investUI;
    }
}
}
