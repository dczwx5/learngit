//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/6/9.
 */
package kof.game.playerCard {

import kof.data.KOFTableConstants;
import kof.framework.CSystemHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.framework.INetworking;
import kof.game.common.CLang;
import kof.game.common.status.CGameStatus;
import kof.game.playerCard.event.CPlayerCardEvent;
import kof.game.playerCard.util.CPlayerCardConst;
import kof.game.playerCard.util.CPlayerCardTestUtil;
import kof.game.playerCard.util.CPlayerCardUtil;
import kof.game.playerCard.util.ECardResultType;
import kof.game.playerCard.util.ECardViewType;
import kof.game.playerCard.view.CPlayerCardResultViewHandler;
import kof.message.CAbstractPackMessage;
import kof.message.CardPlayer.CardPlayerFreeRequest;
import kof.message.CardPlayer.CardPlayerFreeResponse;
import kof.message.CardPlayer.CardPlayerMailContentRequest;
import kof.message.CardPlayer.CardPlayerMailContentResponse;
import kof.message.CardPlayer.CardPlayerOpenRequest;
import kof.message.CardPlayer.CardPlayerOpenResponse;
import kof.message.CardPlayer.CardPlayerRequest;
import kof.message.CardPlayer.CardPlayerResponse;
import kof.message.CardPlayer.CardPlayerResponse;
import kof.message.CardPlayer.CardPlayerSubPoolRequest;
import kof.message.CardPlayer.CardPlayerSubPoolResponse;
import kof.message.Hero.ItemConvertToHeroPieceResponse;
import kof.table.GamePrompt;
import kof.ui.CMsgAlertHandler;
import kof.ui.CUISystem;

public class CPlayerCardNetHandler extends CSystemHandler{

    private var m_iCurrPoolType:int;
    private var m_iCurrResultType:int;

    public function CPlayerCardNetHandler()
    {
        super ();
    }

    override protected function onSetup():Boolean
    {
        var ret:Boolean = super.onSetup();
        _addNetListeners();

        return ret;
    }

    private function _addNetListeners():void
    {
        networking.bind(CardPlayerResponse).toHandler(_pumpingCardResponse);
        networking.bind(CardPlayerFreeResponse).toHandler(_pumpingCardFreeResponse);
        networking.bind(CardPlayerOpenResponse).toHandler(_cardPlayerOpenResponse);
        networking.bind(ItemConvertToHeroPieceResponse).toHandler(_itemConvertToHeroPieceResponse);
        networking.bind(CardPlayerSubPoolResponse).toHandler(_cardPlayerSubPoolResponse);
        networking.bind(CardPlayerMailContentResponse).toHandler(_cardPlayerMailContentResponse);
    }

//=================================================>>
    /**
     * 抽卡请求
     * @param poolId 卡池ID
     * @param count 道具数量
     */
    public function pumpingCardRequest(poolId:int, count:int):void
    {
//        if(!CGameStatus.checkStatus(system))
//        {
//            return;
//        }

        m_iCurrPoolType = poolId;
        switch(count)
        {
            case CPlayerCardConst.Consume_Num_One:
                m_iCurrResultType = ECardResultType.Type_One;
                break;
            case CPlayerCardConst.Consume_Num_Ten:
                m_iCurrResultType = ECardResultType.Type_Ten;
                break;
            case CPlayerCardConst.Consume_Num_Fifty:
                m_iCurrResultType = ECardResultType.Type_Fifty;
                break;
        }

        var request:CardPlayerRequest = new CardPlayerRequest();
//        request.decode([poolId,count]);
        request.count = count;
        request.poolID = poolId;
        networking.post(request);
    }

    /**
     * 抽卡消息返回
     * @param net
     * @param message
     */
    private final function _pumpingCardResponse(net:INetworking,message:CAbstractPackMessage):void
    {
        var response:CardPlayerResponse = message as CardPlayerResponse;
        if(response.gamePromptID == 0)
        {
            (system.getHandler(CPlayerCardManager) as CPlayerCardManager).updateData(response);

            var resultViewHandler:CPlayerCardResultViewHandler = system.getHandler(CPlayerCardResultViewHandler)
                    as CPlayerCardResultViewHandler;

            resultViewHandler.viewType = m_iCurrPoolType;
            resultViewHandler.resultType = m_iCurrResultType;
            resultViewHandler.addDisplay();
        }
        else
        {
            var gamePromptTable:IDataTable = (system.stage.getSystem(IDatabase) as IDatabase).getTable(KOFTableConstants.GAME_PROMPT);
            var tableData:GamePrompt = gamePromptTable.findByPrimaryKey(response.gamePromptID) as GamePrompt;
            if(tableData)
            {
                (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert(tableData.content,CMsgAlertHandler.WARNING);
            }
        }
    }
//<<=================================================


//=================================================>>
    /**
     * 免费抽卡请求
     * @param poolId 卡池ID
     */
    public function pumpingCardFreeRequest(poolId:int):void
    {
//        if(!CGameStatus.checkStatus(system))
//        {
//            return;
//        }

        var request:CardPlayerFreeRequest = new CardPlayerFreeRequest();
        request.decode([poolId]);
        networking.post(request);
    }

    /**
     * 免费抽卡响应
     * @param net
     * @param message
     */
    private function _pumpingCardFreeResponse(net:INetworking,message:CAbstractPackMessage):void
    {
        var response:CardPlayerFreeResponse = message as CardPlayerFreeResponse;
        if(response.gamePromptID == 0)
        {
            (system.getHandler(CPlayerCardManager) as CPlayerCardManager).updateFreeData(response);

            var resultViewHandler:CPlayerCardResultViewHandler = system.getHandler(CPlayerCardResultViewHandler)
                    as CPlayerCardResultViewHandler;

            resultViewHandler.viewType = ECardViewType.Type_Common;
            resultViewHandler.resultType = ECardResultType.Type_Free;
            resultViewHandler.addDisplay();
        }
        else
        {
            var gamePromptTable:IDataTable = (system.stage.getSystem(IDatabase) as IDatabase).getTable(KOFTableConstants.GAME_PROMPT);
            var tableData:GamePrompt = gamePromptTable.findByPrimaryKey(response.gamePromptID) as GamePrompt;
            if(tableData)
            {
                (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert(tableData.content,CMsgAlertHandler.WARNING);
            }
        }
    }
//<<=================================================


//=================================================>>
    /**
     * 打开抽卡页面请求
     * @param poolId 卡池ID
     */
    public function cardPlayerOpenRequest(poolId:int = 0):void
    {
        var request:CardPlayerOpenRequest = new CardPlayerOpenRequest();
        request.decode([poolId]);
        networking.post(request);
    }

    /**
     * 打开抽卡页面响应
     * @param net
     * @param message
     */
    private function _cardPlayerOpenResponse(net:INetworking,message:CAbstractPackMessage):void
    {
        var response:CardPlayerOpenResponse = message as CardPlayerOpenResponse;
        (system.getHandler(CPlayerCardManager) as CPlayerCardManager).updateOpenData(response);
    }
//<<=================================================

    /**
     * 道具转换成格斗家碎片响应
     * @param net
     * @param message
     */
    private function _itemConvertToHeroPieceResponse(net:INetworking,message:CAbstractPackMessage):void
    {
        var response:ItemConvertToHeroPieceResponse = message as ItemConvertToHeroPieceResponse;
        if(response)
        {
            CPlayerCardUtil.showHeroGetView2(response);
        }
    }
//<<=================================================


//=================================================>>
    /**
     * 获取高级卡池的子卡池ID请求
     * @param poolId 卡池ID
     */
    public function cardPlayerSubPoolRequest():void
    {
        var request:CardPlayerSubPoolRequest = new CardPlayerSubPoolRequest();
        request.flag = 1;
        networking.post(request);
    }

    /**
     * 获取高级卡池的子卡池ID响应
     * @param net
     * @param message
     */
    private function _cardPlayerSubPoolResponse(net:INetworking,message:CAbstractPackMessage):void
    {
        var response:CardPlayerSubPoolResponse = message as CardPlayerSubPoolResponse;
        if(response)
        {
            system.dispatchEvent(new CPlayerCardEvent(CPlayerCardEvent.SubPoolInfo, response.subPoolID));
        }
    }
//<<=================================================


//====================================================================================================================>>
    /**
     * 抽卡信件内容请求
     * @param message 信封上写的内容
     */
    public function cardPlayerMailContentRequest(message:String):void
    {
        var request:CardPlayerMailContentRequest = new CardPlayerMailContentRequest();
        request.content = message;
        networking.post(request);
    }

    /**
     * 抽卡信件内容请求响应
     * @param net
     * @param message
     */
    private function _cardPlayerMailContentResponse(net:INetworking,message:CAbstractPackMessage):void
    {
        var response:CardPlayerMailContentResponse = message as CardPlayerMailContentResponse;
        if(response && response.content)
        {
            (system.getHandler(CPlayerCardManager) as CPlayerCardManager).mailContent = response.content;
        }
    }
//<<====================================================================================================================
}
}
