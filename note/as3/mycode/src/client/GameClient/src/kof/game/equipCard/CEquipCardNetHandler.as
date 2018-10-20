//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/7/13.
 */
package kof.game.equipCard {

import kof.data.KOFTableConstants;
import kof.framework.CSystemHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.framework.INetworking;
import kof.game.common.status.CGameStatus;
import kof.game.equipCard.util.CEquipCardConst;
import kof.game.equipCard.view.CEquipCardResultViewHandler;
import kof.game.playerCard.util.ECardResultType;
import kof.message.CAbstractPackMessage;
import kof.message.EquipCard.EquipCardOpenRequest;
import kof.message.EquipCard.EquipCardOpenResponse;
import kof.message.EquipCard.EquipCardRequest;
import kof.message.EquipCard.EquipCardResponse;
import kof.table.GamePrompt;
import kof.ui.CMsgAlertHandler;
import kof.ui.CUISystem;

public class CEquipCardNetHandler extends CSystemHandler {

    private var m_iCurrPoolType:int;
    private var m_iCurrResultType:int;

    public function CEquipCardNetHandler()
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
        networking.bind(EquipCardResponse).toHandler(_pumpingCardResponse);
//        networking.bind(CardPlayerFreeResponse).toHandler(_pumpingCardFreeResponse);
        networking.bind(EquipCardOpenResponse).toHandler(_equipCardOpenResponse);
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
            case CEquipCardConst.Consume_Num_One:
                m_iCurrResultType = ECardResultType.Type_One;
                break;
            case CEquipCardConst.Consume_Num_Ten:
                m_iCurrResultType = ECardResultType.Type_Ten;
                break;
            case CEquipCardConst.Consume_Num_Fifty:
                m_iCurrResultType = ECardResultType.Type_Fifty;
                break;
        }

        var request:EquipCardRequest = new EquipCardRequest();
        request.decode([poolId,count]);
        networking.post(request);
    }

    /**
     * 抽卡消息返回
     * @param net
     * @param message
     */
    private final function _pumpingCardResponse(net:INetworking,message:CAbstractPackMessage):void
    {
        var response:EquipCardResponse = message as EquipCardResponse;
        (system.getHandler(CEquipCardManager) as CEquipCardManager).updateData(response);

        var resultViewHandler:CEquipCardResultViewHandler = system.getHandler(CEquipCardResultViewHandler)
                as CEquipCardResultViewHandler;

        resultViewHandler.viewType = m_iCurrPoolType;
        resultViewHandler.resultType = m_iCurrResultType;
        resultViewHandler.addDisplay();

        if(response.gamePromptID)
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
    /*
    public function pumpingCardFreeRequest(poolId:int):void
    {
        var request:CardPlayerFreeRequest = new CardPlayerFreeRequest();
        request.decode([poolId]);
        networking.post(request);
    }
    */

    /**
     * 免费抽卡响应
     * @param net
     * @param message
     */
    /*
    private function _pumpingCardFreeResponse(net:INetworking,message:CAbstractPackMessage):void
    {
        var response:CardPlayerFreeResponse = message as CardPlayerFreeResponse;
        (system.getHandler(CPlayerCardManager) as CPlayerCardManager).updateFreeData(response);

        var resultViewHandler:CPlayerCardResultViewHandler = system.getHandler(CPlayerCardResultViewHandler)
                as CPlayerCardResultViewHandler;

        resultViewHandler.viewType = ECardViewType.Type_Common;
        resultViewHandler.resultType = ECardResultType.Type_Free;
        resultViewHandler.addDisplay();

        if(response.gamePromptID)
        {
            var gamePromptTable:IDataTable = (system.stage.getSystem(IDatabase) as IDatabase).getTable(KOFTableConstants.GAME_PROMPT);
            var tableData:GamePrompt = gamePromptTable.findByPrimaryKey(response.gamePromptID) as GamePrompt;
            if(tableData)
            {
                (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert(tableData.content,CMsgAlertHandler.WARNING);
            }
        }
    }
    */
//<<=================================================


//=================================================>>
    /**
     * 打开抽卡页面请求
     * @param poolId 卡池ID
     */
    public function equipCardOpenRequest(poolId:int = 0):void
    {
        var request:EquipCardOpenRequest = new EquipCardOpenRequest();
        request.open = poolId;
        networking.post(request);
    }

    /**
     * 打开抽卡页面响应
     * @param net
     * @param message
     */
    private function _equipCardOpenResponse(net:INetworking,message:CAbstractPackMessage):void
    {
        var response:EquipCardOpenResponse = message as EquipCardOpenResponse;
        (system.getHandler(CEquipCardManager) as CEquipCardManager).updateOpenData(response);
    }
//<<=================================================
}
}
