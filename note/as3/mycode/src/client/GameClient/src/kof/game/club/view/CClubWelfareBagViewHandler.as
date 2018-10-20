//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/5/26.\
 * 福袋主界面
 */
package kof.game.club.view {

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.game.chat.CChatSystem;
import kof.game.chat.data.CChatChannel;
import kof.game.chat.data.CChatType;
import kof.game.club.CClubEvent;
import kof.game.club.CClubHandler;
import kof.game.club.CClubManager;
import kof.game.club.data.CClubConst;
import kof.game.club.data.CClubWelfareBagData;
import kof.game.club.view.welfarebag.CClubBagSendInfoViewHandler;
import kof.game.club.view.welfarebag.CClubWelfareBagGetViewHandler;
import kof.game.club.view.welfarebag.CClubWelfareBagInfoViewHandler;
import kof.game.club.view.welfarebag.CClubWelfareBagRechargeViewHandler;
import kof.game.club.view.welfarebag.CClubWelfareBagSendViewHandler;
import kof.game.common.CLang;
import kof.game.common.CSystemRuleUtil;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.message.Club.GetLuckyBagResponse;
import kof.message.Club.SendLuckyBagResponse;
import kof.table.LuckyBagConfig;
import kof.ui.master.club.ClubWelfareBagGetUI;
import kof.ui.master.club.ClubWelfareBagRechargeUI;
import kof.ui.master.club.ClubWelfareBagSendUI;
import kof.ui.master.club.ClubWelfareBagUI;
import kof.ui.master.club.ClubWelfareBagViewUI;

import morn.core.components.Dialog;

import morn.core.handlers.Handler;

public class CClubWelfareBagViewHandler extends CViewHandler {

    private var _clubWelfareBagUI : ClubWelfareBagUI;

    private var _groupAry : Array;

    private var _tab : int;

    public function CClubWelfareBagViewHandler() {
        super( false );
    }
    override public function get viewClass() : Array {
        return [ ClubWelfareBagUI ];
    }
    override protected function get additionalAssets() : Array {
        return [
            "frameclip_club.swf"
        ];
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
            _groupAry.push( _onClubWelfareBagResponse ,_onClubWelfareBagSendResponse ,_onClubWelfareBagGetResponse ,_onRechargeLuckyBagResponse);
        }
        if( !_clubWelfareBagUI ){
            _clubWelfareBagUI = new ClubWelfareBagUI();

            _clubWelfareBagUI.closeHandler = new Handler( _onClose );
            _clubWelfareBagUI.tab.selectHandler = new Handler( _onBtnTabSelectHandler );

//            _clubWelfareBagUI.img_tips.toolTip = CClubConst.WELFAREBAG_TIPS;
            CSystemRuleUtil.setRuleTips(_clubWelfareBagUI.img_tips, CLang.Get("club_welfarebag_rule"));
        }
        _clubWelfareBagUI.img_red0.visible = false;
        _clubWelfareBagUI.img_red2.visible = false;

        return Boolean( _clubWelfareBagUI );
    }

    private function _onBtnTabSelectHandler( index : int ):void{
        var j : int;
        for( j = CClubConst.BAG_BASE_INFO ; j <= CClubConst.CLUB_BAG_RECHARGE ; j++ ){
            _clubWelfareBagUI['view_' + j ].visible = ( j == index );
        }
        _groupAry[index].apply();//先显示,以防后台没有返回协议
        if( index == CClubConst.BAG_BASE_INFO ){
            _pClubHandler.onLuckyBagInfoListRequest( CClubConst.CLUB_BAG_LIST );
        }else if(  index == CClubConst.CLUB_BAG_SEND ){

        }else if(  index == CClubConst.CLUB_BAG_GET ){
            _pClubHandler.onLuckyBagInfoListRequest( CClubConst.USER_BAG_LIST );
        }else if( index == CClubConst.CLUB_BAG_RECHARGE ){
            _pClubHandler.onRechargeLuckyBagRequest( );
        }

    }

    //俱乐部系统福袋页签
    private function _onClubWelfareBagResponse( evt : CClubEvent = null):void{
        if( !_clubWelfareBagUI )
            return;
        _pClubWelfareBagInfoViewHandler.updateView( _clubWelfareBagUI.view_0 as ClubWelfareBagViewUI );
    }
    //发福袋页签
    private function _onClubWelfareBagSendResponse( evt : CClubEvent = null):void{
        if( !_clubWelfareBagUI )
            return;
        _pClubWelfareBagSendViewHandler.updateView( _clubWelfareBagUI.view_1 as ClubWelfareBagSendUI );

    }
    //抢福袋页签
    private function _onClubWelfareBagGetResponse( evt : CClubEvent = null):void{
        if( !_clubWelfareBagUI )
            return;
        _pClubWelfareBagGetViewHandler.updateView( _clubWelfareBagUI.view_2 as ClubWelfareBagGetUI );
    }
    //充值福袋页签
    private function _onRechargeLuckyBagResponse( evt : CClubEvent = null):void{
        if( !_clubWelfareBagUI )
            return;
        _pClubWelfareBagRechargeViewHandler.updateView( _clubWelfareBagUI.view_3 as ClubWelfareBagRechargeUI );
    }

    private function _onClubBagResponseHandler( evt : CClubEvent ):void{
        var type : int = int( evt.data );
        if( type == CClubConst.CLUB_BAG_LIST ){
            _onClubWelfareBagResponse();
        }else if( type == CClubConst.USER_BAG_LIST || type == CClubConst.RECHARGE_BAG_LIST ){
            _onClubWelfareBagGetResponse();
        }
        _clubWelfareBagUI.img_red0.visible = _pClubManager.checkWelBagState;
        _clubWelfareBagUI.img_red2.visible = _pClubManager.playerLuckyBagState;
    }
    private function _onClubGetBagResponseHandler( evt : CClubEvent ):void{
        if( !_clubWelfareBagUI )
            return;
        var response:GetLuckyBagResponse = evt.data as GetLuckyBagResponse;
        if( response.type == CClubConst.CLUB_BAG_LIST ){
            _pClubWelfareBagInfoViewHandler.updateCurItem( response.luckBagID );
            _clubWelfareBagUI.img_red0.visible = _pClubManager.checkWelBagState;
        }else if( response.type == CClubConst.USER_BAG_LIST || response.type == CClubConst.RECHARGE_BAG_LIST){
            _pClubWelfareBagGetViewHandler.updateCurItem( response.luckBagID );
        }

    }
    private function _onClubSendBagResponseHandler( evt : CClubEvent ):void{
        if( !_clubWelfareBagUI )
            return;
        _pClubBagSendInfoViewHandler.removeDisplay();
        _clubWelfareBagUI.tab.selectedIndex = CClubConst.CLUB_BAG_GET;
        _clubWelfareBagUI.tab.callLater( _onBtnTabSelectHandler,[CClubConst.CLUB_BAG_GET]);

        var response : SendLuckyBagResponse = evt.data as SendLuckyBagResponse;
        var pTableLuckyBag : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.LUCKYBAGCONFIG );
        var luckyBagConfig : LuckyBagConfig = pTableLuckyBag.findByPrimaryKey( response.type );
        _pChatSystem.broadcastMessage( CChatChannel.GUILD, _playerData.teamData.name + ':' + luckyBagConfig.name, CChatType.CLUB_BAG_INVITATION );

    }
    private function _onClubMsgResponseHandler( evt : CClubEvent ):void{
        if( !_clubWelfareBagUI || !_clubWelfareBagUI.parent )
            return;
        _clubWelfareBagUI.img_red2.visible = true;
        _pClubManager.playerLuckyBagState = 1;
        _pClubHandler.onLuckyBagInfoListRequest( CClubConst.USER_BAG_LIST );
    }

    public function addDisplay( tab : int = 0 ) : void {
        _tab = tab;
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
        uiCanvas.addDialog( _clubWelfareBagUI );
//        uiCanvas.addPopupDialog( _clubWelfareBagUI );
        _addEventListeners();

        _clubWelfareBagUI.tab.selectedIndex = _tab;
        _clubWelfareBagUI.tab.callLater( _onBtnTabSelectHandler,[_tab]);
//        _clubWelfareBagUI.tab.selectedIndex = CClubConst.BAG_BASE_INFO;
//        _clubWelfareBagUI.tab.callLater( _onBtnTabSelectHandler,[CClubConst.BAG_BASE_INFO]);
    }
    public function removeDisplay() : void {
        if ( _clubWelfareBagUI ) {
            _clubWelfareBagUI.close( Dialog.CLOSE );
        }
    }

    public function setTabIndex( index : int ):void{
        _clubWelfareBagUI.tab.selectedIndex = index;
        _clubWelfareBagUI.tab.callLater( _onBtnTabSelectHandler,[index]);
    }
    private function _addEventListeners():void{
        _removeEventListeners();

        system.addEventListener( CClubEvent.LUCKY_BAGINFO_LIST_RESPONSE ,_onClubBagResponseHandler );
        system.addEventListener( CClubEvent.GET_LUCKY_BAG_RESPONSE ,_onClubGetBagResponseHandler );
        system.addEventListener( CClubEvent.SEND_LUCKY_BAG_RESPONSE ,_onClubSendBagResponseHandler );
        system.addEventListener( CClubEvent.CLUB_MSG_RESPONSE ,_onClubMsgResponseHandler );
        system.addEventListener( CClubEvent.CLUB_BAG_RECHARGE_RESPONSE ,_onRechargeLuckyBagResponse );

    }
    private function _removeEventListeners():void{
        system.removeEventListener( CClubEvent.LUCKY_BAGINFO_LIST_RESPONSE ,_onClubBagResponseHandler );
        system.removeEventListener( CClubEvent.GET_LUCKY_BAG_RESPONSE ,_onClubGetBagResponseHandler );
        system.removeEventListener( CClubEvent.SEND_LUCKY_BAG_RESPONSE ,_onClubSendBagResponseHandler );
        system.removeEventListener( CClubEvent.CLUB_MSG_RESPONSE ,_onClubMsgResponseHandler );
        system.removeEventListener( CClubEvent.CLUB_BAG_RECHARGE_RESPONSE ,_onRechargeLuckyBagResponse );
    }
    private function _onClose( type : String ) : void {
        switch ( type ) {
            default:
                break;
        }
        _removeEventListeners();
    }

    private function get _pClubHandler():CClubHandler{
        return system.getBean( CClubHandler ) as CClubHandler;
    }
    private function get _pClubManager():CClubManager{
        return system.getBean( CClubManager ) as CClubManager;
    }
    private function get _pClubWelfareBagInfoViewHandler():CClubWelfareBagInfoViewHandler{
        return system.getBean( CClubWelfareBagInfoViewHandler ) as CClubWelfareBagInfoViewHandler;
    }
    private function get _pClubWelfareBagSendViewHandler():CClubWelfareBagSendViewHandler{
        return system.getBean( CClubWelfareBagSendViewHandler ) as CClubWelfareBagSendViewHandler;
    }
    private function get _pClubWelfareBagGetViewHandler():CClubWelfareBagGetViewHandler{
        return system.getBean( CClubWelfareBagGetViewHandler ) as CClubWelfareBagGetViewHandler;
    }
    private function get _pClubWelfareBagRechargeViewHandler():CClubWelfareBagRechargeViewHandler{
        return system.getBean( CClubWelfareBagRechargeViewHandler ) as CClubWelfareBagRechargeViewHandler;
    }
    private function get _pClubBagSendInfoViewHandler():CClubBagSendInfoViewHandler{
        return system.getBean( CClubBagSendInfoViewHandler ) as CClubBagSendInfoViewHandler;
    }

    public function get m__clubWelfareBagUI() : ClubWelfareBagUI {
        return _clubWelfareBagUI;
    }
    private function get _pChatSystem():CChatSystem{
        return  system.stage.getSystem( CChatSystem ) as CChatSystem;
    }
    private function get _playerData() : CPlayerData {
        return ( _playerSystem.getBean( CPlayerManager ) as CPlayerManager ).playerData;
    }
    private function get _playerSystem() : CPlayerSystem {
        return system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }
    private function get _pCDatabaseSystem():CDatabaseSystem{
        return system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }

}
}
