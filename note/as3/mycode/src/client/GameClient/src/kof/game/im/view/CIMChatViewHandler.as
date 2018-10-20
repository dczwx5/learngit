//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/5/4.
 */
package kof.game.im.view {

import flash.display.DisplayObject;
import flash.filters.GlowFilter;
import flash.geom.Rectangle;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

import kof.SYSTEM_ID;
import kof.framework.CViewHandler;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.chat.CChatFaceViewHandler;
import kof.game.chat.CChatMessageList;
import kof.game.chat.CChatSystem;
import kof.game.chat.CRichTextField;
import kof.game.chat.data.CChatConst;
import kof.game.im.CIMEvent;
import kof.game.im.CIMHandler;
import kof.game.im.CIMManager;
import kof.game.im.CIMSystem;
import kof.game.im.data.CIMChatData;
import kof.game.im.data.CIMFriendsData;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerData;
import kof.game.systemnotice.CSystemNoticeConst;
import kof.game.systemnotice.CSystemNoticeSystem;
import kof.ui.CUISystem;
import kof.ui.chat.ChatSystemFaceUI;
import kof.ui.master.im.IMChatInfoItemUI;
import kof.ui.master.im.IMChatItemUI;
import kof.ui.master.im.IMChatSelfInfoItemUI;
import kof.ui.master.im.IMChatUI;

import morn.core.components.Component;
import morn.core.components.Dialog;
import morn.core.components.View;
import morn.core.events.UIEvent;
import morn.core.handlers.Handler;

public class CIMChatViewHandler extends CViewHandler {

    private var m_IMChatUI:IMChatUI;

    private var _friendsAry:Array;

    private var _selectIndex : int;

    private var _curFriendsData : Object;

    private var m_bFocused : Boolean;

    private var _chatItemAry:Array;

    private var m_pCloseHandler : Handler;

    private var m_bViewInitialized : Boolean;


    public function CIMChatViewHandler() {
        super( false );
    }
    override public function dispose() : void {
        super.dispose();

        removeDisplay();
        m_IMChatUI = null;
    }
    override public function get viewClass() : Array {
        return [ IMChatUI ,ChatSystemFaceUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }
    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;
        if ( !m_bViewInitialized ) {
            if( !_friendsAry ){
                _friendsAry = [];
            }
            if( !_chatItemAry ){
                _chatItemAry = [];
            }
            if ( !m_IMChatUI ) {
                m_IMChatUI = new IMChatUI();
                m_IMChatUI.closeHandler = new Handler( _onClose );

                m_IMChatUI.list.renderHandler = new Handler( renderItem );
                m_IMChatUI.list.selectHandler = new Handler( selectItemHandler );
                m_IMChatUI.list.dataSource = [];
            }

            m_bViewInitialized = true;
        }
        return m_bViewInitialized;
    }


    private function renderItem(item:Component, idx:int):void {
        if (!(item is IMChatItemUI)) {
            return;
        }
        var pIMChatItemUI:IMChatItemUI = item as IMChatItemUI;
        if(pIMChatItemUI.dataSource){
            pIMChatItemUI.img_head.url = CPlayerPath.getUIHeroIconBigPath(pIMChatItemUI.dataSource.headID);
            pIMChatItemUI.txt_name.text = pIMChatItemUI.dataSource.name;
            var pMaskDisplayObject : DisplayObject = pIMChatItemUI.maskimg;
            if ( pMaskDisplayObject ) {
                pIMChatItemUI.img_head.cacheAsBitmap = true;
                pMaskDisplayObject.cacheAsBitmap = true;
                pIMChatItemUI.img_head.mask = pMaskDisplayObject;
            }
            _updateItemNewTips( pIMChatItemUI );

            pIMChatItemUI.btn_close.clickHandler = new Handler( _onCloseItem ,[pIMChatItemUI.dataSource] );
        }
    }
    private function selectItemHandler( index : int ) : void {
        var pIMChatItemUI : IMChatItemUI = m_IMChatUI.list.getCell( index ) as IMChatItemUI;
        if ( !pIMChatItemUI || !pIMChatItemUI.dataSource )
            return;
        _curFriendsData = pIMChatItemUI.dataSource;
        _imChatInputViewHandler.setCurFriendsData( _curFriendsData );

        m_IMChatUI.img_head.url = CPlayerPath.getUIHeroIconBigPath(pIMChatItemUI.dataSource.headID);
        m_IMChatUI.txt_name.text = pIMChatItemUI.dataSource.name;
        m_IMChatUI.txt_lv.text = '等级: ' + pIMChatItemUI.dataSource.level ;
        m_IMChatUI.txt_power.text = String( pIMChatItemUI.dataSource.battleValue );
        if( pIMChatItemUI.dataSource.clubName.length )
            m_IMChatUI.txt_guild.text = '俱乐部: ' + pIMChatItemUI.dataSource.clubName;
        else
            m_IMChatUI.txt_guild.text = '俱乐部: 暂无';
        var pMaskDisplayObject : DisplayObject = m_IMChatUI.maskimg;
        if ( pMaskDisplayObject ) {
            m_IMChatUI.img_head.cacheAsBitmap = true;
            pMaskDisplayObject.cacheAsBitmap = true;
            m_IMChatUI.img_head.mask = pMaskDisplayObject;
        }
        m_IMChatUI.txt_nameT.text = pIMChatItemUI.dataSource.name;
        m_IMChatUI.txt_nameT.x = m_IMChatUI.img_title0.x + m_IMChatUI.img_title0.width + 10;
        m_IMChatUI.img_title1.x = m_IMChatUI.txt_nameT.x + m_IMChatUI.txt_nameT.textField.textWidth + 10;

        _selectIndex = index;
        _onUpdateChatItem();

        _imManager.resetChatNew( pIMChatItemUI.dataSource.roleID );
        _updateItemNewTips( pIMChatItemUI );

        _imManager.removeNewNotReadFriendsAry( pIMChatItemUI.dataSource.roleID );

    }

    private function _updateItemNewTips( pIMChatItemUI : IMChatItemUI ):void{
        var num : int = _imManager.getChatNew( pIMChatItemUI.dataSource.roleID );
        if( num ){
            pIMChatItemUI.img_num.visible = true;
            pIMChatItemUI.txt_num.text = String( num );
        }else{
            pIMChatItemUI.img_num.visible = false;
            pIMChatItemUI.txt_num.text = '';
        }
    }
    private function _onCloseItem( ... args ):void{
        deleteFriendsDataByID( args[ 0 ] );
        if( _friendsAry.length == 0 ){
            m_IMChatUI.close( Dialog.CLOSE );
            return;
        }
        m_IMChatUI.list.dataSource = _friendsAry;
        m_IMChatUI.list.selectedIndex = 0;
        callLater(selectItemHandler,[0]);
        _viewChangeHandler();
    }
    private function _onChatInfoResponse( evt:CIMEvent ):void{
        var friendID : Object = evt.data;
        if( _curFriendsData && friendID == _curFriendsData.roleID ){
            _onUpdateChatItem();
//            callLater( _onUpdateChatItem );//todo 优化
        }
        else{
            _onAddItem(  int(friendID) );
            _onNewTips( int(friendID) );
        }

    }
    private function _onAddItem( friendID : int ):void{
        var i:int;
        var has : Boolean;
        for( i = 0 ; i < m_IMChatUI.list.length ; i++ ){
            var pIMChatItemUI:IMChatItemUI = m_IMChatUI.list.getCell( i ) as  IMChatItemUI;
            if( pIMChatItemUI.dataSource && pIMChatItemUI.dataSource.roleID == friendID ){
                has = true;
                break;
            }
        }
        if( !has ){
            addDisplay();
        }
    }
    private function _onNewTips( friendID : int ):void{
        var i:int;
        for( i = 0 ; i < m_IMChatUI.list.length ; i++ ){
            var pIMChatItemUI:IMChatItemUI = m_IMChatUI.list.getCell( i ) as  IMChatItemUI;
            if( pIMChatItemUI.dataSource && pIMChatItemUI.dataSource.roleID == friendID ){
                _updateItemNewTips( pIMChatItemUI );
                break;
            }
        }
    }
    private function _onUpdateChatItem():void{
        clearChatItem();
        updateChatData();
    }
    private function clearChatItem():void{
        for each( var pIMChatInfoItemUI : View in  _chatItemAry ){
            pIMChatInfoItemUI.remove();
            pIMChatInfoItemUI = null;
        }
        m_IMChatUI.panel_list.refresh();
        _chatItemAry = [];
    }
    private var _itemX:Number;
    private var _itemY:Number;
    private function updateChatData():void{
        _itemY = 20.0;
        var pIMChatInfoItemUI : View;
        var dataAry : Array = _imManager.getChatInfoByRoleID( _curFriendsData.roleID );
        for each( var chatData:CIMChatData in dataAry){
            if( chatData.senderID == _playerData.ID ){
                pIMChatInfoItemUI =  createChatItem( chatData ) as IMChatSelfInfoItemUI;
            }else{
                pIMChatInfoItemUI =  createChatItem( chatData ) as IMChatInfoItemUI;
            }
            chatData.senderID == _playerData.ID ? _itemX = 260  : _itemX = 18 ;
            m_IMChatUI.panel_list.addElement(pIMChatInfoItemUI,_itemX,_itemY);
            _itemY += pIMChatInfoItemUI.height + 5;
            _chatItemAry.push( pIMChatInfoItemUI );
        }
        _imManager.removeNewNotReadFriendsAry( _curFriendsData.roleID );
        m_IMChatUI.panel_list.scrollTo( 0,_itemY );
    }

    private function createChatItem( chatData:CIMChatData ) : View {
        var chatItemUI : View;

        var rtf : CRichTextField = new CRichTextField();
//        rtf.filters = [new GlowFilter(0, 1, 1.2, 1.2, 10)];
        rtf.textfield.autoSize = TextFieldAutoSize.LEFT;
        rtf.textfield.multiline = true;
        rtf.textfield.wordWrap = true;
        rtf.textfield.condenseWhite = true;
        rtf.html = true;
        rtf.lineHeight = 24;//30
        rtf.faceRect = new Rectangle(0,0,18,18);//24
        var tf : TextFormat = new TextFormat('宋体',13);
        rtf.defaultTextFormat = tf;
        tf = rtf.defaultTextFormat;


        if( chatData.senderID == _playerData.ID ){
             chatItemUI  = new IMChatSelfInfoItemUI();
             tf.color = 0xfcfdff;
        }else {
             chatItemUI  = new IMChatInfoItemUI();
             tf.color = 0xd9e0ee;
        }
        var pMaskDisplayObject : DisplayObject = chatItemUI['maskimg'];
        if ( pMaskDisplayObject ) {
            chatItemUI['img_head'].cacheAsBitmap = true;
            pMaskDisplayObject.cacheAsBitmap = true;
            chatItemUI['img_head' ].mask = pMaskDisplayObject;
        }
        chatItemUI['img_head'].url = CPlayerPath.getUIHeroIconBigPath( chatData.headID);

        chatItemUI['box'].addElement( rtf, 0, 0 );
        chatItemUI.dataSource = chatData;

        var xml : XML;
        xml = XML( chatData.message );
        rtf.importXML( xml );
        rtf.setSize( 220 ,60 );
        if( rtf.textfield.textWidth >= 220 ){
            rtf.setSize( 220 ,rtf.textfield.textHeight + 10 );
        }else{
            rtf.setSize( rtf.textfield.textWidth + 10 ,rtf.textfield.textHeight + 10 );
        }

//        chatItemUI['box' ].opaqueBackground = '0x93ff85'
        if( chatData.senderID == _playerData.ID ){
            chatItemUI['box' ].x = 235 -  chatItemUI['box' ].width;
            chatItemUI['img_bg' ].x = chatItemUI['box' ].x - 15;
            chatItemUI['img_bg'].width = chatItemUI['box'].width + 25;
            chatItemUI['img_bg'].height = chatItemUI['box'].height + 15;
        }else{
            chatItemUI['img_bg'].width = chatItemUI['box'].width + 25;
            chatItemUI['img_bg'].height = chatItemUI['box'].height + 15;
        }


        return chatItemUI;
    }




    private function _viewChangeHandler():void{//这里要看UI怎么改
        m_IMChatUI.box_left.visible = _friendsAry.length > 1 ;
    }
    private function addFriendsData( friendsData : Object ):void{
        var bool : Boolean;
        var obj : Object;
        for each( obj in _friendsAry ){
           if( obj.roleID == friendsData.roleID ){
               bool = true;
               break;
           }
        }
        if( !bool )
            _friendsAry.push( friendsData );
    }
    private function isFriendTalking( friendsData : Object ):Boolean{
        var bool : Boolean;
        var obj : Object;
        for each( obj in _friendsAry ){
            if( obj.roleID == friendsData.roleID ){
                bool = true;
                break;
            }
        }
        return bool;
    }
    private function deleteFriendsDataByID( friendsData : Object ):void{
       if( _friendsAry.indexOf( friendsData ) != -1 )
           _friendsAry.splice(_friendsAry.indexOf(friendsData),1);
    }


    private function _onListChange( evt : UIEvent ) : void {
        m_IMChatUI.list.removeEventListener( UIEvent.ITEM_RENDER, _onListChange );
        callLater(selectItemHandler,[_selectIndex]);
    }

    private function _addEventListeners() : void {
        _removeEventListeners();
        system.addEventListener( CIMEvent.CHAT_INFO_RESPONSE,_onChatInfoResponse );
        m_IMChatUI.list.addEventListener( UIEvent.ITEM_RENDER, _onListChange );
    }
    private function _removeEventListeners() : void {
        if ( m_IMChatUI ) {
            system.removeEventListener( CIMEvent.CHAT_INFO_RESPONSE,_onChatInfoResponse );
            m_IMChatUI.list.removeEventListener( UIEvent.ITEM_RENDER, _onListChange );
        }
    }
    final public function get focused() : Boolean {
        return m_bFocused;
    }

    final public function set focused( value : Boolean ) : void {
        m_bFocused = value;
    }

    public function get closeHandler() : Handler {
        return m_pCloseHandler;
    }
    public function set closeHandler( value : Handler ) : void {
        m_pCloseHandler = value;
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
    private function _addToDisplay() : void {
        if ( m_IMChatUI ){
            _imManager.addNewToChatFriendsAry();
            if( _imManager.firstShowChatFriendID > 0){//如果是从菜单打开的，展示当前菜单好友
                if( _imManager.curChatFriendsAry.indexOf( _imManager.firstShowChatFriendID ) != -1 ){
                    _imManager.curChatFriendsAry.splice( _imManager.curChatFriendsAry.indexOf( _imManager.firstShowChatFriendID ), 1 );
                }
                _imManager.curChatFriendsAry.unshift( _imManager.firstShowChatFriendID );
                _imManager.firstShowChatFriendID = 0;
            }
            var pCIMFriendsData : CIMFriendsData;
            for each( var roleID : int in _imManager.curChatFriendsAry ){
                pCIMFriendsData = _imManager.getFriendsDataByID( roleID );
//                if( !pCIMFriendsData )
//                    pCIMFriendsData = _imManager.getSearchFriendsDataByID( roleID );
                if( pCIMFriendsData )
                    addFriendsData( pCIMFriendsData );
            }
            _addEventListeners();

            m_IMChatUI.list.addEventListener( UIEvent.ITEM_RENDER, _onListItemRender );
            m_IMChatUI.list.dataSource = _friendsAry;
            _viewChangeHandler();
            uiCanvas.addDialog( m_IMChatUI );

            _pSystemNoticeSystem.hideIcon( CSystemNoticeConst.SYSTEM_CHAT );

            _imChatInputViewHandler.initUI( m_IMChatUI );
        }
    }
    private function _onListItemRender( evt : UIEvent ) : void {
        m_IMChatUI.list.removeEventListener( UIEvent.ITEM_RENDER, _onListItemRender );
        m_IMChatUI.list.selectedIndex = 0;
        m_IMChatUI.list.callLater( selectItemHandler ,[0] );
    }
    public function removeDisplay() : void {
        if ( m_IMChatUI ) {
            m_IMChatUI.close( Dialog.CLOSE );
        }
    }


    private function _onClose( type : String ) : void {
        switch ( type ) {
            default:
                if ( this.closeHandler ) {
                    this.closeHandler.execute();
                }
                break;
        }
        _friendsAry.splice( 0 , _friendsAry.length );
        _selectIndex = 0;
        _removeEventListeners();
        _imManager.resetChatFriendsAry();

        if( _imManager.newNotReadFriendsAry.length > 0 ){
            var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
            if ( pSystemBundleCtx ) {
                var pSystemBundle : ISystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.SYSTEM_NOTICE ) );
                pSystemBundleCtx.setUserData( pSystemBundle, CBundleSystem.NOTICE_ARGS,[CSystemNoticeConst.SYSTEM_CHAT]);
                pSystemBundleCtx.setUserData( pSystemBundle, CBundleSystem.ACTIVATED, true );
            }
        }

        //
        if( _pChatFaceViewHandler.isViewShow  && _pChatFaceViewHandler.isReceiveIsIMChat ){
            _pChatFaceViewHandler.removeDisplay();
        }
    }

    private function get _imHandler():CIMHandler{
        return  _pCIMSystem.getBean( CIMHandler ) as CIMHandler ;
    }
    private function get _imManager():CIMManager{
        return  _pCIMSystem.getBean( CIMManager ) as CIMManager ;
    }
    private function get pCChatSystem():CChatSystem{
        return _pCIMSystem.stage.getSystem( CChatSystem ) as CChatSystem;
    }
    private function get _pChatFaceViewHandler():CChatFaceViewHandler{
        return pCChatSystem.getBean( CChatFaceViewHandler ) as CChatFaceViewHandler;
    }
    private function get _domain():CChatMessageList{
        return pCChatSystem.getBean( CChatMessageList ) as CChatMessageList;
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
    private function get _pCIMSystem():CIMSystem{
        return system.stage.getSystem( CIMSystem ) as CIMSystem;
    }
    private function get _pSystemNoticeSystem():CSystemNoticeSystem{
        return system.stage.getSystem( CSystemNoticeSystem ) as CSystemNoticeSystem
    }
    private function get _imChatInputViewHandler():CIMChatInputViewHandler{
        return system.getBean( CIMChatInputViewHandler ) as CIMChatInputViewHandler
    }
}
}
