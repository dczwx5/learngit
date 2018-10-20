/**
 * Created by auto on 2016/7/4.
 */
package kof.game.levelCommon.info.base {

import kof.game.common.CCreateListUtil;
import kof.game.levelCommon.info.event.CSceneEventInfo;

public class CTrunkObjectEventData extends CTrunkEntityBaseData {
    public var appearEvents:Array; // 出现的事件
    public var readyEvents:Array; // 什么的准备时事件？当完成出场后执行
    public var hitEvents:Array; // 当这些怪受击时的事件
    public var dieEvents:Array; // 当这些怪死亡后的事件

    public function CTrunkObjectEventData(data:Object) {
        super (data);

        appearEvents = CCreateListUtil.createArrayData(data["appearEvents"], CSceneEventInfo);
        readyEvents = CCreateListUtil.createArrayData(data["readyEvents"], CSceneEventInfo);
        hitEvents = CCreateListUtil.createArrayData(data["hitEvents"], CSceneEventInfo);
        dieEvents = CCreateListUtil.createArrayData(data["dieEvents"], CSceneEventInfo);
    }
}
}
