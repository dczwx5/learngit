/**
 * Created by auto on 2016/9/12.
 */
package kof.game.levelCommon.info.base {
public class CTrunkConditionInfo  {

    public function CTrunkConditionInfo(data:Object) {
        name = data["name"];
        parameter = data["parameter"];
        delay = data["delay"];

        interval = data["interval"];
        distance = data["distance"];

        countType = data["countType"];
        keepTime = data["keepTime"];
        compare = data["compare"];
        targetType = data["targetType"];
        targetID = data["targetID"];
        targetValue = data["targetValue"];
    }

    public function getParameterArray() : Array {
        var strIds:Array = parameter.split(",");
        return strIds;
    }
    public function getParameterIntArray() : Array {
        var strIds:Array = parameter.split(",");
        var iIds:Array = new Array(strIds.length);
        for (var i:int = 0; i < strIds.length; i++) {
            iIds[i] = int(strIds[i]);
        }
        return iIds;
    }
    public var name:String;
     public var parameter:String;
    public var delay:Number; // 条件执行delay

    // timer treigger
    public var interval:int; // : 触发器间隔, 单位秒
    // zone trigger
    public var distance:int; // : 移动距离
    // monster
    public static const COUNT_TYPE_ADD:int = 0;
    public static const COUNT_TYPE_KEEP:int = 1;
    public static const COUNT_TYPE_SUB:int = 2;
    public static const COUNT_TYPE_TO_VALUE:int = 3;
    public var countType:int; // 0 : 增加, 1,保持, 2减少, 3至指定数值

    public var keepTime:int; // 时间

    public static const COMPARTE_LESS:int = -2;
    public static const COMPARTE_LESS_EQUOT:int = -1;
    public static const COMPARTE_EQUOT:int = 0;
    public static const COMPARTE_GREATER_EQUOT:int = 1;
    public static const COMPARTE_GREATER:int = 2;
    public var compare:int; // -2小于, -1小于等于, 0等于, 1大于等于, 2大于

    public static const TARGET_TYPE_MONSTER:int = 0;
//    public static const TARGET_TYPE_MAPOBJECT:int = 1;
    public static const TARGET_TYPE_HP:int = 1;
    public static const TARGET_TYPE_ATTACK:int = 2;
    public static const TARGET_TYPE_ATTACKPOWER:int = 3;
    public static const TARGET_TYPE_DEFENSE:int = 4;
    public static const TARGET_TYPE_DEFENSEPOWER:int = 5;
    public var targetType:int; // 0 monster, 1 : mapObject, 2 : hp, 3 晕眩
    public var targetID:int; // -1 or 0 mains all monster, counter : 目标ID, 怪物ID
    public var targetValue:int; // 目标值 counter & property

    // 特殊标记先不理, 眩晕啥的

}
}
