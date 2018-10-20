//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/10/23.
 * Time: 15:22
 */
package kof.game.clubBoss.net {

import kof.framework.CAppSystem;
import kof.framework.INetworking;
import kof.game.clubBoss.CClubBossViewHandler;
import kof.game.clubBoss.datas.CCBDataManager;
import kof.game.clubBoss.enums.EClubBossEventType;
import kof.message.CAbstractPackMessage;
import kof.message.ClubBoss.ClubBossActivityStartResponse;
import kof.message.ClubBoss.ClubBossInfoResponse;
import kof.message.ClubBoss.ClubBossRemainderHPPercentResponse;
import kof.message.ClubBoss.ClubBossReviveRequest;
import kof.message.ClubBoss.ClubBossReviveResponse;
import kof.message.ClubBoss.ClubBossRewardInfoResponse;
import kof.message.ClubBoss.ClubBossStartFightResponse;
import kof.message.ClubBoss.ClubBossTimeResponse;
import kof.message.ClubBoss.DamageRewardRequest;
import kof.message.ClubBoss.DamageRewardResponse;
import kof.message.ClubBoss.IfGotDamageRewardRequest;
import kof.message.ClubBoss.IfGotDamageRewardResponse;
import kof.message.ClubBoss.JoinClubBossRequest;
import kof.message.ClubBoss.JoinClubBossResponse;
import kof.message.ClubBoss.QueryClubBossInfoRequest;
import kof.message.ClubBoss.QueryClubBossInfoResponse;
import kof.message.ClubBoss.SetClubBossRequest;
import kof.message.ClubBoss.SetClubBossResponse;

/**
 * @author yili(guoyiligo@qq.com)
 * 2017/10/23
 */
public class CCBNet {
    private var _pNetwork : INetworking = null;
    private var _pCBDataManager : CCBDataManager = null;
    private var _pSystem:CAppSystem;

    public function set cbDataManager( value : CCBDataManager ) : void {
        this._pCBDataManager = value;
    }

    public function CCBNet( network : INetworking ) {
        this._pNetwork = network;
        _init();
    }

    private function _init() : void {
        this._pNetwork.bind( QueryClubBossInfoResponse ).toHandler( _queryClubBossInfoResponse );//主界面响应
        this._pNetwork.bind( ClubBossTimeResponse ).toHandler( _clubBossTimeResponse );//boss时间响应
        this._pNetwork.bind( SetClubBossResponse ).toHandler( _setClubBossResponse );//布阵响应
        this._pNetwork.bind( DamageRewardResponse ).toHandler( _damageRewardResponse );//领取参与奖励响应
        this._pNetwork.bind( IfGotDamageRewardResponse ).toHandler( _ifGotDamageRewardResponse );//是否可以领取
        this._pNetwork.bind( ClubBossActivityStartResponse ).toHandler( _onActivityStartResponseHandler );//活动开始推送

        //战斗相关
        this._pNetwork.bind( JoinClubBossResponse ).toHandler( _joinClubBossResponse );//参与工会boss封印响应
        this._pNetwork.bind( ClubBossInfoResponse ).toHandler( _clubBossInfoResponse );//工会boss场内信息响应
        this._pNetwork.bind( ClubBossReviveResponse ).toHandler( _clubBossReviveResponse );//复活响应
        this._pNetwork.bind( ClubBossRewardInfoResponse ).toHandler( _clubBossRewardInfoResponse );//封印成功结算面板
        this._pNetwork.bind( ClubBossRemainderHPPercentResponse ).toHandler( _clubBossRemainderHPPercentResponse );//工会boss血量百分比聊天推送
        this._pNetwork.bind( ClubBossStartFightResponse ).toHandler( _clubBossStartFightResponse );//工会boss开战响应
    }

    //查询是否可以领取参与奖励响应
    private function _ifGotDamageRewardResponse( net : INetworking, message : CAbstractPackMessage ) : void {
        var response : IfGotDamageRewardResponse = message as IfGotDamageRewardResponse;
        _pCBDataManager.setQueryCanGetReward( response );
        _pCBDataManager.dispatchEvent( EClubBossEventType.CAN_GET_REWARD );
    }

    //领取参与奖励响应
    private function _damageRewardResponse( net : INetworking, message : CAbstractPackMessage ) : void {
        var response : DamageRewardResponse = message as DamageRewardResponse;
        _pCBDataManager.setDamageReward( response );
        _pCBDataManager.dispatchEvent(EClubBossEventType.GET_JOIN_REWARD);
    }

    //布阵响应
    private function _setClubBossResponse( net : INetworking, message : CAbstractPackMessage ) : void {
        var response : SetClubBossResponse = message as SetClubBossResponse;
        _pCBDataManager.setClubBoss( response );
        _pCBDataManager.dispatchEvent(EClubBossEventType.SET_EMBATTLE);
    }

    //时间响应
    private function _clubBossTimeResponse( net : INetworking, message : CAbstractPackMessage ) : void {
        var response : ClubBossTimeResponse = message as ClubBossTimeResponse;
        _pCBDataManager.setTimeInfo( response );
        _pCBDataManager.dispatchEvent(EClubBossEventType.UPDATE_TIME);
    }

    //主界面响应
    private function _queryClubBossInfoResponse( net : INetworking, message : CAbstractPackMessage ) : void {
        var response : QueryClubBossInfoResponse = message as QueryClubBossInfoResponse;
        _pCBDataManager.setMainUIInfo( response );
        _pCBDataManager.dispatchEvent( EClubBossEventType.UPDATE_MAINUI );
    }

    /**请求工会boss主界面*/
    public function queryClubBossInfoRequest() : void {
        var queryReq : QueryClubBossInfoRequest = new QueryClubBossInfoRequest();
        queryReq.flag = 1;
        _pNetwork.post( queryReq );
    }

    /**布阵请求*/
    public function setClubBossRequest( bossId : Number, heroId : Number ) : void {
        var queryReq : SetClubBossRequest = new SetClubBossRequest();
        queryReq.bossId = bossId;
        queryReq.heroId = heroId;
        _pNetwork.post( queryReq );
    }
    /**下阵请求*/
    public function unloadHeroRequest(bossId:Number):void{
        var queryReq : SetClubBossRequest = new SetClubBossRequest();
        queryReq.bossId = bossId;
        queryReq.heroId = 0;
        _pNetwork.post( queryReq );
    }
    /**查询参与奖励*/
    public function ifGotDamageRewardRequest():void{
        var queryReq : IfGotDamageRewardRequest = new IfGotDamageRewardRequest();
        queryReq.flag = 1;
        _pNetwork.post( queryReq );
    }

    /**领取参与奖励*/
    public function damageRewardRequest(bossId:int) : void {
        var queryReq : DamageRewardRequest = new DamageRewardRequest();
        queryReq.bossId = bossId;
        _pNetwork.post( queryReq );
    }

    //战斗相关
    /**请求参与工会boss封印*/
    public function joinClubBossRequest(bossId:int) : void {
        var queryReq : JoinClubBossRequest = new JoinClubBossRequest();
        queryReq.bossId = bossId;
        _pNetwork.post( queryReq );
    }

    /**复活请求*/
    public function clubBossReviveRequest() : void {
        var queryReq : ClubBossReviveRequest = new ClubBossReviveRequest();
        queryReq.flag = 1;
        _pNetwork.post( queryReq );
    }

    //请求封印boss响应
    private function _joinClubBossResponse( net : INetworking, message : CAbstractPackMessage ) : void {
        var response : JoinClubBossResponse = message as JoinClubBossResponse;
        _pCBDataManager.setJoinFight( response );
        _pCBDataManager.dispatchEvent(EClubBossEventType.JOIN_BATTALE);
    }

    //公会boss场内信息响应
    private function _clubBossInfoResponse( net : INetworking, message : CAbstractPackMessage ) : void {
        var response : ClubBossInfoResponse = message as ClubBossInfoResponse;
        _pCBDataManager.setBossInFight( response );
        _pCBDataManager.dispatchEvent(EClubBossEventType.IN_BATTLE_INFO);
    }

    //**公会boss复活响应*/
    private function _clubBossReviveResponse( net : INetworking, message : CAbstractPackMessage ) : void {
        var response : ClubBossReviveResponse = message as ClubBossReviveResponse;
        _pCBDataManager.setRevive( response );
        _pCBDataManager.dispatchEvent(EClubBossEventType.REVIVE);
    }

    //**封印成功结算面板响应*/
    private function _clubBossRewardInfoResponse( net : INetworking, message : CAbstractPackMessage ) : void {
        var response : ClubBossRewardInfoResponse = message as ClubBossRewardInfoResponse;
        _pCBDataManager.setRewardResult( response );
        _pCBDataManager.dispatchEvent(EClubBossEventType.RESULT_REWARD);
    }

    //**工会boss血量百分比*/
    private function _clubBossRemainderHPPercentResponse( net : INetworking, message : CAbstractPackMessage ) : void {
        var response : ClubBossRemainderHPPercentResponse = message as ClubBossRemainderHPPercentResponse;
        response.percent;

        //八杰出来袭，微丝 剩余 80% 血量啦！前往挑战
    }

    //**工会boss开战*/
    private function _clubBossStartFightResponse( net : INetworking, message : CAbstractPackMessage ) : void {
        var response : ClubBossStartFightResponse = message as ClubBossStartFightResponse;
        _pCBDataManager.setStartFight( response );
        _pCBDataManager.dispatchEvent(EClubBossEventType.START_FIGHT);
    }

    private function _onActivityStartResponseHandler(net : INetworking, message : CAbstractPackMessage):void
    {
//        _pCBDataManager.dispatchEvent(EClubBossEventType.ACTIVITY_START);
        var view:CClubBossViewHandler = _pSystem.getHandler(CClubBossViewHandler) as CClubBossViewHandler;
        if(view && view.isViewShow)
        {
            queryClubBossInfoRequest();
        }
    }


    public function get system() : CAppSystem {
        return _pSystem;
    }

    public function set system( value : CAppSystem ) : void {
        _pSystem = value;
    }
}
}
