/**
 * Created by user on 2016/11/19.
 */
package kof.game.scenario.info {
public class CScenarioCameraInfo {
    public function CScenarioCameraInfo(data:Object) {
        if(data == null)return;
        _x = data["x"];
        _y = data["y"];
        _height = data["height"];
        _default = data["default"];
    }

    final public function get x() : Number {
        return _x;
    }
    final public function get y() : Number {
        return _y;
    }

    final public function get Default() : Boolean {
        return _default;
    }

    final public function get height() : Number {
        return _height;
    }

    private var _x:Number;
    private var _y:Number;
    private var _default:Boolean;
    private var _height:Number;
}
}
