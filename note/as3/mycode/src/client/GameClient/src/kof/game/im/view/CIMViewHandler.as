//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/5/2.
 */
package kof.game.im.view {

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.game.KOFSysTags;
import kof.game.common.view.CTweenViewHandler;
import kof.game.im.CIMEvent;
import kof.game.im.CIMHandler;
import kof.game.im.CIMManager;
import kof.game.im.data.CIMConst;
import kof.game.im.data.CIMFriendsData;
import kof.game.im.data.CIMRecommendData;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerData;
import kof.game.player.event.CPlayerEvent;
import kof.table.FriendConfig;
import kof.ui.CMsgAlertHandler;
import kof.ui.CUISystem;
import kof.ui.master.im.IMItemUI;
import kof.ui.master.im.IMUI;

import morn.core.components.Button;
import morn.core.components.Component;
import morn.core.components.Dialog;
import morn.core.handlers.Handler;

public class CIMViewHandler extends CTweenViewHandler {

    private var m_IMUI:IMUI;

    private var m_pCloseHandler : Handler;

    private var m_bViewInitialized : Boolean;

    private var _appHandlerAry : Array;
    private var _groupAry : Array;

    private var _tab : int ;

    public function CIMViewHandler() {
        super( false );
    }
    override public function dispose() : void {
        super.dispose();

        removeDisplay();
        m_IMUI = null;
    }
    override public function get viewClass() : Array {
        return [ IMUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }
    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !m_bViewInitialized ) {
            if( !_appHandlerAry ){
                _appHandlerAry = [];
                _appHandlerAry.push( _onFriendInfoListRequest, _onApplyFriendListRequest, _onFriendRecommendListRequest );
            }
            if( !_groupAry ){
                _groupAry = [];
                _groupAry.push( _onFriendInfoListResponse ,_onApplyFriendListResponse ,_onFriendRecommendListResponse );
            }
            if ( !m_IMUI ) {
                m_IMUI = new IMUI();

                m_IMUI.closeHandler = new Handler( _onClose );
                m_IMUI.btn_search.clickHandler = new Handler( _onUICkHandler ,[m_IMUI.btn_search]);
                m_IMUI.btn_haoyouGet.clickHandler = new Handler( _onUICkHandler,[m_IMUI.btn_haoyouGet] );
                m_IMUI.btn_haoyouSend.clickHandler = new Handler( _onUICkHandler,[m_IMUI.btn_haoyouSend] );
                m_IMUI.btn_shenqingYes.clickHandler = new Handler( _onUICkHandler,[m_IMUI.btn_shenqingYes] );
                m_IMUI.btn_shenqingNo.clickHandler = new Handler( _onUICkHandler,[m_IMUI.btn_shenqingNo] );
                m_IMUI.btn_refresh.clickHandler = new Handler( _onUICkHandler,[m_IMUI.btn_refresh] );
                m_IMUI.btn_tuijianAll.clickHandler = new Handler( _onUICkHandler,[m_IMUI.btn_tuijianAll] );

                m_IMUI.list.renderHandler = new Handler( renderItem );
                m_IMUI.list.selectHandler = new Handler( selectItemHandler );
                m_IMUI.list.mouseHandler = new Handler( listMouseHandler );

                m_IMUI.list.dataSource = [];

                m_IMUI.btnGronp.selectHandler = new Handler( _onBtnGronpSelectHandler );

                m_bViewInitialized = true;
            }
        }

        return m_bViewInitialized;
    }

    private function _onUpdateInfoHandler():void{
       if( !m_IMUI )
               return;
        m_IMUI.txt_name.text = _playerData.teamData.name;
//        m_IMUI.clip_sex.index = 0;//todo 性别
        m_IMUI.txt_guild.text = '';
        var pMaskDisplayObject : DisplayObject = m_IMUI.maskimg;
        if ( pMaskDisplayObject ) {
            m_IMUI.img_head.cacheAsBitmap = true;
            pMaskDisplayObject.cacheAsBitmap = true;
            m_IMUI.img_head.mask = pMaskDisplayObject;
        }
        m_IMUI.img_head.url = CPlayerPath.getUIHeroIconBigPath(_playerData.teamData.useHeadID);
        if( _playerData.guideData.clubName.length > 0  )
            m_IMUI.txt_guild.text = '所属俱乐部: ' + _playerData.guideData.clubName ;
        else
            m_IMUI.txt_guild.text = '所属俱乐部: 暂无';
    }
    private function _onBtnGronpSelectHandler( i:int ):void{
        var j : int;
        for( j = CIMConst.FRIENDS ; j <= CIMConst.RECOMMEND ; j++ ){
            m_IMUI['box_' + j ].visible = ( j == i );
        }
        m_IMUI.txt_tips.text = '';
        _groupAry[i].apply();//先显示，以防因为时间间隔不够的原因，后台没有返回协议
        _appHandlerAry[i].apply();
    }

    private function renderItem(item:Component, idx:int):void {
        if (!(item is IMItemUI)) {
            return;
        }
        var pIMItemUI:IMItemUI = item as IMItemUI;
        if( pIMItemUI.dataSource ){
            pIMItemUI.img_head.url = CPlayerPath.getUIHeroIconBigPath(pIMItemUI.dataSource.headID);
//            pIMItemUI.txt_name.text = pIMItemUI.dataSource.name;
            pIMItemUI.txt_power.text = pIMItemUI.dataSource.battleValue;
            pIMItemUI.txt_lv.text = 'Lv.' + pIMItemUI.dataSource.level;

            var pMaskDisplayObject : DisplayObject = pIMItemUI.maskimg;
            if ( pMaskDisplayObject ) {
                pIMItemUI.img_head.cacheAsBitmap = true;
                pMaskDisplayObject.cacheAsBitmap = true;
                pIMItemUI.img_head.mask = pMaskDisplayObject;
            }
            for( var i : int = CIMConst.FRIENDS ; i <= CIMConst.RECOMMEND ; i++ ){
                pIMItemUI['box_' + i ].visible = m_IMUI.btnGronp.selectedIndex == i;
            }
            if( m_IMUI.btnGronp.selectedIndex == CIMConst.FRIENDS ){
                pIMItemUI.btn_get.visible = pIMItemUI.dataSource.isGet == CIMConst.CAN_GET_STRENG;
                pIMItemUI.dataSource.isSend == CIMConst.NOT_SEND_STRENG ? pIMItemUI.btn_send.label = '赠送': pIMItemUI.btn_send.label = '已送';
                pIMItemUI.btn_send.disabled = pIMItemUI.dataSource.isSend != 0;
                _pIMItemUIDisable( pIMItemUI , pIMItemUI.dataSource.isOnline == CIMConst.OFFLINE );
            }else if( m_IMUI.btnGronp.selectedIndex == CIMConst.APPLY ){
                _pIMItemUIDisable( pIMItemUI , pIMItemUI.dataSource.isOnline == CIMConst.OFFLINE );
            }else if( m_IMUI.btnGronp.selectedIndex == CIMConst.RECOMMEND ){
                pIMItemUI.dataSource.isHaveAgree == CIMConst.NOT_SEND_APPLY ? pIMItemUI.btn_handler.label = '申请': pIMItemUI.btn_handler.label = '已申请';
                pIMItemUI.btn_handler.disabled = pIMItemUI.dataSource.isHaveAgree == CIMConst.HASED_SEND_APPLY;
                _pIMItemUIDisable( pIMItemUI , false );
            }

            pIMItemUI.btn_get.clickHandler = new Handler( _onItemBtnCkHandler,[pIMItemUI,pIMItemUI.btn_get]);
            pIMItemUI.btn_send.clickHandler = new Handler( _onItemBtnCkHandler,[pIMItemUI,pIMItemUI.btn_send]);
            pIMItemUI.btn_yes.clickHandler = new Handler( _onItemBtnCkHandler,[pIMItemUI,pIMItemUI.btn_yes]);
            pIMItemUI.btn_no.clickHandler = new Handler( _onItemBtnCkHandler,[pIMItemUI,pIMItemUI.btn_no]);
            pIMItemUI.btn_handler.clickHandler = new Handler( _onItemBtnCkHandler,[pIMItemUI,pIMItemUI.btn_handler]);

            var dataSource:* = pIMItemUI.dataSource ;
            if( dataSource )
//                vipInfo( pIMItemUI ,pIMItemUI.dataSource.vipLevel , _imManager.getTxVipInfo( dataSource.platformData ));
               _playerSystem.platform.signatureRender.renderSignature(pIMItemUI.dataSource.vipLevel, pIMItemUI.dataSource.platformData, pIMItemUI.signature, pIMItemUI.dataSource.name);

        }
    }
    private function selectItemHandler( index : int ) : void {
        var pIMItemUI : IMItemUI = m_IMUI.list.getCell( index ) as IMItemUI;
        if ( !pIMItemUI )
            return;
    }
    private function listMouseHandler( evt:Event,idx : int ) : void {
        var pIMItemUI : IMItemUI = m_IMUI.list.getCell( idx ) as IMItemUI;
        if ( evt.type == MouseEvent.CLICK ) {
            if( evt.target is Button )
                    return;
            if( pIMItemUI.dataSource){
                _imMenuHandler.addDisplay( pIMItemUI );
            }
        }
    }
    private function _onUICkHandler(... args):void {
        var friendsAry : Array ;
        var pIMFriendsData : CIMFriendsData;
        var bool : Boolean;
        switch ( args[0] ) {
            case m_IMUI.btn_search://搜索
                ( system.getBean( CIMSearchViewHandler ) as CIMSearchViewHandler ).addDisplay();
                break;
            case m_IMUI.btn_haoyouGet:{//一键领取体力
                friendsAry = _imManager.getListDataByType( CIMConst.FRIENDS );
                for each ( pIMFriendsData in  friendsAry ){
                    if( pIMFriendsData.isGet == CIMConst.CAN_GET_STRENG ){
                        bool = true;
                        break;
                    }
                }
                if( bool)
                    _imHandler.onGetPhysicalStrengthRequest( 0,1 );
                else
                    _pCUISystem.showMsgAlert('没有可以领取的体力!' );

                break;
            }
            case m_IMUI.btn_haoyouSend:{//一键赠送体力
                friendsAry = _imManager.getListDataByType( CIMConst.FRIENDS );
                for each ( pIMFriendsData in  friendsAry ){
                    if( pIMFriendsData.isSend == CIMConst.NOT_SEND_STRENG ){
                        bool = true;
                        break;
                    }
                }
                if( bool)
                    _imHandler.onSendPhysicalStrengthRequest( 0,1 );
                else
                    _pCUISystem.showMsgAlert('暂无好友可以赠送礼物!' );

                break;
            }
            case m_IMUI.btn_shenqingYes://一键同意申请
                if( _imManager.getListDataByType( CIMConst.APPLY ).length <= 0 ){
                    _pCUISystem.showMsgAlert('申请列表为空!' );
                    return;
                }
                _imHandler.onDealApplicationRequest( 0,0,1 );
                break;
            case m_IMUI.btn_shenqingNo://一键拒绝申请
                if( _imManager.getListDataByType( CIMConst.APPLY ).length <= 0 ){
                    _pCUISystem.showMsgAlert('申请列表为空!' );
                    return;
                }
                _imHandler.onDealApplicationRequest( 0,1,1 );
                break;
            case m_IMUI.btn_refresh://一键刷新推荐
                _imHandler.onFriendRecommendListRequest();
                break;
            case m_IMUI.btn_tuijianAll://一键添加所有推荐
                var idAry : Array = [];
                var recommendAry : Array  = _imManager.getListDataByType( CIMConst.RECOMMEND );
                var pCIMRecommendData: CIMRecommendData;
                for each( pCIMRecommendData in recommendAry ){
                    if( pCIMRecommendData.isHaveAgree == CIMConst.NOT_SEND_APPLY ){
                        idAry.push( pCIMRecommendData.roleID );
                    }

                }
                if( idAry.length <= 0 ){
                    _pCUISystem.showMsgAlert('无玩家可申请!' , CMsgAlertHandler.WARNING );
                    return;
                }
                _imHandler.onAddFriendRequest( idAry,CIMConst.ALL );
                break;
        }
    }
    private function _onItemBtnCkHandler(... args):void{
        var pIMItemUI:IMItemUI = args[0] as IMItemUI;
        switch ( args[1] ){
            case pIMItemUI.btn_get://领取体力
                _imHandler.onGetPhysicalStrengthRequest( pIMItemUI.dataSource.roleID,0);
                break;
            case pIMItemUI.btn_send://赠送体力
                _imHandler.onSendPhysicalStrengthRequest( pIMItemUI.dataSource.roleID,0);
                break;
            case pIMItemUI.btn_yes://同意申请
                _imHandler.onDealApplicationRequest( pIMItemUI.dataSource.roleID,0,0);
                break;
            case pIMItemUI.btn_no://拒绝申请
                _imHandler.onDealApplicationRequest( pIMItemUI.dataSource.roleID,1,0);
                break;
            case pIMItemUI.btn_handler://申请加好友
                _imHandler.onAddFriendRequest( [pIMItemUI.dataSource.roleID],CIMConst.SINGLE );
                break;
        }
    }
    /**********************Request********************************/
    //好友请求
    private function _onFriendInfoListRequest():void{
        _imHandler.onFriendInfoListRequest();
    }
    //申请请求
    private function _onApplyFriendListRequest():void{
        _imHandler.onApplyFriendListRequest();
    }
    //推荐请求
    private function _onFriendRecommendListRequest():void{
        _imHandler.onFriendRecommendListRequest();
    }
    /**********************Response********************************/
    //好友返回
    private function _onFriendInfoListResponse( evt : CIMEvent = null):void{
        m_IMUI.img_tips0.visible = _imManager.new_streng_notice_b || _imManager.canGetStrengNum > 0 ;

        if(  m_IMUI.btnGronp.selectedIndex != CIMConst.FRIENDS )
            return;
        m_IMUI.list.dataSource = _imManager.getListDataByType( CIMConst.FRIENDS );
        m_IMUI.txt_tips.visible = m_IMUI.list.dataSource.length == 0;
        m_IMUI.txt_tips.text = CIMConst.NO_FRIENDS_TIPS;
        m_IMUI.img_tips0.visible = _imManager.canGetStrengNum > 0 ;
        m_IMUI.txt_buttom.text = '已领体力:' + _imManager.getPhysicalStrengthCount + '/' + _friendConfig.physicalUpperLimit + '次';
        m_IMUI.txt_mid.text = '我的好友:' + _imManager.getOnlineFriendsNum() + '/' + _imManager.getFriendsNum();
    }
    //申请返回
    private function _onApplyFriendListResponse( evt : CIMEvent = null):void{
       if(  m_IMUI.btnGronp.selectedIndex != CIMConst.APPLY )
               return;
        m_IMUI.list.dataSource = _imManager.getListDataByType( CIMConst.APPLY );
        m_IMUI.txt_tips.visible = m_IMUI.list.dataSource.length == 0;
        m_IMUI.txt_tips.text = CIMConst.NO_APPLY_TIPS;
        m_IMUI.img_tips1.visible = _imManager.applyNum > 0;

        m_IMUI.txt_buttom.text = '申请人: ' + m_IMUI.list.dataSource.length;
        m_IMUI.txt_mid.text = '';
    }
    //推荐返回
    private function _onFriendRecommendListResponse( evt : CIMEvent = null):void{
       if(  m_IMUI.btnGronp.selectedIndex != CIMConst.RECOMMEND )
               return;
        m_IMUI.list.dataSource = _imManager.getListDataByType( CIMConst.RECOMMEND );
        m_IMUI.txt_buttom.text = '好友上限: ' + (_imManager.getListDataByType( CIMConst.FRIENDS ) as Array).length + '/' + _friendConfig.friendCap;
        m_IMUI.txt_mid.text = '';
    }
    //新消息提示
    private function _onNewNoticeResponse( evt : CIMEvent = null):void{
       if( !m_IMUI )
           return;

        m_IMUI.img_tips0.visible = _imManager.new_streng_notice_b || _imManager.canGetStrengNum > 0 ;
        m_IMUI.img_tips1.visible = _imManager.new_apply_notice_b || _imManager.applyNum > 0;
        if( evt ){
            var type : int  = int( evt.data );
            if( m_IMUI.btnGronp.selectedIndex == CIMConst.FRIENDS && type == CIMConst.NEW_STRENG_NOTICE )
                _onFriendInfoListRequest();
            if( m_IMUI.btnGronp.selectedIndex == CIMConst.APPLY && type == CIMConst.NEW_APPLY_NOTICE )
                _onApplyFriendListRequest();
        }

    }
    private function _onSelfTxVipInfo():void{//修复
        m_IMUI.clip_blue.visible =
                m_IMUI.clip_superBlue.visible =
                        m_IMUI.clip_year.visible =
                                m_IMUI.clip_yellow.visible =
                                        m_IMUI.clip_superYellow.visible = false;
        var vipLevel : int = _playerData.vipData.vipLv;
        if( _playerSystem.platform.data ){
           var vipObj : Object =  _imManager.getTxVipInfo( _playerSystem.platform.data );

            var txVipFlg : Boolean = true;
            if( vipObj == null || vipObj.type == 0){
                txVipFlg = false;
            }
            if( txVipFlg ){
                if( vipObj.subType == 1 ){
                    m_IMUI.clip_superBlue.visible = m_IMUI.clip_year.visible = true;
                    m_IMUI.clip_superBlue.index = vipObj.level - 1;
                    m_IMUI.img_vip.visible = vipLevel > 0;
                    if( vipLevel > 0 ){
                        m_IMUI.img_vip.index = vipLevel;
                        m_IMUI.img_vip.x = 105;
                        m_IMUI.txt_name.x = 145;
                    }else {
                        m_IMUI.txt_name.x = 95;
                    }
                }else if( vipObj.subType == 2 ){
                    m_IMUI.clip_blue.visible = m_IMUI.clip_year.visible = true;
                    m_IMUI.clip_blue.index = vipObj.level - 1;
                    m_IMUI.img_vip.visible = vipLevel > 0;
                    if( vipLevel > 0 ){
                        m_IMUI.img_vip.index = vipLevel;
                        m_IMUI.img_vip.x = 105;
                        m_IMUI.txt_name.x = 145;
                    }else {
                        m_IMUI.txt_name.x = 95;
                    }
                }else if( vipObj.subType == 3 ){
                    m_IMUI.clip_superBlue.visible = true;
                    m_IMUI.clip_superBlue.index = vipObj.level - 1;
                    m_IMUI.img_vip.visible = vipLevel > 0;
                    if( vipLevel > 0 ){
                        m_IMUI.img_vip.index = vipLevel;
                        m_IMUI.img_vip.x = 85;
                        m_IMUI.txt_name.x = 125;
                    }else {
                        m_IMUI.txt_name.x = 75;
                    }
                }else if( vipObj.subType == 4 ){
                    m_IMUI.clip_blue.visible = true;
                    m_IMUI.clip_blue.index = vipObj.level - 1;
                    m_IMUI.img_vip.visible = vipLevel > 0;
                    if( vipLevel > 0 ){
                        m_IMUI.img_vip.index = vipLevel;
                        m_IMUI.img_vip.x = 58;
                        m_IMUI.txt_name.x = 125;
                    }else {
                        m_IMUI.txt_name.x = 75;
                    }
                }else if( vipObj.subType == 5 ){
                    m_IMUI.clip_superYellow.visible = true;
                    m_IMUI.clip_superYellow.index = vipObj.level - 1;
                    m_IMUI.img_vip.visible = vipLevel > 0;
                    if( vipLevel > 0 ){
                        m_IMUI.img_vip.index = vipLevel;
                        m_IMUI.img_vip.x = 105;
                        m_IMUI.txt_name.x = 145;
                    }else {
                        m_IMUI.txt_name.x = 95;
                    }
                }else if( vipObj.subType == 6 ){
                    m_IMUI.clip_yellow.visible = true;
                    m_IMUI.clip_yellow.index = vipObj.level - 1;
                    m_IMUI.img_vip.visible = vipLevel > 0;
                    if( vipLevel > 0 ){
                        m_IMUI.img_vip.index = vipLevel;
                        m_IMUI.img_vip.x = 85;
                        m_IMUI.txt_name.x = 125;
                    }else {
                        m_IMUI.txt_name.x = 75;
                    }
                }
            }else{
                m_IMUI.img_vip.visible = vipLevel > 0;
                if( vipLevel > 0 ){
                    m_IMUI.img_vip.index = vipLevel;
                    m_IMUI.img_vip.x = 70;
                    m_IMUI.txt_name.x = 110;
                }else {
                    m_IMUI.txt_name.x = 80;
                }

            }

        }
    }


//    //腾讯 蓝钻 黄钻
//    private function vipInfo( pIMItemUI : IMItemUI , vipLevel : int = 0, vipObj : Object = null ):void{
//        pIMItemUI.clip_blue.visible =
//                pIMItemUI.clip_superBlue.visible =
//                        pIMItemUI.clip_year.visible =
//                                pIMItemUI.clip_yellow.visible =
//                                        pIMItemUI.clip_superYellow.visible = false;
//        pIMItemUI.txt_name.x = 57;
//
//        var txVipFlg : Boolean = true;
//        if( vipObj == null || vipObj.type == 0){
//            txVipFlg = false;
//        }
//        if( txVipFlg ){
//            if( vipObj.subType == 1 ){
//                pIMItemUI.clip_superBlue.visible = pIMItemUI.clip_year.visible = true;
//                pIMItemUI.clip_superBlue.index = vipObj.level - 1;
//                pIMItemUI.img_vip.visible = vipLevel > 0;
//                if( vipLevel > 0 ){
//                    pIMItemUI.img_vip.x = 95;
//                    pIMItemUI.txt_name.x = 115;
//                }else {
//                    pIMItemUI.txt_name.x = 95;
//                }
//            }else if( vipObj.subType == 2 ){
//                pIMItemUI.clip_blue.visible = pIMItemUI.clip_year.visible = true;
//                pIMItemUI.clip_blue.index = vipObj.level - 1;
//                pIMItemUI.img_vip.visible = vipLevel > 0;
//                if( vipLevel > 0 ){
//                    pIMItemUI.img_vip.x = 95;
//                    pIMItemUI.txt_name.x = 115;
//                }else {
//                    pIMItemUI.txt_name.x = 95;
//                }
//            }else if( vipObj.subType == 3 ){
//                pIMItemUI.clip_superBlue.visible = true;
//                pIMItemUI.clip_superBlue.index = vipObj.level - 1;
//                pIMItemUI.img_vip.visible = vipLevel > 0;
//                if( vipLevel > 0 ){
//                    pIMItemUI.img_vip.x = 80;
//                    pIMItemUI.txt_name.x = 100;
//                }else {
//                    pIMItemUI.txt_name.x = 80;
//                }
//            }else if( vipObj.subType == 4 ){
//                pIMItemUI.clip_blue.visible = true;
//                pIMItemUI.clip_blue.index = vipObj.level - 1;
//                pIMItemUI.img_vip.visible = vipLevel > 0;
//                if( vipLevel > 0 ){
//                    pIMItemUI.img_vip.x = 80;
//                    pIMItemUI.txt_name.x = 100;
//                }else {
//                    pIMItemUI.txt_name.x = 80;
//                }
//            }else if( vipObj.subType == 5 ){
//                pIMItemUI.clip_superYellow.visible = true;
//                pIMItemUI.clip_superYellow.index = vipObj.level - 1;
//                pIMItemUI.img_vip.visible = vipLevel > 0;
//                if( vipLevel > 0 ){
//                    pIMItemUI.img_vip.x = 95;
//                    pIMItemUI.txt_name.x = 115;
//                }else {
//                    pIMItemUI.txt_name.x = 95;
//                }
//            }else if( vipObj.subType == 6 ){
//                pIMItemUI.clip_yellow.visible = true;
//                pIMItemUI.clip_yellow.index = vipObj.level - 1;
//                pIMItemUI.img_vip.visible = vipLevel > 0;
//                if( vipLevel > 0 ){
//                    pIMItemUI.img_vip.x = 80;
//                    pIMItemUI.txt_name.x = 100;
//                }else {
//                    pIMItemUI.txt_name.x = 80;
//                }
//            }
//        }else{
//            pIMItemUI.img_vip.visible = vipLevel > 0;
//            if( vipLevel > 0 ){
//                pIMItemUI.img_vip.x = 58;
//                pIMItemUI.txt_name.x = 78;
//            }else {
//                pIMItemUI.txt_name.x = 58;
//            }
//        }
//    }
    private function _addEventListeners():void {
        system.addEventListener( CIMEvent.FRIENDINFO_LIST_RESPONSE,_onFriendInfoListResponse );
        system.addEventListener( CIMEvent.APPLY_LIST_RESPONSE,_onApplyFriendListResponse );
        system.addEventListener( CIMEvent.FRIEND_RECOMMEND_LIST_RESPONSE,_onFriendRecommendListResponse );
        system.addEventListener( CIMEvent.NEW_NOTICE_RESPONSE,_onNewNoticeResponse );

        _playerSystem.addEventListener( CPlayerEvent.PLAYER_TEAM ,_updateData );
        _playerSystem.addEventListener( CPlayerEvent.PLAYER_GUILD_DATA ,_updateData );
    }
    private function _removeEventListeners():void {
        if(_playerSystem)
        system.removeEventListener( CIMEvent.FRIENDINFO_LIST_RESPONSE,_onFriendInfoListResponse );
        system.removeEventListener( CIMEvent.APPLY_LIST_RESPONSE,_onApplyFriendListResponse );
        system.removeEventListener( CIMEvent.FRIEND_RECOMMEND_LIST_RESPONSE,_onFriendRecommendListResponse );
        system.removeEventListener( CIMEvent.NEW_NOTICE_RESPONSE,_onNewNoticeResponse );

        _playerSystem.removeEventListener( CPlayerEvent.PLAYER_TEAM ,_updateData );
        _playerSystem.removeEventListener( CPlayerEvent.PLAYER_GUILD_DATA ,_updateData );
    }
    public function get closeHandler() : Handler {
        return m_pCloseHandler;
    }
    public function set closeHandler( value : Handler ) : void {
        m_pCloseHandler = value;
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
    private function _addToDisplay() : void {
        if( m_IMUI && m_IMUI.parent )
            return;
        setTweenData(KOFSysTags.FRIEND);
        showDialog(m_IMUI, false, _addToDisplayB);
    }

    private function _addToDisplayB() : void {
        if ( m_IMUI ){
            _onNewNoticeResponse();
            _addEventListeners();
            _onUpdateInfoHandler();
            m_IMUI.btnGronp.selectedIndex = _tab;
            m_IMUI.btnGronp.callLater(_onBtnGronpSelectHandler,[_tab]);
            _onSelfTxVipInfo();
        }

    }
    public function removeDisplay() : void {
        closeDialog(_removeDisplayB);
    }
    private function _removeDisplayB() : void {
        if ( m_IMUI ) {
            _removeEventListeners();
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

    }
    private function _updateData(e:CPlayerEvent):void {
        _onUpdateInfoHandler();
    }

    private function _pIMItemUIDisable( pIMItemUI:IMItemUI ,disabled : Boolean ):void{
        pIMItemUI.img_head.disabled =
                pIMItemUI.txt_lv.disabled =
//                        pIMItemUI.txt_name.disabled =
                                pIMItemUI.txt_power.disabled =
                                        pIMItemUI.txt_powert.disabled = disabled;
    }
    private function get _imHandler():CIMHandler{
        return  system.getBean( CIMHandler ) as CIMHandler ;
    }
    private function get _imManager():CIMManager{
        return  system.getBean( CIMManager ) as CIMManager ;
    }
    private function get _imMenuHandler():CIMMenuHandler{
        return  system.getBean( CIMMenuHandler ) as CIMMenuHandler ;
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
    private function get _pCDatabaseSystem():CDatabaseSystem{
        return system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem
    }
    private function get _friendConfig():FriendConfig{
        var pTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.FRIENDCONFIG );
        return pTable.findByPrimaryKey(1);

    }

}
}
