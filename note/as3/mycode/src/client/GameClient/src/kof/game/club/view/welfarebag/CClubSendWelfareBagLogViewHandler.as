//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/6/15.
 * 发红包排行
 */
package kof.game.club.view.welfarebag {

import kof.framework.CViewHandler;
import kof.game.club.CClubEvent;
import kof.game.club.CClubHandler;
import kof.game.club.CClubManager;
import kof.game.club.data.CClubConst;
import kof.game.club.data.CClubSendBagRankData;
import kof.message.Club.SendLuckyBagRankResponse;
import kof.ui.master.club.ClubSendWelfareBagLogItemUI;
import kof.ui.master.club.ClubSendWelfareBagLogUI;

import morn.core.components.Component;
import morn.core.components.Dialog;
import morn.core.handlers.Handler;

public class CClubSendWelfareBagLogViewHandler extends CViewHandler {

    private var _clubSendWelfareBagLogUI:ClubSendWelfareBagLogUI;

    public function CClubSendWelfareBagLogViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array {
        return [ ClubSendWelfareBagLogUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if( !_clubSendWelfareBagLogUI ){
            _clubSendWelfareBagLogUI = new ClubSendWelfareBagLogUI();

            _clubSendWelfareBagLogUI.tab.selectHandler = new Handler( _onBtnTabSelectHandler );

            _clubSendWelfareBagLogUI.list.renderHandler = new Handler( renderItem );
            _clubSendWelfareBagLogUI.list.selectHandler = new Handler( selectItemHandler );
            _clubSendWelfareBagLogUI.list.dataSource = [];


            _clubSendWelfareBagLogUI.closeHandler = new Handler( _onClose );
        }

        return Boolean( _clubSendWelfareBagLogUI );
    }

    private function _onBtnTabSelectHandler( index : int ):void{
        var type : int;
        if( index == CClubConst.BAG_LOG_GOLD_TYPE ){
            type = CClubConst.BAG_GOLD_TYPE ;
        }else if(  index == CClubConst.BAG_LOG_DIAMONDS_TYPE ){
            type = CClubConst.BAG_DIAMONDS_TYPE ;
        }else if(  index == CClubConst.BAG_LOG_ITEM_TYPE ){
            type = CClubConst.BAG_ITEM_TYPE ;
        }else if(  index == CClubConst.BAG_LOG_RECHARGE_TYPE ){
            type = CClubConst.BAG_RECHARGE_TYPE ;
        }
        _pClubHandler.onSendLuckyBagRankRequest( type );

        for( var indexI : int = CClubConst.BAG_LOG_GOLD_TYPE + 1; indexI <= CClubConst.BAG_LOG_RECHARGE_TYPE ; indexI++ ) {
            _clubSendWelfareBagLogUI['img_iconI_' + indexI ].visible = _clubSendWelfareBagLogUI.tab.selectedIndex + 1 == indexI;
        }
    }

    private function renderItem(item:Component, idx:int):void {
        if ( !(item is ClubSendWelfareBagLogItemUI) ) {
            return;
        }
        var pClubSendWelfareBagLogItemUI : ClubSendWelfareBagLogItemUI = item as ClubSendWelfareBagLogItemUI;
        var pClubSendBagRankData : CClubSendBagRankData;
        var dataSource : Array;
        var rank :int;
        if ( pClubSendWelfareBagLogItemUI.dataSource ) {
            pClubSendBagRankData = pClubSendWelfareBagLogItemUI.dataSource as CClubSendBagRankData;
            dataSource = _clubSendWelfareBagLogUI.list.dataSource as Array;
            rank = dataSource.indexOf( pClubSendBagRankData );
            pClubSendWelfareBagLogItemUI.clip_rank.visible = rank <= 2;
            if( pClubSendWelfareBagLogItemUI.clip_rank.visible)
                pClubSendWelfareBagLogItemUI.clip_rank.index = rank;
            pClubSendWelfareBagLogItemUI.txt_rank.visible = rank > 2;
            if( pClubSendWelfareBagLogItemUI.txt_rank.visible )
                pClubSendWelfareBagLogItemUI.txt_rank.text = String( rank + 1);
            pClubSendWelfareBagLogItemUI.txt_name.text = pClubSendBagRankData.name;
            pClubSendWelfareBagLogItemUI.txt_num.text = String( pClubSendBagRankData.totalCounts );
            pClubSendWelfareBagLogItemUI.txt_value.text = String( pClubSendBagRankData.totalValue );

            for( var index : int = CClubConst.BAG_LOG_GOLD_TYPE + 1; index <= CClubConst.BAG_LOG_RECHARGE_TYPE ; index++ ) {
                pClubSendWelfareBagLogItemUI['img_iconI_' + index ].visible = _clubSendWelfareBagLogUI.tab.selectedIndex + 1 == index;
            }
            pClubSendWelfareBagLogItemUI.img_vip.visible = pClubSendBagRankData.vipLevel > 0;
            if( pClubSendBagRankData.vipLevel > 0 )
                pClubSendWelfareBagLogItemUI.img_vip.index = pClubSendBagRankData.vipLevel;
        }
    }
    private function selectItemHandler( index : int ) : void {
        var pClubSendWelfareBagLogItemUI : ClubSendWelfareBagLogItemUI = _clubSendWelfareBagLogUI.list.getCell( index ) as ClubSendWelfareBagLogItemUI;
        if ( !pClubSendWelfareBagLogItemUI )
            return;

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
    public function _addToDisplay( ):void {
        uiCanvas.addPopupDialog( _clubSendWelfareBagLogUI );
        _addEventListeners();
        _clubSendWelfareBagLogUI.tab.selectedIndex = 0;
        _clubSendWelfareBagLogUI.tab.callLater( _onBtnTabSelectHandler,[0]);
    }
    public function removeDisplay() : void {
        if ( _clubSendWelfareBagLogUI ) {
            _clubSendWelfareBagLogUI.close( Dialog.CLOSE );
        }
    }
    private function _onSendRankListResponseHandler( evt:CClubEvent ):void{
        var response : SendLuckyBagRankResponse =  evt.data as SendLuckyBagRankResponse;
        if( response.type == _clubSendWelfareBagLogUI.tab.selectedIndex + 1 ){
            _clubSendWelfareBagLogUI.list.dataSource = _pClubManager.userSendBagRankList;
            _clubSendWelfareBagLogUI.txt_num.text = String( response.playerRecord.totalCounts );
            _clubSendWelfareBagLogUI.txt_value.text = String( response.playerRecord.totalValue );
            _clubSendWelfareBagLogUI.box_self.visible = response.playerRecord.totalValue > 0;
        }


    }
    private function _addEventListeners():void{
        _removeEventListeners();
        system.addEventListener( CClubEvent.SEND_LUCKY_BAG_RANK_RESPONSE , _onSendRankListResponseHandler );
    }
    private function _removeEventListeners():void{
        system.removeEventListener( CClubEvent.SEND_LUCKY_BAG_RANK_RESPONSE , _onSendRankListResponseHandler );
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
