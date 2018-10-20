//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/5/25.
 */
package kof.game.club {

import QFLib.Utils.HtmlUtil;

import flash.utils.Dictionary;

import kof.SYSTEM_ID;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CAppStage;
import kof.framework.IDataTable;
import kof.framework.INetworking;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.chat.CChatSystem;
import kof.game.chat.data.CChatChannel;
import kof.game.chat.data.CChatLinkConst;
import kof.game.chat.data.CChatType;
import kof.game.club.data.CClubConst;
import kof.game.club.view.clubgame.ClubGameConst;
import kof.game.common.system.CNetHandlerImp;
import kof.game.instance.CInstanceSystem;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.message.CAbstractPackMessage;
import kof.message.Club.ApplyClubRequest;
import kof.message.Club.ApplyClubResponse;
import kof.message.Club.ClubChairmanChangeResponse;
import kof.message.Club.ClubFundInvestmentRequest;
import kof.message.Club.ClubFundInvestmentResponse;
import kof.message.Club.ClubInfoListRequest;
import kof.message.Club.ClubInfoListResponse;
import kof.message.Club.ClubInfoMessageRequest;
import kof.message.Club.ClubInfoMessageResponse;
import kof.message.Club.ClubInfoRequest;
import kof.message.Club.ClubInfoResponse;
import kof.message.Club.ClubInvitationRequest;
import kof.message.Club.ClubInvitationResponse;
import kof.message.Club.ClubMessageResponse;
import kof.message.Club.ClubRankListRequest;
import kof.message.Club.ClubRankListResponse;
import kof.message.Club.CreateClubRequest;
import kof.message.Club.CreateClubResponse;
import kof.message.Club.DealPlayerApplicationRequest;
import kof.message.Club.DealPlayerApplicationResponse;
import kof.message.Club.ExitClubRequest;
import kof.message.Club.ExitClubResponse;
import kof.message.Club.GetClubActiveRewardRequest;
import kof.message.Club.GetLuckyBagRequest;
import kof.message.Club.GetLuckyBagResponse;
import kof.message.Club.GetOfficerWelfareRequest;
import kof.message.Club.GetOfficerWelfareResponse;
import kof.message.Club.KickOutClubRequest;
import kof.message.Club.KickOutClubResponse;
import kof.message.Club.LuckyBagInfoListRequest;
import kof.message.Club.LuckyBagInfoListResponse;
import kof.message.Club.LuckyBagRecordRequest;
import kof.message.Club.LuckyBagRecordResponse;
import kof.message.Club.MemberInfoModifyResponse;
import kof.message.Club.ModifyClubInfoRequest;
import kof.message.Club.ModifyClubInfoResponse;
import kof.message.Club.ModifyJoinClubConditionRequest;
import kof.message.Club.ModifyJoinClubConditionResponse;
import kof.message.Club.OpenClubFundRequest;
import kof.message.Club.OpenClubFundResponse;
import kof.message.Club.OpenClubRequest;
import kof.message.Club.OpenClubResponse;
import kof.message.Club.PlayerLuckyBagRecordRequest;
import kof.message.Club.PlayerLuckyBagRecordResponse;
import kof.message.Club.RechargeLuckyBagRequest;
import kof.message.Club.RechargeLuckyBagResponse;
import kof.message.Club.SendLuckyBagRankRequest;
import kof.message.Club.SendLuckyBagRankResponse;
import kof.message.Club.SendLuckyBagRequest;
import kof.message.Club.SendLuckyBagResponse;
import kof.message.Club.ThanksRechargeLuckyBagRequest;
import kof.message.Club.ThanksRechargeLuckyBagResponse;
import kof.message.Club.UpdateClubPositionRequest;
import kof.message.Club.UpdateClubPositionResponse;
import kof.message.ClubGame.ClubGameInfoRequest;
import kof.message.ClubGame.ClubGameInfoResponse;
import kof.message.ClubGame.ClubGameSettingRequest;
import kof.message.ClubGame.GetClubGameRewardRequest;
import kof.message.ClubGame.GetClubGameRewardResponse;
import kof.message.ClubGame.PlayClubGameRequest;
import kof.message.ClubGame.PlayClubGameResponse;
import kof.table.ThanksMessage;
import kof.ui.CMsgAlertHandler;
import kof.ui.CUISystem;

public class CClubHandler extends CNetHandlerImp {
    public function CClubHandler() {
    }
    private var _initDic : Dictionary;
    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        this.bind( CreateClubResponse, _onCreateClubResponseHandler );
        this.bind( OpenClubResponse, _onOpenClubResponseHandler );
        this.bind( ClubInfoResponse, _onClubInfoResponseHandler );
        this.bind( ClubInfoListResponse, _onClubInfoListResponseHandler );
        this.bind( ClubRankListResponse, _onClubRankListResponseHandler );
        this.bind( ApplyClubResponse, _onApplyClubResponseHandler );
        this.bind( ModifyJoinClubConditionResponse, _onModifyJoinClubConditionResponseHandler );
        this.bind( ModifyClubInfoResponse, _onModifyClubInfoResponseHandler );
        this.bind( ExitClubResponse, _onExitClubResponseHandler );
        this.bind( UpdateClubPositionResponse, _onUpdateClubPositionResponseHandler );
        this.bind( KickOutClubResponse, _onKickOutClubResponseHandler );
        this.bind( DealPlayerApplicationResponse, _onDealPlayerApplicationResponseHandler );
        this.bind( GetOfficerWelfareResponse, _onGetOfficerWelfareResponseHandler );
        this.bind( MemberInfoModifyResponse, _onMemberInfoModifyResponseHandler );
        this.bind( OpenClubFundResponse, _onOpenClubFundResponseHandler );
        this.bind( ClubFundInvestmentResponse , _onClubFundInvestmentResponseHandler );
        this.bind( LuckyBagInfoListResponse, _onLuckyBagInfoListResponseHandler );
        this.bind( GetLuckyBagResponse, _onGetLuckyBagResponseHandler );
        this.bind( SendLuckyBagResponse, _onSendLuckyBagResponseHandler );
        this.bind( SendLuckyBagRankResponse, _onSendLuckyBagRankResponseHandler );
        this.bind( LuckyBagRecordResponse, _onLuckyBagRecordResponseHandler );
        this.bind( PlayerLuckyBagRecordResponse, _onPlayerLuckyBagRecordResponseHandler );
        this.bind( ClubInfoMessageResponse, _onClubInfoMessageResponseHandler );
        this.bind( ClubChairmanChangeResponse, _onClubChairmanChangeResponseHandler );
        this.bind( ClubMessageResponse, _onClubMessageResponseHandler );
        this.bind( ClubInvitationResponse, _onClubInvitationResponseHandler );
        this.bind( ClubGameInfoResponse, _onClubGameInfoResponseHandler );
        this.bind( PlayClubGameResponse, _onPlayClubGameResponseHandler );
        this.bind( GetClubGameRewardResponse, _onGetClubGameRewardResponseHandler );
        this.bind( RechargeLuckyBagResponse, _onRechargeLuckyBagResponseHandler );
        this.bind( ThanksRechargeLuckyBagResponse, _onThanksRechargeLuckyBagResponseHandler );

        _initDic = new Dictionary();
        _initDic["OpenClub"] = false;
        _initDic["LuckyBagInfoList"] = false;
        _initDic["ClubGameInfo"] = false;
        return ret;
    }

    override protected function enterStage( stage : CAppStage ) : void {
        super.enterStage( stage );
        this.onClubInfoMessageRequest();
        this.onOpenClubRequest( false );
        this.onLuckyBagInfoListRequest( CClubConst.CLUB_BAG_LIST );
        this.onLuckyBagInfoListRequest( CClubConst.USER_BAG_LIST );
        this.onClubGameInfoRequest();
    }

    /**********************Request********************************/

    /*创建俱乐部请求*/
    public function onCreateClubRequest( clubName : String, clubSignID : int ) : void {
        var request : CreateClubRequest = new CreateClubRequest();
        request.decode( [ clubName, clubSignID ] );

        networking.post( request );
    }

    /*打开俱乐部请求*/
    public function onOpenClubRequest( needShowClubView : Boolean = true ) : void {

        _pClubManager.needShowClubView = needShowClubView;

        var request : OpenClubRequest = new OpenClubRequest();
        request.decode( [ 1 ] );

        networking.post( request );
    }

    /*俱乐部信息请求*/
    //请求类型 0 俱乐部信息 1 俱乐部成员信息 2俱乐部申请列表信息 3查看俱乐部信息（任何人）
    public function onClubInfoRequest( clubID : String, infoType : int ) : void {
        var request : ClubInfoRequest = new ClubInfoRequest();
        request.decode( [ clubID, infoType ] );

        networking.post( request );
    }

    /*俱乐部列表请求  未加入俱乐部之前*/
    //页数从1开始
    public function onClubInfoListRequest( pages : int ) : void {
        var request : ClubInfoListRequest = new ClubInfoListRequest();
        request.decode( [ pages ] );

        networking.post( request );
    }

    /*俱乐部排行榜请求   加入俱乐部之后*/
    //页数从1开始
    public function onClubRankListRequest( clubID : String, pages : int ) : void {
        var request : ClubRankListRequest = new ClubRankListRequest();
        request.decode( [ clubID, pages ] );

        networking.post( request );
    }

    /*申请俱乐部请求*/
    //0 单个申请 1 快速申请
    public function onApplyClubRequest( clubID : String, type : int ) : void {
        var request : ApplyClubRequest = new ApplyClubRequest();
        request.decode( [ clubID, type ] );

        networking.post( request );
    }

    /*修改俱乐部加入条件请求*/
//    condition : 修改条件  1允许任何人加入 2 允许任何人申请 3 允许任何人加入有等级限制 4允许任何人申请但有等级限制 5不允许任何人加入
//    level : 等级限制 1,2,5,传0  3,4传相应的等级限制
    public function onModifyJoinClubConditionRequest( clubID : String, condition : int, level : int ) : void {
        var request : ModifyJoinClubConditionRequest = new ModifyJoinClubConditionRequest();
        request.decode( [ clubID, condition, level ] );

        networking.post( request );
    }

    /*修改俱乐部公告，名称，标志请求*/
    //修改信息类型 1公告 2名称 3 标志
    public function onModifyClubInfoRequest( announcement : String = '', clubName : String = '', clubSignID : int = 0, type : int = 0 ) : void {
        var request : ModifyClubInfoRequest = new ModifyClubInfoRequest();
        request.decode( [ announcement, clubName, clubSignID, type ] );
        networking.post( request );
    }

    /*退出俱乐部请求*/
    public function onExitClubRequest( clubID : String ) : void {
        var request : ExitClubRequest = new ExitClubRequest();
        request.decode( [ clubID ] );

        networking.post( request );
    }

    /*俱乐部职位调整请求*/
    public function onUpdateClubPositionRequest( playerRoleID : int, clubID : String, position : int ) : void {
        var request : UpdateClubPositionRequest = new UpdateClubPositionRequest();
        request.decode( [ playerRoleID, clubID, position ] );

        networking.post( request );
    }

    /*请离俱乐部请求*/
    public function onKickOutClubRequest( playerRoleID : int, clubID : String ) : void {
        var request : KickOutClubRequest = new KickOutClubRequest();
        request.decode( [ playerRoleID, clubID ] );

        networking.post( request );
    }

    /*处理玩家申请请求*/
//    playerID : 玩家ID  一键的时候发0
//    dealType : 0同意 1拒绝
//    type : 0单个 1一键
    public function onDealPlayerApplicationRequest( playerID : int, dealType : int, type : int ) : void {
        var request : DealPlayerApplicationRequest = new DealPlayerApplicationRequest();
        request.decode( [ playerID, dealType, type ] );

        networking.post( request );
    }

    /*打开俱乐部基金请求*/
    public function onOpenClubFundRequest() : void {
        var request : OpenClubFundRequest = new OpenClubFundRequest();
        request.decode( [ 1 ] );

        networking.post( request );
    }

    /*俱乐部基金投资请求*/
    public function onClubFundInvestmentRequest( investType : int ) : void {
        var request : ClubFundInvestmentRequest = new ClubFundInvestmentRequest();
        request.decode( [ investType ] );

        networking.post( request );
    }

    /*获得俱乐部活跃值奖励请求*/
    public function onGetClubActiveRewardRequest( type : int ) : void {
        var request : GetClubActiveRewardRequest = new GetClubActiveRewardRequest();
        request.decode( [ type ] );

        networking.post( request );
    }

    /*福利领取请求*/
    public function onGetOfficerWelfareRequest() : void {
        var request : GetOfficerWelfareRequest = new GetOfficerWelfareRequest();
        request.decode( [ 1 ] );

        networking.post( request );
    }

    /*福袋列表信息请求*/
    //1,俱乐部福袋 2玩家福袋
    public function onLuckyBagInfoListRequest( type : int ) : void {
        var request : LuckyBagInfoListRequest = new LuckyBagInfoListRequest();
        request.decode( [ type ] );

        networking.post( request );
    }

    /*抢福袋请求*/
    //1,俱乐部福袋 2玩家福袋
    public function onGetLuckyBagRequest( type : int, luckBagID : String ) : void {
        var request : GetLuckyBagRequest = new GetLuckyBagRequest();
        request.decode( [ type, luckBagID ] );

        networking.post( request );
    }

    /*发福袋请求*/
    public function onSendLuckyBagRequest( type : int ) : void {
        var request : SendLuckyBagRequest = new SendLuckyBagRequest();
        request.decode( [ type ] );

        networking.post( request );
    }

    /*福袋记录信息请求*/
    // 1,俱乐部福袋 2玩家福袋
    public function onLuckyBagRecordRequest( type : int, luckBagID : String ) : void {
        var request : LuckyBagRecordRequest = new LuckyBagRecordRequest();
        request.decode( [ type, luckBagID ] );

        networking.post( request );
    }

    /*发福袋排行榜请求*/
    // 1金币福袋 2钻石福袋 3道具福袋 4充值福袋
    public function onSendLuckyBagRankRequest( type : int ) : void {
        var request : SendLuckyBagRankRequest = new SendLuckyBagRankRequest();
        request.decode( [ type ] );

        networking.post( request );
    }

    /*玩家福袋记录*/
    public function onPlayerLuckyBagRecordRequest() : void {
        var request : PlayerLuckyBagRecordRequest = new PlayerLuckyBagRecordRequest();
        request.decode( [ 1 ] );

        networking.post( request );
    }

    /*玩家俱乐部信息  登录请求*/
    public function onClubInfoMessageRequest() : void {
        var request : ClubInfoMessageRequest = new ClubInfoMessageRequest();
        request.decode( [ 1 ] );

        networking.post( request );
    }

    /*发布邀请请求*/
    public function onClubInvitationRequest() : void {
        var request : ClubInvitationRequest = new ClubInvitationRequest();
        request.decode( [ 1 ] );

        networking.post( request );
    }
    /*俱乐部小玩法玩家信息请求 */
    public function onClubGameInfoRequest() : void {
        var request : ClubGameInfoRequest = new ClubGameInfoRequest();
        request.decode( [ 1 ] );

        networking.post( request );
    }
    /*玩俱乐部小玩法请求（开转）
    * 0:重新转 1：改转 2付费改转
    * */
    public function onPlayClubGameRequest( type : int ) : void {
        var request : PlayClubGameRequest = new PlayClubGameRequest();
        request.decode( [ type ] );

        networking.post( request );
    }
    /*获取奖励请求（见好就收）
    * */
    public function onGetClubGameRewardRequest() : void {
        var request : GetClubGameRewardRequest = new GetClubGameRewardRequest();
        request.decode( [ 1 ] );

        networking.post( request );
    }
    /*俱乐部小玩法游戏设置（跳过动画）
     0 不跳过 1 跳过动画
    * */
    public function onClubGameSettingRequest( skipAnimationSetting : int ) : void {
        var request : ClubGameSettingRequest = new ClubGameSettingRequest();
        request.decode( [ skipAnimationSetting ] );

        networking.post( request );
    }


    /*充值福袋信息*/
    public function onRechargeLuckyBagRequest() : void {
        var request : RechargeLuckyBagRequest = new RechargeLuckyBagRequest();
        request.decode( [ 1 ] );

        networking.post( request );
    }
    /*充值福袋感谢协议*/
    public function onThanksRechargeLuckyBagRequest( luckBagID : String ) : void {
        var request : ThanksRechargeLuckyBagRequest = new ThanksRechargeLuckyBagRequest();
        request.decode( [ luckBagID ] );

        networking.post( request );
    }


    /**********************Response********************************/

    /*创建俱乐部响应*/
    private final function _onCreateClubResponseHandler( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        if ( isError ) return;
        var response : CreateClubResponse = message as CreateClubResponse;
        system.dispatchEvent( new CClubEvent( CClubEvent.CREATE_CLUB_SUCC ) );

    }

    /*打开俱乐部响应*/
    private final function _onOpenClubResponseHandler( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        if ( isError ) return;
        var response : OpenClubResponse = message as OpenClubResponse;
        _pClubManager.isOpenClub = response.isOpenClub;
        _pClubManager.updateClubOpenInfo( response );
        //=============================add by Lune 0710=========================
        system.dispatchEvent( new CClubEvent( CClubEvent.CLUB_RED_POINT ) );//刷新主界面红点
        if(_initDic["OpenClub"]) //初始化的时候只是请求了数据，不需要打开界面
        {
            system.dispatchEvent( new CClubEvent( CClubEvent.OPEN_CLUB_RESPONSE ) );
        }
        _initDic["OpenClub"] = true;
    }

    /*俱乐部信息响应*/
    private final function _onClubInfoResponseHandler( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        if ( isError ) return;
        var response : ClubInfoResponse = message as ClubInfoResponse;
        _pClubManager.updateClubInfo( response );
        system.dispatchEvent( new CClubEvent( CClubEvent.CLUB_INFO_RESPONSE, response ) );
    }

    /*俱乐部列表响应*/
    private final function _onClubInfoListResponseHandler( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        if ( isError ) return;
        var response : ClubInfoListResponse = message as ClubInfoListResponse;
        _pClubManager.updateClubListInfo( response.pages, response.clubNum, response.dataMap );
        system.dispatchEvent( new CClubEvent( CClubEvent.CLUB_LIST_RESPONSE ) );

    }

    /*俱乐部排行榜响应*/
    private final function _onClubRankListResponseHandler( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        if ( isError ) return;
        var response : ClubRankListResponse = message as ClubRankListResponse;
        _pClubManager.updateClubRankListInfo( response.pages, response.clubNum, response.dataMap );
        system.dispatchEvent( new CClubEvent( CClubEvent.CLUB_LIST_RESPONSE ) );

    }

    /*申请俱乐部响应*/
    private final function _onApplyClubResponseHandler( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        if ( isError ) return;
        var response : ApplyClubResponse = message as ApplyClubResponse;
        _pClubManager.updateApplyInfo( response );
    }

    /*修改俱乐部加入条件响应*/
    private final function _onModifyJoinClubConditionResponseHandler( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        if ( isError ) return;
        var response : ModifyJoinClubConditionResponse = message as ModifyJoinClubConditionResponse;
        _pClubManager.updateClubInfoData( response.clubInfoMap );
        system.dispatchEvent( new CClubEvent( CClubEvent.CLUB_INFO_CHANGE ) );
        _pCUISystem.showMsgAlert( '修改俱乐部加入条件成功', CMsgAlertHandler.NORMAL );
    }

    /*修改俱乐部公告，名称，标志响应*/
    private final function _onModifyClubInfoResponseHandler( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        if ( isError ) return;
        var response : ModifyClubInfoResponse = message as ModifyClubInfoResponse;
        _pClubManager.updateClubInfoData( response.ClubDataMap );
        system.dispatchEvent( new CClubEvent( CClubEvent.CLUB_INFO_CHANGE ) );
        _pCUISystem.showMsgAlert( '修改俱乐部' + CClubConst.CHANGETYPE[ response.type ] + '成功', CMsgAlertHandler.NORMAL );
    }

    /*退出俱乐部响应*/
    private final function _onExitClubResponseHandler( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        if ( isError ) return;
        var response : ExitClubResponse = message as ExitClubResponse;
        system.dispatchEvent( new CClubEvent( CClubEvent.CLUB_EXIT_SUCC ) );
        _pCUISystem.showMsgAlert( '退出' + _pClubManager.clubName + '俱乐部成功', CMsgAlertHandler.NORMAL );
        _pClubManager.clubID = '';
        _pClubManager.clubLevel = 0;
        _pClubManager.clubName = '';
        _pClubManager.clubState = CClubConst.NOT_IN_CLUB;
        _pClubManager.selfClubApplyList = [];
        _pClubManager.selfClubMemBerList = [];
        system.dispatchEvent( new CClubEvent( CClubEvent.CLUB_RED_POINT ) );//刷新主界面红点
        var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        var pSystemBundle : ISystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.GUILD ) );
        pSystemBundleCtx.setUserData( pSystemBundle, CBundleSystem.ACTIVATED, false );
    }

    /*俱乐部职位调整响应*/
    private final function _onUpdateClubPositionResponseHandler( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        if ( isError ) return;
        var response : UpdateClubPositionResponse = message as UpdateClubPositionResponse;
        _pClubManager.updateMemberListData( response.playerInfoList.playerInfoList );
        _pCUISystem.showMsgAlert( '调整职位成功', CMsgAlertHandler.NORMAL );
        system.dispatchEvent( new CClubEvent( CClubEvent.CLUB_MEMBER_LIST_CHANGE ) );
    }

    /*请离俱乐部响应*/
    private final function _onKickOutClubResponseHandler( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        if ( isError ) return;
        var response : KickOutClubResponse = message as KickOutClubResponse;
        _pClubManager.updateMemberListData( response.playerInfoList.playerInfoList );
        _pCUISystem.showMsgAlert( '请离成功', CMsgAlertHandler.NORMAL );
        system.dispatchEvent( new CClubEvent( CClubEvent.CLUB_MEMBER_LIST_CHANGE ) );
    }

    /*处理玩家申请响应*/
    private final function _onDealPlayerApplicationResponseHandler( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        if ( isError ){
            onClubInfoRequest(  _pClubManager.selfClubData.id , 2 );
            return;
        }
        var response : DealPlayerApplicationResponse = message as DealPlayerApplicationResponse;
        _pClubManager.updateClubApplyData( response.dataMap.applicationList );
        system.dispatchEvent( new CClubEvent( CClubEvent.DEAL_APPLICATION_RESPONSE ) );
        _pCUISystem.showMsgAlert( '处理申请成功', CMsgAlertHandler.NORMAL );
    }

    /*信息变化响应*/
    private final function _onMemberInfoModifyResponseHandler( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        if ( isError ) return;
        var response : MemberInfoModifyResponse = message as MemberInfoModifyResponse;
        //信息类型 1被踢  2职位提升 3 职位下降 4通过申请
        system.dispatchEvent( new CClubEvent( CClubEvent.MEMBER_INFO_MODIFY_RESPONSE, response ) );

        if(response.type == 4)
        {
            this.onLuckyBagInfoListRequest( CClubConst.CLUB_BAG_LIST );
            this.onLuckyBagInfoListRequest( CClubConst.USER_BAG_LIST );//加入成功后请求一次红包数据
        }
    }

    /*打开俱乐部基金响应*/
    private final function _onOpenClubFundResponseHandler( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        if ( isError ) return;
        var response : OpenClubFundResponse = message as OpenClubFundResponse;
        _pClubManager.updateClubFundData( response.ClubFundMap );
        system.dispatchEvent( new CClubEvent( CClubEvent.OPEN_CLUB_FUND_RESPONSE ) );
    }
    /*俱乐部基金投资响应*/
    private final function _onClubFundInvestmentResponseHandler( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        if ( isError ) return;
        var response : ClubFundInvestmentResponse = new ClubFundInvestmentResponse();
        if(response.gamePromptID)
        {

        }
        _pCUISystem.showMsgAlert( '俱乐部投资成功', CMsgAlertHandler.NORMAL );
    }

    /*福利领取响应*/
    private final function _onGetOfficerWelfareResponseHandler( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        if ( isError ) return;
        var response : GetOfficerWelfareResponse = message as GetOfficerWelfareResponse;
        _pClubManager.getClubRewardSign = true;
        _pCUISystem.showMsgAlert( '领取福利成功', CMsgAlertHandler.NORMAL );
        system.dispatchEvent( new CClubEvent( CClubEvent.GET_OFFICER_WELFARE_RESPONSE ) );
        //=============================add by Lune 0710=========================
        system.dispatchEvent( new CClubEvent( CClubEvent.CLUB_RED_POINT ) );//刷新主界面红点
    }

    /*福袋列表信息响应*/
    private final function _onLuckyBagInfoListResponseHandler( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        if ( isError ) return;
        var response : LuckyBagInfoListResponse = message as LuckyBagInfoListResponse;
        _pClubManager.updateBagList( response );
        _pClubManager.sendBagCounts = response.sendLuckyBagCounts;
        _pClubManager.getUserBagCounts = response.getLuckyBagCounts;
        _pClubManager.playerLuckyBagState = response.playerLuckyBagState;
        if( _initDic["LuckyBagInfoList"])
            system.dispatchEvent( new CClubEvent( CClubEvent.LUCKY_BAGINFO_LIST_RESPONSE, response.type ) );
        //=============================add by Lune 0710=========================
        _initDic["LuckyBagInfoList"] = true;
        system.dispatchEvent( new CClubEvent( CClubEvent.CLUB_RED_POINT ) );//刷新主界面红点
    }

    /*抢福袋响应*/
    private final function _onGetLuckyBagResponseHandler( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        if ( isError ) return;
        var response : GetLuckyBagResponse = message as GetLuckyBagResponse;
        if ( response.type == CClubConst.CLUB_BAG_LIST ) {
            _pClubManager.updateSystemBagListItemDataToDic( response.luckyBagMap );
            _pClubManager.checkWelBagState = false;//领完状态归位
        } else if ( response.type == CClubConst.USER_BAG_LIST || response.type == CClubConst.RECHARGE_BAG_LIST  ) {
            _pClubManager.getUserBagCounts = response.counts;
            _pClubManager.updateUserBagListItemDataToDic( response.luckyBagMap );
        }
        _pClubManager.getUserBagCounts = response.counts;
        system.dispatchEvent( new CClubEvent( CClubEvent.GET_LUCKY_BAG_RESPONSE, response ) );
        //=============================add by Lune 0710=========================
        system.dispatchEvent( new CClubEvent( CClubEvent.CLUB_RED_POINT ) );//刷新主界面红点
    }

    /*发福袋响应*/
    private final function _onSendLuckyBagResponseHandler( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        if ( isError ) return;
        var response : SendLuckyBagResponse = message as SendLuckyBagResponse;
        _pClubManager.sendBagCounts = response.counts;
        system.dispatchEvent( new CClubEvent( CClubEvent.SEND_LUCKY_BAG_RESPONSE , response ) );

    }

    /*福袋记录信息响应*/
    private final function _onLuckyBagRecordResponseHandler( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        if ( isError ) return;
        var response : LuckyBagRecordResponse = message as LuckyBagRecordResponse;
        if ( response.type == CClubConst.CLUB_BAG_LIST ) {
            _pClubManager.updateSystemBagLogList( response.recordList );
            system.dispatchEvent( new CClubEvent( CClubEvent.SYETEM_LUCKY_BAG_RECORD_RESPONSE ) );
        } else if ( response.type == CClubConst.USER_BAG_LIST || response.type == CClubConst.RECHARGE_BAG_LIST) {
            _pClubManager.updatesingleUserBagLogList( response.recordList );
            system.dispatchEvent( new CClubEvent( CClubEvent.SINGLE_LUCKY_BAG_RECORD_RESPONSE ) );
        }
    }

    /*发福袋排行榜响应*/
    private final function _onSendLuckyBagRankResponseHandler( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        if ( isError ) return;
        var response : SendLuckyBagRankResponse = message as SendLuckyBagRankResponse;
        _pClubManager.updateUserSendBagRankList( response.rankMap );
        system.dispatchEvent( new CClubEvent( CClubEvent.SEND_LUCKY_BAG_RANK_RESPONSE, response ) );
    }

    /*玩家福袋记录响应*/
    private final function _onPlayerLuckyBagRecordResponseHandler( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        if ( isError ) return;
        var response : PlayerLuckyBagRecordResponse = message as PlayerLuckyBagRecordResponse;
        _pClubManager.updateSelfBagLog( response.playerRecordList );
    }

    /*玩家俱乐部信息 登录请求*/
    private final function _onClubInfoMessageResponseHandler( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        if ( isError ) return;
        var response : ClubInfoMessageResponse = message as ClubInfoMessageResponse;
        _pClubManager.clubID = response.clubInfoMap.clubID;
        _pClubManager.clubLevel = response.clubInfoMap.clubLevel;
        _pClubManager.clubName = response.clubInfoMap.clubName;

    }

    /*新会长变更提示（只对新会长发）在主城弹*/
    private final function _onClubChairmanChangeResponseHandler( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        if ( isError ) return;
        var response : ClubChairmanChangeResponse = message as ClubChairmanChangeResponse;

        _instanceSystem.callWhenInMainCity( showRewardViewHandler, [ response ], null, null, 9999 );

    }

    /*俱乐部信息（即时通知）*/
    private final function _onClubMessageResponseHandler( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        if ( isError ) return;
        var response : ClubMessageResponse = message as ClubMessageResponse;

        // type //响应类型 1 审核列表更新，2俱乐部申请通过 3有新的福袋 4俱乐部等级变化
        system.dispatchEvent( new CClubEvent( CClubEvent.CLUB_MSG_RESPONSE, response.type ) );

    }

    /*俱乐部发布邀请*/
    private final function _onClubInvitationResponseHandler( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        if ( isError ) return;
        var response : ClubInvitationResponse = message as ClubInvitationResponse;
        _pClubManager.nextInviteTime = response.nextInviteTime;
        system.dispatchEvent( new CClubEvent( CClubEvent.CLUB_INVITATION_RESPONSE ) );

    }

    ////////////////////////俱乐部小玩法////////////////////
    /*俱乐部小玩法信息*/
    private final function _onClubGameInfoResponseHandler( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        if ( isError ) return;
        var response : ClubGameInfoResponse = message as ClubGameInfoResponse;
        _pClubManager.latticeNumber = response.dateMap.latticeNumber;
        _pClubManager.oldLatticeNumber = _pClubManager.latticeNumber.concat();
        _pClubManager.totalBuyResetCounts = response.dateMap.totalBuyResetCounts;
        _pClubManager.buyResetCounts = response.dateMap.buyResetCounts;
        _pClubManager.playGameCounts = response.dateMap.playGameCounts;
        _pClubManager.resetCounts = response.dateMap.resetCounts;
        _pClubManager.bestPlayerName = response.bestPlayerName;
        _pClubManager.maxBestPlayCounts = response.maxBestPlayCounts;
        _pClubManager.skipAnimationSetting = response.dateMap.skipAnimationSetting;
        if(_initDic["ClubGameInfo"]) //初始化的时候只是请求了数据
            system.dispatchEvent( new CClubEvent( CClubEvent.CLUB_GAME_INFO_REQUEST ) );
        //=============================add by Lune 0710=========================
        _initDic["ClubGameInfo"] = true;
        system.dispatchEvent( new CClubEvent( CClubEvent.CLUB_RED_POINT ) );//刷新主界面红点
    }
    /*俱乐部小玩法结果*/
    private final function _onPlayClubGameResponseHandler( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        if ( isError ) return;
        var response : PlayClubGameResponse = message as PlayClubGameResponse;
        _pClubManager.latticeNumber = response.dateMap.latticeNumber;
        if( response.type == ClubGameConst.ALL_TURN )
            _pClubManager.oldLatticeNumber = _pClubManager.latticeNumber.concat();
        _pClubManager.totalBuyResetCounts = response.dateMap.totalBuyResetCounts;
        _pClubManager.buyResetCounts = response.dateMap.buyResetCounts;
        _pClubManager.playGameCounts = response.dateMap.playGameCounts;
        _pClubManager.resetCounts = response.dateMap.resetCounts;
        _pClubManager.bestPlayerName = response.bestPlayerName;
        _pClubManager.maxBestPlayCounts = response.maxBestPlayCounts;
        system.dispatchEvent( new CClubEvent( CClubEvent.PLAY_CLUB_GAME_RESPONSE ,response.type ) );
        //=============================add by Lune 0710=========================
        system.dispatchEvent( new CClubEvent( CClubEvent.CLUB_RED_POINT ) );//刷新主界面红点
    }
    /*获取奖励响应（见好就收）*/
    private final function _onGetClubGameRewardResponseHandler( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        if ( isError ) return;
        var response : GetClubGameRewardResponse = message as GetClubGameRewardResponse;
        _pClubManager.latticeNumber = response.latticeNumber;
        _pClubManager.buyResetCounts = 0;
        system.dispatchEvent( new CClubEvent( CClubEvent.GET_CLUBGAME_REWARD_RESPONSE ) );
    }


    /*充值福袋信息*/
    private final function _onRechargeLuckyBagResponseHandler( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        if ( isError ) return;
        _pClubManager.rechargeLuckyBagAry = [];
        var rechargeLuckyBagResponse : RechargeLuckyBagResponse = message as RechargeLuckyBagResponse;
        var bagObj : Object;
        var i : int;
        if( rechargeLuckyBagResponse.rechargeLuckyBagBig > 0 ){
            for( i = 0 ; i < rechargeLuckyBagResponse.rechargeLuckyBagBig ; i++ ){
                bagObj = new Object();
                bagObj.bagType = CClubConst.BAG_RECHARGE_BIG;
                bagObj.configType = 12;
                _pClubManager.rechargeLuckyBagAry.push( bagObj );
            }

        }
        if( rechargeLuckyBagResponse.rechargeLuckyBagMid > 0 ){
            for( i = 0 ; i < rechargeLuckyBagResponse.rechargeLuckyBagMid ; i++ ){
                bagObj = new Object();
                bagObj.bagType = CClubConst.BAG_RECHARGE_MID;
                bagObj.configType = 11;
                _pClubManager.rechargeLuckyBagAry.push( bagObj );
            }

        }
        if( rechargeLuckyBagResponse.rechargeLuckyBagSmall > 0 ){
            for( i = 0 ; i < rechargeLuckyBagResponse.rechargeLuckyBagSmall ; i++ ){
                bagObj = new Object();
                bagObj.bagType = CClubConst.BAG_RECHARGE_SMALL;
                bagObj.configType = 10;
                _pClubManager.rechargeLuckyBagAry.push( bagObj );
            }

        }

        system.dispatchEvent( new CClubEvent( CClubEvent.CLUB_BAG_RECHARGE_RESPONSE ) );
    }



    /*充值福袋感谢协议*/
    private final function _onThanksRechargeLuckyBagResponseHandler( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        if ( isError ) return;
        var thanksRechargeLuckyBagResponse : ThanksRechargeLuckyBagResponse = message as ThanksRechargeLuckyBagResponse;
        var thanksmessageTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.THANKSMESSAGE );
        var thanksMessage : ThanksMessage = thanksmessageTable.findByPrimaryKey( thanksRechargeLuckyBagResponse.thanksMessageId );
        if( !thanksMessage )
                return;
        var contentStr : String = thanksMessage.content;
        var replaceKey : String;
        for ( var i : int = 0; i < thanksRechargeLuckyBagResponse.content.length; i++ ) {
            replaceKey = "{" + i + "}";
            contentStr = contentStr.replace( replaceKey, thanksRechargeLuckyBagResponse.content[ i ] );
        }

        var taskTargetStr : String = HtmlUtil.hrefAndU( thanksMessage.linkWord, CChatLinkConst.CLUB_BAG, "#ff8282" );
        contentStr = contentStr.replace( thanksMessage.linkWord, taskTargetStr );

        _pChatSystem.broadcastMessage( CChatChannel.GUILD, contentStr, CChatType.CLUB_RECHARGE_BAG_INVITATION );
    }

    private function get _playerSystem() : CPlayerSystem {
        return system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }
    private function get _pChatSystem():CChatSystem{
        return  system.stage.getSystem( CChatSystem ) as CChatSystem;
    }



    ////////////////////////////////////////////////////////////

    private function showRewardViewHandler( response : ClubChairmanChangeResponse ) : void {
        _pCUISystem.showMsgAlert( response.content, CMsgAlertHandler.NORMAL );
    }

    private function get _pClubManager() : CClubManager {
        return system.getBean( CClubManager ) as CClubManager;
    }

    private function get _pCUISystem() : CUISystem {
        return system.stage.getSystem( CUISystem ) as CUISystem;
    }

    private function get _instanceSystem() : CInstanceSystem {
        return system.stage.getSystem( CInstanceSystem ) as CInstanceSystem;
    }

    private function get _pCDatabaseSystem() : CDatabaseSystem {
        return system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
    }
}
}
