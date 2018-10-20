//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/10/10.
 */
package kof.game.endlessTower {

import kof.framework.INetworking;
import kof.game.common.CFlyItemUtil;
import kof.game.common.CRewardUtil;
import kof.game.common.CUIFactory;
import kof.game.common.system.CNetHandlerImp;
import kof.game.endlessTower.data.CEndlessTowerBoxData;
import kof.game.endlessTower.data.CEndlessTowerBoxData;
import kof.game.endlessTower.data.CEndlessTowerResultData;
import kof.game.endlessTower.event.CEndlessTowerEvent;
import kof.game.endlessTower.util.CEndlessUtil;
import kof.game.endlessTower.view.CEndlessTowerSweepViewHandler;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardData;
import kof.game.item.data.CRewardListData;
import kof.game.item.view.CItemViewHandler;
import kof.message.CAbstractPackMessage;
import kof.message.EndlessTower.EndlessTowerBattleResultResponse;
import kof.message.EndlessTower.EndlessTowerChallengeRequest;
import kof.message.EndlessTower.EndlessTowerChallengeResponse;
import kof.message.EndlessTower.EndlessTowerDataRequest;
import kof.message.EndlessTower.EndlessTowerDataResponse;
import kof.message.EndlessTower.EndlessTowerEverydayRewardObtainRequest;
import kof.message.EndlessTower.EndlessTowerEverydayRewardObtainResponse;
import kof.message.EndlessTower.EndlessTowerPassBoxObtainRequest;
import kof.message.EndlessTower.EndlessTowerPassBoxObtainResponse;
import kof.message.EndlessTower.EndlessTowerRankRequest;
import kof.message.EndlessTower.EndlessTowerRankResponse;
import kof.message.EndlessTower.EndlessTowerSweepRequest;
import kof.message.EndlessTower.EndlessTowerSweepResponse;
import kof.ui.CMsgAlertHandler;
import kof.ui.CUISystem;
import kof.ui.IUICanvas;
import kof.ui.imp_common.RewardItemUI;
import kof.ui.imp_common.RewardItemUI;

public class CEndlessTowerNetHandler extends CNetHandlerImp {
    public function CEndlessTowerNetHandler()
    {
        super();
    }

    override protected function onSetup() : Boolean
    {
        super.onSetup();

        bind( EndlessTowerDataResponse, _onEndlessTowerDataResponse );
        bind( EndlessTowerRankResponse, _onEndlessTowerRankResponse );
        bind( EndlessTowerEverydayRewardObtainResponse, _onEndlessTowerEverydayRewardObtainResponse );
        bind( EndlessTowerPassBoxObtainResponse, _onEndlessTowerPassBoxObtainResponse );
        bind( EndlessTowerBattleResultResponse, _onResult );
        bind( EndlessTowerChallengeResponse, _onEndlessTowerChallengeResponse );
        bind( EndlessTowerSweepResponse, _onEndlessTowerSweepResponse );


        return true;
    }

//=================================================>>
    /**
     * 无尽塔界面数据
     */
    public function endlessTowerDataRequest() : void
    {
        var request : EndlessTowerDataRequest = new EndlessTowerDataRequest();
        request.flag = 1;
        networking.post( request );
    }

    private final function _onEndlessTowerDataResponse( net : INetworking, message : CAbstractPackMessage, isError:Boolean ) : void
    {
        if (isError) return ;

        var response:EndlessTowerDataResponse = message as EndlessTowerDataResponse;
        if(response)
        {
            _endlessTowerManager.updateBaseData(response);
        }
    }
//<<=================================================



//=================================================>>
    /**
     * 爬塔排行
     */
    public function endlessTowerRankRequest() : void
    {
        var request : EndlessTowerRankRequest = new EndlessTowerRankRequest();
        request.flag = 1;
        networking.post( request );
    }

    private final function _onEndlessTowerRankResponse( net : INetworking, message : CAbstractPackMessage, isError:Boolean ) : void
    {
        if (isError) return ;

        var response:EndlessTowerRankResponse = message as EndlessTowerRankResponse;
        if(response)
        {
            _endlessTowerManager.updateRankData(response);
        }
    }
//<<=================================================



//=================================================>>
    /**
     * 挑战
     * @param layer 挑战那一层
     */
    public function endlessTowerChallengeRequest(layer:int) : void
    {
        var request : EndlessTowerChallengeRequest = new EndlessTowerChallengeRequest();
        request.layer = layer;
        networking.post( request );
    }

    private final function _onEndlessTowerChallengeResponse( net : INetworking, message : CAbstractPackMessage, isError:Boolean ) : void
    {
        if (isError) return ;

        var response:EndlessTowerChallengeResponse = message as EndlessTowerChallengeResponse;
        if(response)
        {
            _endlessTowerManager.startPreload(response.layer);
        }
    }
//<<=================================================



//=================================================>>
    /**
     * 领取每日奖励
     */
    public function takeDayReward() : void
    {
        var request : EndlessTowerEverydayRewardObtainRequest = new EndlessTowerEverydayRewardObtainRequest();
        request.flag = 1;
        networking.post( request );
    }

    private final function _onEndlessTowerEverydayRewardObtainResponse( net : INetworking, message : CAbstractPackMessage, isError:Boolean ) : void
    {
        if (isError) return ;

        var response:EndlessTowerEverydayRewardObtainResponse = message as EndlessTowerEverydayRewardObtainResponse;
        if(response)
        {
            _endlessTowerManager.updateDayRewardTakeInfo(response);

            var rewardListData:CRewardListData = CRewardUtil.createByList(system.stage, response.rewardList);
            if(rewardListData)
            {
                (system.stage.getSystem(CItemSystem) as CItemSystem).showRewardFull(rewardListData);
            }
        }
    }
//<<=================================================



//=================================================>>
    /**
     * 通关宝箱领取
     * @param layer 哪一层
     * @param index 哪个宝箱
     */
    public function takePassBoxReward(layer:int, index:int) : void
    {
        CEndlessUtil.currTakeBoxIndex = index;

        var request : EndlessTowerPassBoxObtainRequest = new EndlessTowerPassBoxObtainRequest();
        request.layer = layer;
        request.index = index;
        networking.post( request );
    }

    private final function _onEndlessTowerPassBoxObtainResponse( net : INetworking, message : CAbstractPackMessage, isError:Boolean ) : void
    {
        var currTakeBoxIndex:int = CEndlessUtil.currTakeBoxIndex;
        CEndlessUtil.currTakeBoxIndex = -1;
        if(isError)
        {
            return;
        }

        var response:EndlessTowerPassBoxObtainResponse = message as EndlessTowerPassBoxObtainResponse;
        if(response)
        {
            _endlessTowerManager.updateBoxRewardTakeInfo(response);

            var _helper:CEndlessTowerHelpHandler = system.getHandler(CEndlessTowerHelpHandler) as CEndlessTowerHelpHandler;
            var boxDataArr:Array = _helper.getBoxDatasById(response.layerInfo["layer"]);
            if(currTakeBoxIndex < boxDataArr.length)
            {
                var boxData:CEndlessTowerBoxData = boxDataArr[currTakeBoxIndex] as CEndlessTowerBoxData;
                if(boxData)
                {
                    var rewardListData:CRewardListData = CRewardUtil.createByDropPackageID(system.stage, boxData.boxRewardId);
                    if(rewardListData)
                    {
                        (system.stage.getSystem(CItemSystem) as CItemSystem).showRewardFull(rewardListData);
                    }
                }
            }
        }
    }
//<<=================================================


    private final function _onResult( net : INetworking, message : CAbstractPackMessage, isError:Boolean ) : void  {
        if (isError) return ;

        var response:EndlessTowerBattleResultResponse = message as EndlessTowerBattleResultResponse;
        if(response) {
            var dataObj:Object = CEndlessTowerResultData.createDataObject(response.isWin, response.isFirstPass,
                    response.rewardList, response.robotHeroIds, response.robotName);
            _endlessTowerManager.updateResultData(dataObj);
            system.dispatchEvent(new CEndlessTowerEvent(CEndlessTowerEvent.NET_RESULT, _endlessTowerManager.baseData.resultData));
        }
    }

//<<=================================================



//=================================================>>
    /**
     * 扫荡
     * @param layer 哪一层
     * @param num 扫荡几次
     */
    public function endlessTowerSweepRequest(layer:int, num:int):void
    {
        var sweepView:CEndlessTowerSweepViewHandler = system.getHandler(CEndlessTowerSweepViewHandler)
                as CEndlessTowerSweepViewHandler;
        if(sweepView)
        {
            sweepView.currLayer = layer;
        }

        var request : EndlessTowerSweepRequest = new EndlessTowerSweepRequest();
        request.layer = layer;
        request.num = num;
        networking.post( request );
    }

    private final function _onEndlessTowerSweepResponse(net : INetworking, message : CAbstractPackMessage, isError:Boolean):void
    {
        if(isError)
        {
            return;
        }

        var response:EndlessTowerSweepResponse = message as EndlessTowerSweepResponse;
        if(response)
        {
            system.dispatchEvent(new CEndlessTowerEvent(CEndlessTowerEvent.SweepSucc, response.totalRewardList));
        }
    }
//<<=================================================

    private function get _endlessTowerManager():CEndlessTowerManager
    {
        return system.getHandler(CEndlessTowerManager) as CEndlessTowerManager;
    }
}
}
