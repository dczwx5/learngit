/**
 * Created by auto on 2016/7/2.
 */
package kof.game.levelCommon.info.base {

import flash.geom.Vector3D;

/**
 * trunk 包括trunk, 实体的基类
 *
 */
public class CTrunkPositionData {
    public var location:Vector3D; // 像素坐标, 中点

    public function CTrunkPositionData(data:Object) {
        if(data["location"]){
            var x:int = data["location"].x;
            var y:int = data["location"].y;
            var z:int = data["location"].hasOwnProperty("z") ? data["location"].z : 0;
            location = new Vector3D(x,y,z);
        }
    }
}
}
