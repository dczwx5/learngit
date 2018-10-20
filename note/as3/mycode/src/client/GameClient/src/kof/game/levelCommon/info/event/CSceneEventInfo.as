/**
 * Created by auto on 2016/5/25.
 */
package kof.game.levelCommon.info.event {
public class CSceneEventInfo {
    public function CSceneEventInfo(data:Object) {
        name = data["name"];
        conditions = data["conditions"];
        parameter = data["parameter"];
        delay = data["delay"];
        weight = data["weight"]
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
    public var conditions:Array;
    public var parameter:String;
    public var delay:Number;
    public var weight:int;
}
}
