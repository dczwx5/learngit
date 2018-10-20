//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/7/28.
 * Time: 10:26
 */
package kof.game.globalBoss.net {

    import kof.framework.INetworking;
    import kof.game.globalBoss.datas.CWBDataManager;
    import kof.message.CAbstractPackMessage;
    import kof.message.WorldBoss.DrawBossTreasureRequest;
    import kof.message.WorldBoss.DrawBossTreasureResponse;
    import kof.message.WorldBoss.ErrorCodeResponse;
    import kof.message.WorldBoss.GainTotalTreasureRequest;
    import kof.message.WorldBoss.JoinWorldBossRequest;
    import kof.message.WorldBoss.JoinWorldBossResponse;
    import kof.message.WorldBoss.QueryWorldBossInfoRequest;
    import kof.message.WorldBoss.QueryWorldBossInfoResponse;
    import kof.message.WorldBoss.QueryWorldBossTreasureInfoRequest;
    import kof.message.WorldBoss.QueryWorldBossTreasureInfoResponse;
    import kof.message.WorldBoss.RefreshVirtualPlayerResponse;
    import kof.message.WorldBoss.ReviveRequest;
    import kof.message.WorldBoss.ReviveResponse;
    import kof.message.WorldBoss.RoleFightStateResponse;
    import kof.message.WorldBoss.WorldBossInfoResponse;
    import kof.message.WorldBoss.WorldBossInspireRequest;
    import kof.message.WorldBoss.WorldBossInspireResponse;
    import kof.message.WorldBoss.WorldBossRemainderHPPercentResponse;
    import kof.message.WorldBoss.WorldBossRewardInfoResponse;
    import kof.message.WorldBoss.WorldBossStartFightResponse;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/7/28
     */
    public class CWBNet {
        private var _pNetwork : INetworking = null;
        private var _pWBDataManager : CWBDataManager = null;

        public function CWBNet( network : INetworking ) {
            this._pNetwork = network;
            _init();
        }

        public function set WBDataManager( value : CWBDataManager ) : void {
            this._pWBDataManager = value;
        }

        private function _init() : void {
            this._pNetwork.bind( QueryWorldBossInfoResponse ).toHandler( _queryWorldBossInfoResponse );
            this._pNetwork.bind( QueryWorldBossTreasureInfoResponse ).toHandler( _queryWorldBossTreasureInfoResponse );
            this._pNetwork.bind( DrawBossTreasureResponse ).toHandler( _drawBossTreasureResponse );
            this._pNetwork.bind( JoinWorldBossResponse ).toHandler( _joinWorldBossResponse );
            this._pNetwork.bind( WorldBossInfoResponse ).toHandler( _worldBossInfoResponse );
            this._pNetwork.bind( ReviveResponse ).toHandler( _reviveResponse );
            this._pNetwork.bind( WorldBossRewardInfoResponse ).toHandler( _worldBossRewardInfoResponse );
            this._pNetwork.bind( RefreshVirtualPlayerResponse ).toHandler( _refreshVirtualPlayerResponse );
            this._pNetwork.bind( WorldBossInspireResponse ).toHandler( _worldBossInspireResponse );
            this._pNetwork.bind( RoleFightStateResponse ).toHandler( _roleFightStateResponse );
            this._pNetwork.bind( WorldBossRemainderHPPercentResponse ).toHandler( _worldBossRemainderHPPercentResponse );
            this._pNetwork.bind( WorldBossStartFightResponse ).toHandler( _worldBossStartFightResponse );
            this._pNetwork.bind( ErrorCodeResponse ).toHandler( _errorCodeResponse );
        }

        private function _errorCodeResponse( net : INetworking, message : CAbstractPackMessage ) : void {
            var response : ErrorCodeResponse = message as ErrorCodeResponse;
            _pWBDataManager.showGamePrompt( response.id , response.contents);
        }

        //开始战斗响应
        private function _worldBossStartFightResponse( net : INetworking, message : CAbstractPackMessage ) : void {
            var response : WorldBossStartFightResponse = message as WorldBossStartFightResponse;
            _pWBDataManager.startFight( response );
        }

        // 世界boss血量百分比聊天频道推送
        private function _worldBossRemainderHPPercentResponse( net : INetworking, message : CAbstractPackMessage ) : void {

        }

        // 玩家是否在世界boss中状态变化
        private function _roleFightStateResponse( net : INetworking, message : CAbstractPackMessage ) : void {
            var response : RoleFightStateResponse = message as RoleFightStateResponse;

        }

        //鼓舞响应
        private function _worldBossInspireResponse( net : INetworking, message : CAbstractPackMessage ) : void {
            var response : WorldBossInspireResponse = message as WorldBossInspireResponse;
            _pWBDataManager.updateInspire( response );
        }

        //刷新假人信息
        private function _refreshVirtualPlayerResponse( net : INetworking, message : CAbstractPackMessage ) : void {
            var response : RefreshVirtualPlayerResponse = message as RefreshVirtualPlayerResponse;
        }

        //封印成功结算面板 (奖励详情客户端读表)
        private function _worldBossRewardInfoResponse( net : INetworking, message : CAbstractPackMessage ) : void {
            var response : WorldBossRewardInfoResponse = message as WorldBossRewardInfoResponse;
            _pWBDataManager.updateRewardInfo( response );
        }

        //复活响应
        private function _reviveResponse( net : INetworking, message : CAbstractPackMessage ) : void {
            var response : ReviveResponse = message as ReviveResponse;
            _pWBDataManager.updateRevive( response );
        }

        //世界boss场内信息
        private function _worldBossInfoResponse( net : INetworking, message : CAbstractPackMessage ) : void {
            var response : WorldBossInfoResponse = message as WorldBossInfoResponse;
            _pWBDataManager.updateWorldBossInfo( response );
        }

        //世界boss主界面响应
        private function _queryWorldBossInfoResponse( net : INetworking, message : CAbstractPackMessage ) : void {
            var response : QueryWorldBossInfoResponse = message as QueryWorldBossInfoResponse;
            _pWBDataManager.updateOpenView( response );
        }

        //Boss探宝主界面响应
        private function _queryWorldBossTreasureInfoResponse( net : INetworking, message : CAbstractPackMessage ) : void {
            var response : QueryWorldBossTreasureInfoResponse = message as QueryWorldBossTreasureInfoResponse;
            _pWBDataManager.updateTreasureInfo( response );
        }

        //抽奖响应
        private function _drawBossTreasureResponse( net : INetworking, message : CAbstractPackMessage ) : void {
            var response : DrawBossTreasureResponse = message as DrawBossTreasureResponse;
            _pWBDataManager.updateDrawTreasure( response );
        }

        //参与世界Boss封印响应
        private function _joinWorldBossResponse( net : INetworking, message : CAbstractPackMessage ) : void {
            var response : JoinWorldBossResponse = message as JoinWorldBossResponse;
            _pWBDataManager.updateJoinFight( response );
        }

        //请求世界boss主界面
        public function queryWorldBossInfoRequest() : void {
            var queryReq : QueryWorldBossInfoRequest = new QueryWorldBossInfoRequest();
            queryReq.decode( [ 1 ] );
            _pNetwork.post( queryReq );
        }

        //请求Boss探宝主界面
        public function queryWorldBossTreasureInfoRequest() : void {
            var queryReq : QueryWorldBossTreasureInfoRequest = new QueryWorldBossTreasureInfoRequest();
            queryReq.decode( [ 1 ] );
            _pNetwork.post( queryReq );
        }

        //请求抽奖  (会同步发送1753响应)
        public function drawBossTreasureRequest() : void {
            var queryReq : DrawBossTreasureRequest = new DrawBossTreasureRequest();
            queryReq.decode( [ 1 ] );
            _pNetwork.post( queryReq );
        }

        //请求领取万能碎片 (会同步发送1753响应)
        public function gainTotalTreasureRequest() : void {
            var queryReq : GainTotalTreasureRequest = new GainTotalTreasureRequest();
            queryReq.decode( [ 1 ] );
            _pNetwork.post( queryReq );
        }

        //请求参与世界boss封印
        public function joinWorldBossRequest() : void {
            var queryReq : JoinWorldBossRequest = new JoinWorldBossRequest();
            queryReq.flag = 1;
            _pNetwork.post( queryReq );
        }

        //复活请求
        public function reviveRequest() : void {
            var queryReq : ReviveRequest = new ReviveRequest();
            queryReq.flag = 1;
            _pNetwork.post( queryReq );
        }

        /**发起鼓舞
         * @param 鼓舞类型， 0： 普通鼓舞， 1： 钻石鼓舞
         * */
        public function worldBossInspireRequest( type : int ) : void {
            var queryReq : WorldBossInspireRequest = new WorldBossInspireRequest();
            queryReq.tp = type;
            _pNetwork.post( queryReq );
        }


    }
}
