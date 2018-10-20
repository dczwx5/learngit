//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/5/26.
 * 俱乐部排行
 */

package kof.game.club.view {

import flash.events.MouseEvent;

import kof.framework.CViewHandler;
import kof.game.club.CClubEvent;
import kof.game.club.CClubHandler;
import kof.game.club.CClubManager;
import kof.game.club.data.CClubInfoData;
import kof.game.club.data.CClubPath;
import kof.table.ClubUpgradeBasic;
import kof.ui.master.club.ClubRankItemUI;
import kof.ui.master.club.ClubRankUI;

import morn.core.components.Component;
import morn.core.components.Dialog;

import morn.core.handlers.Handler;

public class CClubRankViewHandler extends CViewHandler {

    private var _clubRankUI : ClubRankUI;

    public function CClubRankViewHandler() {
        super( false );
    }
    override public function get viewClass() : Array {
        return [ ClubRankUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }
    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if( !_clubRankUI ){
            _clubRankUI = new ClubRankUI();
            _clubRankUI.closeHandler = new Handler( _onClose );
            _clubRankUI.list.renderHandler = new Handler( renderItem );
            _clubRankUI.list.selectHandler = new Handler( selectItemHandler );
            _clubRankUI.list.dataSource = [];
            _clubRankUI.btn_left.clickHandler = new Handler(_onPageChange,[_clubRankUI.btn_left]);
            _clubRankUI.btn_right.clickHandler = new Handler(_onPageChange,[_clubRankUI.btn_right]);
            _clubRankUI.btn_allleft.clickHandler = new Handler(_onPageChange,[_clubRankUI.btn_allleft]);
            _clubRankUI.btn_allright.clickHandler = new Handler(_onPageChange,[_clubRankUI.btn_allright]);
        }

        return Boolean( _clubRankUI );
    }



    private function renderItem(item:Component, idx:int):void {
        if (!(item is ClubRankItemUI)) {
            return;
        }
        var pClubRankItemUI:ClubRankItemUI = item as ClubRankItemUI;
        if(pClubRankItemUI.dataSource){
            pClubRankItemUI.clip_rank.visible = pClubRankItemUI.dataSource.rank <= 3;
            if( pClubRankItemUI.clip_rank.visible )
                pClubRankItemUI.clip_rank.index = pClubRankItemUI.dataSource.rank - 1;
            pClubRankItemUI.txt_rank.visible = pClubRankItemUI.dataSource.rank > 3;
            if( pClubRankItemUI.txt_rank.visible )
                pClubRankItemUI.txt_rank.text = String( pClubRankItemUI.dataSource.rank );
            pClubRankItemUI.img_icon.url = CClubPath.getClubIconUrByID(pClubRankItemUI.dataSource.clubSignID);
            pClubRankItemUI.txt_name.text = pClubRankItemUI.dataSource.name;
            pClubRankItemUI.txt_level.text = pClubRankItemUI.dataSource.level;
            pClubRankItemUI.kofnum_battleValue.num = int( pClubRankItemUI.dataSource.battleValue );

           //会长
            pClubRankItemUI.img_vip.visible = pClubRankItemUI.dataSource.chairmanInfo.vipLevel >= 1;
            if( pClubRankItemUI.dataSource.chairmanInfo.vipLevel >= 1 )
                pClubRankItemUI.img_vip.index = pClubRankItemUI.dataSource.chairmanInfo.vipLevel;
            //todo  蓝钻
            pClubRankItemUI.txt_chairmanName.text = pClubRankItemUI.dataSource.chairmanInfo.name;

            pClubRankItemUI.txt_name.removeEventListener( MouseEvent.CLICK, _showClubInfoHandler );
            pClubRankItemUI.txt_name.addEventListener( MouseEvent.CLICK, _showClubInfoHandler );
            var clubUpgradeBasic : ClubUpgradeBasic = _pClubManager.getClubUpgradeBasicByLevel( pClubRankItemUI.dataSource.level );
            if(!clubUpgradeBasic) return;
            pClubRankItemUI.txt_member.text = pClubRankItemUI.dataSource.memberCount + "/" + clubUpgradeBasic.memberCountMax;
        }
    }
    private function selectItemHandler( index : int ) : void {
        var pClubRankItemUI : ClubRankItemUI = _clubRankUI.list.getCell( index ) as ClubRankItemUI;
        if ( !pClubRankItemUI )
            return;
    }

    private function _onPageChange(...args):void{
        switch ( args[0] ) {
            case _clubRankUI.btn_left:{
                if( _pClubManager.curClubRankListPage <= 1 )
                    return;
                _pClubHandler.onClubRankListRequest( '' ,_pClubManager.curClubRankListPage - 1 );
                break
            }
            case _clubRankUI.btn_right:{
                if( _pClubManager.curClubRankListPage >= _pClubManager.totalClubRankListPages )
                    return;
                _pClubHandler.onClubRankListRequest( '' ,_pClubManager.curClubRankListPage + 1 );
                break
            }
            case _clubRankUI.btn_allleft:{
                if( _pClubManager.curClubRankListPage <= 1 )
                    return;
                _pClubHandler.onClubRankListRequest( '' ,1 );
                break
            }
            case _clubRankUI.btn_allright:{
                if( _pClubManager.curClubRankListPage >= _pClubManager.totalClubRankListPages )
                    return;
                _pClubHandler.onClubRankListRequest( '' ,_pClubManager.totalClubRankListPages );
                break
            }
        }
    }
    private function _pageBtnDisable():void{
        _clubRankUI.btn_left.disabled =
                _clubRankUI.btn_allleft.disabled = _pClubManager.curClubRankListPage <= 1;
        _clubRankUI.btn_right.disabled =
                _clubRankUI.btn_allright.disabled = _pClubManager.curClubRankListPage >= _pClubManager.totalClubRankListPages;
        _clubRankUI.txt_page.text = _pClubManager.curClubRankListPage + '/' + _pClubManager.totalClubRankListPages;
    }
    private function _onClubListUpdate( evt : CClubEvent ):void{
        _clubRankUI.list.dataSource = _pClubManager.clubList;
        _pageBtnDisable();
    }
    private function _showClubInfoHandler( evt : MouseEvent ):void{
        var pClubRankItemUI:ClubRankItemUI = evt.currentTarget.parent.parent as ClubRankItemUI;
        _pClubInfoViewHandler.addDisplay( pClubRankItemUI.dataSource as CClubInfoData );
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
        _pClubHandler.onClubRankListRequest( '' ,1 );
        uiCanvas.addPopupDialog( _clubRankUI );
        _addEventListeners();
    }
    public function removeDisplay() : void {
        if ( _clubRankUI ) {
            _clubRankUI.close( Dialog.CLOSE );
        }
    }
    private function _addEventListeners():void{
        _removeEventListeners();
        system.addEventListener( CClubEvent.CLUB_LIST_RESPONSE , _onClubListUpdate );
    }
    private function _removeEventListeners():void{
        system.removeEventListener(  CClubEvent.CLUB_LIST_RESPONSE , _onClubListUpdate );
    }
    private function _onClose( type : String ) : void {
        switch ( type ) {
            default:
                break;
        }
        _removeEventListeners();
    }
    private function get _pClubManager() : CClubManager {
        return system.getBean( CClubManager ) as CClubManager;
    }
    private function get _pClubHandler() : CClubHandler {
        return system.getBean( CClubHandler ) as CClubHandler;
    }
    private function get _pClubInfoViewHandler() : CClubInfoViewHandler {
        return system.getBean( CClubInfoViewHandler ) as CClubInfoViewHandler;
    }
}
}
