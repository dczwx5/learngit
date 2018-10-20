//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/7/2.
 */
package kof.game.common {
import flash.geom.Point;

public class CCreateListUtil {
    /**
     * 根据json数组数据, 创建一个元素类型的数组. json数组的每个元素, 传入classType的构造函数中
     * @param data json数组数据
     * @param classType 元素类型
     * @param childrenCallback 每添加一个新元素时, 回调函数, 参数为创建的子元素
     & @param args : 额外参数, 最多5个
     * @return 结果数组
     */
    public static function createArrayData(data:Object, classType:Class, childrenCallback:Function = null, args:Array = null) : Array {
        if (!data) return null;
        var len:int = data.length;
        if (len > 0) {
            var ret:Array = new Array(len);
            for (var i:int = 0; i < len; i++) {
                var obj:* = createObjectData(data[i], classType, childrenCallback, args);
                ret[i] = obj;
            }
            return ret;
        }
        return null;
    }

    public static function createObjectData(data:Object, classType:Class, childrenCallback:Function = null, args:Array = null) : Object {
        if (!data) return null;
        var obj:*;
        if (args && args.length > 0) {
            if (args.length == 1) obj = new classType(data, args[0]);
            else if (args.length == 2) obj = new classType(data, args[0], args[1]);
            else if (args.length == 3) obj = new classType(data, args[0], args[1], args[2]);
            else if (args.length == 4) obj = new classType(data, args[0], args[1], args[2], args[3]);
            else if (args.length == 5) obj = new classType(data, args[0], args[1], args[2], args[3], args[4]);
        } else {
            obj = new classType(data);
        }
        if (childrenCallback) {
            childrenCallback(obj);
        }
        return obj;
    }

    public static function createPointData(data:Object) : Point {
        if (!data) return null;
        return new Point(data["x"], data["y"]);
    }
}
}
