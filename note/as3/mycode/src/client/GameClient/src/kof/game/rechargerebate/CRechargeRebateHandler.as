//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by EDDY on 2018/1/4.
 */
package kof.game.rechargerebate {

import kof.framework.INetworking;
import kof.game.activityHall.CActivityHallDataManager;
import kof.game.activityHall.CActivityHallSystem;
import kof.game.activityHall.event.CActivityHallEvent;
import kof.game.common.system.CNetHandlerImp;
import kof.message.CAbstractPackMessage;
import kof.message.RechargeRebate.ReceiveRebateRewardRequest;
import kof.message.RechargeRebate.ReceiveRebateRewardResponse;
import kof.message.RechargeRebate.RechargeRebateInfoRequest;
import kof.message.RechargeRebate.RechargeRebateInfoResponse;

public class CRechargeRebateHandler extends CNetHandlerImp {

    public function CRechargeRebateHandler() {
        super();
    }

    override protected function onSetup():Boolean {
        var ret:Boolean = super.onSetup();

        this.bind(RechargeRebateInfoResponse, _onRechargeRebateInfoResponseHandler);
        this.bind(ReceiveRebateRewardResponse, _onReceiveRebateRewardResponseHandler);

        onRechargeRebateInfoRequest();

        return ret;
    }
    /**********************Request********************************/

    /*请求充值返钻信息*/
    public function onRechargeRebateInfoRequest( ):void{
        var request:RechargeRebateInfoRequest = new RechargeRebateInfoRequest();
        request.decode([1]);

        networking.post(request);
    }
    /*请求充值范钻宝箱领取*/
    public function onReceiveRebateRewardRequest( chestNumber : int  ):void{
        var request:ReceiveRebateRewardRequest = new ReceiveRebateRewardRequest();
        request.decode([chestNumber]);

        networking.post(request);
    }

    /**********************Response********************************/

    /*请求充值返钻信息返回*/
    private final function _onRechargeRebateInfoResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if ( isError ) return;
        var response : RechargeRebateInfoResponse = message as RechargeRebateInfoResponse;
        _pRechargeRebateManager.blueDiamondExp = response.blueDiamondExp;
        _pRechargeRebateManager.receiveRebateRecord = response.receiveRebateRecord;
        system.dispatchEvent( new CRechargeRebateEvent( CRechargeRebateEvent.RECHARGE_REBATE_INFO_RESPONSE ,response));
        //=============add by Lune 0627======================================
        //用于收集活动开启预览数据
        var args : Object = new Object();
        args.sysID = _system.bundleID;
        args.state = 1;
        args.endTime = 0;
        if(_activityManager)
            _activityManager.updatePreviewDic(args);
        //=============add by Lune 0627======================================
        if( _pRechargeRebateManager.fristFlg ){
            _pRechargeRebateManager.fristFlg = false;
            return;
        }
        system.dispatchEvent( new CRechargeRebateEvent( CRechargeRebateEvent.SHOW_RECHARGE_REBATE_VIEW ,response));

    }
    /*充值范钻宝箱领取响应*/
    private final function _onReceiveRebateRewardResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if ( isError ) return;
        var response : ReceiveRebateRewardResponse = message as ReceiveRebateRewardResponse;
        _pRechargeRebateManager.blueDiamondExp = response.blueDiamondExp;
        _pRechargeRebateManager.receiveRebateRecord = response.receiveRebateRecord;

        system.dispatchEvent( new CRechargeRebateEvent( CRechargeRebateEvent.RECEIVE_REBATE_REWARD_RESPONSE ,response));
        _activityManager.checkHavePreviewData();
    }

    private function get _pRechargeRebateManager():CRechargeRebateManager{
        return system.getBean( CRechargeRebateManager ) as CRechargeRebateManager;
    }
    private function get _system() : CRechargeRebateSystem
    {
        return system as CRechargeRebateSystem;
    }
    private function get _activityManager() : CActivityHallDataManager
    {
        var _activitySystem : CActivityHallSystem = system.stage.getSystem(CActivityHallSystem) as CActivityHallSystem;
        if(!_activitySystem) return null;
        return _activitySystem.getBean(CActivityHallDataManager) as CActivityHallDataManager;
    }
}
}
