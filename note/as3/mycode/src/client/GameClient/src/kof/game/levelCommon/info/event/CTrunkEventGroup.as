/**
 * Created by auto on 2016/7/2.
 */
package kof.game.levelCommon.info.event {

import kof.game.common.CCreateListUtil;

public class CTrunkEventGroup {
    public var name:String;
    public var events:Array; // <CSceneEventInfo>;
    public function CTrunkEventGroup(data:Object) {
        name = data["name"];
        events = CCreateListUtil.createArrayData(data["events"], CSceneEventInfo);
    }


}
}
