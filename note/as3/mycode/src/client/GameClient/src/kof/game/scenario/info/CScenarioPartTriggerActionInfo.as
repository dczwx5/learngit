/**
 * Created by auto on 2016/8/10.
 */
package kof.game.scenario.info {
public class CScenarioPartTriggerActionInfo {
    public function CScenarioPartTriggerActionInfo(data:Object) {
        delay = data["delay"];
        id = data["id"];
    }

    public function encode() : Object {
        var obj:Object = new Object();
        obj.delay = delay;
        obj.id = id;
        return obj;
    }
    public var id:int;
    public var delay:Number;
}
}
