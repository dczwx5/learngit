/**
 * Created by auto on 2016/7/2.
 */
package kof.game.levelCommon.info.base {

import kof.game.common.CCreateListUtil;
import flash.geom.Point;

public class CTrunkAreaData extends CTrunkPositionData{
    public var size:Point; // 范围大小

    public function CTrunkAreaData(data:Object) {
        super(data);
        size = CCreateListUtil.createPointData(data["size"]);

    }
}
}
