//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/10/13.
 */
package kof.game.chat {

import QFLib.Utils.HtmlUtil;

import flash.events.TextEvent;
import flash.filters.GlowFilter;
import flash.geom.Rectangle;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

import kof.framework.CViewHandler;
import kof.game.chat.data.CChatChannel;
import kof.game.chat.data.CChatConst;
import kof.game.chat.data.CChatData;
import kof.game.chat.data.CChatLinkConst;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.ui.chat.CChatTxVipUI;
import kof.ui.chat.ChatHronUI;
import kof.ui.chat.ChatItemUI;
import kof.ui.chat.ChatUI;

public class CChatHornViewHandler extends CViewHandler {

    private var m_chatUI : ChatUI;
    private var _chatHornI : ChatHronUI;
    private var _chatHornII : ChatHronUI;
    public var chatHornAry : Array;

    public function CChatHornViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }

    /////////////////init///////////////
    public function initHornView( m_chatUI : ChatUI ) : void {

        this.m_chatUI = m_chatUI;
        var rtf : CRichTextField;
        var tf : TextFormat;
        if ( !_chatHornI )
            _chatHornI = initHornItem( _chatHornI );
        if ( !_chatHornII )
            _chatHornII = initHornItem( _chatHornII );
        chatHornAry =[];

        schedule( 2, _onUpdateHornView );
    }

    private function initHornItem( chatHorn : ChatHronUI ) : ChatHronUI {
        chatHorn = new ChatHronUI();
        var chatItemUI : ChatItemUI = chatHorn.chatItem;
        var rtf : CRichTextField = new CRichTextField();
        rtf.filters = [ new GlowFilter( 0, 1, 1.2, 1.2, 10 ) ];
        rtf.textfield.autoSize = TextFieldAutoSize.LEFT;
        rtf.textfield.multiline = true;
        rtf.textfield.wordWrap = true;
        rtf.textfield.condenseWhite = true;
        rtf.textfield.selectable = false;
        rtf.html = true;
        rtf.lineHeight = 24;//24
        rtf.faceRect = new Rectangle( 0, 0, 18, 18 );//24
        rtf.addEventListener( TextEvent.LINK , _onTextLinkHandler );
//        rtf.addEventListener( MouseEvent.MOUSE_MOVE,  _onTextRollHandler );
//        rtf.addEventListener( MouseEvent.MOUSE_OVER,  _onTextRollHandler );
//        rtf.addEventListener( MouseEvent.MOUSE_OUT,  _onTextRollHandler );
//        rtf.addEventListener( MouseEvent.ROLL_OVER,  _onTextRollHandler );
        var tf : TextFormat = new TextFormat( '宋体', 13 );
        rtf.defaultTextFormat = tf;
        rtf.setSize( m_chatUI.panel_list.width - 40, rtf.textfield.textHeight + 10 );
        rtf.name = 'rtf';
        chatItemUI.clip_channel.index = 4;
        tf.color = CChatConst.CHANNEL_TXT_COLOR[ 4 ];
        chatItemUI.addElement( rtf, 35, 0 );
        return chatHorn;
    }

    //////////////////////////////
    private function _onUpdateHornView( delta : Number ) : void {

        var chatHorn : ChatHronUI;
        var chatData : CChatData;
        if ( _chatHornI.parent ) {
            chatData = _chatHornI.dataSource as CChatData;
            if ( chatData.showTime <= 0 ) {
                _chatHornI.remove();
                chatHornAry.splice( chatHornAry.indexOf( _chatHornI ), 1 );
                callLater( resetAllItemXY );
            } else {
                chatData.showTime -= 2;
            }
        }
        if ( _chatHornII.parent ) {
            chatData = _chatHornII.dataSource as CChatData;
            if ( chatData.showTime <= 0 ) {
                _chatHornII.remove();
                chatHornAry.splice( chatHornAry.indexOf( _chatHornII ), 1 );
                callLater( resetAllItemXY );
            } else {
                chatData.showTime -= 2;
            }
        }

        var dataAry : Array;
        if ( m_chatUI.box_horn.numChildren == 1 ) {
            dataAry = _domain.getList( CChatChannel.HORN );
            chatData = dataAry.shift();
            if ( chatData ) {
                if ( !_chatHornI.parent ) {
                    _chatHornI = updateHornItem( chatData, _chatHornI );
                    m_chatUI.box_horn.addChild( _chatHornI );
                    chatHornAry.push( _chatHornI );
                } else {
                    _chatHornII = updateHornItem( chatData, _chatHornII );
                    m_chatUI.box_horn.addChild( _chatHornII );
                    chatHornAry.push( _chatHornII );
                }
                callLater( resetAllItemXY );
            }

        } else if ( m_chatUI.box_horn.numChildren == 0 ) {
            dataAry = _domain.getList( CChatChannel.HORN );
            chatData = dataAry.shift();
            if ( chatData ) {
                _chatHornI = updateHornItem( chatData, _chatHornI );
                m_chatUI.box_horn.addChild( _chatHornI );
                chatHornAry.push( _chatHornI );
                callLater( resetAllItemXY );
            }
            chatData = dataAry.shift();
            if ( chatData ) {
                _chatHornII = updateHornItem( chatData, _chatHornII );
                m_chatUI.box_horn.addChild( _chatHornII );
                chatHornAry.push( _chatHornII );
                callLater( resetAllItemXY );
            }
        }

    }

    public function resetAllItemWH( ):void{
        var chatHorn : ChatHronUI;
        var chatItemUI : ChatItemUI;
        var rtf :CRichTextField;
        for each ( chatHorn in chatHornAry ){
            chatItemUI = chatHorn.chatItem;
            rtf = chatItemUI.getChildByName( 'rtf' ) as CRichTextField;
            rtf.setSize( m_chatUI.panel_list.width - 40, rtf.textfield.textHeight + 10 );
            chatHorn.img_bg.width = rtf.width + 58;
            chatHorn.img_bg.height = rtf.textfield.textHeight + 25;
            chatHorn.height = rtf.textfield.textHeight + 25;
        }
    }
    public function resetAllItemXY():void{
        var chatHorn : ChatHronUI;
        var itemY : int = 0;
        var index : int;
        for( index = chatHornAry.length - 1 ; index >= 0 ; index -- ){
            chatHorn = chatHornAry[index];
            chatHorn.y = itemY;
            itemY += chatHorn.height + 5;
        }
        m_chatUI.box_horn.y = m_chatUI.gm_default.y - m_chatUI.box_horn.height;
    }

    private function updateHornItem( chatData : CChatData, chatHorn : ChatHronUI ) : ChatHronUI {
        var rtf : CRichTextField;
        var tf : TextFormat;
        chatData.showTime = 10;//
        chatHorn.dataSource = chatData;//别去
        var chatItemUI : ChatItemUI = chatHorn.chatItem;
        chatItemUI.dataSource = chatData;//别去
        rtf = chatItemUI.getChildByName( 'rtf' ) as CRichTextField;
        tf = rtf.defaultTextFormat;
        rtf.clear();

        var senderName : String = '';
        var totalStr : String = '';

        if ( _playerData.ID == chatData.senderID ) {
            senderName = chatData.senderName;
        } else {
            senderName = HtmlUtil.hrefAndU( chatData.senderName, CChatLinkConst.SEND_NAME, String( tf.color ) );
        }

        var location : String = '';
        if( chatData.location.length > 0 ){
            location = '[' + chatData.location + ']';
        }
        if( chatData.senderName.length > 0 ){
            senderName = senderName + " : ";
        }

        totalStr = location + senderName;

        var xml : XML;
        if( chatData.location.length <= 0 || chatData.senderName.length <= 0 ){
            xml = <a/>;
            xml.t = chatData.message;
        }
        else { //todo 解析的时候，从 ht+t ，里面i的位置开始插入表情
            xml = XML( chatData.message );
            xml.ht = totalStr;
        }

        rtf.importXML( xml, false, HtmlUtil.removeHtml( totalStr, false ).length );
        if( chatData.location )
            vipInfo( rtf, chatData.location.length + 1, chatData.vipLevel, _domain.getTxVipInfo( chatData ) );

        rtf.setSize( m_chatUI.panel_list.width - 40, rtf.textfield.textHeight + 10 );
        chatHorn.img_bg.width = rtf.width + 58;
        chatHorn.img_bg.height = rtf.textfield.textHeight + 25;
        chatHorn.height = rtf.textfield.textHeight + 25;

        return chatHorn;
    }


    ////////////////点击文本链接//////////////
    private function _onTextLinkHandler( evt : TextEvent ):void{
        var chatItemUI : ChatItemUI = evt.currentTarget.parent as ChatItemUI;
        var text : String = evt.text;
        if( text == CChatLinkConst.SEND_NAME ){
            _pChatMenuHandler.show( chatItemUI );
        }else if( text == CChatLinkConst.ITEM_NAME ){
        }
    }

    ///////////////////腾讯 蓝钻 黄钻 游戏中的VIP
    private function vipInfo( rtf : CRichTextField , index : int ,vipLevel : int = 0 , vipObj : Object = null ):void{

        var txVipFlg : Boolean = true;
        if( vipObj == null || vipObj.type == 0){
            txVipFlg = false;
        }
        var vipImg : CChatTxVipUI = new CChatTxVipUI();
        vipImg.clip_blue.visible =
                vipImg.clip_superBlue.visible =
                        vipImg.clip_year.visible =
                                vipImg.clip_yellow.visible =
                                        vipImg.clip_superYellow.visible =
                                                vipImg.img_vip.visible = false;

        if( txVipFlg ){
            var bigF : Boolean;
            if( vipObj.subType == 1 ){
                vipImg.clip_superBlue.visible = vipImg.clip_year.visible = true;
                vipImg.clip_superBlue.index = vipObj.level - 1;
                vipImg.img_vip.visible = vipLevel > 0;
                if( vipLevel > 0 ){
                    vipImg.img_vip.x = 42;
                    vipImg.img_vip.index = vipLevel;
                }

                bigF = true;
            }else if( vipObj.subType == 2 ){
                vipImg.clip_blue.visible = vipImg.clip_year.visible = true;
                vipImg.clip_blue.index = vipObj.level - 1;
                vipImg.img_vip.visible = vipLevel > 0;
                if( vipLevel > 0 ){
                    vipImg.img_vip.x = 42;
                    vipImg.img_vip.index = vipLevel;
                }

                bigF = true;
            }else if( vipObj.subType == 3 ){
                vipImg.clip_superBlue.visible = true;
                vipImg.clip_superBlue.index = vipObj.level - 1;
                vipImg.img_vip.visible = vipLevel > 0;
                if( vipLevel > 0 ){
                    vipImg.img_vip.x = 22;
                    vipImg.img_vip.index = vipLevel;
                }

            }else if( vipObj.subType == 4 ){
                vipImg.clip_blue.visible = true;
                vipImg.clip_blue.index = vipObj.level - 1;
                vipImg.img_vip.visible = vipLevel > 0;
                if( vipLevel > 0 ){
                    vipImg.img_vip.x = 22;
                    vipImg.img_vip.index = vipLevel;
                }

            }else if( vipObj.subType == 5 ){
                vipImg.clip_superYellow.visible = true;
                vipImg.clip_superYellow.index = vipObj.level - 1;
                vipImg.img_vip.visible = vipLevel > 0;
                if( vipLevel > 0 ){
                    vipImg.img_vip.x = 42;
                    vipImg.img_vip.index = vipLevel;
                }

                bigF = true;
            }else if( vipObj.subType == 6 ){
                vipImg.clip_yellow.visible = true;
                vipImg.clip_yellow.index = vipObj.level - 1;
                vipImg.img_vip.visible = vipLevel > 0;
                if( vipLevel > 0 ){
                    vipImg.img_vip.x = 22;
                    vipImg.img_vip.index = vipLevel;
                }

            }

            if( bigF ){
                if( vipLevel > 0 ){
                    rtf.replace( index + 1, index + 1, '     ' );
                    rtf.insertSprite( vipImg ,index + 3 );
                }else{
                    rtf.replace( index + 1, index + 1, '   ' );
                    rtf.insertSprite( vipImg ,index + 2 );
                }
            }else{
                if( vipLevel > 0 ){
                    rtf.replace( index + 1, index + 1, '   ' );
                    rtf.insertSprite( vipImg ,index + 2 );
                }else{
                    rtf.replace( index + 1, index + 1, '  ' );
                    rtf.insertSprite( vipImg ,index + 1 );
                }
            }
        }else{
            vipImg.img_vip.visible = vipLevel > 0;
            if( vipLevel > 0 ){
                vipImg.img_vip.x = 0;
                vipImg.img_vip.index = vipLevel;
                rtf.replace( index + 1, index + 1, '  ' );
                rtf.insertSprite( vipImg ,index + 1 );
            }
        }

    }


    private function get _domain():CChatMessageList{
        return system.getBean( CChatMessageList ) as CChatMessageList;
    }
    private function get _playerData() : CPlayerData {
        return ( _playerSystem.getBean( CPlayerManager ) as CPlayerManager ).playerData;
    }
    private function get _playerSystem() : CPlayerSystem {
        return system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }
    private function get _pChatMenuHandler():CChatMenuHandler{
        return system.getBean( CChatMenuHandler ) as CChatMenuHandler;
    }

}
}
