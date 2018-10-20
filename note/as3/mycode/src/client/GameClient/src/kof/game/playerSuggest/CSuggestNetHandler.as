//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Administrator on 2017/5/15.
 */
package kof.game.playerSuggest {

import flash.display.DisplayObject;

import kof.data.KOFTableConstants;
import kof.framework.CSystemHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.framework.INetworking;
import kof.game.common.CLang;
import kof.message.CAbstractPackMessage;
import kof.message.Suggestion.PlayerSuggestionRequest;
import kof.message.Suggestion.PlayerSuggestionResponse;
import kof.table.GamePrompt;
import kof.ui.CMsgAlertHandler;
import kof.ui.CUISystem;
import kof.ui.IUICanvas;

/**
 * 网络通信
 */
public class CSuggestNetHandler extends CSystemHandler{

    public function CSuggestNetHandler()
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
        networking.bind(PlayerSuggestionResponse ).toHandler(_onSuggestResponseHandler);
    }

    /**
     * 提交意见
     */
    public function playerSuggestionRequest(type:int, content:String):void
    {
        var request:PlayerSuggestionRequest = new PlayerSuggestionRequest();
        request.type = type;
        request.content = content;
        request.qq = "";
        request.phone = "";
        request.time = 0;
        request.fightUUID = "";
        networking.post(request);
    }

    /**
     * 消息返回
     * @param net
     * @param message
     */
    private function _onSuggestResponseHandler(net:INetworking, message:CAbstractPackMessage):void
    {
        var response:PlayerSuggestionResponse = message as PlayerSuggestionResponse;

        if(response.gamePromptID == 0)
        {
            (system.stage.getSystem( IUICanvas ) as IUICanvas).showMsgAlert(CLang.Get("suggest_submit_succ_tip"), CMsgAlertHandler.NORMAL);
        }
        else
        {
            var gamePromptTable:IDataTable = (system.stage.getSystem(IDatabase) as IDatabase).getTable(KOFTableConstants.GAME_PROMPT);
            var configInfo:GamePrompt = gamePromptTable.findByPrimaryKey(response.gamePromptID) as GamePrompt;
            if(configInfo)
            {
                (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert(configInfo.content,CMsgAlertHandler.NORMAL);
            }
        }
    }
}
}
