/**
 * Created by auto on 2016/7/2.
 */
package kof.game.levelCommon.info.base {

import kof.game.common.CCreateListUtil;
import kof.game.levelCommon.info.event.CSceneEventInfo;

public class CTrunkEntityBaseData extends CTrunkAreaData {
    public var ID:int; // 该类型序列ID
    public var limit:int; // 可激活次数, 一般fb配的是1, 挂机副本配的是-1, 刷怪点limit不管如何都是无限, trunk是1次
    public var type:int; // 实体类型 ETrunkEntityType
    public var activeEvents:Array; // 进入事件

    // public var lockTargetId:int; // 锁定目标 不理
    // public var conditions:Array;
    public function CTrunkEntityBaseData(data:Object) {
        super(data);
        ID = data["ID"];
        limit = data["limit"];
        type = data["type"];

        activeEvents = CCreateListUtil.createArrayData(data["activeEvents"], CSceneEventInfo);

    }
}
}
