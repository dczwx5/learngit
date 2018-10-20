/**
 * Created by auto on 2016/5/19. modify on 2016/7/2
 */

package kof.game.levelCommon.info {
import flash.utils.Dictionary;

import kof.game.common.CCreateListUtil;

import kof.game.levelCommon.Enum.EMapType;
import kof.game.levelCommon.Enum.ETrunkEntityType;
import kof.game.levelCommon.info.base.CTrunkEntityBaseData;
import kof.game.levelCommon.info.entity.CTrunkEntityEntrance;
import kof.game.levelCommon.info.entity.CTrunkEffectInfo;
import kof.game.levelCommon.info.entity.CTrunkEntityMonster;
import kof.game.levelCommon.info.entity.CTrunkEntityTriggerPortal;
import kof.game.levelCommon.info.trunk.CTrunkConfigInfo;


public class CLevelConfigInfo {
    // =================================================已经在使用=====================================================================
    public var map:String; // 场景文件
    public var trunks:Array; // Vector.<CTrunkConfigInfo>;    // trunk数据
    public var entrance:Array; // 入口
    public var portal:Array; // CTrunkEntityTriggerPortal; // 传送门
    public var preLoad:Array; // 预加载怪物ID列表
    public var levelEffectInfo:Array; //特效列表
    public var signPoint:Array; //关卡标记点
    public var npc:Array;//npc列表hved
    public var levelCamera:Object;//关卡初始镜头
    // ===============================================不要了=======================================================================
    private var _allTrunks:Dictionary;
    public function CLevelConfigInfo(data:Object) {
        map = data["map"];
        entrance = CCreateListUtil.createArrayData(data["entrance"], CTrunkEntityMonster);
        portal = CCreateListUtil.createArrayData(data["portal"], CTrunkEntityTriggerPortal);
        _allTrunks = new Dictionary();
        trunks = CCreateListUtil.createArrayData(data["trunks"], CTrunkConfigInfo, null, [_allTrunks]);
        levelEffectInfo = CCreateListUtil.createArrayData(data["levelEffectInfo"], CTrunkEffectInfo);
        preLoad = data["preLoad"];
        signPoint = data["signPoint"];
        npc = data["NPC"];
        levelCamera = data["levelCamera"];
    }

    public function dispose() : void {

    }

    public function getEntityById(id:int):CTrunkEntityMonster{
        var _entity:CTrunkEntityMonster;
        for each (var trunk:CTrunkConfigInfo in trunks) {
            _entity = trunk.getEntityById(ETrunkEntityType.MONSTER,id) as CTrunkEntityMonster;
            if (_entity) {
                return _entity;
            }
        }
        return null;
    }

    public function getEntranceById(id:int):CTrunkEntityMonster{
        for each (var entity:CTrunkEntityBaseData in this.entrance) {
            if (entity.ID == id) {
                return entity as CTrunkEntityMonster;
            }
        }
        return null;
    }

    public function getTriggerById(id:int):CTrunkEntityBaseData{
        var _entity:CTrunkEntityBaseData;
        for each (var trunk:CTrunkConfigInfo in trunks) {
            _entity = trunk.getEntityById(ETrunkEntityType.TRIGGER,id) as CTrunkEntityBaseData;
            if (_entity) {
                return _entity;
            }
        }
        return null;
    }

    public function getNpcById(id:int):Object{
        for each( var obj:Object in npc){
            if(obj.npcID == id){
                return obj;
            }
        }
        return null;
    }

    public function getTrunkById(id:int) : CTrunkConfigInfo {
        for each (var trunk:CTrunkConfigInfo in trunks) {
            if (trunk.ID == id) {
                return trunk;
            }
        }
        return null;
    }

    public function getEndTrunkID() : int {
        var max:int = 0;
        for each (var trunk:CTrunkConfigInfo in trunks) {
            if (trunk.ID > max) {
                max = trunk.ID;
            }
        }
        return max;
    }

    public function getEffectInfoByName(name:String):CTrunkEffectInfo{
        for each (var info:CTrunkEffectInfo in levelEffectInfo) {
            if (info.name == name) {
                return info;
            }
        }
        return null;
    }

    public function getSignPoint(id:int):Object{
        for each( var obj:Object in signPoint){
            if(obj.ID == id){
                return obj.location;
            }
        }
        return null;
    }

}
}