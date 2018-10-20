/**
 * Created by auto on 2016/7/21.
 */
package kof.game.levelCommon.info.levelScenario {
public class CLevelScenarioScenarioInfo {
    public var trunk:int; // trunk id
    public var entityType:int; // 实体类型, -1即不在entity, 而是在trunk下
    public var ID:int; // 实体ID, 如果entityType不为-1, 则ID为对应的实体ID
    public var event:String; // 事件名称 activeEvents, 根据trunk, entityType, ID, 找到event所在的位置
    public var allControl:int; // 完全控制与非完全控制, 0 : 非完全控制, 1 : 完全控制
    public var scenarioID:int; // 剧情 ID
    public var delay:Number; //
    public var surrender:int; // 是否废弃
    public function CLevelScenarioScenarioInfo(data:Object) {
        trunk = data["trunk"];
        entityType = data["entityType"];
        ID = data["ID"];
        event = data["event"];
        scenarioID = data["scenarioID"];
        allControl = data["allControl"];
        surrender = data["surrender"];

        if (data.hasOwnProperty("delay")) {
            delay = data["delay"];
        } else {
            delay = 0;
        }
    }

    public function get isInEntity() : Boolean {
        return entityType != -1;
    }
    public function get isInTrunk() : Boolean {
        return entityType == -1;
    }
    public function get isAllControl() : Boolean {
        return allControl > 0;
    }

}
}
