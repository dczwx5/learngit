/**
 * Created by auto on 2016/5/27.
 */
package preview.game.levelServer {
import flash.utils.Dictionary;

import kof.framework.CAppSystem;
import kof.game.common.CDelayCall;
import kof.game.levelCommon.CLevelLog;
import kof.game.levelCommon.Enum.ETrunkEventType;
import kof.game.levelCommon.Interface.ITrunkEventHandler;
import kof.game.levelCommon.info.base.CTrunkEntityBaseData;
import kof.game.levelCommon.info.event.CSceneEventInfo;
import kof.game.levelCommon.info.trunk.CTrunkConfigInfo;

import preview.game.levelServer.event.CActiveAutoTriggers;
import preview.game.levelServer.event.CActiveDeactiveAutoTrigger;
import preview.game.levelServer.event.CActiveDeactiveEventTrigger;
import preview.game.levelServer.event.CActiveDeactiveGlobalMonsterTrigger;
import preview.game.levelServer.event.CActiveDeactiveRandomTrigger;
import preview.game.levelServer.event.CActiveEventTriggers;
import preview.game.levelServer.event.CActiveGlobalMonsterTrigger;
import preview.game.levelServer.event.CActiveMapObjects;
import preview.game.levelServer.event.CActiveRandomTriggers;
import preview.game.levelServer.event.CActiveSpawnersByGroup;
import preview.game.levelServer.event.CEventPlayEffect;
import preview.game.levelServer.event.CEventPlaySceneAnimation;
import preview.game.levelServer.event.CEventScenario;
import preview.game.levelServer.event.CLockTrunks;
import preview.game.levelServer.event.CRemoveSpawnMonster;
import preview.game.levelServer.event.CTriggerSceneEventGroup;
import preview.game.levelServer.trunkState.CLevelTrunkState;

// 执行的事件. 非条件或触发
public class CLevelServerEventManager {
    private const _eventHandlerDic:Dictionary = new Dictionary();
    private var _server:CLevelServer;
    public function CLevelServerEventManager(rServer:CLevelServer) {
        _server = rServer;
        _eventHandlerDic[ETrunkEventType.ACTIVE_EVENT_TRIGGERS] = new CActiveEventTriggers();
        _eventHandlerDic[ETrunkEventType.ACTIVE_AUTO_TRIGGERS] = new CActiveAutoTriggers();
        _eventHandlerDic[ETrunkEventType.ACTIVE_GLOBAL_MONSTER_TRIGGER] = new CActiveGlobalMonsterTrigger();
        _eventHandlerDic[ETrunkEventType.ACTIVE_RANDOM_TRIGGER] = new CActiveRandomTriggers();
        _eventHandlerDic[ETrunkEventType.ACTIVE_MAP_OBJECT] = new CActiveMapObjects();
        _eventHandlerDic[ETrunkEventType.ACTIVE_SPAWWNERS] = new CActiveSpawnersByGroup();
        _eventHandlerDic[ETrunkEventType.ACTIVE_DEACTIVE_EVENTTRIGGER] = new CActiveDeactiveEventTrigger();
        _eventHandlerDic[ETrunkEventType.ACTIVE_DEACTIVE_AUTOTRIGGER] = new CActiveDeactiveAutoTrigger();
        _eventHandlerDic[ETrunkEventType.ACTIVE_DEACTIVE_GLOBALMONSTERTRIGGER] = new CActiveDeactiveGlobalMonsterTrigger();
        _eventHandlerDic[ETrunkEventType.ACTIVE_DEACTIVE_RANDOMTRIGGER] = new CActiveDeactiveRandomTrigger();


        _eventHandlerDic[ETrunkEventType.LOCK_TRUNKS] = new CLockTrunks();
        _eventHandlerDic[ETrunkEventType.SCENARIO] = new CEventScenario();
        _eventHandlerDic[ETrunkEventType.PLAY_SCENE_ANIMATION] = new CEventPlaySceneAnimation(1);
        _eventHandlerDic[ETrunkEventType.PLAY_SCENE_EFFECT] = new CEventPlayEffect(1);
        _eventHandlerDic[ETrunkEventType.PLAY_EFFECT] = new CEventPlayEffect(2);
        _eventHandlerDic[ETrunkEventType.PLAY_ANIMATION] = new CEventPlaySceneAnimation(2);

        _eventHandlerDic[ETrunkEventType.TRIGGER_SCENE_EVENT_GROUP] = new CTriggerSceneEventGroup();
        _eventHandlerDic[ETrunkEventType.REMOVE_SPAWNED_MONSTER] = new CRemoveSpawnMonster();


        _eventMessageQueue = new Vector.<CEventMessage>();
    }
    public function dispose() : void {
        _eventMessageQueue = null;
    }

    // trunk事件
    public function handlerTrunkEvent(trunkInfo:CTrunkConfigInfo, eventName:String) : void {
        if (!trunkInfo) return;

        CLevelLog.addDebugLog("------trunk event : trunk " + trunkInfo.ID + ", event : " + eventName);
        var eventsArrName:String = eventName + "Events";
        var eventArr:Array = eventsArrName in trunkInfo ? trunkInfo[eventsArrName] : null; // 某种事件数组
        if (!eventArr || eventArr.length == 0) return;

        if(CLevelTrunkState._PASS == eventName){
            _server.sender.sendTrunkTargetComplete();
            return;
        }
        handlerEvent(trunkInfo.ID, eventArr);
    }

    public function handlerEvent(trunkId:int, events:Array) : void {
        for each (var eventData:CSceneEventInfo in events) {
            CLevelLog.addDebugLog("------entity event put in queue : trunkId : + " + trunkId + ", event :" + eventData.name);
            pushEventInQueue(trunkId, eventData);
        }
    }
    public function pushEventInQueue(trunkId:int, eventInfo:CSceneEventInfo):void {
        var eventMessage:CEventMessage = new CEventMessage();
        eventMessage.trunkId = trunkId;
        eventMessage.eventInfo = eventInfo;
        _eventMessageQueue.push(eventMessage);
    }


    // ==============================
    private const _delayedCalls:Array = [];
    public function clearDelayedCall():void {
        for (var i:int = 0, len:int = _delayedCalls.length; i < len; ++i) {
//            var dc:DelayedCall = _delayedCalls[i];
//            dc.reset(null, 1);
//            Starling.juggler.remove(dc);
        }
        _delayedCalls.length = 0;
    }

    public function update(delta:Number) : void {
        if (_eventMessageQueue == null || _eventMessageQueue.length == 0) return ;

        while(_eventMessageQueue.length > 0) {
            var eventMessage:CEventMessage = _eventMessageQueue.shift();
            _handleSingleEvent(eventMessage.trunkId, eventMessage.eventInfo);
        }
    }

    private function _handleSingleEvent(trunkId:int, eventInfo:CSceneEventInfo):void {
        CLevelLog.addDebugLog("------entity event : trunkId : + " + trunkId + ", event :" + eventInfo.name);

        var handler:ITrunkEventHandler = _eventHandlerDic[eventInfo.name];

        if (handler) {
            if(eventInfo.delay > 0) {
                _delayCallCount++;
                new CDelayCall(_delayHandler, eventInfo.delay, [handler.handler,_server.system, trunkId, eventInfo]);
            } else {
                handler.handler(_server.system, trunkId, eventInfo);
            }
        }
    }
    private function _delayHandler(handler:Function, system:CAppSystem, trunkID:int, sceneEvent:CSceneEventInfo) : void {
        handler(system, trunkID, sceneEvent);
        _delayCallCount--;
    }


    // trunk entity event
    public function handlerTrunkEntityEvent(trunkInfo:CTrunkConfigInfo, entityType:int, entityID:int, eventName) : void {
        if (!trunkInfo) return;

        var trunkEntityCfgInfo:CTrunkEntityBaseData = trunkInfo.getEntityById(entityType, entityID);
        if (!trunkEntityCfgInfo) return;

        var eventsArrName:String = eventName + "Events";
        var eventArr:Array = eventsArrName in trunkEntityCfgInfo ? trunkEntityCfgInfo[eventsArrName] : null;
        if (!eventArr || eventArr.length == 0) return;

        handlerEvent(trunkInfo.ID, eventArr);
    }

    public function get hasDelayCall() : Boolean {
        return _delayCallCount != 0;
    }


    private var _delayCallCount:int;
    private var _eventMessageQueue:Vector.<CEventMessage>;
}
}

import kof.game.levelCommon.info.event.CSceneEventInfo;

class CEventMessage {
    public var trunkId:int
    public var eventInfo:CSceneEventInfo;
}