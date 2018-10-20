//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/6/15.
 * 单个福袋记录
 */
package kof.game.club.view.welfarebag {

import kof.framework.CViewHandler;
import kof.game.club.CClubEvent;
import kof.game.club.CClubHandler;
import kof.game.club.CClubManager;
import kof.game.club.data.CClubBagRecordData;
import kof.game.club.data.CClubConst;
import kof.game.club.data.CClubWelfareBagData;
import kof.game.common.view.CViewExternalUtil;
import kof.game.item.view.part.CRewardItemListView;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.ui.master.club.ClubGetWelfareBagLogItemUI;
import kof.ui.master.club.ClubSingleBagLogUI;

import morn.core.components.Component;
import morn.core.components.Dialog;

import morn.core.handlers.Handler;

public class CClubSingleBagLogViewHandler extends CViewHandler {

    private var _clubSingleBagLogUI : ClubSingleBagLogUI;

    private var _pClubWelfareBagData : CClubWelfareBagData;

    private var m_viewExternal:CViewExternalUtil;

    public function CClubSingleBagLogViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array {
        return [ ClubSingleBagLogUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !_clubSingleBagLogUI ) {
            _clubSingleBagLogUI = new ClubSingleBagLogUI();

            _clubSingleBagLogUI.list.renderHandler = new Handler( renderItem );
            _clubSingleBagLogUI.list.selectHandler = new Handler( selectItemHandler );
            _clubSingleBagLogUI.list.dataSource = [];

            _clubSingleBagLogUI.btn_thx.clickHandler = new Handler( _onThxHandler );
        }

        return Boolean( _clubSingleBagLogUI );
    }
    private function renderItem(item:Component, idx:int):void {
        if ( !(item is ClubGetWelfareBagLogItemUI ) ) {
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
                pClubGetWelfareBagLogItemUI.img_vip.index = pClubBagRecordData.vipLevel;

        }
    }
    private function selectItemHandler( index : int ) : void {
        var pClubGetWelfareBagLogItemUI : ClubGetWelfareBagLogItemUI = _clubSingleBagLogUI.list.getCell( index ) as ClubGetWelfareBagLogItemUI;
        if ( !pClubGetWelfareBagLogItemUI )
            return;

    }
    public function addDisplay( pClubWelfareBagData : CClubWelfareBagData ) : void {
        _pClubWelfareBagData = pClubWelfareBagData;
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
        _addEventListeners();
        _pClubHandler.onLuckyBagRecordRequest( _pClubWelfareBagData.type ,_pClubWelfareBagData.ID );


        var index : int ;
        for( index = 1 ; index <= 3 ; index++ ){
            _clubSingleBagLogUI['img_icon_' + index ].visible = _pClubWelfareBagData.itemType == index;
        }
        var obj :Object;
        var selfGotNum : int;
        for each( obj in _pClubWelfareBagData.recordList ){
            if( obj.roleID == _playerData.ID ){
                selfGotNum = obj.record;
                break;
            }
        }

        if( _pClubWelfareBagData.itemType == CClubConst.BAG_ITEM_TYPE ){
            _clubSingleBagLogUI.txt_num.text = 'x 1';
        }else{
            _clubSingleBagLogUI.txt_num.text = 'x ' + selfGotNum;
        }


        _clubSingleBagLogUI.box_reward.visible = selfGotNum > 0;
        if( _clubSingleBagLogUI.box_reward.visible )
            _clubSingleBagLogUI.txt_title.text = '恭喜你,抢到玩家' + _pClubWelfareBagData.name + '的福袋';
        else
            _clubSingleBagLogUI.txt_title.text = '很遗憾，福袋已被抢完。';



        _clubSingleBagLogUI.btn_thx.visible = _pClubWelfareBagData.type == CClubConst.BAG_RECHARGE;

    }
    public function removeDisplay() : void {
        if ( _clubSingleBagLogUI ) {
            _clubSingleBagLogUI.close( Dialog.CLOSE );
        }
    }
    private function _onSingleBagRecordResponseHandler( evt :CClubEvent ):void{
        var ary : Array = _pClubManager.singleUserBagLogList;
        ary.sortOn('record' ,Array.DESCENDING|Array.NUMERIC );
        _clubSingleBagLogUI.list.dataSource = ary;

        _clubSingleBagLogUI.img_best.visible = ary.length > 0;
        if( _pClubWelfareBagData.itemType == CClubConst.BAG_ITEM_TYPE ){
            _clubSingleBagLogUI.img_best.visible = false;
        }

        uiCanvas.addPopupDialog( _clubSingleBagLogUI );
    }
    private function _onThxHandler():void{
        _pClubHandler.onThanksRechargeLuckyBagRequest( _pClubWelfareBagData.ID );
    }
    private function _addEventListeners():void{
        _removeEventListeners();
        system.addEventListener( CClubEvent.SINGLE_LUCKY_BAG_RECORD_RESPONSE  , _onSingleBagRecordResponseHandler );
    }
    private function _removeEventListeners():void{
        system.removeEventListener( CClubEvent.SINGLE_LUCKY_BAG_RECORD_RESPONSE  , _onSingleBagRecordResponseHandler );
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
    private function get _playerData() : CPlayerData {
        return ( _playerSystem.getBean( CPlayerManager ) as CPlayerManager ).playerData;
    }
    private function get _playerSystem() : CPlayerSystem {
        return system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }
}
}
