//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/7/18.
 */
package kof.game.arena {

import kof.data.KOFTableConstants;
import kof.framework.CSystemHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.framework.INetworking;
import kof.game.arena.event.CArenaEvent;
import kof.game.arena.util.CArenaState;
import kof.message.Arena.ArenaBaseRequest;
import kof.message.Arena.ArenaBaseResponse;
import kof.message.Arena.ArenaBattleResultResponse;
import kof.message.Arena.ArenaBuyChallengeRequest;
import kof.message.Arena.ArenaBuyChallengeResponse;
import kof.message.Arena.ArenaChallengeRequest;
import kof.message.Arena.ArenaChallengeResponse;
import kof.message.Arena.ArenaChangeRequest;
import kof.message.Arena.ArenaChangeResponse;
import kof.message.Arena.ArenaFightReportRequest;
import kof.message.Arena.ArenaFightReportResponse;
import kof.message.Arena.ArenaHighestAwardGetRequest;
import kof.message.Arena.ArenaHighestAwardGetResponse;
import kof.message.Arena.ArenaHighestAwardListRequest;
import kof.message.Arena.ArenaHighestAwardListResponse;
import kof.message.Arena.ArenaWorshipRequest;
import kof.message.Arena.ArenaWorshipResponse;
import kof.message.CAbstractPackMessage;
import kof.table.GamePrompt;
import kof.ui.CMsgAlertHandler;
import kof.ui.CUISystem;

public class CArenaNetHandler extends CSystemHandler {
    public function CArenaNetHandler()
    {
        super();
    }

    override protected function onSetup():Boolean
    {
        var ret:Boolean = super.onSetup();
        _addNetListeners();

        return ret;
    }

    private function _addNetListeners():void
    {
        networking.bind(ArenaBaseResponse).toHandler(_arenaBaseResponse);
        networking.bind(ArenaChallengeResponse).toHandler(_arenaChallengeResponse);
        networking.bind(ArenaChangeResponse).toHandler(_arenaChangeResponse);
        networking.bind(ArenaHighestAwardListResponse).toHandler(_arenaHighestAwardListResponse);
        networking.bind(ArenaHighestAwardGetResponse).toHandler(_arenaHighestAwardGetResponse);
        networking.bind(ArenaFightReportResponse).toHandler(_arenaFightReportResponse);
        networking.bind(ArenaBuyChallengeResponse).toHandler(_arenaBuyChallengeResponse);
        networking.bind(ArenaWorshipResponse).toHandler(_arenaWorshipResponse);
        networking.bind(ArenaBattleResultResponse).toHandler(_onArenaResult);


    }

//=================================================>>
    /**
     * 竞技场基本信息请求
     */
    public function arenaBaseRequest():void
    {
        var request:ArenaBaseRequest = new ArenaBaseRequest();
        request.placeholder = 0;
        networking.post(request);
    }

    /**
     * 竞技场基本信息响应
     * @param net
     * @param message
     */
    private final function _arenaBaseResponse(net:INetworking,message:CAbstractPackMessage):void
    {
        var response:ArenaBaseResponse = message as ArenaBaseResponse;
        (system.getHandler(CArenaManager) as CArenaManager).updateArenaBaseData(response);
    }
//<<=================================================


//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    /**
     * 竞技场结算信息
     * @param net
     * @param message
     */
    private final function _onArenaResult(net:INetworking,message:CAbstractPackMessage):void
    {
        var response:ArenaBattleResultResponse = message as ArenaBattleResultResponse;
        (system.getHandler(CArenaManager) as CArenaManager).updateArenaResultData(response);
    }


//=================================================>>
    /**
     * 竞技场挑战请求
     * @param rank 被挑战者的排名
     */
    public function arenaChallengeRequest(rank:int):void
    {
        CArenaState.isInChallenge = true;

        var request:ArenaChallengeRequest = new ArenaChallengeRequest();
        request.rank = rank;
        networking.post(request);
    }

    /**
     * 竞技场挑战响应
     * @param net
     * @param message
     */
    private final function _arenaChallengeResponse(net:INetworking,message:CAbstractPackMessage):void
    {
        CArenaState.isInChallenge = false;

        var response:ArenaChallengeResponse = message as ArenaChallengeResponse;

        if(response.gamePromptID == 0)
        {
            (system.getHandler(CArenaManager) as CArenaManager).updateSingleChallengerInfo(response);
        }
        else
        {
            _showErrorMsg(response.gamePromptID);
        }
    }
//<<=================================================


//=================================================>>
    /**
     * 竞技场换一批请求
     */
    public function arenaChangeRequest(type:int):void
    {
        CArenaState.isInChangeGroup = true;

        var request:ArenaChangeRequest = new ArenaChangeRequest();
        request.type = type;
        networking.post(request);
    }

    /**
     * 竞技场换一批响应
     * @param net
     * @param message
     */
    private final function _arenaChangeResponse(net:INetworking,message:CAbstractPackMessage):void
    {
        CArenaState.isInChangeGroup = false;

        var response:ArenaChangeResponse = message as ArenaChangeResponse;
        if(response.gamePromptID == 0)
        {
            (system.getHandler(CArenaManager) as CArenaManager).updateChallengerInfo(response);
        }
        else
        {
            _showErrorMsg(response.gamePromptID);
        }
    }
//<<=================================================


//=================================================>>
    /**
     * 最高奖励列表请求
     */
    public function arenaHighestAwardListRequest():void
    {
        var request:ArenaHighestAwardListRequest = new ArenaHighestAwardListRequest();
        request.placeholder = 0;
        networking.post(request);
    }

    /**
     * 最高奖励列表响应
     * @param net
     * @param message
     */
    private final function _arenaHighestAwardListResponse(net:INetworking,message:CAbstractPackMessage):void
    {
        var response:ArenaHighestAwardListResponse = message as ArenaHighestAwardListResponse;
        (system.getHandler(CArenaManager) as CArenaManager).updateRewardData(response);
    }
//<<=================================================


//=================================================>>

    private var m_iRewardId:int;
    /**
     * 最高奖励领取请求
     */
    public function arenaHighestAwardGetRequest(rewardId:int):void
    {
        CArenaState.isInTakeReward = true;

        m_iRewardId = rewardId;
        var request:ArenaHighestAwardGetRequest = new ArenaHighestAwardGetRequest();
        request.id = rewardId;
        networking.post(request);
    }

    /**
     * 最高奖励领取响应
     * @param net
     * @param message
     */
    private final function _arenaHighestAwardGetResponse(net:INetworking,message:CAbstractPackMessage):void
    {
        CArenaState.isInTakeReward = false;

        var response:ArenaHighestAwardGetResponse = message as ArenaHighestAwardGetResponse;
        if(response)
        {
            if(response.gamePromptID)
            {
                _showErrorMsg(response.gamePromptID);
            }
            else
            {
                // 领取成功，派发事件
                system.dispatchEvent(new CArenaEvent(CArenaEvent.TakeRewardSucc,m_iRewardId));
            }
        }
    }
//<<=================================================


//=================================================>>
    /**
     * 战报请求
     */
    public function arenaFightReportRequest():void
    {
        var request:ArenaFightReportRequest = new ArenaFightReportRequest();
        request.fightReport = 0;
        networking.post(request);
    }

    /**
     * 战报响应
     * @param net
     * @param message
     */
    private final function _arenaFightReportResponse(net:INetworking,message:CAbstractPackMessage):void
    {
        var response:ArenaFightReportResponse = message as ArenaFightReportResponse;
        (system.getHandler(CArenaManager) as CArenaManager).updateFightReportData(response);
    }
//<<=================================================


//=================================================>>
    /**
     * 竞技场购买挑战次数请求
     */
    public function arenaBuyChallengeRequest():void
    {
        CArenaState.isInBuyPower = true;

        var request:ArenaBuyChallengeRequest = new ArenaBuyChallengeRequest();
        request.placeholder = 0;
        networking.post(request);
    }

    /**
     * 竞技场购买挑战次数响应
     * @param net
     * @param message
     */
    private final function _arenaBuyChallengeResponse(net:INetworking,message:CAbstractPackMessage):void
    {
        CArenaState.isInBuyPower = false;

        var response:ArenaBuyChallengeResponse = message as ArenaBuyChallengeResponse;
        if(response.gamePromptID == 0)
        {
            (system.getHandler(CArenaManager) as CArenaManager).updateChallengeBaseInfo(response);
        }
        else
        {
            _showErrorMsg(response.gamePromptID);
        }
    }
//<<=================================================


//=================================================>>
    /**
     * 膜拜请求
     */
    public function arenaWorshipRequest(rank:int):void
    {
        CArenaState.isInWorship = true;

        var request:ArenaWorshipRequest = new ArenaWorshipRequest();
        request.rank = rank;
        networking.post(request);
    }

    /**
     * 膜拜响应
     * @param net
     * @param message
     */
    private final function _arenaWorshipResponse(net:INetworking,message:CAbstractPackMessage):void
    {
        CArenaState.isInWorship = false;

        var response:ArenaWorshipResponse = message as ArenaWorshipResponse;
        if(response.gamePromptID == 0)
        {
            system.dispatchEvent(new CArenaEvent(CArenaEvent.WorshipSucc, response.rank));
        }
        else
        {
            _showErrorMsg(response.gamePromptID);
        }
    }
//<<=================================================


    private function _showErrorMsg(gamePromptID:int):void
    {
        var gamePromptTable:IDataTable = (system.stage.getSystem(IDatabase) as IDatabase).getTable(KOFTableConstants.GAME_PROMPT);
        var tableData:GamePrompt = gamePromptTable.findByPrimaryKey(gamePromptID) as GamePrompt;
        if(tableData)
        {
            (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert(tableData.content,CMsgAlertHandler.WARNING);
        }
    }

}
}
