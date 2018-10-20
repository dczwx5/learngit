//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/6/13.
 */
package kof.game.club.view.welfarebag {

import QFLib.Foundation.CTime;

import flash.events.MouseEvent;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.game.club.CClubEvent;
import kof.game.club.CClubHandler;
import kof.game.club.CClubManager;
import kof.game.club.data.CClubConst;
import kof.game.club.data.CClubWelfareBagData;
import kof.game.club.view.CClubWelfareBagViewHandler;
import kof.game.player.config.CPlayerPath;
import kof.message.Club.GetLuckyBagResponse;
import kof.table.ClubConstant;
import kof.ui.master.club.ClubWelfareBagGetItemUI;
import kof.ui.master.club.ClubWelfareBagGetUI;

import morn.core.components.Component;
import morn.core.components.Label;
import morn.core.handlers.Handler;

public class CClubWelfareBagGetViewHandler extends CViewHandler {

    private var _clubWelfareBagGetUI : ClubWelfareBagGetUI;

    private var _updateAry : Array;

    private var _curClubWelfareBagData : CClubWelfareBagData;

    public function CClubWelfareBagGetViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }
    public function updateView( clubWelfareBagGetUI : ClubWelfareBagGetUI ):void{
        _clubWelfareBagGetUI = clubWelfareBagGetUI;

        _updateAry = [];
        unschedule( updateTime );
        schedule( 1, updateTime );

        _clubWelfareBagGetUI.list.renderHandler = new Handler( renderItem );
        _clubWelfareBagGetUI.list.selectHandler = new Handler( selectItemHandler );
        var userWelfareBagAry : Array = _pClubManager.userWelfareBagAry;
        userWelfareBagAry.sortOn(["luckyBagState","configID","type","expireTime"], [ Array.NUMERIC|Array.CASEINSENSITIVE,Array.NUMERIC|Array.DESCENDING,Array.NUMERIC|Array.DESCENDING, Array.NUMERIC|Array.DESCENDING]);
        _clubWelfareBagGetUI.list.dataSource = userWelfareBagAry;
        _onRedPoint();
        _onNoTips();

        var pTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.CLUBCONSTANT );
        var clubConstant : ClubConstant =  pTable.findByPrimaryKey(1);
        _clubWelfareBagGetUI.txt_num.text = '今日已抢福袋次数：' + _pClubManager.getUserBagCounts + '/' + clubConstant.getPlayerBagTimes;

        _clubWelfareBagGetUI.btn_left.clickHandler = new Handler(_onPageChange,[_clubWelfareBagGetUI.btn_left]);
        _clubWelfareBagGetUI.btn_right.clickHandler = new Handler(_onPageChange,[_clubWelfareBagGetUI.btn_right]);

        _clubWelfareBagGetUI.btn_link.clickHandler = new Handler( _onGotoSendBag );

        _clubWelfareBagGetUI.list.page = 0;
        _pageBtnDisable();

        _addEventListeners();

    }
    private function renderItem(item:Component, idx:int):void {
        if ( !(item is ClubWelfareBagGetItemUI) ) {
            return;
        }
        var pClubWelfareBagGetItemUI : ClubWelfareBagGetItemUI = item as ClubWelfareBagGetItemUI;
        var index : int;
        if ( pClubWelfareBagGetItemUI.dataSource ) {
            var pClubWelfareBagData : CClubWelfareBagData = pClubWelfareBagGetItemUI.dataSource as CClubWelfareBagData;
            if( pClubWelfareBagData.type == CClubConst.BAG_PLAYER ){
                for( index = CClubConst.BAG_GOLD_TYPE ; index <= CClubConst.BAG_ITEM_TYPE ; index++ ){
                    pClubWelfareBagGetItemUI['box_' + index ].visible = pClubWelfareBagData.itemType == index;
                }
                for( index = CClubConst.BAG_RECHARGE_SMALL ; index <= CClubConst.BAG_RECHARGE_BIG ; index++ ){
                    pClubWelfareBagGetItemUI['box_recharge_' + index ].visible = false;
                }

                pClubWelfareBagGetItemUI.txt_name.text = pClubWelfareBagData.name;
                if( pClubWelfareBagData.luckyBagState == CClubConst.CLUB_BAG_CAN_GET ){
                    pClubWelfareBagGetItemUI.box_getInfo.visible =
                            pClubWelfareBagGetItemUI.btn_get.visible = true;
                    pClubWelfareBagGetItemUI.clip_state.visible = false;
                    pClubWelfareBagGetItemUI.btn_log.visible = false;
                    pClubWelfareBagGetItemUI.txt_time.text = "剩余时间："  + CTime.toDurTimeString( pClubWelfareBagData.expireTime - CTime.getCurrServerTimestamp() );
                    pClubWelfareBagGetItemUI.txt_num.text = "剩余福袋数：" + pClubWelfareBagData.rewardNum + '/' + pClubWelfareBagData.totalNum ;

                    var objT : Object = {};
                    objT.label = pClubWelfareBagGetItemUI.txt_time;
                    objT.expireTime = pClubWelfareBagData.expireTime;
                    _updateAry.push( objT );
                }else{
                    pClubWelfareBagGetItemUI.box_getInfo.visible =
                            pClubWelfareBagGetItemUI.btn_get.visible = false;
                    pClubWelfareBagGetItemUI.btn_log.visible = true;

                    pClubWelfareBagGetItemUI.clip_state.visible = true;
                    if( pClubWelfareBagData.luckyBagState == CClubConst.CLUB_BAG_GOT ){
                        pClubWelfareBagGetItemUI.clip_state.index = 0;
                    }else if( pClubWelfareBagData.luckyBagState == CClubConst.CLUB_BAG_NO_LESS ){
                        pClubWelfareBagGetItemUI.clip_state.index = 1;
                    }
                }

                pClubWelfareBagGetItemUI.btn_log.clickHandler = new Handler( _onLogCkHandler,[pClubWelfareBagData]);

            }else if( pClubWelfareBagData.type == CClubConst.BAG_RECHARGE ){
                for( index = CClubConst.BAG_RECHARGE_SMALL ; index <= CClubConst.BAG_RECHARGE_BIG ; index++ ){
                    pClubWelfareBagGetItemUI['box_recharge_' + index ].visible = pClubWelfareBagData.configID - 10 == index;
                }
                for( index = CClubConst.BAG_GOLD_TYPE ; index <= CClubConst.BAG_ITEM_TYPE ; index++ ){
                    pClubWelfareBagGetItemUI['box_' + index ].visible = false;
                }

                pClubWelfareBagGetItemUI.btn_get.visible = pClubWelfareBagData.luckyBagState == CClubConst.CLUB_BAG_CAN_GET;
                pClubWelfareBagGetItemUI.clip_state.visible = pClubWelfareBagData.luckyBagState != CClubConst.CLUB_BAG_CAN_GET;

                if( pClubWelfareBagGetItemUI.clip_state.visible ){
                    if( pClubWelfareBagData.luckyBagState == CClubConst.CLUB_BAG_GOT ){
                        pClubWelfareBagGetItemUI.clip_state.index = 0;
                    }else if( pClubWelfareBagData.luckyBagState == CClubConst.CLUB_BAG_NO_LESS ){
                        pClubWelfareBagGetItemUI.clip_state.index = 1;
                    }
                }

                if( pClubWelfareBagData.configID >= 10 ){
                    var itemIndex : int = pClubWelfareBagData.configID - 10;
                    pClubWelfareBagGetItemUI['txt_recharge_name_' + itemIndex ].text = pClubWelfareBagData.name;
                    pClubWelfareBagGetItemUI['txt_recharge_num_' + itemIndex ].text = '剩余福袋个数：' + pClubWelfareBagData.rewardNum + '/' + pClubWelfareBagData.totalNum ;
                    pClubWelfareBagGetItemUI['icon_image_' + itemIndex].mask = pClubWelfareBagGetItemUI['hero_icon_mask_' + itemIndex];
                    pClubWelfareBagGetItemUI['icon_image_' + itemIndex].url = CPlayerPath.getUIHeroIconMiddlePath( pClubWelfareBagData.headId  );

                    pClubWelfareBagGetItemUI['btn_recharge_log_' + itemIndex ].clickHandler = new Handler( _onLogCkHandler,[pClubWelfareBagData]);
                    pClubWelfareBagGetItemUI['btn_recharge_log_' + itemIndex ].visible = pClubWelfareBagData.luckyBagState != CClubConst.CLUB_BAG_CAN_GET;
                }

            }


            pClubWelfareBagGetItemUI.btn_get.clickHandler = new Handler( _onGetCkHandler,[pClubWelfareBagData]);

        }
    }
    private function selectItemHandler( index : int ) : void {
        var pClubWelfareBagGetItemUI : ClubWelfareBagGetItemUI = _clubWelfareBagGetUI.list.getCell( index ) as ClubWelfareBagGetItemUI;
        if ( !pClubWelfareBagGetItemUI )
            return;

    }
    private function updateTime( delta : Number ):void{
        var objT : Object;
        for each ( objT in _updateAry ){
            if( objT.expireTime - CTime.getCurrServerTimestamp() <= 0 ){
                _updateAry.splice( _updateAry.indexOf( objT ) , 1 );
                objT.label.text = "剩余时间：0";
            }else {
                objT.label.text = "剩余时间："  + CTime.toDurTimeString( objT.expireTime - CTime.getCurrServerTimestamp() );
            }
        }
    }
    private function updateItemTime( label : Label , expireTime : Number ):void{
        label.text = "剩余时间："  + CTime.toDurTimeString( expireTime - CTime.getCurrServerTimestamp() );
    }
    private function _onPageChange(...args):void{
        switch ( args[0] ) {
            case _clubWelfareBagGetUI.btn_left:{
                if( _clubWelfareBagGetUI.list.page <= 0 )
                    return;
                _clubWelfareBagGetUI.list.page --;
                break
            }
            case _clubWelfareBagGetUI.btn_right:{
                if( _clubWelfareBagGetUI.list.page >= _clubWelfareBagGetUI.list.totalPage )
                    return;
                _clubWelfareBagGetUI.list.page ++;
                break
            }
        }
        _pageBtnDisable();
    }
    private function _pageBtnDisable():void{
        _clubWelfareBagGetUI.btn_left.disabled =
                        _clubWelfareBagGetUI.list.page <= 0;
        _clubWelfareBagGetUI.btn_right.disabled =
                        _clubWelfareBagGetUI.list.page >= _clubWelfareBagGetUI.list.totalPage - 1;
    }
    private function _onGetCkHandler(...args):void{
        _curClubWelfareBagData = args[0] as CClubWelfareBagData;
        _pClubHandler.onGetLuckyBagRequest( _curClubWelfareBagData.type, _curClubWelfareBagData.ID );
    }
    private function _onLogCkHandler(...args):void{
        var pClubWelfareBagData : CClubWelfareBagData = args[0] as CClubWelfareBagData;
        _pClubSingleBagLogViewHandler.addDisplay( pClubWelfareBagData );
    }

    public function updateCurItem( ID : String ):void{
        var userWelfareBagAry : Array = _pClubManager.userWelfareBagAry;
        userWelfareBagAry.sortOn(["luckyBagState","configID","type","expireTime"], [ Array.NUMERIC|Array.CASEINSENSITIVE,Array.NUMERIC|Array.DESCENDING,Array.NUMERIC|Array.DESCENDING, Array.NUMERIC|Array.DESCENDING]);
        _clubWelfareBagGetUI.list.dataSource = userWelfareBagAry;
        _onRedPoint();
        _onNoTips();
        var pTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.CLUBCONSTANT );
        var clubConstant : ClubConstant =  pTable.findByPrimaryKey(1);
        _clubWelfareBagGetUI.txt_num.text = '今日已抢福袋次数：' + _pClubManager.getUserBagCounts + '/' + clubConstant.getPlayerBagTimes;
    }
    private function _onSelfLogHandler( evt : MouseEvent ):void{
        _pClubSelfBagLogViewHandler.addDisplay();
    }
    private function _onGotoSendBag( ):void{
        _pClubWelfareBagViewHandler.setTabIndex( CClubConst.CLUB_BAG_SEND );
    }
    private function _getBagResponse( evt : CClubEvent ):void{
        var response:GetLuckyBagResponse = evt.data as GetLuckyBagResponse;
        if( response.type == CClubConst.USER_BAG_LIST  || response.type == CClubConst.RECHARGE_BAG_LIST ){
            _pClubSingleBagLogViewHandler.addDisplay( _curClubWelfareBagData );
        }
    }
    private function _addEventListeners():void{
        _removeEventListeners();
        _clubWelfareBagGetUI.txt_log.addEventListener( MouseEvent.CLICK, _onSelfLogHandler ,false, 0, true);

        system.addEventListener( CClubEvent.GET_LUCKY_BAG_RESPONSE ,_getBagResponse );
    }
    private function _removeEventListeners():void{
        _clubWelfareBagGetUI.txt_log.removeEventListener( MouseEvent.CLICK, _onSelfLogHandler );
        system.removeEventListener( CClubEvent.GET_LUCKY_BAG_RESPONSE ,_getBagResponse );
    }
    private function _onRedPoint():void{
        var userWelfareBagAry : Array = _clubWelfareBagGetUI.list.dataSource as Array;
        var pClubWelfareBagData : CClubWelfareBagData;
        for each( pClubWelfareBagData in userWelfareBagAry ){
            if( pClubWelfareBagData.luckyBagState == CClubConst.CLUB_BAG_CAN_GET ){
                _pClubManager.playerLuckyBagState = 1;
                break;
            }
            _pClubManager.playerLuckyBagState = 0;
        }
        _pClubWelfareBagViewHandler.m__clubWelfareBagUI.img_red2.visible = _pClubManager.playerLuckyBagState ;
    }
    private function _onNoTips():void{
        _clubWelfareBagGetUI.box_notips.visible = _clubWelfareBagGetUI.list.dataSource <= 0;
    }
    private function get _pClubHandler() : CClubHandler {
        return system.getBean( CClubHandler ) as CClubHandler;
    }
    private function get _pClubManager() : CClubManager {
        return system.getBean( CClubManager ) as CClubManager;
    }
    private function get _pClubSingleBagLogViewHandler() : CClubSingleBagLogViewHandler {
        return system.getBean( CClubSingleBagLogViewHandler ) as CClubSingleBagLogViewHandler;
    }
    private function get _pClubSelfBagLogViewHandler() : CClubSelfBagLogViewHandler {
        return system.getBean( CClubSelfBagLogViewHandler ) as CClubSelfBagLogViewHandler;
    }
    private function get _pClubWelfareBagViewHandler() : CClubWelfareBagViewHandler {
        return system.getBean( CClubWelfareBagViewHandler ) as CClubWelfareBagViewHandler;
    }

    private function get _pCDatabaseSystem():CDatabaseSystem{
        return system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }
    override public function dispose() : void {
        super.dispose();
        _removeEventListeners();
    }

}
}
