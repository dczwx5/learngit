//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.chat {

import QFLib.Utils.HtmlUtil;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TextEvent;
import flash.external.ExternalInterface;
import flash.filters.GlowFilter;
import flash.geom.Rectangle;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

import kof.SYSTEM_ID;
import kof.data.CDatabaseSystem;
import kof.framework.CAppStage;
import kof.framework.CViewHandler;
import kof.game.KOFSysTags;
import kof.game.Tutorial.CTutorSystem;
import kof.game.bag.CBagManager;
import kof.game.bag.CBagSystem;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.CSystemBundleContext;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.character.handler.CPlayHandler;
import kof.game.chat.data.CChatChannel;
import kof.game.chat.data.CChatConst;
import kof.game.chat.data.CChatData;
import kof.game.chat.data.CChatLinkConst;
import kof.game.chat.data.CChatType;
import kof.game.chat.face.CFace1;
import kof.game.chat.face.CFace10;
import kof.game.chat.face.CFace11;
import kof.game.chat.face.CFace12;
import kof.game.chat.face.CFace13;
import kof.game.chat.face.CFace14;
import kof.game.chat.face.CFace15;
import kof.game.chat.face.CFace16;
import kof.game.chat.face.CFace17;
import kof.game.chat.face.CFace18;
import kof.game.chat.face.CFace19;
import kof.game.chat.face.CFace2;
import kof.game.chat.face.CFace20;
import kof.game.chat.face.CFace21;
import kof.game.chat.face.CFace22;
import kof.game.chat.face.CFace23;
import kof.game.chat.face.CFace24;
import kof.game.chat.face.CFace25;
import kof.game.chat.face.CFace26;
import kof.game.chat.face.CFace27;
import kof.game.chat.face.CFace28;
import kof.game.chat.face.CFace29;
import kof.game.chat.face.CFace3;
import kof.game.chat.face.CFace30;
import kof.game.chat.face.CFace31;
import kof.game.chat.face.CFace32;
import kof.game.chat.face.CFace4;
import kof.game.chat.face.CFace5;
import kof.game.chat.face.CFace6;
import kof.game.chat.face.CFace7;
import kof.game.chat.face.CFace8;
import kof.game.chat.face.CFace9;
import kof.game.club.CClubEvent;
import kof.game.club.CClubHandler;
import kof.game.club.CClubSystem;
import kof.game.club.data.CClubConst;
import kof.game.club.data.CClubInfoData;
import kof.game.club.view.CClubInfoViewHandler;
import kof.game.core.CECSLoop;
import kof.game.item.CItemData;
import kof.game.item.CItemSystem;
import kof.game.item.view.tips.CItemTipsView;
import kof.game.lobby.CLobbySystem;
import kof.game.lobby.view.CLobbyViewHandler;
import kof.game.peakGame.CPeakGameSystem;
import kof.game.peakGame.data.CPeakGameData;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.message.Club.ClubInfoResponse;
import kof.table.FairPeakScoreLevel;
import kof.table.PeakScoreLevel;
import kof.ui.CUISystem;
import kof.ui.chat.CChatTxVipUI;
import kof.ui.chat.ChatHideUI;
import kof.ui.chat.ChatItemUI;
import kof.ui.chat.ChatSystemFaceUI;
import kof.ui.chat.ChatUI;
import kof.util.CQualityColor;

import morn.core.components.Box;
import morn.core.events.UIEvent;
import morn.core.handlers.Handler;

/**
 * Chat view handler.
 *
 * @author eddy
 */
public class CChatViewHandler extends CViewHandler {

    public var m_chatUI : ChatUI;

    private var m_chatHideUI : ChatHideUI;

    private var _appStage : CAppStage;

    private var _selectedChannel : int;

    private var m_bFocused : Boolean;

    private var _chatItemAry:Array;

    private static const MAX_ITEM_NUM : int = 50;

    private var _chatMsgDirty : Boolean;

    private var _panelCkFlg : Boolean;

    private var _chaFaceClassAry : Array;

    public function CChatViewHandler( ) {
        super( false );
    }

    override public function get viewClass() : Array {
        return [ ChatUI ,ChatHideUI,ChatSystemFaceUI];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;
        if ( !m_chatUI ) {
            m_chatUI = new ChatUI();
            _selectedChannel = CChatChannel.WORLD;

            m_chatUI.combox_channel.selectHandler = new Handler( channelSelectHandler );
            m_chatUI.tab_chat.selectHandler = new Handler( chatInfoSelectHandler );

            if( !m_chatHideUI ){
                m_chatHideUI = new ChatHideUI();
            }
            m_chatUI.btn_face.clickHandler = new Handler( faceHandler );
            m_chatUI.btn_hide.clickHandler = new Handler( onHideHandler ,[ m_chatUI,m_chatHideUI] );
            m_chatHideUI.btn.clickHandler = new Handler( onHideHandler ,[ m_chatHideUI,m_chatUI] );
            onHideHandler( m_chatHideUI,m_chatUI );

            m_chatUI.btnJoinQQGroup.clickHandler = new Handler( onJoinQQGroup );
            m_chatUI.clipQQGroup.num = system.stage.configuration.getNumber( "external.qqgroup", system.stage.configuration.getNumber( "qqgroup", 0 ) );

            _pChatInputViewHandler.initInputView( m_chatUI );
            _PChatHornViewHandler.initHornView( m_chatUI );


            var qqgroup:Number = system.stage.configuration.getNumber( "external.qqgroup", system.stage.configuration.getNumber( "qqgroup", 0 ) );
            if ( qqgroup == 0.0 ) {
                m_chatUI.gm_default.visible = false;
                m_chatUI.clipQQGroup.visible = false;
                m_chatUI.btnJoinQQGroup.visible = false;
            }

        }
        _chaFaceClassAry = [CFace1,CFace2,CFace3,CFace4,CFace5,CFace6,CFace7,CFace8,CFace9,
            CFace10,CFace11,CFace12,CFace13,CFace14,CFace15,CFace16,CFace17,CFace18,CFace19,
            CFace20,CFace21,CFace22,CFace23,CFace24,CFace25,CFace26,CFace27,CFace28,CFace29,
            CFace30,CFace31,CFace32];

        if( null == _chatItemAry )
            _chatItemAry = [];
        show();

        updateTabLabels();

        return Boolean( m_chatUI );
    }

    public function updateTabLabels():void{
        if( !m_chatUI )
                return;
        var bundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        var iStateValue : int = bundleCtx.getSystemBundleState( bundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.GUILD ) ) );
//        if( false ){
        if( iStateValue == CSystemBundleContext.STATE_STARTED ){
            m_chatUI.tab_chat.labels = '综合,世界,俱乐部,私聊,获得,系统';
        }else{
            m_chatUI.tab_chat.labels = '综合,世界,私聊,获得,系统';
        }
    }

    /**
     * Validate the data.
     */
    override protected function updateData() : void {
        super.updateData();

        // channel's message list changed.

        if ( _domain ) {
            // TODO: update domain data to view.
            LOG.logTraceMsg( "Updated chat view ..." );

            //todo
            _onUpdateChatItem();
        }
    }

    public function show() : void {
        if ( !parentCtn ) {
            callLater( show );
            return;
        }
        _addEventListeners();
        parentCtn.addChild(m_chatUI);

        m_chatUI.tab_chat.selectedIndex = 0;
        m_chatUI.tab_chat.callLater( chatInfoSelectHandler, [0] );

        onGmChannelHandler();
        _panelCkFlg = false;
        schedule( 2,_onUpdateChatView );//每2秒更新一次

    }
    ////////////////////更新聊天内容///////////////

    private function _onUpdateChatView( delta : Number ):void{
        if ( _chatMsgDirty ) {
            _chatMsgDirty = false;
            clearChatItem();
            updateChatData( !_panelCkFlg );
        }
    }
    //////////////////更新整个显示数据//////////////
    private var _itemY:Number;
    private function updateChatData( scrollToBottom : Boolean = false ):void{
        // TODO: 当前是否在最大滚动量
        _itemY = 0;
        var dataAry : Array = _domain.getList( _selectedChannel );
        var chatItemUI : ChatItemUI;
        var chatData:CChatData;
        for each( chatData in dataAry){
            chatItemUI =  updateChatItem( chatData );
            m_chatUI.panel_list.addElement(chatItemUI,20,_itemY);
            _itemY += chatItemUI.height + 5;
        }
        if( scrollToBottom )
        // TODO: 如果在最大滚动量条件下才设置往下滚动
            m_chatUI.panel_list.callLater( resetListScroll );
    }
    //////////////////增加一个聊天内容//////////////
//    private function addChatData( chatData : CChatData ):void{
//        if( m_chatUI.tab_chat.selectedIndex != chatData.channel )
//            return;
//        var chatItemUI : CRichTextField =  createChatItem( chatData );
//        m_chatUI.panel_list.addElement(chatItemUI,18,_itemY);
//        _itemY += chatItemUI.height ;
//        m_chatUI.panel_list.scrollTo( 0,_itemY );
//    }

    /////////////////////清除全部聊天item//////////////

    private function clearChatItem():void{
        var chatItemUI : ChatItemUI;
        for each( chatItemUI in _chatItemAry ){
            chatItemUI.remove();
        }
        _chatItemAry = [];
    }

    //////////////////更新聊天item////////////////////

    private function updateChatItem( chatData:CChatData ) : ChatItemUI {

        var chatItemUI : ChatItemUI;
        var rtf : CRichTextField;
        var tf : TextFormat;
        var index : int;
        if ( _chatItemAry.length >= MAX_ITEM_NUM ) {
            chatItemUI = _chatItemAry.shift();
            _chatItemAry.push( chatItemUI );
        } else {
            chatItemUI = new ChatItemUI();
            rtf = new CRichTextField();
            rtf.filters = [new GlowFilter(0, 1, 1.2, 1.2, 10)];
            rtf.textfield.autoSize = TextFieldAutoSize.LEFT;
            rtf.textfield.multiline = true;
            rtf.textfield.wordWrap = true;
            rtf.textfield.condenseWhite = true;
            rtf.textfield.selectable = false;
            rtf.html = true;
            rtf.lineHeight = 24;//24
            rtf.faceRect = new Rectangle(0,0,18,18);//24
            rtf.addEventListener( TextEvent.LINK , _onTextLinkHandler,false, 0, true  );
            rtf.addEventListener( MouseEvent.MOUSE_MOVE,  _onTextRollHandler );
            rtf.addEventListener( MouseEvent.MOUSE_OVER,  _onTextRollHandler );
            rtf.addEventListener( MouseEvent.MOUSE_OUT,  _onTextRollHandler );
            rtf.addEventListener( MouseEvent.ROLL_OVER,  _onTextRollHandler );
            tf = new TextFormat('宋体',13);
            rtf.defaultTextFormat = tf;
            rtf.setSize( m_chatUI.panel_list.width - 58 ,rtf.textfield.textHeight + 10 );
            rtf.name = 'rtf';
            chatItemUI.addElement( rtf, 35, 0 );
            _chatItemAry.push( chatItemUI );
//            rtf.opaqueBackground = '0x93ff85';
//            chatItemUI.opaqueBackground = '0xffe778';
        }
        chatItemUI.dataSource = chatData;
        rtf = chatItemUI.getChildByName( 'rtf' ) as CRichTextField;
        tf = rtf.defaultTextFormat;
        rtf.clear();
        //顺序乱
        if( chatData.channel == CChatChannel.HORN ){
            chatItemUI.clip_channel.index = 4;
            tf.color = CChatConst.CHANNEL_TXT_COLOR[4];
        }else if( chatData.channel == CChatChannel.GETITEM ){
            chatItemUI.clip_channel.index = 5;
            tf.color = CChatConst.CHANNEL_TXT_COLOR[5];
        }else{
            chatItemUI.clip_channel.index = chatData.channel - 1;
            tf.color = CChatConst.CHANNEL_TXT_COLOR[ chatData.channel - 1 ];
        }


        chatData.channel == CChatChannel.GUILD ? rtf.x = 45 : rtf.x = 35;

        if( chatData.type == CChatType.ONLY_STR ){
            rtf.append( chatData.message );
        }else{
            var senderName : String = '';
            var totalStr : String = '';
            if( chatData.channel == CChatChannel.PERSONAL ){
                if( _playerData.ID == chatData.senderID ){
                    senderName = '你对' + HtmlUtil.hrefAndU( chatData.receiverName , CChatLinkConst.SEND_NAME , String(tf.color)) + '说';
                }else{
                    senderName = HtmlUtil.hrefAndU( chatData.senderName , CChatLinkConst.SEND_NAME , String(tf.color)) + '对你说';
                }
            }else{
                if( _playerData.ID == chatData.senderID ){
                    senderName = chatData.senderName;
                }else{
                    senderName = HtmlUtil.hrefAndU( chatData.senderName , CChatLinkConst.SEND_NAME , String(tf.color));
                }
            }
            var peakMsg:String = "";
            if (chatData.peakScore > 0) {
                var peakSystem:CPeakGameSystem = system.stage.getSystem(CPeakGameSystem) as CPeakGameSystem;
                if (peakSystem) {

                    var findScoreLevelRecord:PeakScoreLevel = CPeakGameData.findScoreLevelRecordByScore(peakSystem.peakGameData.peakLevelTable.toVector(), chatData.peakScore);
                    peakMsg = "<font color='#" + (findScoreLevelRecord).color + "'>【" + findScoreLevelRecord.levelName + "】</font>"
                }

            }
            var titleMsg : String = '[' + chatData.location + ']' + senderName + peakMsg + " : ";
            totalStr += titleMsg;
//        rtf.append("", [{r: new CFace1(), i: 0}]);
//        totalStr += '{r: kof.game.chat.face::CFace11 , i: 0}'
            if ( chatData.type == CChatType.ITEM_SHOW ) {
                //特殊；物品展示
                var pItemData : CItemData  = _pItemSystem.getItem( int( chatData.message ) );
                var itemName : String = HtmlUtil.hrefAndU( pItemData.name , CChatLinkConst.ITEM_NAME ,CQualityColor.getColorByQuality( pItemData.quality -1 ));
                totalStr += '我的' + itemName;
                rtf.append( totalStr );
            } else if( chatData.type == CChatType.CLUB_INVITATION ){
                var clubInfoAry : Array = chatData.message.split(':');
                chatData.clubID  = String( clubInfoAry[0]);
                var clubName : String = HtmlUtil.hrefAndU( clubInfoAry[1] , CChatLinkConst.CLUB_INVITATION ,"#6ddc23" );
                totalStr += clubName + '俱乐部正在邀请会员加入，快去申请加入吧';
                rtf.append( totalStr );
                //特殊；公会邀请
            } else if( chatData.type == CChatType.CLUB_BAG_INVITATION ){
                var clubBagInfoAry : Array = chatData.message.split(':');
                var sendName : String = String( clubBagInfoAry[0]);
                var bagName : String = String( clubBagInfoAry[1]);
                var getStr : String = HtmlUtil.hrefAndU( '抢福袋' , CChatLinkConst.CLUB_BAG ,"#ff8282" );
                totalStr += sendName + '在俱乐部发放' + bagName + '，快来' + getStr + '吧！';
                rtf.append( totalStr );
                //特殊；公会福袋
            }else if( chatData.type == CChatType.CLUB_RECHARGE_BAG_INVITATION){
                rtf.append( totalStr += chatData.message );
            } else {
                var xml : XML;
//            totalStr += chatData.message;
                if ( true ) //todo 解析的时候，从 ht+t ，里面i的位置开始插入表情
                {
                    xml = XML( chatData.message );
                    xml.ht = totalStr;
                }
                else {
                    xml = <a/>;
                    xml.t = totalStr;
//                xml.t = chatData.message;
                }

                rtf.importXML( xml ,false,HtmlUtil.removeHtml(totalStr,false).length);
            }

            //for test
//            var obj : Object = {};
//            obj.type = 1;
//            obj.subType = 4;
//            vipInfo( rtf , chatData.location.length + 1 , chatData.vipLevel , obj  );

            vipInfo( rtf , chatData.location.length + 1 , chatData.vipLevel , _domain.getTxVipInfo( chatData )  );

        }

        rtf.setSize( m_chatUI.panel_list.width - 58 ,rtf.textfield.textHeight + 10 );
        chatItemUI.height = rtf.height;

        return chatItemUI;
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

    ////////////////点击文本链接//////////////

    private var _clubBagViewType : int ;

    private function _onTextLinkHandler( evt : TextEvent ):void{
        evt.stopImmediatePropagation();
        var chatItemUI : ChatItemUI = evt.currentTarget.parent as ChatItemUI;
        var chatData : CChatData = chatItemUI.dataSource as CChatData;
        var text : String = evt.text;
        if( text == CChatLinkConst.SEND_NAME ){
            _pChatMenuHandler.show( chatItemUI );
        }else if( text == CChatLinkConst.ITEM_NAME ){
//            chatItemUI.dispatchEvent( new UIEvent( UIEvent.SHOW_TIP ,chatItemUI.toolTip,true));
            var pItemData : CItemData  = _pItemSystem.getItem( int( chatData.message ) );
            (system.stage.getSystem(CItemSystem) as CItemSystem).showItemInfo(pItemData);
        }else if( text == CChatLinkConst.CLUB_INVITATION ){
            _clubSystem.addEventListener( CClubEvent.CLUB_INFO_RESPONSE ,_onClubInfoResponseHandler );
            _clubHandler.onClubInfoRequest( chatData.clubID , 3 );
        }else if( text == CChatLinkConst.CLUB_BAG ) {
            _clubBagViewType = CClubConst.CLUB_BAG_GET;
            _clubSystem.addEventListener( CClubEvent.CLUB_WORLD_VIEW_SHOW ,_onClubViewOnshowHandler );
            _clubHandler.onOpenClubRequest( false );
        }else if( text == CChatLinkConst.MARQUEE_TARGET ){
            if( chatData.marqueeInfo.linkTarget == CChatLinkConst.CLUB_BAG ){
                if( chatData.marqueeInfo.ID == 1105 || chatData.marqueeInfo.ID == 1106 )
                    _clubBagViewType = CClubConst.BAG_BASE_INFO;
                else
                    _clubBagViewType = CClubConst.CLUB_BAG_GET ;
                _clubSystem.addEventListener( CClubEvent.CLUB_WORLD_VIEW_SHOW ,_onClubViewOnshowHandler );
                _clubHandler.onOpenClubRequest( false );
            }else{
                var bundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
                var bundle : ISystemBundle =  bundleCtx.getSystemBundle( SYSTEM_ID(chatData.marqueeInfo.linkTarget));
                if( bundle ) {
                    bundleCtx.setUserData( bundle, CBundleSystem.MARQUEE_DATA, chatData.responseData );//公告中携带的数据
                    bundleCtx.setUserData( bundle, CBundleSystem.ACTIVATED, true );
                }
                else{
                    _pCUISystem.showMsgAlert('很抱歉，活动已过期或者您已经参与过了');
                }
            }
        }else if( text.indexOf( CChatLinkConst.MARQUEE_ROLE_TARGET ) != -1 ){
            chatData.marqueeRoleID = int( chatData.responseData[text] );
            chatData.marqueeRoleName = String( chatData.responseData['marqueeRoleName'] );
            _pChatMenuHandler.show( chatItemUI );
        }
    }
    private function _onClubInfoResponseHandler( evt : CClubEvent = null ):void{
        _clubSystem.removeEventListener( CClubEvent.CLUB_INFO_RESPONSE ,_onClubInfoResponseHandler );
        var response : ClubInfoResponse = evt.data as ClubInfoResponse;
        var clubInfoData : CClubInfoData = new CClubInfoData(system);
        clubInfoData.updateDataByData( response.clubInfoMap );
        _clubInfoViewHandler.addDisplay( clubInfoData );
    }
    private function _onClubViewOnshowHandler( evt : CClubEvent = null ):void{
        _clubSystem.removeEventListener( CClubEvent.CLUB_WORLD_VIEW_SHOW ,_onClubViewOnshowHandler );
        _clubSystem.showClubSubView( CClubConst.WELFARE_BAG , _clubBagViewType );
    }
    //////////////////鼠标滑过 文本tips/////////////////////
    private function _onTextRollHandler( evt : MouseEvent ):void{
        var tf : CRichTextField = evt.currentTarget as CRichTextField;
        var chatItemUI : ChatItemUI = tf.parent as ChatItemUI;
        if( evt.type == MouseEvent.MOUSE_OVER || evt.type == MouseEvent.MOUSE_MOVE || evt.type == MouseEvent.ROLL_OVER ){
            var turl : String = tf.textfield.getTextFormat( tf.textfield.getCharIndexAtPoint( tf.textfield.mouseX, tf.textfield.mouseY ) ).url;
            if(turl){
                var chatData : CChatData = chatItemUI.dataSource as CChatData;
                if( chatData ){
                    var ary : Array = turl.split(':');
                    if( ary[1] == CChatLinkConst.SEND_NAME ){
//                        App.tip.closeAll();
                    }else if( ary[1] == CChatLinkConst.ITEM_NAME ){
//                        if( !chatItemUI.toolTip)
//                        {
//                            chatItemUI.toolTip = new Handler( showTips, [chatItemUI] );
//                            chatItemUI.dispatchEvent( new UIEvent( UIEvent.SHOW_TIP ,chatItemUI.toolTip,true));
//                        }
                    }
                }
            }else {
//                App.tip.closeAll();
            }

        }else if( evt.type == MouseEvent.MOUSE_OUT ) {
//            App.tip.closeAll();
        }
    }

    private function showTips( item : ChatItemUI ):void {
        var chatData : CChatData = item.dataSource as CChatData;
//        var pItemData : CItemData  = _pItemSystem.getItem( int( chatData.message ) );
        (system.stage.getSystem(CItemSystem) as CItemSystem).addTips(CItemTipsView,null,[int( chatData.message )]);
    }


    ////////////////////GM频道 建议另外一个viewHandler///////////////

    private function onGmChannelHandler():void{
        //todo
        var qqgroup:Number = system.stage.configuration.getNumber( "external.qqgroup", system.stage.configuration.getNumber( "qqgroup", 0 ) );
        if ( qqgroup == 0.0 ) {
            m_chatUI.gm_default.visible = false;
        }else{
            m_chatUI.gm_default.visible = true;
        }
        m_chatUI.box_gm.visible = false;
    }

    ///////////////////////打开表情面板///////////////////////////////

    private function faceHandler() : void {
        var pChatFaceViewHandler : CChatFaceViewHandler = system.getBean( CChatFaceViewHandler ) as CChatFaceViewHandler;
        pChatFaceViewHandler.addDisplay( this, m_chatUI.btn_face, 100, -300 );

    }

    //////////////////////////发言频道选择////////////////////
    private function channelSelectHandler( index : int ):void{

        if( _channelCombox != CChatChannel.HORN && _channelCombox != _channelTab ){//喇叭频道不用
            var tempIndex : int = CChatChannel.getIndexByLabel( m_chatUI.tab_chat.labels ,CChatChannel.getLabelByIndex( m_chatUI.combox_channel.labels,index ));
            if( tempIndex != -1){
                m_chatUI.tab_chat.selectedIndex = tempIndex;
                m_chatUI.tab_chat.callLater( chatInfoSelectHandler,[ tempIndex ]);
            }
        }
        _pChatInputViewHandler.txtInput.clear();
        if( _channelCombox == CChatChannel.PERSONAL  ){
            _pChatInputViewHandler.txtInput.text = CChatConst.defaul_priavte_input;
        }else{
            _pChatInputViewHandler.txtInput.text = CChatConst.defaul_input;
        }
    }

    ///////////////////////查看聊天内容频道选择///////////////////////////////

    private function chatInfoSelectHandler( index : int ):void{
        _selectedChannel = _channelTab;
//        m_chatUI.panel_list.vScrollBar.height = 0;

        _onUpdateChatItem( );
        if( _channelTab != CChatChannel.ALL &&
                _channelTab != CChatChannel.SYSTEM &&
                _channelTab != CChatChannel.GETITEM &&
                _channelTab != _channelCombox ){

            var tempIndex : int = CChatChannel.getIndexByLabel( m_chatUI.combox_channel.labels ,CChatChannel.getLabelByIndex( m_chatUI.tab_chat.labels,index ));
            if( tempIndex != -1){
                m_chatUI.combox_channel.selectedIndex = tempIndex;
                m_chatUI.combox_channel.callLater( channelSelectHandler,[ tempIndex ]);
            }

        }
    }

    ///////////////////////新消息反应///////////////////////////////

    private function _onChatResponse( evt : CChatEvent ):void{
//         addChatData( evt.data as CChatData);//不是每来一条就立刻做处理
        _chatMsgDirty = true;

    }
    private function _onUpdateChatItem( ):void{
        clearChatItem();
        updateChatData( true );
    }

    ///////////////////////是否点中聊天面板//////////////////////////////

    private function _onPanelClickHandler( evt : MouseEvent ):void{
        if( evt.type == MouseEvent.MOUSE_DOWN ){
            _panelCkFlg = true;
            if( _appStage )
                _appStage.flashStage.addEventListener( MouseEvent.MOUSE_UP,_onPanelClickHandler );
        }else if( evt.type == MouseEvent.MOUSE_UP ){
            _panelCkFlg = false;
            if( _appStage )
                _appStage.flashStage.removeEventListener( MouseEvent.MOUSE_UP,_onPanelClickHandler );
        }
    }
    ////////////私聊 tab变换///////////////////////////////
    public function onPrivateChat():void{

        var tempIndex : int = CChatChannel.getIndexByLabel( m_chatUI.combox_channel.labels ,'私聊');
        if( tempIndex != -1){
            m_chatUI.combox_channel.selectedIndex = tempIndex;
            m_chatUI.combox_channel.callLater( channelSelectHandler,[ tempIndex ]);
        }
    }
    ///////////////////拖动///////////////////////

    private function _onMouseDown( evt :MouseEvent ):void{
        _pChatMenuHandler._onMenuCloseHandler();
        _appStage.flashStage.addEventListener( MouseEvent.MOUSE_UP,_onMouseUp );
        _appStage.flashStage.addEventListener( MouseEvent.MOUSE_MOVE,_onMouseMove );
    }
    private function _onMouseUp( evt :MouseEvent ):void{
        _appStage.flashStage.removeEventListener( MouseEvent.MOUSE_UP,_onMouseUp );
        _appStage.flashStage.removeEventListener( MouseEvent.MOUSE_MOVE,_onMouseMove );
        callLater( resetAllItemWH );
        callLater( resetAllItemXY );
    }
    private function _onMouseMove( evt :MouseEvent ):void{

        if( parentCtn.mouseX >= 328 && parentCtn.mouseX <= 650 ){
            m_chatUI.width = parentCtn.mouseX;
        }
        if( parentCtn.mouseY <= 88 && parentCtn.mouseY >= -140 ){
            m_chatUI.height =  88 - parentCtn.mouseY + 312  ;
            m_chatUI.y =  parentCtn.mouseY - 88 - 14;
        }
    }

    private function _onResizeHandler( evt: UIEvent = null ):void{
        _pChatInputViewHandler.txtInput.x = m_chatUI.txt_input.x;
        _pChatInputViewHandler.txtInput.y = m_chatUI.txt_input.y;
        _pChatInputViewHandler.setTxtInputWidth( m_chatUI.panel_list.width - 130 );

        callLater( resetAllItemWH );
        callLater( resetAllItemXY );

    }
    private function resetAllItemWH( ):void{
        var chatItemUI : ChatItemUI;
        var rtf :CRichTextField;
        for each( chatItemUI in _chatItemAry ){
            rtf = chatItemUI.getChildByName( 'rtf' ) as CRichTextField;
            rtf.setSize( m_chatUI.panel_list.width - 58 ,rtf.textfield.textHeight + 10 );
            chatItemUI.setSize( m_chatUI.panel_list.width - 25 ,rtf.textfield.textHeight + 15);
            chatItemUI.height = rtf.textfield.textHeight + 15;
//            trace(rtf.textfield.textHeight,'----------rtf.textfield.textHeight')
        }

        _PChatHornViewHandler.resetAllItemWH();

    }
    private function resetAllItemXY():void{
        _itemY = 0;
        var chatItemUI : ChatItemUI;
        for each( chatItemUI in _chatItemAry ){
            chatItemUI.y = _itemY;
            _itemY += chatItemUI.height + 5;
        }
        callLater( resetListScroll );


        _PChatHornViewHandler.resetAllItemXY();
    }

    private function resetListScroll():void{
        m_chatUI.panel_list.scrollTo( 0,_itemY );
    }

    //////////////////////////////////////////


    private function _addEventListeners() : void {
        _removeEventListeners();
        system.addEventListener( CChatEvent.CHAT_RESPONSE ,_onChatResponse, false, 0, true);
        m_chatUI.panel_list.addEventListener( MouseEvent.MOUSE_DOWN, _onPanelClickHandler, false, 0, true );
        m_chatUI.panel_list.vScrollBar.addEventListener( MouseEvent.MOUSE_UP, _onPanelClickHandler, false, 0, true );
        m_chatUI.btn_drag.addEventListener( MouseEvent.MOUSE_DOWN ,_onMouseDown , false , 0, true );
        m_chatUI.addEventListener( Event.RESIZE, _onResizeHandler , false , 0, true );
    }
    private function _removeEventListeners() : void {
        if ( m_chatUI ) {
            system.removeEventListener( CChatEvent.CHAT_RESPONSE,_onChatResponse );
            m_chatUI.panel_list.removeEventListener( MouseEvent.MOUSE_DOWN, _onPanelClickHandler );
            if( _appStage )
                _appStage.flashStage.addEventListener( MouseEvent.MOUSE_UP,_onPanelClickHandler );
            m_chatUI.btn_drag.removeEventListener( MouseEvent.MOUSE_DOWN ,_onMouseDown );
            m_chatUI.removeEventListener( Event.RESIZE, _onResizeHandler );
        }
    }


    private function get parentCtn():Box{
        var pLobbySystem:CLobbySystem = system.stage.getSystem( CLobbySystem ) as CLobbySystem;
        var pLobbyViewHandler:CLobbyViewHandler = pLobbySystem.getBean(CLobbyViewHandler) as CLobbyViewHandler;
        if ( !pLobbyViewHandler.pMainUI )
            return null;

        var left_bottom:Box = pLobbyViewHandler.pMainUI.getChildByName("left_bottom") as Box;
        return left_bottom;
    }

    override protected function enterStage( appStage : CAppStage ) : void {
        super.enterStage( appStage );
        _appStage = appStage;
    }

    final public function get focused() : Boolean {
        return m_bFocused;
    }

    final public function set focused( value : Boolean ) : void {
        m_bFocused = value;
    }

    private function onJoinQQGroup() : void {
        try {
            ExternalInterface.call( "joinQQGroup" );
        } catch ( e : Error ) {
            LOG.logErrorMsg( "External call 'joinQQGroup' failed: " + e.message );
        }
    }

    private function onHideHandler( ...args):void{
        if((args[0] as DisplayObject).parent)
            (args[0] as DisplayObject).parent.removeChild(args[0]);

        if ( parentCtn )
            parentCtn.addChild(args[1]);
    }

    public function hide( removed : Boolean = true ) : void {
        if ( m_chatUI ) {
            if ( removed )
                m_chatUI.remove();
            else
                m_chatUI.alpha = 0;
        }
        _removeEventListeners();
        unschedule( _onUpdateChatView );
    }

    private function get _channelTab():int{
        return CChatChannel.getChannelByLabel( m_chatUI.tab_chat.labels,m_chatUI.tab_chat.selectedIndex);
    }
    private function get _channelCombox():int{
        return CChatChannel.getChannelByLabel( m_chatUI.combox_channel.labels,m_chatUI.combox_channel.selectedIndex);
    }

    private function get _domain():CChatMessageList{
        return system.getBean( CChatMessageList ) as CChatMessageList;
    }
    private function get _pCUISystem():CUISystem{
        return system.stage.getSystem( CUISystem ) as CUISystem;
    }
    private function get _pCDatabaseSystem():CDatabaseSystem{
        return system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }
    private function get _pBagSystem():CBagSystem{
        return system.stage.getSystem( CBagSystem ) as CBagSystem;
    }
    private function get _pBagManager():CBagManager{
        return _pBagSystem.getBean( CBagManager ) as CBagManager;
    }
    private function get _pChatInputViewHandler():CChatInputViewHandler{
        return system.getBean( CChatInputViewHandler ) as CChatInputViewHandler;
    }
    private function get _PChatHornViewHandler():CChatHornViewHandler{
        return system.getBean( CChatHornViewHandler ) as CChatHornViewHandler;
    }
    private function get _pChatMenuHandler():CChatMenuHandler{
        return system.getBean( CChatMenuHandler ) as CChatMenuHandler;
    }
    private function get _pItemSystem():CItemSystem{
        return system.stage.getSystem( CItemSystem ) as CItemSystem;
    }
    private function get _playerData() : CPlayerData {
        return ( _playerSystem.getBean( CPlayerManager ) as CPlayerManager ).playerData;
    }
    private function get _playerSystem() : CPlayerSystem {
        return system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }
    private function get _clubInfoViewHandler() : CClubInfoViewHandler {
        return _clubSystem.getBean( CClubInfoViewHandler ) as CClubInfoViewHandler;
    }
    private function get _clubHandler() : CClubHandler {
        return _clubSystem.getBean( CClubHandler ) as CClubHandler;
    }
    private function get _clubSystem() : CClubSystem {
        return system.stage.getSystem( CClubSystem ) as CClubSystem;
    }
    private function get _pCTutorSystem() : CTutorSystem {
        return system.stage.getSystem( CTutorSystem ) as CTutorSystem;
    }
    private function get _playHandler() : CPlayHandler {
        return (system.stage.getSystem(CECSLoop).getBean(CPlayHandler)) as CPlayHandler;
    }
}
}
