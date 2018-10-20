/**
 * Created by auto on 2016/6/29.
 */
package preview.game.levelServer {

import QFLib.Interface.IDisposable;

import kof.game.level.CLevelTypeExchange;
import kof.game.levelCommon.Enum.ELevelEventType;
import kof.game.levelCommon.info.base.CTrunkObjectEventData;
import preview.game.levelServer.data.CLevelSceneMonsterData;
import preview.game.levelServer.data.CLevelSceneObjectData;
import preview.game.levelServer.event.map.CTrunkMonsterDeadEvent;
import kof.message.Fight.HitRequest;
import kof.message.Level.AppearingWaysEndRequest;
import kof.message.Level.EndScenarioRequest;
import kof.message.Level.TruckPassEventRequest;
import kof.message.Map.CharacterDeadRequest;
import kof.message.Scene.ClientReadyRequest;

/**
 * 处理客户端发过来的消息
 */
public class CLevelServerHandler implements IDisposable {

     public function CLevelServerHandler(levelServer:CLevelServer) {
        _levelServer = levelServer;
    }

    public function dispose() : void {
        _levelServer = null;
    }

    //////////////////////////////////////监听客户端过来的消息///////////////////////////////////////////
    private function _passedEventFun(request:TruckPassEventRequest):void{
        _levelServer.passedStateFun();
    }

    private function  _appearingWaysEndFun(request:AppearingWaysEndRequest):void{
        var spawner:CTrunkObjectEventData =_levelServer.curTrunkData.trunkInfo.getEntityById(request.type, request.ID) as CTrunkObjectEventData;
        if (spawner.readyEvents && spawner.readyEvents.length > 0) {
            _levelServer.serverEnventManager.handlerEvent(_levelServer.curTrunkData.trunkInfo.ID, spawner.readyEvents);
            spawner.readyEvents = null;
        }
    }

    private function _onCharacterUpdate(request:HitRequest):void{
        for each (var obj:Object in  request.targets){
            var sceneObject:CLevelSceneObjectData = _levelServer.sceneObjectHandler.getSceneObject(obj.type, obj.ID);
            if(sceneObject){
                (sceneObject as CLevelSceneMonsterData).HP = obj.dynamicStates.curHp;
                (sceneObject as CLevelSceneMonsterData).attackPower = obj.dynamicStates.attackPower;
                (sceneObject as CLevelSceneMonsterData).defensePower = obj.dynamicStates.defensePower;

                if((sceneObject as CLevelSceneMonsterData).HP <= 0)
                {
                    _levelServer.sender.sendMonsterDead(sceneObject.uniID, sceneObject.gameObjectType);
                }

                var entityType:int = CLevelTypeExchange.ExchangeCharacterTypeToEntityType(obj.type);
                var spawner:CTrunkObjectEventData =_levelServer.curTrunkData.trunkInfo.getEntityById(entityType, sceneObject.entityID) as CTrunkObjectEventData;
                if (spawner && spawner.hitEvents && spawner.hitEvents.length > 0) {
                    _levelServer.serverEnventManager.handlerEvent(_levelServer.curTrunkData.trunkInfo.ID, spawner.hitEvents);
                    spawner.hitEvents = null;
                }
            }
        }
    }


    private function _onCharacterDead(request:CharacterDeadRequest) : void {
        var entityType:int = CLevelTypeExchange.ExchangeCharacterTypeToEntityType(request.type);
        var sceneObject:CLevelSceneObjectData = _levelServer.sceneObjectHandler.getSceneObject(entityType, request.id);
        var monsterID:int = sceneObject.objectID;
        var entityID:int = sceneObject.entityID;

        // 通知服务器内部处理怪物死亡
        _levelServer.dispatchEvent(new CTrunkMonsterDeadEvent(ELevelEventType.MONSTER_DIE, entityType, monsterID, request.id));

        if (_levelServer.curTrunkData && _levelServer.curTrunkData.trunkInfo) {
            var spawner:CTrunkObjectEventData =_levelServer.curTrunkData.trunkInfo.getEntityById(entityType, entityID) as CTrunkObjectEventData;
            if (spawner.dieEvents && spawner.dieEvents.length > 0) {
                _levelServer.serverEnventManager.handlerEvent(_levelServer.curTrunkData.trunkInfo.ID, spawner.dieEvents);
            }
        }

    }
    private function _onScenarioEnd(request:EndScenarioRequest) : void {
        // 剧情结束

        _levelServer.onScenarioEnd(request.scenarioID);
    }

    private function _onClientReady(request:ClientReadyRequest) : void {
        _levelServer.onClientReady();
    }


    private var _levelServer:CLevelServer;
}
}
