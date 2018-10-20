//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/6/1.
 * 俱乐部申请审核
 */
package kof.game.club.view.clubview {

import QFLib.Foundation.CTime;

import kof.framework.CViewHandler;
import kof.game.chat.CChatSystem;
import kof.game.chat.data.CChatChannel;
import kof.game.chat.data.CChatType;
import kof.game.club.CClubEvent;
import kof.game.club.CClubHandler;
import kof.game.club.CClubManager;
import kof.game.club.data.CClubConst;
import kof.game.club.view.CClubViewHandler;
import kof.game.common.CLang;
import kof.ui.master.club.ClubApplyItemUI;
import kof.ui.master.club.ClubApplyViewUI;

import morn.core.components.Component;
import morn.core.handlers.Handler;

public class CClubApplyViewHandler extends CViewHandler {

    private var clubApplyViewUI : ClubApplyViewUI;

    public function CClubApplyViewHandler() {
        super();
    }
    public function updateView( clubApplyViewUI : ClubApplyViewUI ):void{
        if( !_pClubManager.selfClubApplyList )
            return;

        clubApplyViewUI.box_noApply.visible = _pClubManager.selfClubApplyList.length <= 0 ;
//        clubApplyViewUI.box_applyList.visible = _pClubManager.selfClubApplyList.length > 0 ;

        this.clubApplyViewUI = clubApplyViewUI;
        clubApplyViewUI.list.renderHandler = new Handler( renderItem );
        clubApplyViewUI.list.selectHandler = new Handler( selectItemHandler );
        clubApplyViewUI.list.dataSource = _pClubManager.selfClubApplyList;

        clubApplyViewUI.btn_all.clickHandler = new Handler( _onAgreeAllHandler );
        clubApplyViewUI.btn_release.clickHandler = new Handler( _onReleaseHandler );

        clubApplyViewUI.btn_left.clickHandler = new Handler(_onPageChange,[clubApplyViewUI.btn_left]);
        clubApplyViewUI.btn_right.clickHandler = new Handler(_onPageChange,[clubApplyViewUI.btn_right]);
        clubApplyViewUI.btn_allleft.clickHandler = new Handler(_onPageChange,[clubApplyViewUI.btn_allleft]);
        clubApplyViewUI.btn_allright.clickHandler = new Handler(_onPageChange,[clubApplyViewUI.btn_allright]);

        clubApplyViewUI.list.page = 0;

        _pageBtnDisable();

        unschedule( updateTime );
        schedule( 1, updateTime );

        _addEventListeners();

        if( _pClubManager.clubPosition == CClubConst.CLUB_POSITION_4 || _pClubManager.clubPosition == CClubConst.CLUB_POSITION_3   ){
            _pClubViewHandler.m__clubViewUI.img_red.visible = _pClubManager.selfClubApplyList.length > 0;
            _pClubManager.selfClubData.applicationSize = _pClubManager.selfClubApplyList.length;
        }

    }

    private function renderItem(item:Component, idx:int):void {
        if (!(item is ClubApplyItemUI)) {
            return;
        }
        var pClubApplyItemUI:ClubApplyItemUI = item as ClubApplyItemUI;
        if( pClubApplyItemUI.dataSource ){
            pClubApplyItemUI.img_vip.visible = pClubApplyItemUI.dataSource.vipLevel >= 1;
            if( pClubApplyItemUI.dataSource.vipLevel >= 1 )
                pClubApplyItemUI.img_vip.index = pClubApplyItemUI.dataSource.vipLevel;
            //todo  蓝钻
            pClubApplyItemUI.txt_name.text = pClubApplyItemUI.dataSource.name;
            pClubApplyItemUI.txt_lv.text = String( pClubApplyItemUI.dataSource.level );
            pClubApplyItemUI.kofnum_battleValue.num = pClubApplyItemUI.dataSource.battleValue ;
            var dateSub:int = CTime.dateSub(CTime.getCurrServerTimestamp(), pClubApplyItemUI.dataSource.applyTime ); // Math.abs();
            dateSub = Math.abs(dateSub);
            if (dateSub == 0) {
                var date : Date = new Date( pClubApplyItemUI.dataSource.applyTime );
                var h : String = String( date.hours );
                if( date.hours < 10 )
                    h = '0' +  date.hours;
                var m : String = String( date.minutes );
                if( date.minutes < 10 )
                    m = '0' +  date.minutes;
                pClubApplyItemUI.txt_lastOutLineTime.text = h + ':' + m;
            } else {
                pClubApplyItemUI.txt_lastOutLineTime.text = CLang.Get("common_last_day", {v1:dateSub});
            }

            pClubApplyItemUI.btn_yes.clickHandler = new Handler( _onApplyYesHandler ,[pClubApplyItemUI.dataSource.roleID] );
            pClubApplyItemUI.btn_no.clickHandler = new Handler( _onApplyNoHandler ,[pClubApplyItemUI.dataSource.roleID] );
        }
    }
    private function selectItemHandler( index : int ) : void {
        var pClubApplyItemUI : ClubApplyItemUI = clubApplyViewUI.list.getCell( index ) as ClubApplyItemUI;
        if ( !pClubApplyItemUI )
            return;
    }

    private function _onPageChange(...args):void{
        switch ( args[0] ) {
            case clubApplyViewUI.btn_left:{
                if( clubApplyViewUI.list.page <= 0 )
                    return;
                clubApplyViewUI.list.page --;
                break
            }
            case clubApplyViewUI.btn_right:{
                if( clubApplyViewUI.list.page >= clubApplyViewUI.list.totalPage )
                    return;
                clubApplyViewUI.list.page ++;
                break
            }
            case clubApplyViewUI.btn_allleft:{
                if( clubApplyViewUI.list.page <= 0 )
                    return;
                clubApplyViewUI.list.page = 0;
                break
            }
            case clubApplyViewUI.btn_allright:{
                if( clubApplyViewUI.list.page >= clubApplyViewUI.list.totalPage )
                    return;
                clubApplyViewUI.list.page = clubApplyViewUI.list.totalPage;
                break
            }
        }
        _pageBtnDisable();
    }

    private function _pageBtnDisable():void{
        clubApplyViewUI.btn_left.disabled =
                clubApplyViewUI.btn_allleft.disabled =
                        clubApplyViewUI.list.page <= 0;
        clubApplyViewUI.btn_right.disabled =
                clubApplyViewUI.btn_allright.disabled =
                        clubApplyViewUI.list.page >= clubApplyViewUI.list.totalPage - 1;
        clubApplyViewUI.txt_page.text = ( clubApplyViewUI.list.page + 1 ) + '/' + clubApplyViewUI.list.totalPage;
        if( clubApplyViewUI.list.totalPage == 0 )
            clubApplyViewUI.txt_page.text = ( clubApplyViewUI.list.totalPage + 1 ) + '/' + (clubApplyViewUI.list.totalPage + 1);

    }
    private function _onApplyYesHandler(...args):void{
        _pClubHandler.onDealPlayerApplicationRequest( args[0], CClubConst.AGREE ,CClubConst.SINGLE );
    }
    private function _onApplyNoHandler(...args):void{
        _pClubHandler.onDealPlayerApplicationRequest( args[0],CClubConst.REFUSE ,CClubConst.SINGLE);
    }
    private function _onAgreeAllHandler():void{
        _pClubHandler.onDealPlayerApplicationRequest( 0, CClubConst.AGREE ,CClubConst.ALL );
    }
    private function _onReleaseHandler():void{
        if( _pClubManager.nextInviteTime - CTime.getCurrServerTimestamp() > 0 ){
            return;
        }
        if( _pClubManager.clubPosition != CClubConst.CLUB_POSITION_4  && _pClubManager.clubPosition != CClubConst.CLUB_POSITION_3 ){
            uiCanvas.showMsgBox(' 很抱歉，只有会长和副会长才可以发布邀请' );
            return;
        }

        _pClubHandler.onClubInvitationRequest();
    }

    private function _onClubInvitationResponse( evt :CClubEvent ):void{
        _pChatSystem.broadcastMessage( CChatChannel.WORLD, String( _pClubManager.selfClubData.id + ':'+ _pClubManager.selfClubData.name ), CChatType.CLUB_INVITATION );
    }

    private function updateTime( delta : Number ):void{
        if( _pClubManager.nextInviteTime - CTime.getCurrServerTimestamp() <= 0 ){
            clubApplyViewUI.btn_release.label = '发布邀请';
        }else {
            clubApplyViewUI.btn_release.label = CTime.toDurTimeString2( _pClubManager.nextInviteTime - CTime.getCurrServerTimestamp() );
        }
    }
    private function _addEventListeners():void{
        _removeEventListeners();
        system.addEventListener( CClubEvent.CLUB_INVITATION_RESPONSE , _onClubInvitationResponse);
    }
    private function _removeEventListeners():void{
        system.removeEventListener( CClubEvent.CLUB_INVITATION_RESPONSE , _onClubInvitationResponse);
    }


    private function get _pClubHandler(): CClubHandler{
        return system.getBean( CClubHandler ) as CClubHandler;
    }
    private function get _pClubManager(): CClubManager{
        return system.getBean( CClubManager ) as CClubManager;
    }
    private function get _pClubViewHandler(): CClubViewHandler{
        return system.getBean( CClubViewHandler ) as CClubViewHandler;
    }
    private function get _pChatSystem():CChatSystem{
        return  system.stage.getSystem( CChatSystem ) as CChatSystem;
    }
}
}
