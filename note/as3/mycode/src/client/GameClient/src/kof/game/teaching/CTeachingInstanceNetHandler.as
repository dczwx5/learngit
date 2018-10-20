//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by dendi on 2018/1/29.
 */
package kof.game.teaching {

import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.framework.INetworking;
import kof.game.common.system.CNetHandlerImp;
import kof.message.CAbstractPackMessage;
import kof.message.Teaching.TeachingChallengeRequest;
import kof.message.Teaching.TeachingChallengeResponse;
import kof.message.Teaching.TeachingInfoRequest;
import kof.message.Teaching.TeachingInfoResponse;
import kof.message.Teaching.TeachingInstanceInfoUpdateResponse;
import kof.message.Teaching.TeachingRewardRequest;
import kof.message.Teaching.TeachingRewardResponse;
import kof.table.GamePrompt;
import kof.ui.CMsgAlertHandler;
import kof.ui.CUISystem;

public class CTeachingInstanceNetHandler extends CNetHandlerImp {

    public function CTeachingInstanceNetHandler() {
        super();
    }

    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        _addEventListeners();
        sendTeachingInfoRequest();
        return ret;
    }

    private function _addEventListeners() : void {
        networking.bind( TeachingInfoResponse ).toHandler( _onTeachingInfoResponse );
        networking.bind( TeachingInstanceInfoUpdateResponse ).toHandler( _onTeachingInstanceInfoUpdateResponse );
        networking.bind( TeachingRewardResponse ).toHandler( _onTeachingRewardResponse );
        networking.bind( TeachingChallengeResponse ).toHandler( _onTeachingChallengeResponse );
    }

    private function _onTeachingChallengeResponse( net : INetworking, message : CAbstractPackMessage ) : void {
        var response : TeachingChallengeResponse = message as TeachingChallengeResponse;
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

    private function _onTeachingRewardResponse( net : INetworking, message : CAbstractPackMessage ) : void {
        var response : TeachingRewardResponse = message as TeachingRewardResponse;
        if(response.gamePromptID == 0){
            (system.getHandler(CTeachingInstanceViewHandler) as CTeachingInstanceViewHandler).flyItem();
            (system.getHandler(CTeachingInstanceViewHandler) as CTeachingInstanceViewHandler).updateView();
            var inletSystem:CTeachingMainInletSystem = (system.stage.getSystem(CTeachingMainInletSystem) as CTeachingMainInletSystem);
            if(inletSystem)
                inletSystem.onRedPoint();
        }

    }

    private function _onTeachingInstanceInfoUpdateResponse( net : INetworking, message : CAbstractPackMessage ) : void {
        var response : TeachingInstanceInfoUpdateResponse = message as TeachingInstanceInfoUpdateResponse;
        var manager:CTeachingInstanceManager = (system.getHandler(CTeachingInstanceManager) as CTeachingInstanceManager);
        manager.setTeachingData( response.instanceInfo );
        (system.getHandler(CTeachingInstanceViewHandler) as CTeachingInstanceViewHandler).updateView();
        var inletSystem:CTeachingMainInletSystem = (system.stage.getSystem(CTeachingMainInletSystem) as CTeachingMainInletSystem);
        if(inletSystem)
            inletSystem.onRedPoint();
    }

    private function _onTeachingInfoResponse( net : INetworking, message : CAbstractPackMessage ) : void {
        var response : TeachingInfoResponse = message as TeachingInfoResponse;
        var manager:CTeachingInstanceManager = (system.getHandler(CTeachingInstanceManager) as CTeachingInstanceManager);
        for each(var item:Object in response.instanceInfoList){
            manager.setTeachingData(item);
        }
        (system.getHandler(CTeachingInstanceViewHandler) as CTeachingInstanceViewHandler).updateView();
        var inletSystem:CTeachingMainInletSystem = (system.stage.getSystem(CTeachingMainInletSystem) as CTeachingMainInletSystem);
        if(inletSystem)
            inletSystem.onRedPoint();
    }

    //=============send=======================
    //请求内容
    public function sendTeachingInfoRequest() : void {
        var teachingInfoRequest : TeachingInfoRequest = new TeachingInfoRequest();
        teachingInfoRequest.flag = 1;
        networking.post( teachingInfoRequest );
    }

    //领取奖励
    public function sendTeachingRewardRequest( TeachingID : int ) : void {
        var teachingRewardRequest : TeachingRewardRequest = new TeachingRewardRequest();
        teachingRewardRequest.teachingContentID = TeachingID;
        networking.post( teachingRewardRequest );
    }

    //开始挑战
    public function sendTeachingChallengeRequest( TeachingID : int ) : void {
        var teachingChallengeRequest : TeachingChallengeRequest = new TeachingChallengeRequest();
        teachingChallengeRequest.teachingContentID = TeachingID;
        networking.post( teachingChallengeRequest );
    }
}
}