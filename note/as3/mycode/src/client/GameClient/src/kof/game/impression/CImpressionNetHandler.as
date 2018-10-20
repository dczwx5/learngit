//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/5/20.
 */
package kof.game.impression {

import kof.data.KOFTableConstants;
import kof.framework.CSystemHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.framework.INetworking;
import kof.game.impression.util.CImpressionState;
import kof.message.CAbstractPackMessage;
import kof.message.Hero.HeroImpressionLevelUpgrateRequest;
import kof.message.Hero.HeroImpressionLevelUpgrateResponse;
import kof.message.Hero.ImpressionTalkRequest;
import kof.message.Hero.ImpressionTaskRecallRequest;
import kof.message.Hero.ImpressionTaskRecallResponse;
import kof.message.Hero.ImpressionTaskRewardRequest;
import kof.message.Hero.ImpressionTaskRewardResponse;
import kof.table.GamePrompt;
import kof.ui.CMsgAlertHandler;
import kof.ui.CUISystem;

/**
 * 羁绊网络通信
 */
public class CImpressionNetHandler extends CSystemHandler {
    public function CImpressionNetHandler() {
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
        networking.bind(HeroImpressionLevelUpgrateResponse).toHandler(_impressionUpgradeResponse);
        networking.bind(ImpressionTaskRewardResponse).toHandler(_impressionTaskRewardResponse);
        networking.bind(ImpressionTaskRecallResponse).toHandler(_impressionTaskRecallResponse);
    }

//=================================================>>
    /**
     * 亲密度提升
     * @param heroID 格斗家ID
     * @param itemId 送美食的道具ID(0表示一键送美食)
     */
    public function impressionUpgrade(heroID:int, itemId:int):void
    {
        CImpressionState.isInLevelUpgrade = true;

        var request:HeroImpressionLevelUpgrateRequest = new HeroImpressionLevelUpgrateRequest();
        request.decode([heroID,itemId]);
        networking.post(request);
    }

    /**
     * 亲密度提升消息返回
     * @param net
     * @param message
     */
    private final function _impressionUpgradeResponse(net:INetworking,message:CAbstractPackMessage):void
    {
        CImpressionState.isInLevelUpgrade = false;

        var response:HeroImpressionLevelUpgrateResponse = message as HeroImpressionLevelUpgrateResponse;

        var gamePromptTable:IDataTable = (system.stage.getSystem(IDatabase) as IDatabase).getTable(KOFTableConstants.GAME_PROMPT);
        var tableData:GamePrompt = gamePromptTable.findByPrimaryKey(response.gamePromptID) as GamePrompt;
        if(tableData)
        {
            (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert(tableData.content,CMsgAlertHandler.NORMAL);
        }
    }
//<<=================================================


//=================================================>>
    /**
     * 更新首次培养需要显示剧情对话的状态
     * @param heroId
     */
    public function impressionTalkRequest(heroId:int):void
    {
        var request:ImpressionTalkRequest = new ImpressionTalkRequest();
        request.decode([heroId]);
        networking.post(request);
    }


//=================================================>>
    /**
     * 羁绊系统神秘任务领奖请求
     * @param heroId
     */
    public function impressionTaskRewardRequest(heroId:int):void
    {
        var request:ImpressionTaskRewardRequest = new ImpressionTaskRewardRequest();
        request.decode([heroId]);
        networking.post(request);
    }

    /**
     * 羁绊系统神秘任务领奖响应
     */
    private function _impressionTaskRewardResponse(net:INetworking,message:CAbstractPackMessage):void
    {
        var response:ImpressionTaskRewardResponse = message as ImpressionTaskRewardResponse;

        var gamePromptTable:IDataTable = (system.stage.getSystem(IDatabase) as IDatabase).getTable(KOFTableConstants.GAME_PROMPT);
        var tableData:GamePrompt = gamePromptTable.findByPrimaryKey(response.gamePromptID) as GamePrompt;
        if(tableData)
        {
            (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert(tableData.content,CMsgAlertHandler.NORMAL);
        }
    }
//<<=================================================


//=================================================>>
    /**
     * 羁绊系统神秘任务召回请求
     * @param heroId
     */
    public function impressionTaskRecallRequest(heroId:int):void
    {
        var request:ImpressionTaskRecallRequest = new ImpressionTaskRecallRequest();
        request.decode([heroId]);
        networking.post(request);
    }

    /**
     * 羁绊系统神秘任务召回响应
     */
    private function _impressionTaskRecallResponse(net:INetworking,message:CAbstractPackMessage):void
    {
        var response:ImpressionTaskRecallResponse = message as ImpressionTaskRecallResponse;

        var gamePromptTable:IDataTable = (system.stage.getSystem(IDatabase) as IDatabase).getTable(KOFTableConstants.GAME_PROMPT);
        var tableData:GamePrompt = gamePromptTable.findByPrimaryKey(response.gamePromptID) as GamePrompt;
        if(tableData)
        {
            (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert(tableData.content,CMsgAlertHandler.NORMAL);
        }
    }
//<<=================================================
}
}
