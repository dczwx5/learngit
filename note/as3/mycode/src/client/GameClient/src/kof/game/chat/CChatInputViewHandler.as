//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/8/10.
 */
package kof.game.chat {

import QFLib.Utils.StringUtil;

import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.SoftKeyboardTrigger;
import flash.geom.Rectangle;
import flash.text.TextFormat;
import flash.ui.Keyboard;

import kof.SYSTEM_ID;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.framework.events.CEventPriority;
import kof.game.KOFSysTags;
import kof.game.Tutorial.CTutorSystem;
import kof.game.bundle.CSystemBundleContext;
import kof.game.bundle.ISystemBundleContext;
import kof.game.chat.data.CChatChannel;
import kof.game.chat.data.CChatConst;
import kof.game.chat.data.CChatData;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.reciprocation.CReciprocalSystem;
import kof.table.ChatConstant;
import kof.ui.CUISystem;
import kof.ui.chat.ChatUI;
import kof.util.CTextFieldInputUtil;

import morn.core.handlers.Handler;

public class CChatInputViewHandler extends CViewHandler {

    private var m_chatUI : ChatUI;

    private var _txtInput : CRichTextField;

    private var m_bFocused : Boolean;

    private var _worldChatCD : Boolean;//世界频道

    private var _guildChatCD : Boolean;//公会

    private var _personalChatCD : Boolean;//私聊

    private var _privateChatName : String;

    private var _chatData:CChatData;

    private var _txtInputWidth : Number;

    private var _tf:TextFormat;

    public function CChatInputViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }

    /////////////////init///////////////
    public function initInputView(  m_chatUI : ChatUI ):void{

        this.m_chatUI = m_chatUI;

        m_chatUI.btn_send.clickHandler = new Handler( sendMsgHandler );

        if( !_txtInput ){
            _tf = new TextFormat();
            _tf.color = 0xffffff;
            _tf.size = 13;
            _tf.font = "Simsun";

            _txtInput = new CRichTextField();
            _txtInput.textfield.multiline = false;
            _txtInput.textfield.wordWrap = false;
            _txtInput.textfield.tabEnabled = false;
            _txtInput.html = false;
            _txtInputWidth = 193;
            _txtInput.setSize(_txtInputWidth, 20);
            _txtInput.type = CRichTextField.INPUT;
            _txtInput.defaultTextFormat = _tf;
            _txtInput.faceRect = new Rectangle(0,0,18,18);//24
            _txtInput.text = CChatConst.defaul_input;

            m_chatUI.addElement( _txtInput, 70, 283 );
//        _txtInput.opaqueBackground = '0xff0000';

            _txtInput.addEventListener( FocusEvent.FOCUS_IN, onTxtFocus, false, 0, true );
            _txtInput.addEventListener( FocusEvent.FOCUS_OUT, onTxtFocus, false, 0, true );
            _txtInput.addEventListener( KeyboardEvent.KEY_DOWN, onTxtInputKeyDown, false, CEventPriority.DEFAULT, true );
            _txtInput.addEventListener( KeyboardEvent.KEY_UP, onTxtInputKeyUp, false, CEventPriority.DEFAULT, true );
            _txtInput.addEventListener( Event.CHANGE, onTxtChange, false, 0, true);
        }


        updateComboxLabels();
    }

    public function updateComboxLabels():void{
        if( !m_chatUI )
            return;
        var bundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        var iStateValue : int = bundleCtx.getSystemBundleState( bundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.GUILD ) ) );
        var labels : String;
        if( iStateValue == CSystemBundleContext.STATE_STARTED ){
            labels = '世界,俱乐部,私聊,喇叭';
        }else{
            labels = '世界,私聊,喇叭';
        }
        if( labels != m_chatUI.combox_channel.labels ){
            m_chatUI.combox_channel.labels = labels;
            m_chatUI.combox_channel.addEventListener( Event.CHANGE, _onComboxInit);
            m_chatUI.combox_channel.selectedIndex = 1;
        }

    }
    private function _onComboxInit( evt : Event):void{
        m_chatUI.combox_channel.removeEventListener( Event.CHANGE, _onComboxInit);
        m_chatUI.combox_channel.selectedIndex = 0;
    }

    ///////////////////////发送聊天消息///////////////////////////////

    public function sendMsgHandler() : void {
//        var channel : int = m_chatUI.combox_channel.selectedIndex + 1;

        var inputText : String;
        inputText = _txtInput.text;
        if( _channel == CChatChannel.PERSONAL ){
            if( StringUtil.beginsWith( inputText ,'/') == false ){
                uiCanvas.showMsgAlert( '私聊输入格式不符合规范,请用"/"开始' );
                return;
            }
            if( inputText.indexOf(' ') == -1 ){
                uiCanvas.showMsgAlert( '私聊输入格式不符合规范,请在玩家名称后面加空格' );
                return;
            }
            _privateChatName = inputText.slice(1,inputText.indexOf(' '));

            if( _privateChatName ==  StringUtil.remove( _playerData.teamData.name , _playerData.teamData.name.slice(0,_playerData.teamData.name.indexOf('.') + 1) )){
                uiCanvas.showMsgAlert( '不能和自己私聊' );
                return;
            }
            inputText = StringUtil.remove( inputText , '/' + _privateChatName  );
            inputText = StringUtil.rightTrim( inputText );
        }

        if ( inputText.length <= 0 && _txtInput.numSprites <= 0){
            uiCanvas.showMsgAlert( "不能发送空消息" );
            return;
        }
        if( ( _channel == CChatChannel.PERSONAL  && _txtInput.text == CChatConst.defaul_priavte_input ) ||
                ( _channel != CChatChannel.PERSONAL  && _txtInput.text == CChatConst.defaul_input ) ){
            uiCanvas.showMsgAlert( "不能发送空消息" );
            return;
        }

        if( _channel == CChatChannel.WORLD && _worldChatCD ){
            uiCanvas.showMsgAlert( "您发言过快" );
            return;
        }else if( _channel == CChatChannel.GUILD && _guildChatCD ){
            uiCanvas.showMsgAlert( "您发言过快" );
            return;
        }else if( _channel == CChatChannel.PERSONAL && _personalChatCD ){
            uiCanvas.showMsgAlert( "您发言过快" );
            return;
        }

        var pTable : IDataTable  = _pCDatabaseSystem.getTable( KOFTableConstants.CHATCONSTANT );
        var chatConstant : ChatConstant = pTable.findByPrimaryKey( 1 );


        if( _channel == CChatChannel.PERSONAL  ){
            _txtInput.text = inputText;//不能去掉这个
            (system as CChatSystem).broadcastMessage( _channel, getInputString( _privateChatName.length + 2 ) , 0, 0 ,_privateChatName  );
            afterSendMsg();
        }else{
            if(_channel == CChatChannel.HORN ){//喇叭
                if( _playerData.teamData.level < chatConstant.labaLevel && _playerData.vipData.vipLv < chatConstant.labaVIPLevel  ){
                    uiCanvas.showMsgBox("vip等级不足" + chatConstant.labaVIPLevel + "级或者战队等级不足" + chatConstant.labaLevel + "级");
                    system.stage.flashStage.focus = null;
                    return;
                }
                system.stage.flashStage.focus = null;
                uiCanvas.showMsgBox("您确定花费" + chatConstant.labaCurrencyNum + "绑钻发送一条喇叭消息吗？",function sendHorn():void{
                    (system.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem).showCostBdDiamondMsgBox( 10, onConfire );
                },null,true,null,null,true,"COST_BIND_D");

            }else{
                (system as CChatSystem).broadcastMessage( m_chatUI.combox_channel.selectedIndex + 1, getInputString() );
                afterSendMsg();
            }

        }
        function onConfire():void{
            (system as CChatSystem).broadcastMessage( CChatChannel.HORN, getInputString() );
            afterSendMsg();
        }
        function afterSendMsg():void{

            if( _channel == CChatChannel.WORLD  ){
                _worldChatCD = !_worldChatCD;
            }else if( _channel == CChatChannel.GUILD  ){
                _guildChatCD = !_guildChatCD;
            }else if( _channel == CChatChannel.PERSONAL  ){
                _personalChatCD = !_personalChatCD;
            }

            clearTxtInput();

            if(  _channel == CChatChannel.PERSONAL  ) {
                _txtInput.append( '/' + _privateChatName + ' ' );
                _txtInput.textfield.setSelection( _txtInput.textfield.text.length, _txtInput.textfield.text.length );
            }




            if( _channel == CChatChannel.WORLD  ){
                unschedule( _onWorldRefreshTime );
                schedule( chatConstant.worldChatCD , _onWorldRefreshTime );
            }else if( _channel == CChatChannel.GUILD  ){
                unschedule( _onGuildRefreshTime );
                schedule( chatConstant.guildCD , _onGuildRefreshTime );
            }else if( _channel == CChatChannel.PERSONAL  ){
                unschedule( _onPersonalRefreshTime );
                schedule( chatConstant.guildCD , _onPersonalRefreshTime );
            }
        }

    }

    ////////////////////发言CD//////////////////////

    private function _onWorldRefreshTime( delta : Number ):void{
        unschedule( _onWorldRefreshTime );
        _worldChatCD = false;
    }
    private function _onGuildRefreshTime( delta : Number ):void{
        unschedule( _onGuildRefreshTime );
        _guildChatCD = false;
    }
    private function _onPersonalRefreshTime( delta : Number ):void{
        unschedule( _onPersonalRefreshTime );
        _personalChatCD = false;
    }

   //////////////////////输入框焦点处理///////////////
    private function onTxtFocus( evt : FocusEvent ) : void {
        this.focused = evt.type == FocusEvent.FOCUS_IN;
        if( evt.type == FocusEvent.FOCUS_IN ){
            if( _channel == CChatChannel.PERSONAL  && _txtInput.text == CChatConst.defaul_priavte_input ){
                clearTxtInput();
            }else if( _channel != CChatChannel.PERSONAL  && _txtInput.text == CChatConst.defaul_input ){
                clearTxtInput();
            }
        }else if( evt.type == FocusEvent.FOCUS_OUT ){
            if( _txtInput.text.length <= 0 && _txtInput.numSprites <= 0 )
                resetTxtInput();
        }
    }
    private function onTxtInputKeyUp( event : KeyboardEvent ) : void {
        if ( this.focused ) {
            if ( event.keyCode == Keyboard.ENTER )
                sendMsgHandler();
            event.stopPropagation();
        }
    }
    private function onTxtInputKeyDown( event : KeyboardEvent ) : void {
        if ( this.focused )
            event.stopPropagation();
    }
    private function onTxtChange( evt :Event ):void{
        checkTxtInput();
    }
    /////////////////////////检查文本长度////////////////////
    private function checkTxtInput():void{
        if( CTextFieldInputUtil.getTextCount( _txtInput.text ) > CChatConst.CHAT_STR_MAX_CHARS ){
            _txtInput.textfield.text = CTextFieldInputUtil.getSubTextByLength( _txtInput.textfield.text, CChatConst.CHAT_STR_MAX_CHARS );
            _pCUISystem.showMsgAlert('已超出最大字数限制');
        }
    }
   //////////////输入框重置//////////////////
    private function resetTxtInput() : void {
        clearTxtInput();
        if( _channel == CChatChannel.PERSONAL   ){
            _txtInput.text = CChatConst.defaul_priavte_input;
        }else {
            _txtInput.text = CChatConst.defaul_input;
        }
    }
    private function clearTxtInput() : void {
        _txtInput.clear();
    }

    ///////////////添加表情//////////////
    public function addFace( faceCode:String ):void{
        if( _channel == CChatChannel.PERSONAL  && _txtInput.text == CChatConst.defaul_priavte_input ){
            clearTxtInput();
        }else if( _channel != CChatChannel.PERSONAL  && _txtInput.text == CChatConst.defaul_input ){
            clearTxtInput();
        }

        _txtInput.insertSprite( 'kof.game.chat.face.CFace' + faceCode.replace('/','') );
        _txtInput.faceRect = new Rectangle(0,0,18,18);//24

        system.stage.flashStage.focus = _txtInput;

        _txtInput.setSize( _txtInputWidth ,_txtInput.textfield.textHeight + 5 );

    }

    //////////////设置私聊对象名称/////
    public function setPrivateChatDatae( chatData : CChatData ):void{
        _chatData = chatData;
    }
//    //////////////设置私聊对象名称/////
//    public function setPrivateChatName( privateChatName :String ):void{
//        _privateChatName = privateChatName;
//    }
    /////////////////////////////////////////


    public function setTxtInputWidth( width : Number ):void{
        _txtInput.setSize(width, 20);
        _txtInputWidth = width;
    }


    public function getInputString( offsetI : int = 0):String{
        return _txtInput.exportXML( offsetI ).toString();
    }

    public function get txtInput() : CRichTextField {
        return _txtInput;
    }
    final public function get focused() : Boolean {
        return m_bFocused;
    }
    final public function set focused( value : Boolean ) : void {
        m_bFocused = value;
    }
    private function get _channel():int{
        return CChatChannel.getChannelByLabel( m_chatUI.combox_channel.labels,m_chatUI.combox_channel.selectedIndex);
    }

    private function get _pCUISystem():CUISystem{
        return system.stage.getSystem( CUISystem ) as CUISystem;
    }

    private function get _pChatViewHandler():CChatViewHandler{
        return system.getBean( CChatViewHandler ) as CChatViewHandler;
    }
    private function get _pCDatabaseSystem():CDatabaseSystem{
        return system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }
    private function get _playerData() : CPlayerData {
        return ( _playerSystem.getBean( CPlayerManager ) as CPlayerManager ).playerData;
    }
    private function get _playerSystem() : CPlayerSystem {
        return system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }
    private function get _pCTutorSystem() : CTutorSystem {
        return system.stage.getSystem( CTutorSystem ) as CTutorSystem;
    }
}
}
