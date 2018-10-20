//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/6/1.
 * Time: 11:03
 */
package kof.game.sign.signFacade.signSystem.net {

    import kof.framework.INetworking;
    import kof.message.CAbstractPackMessage;
    import kof.message.SignIn.CommonSignInRequest;
    import kof.message.SignIn.GetTotalSignInDaysRewardRequest;
    import kof.message.SignIn.GetVipSingInRewardRequest;
    import kof.message.SignIn.GetVipSingInRewardResponse;
    import kof.message.SignIn.OpenSignInSystemRequest;
    import kof.message.SignIn.UpdateSignInSystemResponse;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/6/1
     */
    public class CSignNet {
        private var _netWork : INetworking = null;

        public function CSignNet() {
        }

        public function set network( value : INetworking ) : void {
            this._netWork = value;
            this._netWork.bind( UpdateSignInSystemResponse ).toHandler( _updateSignInSystemResponse );
        }

        //打开签到系统服务器响应数据
        private function _updateSignInSystemResponse( net : INetworking, message : CAbstractPackMessage ) : void {
            var response : UpdateSignInSystemResponse = message as UpdateSignInSystemResponse;
            CSignNetDataManager.getInstance().updateSignData( response );
        }

        //打开签到系统请求
        public function openSignInSystemRequest() : void {
            var signSysReq : OpenSignInSystemRequest = new OpenSignInSystemRequest();
            signSysReq.decode( [ 1 ] );
            _netWork.post( signSysReq );
        }

        //签到请求
        public function commonSignRequest() : void {
            var commonReq : CommonSignInRequest = new CommonSignInRequest();
            commonReq.decode( [ 1 ] );
            _netWork.post( commonReq );
        }

        //vip奖励请求
        public function getVipSignInRewardRequest() : void {
            var vipReq : GetVipSingInRewardRequest = new GetVipSingInRewardRequest();
            vipReq.decode( [ 1 ] );
            _netWork.post( vipReq );
        }

        /**
         * 累积签到奖励
         * @param days 领取多少天的累积奖励
         * */
        public function getTotalSignInDaysRewardRequest(days:int) : void {
            var totalSignReq : GetTotalSignInDaysRewardRequest = new GetTotalSignInDaysRewardRequest();
            totalSignReq.decode( [ days ] );
            _netWork.post( totalSignReq );
        }
    }
}
