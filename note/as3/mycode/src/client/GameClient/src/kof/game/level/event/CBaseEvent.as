/**
 * Created by auto on 2016/5/19.
 */
package kof.game.level.event {
import QFLib.Graphics.RenderCore.starling.events.Event;

public class CBaseEvent extends Event
{
    private static var _soleEventTypeId:int = 0;
    public function CBaseEvent(type:String,data:Object = null) {
        super(type,false, data);
    }

    public static function getSoleEventType() : String {
        _soleEventTypeId++;
        return "sole_event_type_" + _soleEventTypeId;
    }

    public function clone() : CBaseEvent{
        var evt:CBaseEvent = new CBaseEvent(type, data)
        return evt;
    }
}
}