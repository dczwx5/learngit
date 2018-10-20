//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/7/27.
 */
package kof.game.resourceInstance {

import QFLib.Framework.CObject;
import QFLib.Framework.CScene;
import QFLib.Math.CVector2;
import QFLib.Math.CVector3;

import kof.framework.INetworking;
import kof.game.common.system.CNetHandlerImp;
import kof.game.core.CGameObject;
import kof.game.instance.enum.EInstanceType;
import kof.game.resourceInstance.view.CGoldInstanceViewHandler;
import kof.game.resourceInstance.view.CResourceInstanceViewHandler;
import kof.game.resourceInstance.view.CTrainInstanceViewHandler;
import kof.game.scene.CSceneRendering;
import kof.game.scene.CSceneSystem;
import kof.game.scene.ISceneFacade;
import kof.message.CAbstractPackMessage;
import kof.message.Instance.ExpInstanceUpResourceResponse;
import kof.message.Instance.ResourceInstanceChallengeRequest;
import kof.message.Instance.ResourceInstanceChallengeResponse;
import kof.message.Instance.ResourceInstanceDamageStartResponse;
import kof.message.Instance.ResourceInstanceDamageUpdateResponse;
import kof.message.Instance.ResourceInstanceInfoRequest;
import kof.message.Instance.ResourceInstanceInfoResponse;
import kof.message.Instance.ResourceInstanceUpResourceResponse;
import kof.message.Instance.ResourceInstanceUpdateResponse;
import kof.message.Level.MonsterRoundResponse;

public class CResourceInstanceHandler extends CNetHandlerImp {

    public function CResourceInstanceHandler() {
        super();
    }

    override protected function onSetup():Boolean {
        var ret:Boolean = super.onSetup();

        this.bind(ResourceInstanceInfoResponse, _onResourceInstanceInfoResponse);
        this.bind(ResourceInstanceUpdateResponse, _onResourceInstanceUpdateResponse);
        this.bind(ResourceInstanceUpResourceResponse, _onResourceInstanceUpResourceResponse);
        this.bind(ResourceInstanceDamageStartResponse, _onResourceInstanceDamageStartResponse);
        this.bind(ResourceInstanceDamageUpdateResponse, _onResourceInstanceDamageUpdateResponse);
        this.bind(ResourceInstanceChallengeResponse, _onResourceInstanceChallengeResponse);
        this.bind(MonsterRoundResponse, _onMonsterRoundResponse);
        this.bind(ExpInstanceUpResourceResponse, _onExpInstanceUpResourceResponse);

        onResourceInstanceInfoRequest();
        return ret;
    }

    private function _onMonsterRoundResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void{
        if(isError)return;

        var response:MonsterRoundResponse = message as MonsterRoundResponse;
        (system as CResourceInstanceSystem).round(response);
    }
    private function _onExpInstanceUpResourceResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void{
        if(isError)return;

        var response:ExpInstanceUpResourceResponse = message as ExpInstanceUpResourceResponse;
        response.rewardList;
        (system as CResourceInstanceSystem).updateExpAward(response);
    }

    private function _onResourceInstanceDamageStartResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void{

        if(isError)return;

        var response:ResourceInstanceDamageStartResponse = message as ResourceInstanceDamageStartResponse;
        (system as CResourceInstanceSystem).startTime(response.time);
    }

    private function _onResourceInstanceDamageUpdateResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void{

        if(isError)return;

        var response:ResourceInstanceDamageUpdateResponse = message as ResourceInstanceDamageUpdateResponse;
        (system as CResourceInstanceSystem).updateDamageValue(response.damage);
    }

    private function _onResourceInstanceUpdateResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void{

        if(isError)return;

        var response:ResourceInstanceUpdateResponse = message as ResourceInstanceUpdateResponse;
        if(response.info.type == EInstanceType.TYPE_GOLD_INSTANCE ){
            (system.getHandler(CGoldInstanceViewHandler) as CGoldInstanceViewHandler).update(response.info);
        }else if(response.info.type == EInstanceType.TYPE_TRAIN_INSTANCE ){
            (system.getHandler(CTrainInstanceViewHandler) as CTrainInstanceViewHandler).update(response.info);
        }
        (system.getHandler(CResourceInstanceViewHandler) as CResourceInstanceViewHandler).update([response.info]);
    }

    private function _onResourceInstanceInfoResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void{

        if(isError)return;

        var response:ResourceInstanceInfoResponse = message as ResourceInstanceInfoResponse;
        var info:Array = response.infoList;
        (system.getHandler(CResourceInstanceManager) as CResourceInstanceManager).m_data = info;
        (system.getHandler(CResourceInstanceViewHandler) as CResourceInstanceViewHandler).update(info);
        for each( var item:Object in info) {
            if ( item.type == EInstanceType.TYPE_GOLD_INSTANCE ) {
                (system.getHandler(CGoldInstanceViewHandler) as CGoldInstanceViewHandler).update(item);
            } else if(item.type == EInstanceType.TYPE_TRAIN_INSTANCE ){
                (system.getHandler(CTrainInstanceViewHandler) as CTrainInstanceViewHandler).update(item);
            }
        }

        (system as CResourceInstanceSystem).onRedPoint();
    }

    private function _onResourceInstanceUpResourceResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void{

        if(isError)return;

        var response:ResourceInstanceUpResourceResponse = message as ResourceInstanceUpResourceResponse;
        var m_pSceneFacade : ISceneFacade = system.stage.getSystem( ISceneFacade ) as ISceneFacade;
        var monsterObj:CGameObject = m_pSceneFacade.findMonster(response.fighterID);
        if(monsterObj && monsterObj.isRunning){
            var monsterX:int = monsterObj.transform.x;
            var monsterZ:int = monsterObj.transform.y - 500;
            var monsterY:int = monsterObj.transform.z;

            var vector3:CVector3 = CObject.get2DPositionFrom3D( monsterX, monsterY, monsterZ );
            var vector2:CVector2 = new CVector2(vector3.x, vector3.y);
            var scene:CScene = ((system.stage.getSystem(CSceneSystem) as CSceneSystem).getBean(CSceneRendering) as CSceneRendering).scene;
            if (scene) {
                scene.mainCamera.worldToScreen(vector2);
            }
            (system as CResourceInstanceSystem).showGoldFlyView(response.totalValue,vector2,response.monsterNums);
        }
    }

    private function _onResourceInstanceChallengeResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void{
        if(isError){
            (system as CResourceInstanceSystem).unEvent();
            return;
        }

        var response:ResourceInstanceChallengeResponse = message as ResourceInstanceChallengeResponse;
        response.gamePromptID == 0;

    }


    /**********************Request********************************/
    public function onResourceInstanceInfoRequest():void{
        var request:ResourceInstanceInfoRequest = new ResourceInstanceInfoRequest();
        request.flag = 1;

        networking.post(request);
    }

    public function onResourceInstanceChallengeRequest(instanceType:int, difficulty:int):void{

        var request:ResourceInstanceChallengeRequest = new ResourceInstanceChallengeRequest();
        request.type = instanceType;
        request.difficulty = difficulty;

        networking.post(request);

    }
}
}
