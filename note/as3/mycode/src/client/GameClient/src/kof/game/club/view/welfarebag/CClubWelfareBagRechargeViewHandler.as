//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2018/5/31.
 */
package kof.game.club.view.welfarebag {

import flash.events.MouseEvent;

import kof.SYSTEM_ID;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.club.CClubEvent;
import kof.game.club.CClubHandler;
import kof.game.club.CClubManager;
import kof.game.club.data.CClubConst;
import kof.game.club.view.CClubWelfareBagViewHandler;
import kof.message.Club.RechargeLuckyBagResponse;
import kof.table.LuckyBagConfig;
import kof.ui.master.club.ClubWelfareBagRechargeItemUI;
import kof.ui.master.club.ClubWelfareBagRechargeUI;

import morn.core.components.Component;

import morn.core.handlers.Handler;

public class CClubWelfareBagRechargeViewHandler extends CViewHandler {

    private var _clubWelfareBagRechargeUI : ClubWelfareBagRechargeUI;


    public function CClubWelfareBagRechargeViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }
    public function updateView( clubWelfareBagRechargeUI : ClubWelfareBagRechargeUI ):void{
        _clubWelfareBagRechargeUI = clubWelfareBagRechargeUI;

        _clubWelfareBagRechargeUI.list.dataSource = [];


        _clubWelfareBagRechargeUI.list.renderHandler = new Handler( renderItem );
        _clubWelfareBagRechargeUI.list.selectHandler = new Handler( selectItemHandler );
        _clubWelfareBagRechargeUI.list.dataSource = _pClubManager.rechargeLuckyBagAry;

        _clubWelfareBagRechargeUI.txt_bagNum.text = '当前可发福袋个数：' + _pClubManager.rechargeLuckyBagAry.length;
        _clubWelfareBagRechargeUI.txt_rechargeTips.visible = _pClubManager.rechargeLuckyBagAry.length <= 0;

        _clubWelfareBagRechargeUI.btn_recharge.clickHandler = new Handler( _onGotoRecharge );


        _clubWelfareBagRechargeUI.btn_left.clickHandler = new Handler(_onPageChange,[_clubWelfareBagRechargeUI.btn_left]);
        _clubWelfareBagRechargeUI.btn_right.clickHandler = new Handler(_onPageChange,[_clubWelfareBagRechargeUI.btn_right]);

        _clubWelfareBagRechargeUI.list.page = 0;
        _pageBtnDisable();

        _addEventListeners();

    }
    private function renderItem(item:Component, idx:int):void {
        if ( !(item is ClubWelfareBagRechargeItemUI) ) {
            return;
        }
        var pClubWelfareBagRechargeItemUI : ClubWelfareBagRechargeItemUI = item as ClubWelfareBagRechargeItemUI;
        var index : int;
        if ( pClubWelfareBagRechargeItemUI.dataSource ) {
            var bagObj : Object = pClubWelfareBagRechargeItemUI.dataSource;
            var j : int;
            for( j = CClubConst.BAG_RECHARGE_SMALL ; j <= CClubConst.BAG_RECHARGE_BIG ; j++ ){
                pClubWelfareBagRechargeItemUI['box_' + j ].visible = ( j == bagObj.bagType );
            }
            var typeID : int ;
            if( bagObj.bagType == CClubConst.BAG_RECHARGE_SMALL ){
                typeID = 10;
            }else if( bagObj.bagType == CClubConst.BAG_RECHARGE_MID ){
                typeID = 11;
            }else if( bagObj.bagType == CClubConst.BAG_RECHARGE_BIG ){
                typeID = 12;
            }
            var pTableLuckyBag : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.LUCKYBAGCONFIG );
            var luckyBagConfig : LuckyBagConfig = pTableLuckyBag.findByPrimaryKey( typeID );
            pClubWelfareBagRechargeItemUI['txt_' + bagObj.bagType ].text = String( luckyBagConfig.totalValue );

            pClubWelfareBagRechargeItemUI.btn_send.clickHandler = new Handler( _onSendBagHandler,[bagObj.configType ]);
        }
    }
    private function _onSendBagHandler(...args):void{
        var configType : int = args[0] as int;
        _pClubHandler.onSendLuckyBagRequest( configType );
    }
    private function selectItemHandler( index : int ) : void {
        var pClubWelfareBagRechargeItemUI : ClubWelfareBagRechargeItemUI = _clubWelfareBagRechargeUI.list.getCell( index ) as ClubWelfareBagRechargeItemUI;
        if ( !pClubWelfareBagRechargeItemUI )
            return;

    }

    private function _onPageChange(...args):void{
        switch ( args[0] ) {
            case _clubWelfareBagRechargeUI.btn_left:{
                if( _clubWelfareBagRechargeUI.list.page <= 0 )
                    return;
                _clubWelfareBagRechargeUI.list.page --;
                break
            }
            case _clubWelfareBagRechargeUI.btn_right:{
                if( _clubWelfareBagRechargeUI.list.page >= _clubWelfareBagRechargeUI.list.totalPage )
                    return;
                _clubWelfareBagRechargeUI.list.page ++;
                break
            }
        }
        _pageBtnDisable();
    }
    private function _pageBtnDisable():void{
        _clubWelfareBagRechargeUI.btn_left.disabled =
                _clubWelfareBagRechargeUI.list.page <= 0;
        _clubWelfareBagRechargeUI.btn_right.disabled =
                _clubWelfareBagRechargeUI.list.page >= _clubWelfareBagRechargeUI.list.totalPage - 1;
    }

    private function _onGotoRecharge( ):void{
        var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
        var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.PAY));
        bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);
    }

    private function _addEventListeners():void{
        _removeEventListeners();

//        system.addEventListener( CClubEvent.GET_LUCKY_BAG_RESPONSE ,_getBagResponse );
    }
    private function _removeEventListeners():void{
//        system.removeEventListener( CClubEvent.GET_LUCKY_BAG_RESPONSE ,_getBagResponse );
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
