//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/9/21.
 */
package kof.game.welfarehall {

import kof.SYSTEM_ID;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.framework.INetworking;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CRewardUtil;
import kof.game.common.system.CNetHandlerImp;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardListData;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.reciprocation.CReciprocalSystem;
import kof.game.welfarehall.view.CAnnouncementState;
import kof.game.welfarehall.view.CRechargeWelfareViewHandler;
import kof.game.welfarehall.view.CWelfareHallViewHandler;
import kof.message.ActivationCode.ActivationCodeRequest;
import kof.message.ActivationCode.ActivationCodeResponse;
import kof.message.CAbstractPackMessage;
import kof.message.CardMonth.BuyCardMonthResponse;
import kof.message.CardMonth.CardMonthInfoResponse;
import kof.message.CardMonth.GetCardMonthRewardResponse;
import kof.message.ForeverRecharge.ForeverRechargeInfoRequest;
import kof.message.ForeverRecharge.ForeverRechargeInfoResponse;
import kof.message.ForeverRecharge.ReceiveRechargeRewardRequest;
import kof.message.ForeverRecharge.ReceiveRechargeRewardResponse;
import kof.message.Notice.AdvertisementListRequest;
import kof.message.Notice.AdvertisementListResponse;
import kof.message.Notice.AnnouncementListRequest;
import kof.message.Notice.AnnouncementListResponse;
import kof.message.Notice.GetUpdateRewardRequest;
import kof.message.Notice.GetUpdateRewardResponse;
import kof.message.Retrieve.GetRetrieveRewardRequest;
import kof.message.Retrieve.GetRetrieveRewardResponse;
import kof.message.Retrieve.RetrieveRewardInfoRequest;
import kof.message.Retrieve.RetrieveRewardInfoResponse;
import kof.table.GamePrompt;
import kof.table.RetrieveReward;
import kof.ui.CMsgAlertHandler;
import kof.ui.CUISystem;

public class CWelfareHallHandler extends CNetHandlerImp {
    public function CWelfareHallHandler() {
        super();
    }
    override protected function onSetup():Boolean {
        var ret:Boolean = super.onSetup();

        this.bind(ActivationCodeResponse, _onActivationCodeResponseHandler);
        this.bind(AnnouncementListResponse, _onAnnouncementListResponseHandler);
        this.bind(AdvertisementListResponse, _onAdvertisementListResponseHandler);
        this.bind(GetUpdateRewardResponse, _ongGetUpdateRewardResponse);
//        this.bind(BuyCardMonthResponse, _ongBuyCardMonthResponseHandler);
//        this.bind(CardMonthInfoResponse, _ongCardMonthInfoResponseHandler);
//        this.bind(GetCardMonthRewardResponse, _onGetCardMonthRewardResponseHandler);
        this.bind(ForeverRechargeInfoResponse, _foreverRechargeInfoResponse);
        this.bind(ReceiveRechargeRewardResponse, _receiveRechargeRewardResponse);
        this.bind(RetrieveRewardInfoResponse,_findRewardsDataResponse);
        this.bind(GetRetrieveRewardResponse,_findRewardsResponse);
        return ret;
    }
    /**********************Request********************************/

    /*激活码兑换请求*/
    public function onActivationCodeRequest( cid : String ):void{
        var request:ActivationCodeRequest = new ActivationCodeRequest();
        request.decode([cid]);

        networking.post(request);
    }

    /*请求永久充值福利信息*/
    public function foreverRechargeInfoRequest( info : int ):void{
        var request:ForeverRechargeInfoRequest = new ForeverRechargeInfoRequest();
        request.info = info;
        networking.post(request);
    }

    /*充值福利领取*/
    public function receiveRechargeRewardRequest( value : int ):void{
        var request:ReceiveRechargeRewardRequest = new ReceiveRechargeRewardRequest();
        request.rechargeValue = value;
        networking.post(request);
    }

    /**********************Response********************************/

    /*激活码兑换响应*/
    private final function _onActivationCodeResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;
        var response : ActivationCodeResponse = message as ActivationCodeResponse;
        if( response.ret == 0 ){//兑换成功
            var str : String; // 1直接获得 2邮件获得
            response.type == 2 ? str = '恭喜你兑换成功，请到邮箱领取奖励' :  str = '恭喜你兑换成功';
            _pCUISystem.showMsgAlert( str, CMsgAlertHandler.NORMAL );
            system.dispatchEvent( new CWelfareHallEvent( CWelfareHallEvent.ACTIVATION_CODE_RESPONSE ,response.rewardList ) );
        }else{
            _pCUISystem.showMsgAlert( response.msg , CMsgAlertHandler.WARNING );
        }
    }

    /**
     * 公告列表请求
     */
    public function announcementListRequest():void
    {
        var request:AnnouncementListRequest = new AnnouncementListRequest();
        request.type = 1;
        networking.post(request);
    }

    private function _onAnnouncementListResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void
    {
        if (isError) return ;
        var response : AnnouncementListResponse = message as AnnouncementListResponse;
        if(response)
        {
            (system.getHandler(CWelfareHallManager) as CWelfareHallManager).updateAnnouncementList(response);

            if(response.gamePromptID == 0)
            {
                // TODO
            }
            else
            {
                _showErrorMsg(response.gamePromptID);
            }
        }
    }

    /**
     * 广告列表请求
     */
    public function advertisementListRequest():void
    {
        var request:AdvertisementListRequest = new AdvertisementListRequest();
        request.type = 2;
        networking.post(request);
    }

    private function _onAdvertisementListResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void
    {
        if (isError) return ;
        var response : AdvertisementListResponse = message as AdvertisementListResponse;
        if(response)
        {
            (system.getHandler(CWelfareHallManager) as CWelfareHallManager).updateAdvertisementList(response);

            if(response.gamePromptID == 0)
            {
                // TODO
            }
            else
            {
                _showErrorMsg(response.gamePromptID);
            }
        }
    }

    /**
     * 领取公告奖励
     */
    public function getUpdateRewardRequest(id:String):void
    {
        CAnnouncementState.isInTakeReward = true;

        var request:GetUpdateRewardRequest = new GetUpdateRewardRequest();
        request.id = id;
        networking.post(request);
    }

    private function _ongGetUpdateRewardResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void
    {
        CAnnouncementState.isInTakeReward = false;

        if (isError) return ;
        var response : GetUpdateRewardResponse = message as GetUpdateRewardResponse;
        if(response)
        {
            (system.getHandler(CWelfareHallManager) as CWelfareHallManager).updateRewardInfo(response);

            if(response.gamePromptID == 0)
            {
                system.dispatchEvent(new CWelfareHallEvent(CWelfareHallEvent.TAKE_REWARD_SUCC, null));
            }
            else
            {
                _showErrorMsg(response.gamePromptID);
            }
        }
    }

    private function _showErrorMsg(gamePromptID:int):void
    {
        var gamePromptTable:IDataTable = (system.stage.getSystem(IDatabase) as IDatabase).getTable(KOFTableConstants.GAME_PROMPT);
        var tableData:GamePrompt = gamePromptTable.findByPrimaryKey(gamePromptID) as GamePrompt;
        if(tableData)
        {
            (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert(tableData.content,CMsgAlertHandler.WARNING);
        }
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
//    /*月卡信息响应*/
//    private final function _ongCardMonthInfoResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
//        if ( isError ) return;
//        var response : CardMonthInfoResponse = message as CardMonthInfoResponse;
//
//        _welfareHallManager.goldCardRewardState = response.dataMap.goldCardState == 1 && response.dataMap.goldCardRewardState == 0;
//        _welfareHallManager.silverCardRewardState = response.dataMap.silverCardState == 1 && response.dataMap.silverCardRewardState == 0;
//        _welfareHallMainView.updateRed();//刷新页签红点
//        system.dispatchEvent( new CWelfareHallEvent( CWelfareHallEvent.CARDMONTHINFO_RESPONSE ,response ));
//        system.dispatchEvent( new CWelfareHallEvent( CWelfareHallEvent.UPDATE_RED_POINT ));
//        var playerHead : CPlayerHeadViewHandler = system.stage.getSystem( CLobbySystem ).getBean( CPlayerHeadViewHandler ) as CPlayerHeadViewHandler;
//        playerHead.invalidateData();
//
//
//    }
//    /*领取月卡奖励响应*/
//    private final function _onGetCardMonthRewardResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
//        if ( isError ) return;
//        var response : GetCardMonthRewardResponse = message as GetCardMonthRewardResponse;
//
//        _welfareHallManager.goldCardRewardState = response.dataMap.goldCardState == 1 && response.dataMap.goldCardRewardState == 0;
//        _welfareHallManager.silverCardRewardState = response.dataMap.silverCardState == 1 && response.dataMap.silverCardRewardState == 0;
//        _welfareHallMainView.updateRed();//刷新页签红点
//        system.dispatchEvent( new CWelfareHallEvent( CWelfareHallEvent.GETCARDMONTHREWARD_RESPONSE ,response ));
//        system.dispatchEvent( new CWelfareHallEvent( CWelfareHallEvent.UPDATE_RED_POINT ));
//        var playerHead : CPlayerHeadViewHandler = system.stage.getSystem( CLobbySystem ).getBean( CPlayerHeadViewHandler ) as CPlayerHeadViewHandler;
//        playerHead.invalidateData();
//
//    }

    /**
     * 请求永久充值福利响应
     */
    private final function _foreverRechargeInfoResponse(net:INetworking,message:CAbstractPackMessage, isError:Boolean):void
    {
        //暂不打开返利功能3
//        var response:ForeverRechargeInfoResponse = message as ForeverRechargeInfoResponse;
//
//        //把数据存储下来
//        (system.getBean(CWelfareHallManager) as CWelfareHallManager).data.updateData(response);
//        if((system.getBean(CRechargeWelfareViewHandler) as CRechargeWelfareViewHandler)._activationCodeUI!=null)
//        {
//            (system.getBean(CRechargeWelfareViewHandler) as CRechargeWelfareViewHandler).updateTotalDiamond();
//        }
//        //主界面图标小红点
//        (system as CWelfareHallSystem).openMainfunction();
    }

    /**
     * 永久充值福利响应
     */
    private final function _receiveRechargeRewardResponse(net:INetworking,message:CAbstractPackMessage, isError:Boolean):void
    {
        var response:ReceiveRechargeRewardResponse = message as ReceiveRechargeRewardResponse;

        //把数据存储下来
        (system.getBean(CWelfareHallManager) as CWelfareHallManager).data.updateDataRecharge(response);
        //调用动画
        (system.getBean(CRechargeWelfareViewHandler) as CRechargeWelfareViewHandler).addBag(response.rechargeValue);
    }

    /**
     * 请求找回数据
     */
    public function findRewardsDataRequest() : void
    {
        var request:RetrieveRewardInfoRequest = new RetrieveRewardInfoRequest();
        request.info = 1;
        networking.post(request);
    }
    private final function _findRewardsDataResponse(net:INetworking,message:CAbstractPackMessage, isError:Boolean):void
    {
        var response:RetrieveRewardInfoResponse = message as RetrieveRewardInfoResponse;
        _welfareHallManager.recoverableList = response.retrieveStateList;
        system.dispatchEvent( new CWelfareHallEvent( CWelfareHallEvent.UPDATE_RECOVERY_VIEW) );
    }
    /**
     * 找回奖励
     */
    public function findRewardsRequest( id : int, type : int, cost:int ) : void
    {
        var request:GetRetrieveRewardRequest = new GetRetrieveRewardRequest();
        request.systemId = id;
        request.type = type;

        if(type == 2)
        {
            var bindDiamond : int = (system.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager).playerData.currency.purpleDiamond;
            if(bindDiamond < cost)
            {
                (system.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem).showCostBdDiamondMsgBox( cost, callBack );
                function callBack() : void
                {
                    networking.post(request);
                    var blueDiamond : int = (system.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager).playerData.currency.blueDiamond;
                    if (blueDiamond + bindDiamond < cost)
                    {
                        var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
                        var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.PAY));
                        bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);
                    }
                }
            }
            else
            {
                networking.post(request);
            }
        }
        else
        {
            networking.post(request);
        }
    }

    private final function _findRewardsResponse(net:INetworking,message:CAbstractPackMessage, isError:Boolean):void
    {
        var response:GetRetrieveRewardResponse = message as GetRetrieveRewardResponse;
        _welfareHallManager.recoverableList = response.retrieveStateList;
        system.dispatchEvent( new CWelfareHallEvent( CWelfareHallEvent.UPDATE_RECOVERY_VIEW ));
        var states : Array = _welfareHallManager.stateChangeArr;
        var rewardListData:CRewardListData;
        var recoveryData : RetrieveReward;
        var rewardIdArray:Array = [];
        var times : Array = [];
        for(var i:int = 0; i < states.length; i++)
        {
            recoveryData = _welfareHallManager.getRecoveryRewardByID(states[i] );
            var rewardId :int = response.type == 1 ? recoveryData.commonReward : recoveryData.payReward;
            rewardIdArray.push(rewardId);
            var item : int = _welfareHallManager.getActivityCountByID(states[i]);
            times.push(item);
        }
        rewardListData = CRewardUtil.createByDropPackageIDArray(system.stage,rewardIdArray,times);
        (system.stage.getSystem(CItemSystem) as CItemSystem).showRewardFull(rewardListData);
        _welfareHallManager.stateChangeArr = [];//清除缓存
        var proStr:String = getGamePromptStr(response.gamePromptID);
        if( proStr != null){
            (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert(proStr);
        }
        _welfareHallMainView.updateRed();
    }
    private function get _pCUISystem():CUISystem{
        return system.stage.getSystem( CUISystem ) as CUISystem;
    }
    private function get _welfareHallManager():CWelfareHallManager{
        return system.getBean( CWelfareHallManager ) as CWelfareHallManager;
    }
    private function get _welfareHallMainView() : CWelfareHallViewHandler
    {
        return system.getBean(CWelfareHallViewHandler) as CWelfareHallViewHandler;
    }
    /******************************table**************************************/
    public function getGamePromptStr(gamePromptID:int):String {
        var pTable:IDataTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.GAME_PROMPT);
        var configInfo:GamePrompt = pTable.findByPrimaryKey(gamePromptID) as GamePrompt;
        var pStr:String = null;
        if(configInfo){
            pStr = configInfo.content;
        }
        return pStr;
    }
}
}
