//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/5/25.
 * 俱乐部大厅
 */
package kof.game.club.view {

import flash.events.Event;
import flash.events.FocusEvent;

import kof.framework.CViewHandler;
import kof.game.club.CClubEvent;
import kof.game.club.CClubHandler;
import kof.game.club.CClubManager;
import kof.game.club.data.CClubConst;
import kof.game.club.view.clubview.CClubApplyViewHandler;
import kof.game.club.view.clubview.CClubBaseInfoViewHandler;
import kof.game.club.view.clubview.CClubLogViewHandler;
import kof.game.club.view.clubview.CClubMemberCViewHandler;
import kof.game.common.CLang;
import kof.game.common.CSystemRuleUtil;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.message.Club.ClubInfoResponse;
import kof.message.Club.MemberInfoModifyResponse;
import kof.ui.CUISystem;
import kof.ui.master.club.ClubApplyViewUI;
import kof.ui.master.club.ClubInfoViewUI;
import kof.ui.master.club.ClubLogViewUI;
import kof.ui.master.club.ClubMemberViewUI;
import kof.ui.master.club.ClubViewUI;
import kof.util.CTextFieldInputUtil;

import morn.core.components.Dialog;
import morn.core.handlers.Handler;

public class CClubViewHandler extends CViewHandler {

    private var _clubViewUI : ClubViewUI;

    private var _groupAry : Array;

    public function CClubViewHandler() {
        super( false );
    }
    override public function get viewClass() : Array {
        return [ ClubViewUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if( !_groupAry ){
            _groupAry = [];
            _groupAry.push( _onMemberResponse ,_onClubLogResponse,_onApplyResponse );
//            _groupAry.push( _onBaseInfoResponse ,_onMemberResponse ,_onApplyResponse );
        }
        if( !_clubViewUI ){
            _clubViewUI = new ClubViewUI();

            _clubViewUI.closeHandler = new Handler( _onClose );
            _clubViewUI.tab.selectHandler = new Handler( _onBtnTabSelectHandler );

//            _clubViewUI.img_tips.toolTip = CClubConst.CLUB_TIPS;
            CSystemRuleUtil.setRuleTips(_clubViewUI.img_tips, CLang.Get("club_hall_rule"));
        }

        _clubViewUI.img_red.visible  = false;

        return Boolean( _clubViewUI );
    }

    private function _onBtnTabSelectHandler( index : int ):void{
        var j : int;
        for( j = CClubConst.CLUB_MEMBER ; j <= CClubConst.CLUB_APPLY ; j++ ){
            _clubViewUI['view_' + j ].visible = ( j == index );
        }
        _groupAry[index].apply();//先显示,以防后台没有返回协议
        var infoType :int; //这里是因为UI改版了
        if( index == 0 ){
            infoType = 1;
        }else if( index == 1 ){
            infoType = 0;
        }else if( index == 2 ){
            infoType = 2;
        }
        _pClubHandler.onClubInfoRequest( _pClubManager.selfClubData.id , infoType );
    }
    private function _onClubInfoResponseHandler( evt : CClubEvent = null ):void{
        var response : ClubInfoResponse = evt.data as ClubInfoResponse;
        var infoType : int = response.infoType;

        //UI改版引起的
        if( infoType == 0 ){
            _onBaseInfoResponse();
        }else if( infoType == 1 ){
            _onMemberResponse();
        }else if( infoType == 2 ){
            _onApplyResponse();
        }
//        if( _clubViewUI.tab.selectedIndex ==  infoType ){
//            _groupAry[infoType].apply();
//        }

        if( _pClubManager.clubPosition == CClubConst.CLUB_POSITION_4 || _pClubManager.clubPosition == CClubConst.CLUB_POSITION_3  ){
//            _clubViewUI.img_red.visible = _pClubManager.selfClubData.applicationSize > 0;
            if( _pClubManager.selfClubData.applicationSize > 0 )
                _clubViewUI.img_red.visible = true; //不要管false
        }

        if( _pClubManager.clubPosition == CClubConst.CLUB_POSITION_4 || _pClubManager.clubPosition == CClubConst.CLUB_POSITION_3  ){
            _clubViewUI.tab.labels = '俱乐部会员,俱乐部记事,申请审核';
        }else{
            _clubViewUI.tab.labels = '俱乐部会员,俱乐部记事';
            _clubViewUI.img_red.visible = false;
        }

        _clubViewUI.tab.x = 870 - _clubViewUI.tab.width;

    }

    //基本信息
    private function _onBaseInfoResponse( evt : CClubEvent = null):void{
        if( !_clubViewUI )
                return;
        _pClubBaseInfoViewHandler.updateView( _clubViewUI.view_info as ClubInfoViewUI );
    }
    //俱乐部成员
    private function _onMemberResponse( evt : CClubEvent = null):void{
        if( !_clubViewUI )
            return;
        _pClubMemberCViewHandler.updateView( _clubViewUI.view_0 as ClubMemberViewUI );

    }
    //俱乐部日志
    private function _onClubLogResponse( evt : CClubEvent = null):void{
        if( !_clubViewUI )
            return;
        _pClubLogViewHandler.updateView( _clubViewUI.view_1 as ClubLogViewUI );
    }
    //申请审核
    private function _onApplyResponse( evt : CClubEvent = null):void{
        if( !_clubViewUI )
            return;
        _pClubApplyViewHandler.updateView( _clubViewUI.view_2 as ClubApplyViewUI );
    }

   //修改公告
    private function _onTxtAnnouncementFocus( evt : FocusEvent ) : void {
        if( evt.type == FocusEvent.FOCUS_IN ){

        }else if( evt.type == FocusEvent.FOCUS_OUT ){
            if( _clubViewUI.view_info.txt_announcement.text !=  _pClubManager.selfClubData.announcement )
                _pClubHandler.onModifyClubInfoRequest(_clubViewUI.view_info.txt_announcement.text,'', 0, CClubConst.CHANGE_ANNOUNCEMENT );
        }
    }
    //修改图标
    private function _onClubIconChangeRequest( evt : CClubEvent ):void{
        var iconID : int = int( evt.data );
        _pClubHandler.onModifyClubInfoRequest( '','', iconID ,CClubConst.CHANGE_ICON );
    }
    //退出俱乐部
    private function _onClubExitSucc( evt : CClubEvent ):void{
        _clubViewUI.close( Dialog.CLOSE );
    }
    //消息更新
    private function _onClubMsgResponse( evt : CClubEvent ):void{
        var type : int = int( evt.data );
        if( type == CClubConst.APPLY_LIST_UPDATE  ){
            _clubViewUI.img_red.visible = true;
            _pClubHandler.onClubInfoRequest( _pClubManager.selfClubData.id, 2 );
        }
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
        _clubViewUI.view_0.visible =
                _clubViewUI.view_1.visible =
                        _clubViewUI.view_2.visible = false;
        uiCanvas.addPopupDialog( _clubViewUI );
        _addEventListeners();


        _pClubHandler.onClubInfoRequest( _pClubManager.selfClubData.id , 0 );

        _clubViewUI.tab.selectedIndex = 0;
        _clubViewUI.tab.callLater( _onBtnTabSelectHandler,[0]);

    }
    public function removeDisplay() : void {
        if ( _clubViewUI ) {
            _clubViewUI.close( Dialog.CLOSE );
        }
    }
    private function _onModifyResponse( evt : CClubEvent ):void {
        var response : MemberInfoModifyResponse = evt.data as MemberInfoModifyResponse;
        if ( response.type == CClubConst.POSITION_UP || response.type == CClubConst.POSITION_DOWN  ) {
        }
    }
    private function onTxtChange( evt :Event ):void{
        checkTxtInput();
    }
    private function checkTxtInput():void{
        if( CTextFieldInputUtil.getTextCount( _clubViewUI.view_info.txt_announcement.text ) > CClubConst.ANNOUNCEMENT_MAX_CHARS ){
            _clubViewUI.view_info.txt_announcement.text = CTextFieldInputUtil.getSubTextByLength( _clubViewUI.view_info.txt_announcement.text, CClubConst.ANNOUNCEMENT_MAX_CHARS );
            _pCUISystem.showMsgAlert('已超出最大字数限制');
        }
    }
    private function _addEventListeners():void{
        _removeEventListeners();
        system.addEventListener( CClubEvent.CLUB_INFO_RESPONSE ,_onClubInfoResponseHandler );
        system.addEventListener( CClubEvent.CLUB_INFO_CHANGE ,_onBaseInfoResponse );
        system.addEventListener( CClubEvent.CLUB_MEMBER_LIST_CHANGE ,_onMemberResponse );
        system.addEventListener( CClubEvent.DEAL_APPLICATION_RESPONSE ,_onApplyResponse );
        system.addEventListener( CClubEvent.CLUB_ICON_CHANGE_REQUEST , _onClubIconChangeRequest );
        system.addEventListener( CClubEvent.CLUB_EXIT_SUCC , _onClubExitSucc );
        system.addEventListener( CClubEvent.CLUB_MSG_RESPONSE , _onClubMsgResponse );
        system.addEventListener( CClubEvent.MEMBER_INFO_MODIFY_RESPONSE , _onModifyResponse  );

        _clubViewUI.view_info.txt_announcement.addEventListener( FocusEvent.FOCUS_IN, _onTxtAnnouncementFocus, false, 0, true );
        _clubViewUI.view_info.txt_announcement.addEventListener( FocusEvent.FOCUS_OUT, _onTxtAnnouncementFocus, false, 0, true );
        _clubViewUI.view_info.txt_announcement.addEventListener( Event.CHANGE, onTxtChange, false, 0, true);
    }
    private function _removeEventListeners():void{
        system.removeEventListener( CClubEvent.CLUB_INFO_RESPONSE ,_onClubInfoResponseHandler );
        system.removeEventListener( CClubEvent.CLUB_INFO_CHANGE ,_onBaseInfoResponse );
        system.removeEventListener( CClubEvent.CLUB_MEMBER_LIST_CHANGE ,_onMemberResponse );
        system.removeEventListener( CClubEvent.DEAL_APPLICATION_RESPONSE ,_onApplyResponse );
        system.removeEventListener( CClubEvent.CLUB_ICON_CHANGE_REQUEST , _onClubIconChangeRequest );
        system.removeEventListener( CClubEvent.CLUB_EXIT_SUCC , _onClubExitSucc );
        system.removeEventListener( CClubEvent.CLUB_MSG_RESPONSE , _onClubMsgResponse );
        system.removeEventListener( CClubEvent.MEMBER_INFO_MODIFY_RESPONSE , _onModifyResponse  );

        _clubViewUI.view_info.txt_announcement.removeEventListener( FocusEvent.FOCUS_IN, _onTxtAnnouncementFocus );
        _clubViewUI.view_info.txt_announcement.removeEventListener( FocusEvent.FOCUS_OUT, _onTxtAnnouncementFocus );
        _clubViewUI.view_info.txt_announcement.removeEventListener( Event.CHANGE, onTxtChange);
    }
    private function _onClose( type : String ) : void {
        switch ( type ) {
            default:
                break;
        }
        _removeEventListeners();
    }

    private function get _playerData() : CPlayerData {
        return ( _playerSystem.getBean( CPlayerManager ) as CPlayerManager ).playerData;
    }
    private function get _playerSystem() : CPlayerSystem {
        return system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }

    private function get _pClubHandler(): CClubHandler{
        return system.getBean( CClubHandler ) as CClubHandler;
    }
    private function get _pClubManager(): CClubManager{
        return system.getBean( CClubManager ) as CClubManager;
    }
    private function get _pClubBaseInfoViewHandler(): CClubBaseInfoViewHandler{
        return system.getBean( CClubBaseInfoViewHandler ) as CClubBaseInfoViewHandler;
    }
    private function get _pClubLogViewHandler(): CClubLogViewHandler{
        return system.getBean( CClubLogViewHandler ) as CClubLogViewHandler;
    }
    private function get _pClubMemberCViewHandler(): CClubMemberCViewHandler{
        return system.getBean( CClubMemberCViewHandler ) as CClubMemberCViewHandler;
    }
    private function get _pClubApplyViewHandler(): CClubApplyViewHandler{
        return system.getBean( CClubApplyViewHandler ) as CClubApplyViewHandler;
    }
    private function get _pCUISystem():CUISystem{
        return system.stage.getSystem( CUISystem ) as CUISystem;
    }

    public function get m__clubViewUI() : ClubViewUI {
        return _clubViewUI;
    }
}
}
