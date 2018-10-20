//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/1/5.
 */
package kof.game.mainnotice {

import kof.framework.CSystemHandler;
import kof.framework.INetworking;
import kof.framework.network.CNetworkMessageScopes;
import kof.game.mainnotice.data.CMainNoticeData;
import kof.game.mainnotice.data.CMainNoticeEvent;
import kof.message.CAbstractPackMessage;
import kof.message.Player.PlayerGamePromptResponse;

public class CMainNoticeHandler extends CSystemHandler {
    public function CMainNoticeHandler() {
        super();
    }
    override protected function onSetup():Boolean {
        var ret:Boolean = super.onSetup();

        networking.bind(PlayerGamePromptResponse).toHandler(networking_broadcastMessageHandler).inScope(CNetworkMessageScopes.NO_SCOPES);

        return ret;
    }

    /** @private */
    private function networking_broadcastMessageHandler(net:INetworking, message:CAbstractPackMessage):void {
        
        var response:PlayerGamePromptResponse = message as PlayerGamePromptResponse;

        var list:CMainNoticeMessageList = system.getBean(CMainNoticeMessageList) as CMainNoticeMessageList;

        for each( var obj:Object in response.gamePromptList ){
            var mainNoticeData:CMainNoticeData = new CMainNoticeData();
            mainNoticeData.initialData(obj);
            _pMainNoticeMessageList.push( mainNoticeData );
        }

        system.dispatchEvent( new CMainNoticeEvent( CMainNoticeEvent.MAIN_NOTICE_UPDATE  ));

//        var pCMainNoticeViewHandler:CMainNoticeViewHandler = system.getBean(CMainNoticeViewHandler) as CMainNoticeViewHandler;
//        pCMainNoticeViewHandler.invalidate();
//
//        var pCMainNoticePanelViewHandler:CMainNoticePanelViewHandler = system.getBean(CMainNoticePanelViewHandler) as CMainNoticePanelViewHandler;
//        pCMainNoticePanelViewHandler.invalidate();
    }

    private function get _pMainNoticeMessageList():CMainNoticeMessageList{
        return system.getBean( CMainNoticeMessageList ) as CMainNoticeMessageList;
    }
}
}
