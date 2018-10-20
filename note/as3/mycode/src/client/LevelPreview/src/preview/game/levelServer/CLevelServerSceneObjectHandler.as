/**
 * Created by auto on 2016/8/1.
 */
package preview.game.levelServer {
import QFLib.Foundation.CMap;

import flash.utils.getTimer;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;

import kof.game.character.CCharacterDataDescriptor;

import kof.game.levelCommon.Enum.ELevelEventType;

import kof.game.levelCommon.Enum.ETrunkEntityType;
import preview.game.levelServer.data.CLevelSceneMonsterData;
import preview.game.levelServer.data.CLevelSceneObjectAllCountStartData;
import preview.game.levelServer.data.CLevelSceneObjectCountData;

import preview.game.levelServer.event.map.CTrunkMonsterDeadEvent;

import preview.game.levelServer.data.CLevelSceneObjectData;
import preview.game.levelServer.event.map.CTrunkMonsterRemoveEvent;
import kof.table.Monster;


/**
 * 保存已创建的怪物/物件列表
 */
public class CLevelServerSceneObjectHandler {
    public function CLevelServerSceneObjectHandler(server:CLevelServer) {
        _server = server;
        _server.addEventListener(ELevelEventType.MONSTER_DIE, _onObjectDie);
        _server.addEventListener(ELevelEventType.MONSTER_REMOVE, _onObjectRemove);

        _objectMap = new Vector.<CMap>(ETrunkEntityType.COUNT);
        for (var i:int = 0; i < _objectMap.length; i++) {
            // ETrunkEntityType , 每种type都对应有一个组
            _objectMap[i] = new CMap();
        }

        _monsterCountDataMap = new CMap();

        _allMonsterCountData = new CLevelSceneObjectCountData();
        _allMonsterCountData.clear();
    }
    public function dispose() : void {
        this.clear();
        _server.removeEventListener(ELevelEventType.MONSTER_DIE, _onObjectDie);
        _server.removeEventListener(ELevelEventType.MONSTER_REMOVE, _onObjectRemove);
        _server = null;
    }
    public function clear() : void {
        for (var i:int = 0; i < _objectMap.length; i++) {
            _objectMap[i] = new CMap();
        }
        _allMonsterCountData.clear();

        _monsterCountDataMap = new CMap();
    }

    public function addSceneObject(obj:Object) : void {
        var sceneObject:CLevelSceneObjectData;
        if(obj["type"] == CCharacterDataDescriptor.TYPE_MONSTER){
            var monster:CLevelSceneMonsterData = new CLevelSceneMonsterData();
            monster.objectID = obj["prototypeID"];
            var monsterTable:IDataTable = (_server.system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.MONSTER);
            var m:Monster = monsterTable.findByPrimaryKey(monster.objectID) as Monster;
//            monster.HP = m.HP;
//            monster.attackPower = m.AttackPower;
//            monster.defensePower = m.DefensePower;
            sceneObject = monster;
        }
        else{
            sceneObject = new CLevelSceneObjectData();
        }

        sceneObject.uniID = obj["id"];
        sceneObject.gameObjectType = obj["type"];
        sceneObject.objectID = obj["prototypeID"];
        sceneObject.entityID = obj["entityID"];
        sceneObject.entityType = obj["entityType"];
        sceneObject.campID = obj["campID"];
        sceneObject.objectTypeID = obj["objectID"];


        var list:CMap = _objectMap[sceneObject.entityType];
        if (list) list[sceneObject.uniID] = sceneObject;

        // 所有怪物
        _allMonsterCountData.add(1);

        // 某种怪物
        var monsterCountData:CLevelSceneObjectCountData = _monsterCountDataMap[sceneObject.objectID];
        if (monsterCountData == null) {
            monsterCountData = new CLevelSceneObjectCountData();
            _monsterCountDataMap.add(sceneObject.objectID, monsterCountData);
        }
        monsterCountData.add(1);
    }
    private function _onObjectDie(e:CTrunkMonsterDeadEvent) : void {
        var list:CMap = _objectMap[e.entityType];
        if (list) {
            if (list.hasOwnProperty(e.uniID.toString())) {
                var sceneObject:CLevelSceneObjectData = list[e.uniID] as CLevelSceneObjectData;
                list.remove(e.uniID);

                // 所有怪物
                _allMonsterCountData.remove(1);

                // 某种怪物
                var monsterCountData:CLevelSceneObjectCountData = _monsterCountDataMap[sceneObject.objectID];
                if (monsterCountData != null) {
                    monsterCountData.remove(1);
                }
            }
        }
    }

    private function _onObjectRemove(e:CTrunkMonsterRemoveEvent):void{
        var monsterArr:Array = e.removeArray;
        for each (var obj:Object in monsterArr){
            var list:CMap = _objectMap[obj.entityType];
            var sceneObject:CLevelSceneObjectData = list[obj.id] as CLevelSceneObjectData;
            list.remove(obj.id);

            // 所有怪物
            _allMonsterCountData.removeCurrentCount(1);

            // 某种怪物
            var monsterCountData:CLevelSceneObjectCountData = _monsterCountDataMap[sceneObject.objectID];
            if (monsterCountData != null) {
                monsterCountData.removeCurrentCount(1);
            }
        }
    }


    public function loopAllObject(procFun:Function) : void {
        if (null == procFun) return ;
        for (var i:int = 0; i < _objectMap.length; i++) {
            var list:CMap = _objectMap[i];
            for each (var object:CLevelSceneObjectData in list) {
                if (object) {
                    procFun(object);
                }
            }
        }
    }
    public function getFirstMonster() : CLevelSceneObjectData {
        var list:CMap = _objectMap[ETrunkEntityType.MONSTER];
        for each (var obj:CLevelSceneObjectData in list){
            if(obj.campID != 1){
                return obj;
            }
        }
        return null;
    }
    public function getSceneObject(type:int, uniID:Number) : CLevelSceneObjectData {
        var list:CMap = _objectMap[type];
        return list[uniID];
    }

    public function getMonsterByObjectID(objectID:int):Vector.<CLevelSceneObjectData> {
        var list:CMap = _objectMap[ETrunkEntityType.MONSTER];
        var vec:Vector.<CLevelSceneObjectData> = new Vector.<CLevelSceneObjectData>();
        for each (var obj:CLevelSceneObjectData in list){
            if(obj.objectID == objectID){
                vec.push(obj);
            }
        }
        return vec;
    }

    public function getMonsterByEntityID(entityID:int):Vector.<CLevelSceneObjectData> {
        var list:CMap = _objectMap[ETrunkEntityType.MONSTER];
        var vec:Vector.<CLevelSceneObjectData> = new Vector.<CLevelSceneObjectData>();
        for each (var obj:CLevelSceneObjectData in list){
            if(obj.entityID == entityID){
                vec.push(obj);
            }
        }
        return vec;
    }

    public function getAllTeammates() : Vector.<CLevelSceneObjectData> {
        var list:CMap = _objectMap[ETrunkEntityType.MONSTER];
        var ret:Vector.<CLevelSceneObjectData> = new Vector.<CLevelSceneObjectData>();
        for each (var obj:CLevelSceneObjectData in list) {
            if(obj.campID == 1){
                ret.push(obj);
            }
        }
        return ret;
    }

    public function getFirstTeammates() : CLevelSceneObjectData {
        var list:CMap = _objectMap[ETrunkEntityType.MONSTER];
        for each (var obj:CLevelSceneObjectData in list){
            if(obj.campID == 1){
                return obj;
            }
        }
        return null;
    }

    public function getAllMonster() : Vector.<CLevelSceneObjectData> {
        var list:CMap = _objectMap[ETrunkEntityType.MONSTER];
        var ret:Vector.<CLevelSceneObjectData> = new Vector.<CLevelSceneObjectData>();
        for each (var obj:CLevelSceneObjectData in list) {
            ret.push(obj);
        }
        return ret;
    }

    public function getAllEnemy():Vector.<CLevelSceneObjectData> {
        var list:CMap = _objectMap[ETrunkEntityType.MONSTER];
        var ret:Vector.<CLevelSceneObjectData> = new Vector.<CLevelSceneObjectData>();
        for each (var obj:CLevelSceneObjectData in list) {
            if(obj.campID != 1){
                ret.push(obj);
            }
        }
        return ret;
    }

    // monsterID is -1 : all monsterCountData, else monsterID's monsterCountData
    public function getMonsterCountData(monsterID:int) : CLevelSceneObjectCountData {
        if (monsterID == -1) return _allMonsterCountData;
        return _monsterCountDataMap[monsterID];
    }
    public function getStartCountData() : CLevelSceneObjectAllCountStartData {
        var data:CLevelSceneObjectAllCountStartData = new CLevelSceneObjectAllCountStartData();
        data.allMonsterCountData = _allMonsterCountData.clone();

        data.monsterCountDataMap = new CMap();
        _monsterCountDataMap.loop(function (key, value) : void {
            data.monsterCountDataMap[key] = (value as CLevelSceneObjectCountData).clone();
        });
        return data;
    }
//
//    final public function get addMonsterCount() : int {
//        return _allMonsterCountData.addCount;
//    }
//    final public function get removeMonsterCount() : int {
//        return _allMonsterCountData.removeCount;
//    }
//    final public function get monsterCountChangeTime() : int {
//        return _allMonsterCountData.countChangeTime;
//    }
//    final public function get currentMonsterCount() : int {
//        return _allMonsterCountData.currentCount;
//    }
    private var _server:CLevelServer;

    private var _objectMap:Vector.<CMap>; // 保存已创建对象, key :LevelEntityType

    private var _monsterCountDataMap:CMap; // 记录某种怪物的数量, key : monsterID

    private var _allMonsterCountData:CLevelSceneObjectCountData; // 所有怪物数量
}
}
