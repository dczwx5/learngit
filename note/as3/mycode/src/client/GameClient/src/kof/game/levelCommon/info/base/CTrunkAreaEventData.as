/**
 * Created by auto on 2016/7/4.
 */
package kof.game.levelCommon.info.base {

import kof.game.common.CCreateListUtil;
import kof.game.levelCommon.info.event.CSceneEventInfo;

public class CTrunkAreaEventData extends CTrunkEntityBaseData {
    public var enterEvents:Array; // 进入事件
    public var passEvents:Array; // 目标完成事件
    public var completeEvents:Array; // trunk完成事件

    public function CTrunkAreaEventData(data:Object) {
        super (data);

        enterEvents = CCreateListUtil.createArrayData(data["enterEvents"], CSceneEventInfo);
        passEvents = CCreateListUtil.createArrayData(data["passEvents"], CSceneEventInfo);
        completeEvents = CCreateListUtil.createArrayData(data["completeEvents"], CSceneEventInfo);

    }

}
}
