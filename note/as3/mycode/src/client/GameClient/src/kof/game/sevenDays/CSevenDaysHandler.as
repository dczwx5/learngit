//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Edison.Weng on 2017/7/24.
 */
package kof.game.sevenDays {

import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.framework.INetworking;
import kof.game.common.system.CNetHandlerImp;
import kof.game.sevenDays.event.CSevenDaysEvent;
import kof.message.Activity.SevenDaysLoginActivityRequest;
import kof.message.Activity.SevenDaysLoginActivityResponse;
import kof.message.CAbstractPackMessage;
import kof.table.GamePrompt;
import kof.ui.CMsgAlertHandler;
import kof.ui.CUISystem;

/**
 * 七天登录请求处理
 * */
public class CSevenDaysHandler extends CNetHandlerImp {

    public function CSevenDaysHandler() {
        super();
    }

    override protected function onSetup() : Boolean
    {
        var ret : Boolean = super.onSetup();
        this.bind( SevenDaysLoginActivityResponse,_onSevenDaysLoginActivityResponseHandler);
        return ret;
    }

    /******************S2C*********************/

    /**领取状态改变反馈**/
    private function _onSevenDaysLoginActivityResponseHandler(net:INetworking, message:CAbstractPackMessage , isError : Boolean ):void
    {
        if( isError ) return;
        var response : SevenDaysLoginActivityResponse = message as SevenDaysLoginActivityResponse;
        if( response )
        {
            if( response.gamePromptID )
            {
                _showErrorMsg( response.gamePromptID );
            }
            else
            {
                sevenDaysManager.updateSevenDaysState( response );
                system.dispatchEvent( new CSevenDaysEvent( CSevenDaysEvent.SEVEN_DAYS_REWARD_SUCCESS ) );
            }
        }
    }

    /**
     * 领取奖励
     * */
    public function getGiftRequest( day : int) : void
    {
        var request : SevenDaysLoginActivityRequest = new SevenDaysLoginActivityRequest();
        request.days = day;
        networking.post( request );
    }

    public function get sevenDaysManager() : CSevenDaysManager
    {
        return system.getBean( CSevenDaysManager ) as CSevenDaysManager;
    }

    private function _showErrorMsg( gamePromptID:int ) : void
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
