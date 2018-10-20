//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddu on 2017/5/31.
 * 俱乐部成员
 */
package kof.game.club.view.clubview {

import QFLib.Foundation.CTime;

import flash.events.MouseEvent;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.game.club.CClubManager;
import kof.game.club.data.CClubConst;
import kof.game.common.CLang;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.table.ClubPosition;
import kof.ui.CUISystem;
import kof.ui.master.club.ClubMemberItemUI;
import kof.ui.master.club.ClubMemberViewUI;

import morn.core.components.Component;
import morn.core.handlers.Handler;

public class CClubMemberCViewHandler extends CViewHandler {

    private var clubMemberViewUI : ClubMemberViewUI;

    public function CClubMemberCViewHandler() {
        super();
    }
    public function updateView( clubMemberViewUI : ClubMemberViewUI ):void{
        if( !_pClubManager.selfClubMemBerList )
            return;

        this.clubMemberViewUI = clubMemberViewUI;
        clubMemberViewUI.list.renderHandler = new Handler( renderItem );
        clubMemberViewUI.list.selectHandler = new Handler( selectItemHandler );
        clubMemberViewUI.list.dataSource = _pClubManager.selfClubMemBerList;

        clubMemberViewUI.btn_left.clickHandler = new Handler(_onPageChange,[clubMemberViewUI.btn_left]);
        clubMemberViewUI.btn_right.clickHandler = new Handler(_onPageChange,[clubMemberViewUI.btn_right]);
        clubMemberViewUI.btn_allleft.clickHandler = new Handler(_onPageChange,[clubMemberViewUI.btn_allleft]);
        clubMemberViewUI.btn_allright.clickHandler = new Handler(_onPageChange,[clubMemberViewUI.btn_allright]);

        clubMemberViewUI.list.page = 0;

        _pageBtnDisable();


    }

    private function renderItem(item:Component, idx:int):void {
        if (!(item is ClubMemberItemUI)) {
            return;
        }
        var pClubMemberItemUI:ClubMemberItemUI = item as ClubMemberItemUI;
        if( pClubMemberItemUI.dataSource ){
            pClubMemberItemUI.img_vip.visible = pClubMemberItemUI.dataSource.vipLevel >= 1;
            if( pClubMemberItemUI.dataSource.vipLevel >= 1 )
                pClubMemberItemUI.img_vip.index = pClubMemberItemUI.dataSource.vipLevel;
            //todo  蓝钻
            pClubMemberItemUI.txt_name.text = pClubMemberItemUI.dataSource.name;
            pClubMemberItemUI.clip_position.visible = pClubMemberItemUI.dataSource.position >= CClubConst.CLUB_POSITION_2 ;
            if( pClubMemberItemUI.clip_position.visible )
                pClubMemberItemUI.clip_position.index = pClubMemberItemUI.dataSource.position - 2;
            var pTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.CLUBPOSITION );
            var clubPosition : ClubPosition =  pTable.findByPrimaryKey( pClubMemberItemUI.dataSource.position );
            pClubMemberItemUI.txt_position.text = clubPosition.position;
            pClubMemberItemUI.txt_lv.text = String( pClubMemberItemUI.dataSource.level );
            pClubMemberItemUI.txt_fund.text = String( pClubMemberItemUI.dataSource.fundCount );
            pClubMemberItemUI.kofnum_battleValue.num =  pClubMemberItemUI.dataSource.battleValue ;
            if( int( pClubMemberItemUI.dataSource.lastOutLineTime) == -1 ){
                pClubMemberItemUI.txt_lastOutLineTime.text = '在线';
            }else{
                var dateSub:int = CTime.dateSub(CTime.getCurrServerTimestamp(), pClubMemberItemUI.dataSource.lastOutLineTime); // Math.abs();
                dateSub = Math.abs(dateSub);
                if (dateSub == 0) {
                    var date : Date = new Date( pClubMemberItemUI.dataSource.lastOutLineTime );
                    pClubMemberItemUI.txt_lastOutLineTime.text = date.hours + ':' + date.minutes;
                    if( date.minutes < 10 )
                        pClubMemberItemUI.txt_lastOutLineTime.text = date.hours + ':0' + date.minutes;
                } else if( dateSub >= 365 ){
                    pClubMemberItemUI.txt_lastOutLineTime.text = '';
                } else if( dateSub >= 30 ){
                    pClubMemberItemUI.txt_lastOutLineTime.text = Math.floor( dateSub / 30 ) + '个月前';
                }else {
                    pClubMemberItemUI.txt_lastOutLineTime.text = CLang.Get("common_last_day", {v1:dateSub});
                }
            }


            pClubMemberItemUI.txt_name.underline = pClubMemberItemUI.dataSource.roleID != _playerData.ID;

            pClubMemberItemUI.txt_name.removeEventListener( MouseEvent.CLICK, _showMemberMenuHandler );
            pClubMemberItemUI.txt_name.addEventListener( MouseEvent.CLICK, _showMemberMenuHandler );
        }
    }
    private function selectItemHandler( index : int ) : void {
        var pClubMemberItemUI : ClubMemberItemUI = clubMemberViewUI.list.getCell( index ) as ClubMemberItemUI;
        if ( !pClubMemberItemUI )
            return;
    }

    private function _showMemberMenuHandler( evt : MouseEvent ):void{
        var pClubMemberItemUI : ClubMemberItemUI  = evt.currentTarget.parent.parent as ClubMemberItemUI;//这里要注意UI的修改
        if( pClubMemberItemUI.dataSource.roleID == _playerData.ID )
                return;
        var targetPosition : int = pClubMemberItemUI.dataSource.position ;
        if( targetPosition >= _pClubManager.clubPosition || _pClubManager.clubPosition <= CClubConst.CLUB_POSITION_2 ){
//            _pCUISystem.showMsgAlert('查看会员信息（待策划补充文案）');
            return;
        }
        _pClubMemberMenuHandler.addDisplay( pClubMemberItemUI );
    }

    private function _onPageChange(...args):void{
        switch ( args[0] ) {
            case clubMemberViewUI.btn_left:{
                if( clubMemberViewUI.list.page <= 0 )
                    return;
                clubMemberViewUI.list.page --;
                break
            }
            case clubMemberViewUI.btn_right:{
                if( clubMemberViewUI.list.page >= clubMemberViewUI.list.totalPage )
                    return;
                clubMemberViewUI.list.page ++;
                break
            }
            case clubMemberViewUI.btn_allleft:{
                if( clubMemberViewUI.list.page <= 0 )
                    return;
                clubMemberViewUI.list.page = 0;
                break
            }
            case clubMemberViewUI.btn_allright:{
                if( clubMemberViewUI.list.page >= clubMemberViewUI.list.totalPage )
                    return;
                clubMemberViewUI.list.page = clubMemberViewUI.list.totalPage;
                break
            }
        }
        _pageBtnDisable();
    }
    private function _pageBtnDisable():void{
        clubMemberViewUI.btn_left.disabled =
                clubMemberViewUI.btn_allleft.disabled =
                        clubMemberViewUI.list.page <= 0;
        clubMemberViewUI.btn_right.disabled =
                clubMemberViewUI.btn_allright.disabled =
                        clubMemberViewUI.list.page >= clubMemberViewUI.list.totalPage - 1;
        clubMemberViewUI.txt_page.text = ( clubMemberViewUI.list.page + 1 ) + '/' + clubMemberViewUI.list.totalPage;
        if( clubMemberViewUI.list.totalPage == 0 )
            clubMemberViewUI.txt_page.text = ( clubMemberViewUI.list.totalPage + 1 ) + '/' + (clubMemberViewUI.list.totalPage + 1);
    }
    private function get _pClubManager(): CClubManager{
        return system.getBean( CClubManager ) as CClubManager;
    }
    private function get _pCDatabaseSystem():CDatabaseSystem{
        return system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }
    private function get _pClubMemberMenuHandler():CClubMemberMenuHandler{
        return system.getBean(CClubMemberMenuHandler) as CClubMemberMenuHandler;
    }
    private function get _playerData() : CPlayerData {
        return ( _playerSystem.getBean( CPlayerManager ) as CPlayerManager ).playerData;
    }
    private function get _playerSystem() : CPlayerSystem {
        return system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }
    private function get _pCUISystem():CUISystem{
        return system.stage.getSystem( CUISystem ) as CUISystem;
    }
}
}
