//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Lune on 2018/5/22.
 */
package kof.game.bossChallenge {

import QFLib.Foundation.CTime;

import flash.utils.Dictionary;
import kof.framework.INetworking;
import kof.game.bossChallenge.view.CBossChallengeEmbattle;
import kof.game.bossChallenge.view.CBossChallengeInvitationView;
import kof.game.bossChallenge.view.CBossChallengeMainView;
import kof.game.bossChallenge.view.CBossChallengeVictoryView;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.system.CNetHandlerImp;
import kof.game.instance.CInstanceSystem;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.message.CAbstractPackMessage;
import kof.message.CooperationBoss.CooperationBossChallengeRequest;
import kof.message.CooperationBoss.CooperationBossChallengeResponse;
import kof.message.CooperationBoss.CooperationBossClubHelpRequest;
import kof.message.CooperationBoss.CooperationBossClubHelpResponse;
import kof.message.CooperationBoss.CooperationBossConfirmHelpResponse;
import kof.message.CooperationBoss.CooperationBossCreateRequest;
import kof.message.CooperationBoss.CooperationBossCreateResponse;
import kof.message.CooperationBoss.CooperationBossDeleteRequest;
import kof.message.CooperationBoss.CooperationBossInviteRejectResponse;
import kof.message.CooperationBoss.CooperationBossInviteRequest;
import kof.message.CooperationBoss.CooperationBossInviteResponse;
import kof.message.CooperationBoss.CooperationBossRecvInviteRequest;
import kof.message.CooperationBoss.CooperationBossRecvInviteResponse;
import kof.message.CooperationBoss.CooperationBossRejectInviteRequest;
import kof.message.CooperationBoss.CooperationBossResultResponse;
import kof.message.CooperationBoss.CooperationBossSetHeroRequest;
import kof.message.CooperationBoss.CooperationBossSetHeroResponse;
import kof.message.Instance.ExitInstanceRequest;
import kof.message.Instance.ExitInstanceResponse;
import kof.ui.CUISystem;

public class CBossChallengeNetHandler extends CNetHandlerImp {

    public function CBossChallengeNetHandler() {
        super();
    }

    override public function dispose() : void {
        super.dispose();
    }

    override protected function onSetup() : Boolean {
        super.onSetup();
        this.bind( CooperationBossCreateResponse, _createRoomResponse );
        this.bind( CooperationBossClubHelpResponse,_clubHelpResponse);
        this.bind( CooperationBossInviteResponse,_inviteResponse);
        this.bind( CooperationBossRecvInviteResponse, _receiveInviteResponse );
        this.bind( CooperationBossChallengeResponse, _bossChallengeResponse );
        this.bind( CooperationBossConfirmHelpResponse, _confirmHelpResponse );
        this.bind( CooperationBossSetHeroResponse, _setHeroResponse );
        this.bind( CooperationBossInviteRejectResponse,_confirmRefuseResponse );
        this.bind( CooperationBossResultResponse,_bossChallengeResultResponse );
        this.bind(ExitInstanceResponse, _onExitInstanceResponse );
        return true;
    }

0
    /**
     * 请求创建房间
     */
    public function createRoomRequest( bossID : int ) : void {
        var request : CooperationBossCreateRequest = new CooperationBossCreateRequest();
        request.bossID = bossID;
        networking.post( request );
    }

    private final function _createRoomResponse( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        var response : CooperationBossCreateResponse = message as CooperationBossCreateResponse;
        if(response.fightHeroID > 0)
        {
            var heroData:CPlayerHeroData = _playerData.heroList.getHero(response.fightHeroID);
            _challengeManager.recommendHero = heroData;//服务器返回上次使用的格斗家
        }
        _challengeManager.bossID = response.bossID;
        _mainView.refreshView();//请求返回刷新一下界面
    }

    /**
     * 请求关闭房间
     */
    public function dissolveRoomRequest( bossID : int ) : void {
        var request : CooperationBossDeleteRequest = new CooperationBossDeleteRequest();
        request.bossID = bossID;
        networking.post( request );
        _challengeManager.dispose();
    }

    /**
     * 发送好友邀请
     */
    public function inviteRequest( roleID : int, needPower : int ) : void {
        var request : CooperationBossInviteRequest = new CooperationBossInviteRequest();
        request.roleID = roleID;
        request.needBattleValue = needPower < 0 ? 0 : needPower;
        networking.post( request );
    }
    private final function _inviteResponse( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void
    {
        var response : CooperationBossInviteResponse = new CooperationBossInviteResponse();
        if(response.gamePromptID > 0)
        {
            var proStr : String = _challengeManager.getGamePromptStr( response.gamePromptID );
            if ( proStr != null ) {
                (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( proStr );
            }
        }
    }

    /**
     * 发送俱乐部请求
     */
    public function clubHelpRequest( value : int ) : void {
        var request : CooperationBossClubHelpRequest = new CooperationBossClubHelpRequest();
        request.needBattleValue = value;
        networking.post( request );
    }
    private final function _clubHelpResponse( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void
    {
        var response : CooperationBossClubHelpResponse = new CooperationBossClubHelpResponse();
        if(response.gamePromptID > 0)
        {
            var proStr : String = _challengeManager.getGamePromptStr( response.gamePromptID );
            if ( proStr != null ) {
                (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( proStr );
            }
        }
    }

    /**
     * 协助者接受邀请请求（来源公会）
     */
    public function receiveInviteRequest( marqueeData : Dictionary ) : void {
        //邀请者ID，bossID，战斗力
        var inviterRoleID : int = marqueeData[3];
        var bossID : int = marqueeData[4];
        var needBattleValue : int = marqueeData[2];
        if(inviterRoleID == _playerData.ID)
            return;
        var curTime : Number = CTime.getCurrServerTimestamp();//获取当前时间
        var showTime : Number = _challengeManager.constTable.LinkOverTime * 1000;
        if(curTime - marqueeData["time"] > showTime)
        {
            (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( "链接已失效" );
            return;
        }
        var request : CooperationBossRecvInviteRequest = new CooperationBossRecvInviteRequest();
        request.bossID = bossID;
        request.inviterRoleID = inviterRoleID;
        request.needBattleValue = needBattleValue;
        networking.post( request );
    }

    /**
     * 收到邀请返回
     */
    private final function _receiveInviteResponse( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        var response : CooperationBossRecvInviteResponse = message as CooperationBossRecvInviteResponse;
        var proStr : String;
        if(response.gamePromptID > 0)
        {
            proStr = _challengeManager.getGamePromptStr( response.gamePromptID );
            if ( proStr != null ) {
                (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( proStr );
                return;
            }
        }
        if(_inviteView.isOpen)    _inviteView.removeDisplay();
        if(_instance.isMainCity && response.bossID > 0)
        {
            var factor:Number = _challengeManager.getConstTableByBossID(response.bossID);//缩小系数
            _challengeManager.bossID = response.bossID;
            _challengeManager.needPower = response.needBattleValue/factor;
            _challengeManager.requesterName = response.name;
            _challengeManager.requesterID = response.inviterRoleID;
            _challengeManager.rewardCount = response.rewardCount;
            _challengeManager.isDirectInvite = response.directInvite;
            _inviteView.addDisplay();
        }
        else
        {
            proStr = _challengeManager.getGamePromptStr( 3609 );//不在主城中
            if ( proStr != null ) {
                (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( proStr );
                return;
            }
        }
        var bundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        var bundle : ISystemBundle =  bundleCtx.getSystemBundle( _challengeSystem.bundleID );
        var marqueeData : Dictionary = bundleCtx.getUserData(bundle, CBundleSystem.MARQUEE_DATA);//用来打开界面的公告信息
        if(marqueeData && marqueeData[3] == response.inviterRoleID)
        {
            bundleCtx.setUserData( bundle, CBundleSystem.MARQUEE_DATA, null );//置空公告中携带的数据
        }

    }

    /**
     * 协助者上阵格斗家请求
     */
    public function setHeroRequest( inviteID : int, bossID : int, heroID : int ) : void {
        var request : CooperationBossSetHeroRequest = new CooperationBossSetHeroRequest();
        request.inviterRoleID = inviteID;
        request.bossID = bossID;
        request.heroID = heroID;
        networking.post( request );
    }

    /**
     * 协助者上阵成功返回
     */
    private final function _setHeroResponse( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        var response : CooperationBossSetHeroResponse = message as CooperationBossSetHeroResponse;
        if ( response.gamePromptID == 0 ) {
            _inviteView.removeDisplay();
        }
        var proStr : String = _challengeManager.getGamePromptStr( response.gamePromptID );
        if ( proStr != null ) {
            (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( proStr );
        }
    }
    /**
     * 拒绝邀请
     */
    public function refuseInviteRequest( inviteID : int, bossID : int ) : void {
        var request : CooperationBossRejectInviteRequest = new CooperationBossRejectInviteRequest();
        request.inviterRoleID = inviteID;
        request.bossID = bossID;
        networking.post( request );
    }

    /**
     * 邀请者收到拒绝
     */
    private final function _confirmRefuseResponse( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        var response : CooperationBossInviteRejectResponse = message as CooperationBossInviteRejectResponse;
        (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( response.rejectorName + "拒绝了你的邀请" );
    }

    /**
     * 邀请者收到协助
     */
    private final function _confirmHelpResponse( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        var response : CooperationBossConfirmHelpResponse = message as CooperationBossConfirmHelpResponse;
        _challengeManager.setHelperData( response.cooperatorRoleID, response.cooperatorName, response.cooperatorHeroID, response.cooperatorBattleValue,response.cooperatorHeroStar );
        _mainView.refreshView();
        _embattle.refreshView();
    }

    /**
     * 发起挑战请求
     */
    public function bossChallengeRequest( heroID : int ) : void {
        var request : CooperationBossChallengeRequest = new CooperationBossChallengeRequest();
        request.heroID = heroID;
        networking.post( request );
    }
    private final function _bossChallengeResponse( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void
    {
        var response : CooperationBossChallengeResponse = message as CooperationBossChallengeResponse;
        if(response.gamePromptID > 0)
        {
            var proStr : String = _challengeManager.getGamePromptStr( response.gamePromptID );
            if ( proStr != null ) {
                (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( proStr );
                return;
            }
        }
        _mainView.removeDisplay();
        _embattle.removeDisplay();
    }

    /**
     * 请求离开副本
     */
    public function sendExitInstance(flag:Boolean) : void
    {
        var exitInstanceRequest : ExitInstanceRequest = new ExitInstanceRequest();
        exitInstanceRequest.flag = flag;
        networking.post( exitInstanceRequest );
    }


    private final function _bossChallengeResultResponse( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void
    {
        var response : CooperationBossResultResponse = message as CooperationBossResultResponse;
        var data:Object = new Object();//记录结算数据
        data["win"] = response.win;
        data["selfHeroID"] = response.selfHeroID;
        data["selfRewards"]  = response.selfRewards;
        data["cooperateName"]  = response.cooperateName;
        data["cooperateHeroID"]  = response.cooperateHeroID;
        data["cooperateRewards"]  = response.cooperateRewards;
        data["cooperateDP"]  = response.cooperateDP;
        _challengeManager.setResultData(data);
        _challengeSystem.instanceOver();// 显示结算界面
    }
    private final function _onExitInstanceResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void
    {
        if(_victoryView.isOpen)
            _victoryView.removeDisplay();
    }
    private function get _challengeSystem() : CBossChallengeSystem
    {
        return system as CBossChallengeSystem;
    }
    private function get _challengeManager() : CBossChallengeManager
    {
        return system.getBean( CBossChallengeManager ) as CBossChallengeManager;
    }
    private function get _inviteView() : CBossChallengeInvitationView
    {
        return system.getBean( CBossChallengeInvitationView ) as CBossChallengeInvitationView;
    }
    private function get _mainView() : CBossChallengeMainView
    {
        return system.getBean( CBossChallengeMainView ) as CBossChallengeMainView;
    }
    private function get _embattle() : CBossChallengeEmbattle
    {
        return system.getBean( CBossChallengeEmbattle ) as CBossChallengeEmbattle;
    }
    private function get _victoryView() : CBossChallengeVictoryView
    {
        return system.getBean( CBossChallengeVictoryView ) as CBossChallengeVictoryView;
    }
    private function get _playerData() : CPlayerData
    {
        return (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
    }
    private function get _instance() : CInstanceSystem
    {
        return system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
    }
}
}
