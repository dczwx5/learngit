//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/7/17.
 * Time: 17:27
 */
package kof.game.hook.net {

    import kof.framework.INetworking;
    import kof.message.CAbstractPackMessage;
    import kof.message.HangUp.CancelHangUpRequest;
    import kof.message.HangUp.CancelHangUpResponse;
    import kof.message.HangUp.HangUpDropResponse;
    import kof.message.HangUp.HangUpExpResponse;
    import kof.message.HangUp.HangUpHeroRequest;
    import kof.message.HangUp.HangUpHeroResponse;
    import kof.message.HangUp.HangUpInfoRequest;
    import kof.message.HangUp.HangUpInfoResponse;
    import kof.message.HangUp.HangUpRequest;
    import kof.message.HangUp.HangUpResponse;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/7/17
     */
    public class CHookNet {
        private var _network : INetworking = null;

        public function CHookNet() {
        }

        public function get network() : INetworking {
            return _network;
        }

        public function set network( value : INetworking ) : void {
            this._network = value;
            this._network.bind( HangUpInfoResponse ).toHandler( _hangUpInfoResponse );
//            this._network.bind( HangUpHeroResponse ).toHandler( _hangUpHeroResponse );
//            this._network.bind( HangUpResponse ).toHandler( _hangUpResponse );
            this._network.bind( CancelHangUpResponse ).toHandler( _cancelHangUpResponse );
//            this._network.bind( HangUpExpResponse ).toHandler( _hangUpExpResponse );
//            this._network.bind( HangUpDropResponse ).toHandler( _hangUpDropResponse );
        }

        //打开挂机界面响应
        private function _hangUpInfoResponse( net : INetworking, message : CAbstractPackMessage ) : void {
            var response : HangUpInfoResponse = message as HangUpInfoResponse;
            CHookNetDataManager.instance.setHookInfoData( response );
        }

        //设置挂机格斗家响应
        private function _hangUpHeroResponse( net : INetworking, message : CAbstractPackMessage ) : void {
            var response : HangUpHeroResponse = message as HangUpHeroResponse;
            CHookNetDataManager.instance.setHookHeroSuccess(response);
        }

        //挂机响应
        private function _hangUpResponse( net : INetworking, message : CAbstractPackMessage ) : void {
            var response : HangUpResponse = message as HangUpResponse;
            CHookNetDataManager.instance.setHookSuccess(response);
        }

        //结束挂机响应
        private function _cancelHangUpResponse( net : INetworking, message : CAbstractPackMessage ) : void {
            var response : CancelHangUpResponse = message as CancelHangUpResponse;
            CHookNetDataManager.instance.setCancelHookData( response );
        }

        //英雄加经验响应
        private function _hangUpExpResponse( net : INetworking, message : CAbstractPackMessage ) : void {
            var response : HangUpExpResponse = message as HangUpExpResponse;
            CHookNetDataManager.instance.setHookGetExpData(response);
        }

        //英雄加道具响应
        private function _hangUpDropResponse( net : INetworking, message : CAbstractPackMessage ) : void {
            var response : HangUpDropResponse = message as HangUpDropResponse;
            CHookNetDataManager.instance.setHookGetDropData(response);
        }

        /**主界面请求*/
        public function hangUpInfoRequest() : void {
            var hangUpReq : HangUpInfoRequest = new HangUpInfoRequest();
            hangUpReq.decode( [ 1 ] );
            _network.post( hangUpReq );
        }

        /**挂机英雄编制设置请求*/
        public function hangUpHeroRequest( arr : Array ) : void {
            var hangUpReq : HangUpHeroRequest = new HangUpHeroRequest();
            hangUpReq.decode( [ arr ] );
            _network.post( hangUpReq );
        }

        /**挂机请求*/
//        public function hangUpRequest() : void {
//            var hangUpReq : HangUpRequest = new HangUpRequest();
//            hangUpReq.decode( [ 1 ] );
//            _network.post( hangUpReq );
//        }

        /**结束挂机请求*/
        public function cancelHangUpRequest() : void {
            var hangUpReq : CancelHangUpRequest = new CancelHangUpRequest();
            hangUpReq.decode( [ 1 ] );
            _network.post( hangUpReq );
        }
    }
}
