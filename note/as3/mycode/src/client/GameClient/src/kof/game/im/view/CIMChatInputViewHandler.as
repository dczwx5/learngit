//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/8/29.
 */
package kof.game.im.view {

import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.text.TextFormat;
import flash.ui.Keyboard;

import kof.framework.CViewHandler;
import kof.framework.events.CEventPriority;
import kof.game.chat.CChatFaceViewHandler;
import kof.game.chat.CChatSystem;
import kof.game.chat.CRichTextField;
import kof.game.chat.data.CChatConst;
import kof.game.im.CIMHandler;
import kof.game.im.CIMManager;
import kof.game.im.CIMSystem;
import kof.game.im.data.CIMConst;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.ui.CUISystem;
import kof.ui.master.im.IMChatUI;
import kof.util.CTextFieldInputUtil;

import morn.core.handlers.Handler;

public class CIMChatInputViewHandler extends CViewHandler {

    private var m_IMChatUI:IMChatUI;

    private var _txtInput : CRichTextField;

    private var m_bFocused : Boolean;

    private var _curFriendsData : Object;

    private var _tf:TextFormat;


    public function CIMChatInputViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }

    public function initUI( imChatUI:IMChatUI ):void{

        this.m_IMChatUI = imChatUI;

        m_IMChatUI.btn_send.clickHandler = new Handler( _onBtnCkHandler,[m_IMChatUI.btn_send]);
        m_IMChatUI.btn_face.clickHandler = new Handler( _onBtnCkHandler,[m_IMChatUI.btn_face]);

        if( !_txtInput ){
            _tf = new TextFormat();
            _tf.color = '0xd9f0ff';
            _tf.size = 12;
            _tf.font = "Simsun";

            _txtInput = new CRichTextField();
            _txtInput.textfield.multiline = true;
            _txtInput.textfield.wordWrap = true;
            _txtInput.textfield.tabEnabled = false;
            _txtInput.html = false;
            _txtInput.setSize(590, 105);
            _txtInput.type = CRichTextField.INPUT;
            _txtInput.defaultTextFormat = _tf;
            _txtInput.faceRect = new Rectangle(0,0,24,24);
            _txtInput.text = CIMConst.DEFULT_INPUT_CHAT ;

            m_IMChatUI.addElement( _txtInput, 201, 385 );
//            _txtInput.opaqueBackground = '0xff0000';

            _txtInput.addEventListener( FocusEvent.FOCUS_IN, onTxtFocus, false, 0, true );
            _txtInput.addEventListener( FocusEvent.FOCUS_OUT, onTxtFocus, false, 0, true );
            _txtInput.addEventListener( KeyboardEvent.KEY_DOWN, onTxtInputKeyDown, false, CEventPriority.DEFAULT, true );
            _txtInput.addEventListener( KeyboardEvent.KEY_UP, onTxtInputKeyUp, false, CEventPriority.DEFAULT, true );
            _txtInput.addEventListener( Event.CHANGE, onTxtChange, false, 0, true);
        }
    }

    private function _onBtnCkHandler(... args):void {
        switch ( args[ 0 ] ) {
            case m_IMChatUI.btn_send://发送
                sendMsg();
                break;
            case m_IMChatUI.btn_face://表情
                faceHandler();
                break;
        }
    }
    private function faceHandler() : void {
        var pCChatSystem: CChatSystem = system.stage.getSystem( CChatSystem ) as CChatSystem;
        var pChatFaceViewHandler : CChatFaceViewHandler = pCChatSystem.getBean( CChatFaceViewHandler ) as CChatFaceViewHandler;
        pChatFaceViewHandler.addDisplay(  this, m_IMChatUI.btn_face, 40, -230 );
    }

    public function addFaceToTxt( faceCode:String):void{
        if( _txtInput.text == CIMConst.DEFULT_INPUT_CHAT )
            clearTxtInput();
        _txtInput.insertSprite( 'kof.game.chat.face.CFace' + faceCode.replace('/','') );
        _txtInput.faceRect = new Rectangle(0,0,24,24);

        system.stage.flashStage.focus = _txtInput;


    }

    public function setCurFriendsData( friendsData : Object ):void{
        _curFriendsData = friendsData;

    }
    private function sendMsg( evt : MouseEvent = null ) : void {

        var inputText : String;
        inputText = _txtInput.text;
        if ( inputText.length <= 0 && _txtInput.numSprites <= 0){
            _pCUISystem.showMsgAlert( "不能发送空消息" );
            return;
        }
        if( inputText == CIMConst.DEFULT_INPUT_CHAT ){
            _pCUISystem.showMsgAlert( "不能发送空消息" );
            return;
        }

        _imHandler.onChatWithFriendRequest(_curFriendsData.roleID ,_playerData.ID, getInputString());
        clearTxtInput();
    }

    private function onTxtChange( evt :Event ):void{
        checkTxtInput();
    }
    private function onTxtFocus( evt : FocusEvent ) : void {
        this.focused = evt.type == FocusEvent.FOCUS_IN;
        if( evt.type == FocusEvent.FOCUS_IN ){
            if( _txtInput.text == CIMConst.DEFULT_INPUT_CHAT )
                clearTxtInput();
        }else if( evt.type == FocusEvent.FOCUS_OUT ){
            if( _txtInput.text.length <= 0  && _txtInput.numSprites <= 0 )
                resetTxtInput();
            system.stage.flashStage.focus = null;
        }
    }

    private function onTxtInputKeyUp( event : KeyboardEvent ) : void {
        if ( this.focused ) {
            if ( event.keyCode == Keyboard.ENTER )
                sendMsg();
            event.stopPropagation();
        }
    }
    private function onTxtInputKeyDown( event : KeyboardEvent ) : void {
        if ( this.focused )
            event.stopPropagation();
    }
    private function checkTxtInput():void{
        if( CTextFieldInputUtil.getTextCount( _txtInput.text ) > CIMConst.CHAT_STR_MAX_CHARS ){
            //todo ，还原
            _txtInput.textfield.text = CTextFieldInputUtil.getSubTextByLength( _txtInput.textfield.text, CIMConst.CHAT_STR_MAX_CHARS );
            _pCUISystem.showMsgAlert('已超出最大字数限制');
        }
    }
    public function resetTxtInput() : void {
        _txtInput.defaultTextFormat = _tf;
        _txtInput.text = CIMConst.DEFULT_INPUT_CHAT ;
    }
    private function clearTxtInput() : void {
        _txtInput.clear();
        _txtInput.defaultTextFormat = _tf;
    }
    private function removeBlank( str : String ):String{//去掉左右空格
        if( str == null)
            return null;
        var pattern:RegExp = /^\s*|\s*$/;
        return str.replace( pattern ,'');
    }

    final public function get focused() : Boolean {
        return m_bFocused;
    }

    final public function set focused( value : Boolean ) : void {
        m_bFocused = value;
    }

    public function getInputString( offsetI : int = 0):String{
        return _txtInput.exportXML( offsetI ).toString();
    }

    private function get _imHandler():CIMHandler{
        return  _pCIMSystem.getBean( CIMHandler ) as CIMHandler ;
    }
    private function get _imManager():CIMManager{
        return  _pCIMSystem.getBean( CIMManager ) as CIMManager ;
    }
    private function get _pCIMSystem():CIMSystem{
        return system.stage.getSystem( CIMSystem ) as CIMSystem;
    }
    private function get _pCUISystem():CUISystem{
        return system.stage.getSystem( CUISystem ) as CUISystem;
    }
    private function get _playerData() : CPlayerData {
        return ( _playerSystem.getBean( CPlayerManager ) as CPlayerManager ).playerData;
    }
    private function get _playerSystem() : CPlayerSystem {
        return system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }
}
}
