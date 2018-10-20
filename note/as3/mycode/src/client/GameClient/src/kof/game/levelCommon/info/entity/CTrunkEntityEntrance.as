/**
 * Created by auto on 2016/7/3.
 */
package kof.game.levelCommon.info.entity {

import kof.game.common.CCreateListUtil;

public class CTrunkEntityEntrance {
    public var transitionMode:int; // ELevelAppearType 0 "手动"  1 : "自动走入"  2 : "自动跑入"
    public var appearPosition:Array;
    public function CTrunkEntityEntrance(data:Object) {
        transitionMode = data["transitionMode"];
        var tempPos:Array = data["appearPosition"];
        if (tempPos && tempPos.length > 0) {
            appearPosition = new Array(tempPos);
            for (var i:int = 0; i < tempPos.length; i++) {
                appearPosition[i] = CCreateListUtil.createPointData(tempPos[i]);
            }
        }
    }
}
}
