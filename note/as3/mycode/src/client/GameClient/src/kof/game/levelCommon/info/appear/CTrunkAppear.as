/**
 * Created by auto on 2016/7/3.
 */
package kof.game.levelCommon.info.appear {

import kof.game.common.CCreateListUtil;

public class CTrunkAppear {
    public function CTrunkAppear(data:Array) {
        if(data == null){
            return;
        }
        var tempPos:Array = data;
        if (tempPos && tempPos.length > 0) {
            location = new Array(tempPos);
            for (var i:int = 0; i < tempPos.length; i++) {
                location[i] = CCreateListUtil.createPointData(tempPos[i]);
            }
        }

    }

    public var location:Array;
}
}
