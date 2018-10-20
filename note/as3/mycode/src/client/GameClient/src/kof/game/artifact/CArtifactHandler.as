//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/4/19.
 */
package kof.game.artifact {

import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.framework.INetworking;
import kof.game.artifact.view.CArtifactViewHandler;
import kof.game.common.system.CNetHandlerImp;
import kof.message.Artifact.ArtifactBreakthroughRequest;
import kof.message.Artifact.ArtifactBreakthroughResponse;
import kof.message.Artifact.ArtifactListRequest;
import kof.message.Artifact.ArtifactListResponse;
import kof.message.Artifact.ArtifactOpenRequest;
import kof.message.Artifact.ArtifactOpenResponse;
import kof.message.Artifact.ArtifactPurifyRequest;
import kof.message.Artifact.ArtifactPurifyResponse;
import kof.message.Artifact.ArtifactSoulBreakRequest;
import kof.message.Artifact.ArtifactSoulBreakResponse;
import kof.message.Artifact.ArtifactSoulOpenRequest;
import kof.message.Artifact.ArtifactSoulOpenResponse;
import kof.message.Artifact.ArtifactUpgradeRequest;
import kof.message.Artifact.ArtifactUpgradeResponse;
import kof.message.Artifact.PropertyReplaceRequest;
import kof.message.Artifact.PropertyReplaceResponse;
import kof.message.CAbstractPackMessage;
import kof.table.GamePrompt;
import kof.ui.CUISystem;

public class CArtifactHandler extends CNetHandlerImp {

    private var lockBool:Boolean;

    public function CArtifactHandler() {
        super();
    }

    override protected function onSetup():Boolean
    {
        var ret:Boolean = super.onSetup();
        _addEventListeners();
        artifactListRequest();
        return ret;
    }

    private function _addEventListeners():void
    {
        networking.bind(ArtifactListResponse).toHandler(_onArtifactListResponse);
        networking.bind(ArtifactOpenResponse).toHandler(_onArtifactOpenResponse);
        networking.bind(ArtifactUpgradeResponse).toHandler(_onArtifactUpgradeResponse);
        networking.bind(ArtifactPurifyResponse).toHandler(_onArtifactPurifyResponse);
        networking.bind(ArtifactBreakthroughResponse).toHandler(_onArtifactBreakthroughResponse);
        networking.bind(PropertyReplaceResponse).toHandler(_onPropertyReplaceResponse);
        networking.bind(ArtifactSoulOpenResponse).toHandler(_onArtifactSoulUnLock);
        networking.bind(ArtifactSoulBreakResponse).toHandler(_onArtifactSouldBreachResponse);
    }
    private function _onPropertyReplaceResponse(net:INetworking, message:CAbstractPackMessage):void{
        var response:PropertyReplaceResponse = message as PropertyReplaceResponse;
        var manager:CArtifactManager = system.getBean(CArtifactManager) as CArtifactManager;
        (system.getBean(CArtifactManager) as CArtifactManager).showSoulPropertyChangeMsg(response.dataMap);
        manager.updateSoul(response.dataMap);
        system.dispatchEvent( new CArtifactEvent(CArtifactEvent.ARTIFACTUPDATE,null));
        lockBool = false;
    }

    private function _onArtifactBreakthroughResponse(net:INetworking, message:CAbstractPackMessage):void{
        var response:ArtifactBreakthroughResponse = message as ArtifactBreakthroughResponse;
        var manager:CArtifactManager = system.getBean(CArtifactManager) as CArtifactManager;
        var isSucces:Boolean = manager.showArtifactPropertyChangeMsg(response.dataMap);
        manager.update(response.dataMap);
        if (isSucces) {
            (system.getBean(CArtifactViewHandler) as CArtifactViewHandler).playBreakEffect();
        }
        lockBool = false;
    }

    private function _onArtifactUpgradeResponse(net:INetworking, message:CAbstractPackMessage):void{
        var response:ArtifactUpgradeResponse = message as ArtifactUpgradeResponse;
        var manager:CArtifactManager = system.getBean(CArtifactManager) as CArtifactManager;
        if(response.dataMap.artifactLevel > manager.getArtifactByID( response.dataMap.artifactID ).artifactLevel){
            manager.showArtifactPropertyChangeMsg(response.dataMap);
        }
        manager.update(response.dataMap);
        lockBool = false;
    }

    private function _onArtifactPurifyResponse(net:INetworking, message:CAbstractPackMessage):void{
        var response:ArtifactPurifyResponse = message as ArtifactPurifyResponse;
        lockBool = false;
    }

    private function _onArtifactOpenResponse(net:INetworking, message:CAbstractPackMessage):void {
        var response:ArtifactOpenResponse = message as ArtifactOpenResponse;
        if(response.gamePromptID != 0){
            return;
        }
        (system.getBean(CArtifactViewHandler) as CArtifactViewHandler).playUnlockEffect();
        lockBool = false;
    }

    private final function _onArtifactListResponse(net:INetworking, message:CAbstractPackMessage):void {
        var response:ArtifactListResponse = message as ArtifactListResponse;
        if(response.gamePromptID != 0) {
            var gamePromptTable:IDataTable = (system.stage.getSystem(IDatabase) as IDatabase).getTable(KOFTableConstants.GAME_PROMPT);
            if (gamePromptTable != null) {
                var promptCfg:GamePrompt = gamePromptTable.findByPrimaryKey(response.gamePromptID) as GamePrompt;
                var uiSystem:CUISystem = (system.stage.getSystem( CUISystem ) as CUISystem);
                if (promptCfg != null && uiSystem != null) {
                    uiSystem.showMsgAlert(promptCfg.content);
                }
            }
            return;
        }

        (system.getBean(CArtifactManager) as CArtifactManager).m_data = response.artifactList;
        system.dispatchEvent( new CArtifactEvent(CArtifactEvent.ARTIFACTUPDATE,null));
        lockBool = false;
    }

    private function _onArtifactSoulUnLock(net:INetworking, message:CAbstractPackMessage):void{
        var response:ArtifactSoulOpenResponse = message as ArtifactSoulOpenResponse;
        var manager:CArtifactManager = system.getBean(CArtifactManager) as CArtifactManager;
        manager.unLockSoul(response.artifactID, response.artifactSoulID);
        system.dispatchEvent( new CArtifactEvent(CArtifactEvent.ARTIFACTUPDATE,null));
        system.dispatchEvent( new CArtifactEvent(CArtifactEvent.ARTIFACT_SOUL_UNLOCK_SUCCESS, response.artifactSoulID));
    }

    private function _onArtifactSouldBreachResponse(net:INetworking, message:CAbstractPackMessage):void{
        var response:ArtifactSoulBreakResponse = message as ArtifactSoulBreakResponse;
        var manager:CArtifactManager = system.getBean(CArtifactManager) as CArtifactManager;
        manager.breakSoul(response.artifactID, response.artifactSoulID);
        system.dispatchEvent( new CArtifactEvent(CArtifactEvent.ARTIFACTUPDATE,null));
    }

    //查询神器
    public function artifactListRequest():void{
        if(lockBool)return;
        lockBool = true;
        var artifactListRequest:ArtifactListRequest = new ArtifactListRequest();
        artifactListRequest.info = 1;
        networking.post(artifactListRequest);
    }

    //解锁神器
    public function artifactOpenRequest(id:int):void{
        if(lockBool)return;
        lockBool = true;
        var artifactOpenRequest:ArtifactOpenRequest = new ArtifactOpenRequest();
        artifactOpenRequest.artifactID = id;
        networking.post(artifactOpenRequest);
    }

    // 神器强化请求
    public function artifactUpgradeRequest(id:int,type:int):void{
        if(lockBool)return;
        lockBool = true;
        var artifactUpgradeRequest:ArtifactUpgradeRequest = new ArtifactUpgradeRequest();
        artifactUpgradeRequest.artifactID = id;
        artifactUpgradeRequest.type = type;
        networking.post(artifactUpgradeRequest);
    }

    //神器突破
    public function artifactBreakthroughRequest(id:int):void{
        if(lockBool)return;
        lockBool = true;
        var artifactBreakthroughRequest:ArtifactBreakthroughRequest = new ArtifactBreakthroughRequest();
        artifactBreakthroughRequest.artifactID = id;
        networking.post(artifactBreakthroughRequest);
    }

    // 神器洗练请求
    public function artifactPurifyRequest(id:int, purifyId:int):void{
        if(lockBool)return;
        lockBool = true;
        var artifactUpgradeRequest:ArtifactPurifyRequest = new ArtifactPurifyRequest();
        artifactUpgradeRequest.artifactID = id;
        artifactUpgradeRequest.artifactSoulID = purifyId;
        networking.post(artifactUpgradeRequest);
    }

    //替换属性
    public function propertyReplaceRequest(id:int, purifyId:int):void{
        if(lockBool)return;
        lockBool = true;
        var propertyReplaceRequest:PropertyReplaceRequest = new PropertyReplaceRequest();
        propertyReplaceRequest.artifactID = id;
        propertyReplaceRequest.artifactSoulID = purifyId;
        networking.post(propertyReplaceRequest);
    }

    //神灵解锁
    public function artifactSoulUnLock(artifactID:int, artifactSoulID:int):void{
        var artifactSoulOpenRequest:ArtifactSoulOpenRequest = new ArtifactSoulOpenRequest();
        artifactSoulOpenRequest.artifactID = artifactID;
        artifactSoulOpenRequest.artifactSoulID = artifactSoulID;
        networking.post(artifactSoulOpenRequest);
    }

    //神灵突破
    public function artifactSoulBreachRequest(artifactID:int, artifactSoulID:int):void{
        var artifactBreakthroughRequest:ArtifactSoulBreakRequest = new ArtifactSoulBreakRequest();
        artifactBreakthroughRequest.artifactID = artifactID;
        artifactBreakthroughRequest.artifactSoulID = artifactSoulID;
        networking.post(artifactBreakthroughRequest);
    }
}
}
