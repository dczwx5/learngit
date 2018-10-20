//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2016/12/21.
 */
package kof.game.chat {

import flash.events.Event;
import flash.geom.Point;

import kof.framework.CViewHandler;
import kof.game.chat.data.CChatConst;
import kof.game.im.CIMChatSystem;
import kof.game.im.view.CIMChatInputViewHandler;
import kof.table.ChatEmoticonShop;
import kof.table.ChatEmoticonShopChild;
import kof.table.ChatEmoticonSystem;
import kof.ui.chat.CFItemUI;
import kof.ui.chat.CFTabUI;
import kof.ui.chat.CFaceUI;
import kof.ui.chat.FaceViewUI;

import morn.core.components.Button;
import morn.core.components.Component;
import morn.core.components.Dialog;
import morn.core.events.UIEvent;
import morn.core.handlers.Handler;

public class CChatFaceViewHandler extends CViewHandler {

    private var m_faceViewUI : FaceViewUI ;
    private var _curEmoticonID : int;
    private var _isShowCloseBtn : Boolean;

    private var _receive : CViewHandler;
    private var _hitBtn : Button ;
    private var _offx : int;
    private var _offy : int;

    public function CChatFaceViewHandler() {
        super( false );
    }
    override public function get viewClass() : Array {
        return [ FaceViewUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if( !m_faceViewUI ){
            m_faceViewUI = new FaceViewUI();
            m_faceViewUI.list_tab.renderHandler = new Handler( renderListTab );
            m_faceViewUI.list_tab.selectHandler = new Handler( selectListTabItemHandler );

            m_faceViewUI.view_faceshop.list.renderHandler = new Handler( renderFaceShop );
            m_faceViewUI.view_faceshop.list.selectHandler = new Handler( selectFaceShopHandler );

            m_faceViewUI.view_facebuy.list.renderHandler = new Handler( renderFaceBuy );
            m_faceViewUI.view_facebuy.list.selectHandler = new Handler( selectFaceBuyHandler );
            m_faceViewUI.view_facebuy.btn_buy.clickHandler = new Handler( onFaceBuyHandler );

            m_faceViewUI.view_face.list.renderHandler = new Handler( renderFace );
            m_faceViewUI.view_face.list.selectHandler = new Handler( selectFaceHandler );
            m_faceViewUI.view_face.list.mouseHandler = new Handler( onMouseHandler );


            m_faceViewUI.btn_return.clickHandler = new Handler( onReturnHandler );
            m_faceViewUI.btn_left.clickHandler = new Handler(_onLeft);
            m_faceViewUI.btn_right.clickHandler = new Handler(_onRight);

            m_faceViewUI.btn_shop.clickHandler = new Handler( _onShopHandler );
            m_faceViewUI.box_shop.visible = false;//todo 策划暂时屏蔽

            m_faceViewUI.view_faceshop.visible =
                    m_faceViewUI.view_facebuy.visible = false;
            m_faceViewUI.view_face.visible = true;

        }

        return Boolean( m_faceViewUI );
    }

    public function get isViewShow():Boolean{
        if( m_faceViewUI )
                return m_faceViewUI.parent;
        return false;
    }
    public function get isReceiveIsIMChat():Boolean{
        if( _receive && _receive is CIMChatInputViewHandler )
                return true;
        return false;
    }

    public function addDisplay( receive : CViewHandler ,hitBtn : Button ,offx : int, offy:int ) : void {
        _receive = receive;
        _hitBtn = hitBtn;
        _offx = offx;
        _offy = offy;
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
        var p:Point = _hitBtn.parent.localToGlobal(new Point(_hitBtn.x,_hitBtn.y));
        m_faceViewUI.x = p.x + _offx;
        m_faceViewUI.y = p.y + _offy;
        m_faceViewUI.popupCenter = false;
        m_faceViewUI.list_tab.selectedIndex = 0;
        uiCanvas.addDialog( m_faceViewUI );
        _addEventListener();

        initViewHandler();
        _onBtnDisabled();
        m__isShowCloseBtn = true;

    }
    public function removeDisplay() : void {
        if ( m_faceViewUI ) {
            m_faceViewUI.close( Dialog.CLOSE );
        }
    }
    private function initViewHandler():void{
        m_faceViewUI.list_tab.dataSource = pCChatMessageList.emoticonList;
        m_faceViewUI.view_facebuy.list.dataSource = pCChatMessageList.chatEmoticonShopTable.toArray();
        m_faceViewUI.view_faceshop.list.dataSource = pCChatMessageList.chatEmoticonShopTable.toArray();
    }
    private function _addEventListener():void{
        _removeEventListener();
        system.addEventListener( CChatEvent.FACE_BUY_SUCC , _onFaceBuySucc );
        m_faceViewUI.list_tab.addEventListener(UIEvent.ITEM_RENDER, _onListTabChange);
    }
    private function _removeEventListener():void{
        system.removeEventListener( CChatEvent.FACE_BUY_SUCC , _onFaceBuySucc );
        m_faceViewUI.list_tab.removeEventListener(UIEvent.ITEM_RENDER, _onListTabChange);
    }

    //////////////////tab////////////////

    private function renderListTab(item:Component, idx:int):void {
        if (!(item is CFTabUI)) {
            return;
        }
        var pCFTabUI:CFTabUI = item as CFTabUI;
        var pData : Object = pCFTabUI.dataSource as Object;
        if( pData ){
            if( pData == CChatConst.SHOP || pData == CChatConst.SYSTEM ){
//                pCFTabUI.img.url = CChatConst.list_tab_icon_url + pData + ".png";
                pCFTabUI.img.skin = 'png.chatsystemface.' + pData ;

            }else{
                pCFTabUI.img.url = CChatConst.list_shopface_icon_url  + pData + "/" + ( pData + 1 ) + ".png";
            }
        }
    }

    private function selectListTabItemHandler( index : int ):void {
        var pCFTabUI : CFTabUI = m_faceViewUI.list_tab.getCell( index ) as CFTabUI;
        if ( !pCFTabUI )
            return;
        var pData : Object = pCFTabUI.dataSource as Object;
        if( pData ){
//            if( pData == CChatConst.SHOP ){
//                m_faceViewUI.view_face.visible =
//                        m_faceViewUI.view_facebuy.visible = false;
//                m_faceViewUI.view_faceshop.visible = true;
//            }else {
                m_faceViewUI.view_faceshop.visible =
                        m_faceViewUI.view_facebuy.visible = false;
                m_faceViewUI.view_face.visible = true;

                if( pData == CChatConst.SYSTEM ){
                    var systemFaces : Array = pCChatMessageList.chatEmoticonSystemTable.toArray();
                    systemFaces.sortOn('iconID',Array.NUMERIC );
                    m_faceViewUI.view_face.list.dataSource = systemFaces;
                }
                else{
                    m_faceViewUI.view_face.list.dataSource = pCChatMessageList.getChatEmoticonShopChildAryByParentID( int( pData ) );
                }

//            }

            m__isShowCloseBtn = true;
        }
    }

    private function _onShopHandler():void{
        m_faceViewUI.view_face.visible =
                m_faceViewUI.view_facebuy.visible = false;
        m_faceViewUI.view_faceshop.visible = true;
        m__isShowCloseBtn = true;
        m_faceViewUI.list_tab.selectedIndex = -1;
    }

    //////////////////faceshop////////////////

    private function renderFaceShop(item:Component, idx:int):void {
        if (!(item is CFItemUI)) {
            return;
        }
        var pCFItemUI:CFItemUI = item as CFItemUI;
        var pData : ChatEmoticonShop = pCFItemUI.dataSource as ChatEmoticonShop;
        if( pData ){
            pCFItemUI.txt_name.text = pData.name;
            pCFItemUI.img.url = CChatConst.list_shop_icon_url + pData.ID + ".png";
            pData.price > 0 ? pCFItemUI.txt_price.text = String( pData.price ): pCFItemUI.txt_price.text = "免费";
            var isEmoticonBought : Boolean =  pCChatMessageList.isEmoticonBought(pData.ID)
            pCFItemUI.img_bought.visible = isEmoticonBought;
            pCFItemUI.txt_price.visible = !isEmoticonBought;
        }
    }

    private function selectFaceShopHandler( index : int ):void {
        var pCFItemUI : CFItemUI = m_faceViewUI.view_faceshop.list.getCell( index ) as CFItemUI;
        if ( !pCFItemUI )
            return;
        var pData : ChatEmoticonShop = pCFItemUI.dataSource as ChatEmoticonShop;
        if( pData ){
            m_faceViewUI.view_faceshop.visible =
                    m_faceViewUI.view_face.visible = false;
            m_faceViewUI.view_facebuy.visible = true;
            _curEmoticonID = pData.ID;
            m_faceViewUI.view_facebuy.list.dataSource = pCChatMessageList.getChatEmoticonShopChildAryByParentID( _curEmoticonID );
            m_faceViewUI.view_facebuy.btn_buy.visible = !pCChatMessageList.isEmoticonBought( _curEmoticonID);
            if( m_faceViewUI.view_facebuy.btn_buy.visible )
                m_faceViewUI.view_facebuy.btn_buy.label = String( pData.price );

            m__isShowCloseBtn = false;
        }
    }
    //////////////////facebuy////////////////

    private function renderFaceBuy(item:Component, idx:int):void {
        if (!(item is CFaceUI)) {
            return;
        }
        var pCFaceUI:CFaceUI = item as CFaceUI;
        var pData : ChatEmoticonShopChild = pCFaceUI.dataSource as ChatEmoticonShopChild;
        if( pData ){
            pCFaceUI.img.url = CChatConst.list_shopface_icon_url  + pData.parentID + "/" + pData.iconID + ".png";
//            pCFaceUI.toolTip = pData.name;
        }
    }

    private function selectFaceBuyHandler( index : int ):void {
        var pCFaceUI : CFaceUI = m_faceViewUI.view_facebuy.list.getCell( index ) as CFaceUI;
        if ( !pCFaceUI )
            return;
        var pData : ChatEmoticonShopChild = pCFaceUI.dataSource as ChatEmoticonShopChild;
        if( pData ){
        }
    }

    //////////////////face////////////////

    private function renderFace(item:Component, idx:int):void {
        if (!(item is CFaceUI)) {
            return;
        }
        var pCFaceUI:CFaceUI = item as CFaceUI;
        var pData : Object = pCFaceUI.dataSource as Object;
        if( pData ){
            if( pData is ChatEmoticonSystem ){
                pCFaceUI.img.skin = 'png.chatsystemface.' + pData.iconID ;
                pCFaceUI.img.width = pCFaceUI.img.height = 24;
                pCFaceUI.img.x = ( pCFaceUI.width - pCFaceUI.img.width ) / 2;
                pCFaceUI.img.y = ( pCFaceUI.height - pCFaceUI.img.height ) / 2;
            }else if( pData is ChatEmoticonShopChild ){
                pCFaceUI.img.url = CChatConst.list_shopface_icon_url  + pData.parentID + "/" + pData.iconID + ".png";
                pCFaceUI.img.width = pCFaceUI.img.height = 36;
                pCFaceUI.img.x = 1;
                pCFaceUI.img.y = 1;
            }
//            pCFaceUI.toolTip = pData.name;
        }
    }

    private function selectFaceHandler( index : int ):void {
        var pCFaceUI : CFaceUI = m_faceViewUI.view_face.list.getCell( index ) as CFaceUI;
        if ( !pCFaceUI )
            return;
        var pData : Object = pCFaceUI.dataSource as Object;
        if( pData ){
            if( _receive is CChatViewHandler )
               _pChatInputViewHandler.addFace( pData.ID );
            else if( _receive is CIMChatInputViewHandler ){
                ( _pIMChatSystem.getBean( CIMChatInputViewHandler ) as CIMChatInputViewHandler ).addFaceToTxt( pData.ID ) ;
            }

            m_faceViewUI.view_face.list.selectedIndex = -1;
            m_faceViewUI.close();
        }
    }

    private function onMouseHandler( evt:Event,idx : int ) : void {
//        var pCFaceUI : CFaceUI = m_faceViewUI.view_face.list.getCell( idx ) as CFaceUI;
//        if ( evt.type == MouseEvent.ROLL_OUT ) {
//            pCFaceUI.toolTip = '';
//        }else if( evt.type == MouseEvent.ROLL_OVER ){
//            var pData : ChatEmoticonShopChild = pCFaceUI.dataSource as ChatEmoticonShopChild;
//            if( pData ){
//                pCFaceUI.img.url = CChatConst.list_shopface_icon_url  + pData.parentID + "/" + pData.iconID + ".png";
//                pCFaceUI.toolTip = pData.name;
//            }
//        }
    }

    ////////////////
    private function onReturnHandler():void{
        m__isShowCloseBtn = true;
        m_faceViewUI.list_tab.selectedIndex = 0;
        callLater( selectListTabItemHandler , 0 );
    }
    private function onFaceBuyHandler():void{
        var chatEmoticonShop : ChatEmoticonShop = pCChatMessageList.getChatEmoticonShopTableByID( _curEmoticonID );
        uiCanvas.showMsgBox( "您确定花费" + chatEmoticonShop.price + "钻购买" + chatEmoticonShop.name
                + "表情包?\n这是一个明智的决定", onBuyEmoticon );
        function onBuyEmoticon():void{
            pCChatHandler.onBuyEmoticonRequest( _curEmoticonID );
        }

    }
    private function _onFaceBuySucc( evt : CChatEvent ):void{
        var emoticonID : int = int( evt.data );
        var index :int = pCChatMessageList.emoticonList.indexOf( emoticonID );
        m_faceViewUI.list_tab.selectedIndex = index;
        m_faceViewUI.list_tab.dataSource = pCChatMessageList.emoticonList;
        _onBtnDisabled();
        m_faceViewUI.view_faceshop.list.refresh();
    }
    private function _onListTabChange( evt:UIEvent ):void{
        callLater( selectListTabItemHandler, m_faceViewUI.list_tab.selectedIndex );
    }
    private function _onLeft() : void {
        if( m_faceViewUI.list_tab.page <= 0 )
            return;
        m_faceViewUI.list_tab.page --;
        _onBtnDisabled();
    }
    private function _onRight() : void {
        if( m_faceViewUI.list_tab.page >= m_faceViewUI.list_tab.totalPage )
            return;
        m_faceViewUI.list_tab.page ++;
        _onBtnDisabled();
    }
    private function _onBtnDisabled():void{
        m_faceViewUI.btn_left.disabled = m_faceViewUI.list_tab.page <= 0;
        m_faceViewUI.btn_right.disabled = m_faceViewUI.list_tab.page >= m_faceViewUI.list_tab.totalPage - 1;
    }

    public override function dispose() : void {
        super.dispose();
        _removeEventListener();
    }
    public function set m__isShowCloseBtn( value : Boolean ) : void {
        _isShowCloseBtn = value;
        m_faceViewUI.btn_close.visible = _isShowCloseBtn;
        m_faceViewUI.btn_return.visible = !_isShowCloseBtn;
        if( _isShowCloseBtn )
            m_faceViewUI.view_faceshop.list.selectedIndex = -1;

    }

    private function get _pIMChatSystem():CIMChatSystem{
        return system.stage.getSystem( CIMChatSystem ) as CIMChatSystem;
    }
    private function get pCChatMessageList():CChatMessageList{
        return system.getBean(CChatMessageList) as CChatMessageList;
    }
    private function get pCChatHandler():CChatHandler{
        return system.getBean(CChatHandler) as CChatHandler;
    }
    private function get _pChatInputViewHandler():CChatInputViewHandler{
        return system.getBean(CChatInputViewHandler) as CChatInputViewHandler;
    }
}
}
