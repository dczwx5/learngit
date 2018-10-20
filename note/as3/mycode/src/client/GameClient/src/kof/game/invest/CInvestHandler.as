//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2018/1/3.
 */
package kof.game.invest {

import kof.framework.INetworking;
import kof.game.activityHall.CActivityHallDataManager;
import kof.game.activityHall.CActivityHallSystem;
import kof.game.common.system.CNetHandlerImp;
import kof.message.CAbstractPackMessage;
import kof.message.Invest.InvestDataRequest;
import kof.message.Invest.InvestDataResponse;
import kof.message.Invest.InvestObtainRewardRequest;
import kof.message.Invest.InvestObtainRewardResponse;
import kof.message.Invest.InvestRequest;
import kof.message.Invest.InvestResponse;

public class CInvestHandler extends CNetHandlerImp {
    public function CInvestHandler() {
        super();
    }

    override protected function onSetup():Boolean {
        var ret:Boolean = super.onSetup();

        this.bind(InvestDataResponse, _onInvestDataResponseHandler);
        this.bind(InvestResponse, _onInvestResponseHandler);
        this.bind(InvestObtainRewardResponse, _onInvestObtainRewardResponseHandler);

        onInvestDataRequest();

        return ret;
    }
    /**********************Request********************************/

    /*投资系统数据*/
    public function onInvestDataRequest( ):void{
        var request:InvestDataRequest = new InvestDataRequest();
        request.decode([1]);

        networking.post(request);
    }

    /*投入资金*/
    public function onInvestRequest( ):void{
        var request:InvestRequest = new InvestRequest();
        request.decode([1]);

        networking.post(request);
    }
    /*领取奖励*/
    public function onInvestObtainRewardRequest( id : int ):void{
        var request:InvestObtainRewardRequest = new InvestObtainRewardRequest();
        request.decode([id]);

        networking.post(request);
    }




    /**********************Response********************************/

    /*投资系统数据*/
    private final function _onInvestDataResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if ( isError ) return;
        var response : InvestDataResponse = message as InvestDataResponse;
        var args : Object = new Object();
        args.sysID = _system.bundleID;
        args.state = 1;
        args.endTime = 0;
        if(_activityManager)
            _activityManager.updatePreviewDic(args);
        //=============add by Lune 0627======================================
        //用于收集活动开启预览数据
        _pInvestManager.m_hasPut = response.hadPut;
        _pInvestManager.m_infos = response.infos;

        system.dispatchEvent( new CInvestEvent( CInvestEvent.INVEST_INIT_DATA_RESPONSE ,response));

        if( _pInvestManager.fristFlg ){
            _pInvestManager.fristFlg = false;
            return;
        }
        system.dispatchEvent( new CInvestEvent( CInvestEvent.SHOW_INVEST_VIEW ,response));
    }

    /*投入资金*/
    private final function _onInvestResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if ( isError ) return;
        var response : InvestResponse = message as InvestResponse;
        _pInvestManager.m_hasPut = response.hadPut;

        system.dispatchEvent( new CInvestEvent( CInvestEvent.INVEST_DATA_RESPONSE ,response));
    }

    /*领取奖励*/
    private final function _onInvestObtainRewardResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if ( isError ) return;
        var response : InvestObtainRewardResponse = message as InvestObtainRewardResponse;
        if( response.gamePromptID == 0 ){
            var obj : Object = {};
            obj.id = response.id;
            obj.obtained = true;
            _pInvestManager.m_infos.push( obj );
        }
        system.dispatchEvent( new CInvestEvent( CInvestEvent.INVEST_GET_AWARD_RESPONSE ,response));
    }

    private function get _pInvestManager() : CInvestManager{
        return system.getBean( CInvestManager ) as CInvestManager;
    }
    private function get _activityManager() : CActivityHallDataManager
    {
        var _activitySystem : CActivityHallSystem = system.stage.getSystem(CActivityHallSystem) as CActivityHallSystem;
        if(!_activitySystem) return null;
        return _activitySystem.getBean(CActivityHallDataManager) as CActivityHallDataManager;
    }
    private function get _system() : CInvestSystem
    {
        return system as CInvestSystem;
    }
}
}
