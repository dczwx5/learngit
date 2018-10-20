//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/5/4.
 */
package kof.game.im.view {

import flash.events.FocusEvent;

import kof.SYSTEM_ID;
import kof.framework.CViewHandler;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.im.CIMChatSystem;
import kof.game.im.CIMEvent;
import kof.game.im.CIMHandler;
import kof.game.im.CIMManager;
import kof.game.im.data.CIMConst;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.message.Friend.SearchFriendResponse;
import kof.ui.CUISystem;
import kof.ui.master.im.IMSearchUI;

import morn.core.components.Dialog;
import morn.core.handlers.Handler;

public class CIMSearchViewHandler extends CViewHandler {

    private var m_IMSearchUI:IMSearchUI;

    private var _friendID : int;

    private var _friendsData : Object;

    public function CIMSearchViewHandler() {
        super( false );
    }
    override public function get viewClass() : Array {
        return [ IMSearchUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !m_IMSearchUI ) {
            m_IMSearchUI = new IMSearchUI();

            m_IMSearchUI.closeHandler = new Handler( _onClose );
//            m_IMSearchUI.btn_chat.clickHandler = new Handler( _onChatHandler );
            m_IMSearchUI.btn_search.clickHandler = new Handler( _onSearchHandler );
            m_IMSearchUI.btn_add.clickHandler = new Handler( _onAddHandler );
        }

        return Boolean( m_IMSearchUI );
    }

    private function _onSearchResponse( evt : CIMEvent ):void{
        var response:SearchFriendResponse = evt.data as SearchFriendResponse;
        _friendsData = response.playerInfoMap;
        m_IMSearchUI.txt_name.text = _friendsData.name;
        m_IMSearchUI.txt_lv.text = _friendsData.level;
        if( _friendsData.clubName.length ){
            m_IMSearchUI.txt_guild.text = _friendsData.clubName;
        }else{
            m_IMSearchUI.txt_guild.text = '暂无';
        }

    }

    private function onTxtFocus( evt : FocusEvent ) : void {
        if( evt.type == FocusEvent.FOCUS_IN ){
            if( m_IMSearchUI.txt_search.text == CIMConst.DEFAUL_INPUT_SEARCH )
                clearTxtInput();
        }else if( evt.type == FocusEvent.FOCUS_OUT ){
            if( m_IMSearchUI.txt_search.text.length <= 0 )
                resetTxtInput();
        }
    }
    private function resetTxtInput() : void {
        m_IMSearchUI.txt_search.text = CIMConst.DEFAUL_INPUT_SEARCH;
    }
    private function clearTxtInput() : void {
        m_IMSearchUI.txt_search.text = "";
    }
    private function _onChatHandler():void{
        if( !_friendsData ){
            _pCUISystem.showMsgAlert('玩家不存在');
            return;
        }
        if( null == _imManager.getFriendsDataByID( _friendsData.roleID )){
            _pCUISystem.showMsgAlert('只能跟好友聊天，该玩家还不是您的好友');
            return;
        }
        _imManager.addChatFriendsAry( _friendsData.roleID );
//        ( _pIMChatSystem.getBean( CIMChatViewHandler ) as CIMChatViewHandler ).addDisplay();

        var bundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        var bundle : ISystemBundle =  bundleCtx.getSystemBundle( SYSTEM_ID(KOFSysTags.FRIEND_CHAT ));
        bundleCtx.setUserData( bundle, CBundleSystem.ACTIVATED, true );

        m_IMSearchUI.close( Dialog.CLOSE );
    }
    private function _onSearchHandler():void{
        if( m_IMSearchUI.txt_search.text == CIMConst.DEFAUL_INPUT_SEARCH || m_IMSearchUI.txt_search.text.length == 0 ){
            _pCUISystem.showMsgAlert('玩家不存在');
            return;
        }
        ( system.getBean( CIMHandler ) as CIMHandler ).onSearchFriendRequest( m_IMSearchUI.txt_search.text );
    }
    private function _onAddHandler():void{
        if( !_friendsData ){
            _pCUISystem.showMsgAlert('玩家不存在');
            return;
        }
        if( _friendsData.roleID == _playerData.ID ){
            _pCUISystem.showMsgAlert('不能添加自己为好友');
            return;
        }
        ( system.getBean( CIMHandler ) as CIMHandler ).onAddFriendRequest( [_friendsData.roleID],CIMConst.SINGLE );
    }

    private function _addEventListeners() : void {
        system.addEventListener( CIMEvent.SEARCH_FRIEND_RESPONSE, _onSearchResponse );
        m_IMSearchUI.txt_search.addEventListener( FocusEvent.FOCUS_IN, onTxtFocus, false, 0, true );
        m_IMSearchUI.txt_search.addEventListener( FocusEvent.FOCUS_OUT, onTxtFocus, false, 0, true );
    }

    private function _removeEventListeners() : void {
        system.removeEventListener( CIMEvent.SEARCH_FRIEND_RESPONSE, _onSearchResponse );
        m_IMSearchUI.txt_search.removeEventListener( FocusEvent.FOCUS_IN, onTxtFocus );
        m_IMSearchUI.txt_search.removeEventListener( FocusEvent.FOCUS_OUT, onTxtFocus );
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
        uiCanvas.addPopupDialog( m_IMSearchUI );
        _addEventListeners();
    }
    public function removeDisplay() : void {
        if ( m_IMSearchUI ) {
            m_IMSearchUI.close( Dialog.CLOSE );
        }
    }
    private function _onClose( type : String ) : void {
        switch ( type ) {
            default:
                break;
        }
        _removeEventListeners();
    }

    private function get _pCUISystem():CUISystem{
        return system.stage.getSystem( CUISystem ) as CUISystem;
    }
    private function get _imManager():CIMManager{
        return system.getBean(CIMManager) as CIMManager;
    }
    private function get _pIMChatSystem():CIMChatSystem{
        return system.stage.getSystem( CIMChatSystem ) as CIMChatSystem;
    }
    private function get _playerData() : CPlayerData {
        return ( _playerSystem.getBean( CPlayerManager ) as CPlayerManager ).playerData;
    }
    private function get _playerSystem() : CPlayerSystem {
        return system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }

}
}
