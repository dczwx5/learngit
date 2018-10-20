/**
 * Created by auto on 2016/7/28.
 */
package kof.game.levelCommon.info.base {
import kof.game.common.CCreateListUtil;
import kof.game.levelCommon.info.event.CSceneEventInfo;

public class CTrunkTriggerData extends CTrunkEntityBaseData {
    public var triggerEvents:Array; // 触发器事件
    public var completeEvents:Array; // 完成事件
    public var conditions:Array; // 条件 , 2维数组, 每个一组数组是一个条件组,
    public var triggerFilter:Array; // 筛选目标

    public var limitInterval:int;//条件间隔，执行间隔
    public var executeImmediately:Boolean;//立即执行

    public function CTrunkTriggerData(data:Object)  {
        super (data);
        triggerEvents = CCreateListUtil.createArrayData(data["triggerEvents"], CSceneEventInfo);
        completeEvents = CCreateListUtil.createArrayData(data["completeEvents"], CSceneEventInfo);
        triggerFilter = data["triggerFilter"];
        limitInterval = data["limitInterval"];
        executeImmediately = data["executeImmediately"];

        var condsList:Array = data["conditions"];
        if (condsList && condsList.length > 0) {
            conditions = new Array();
            var conds:Array;
            for (var i:int = 0; i < condsList.length; i++) {
                conds = CCreateListUtil.createArrayData(condsList[i], CTrunkConditionInfo);
                conditions.push(conds);
            }

        }

    }
}
}
