//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Lune on 2018/9/10.
 */
package kof.game.bargainCard {

import kof.framework.INetworking;
import kof.game.common.system.CNetHandlerImp;
import kof.game.lobby.CLobbySystem;
import kof.game.lobby.view.CPlayerHeadViewHandler;
import kof.message.CAbstractPackMessage;
import kof.message.CardMonth.BuyCardMonthResponse;
import kof.message.CardMonth.CardMonthInfoRequest;
import kof.message.CardMonth.CardMonthInfoResponse;
import kof.message.CardMonth.GetCardMonthRewardRequest;
import kof.message.CardMonth.GetCardMonthRewardResponse;

public class CBargainCardNetHandler extends CNetHandlerImp {
    public function CBargainCardNetHandler() {
        super();
    }
    override public function dispose() : void {
        super.dispose();
    }

    override protected function onSetup() : Boolean {
        super.onSetup();
        //this.bind(BuyCardMonthResponse, _ongBuyCardMonthResponseHandler);
        this.bind(CardMonthInfoResponse, _ongCardMonthInfoResponseHandler);
        this.bind(GetCardMonthRewardResponse, _onGetCardMonthRewardResponseHandler);
        onCardMonthInfoRequest();
        return true;
    }


    /*月卡信息请求*/
    public function onCardMonthInfoRequest( ):void{
        var request:CardMonthInfoRequest = new CardMonthInfoRequest();
        request.decode([1]);

        networking.post(request);
    }
    /*领取月卡奖励请求*/
    public function onGetCardMonthRewardRequest( type : int ):void{
        var request:GetCardMonthRewardRequest = new GetCardMonthRewardRequest();
        request.decode([type]);
        networking.post(request);
    }

//    /*购买月卡响应*/
//    private final function _ongBuyCardMonthResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
//        if ( isError ) return;
//        var response : BuyCardMonthResponse = message as BuyCardMonthResponse;
//        if( response.type == 1 ){
//            _pCUISystem.showMsgAlert('购买白银月卡成功！',CMsgAlertHandler.NORMAL );
//        }else if( response.type == 2 ){
//            _pCUISystem.showMsgAlert('购买黄金月卡成功！',CMsgAlertHandler.NORMAL );
//        }
//
//        onCardMonthInfoRequest();
//
//    }
    /*月卡信息响应*/
    private final function _ongCardMonthInfoResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if ( isError ) return;
        var response : CardMonthInfoResponse = message as CardMonthInfoResponse;
        _manager.responseData = response.dataMap;
        _mainView.updateView();
        var playerHead : CPlayerHeadViewHandler = system.stage.getSystem( CLobbySystem ).getBean( CPlayerHeadViewHandler ) as CPlayerHeadViewHandler;
        playerHead.invalidateData();


    }
    /*领取月卡奖励响应*/
    private final function _onGetCardMonthRewardResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if ( isError ) return;
        var response : GetCardMonthRewardResponse = message as GetCardMonthRewardResponse;
        _manager.responseData = response.dataMap;
        _mainView.updateView();
        var playerHead : CPlayerHeadViewHandler = system.stage.getSystem( CLobbySystem ).getBean( CPlayerHeadViewHandler ) as CPlayerHeadViewHandler;
        playerHead.invalidateData();

    }

    private function get _manager() : CBargainCardManager
    {
        return system.getBean(CBargainCardManager) as CBargainCardManager;
    }
    private function get _mainView() : CBargainCardView
    {
        return system.getBean(CBargainCardView) as CBargainCardView;
    }
}
}
