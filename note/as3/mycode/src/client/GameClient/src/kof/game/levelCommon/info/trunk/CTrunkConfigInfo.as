/**
 * Created by auto on 2016/5/19.
 */
package kof.game.levelCommon.info.trunk {

import kof.game.common.CCreateListUtil;

import flash.geom.Rectangle;
import flash.utils.Dictionary;

import kof.game.levelCommon.info.base.CTrunkAreaData;
import kof.game.levelCommon.info.base.CTrunkEntityBaseData;

import kof.game.levelCommon.info.entity.CTrunkEntityFactory;
import kof.game.levelCommon.info.event.CSceneEventInfo;
import kof.game.levelCommon.info.event.CTrunkEventGroup;
import kof.game.levelCommon.info.goal.CTrunkGoalsInfo;

public class CTrunkConfigInfo extends CTrunkAreaData // extends CBaseInfo
{
    public var ID:int;    /**trunk id*/
    public var eventGroups:Array; // CTrunkEventGroup 事件组, add by auto , use in auto grigger
    public var children:Array; // CTrunkConfigInfo 子trunk
    public var passEvents:Array;    /**当前Trunk目标达成后触发事件*/
    public var completeEvents:Array;    /**当trunk目标完成时的事件*/
    public var activeEvents:Array;    /**激活时的事件*/
    public var enterEvents:Array;    /**当进入trunk时的事件*/
    public var goals:CTrunkGoalsInfo;    // 目标
    public var entities:Array; // CTrunkEntityBaseData
    //
    private var _allTrunks:Dictionary;

    public function CTrunkConfigInfo(resData:Object, allTrunks:Dictionary) {
        _allTrunks = allTrunks;

        super(resData);

        ID = resData["ID"];
        _allTrunks[ID] = this;
        eventGroups = CCreateListUtil.createArrayData(resData["eventGroups"], CTrunkEventGroup);
        children = CCreateListUtil.createArrayData(resData["children"], CTrunkConfigInfo, null, [_allTrunks]);
        passEvents = CCreateListUtil.createArrayData(resData["passEvents"], CSceneEventInfo);
        completeEvents = CCreateListUtil.createArrayData(resData["completeEvents"], CSceneEventInfo);
        activeEvents = CCreateListUtil.createArrayData(resData["activeEvents"], CSceneEventInfo);
        enterEvents = CCreateListUtil.createArrayData(resData["enterEvents"], CSceneEventInfo);
        goals = new CTrunkGoalsInfo(resData["goals"]);

        var tempEntities:Array = resData["entities"];
        if (tempEntities && tempEntities.length > 0) {
            entities = new Array(tempEntities.length);
            for (var i:int = 0; i < tempEntities.length; i++) {
                entities[i] = CTrunkEntityFactory.createTrunkEntity(tempEntities[i]);
            }
        }

    }

    public function getTrunkByID(trunkID:int) : CTrunkConfigInfo {
        return _allTrunks[trunkID];
    }
    public function getEntityById(spawnType:int, id:int) : CTrunkEntityBaseData {
        for each (var entity:CTrunkEntityBaseData in this.entities) {
            if( entity == null )
                    continue;
                    
            if (entity.type == spawnType && entity.ID == id) {
                return entity;
            }
        }
        return null;
    }

    private var _rect:Rectangle;
    public function getTrunkRect() : Rectangle {
        if (!_rect) {
            _rect = new Rectangle();
        }
        _rect.setTo(location.x - size.x * 0.5, location.y - size.y * 0.5, size.x, size.y);
        return _rect;
    }
}
}