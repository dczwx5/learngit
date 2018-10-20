//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/5/2.
 */
package kof.game.im {

import kof.SYSTEM_ID;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.framework.INetworking;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.system.CNetHandlerImp;
import kof.game.im.data.CIMConst;
import kof.game.systemnotice.CSystemNoticeConst;
import kof.game.systemnotice.CSystemNoticeSystem;
import kof.message.CAbstractPackMessage;
import kof.message.Friend.AddFriendRequest;
import kof.message.Friend.AddFriendResponse;
import kof.message.Friend.ApplyFriendListRequest;
import kof.message.Friend.ApplyFriendListResponse;
import kof.message.Friend.ChatMessageResponse;
import kof.message.Friend.ChatWithFriendRequest;
import kof.message.Friend.ChatWithFriendResponse;
import kof.message.Friend.DealApplicationRequest;
import kof.message.Friend.DealApplicationResponse;
import kof.message.Friend.DeleteFriendRequest;
import kof.message.Friend.DeleteFriendResponse;
import kof.message.Friend.ExamineFriendInfoRequest;
import kof.message.Friend.ExamineFriendInfoResponse;
import kof.message.Friend.FriendInfoListRequest;
import kof.message.Friend.FriendInfoListResponse;
import kof.message.Friend.FriendMessageModifyResponse;
import kof.message.Friend.FriendRecommendListRequest;
import kof.message.Friend.FriendRecommendListResponse;
import kof.message.Friend.GetPhysicalStrengthRequest;
import kof.message.Friend.GetPhysicalStrengthResponse;
import kof.message.Friend.ReplaceFriendRecommendRequest;
import kof.message.Friend.SearchFriendRequest;
import kof.message.Friend.SearchFriendResponse;
import kof.message.Friend.SendPhysicalStrengthRequest;
import kof.message.Friend.SendPhysicalStrengthResponse;
import kof.table.GamePrompt;
import kof.ui.CMsgAlertHandler;
import kof.ui.CUISystem;

public class CIMHandler extends CNetHandlerImp {
    public function CIMHandler() {
        super();
    }
    override protected function onSetup():Boolean {
        var ret:Boolean = super.onSetup();

        this.bind(FriendInfoListResponse, _onFriendInfoListResponseHandler);
        this.bind(GetPhysicalStrengthResponse, _onGetPhysicalStrengthResponseHandler);
        this.bind(SendPhysicalStrengthResponse, _onSendPhysicalStrengthResponseHandler);
        this.bind(ExamineFriendInfoResponse, _onExamineFriendInfoResponseHandler);
        this.bind(SearchFriendResponse, _onSearchFriendResponseHandler);
        this.bind(AddFriendResponse, _onAddFriendResponseHandler);
        this.bind(DeleteFriendResponse, _onDeleteFriendResponseHandler);
        this.bind(ApplyFriendListResponse, _onApplyFriendListResponseHandler);
        this.bind(DealApplicationResponse, _onDealApplicationResponseHandler);
        this.bind(FriendRecommendListResponse, _onFriendRecommendListResponseHandler);
        this.bind(ChatWithFriendResponse, _onChatWithFriendResponseHandler);
        this.bind(ChatMessageResponse, _onChatMessageResponseHandler);
        this.bind(FriendMessageModifyResponse, _onFriendMessageModifyResponseHandler);

        this.onFriendInfoListRequest();
        this.onApplyFriendListRequest();
        return ret;
    }
    /**********************Request********************************/

    /*好友列表信息请求*/
    public function onFriendInfoListRequest( ):void{

        _imManager.new_streng_notice_b = false;

        var request:FriendInfoListRequest = new FriendInfoListRequest();
        request.decode([1]);

        networking.post(request);
    }
    /*领取体力请求*/
    //0 单个领取 1 一键领取
    public function onGetPhysicalStrengthRequest( friendID : int , type : int ):void{
        var request:GetPhysicalStrengthRequest = new GetPhysicalStrengthRequest();
        request.decode([friendID,type]);

        networking.post(request);
    }
    /*赠送体力请求*/
    //0 单个赠送 1 一键赠送
    public function onSendPhysicalStrengthRequest( friendID : int , type : int ):void{
        var request:SendPhysicalStrengthRequest = new SendPhysicalStrengthRequest();
        request.decode([friendID,type]);

        networking.post(request);
    }
    /*查看好友资料请求*/
    public function onExamineFriendInfoRequest( friendID : int ):void{
        var request:ExamineFriendInfoRequest = new ExamineFriendInfoRequest();
        request.decode([friendID]);

        networking.post(request);
    }
    /*搜索好友请求*/
    public function onSearchFriendRequest( name : String ):void{
        var request:SearchFriendRequest = new SearchFriendRequest();
        request.decode([name]);

        networking.post(request);
    }
    /*添加好友请求*/
    public function onAddFriendRequest( friendIDList : Array ,type : int ):void{
        var request:AddFriendRequest = new AddFriendRequest();
        request.decode([friendIDList,type]);

        networking.post(request);
    }
    /*删除好友请求*/
    public function onDeleteFriendRequest( friendID : int ):void{
        var request:DeleteFriendRequest = new DeleteFriendRequest();
        request.decode([friendID]);

        networking.post(request);
    }
    /*好友申请列表信息请求*/
    public function onApplyFriendListRequest():void{

        _imManager.new_apply_notice_b = false;

        var request:ApplyFriendListRequest = new ApplyFriendListRequest();
        request.decode([1]);

        networking.post(request);
    }
    /*同意或拒绝好友申请请求*/
    //dealType 0同意 1拒绝
    //type  /0单个 1一键
    public function onDealApplicationRequest(friendID : int ,dealType:int, type : int):void{
        var request:DealApplicationRequest = new DealApplicationRequest();
        request.decode([friendID,dealType,type]);

        networking.post(request);
    }

    /*好友推荐列表信息请求*/
    public function onFriendRecommendListRequest():void{
        var request:FriendRecommendListRequest = new FriendRecommendListRequest();
        request.decode([1]);

        networking.post(request);
    }
    /*换一批好友推荐请求*/
    public function onReplaceFriendRecommendRequest():void{
        var request:ReplaceFriendRecommendRequest = new ReplaceFriendRecommendRequest();
        request.decode([1]);

        networking.post(request);
    }

    /*好友聊天请求*/
    public function onChatWithFriendRequest(friendID : int ,senderID: int, message : String):void{
        var request:ChatWithFriendRequest = new ChatWithFriendRequest();
        request.decode([friendID,senderID,message]);

        networking.post(request);
    }

    /**********************Response********************************/

    /*好友列表信息响应*/
    private final function _onFriendInfoListResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;
        var response:FriendInfoListResponse = message as FriendInfoListResponse;
        if( !response.friendInfoMap.friendInfoList ){
            _imManager.resetFriendsData();
            system.dispatchEvent(new CIMEvent(CIMEvent.FRIENDINFO_LIST_RESPONSE ));
            return;
        }
        if( response.friendInfoMap.hasOwnProperty('getPhysicalStrengthCount') )
            _imManager.getPhysicalStrengthCount = response.friendInfoMap.getPhysicalStrengthCount;
        _imManager.resetFriendsData();
        _imManager.updateFriendsData( response.friendInfoMap.friendInfoList);
        system.dispatchEvent(new CIMEvent(CIMEvent.FRIENDINFO_LIST_RESPONSE ));
    }
    /*领取体力响应*/
    private final function _onGetPhysicalStrengthResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;
        var response:GetPhysicalStrengthResponse = message as GetPhysicalStrengthResponse;
        if( response.dataMap.getPhysicalStrengthCount )
            _imManager.getPhysicalStrengthCount = response.dataMap.getPhysicalStrengthCount;
        _imManager.updateFriendsData( response.dataMap.friendInfoList );
        system.dispatchEvent(new CIMEvent(CIMEvent.FRIENDINFO_LIST_RESPONSE ));
    }
    /*赠送体力响应*/
    private final function _onSendPhysicalStrengthResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;
        var response:SendPhysicalStrengthResponse = message as SendPhysicalStrengthResponse;
        _imManager.updateFriendsData( response.dataMap.friendInfoList );
        system.dispatchEvent(new CIMEvent(CIMEvent.FRIENDINFO_LIST_RESPONSE ));
        if( response.dataMap.friendInfoList && response.dataMap.friendInfoList.length )
            _pCUISystem.showMsgAlert('赠送体力成功', CMsgAlertHandler.NORMAL);

    }
    /*查看好友资料响应*/
    private final function _onExamineFriendInfoResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;
        var response:ExamineFriendInfoResponse = message as ExamineFriendInfoResponse;
//        response
    }
    /*搜索好友响应*/
    private final function _onSearchFriendResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;
        var response:SearchFriendResponse = message as SearchFriendResponse;
        if( !response.playerInfoMap.roleID ){
            _pCUISystem.showMsgAlert('玩家不存在');
            return;
        }
        _imManager.updateSearchFriendData( response.playerInfoMap );
        system.dispatchEvent(new CIMEvent(CIMEvent.SEARCH_FRIEND_RESPONSE,response));
    }
    /*添加好友响应*/
    private final function _onAddFriendResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;
        var response:AddFriendResponse = message as AddFriendResponse;
        _imManager.updateRecommendData( response.dataMap.playerInfoList);
        system.dispatchEvent(new CIMEvent(CIMEvent.FRIEND_RECOMMEND_LIST_RESPONSE));

    }
    /*删除好友响应*/
    private final function _onDeleteFriendResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;
        var response:DeleteFriendResponse = message as DeleteFriendResponse;
        _imManager.deleteFriendsData( response.dataMap.friendInfoList);
        system.dispatchEvent(new CIMEvent(CIMEvent.FRIENDINFO_LIST_RESPONSE ));
    }
    /*好友申请列表信息响应*/
    private final function _onApplyFriendListResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;
        var response:ApplyFriendListResponse = message as ApplyFriendListResponse;
        if( !response.applicationMap.friendInfoList )
                return;
        _imManager.resetApplyData();
        _imManager.updateApplyData( response.applicationMap.friendInfoList);
        system.dispatchEvent(new CIMEvent(CIMEvent.APPLY_LIST_RESPONSE));
    }
    /*同意或拒绝好友申请响应*/
    private final function _onDealApplicationResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;
        var response:DealApplicationResponse = message as DealApplicationResponse;
        _imManager.updateApplyResponseData( response );
        system.dispatchEvent(new CIMEvent(CIMEvent.APPLY_LIST_RESPONSE));
    }
    /*好友推荐列表信息响应*/
    private final function _onFriendRecommendListResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;
        var response:FriendRecommendListResponse = message as FriendRecommendListResponse;
        if( !response.recommendMap.playerInfoList )
            return;
        _imManager.resetRecommendData();
        _imManager.initRecommendData( response.recommendMap.playerInfoList);
        system.dispatchEvent(new CIMEvent(CIMEvent.FRIEND_RECOMMEND_LIST_RESPONSE));

    }
    /*好友聊天请求响应*/
    private final function _onChatWithFriendResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;
        var response:ChatWithFriendResponse = message as ChatWithFriendResponse;
        _imManager.updateChatInfo( response.dataMap );
        _pIMChatSystem.dispatchEvent(new CIMEvent(CIMEvent.CHAT_INFO_RESPONSE ,response.dataMap.friendID));
    }
    /*聊天响应（信息接收）*/

    private final function _onChatMessageResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;
        var response:ChatMessageResponse = message as ChatMessageResponse;
        _imManager.updateChatInfo( response.dataMap );
        _imManager.addChatFriendsAry( response.dataMap.friendID );
        _imManager.addNewNotReadFriendsAry( response.dataMap.friendID );
        _pIMChatSystem.dispatchEvent(new CIMEvent(CIMEvent.CHAT_INFO_RESPONSE ,response.dataMap.friendID));

        var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as
                ISystemBundleContext;
        if ( pSystemBundleCtx ) {
            var pSystemBundle : ISystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.SYSTEM_NOTICE ) );
            pSystemBundleCtx.setUserData( pSystemBundle, CBundleSystem.NOTICE_ARGS,[CSystemNoticeConst.SYSTEM_CHAT]);
            pSystemBundleCtx.setUserData( pSystemBundle, CBundleSystem.ACTIVATED, true );
        }
//        ( system.stage.getSystem( CSystemNoticeSystem ) as CSystemNoticeSystem ).showNotice( CSystemNoticeConst.SYSTEM_CHAT );
    }


    /*新消息提示（信息接收）
    * 0;//体力领取信息
    * 1;//好友申请信息
    * 2;//好友增加
    * 3;//好友删除
    * */

    private final function _onFriendMessageModifyResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;
        var response:FriendMessageModifyResponse = message as FriendMessageModifyResponse;

        if( response.type == CIMConst.NEW_STRENG_NOTICE ){
            _imManager.new_streng_notice_b = true;
        } else if( response.type == CIMConst.NEW_APPLY_NOTICE ){
            _imManager.new_apply_notice_b = true;
        } else if( response.type == CIMConst.DELETE_FRIEND_NOTICE ){
            _imManager.new_streng_notice_b = false;
            system.addEventListener( CIMEvent.FRIENDINFO_LIST_RESPONSE , _friendinfoListResponse );
            onFriendInfoListRequest();
        }

        system.dispatchEvent(new CIMEvent(CIMEvent.NEW_NOTICE_RESPONSE,response.type ));

    }
    private function _friendinfoListResponse( evt : CIMEvent ):void{
        var flg : Boolean;
        var roleID : int ;
        for each ( roleID in _imManager.newNotReadFriendsAry ){
            if( _imManager.getFriendsDataByID(roleID) ){
                flg = true;
            }else{
                _imManager.removeNewNotReadFriendsAry( roleID );
            }
        }

        if( !flg ){
            _pSystemNoticeSystem.hideIcon( CSystemNoticeConst.SYSTEM_CHAT );
        }


    }







    private function get _imManager():CIMManager{
        return system.getBean(CIMManager) as CIMManager;
    }
    private function get _pCUISystem():CUISystem{
        return system.stage.getSystem( CUISystem ) as CUISystem;
    }
    private function get _pIMChatSystem():CIMChatSystem{
        return system.stage.getSystem( CIMChatSystem ) as CIMChatSystem;
    }
    private function get _pSystemNoticeSystem():CSystemNoticeSystem{
        return system.stage.getSystem( CSystemNoticeSystem ) as CSystemNoticeSystem
    }









}
}
