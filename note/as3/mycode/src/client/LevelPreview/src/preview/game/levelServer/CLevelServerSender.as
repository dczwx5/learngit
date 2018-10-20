/**
 * Created by auto on 2016/6/29.
 */
package preview.game.levelServer {

import flash.geom.Point;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.game.levelCommon.CLevelLog;
import kof.game.levelCommon.info.base.CTrunkEntityBaseData;
import kof.game.levelCommon.info.base.CTrunkObjectEventData;
import kof.game.levelCommon.info.entity.CTrunkEntityMapObject;
import kof.game.levelCommon.info.entity.CTrunkEntityMonster;
import preview.game.levelServer.protocol.CEnterLevelResponse;
import kof.message.Fight.FighterDeadResponse;
import kof.message.Instance.InstanceOverResponse;
import kof.message.Level.ActivePortalResponse;
import kof.message.Level.ActiveTruckResponse;
import kof.message.Level.ClearanceTruckResponse;
import kof.message.Level.EnterTruckResponse;
import kof.message.Level.LockScreenResponse;
import kof.message.Level.PlayAnimationResponse;
import kof.message.Level.PlayEffectResponse;
import kof.message.Level.StartScenarioResponse;
import kof.message.Level.TruckTargetPassResponse;
import kof.message.Map.CharacterAddResponse;
import kof.message.Map.CharacterRemovedResponse;

/**
 * 给客户端发消息
 */
public class CLevelServerSender {
    public function CLevelServerSender(levelServer:CLevelServer) {
        _levelServer = levelServer;
    }

    public function enterLevel(fileName:String) : void {
        var response:CEnterLevelResponse = new CEnterLevelResponse();
        response.fileName = fileName;
//        _dummyServer.send(response);
        CLevelLog.addDebugLog("server : send enter level");
    }


    private static var _id:int = 0;
    public function spawnMonsters(entity:CTrunkEntityBaseData) : void {
        var monsterList:Array = new Array();
        var monsterTable:IDataTable = (_levelServer.system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.MONSTER);

        var monster:CTrunkEntityMonster;
        monster = entity as CTrunkEntityMonster;
        if (monster) {
            // monster.buildSpawnID();
            var count:int = monster.count;
            for(var i:int = 0; i<count; i++)
            {
                monsterList.push({
                    id: ++_id, // obj.tribeID,
                    entityType:monster.type, type:monster.tribe, x:monster.location.x, y:monster.location.y, delay:monster.delay, spawnID:monster.spawnID, entityID:monster.ID, direction: monster.ori,campID:monster.tribeID, objectID:monster.objectID
                });
            }
            if (monsterTable.findByPrimaryKey(monster.spawnID) == null) {
                CLevelLog.addDebugLog("monster ID error : " + monster.spawnID);
            }
        }

        var response : CharacterAddResponse = new CharacterAddResponse();
        response.data = [];
        var nSpawnCount : uint = monsterList.length;
        for ( i = 0; i < nSpawnCount; ++i ) {
            var spawnRoleData : Object = new Object();
            var m : Object = monsterList[ i ];
            spawnRoleData.id = m[ "id" ]; // m_roleData.roleID + 1 + i;
            spawnRoleData.type = 2; // m["type"]; // int(randomInt(1, 2));
            spawnRoleData.prototypeID = m["spawnID"]; // 10; // int(randomValue([10])); // damen bu hui dong
            spawnRoleData.name = "[NPC] DaMEN";
            spawnRoleData.x = m[ "x" ]; // randomInt(40, 80);
            spawnRoleData.y = m[ "y" ]; // randomInt(10, 22);
            spawnRoleData.entityID = m["entityID"];
            spawnRoleData.direction = m["direction"];
            spawnRoleData.entityType = m["entityType"];
            spawnRoleData.campID = m["campID"];
            spawnRoleData.objectID = m["objectID"];

            response.data.push( spawnRoleData );

            _levelServer.sceneObjectHandler.addSceneObject(spawnRoleData);

            var spawner:CTrunkObjectEventData =_levelServer.curTrunkData.trunkInfo.getEntityById(spawnRoleData.entityType,  spawnRoleData.entityID) as CTrunkObjectEventData;
            if (spawner.appearEvents && spawner.appearEvents.length > 0) {
                _levelServer.serverEnventManager.handlerEvent(_levelServer.curTrunkData.trunkInfo.ID, spawner.appearEvents);
                spawner.appearEvents = null;
            }
            if (monster.appearType == 0 && spawner.readyEvents && spawner.readyEvents.length > 0) {
                _levelServer.serverEnventManager.handlerEvent(_levelServer.curTrunkData.trunkInfo.ID, spawner.readyEvents);
                spawner.readyEvents = null;
            }
        }
//        _dummyServer.send( response );
    }
    public function spawnMapObjects(findEntities:Vector.<CTrunkEntityBaseData>) : void {
        var monsterList:Array = new Array();
        if (findEntities.length > 0) {
            var mapObjectTable:IDataTable= (_levelServer.system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.MAP_OBJECT);

            var mapObject:CTrunkEntityMapObject;
            for each (var obj:CTrunkEntityBaseData in findEntities) {
                mapObject = obj as CTrunkEntityMapObject;
                if (mapObject) {
                    monsterList.push({
                        id: ++_id, // obj.tribeID,
                        entityType:mapObject.type, type:mapObject.tribe, x:mapObject.location.x, y:mapObject.location.y,
                        spawnID:mapObject.spawnID, entityID:mapObject.ID, campID:mapObject.tribeID
                    });
                    if (mapObjectTable.findByPrimaryKey(mapObject.spawnID) == null) {
                        CLevelLog.addDebugLog("mapObject ID error : " + mapObject.spawnID);
                    }
                }
            }
        }

        var response : CharacterAddResponse = new CharacterAddResponse();
        response.data = [];
        var nSpawnCount : uint = monsterList.length;
        for ( var i : int = 0; i < nSpawnCount; ++i ) {
            var spawnMapObjectData : Object = new Object();
            var m : Object = monsterList[ i ];
            spawnMapObjectData.id = m[ "id" ]; // m_roleData.roleID + 1 + i;
            spawnMapObjectData.type = 3; // m["type"]; // int(randomInt(1, 2));
            spawnMapObjectData.prototypeID = m["spawnID"]; // 10; // int(randomValue([10])); // damen bu hui dong
            spawnMapObjectData.name = "[NPC] DaMEN";
            spawnMapObjectData.x = m[ "x" ]; // randomInt(40, 80);
            spawnMapObjectData.y = m[ "y" ]; // randomInt(10, 22);
            spawnMapObjectData.entityID = m["entityID"];
            spawnMapObjectData.entityType = m["entityType"];
            spawnMapObjectData.campID = m["campID"];
            response.data.push( spawnMapObjectData );

            _levelServer.sceneObjectHandler.addSceneObject(spawnMapObjectData);
        }
//        _dummyServer.send( response );
    }
    public function spawnHero() : void {
        var response : CharacterAddResponse = new CharacterAddResponse();
        response.data = [];
        var len:int = _levelServer.heroIDList.length;
        for(var i:int = 0; i<len; i++){
            var spawnRoleData : Object = new Object();
            spawnRoleData.id = 10086 + i;
            spawnRoleData.type = 1; // int(randomInt(1, 2));
            spawnRoleData.prototypeID = _levelServer.heroIDList[i] > 0 ? _levelServer.heroIDList[i] : 312; // m_roleData ? m_roleData.prototypeID : 10;
            // spawnRoleData.name = "[Hero] HaHa";
//        spawnRoleData.x = 5;
//        spawnRoleData.y = 14;
            spawnRoleData.moveSpeed = 500;
            spawnRoleData.operateSide = i == 0 ? 1 : 0;
            spawnRoleData.operateIndex = i == 0 ? 1 : 0;
            spawnRoleData.x = _levelServer.levelInfo.entrance[0].appearPosition[0].x;//5 * 50;
            spawnRoleData.y = _levelServer.levelInfo.entrance[0].appearPosition[0].y;//14 * 50;
            spawnRoleData.campID = 1;
            spawnRoleData.objectID = i == 0 ? 0 : 1;
            response.data.push( spawnRoleData );
        }


//        _dummyServer.send( response );
    }
    public function lockTrunks(topPoint:Point, bottomPoint:Point) : void {
        // 发锁屏给前台
        var lock:LockScreenResponse = new LockScreenResponse();
        lock.srcX = topPoint.x;
        lock.srcy = topPoint.y;
        lock.desX = bottomPoint.x;
        lock.desy = bottomPoint.y;
//        _dummyServer.send(lock);
    }
    public function playScenario(scenarioID:int, controlType:int) : void {
        // 发锁屏给前台
        var scenario:StartScenarioResponse = new StartScenarioResponse();
        scenario.scenarioID = scenarioID;
        scenario.contralType = controlType;
//        _dummyServer.send(scenario);
    }
    public function activePortal() : void {
        var response:ActivePortalResponse = new ActivePortalResponse();
        response.activePortal = true;
//        _dummyServer.send(response);
    }
    public function playSceneAnimation(params:String, type:int) : void {
        var response:PlayAnimationResponse = new PlayAnimationResponse();
        response.type = type;
        response.param = params;
//        _dummyServer.send(response);
    }
    public function playEff(params:String, type:int) : void {
        var response:PlayEffectResponse = new PlayEffectResponse();
        response.type = type;
        response.param =params;
//        _dummyServer.send(response);
    }
    public function sendActiveTrunk(trunkID:int) : void {
        var response:ActiveTruckResponse = new ActiveTruckResponse();
        response.truckID =trunkID;
//        _dummyServer.send(response);
    }
    public function sendEnterTrunk(trunkID:int) : void {
        var response:EnterTruckResponse = new EnterTruckResponse();
        response.truckID =trunkID;
//        _dummyServer.send(response);
    }
    public function sendCleanTrunk(trunkID:int) : void {
        var response:ClearanceTruckResponse = new ClearanceTruckResponse();
        response.truckID =trunkID;
//        _dummyServer.send(response);
    }
    public function sendInstanceOver() : void {
        var response:InstanceOverResponse = new InstanceOverResponse();
        response.fightResult = 1;
//        _dummyServer.send(response);
    }

    //移除怪物
    public function sendRemoveSpawiedMonster(arr:Array):void{
        var response:CharacterRemovedResponse = new CharacterRemovedResponse();
        response.data = arr;
//        _dummyServer.send(response);
    }

    //trunk目标完成
    public function sendTrunkTargetComplete():void{
        var response:TruckTargetPassResponse = new TruckTargetPassResponse();
//        _dummyServer.send(response);
    }

    public function sendMonsterDead(id:int, type:int):void{
        var response:FighterDeadResponse  = new FighterDeadResponse();
        response.ID = id;
        response.type = type;
//        _dummyServer.send(response);
    }

    private var _levelServer:CLevelServer;
//    private var _dummyServer:IDummyServer;
}
}
