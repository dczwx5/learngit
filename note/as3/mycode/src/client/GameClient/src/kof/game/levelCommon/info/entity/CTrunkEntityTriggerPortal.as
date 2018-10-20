/**
 * Created by auto on 2016/7/3.
 */
package kof.game.levelCommon.info.entity {
import kof.game.levelCommon.info.base.CTrunkAreaEventData;

/**
 * 传送门
 */
public class CTrunkEntityTriggerPortal extends CTrunkAreaEventData {
    public var effectID:String;
     public function CTrunkEntityTriggerPortal(data:Object) {
        super (data);
        effectID = data["effect"];
    }
}
}
