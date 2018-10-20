//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/6/14.
 * 抢红包排行榜
 */
package kof.game.club.view.welfarebag {

import kof.framework.CViewHandler;
import kof.game.club.CClubEvent;
import kof.game.club.CClubHandler;
import kof.game.club.CClubManager;
import kof.game.club.data.CClubBagRecordData;
import kof.game.club.data.CClubConst;
import kof.game.club.data.CClubConst;
import kof.game.club.data.CClubWelfareBagData;
import kof.game.common.view.CViewExternalUtil;
import kof.ui.master.club.ClubGetWelfareBagLogItemUI;
import kof.ui.master.club.ClubGetWelfareBagLogUI;

import morn.core.components.Component;
import morn.core.components.Dialog;
import morn.core.handlers.Handler;

public class CClubGetWelfareBagLogViewHandler extends CViewHandler {

    private var _clubGetWelfareBagLogUI:ClubGetWelfareBagLogUI;

    private var m_viewExternal:CViewExternalUtil;

    private var _defultType:int;

    public function CClubGetWelfareBagLogViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }
    override public function get viewClass() : Array {
        return [ ClubGetWelfareBagLogUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if( !_clubGetWelfareBagLogUI ){
            _clubGetWelfareBagLogUI = new ClubGetWelfareBagLogUI();

            _clubGetWelfareBagLogUI.tab.selectHandler = new Handler( _onBtnTabSelectHandler );

            _clubGetWelfareBagLogUI.list.renderHandler = new Handler( renderItem );
            _clubGetWelfareBagLogUI.list.selectHandler = new Handler( selectItemHandler );
            _clubGetWelfareBagLogUI.list.dataSource = [];


            _clubGetWelfareBagLogUI.closeHandler = new Handler( _onClose );
        }

        return Boolean( _clubGetWelfareBagLogUI );
    }
    private function _onBtnTabSelectHandler( index : int ):void{
        var clubWelfareBagData : CClubWelfareBagData;
        if( index == CClubConst.BAG_LOG_GOLD_TYPE ){
            clubWelfareBagData = _pClubManager.getClubSystemBagDataByType( CClubConst.BAG_GOLD_TYPE );
        }else if(  index == CClubConst.BAG_LOG_DIAMONDS_TYPE ){
            clubWelfareBagData = _pClubManager.getClubSystemBagDataByType( CClubConst.BAG_DIAMONDS_TYPE );
        }else if(  index == CClubConst.BAG_LOG_ITEM_TYPE ){
            clubWelfareBagData = _pClubManager.getClubSystemBagDataByType( CClubConst.BAG_ITEM_TYPE );
        }else if(  index == CClubConst.BAG_LOG_RECHARGE_TYPE ){
//            clubWelfareBagData = _pClubManager.getClubSystemBagDataByType( CClubConst.BAG_LOG_RECHARGE_TYPE );
        }
        _pClubHandler.onLuckyBagRecordRequest( CClubConst.CLUB_BAG_LIST ,clubWelfareBagData.ID );
    }

    private function renderItem(item:Component, idx:int):void {
        if ( !(item is ClubGetWelfareBagLogItemUI) ) {
            return;
        }
        var pClubGetWelfareBagLogItemUI : ClubGetWelfareBagLogItemUI = item as ClubGetWelfareBagLogItemUI;
        if ( pClubGetWelfareBagLogItemUI.dataSource ) {
            var pClubBagRecordData : CClubBagRecordData =  pClubGetWelfareBagLogItemUI.dataSource as CClubBagRecordData;
            if( pClubBagRecordData.type == CClubConst.BAG_GOLD_TYPE || pClubBagRecordData.type == CClubConst.BAG_DIAMONDS_TYPE  ){
//                pClubGetWelfareBagLogItemUI.reward_list.visible = false;
                pClubGetWelfareBagLogItemUI.txt_num.text = String( pClubBagRecordData.record );
            }else{
//                pClubGetWelfareBagLogItemUI.reward_list.visible = true;
//                pClubGetWelfareBagLogItemUI.txt_num.visible = false;
//                m_viewExternal = new CViewExternalUtil(CRewardItemListView, this, pClubGetWelfareBagLogItemUI);
//                m_viewExternal.show();
//                m_viewExternal.setData( pClubBagRecordData.record );
//                m_viewExternal.updateWindow();
                pClubGetWelfareBagLogItemUI.txt_num.text = '1';
            }
            pClubGetWelfareBagLogItemUI.txt_name.text = pClubBagRecordData.name;
            pClubGetWelfareBagLogItemUI.img_vip.visible = pClubBagRecordData.vipLevel > 0;
            if( pClubBagRecordData.vipLevel > 0 )
                pClubGetWelfareBagLogItemUI.img_vip.index = pClubBagRecordData.vipLevel ;
        }
    }
    private function selectItemHandler( index : int ) : void {
        var pClubGetWelfareBagLogItemUI : ClubGetWelfareBagLogItemUI = _clubGetWelfareBagLogUI.list.getCell( index ) as ClubGetWelfareBagLogItemUI;
        if ( !pClubGetWelfareBagLogItemUI )
            return;

    }

    public function addDisplay( defultType : int ) : void {
        _defultType = defultType;
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
        _clubGetWelfareBagLogUI.img_best.visible = false;
        uiCanvas.addPopupDialog( _clubGetWelfareBagLogUI );
        _addEventListeners();
        _clubGetWelfareBagLogUI.list.dataSource = [];
        _clubGetWelfareBagLogUI.tab.selectedIndex = _defultType;
        _clubGetWelfareBagLogUI.tab.callLater( _onBtnTabSelectHandler,[_defultType]);
    }
    public function removeDisplay() : void {
        if ( _clubGetWelfareBagLogUI ) {
            _clubGetWelfareBagLogUI.close( Dialog.CLOSE );
        }
    }
    private function _onRecordResponseHandler(evt : CClubEvent ):void{
        _clubGetWelfareBagLogUI.list.dataSource = _pClubManager.systemBagLogList;
        _clubGetWelfareBagLogUI.img_best.visible = _pClubManager.systemBagLogList.length > 0;
        if( _clubGetWelfareBagLogUI.tab.selectedIndex == CClubConst.BAG_LOG_ITEM_TYPE )
            _clubGetWelfareBagLogUI.img_best.visible = false;
    }
    private function _addEventListeners():void{
        _removeEventListeners();
        system.addEventListener( CClubEvent.SYETEM_LUCKY_BAG_RECORD_RESPONSE , _onRecordResponseHandler );
    }
    private function _removeEventListeners():void{
        system.removeEventListener( CClubEvent.SYETEM_LUCKY_BAG_RECORD_RESPONSE , _onRecordResponseHandler );
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


}
}
