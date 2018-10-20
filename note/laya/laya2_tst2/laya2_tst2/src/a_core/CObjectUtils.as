package a_core
{
public final class CObjectUtils {

    // options : key数组
    // 根据key数组, 从src中取出元素，并组成一个object返回
    public static function toObject(src:Object, options:Array) : Object {
        options = options || [];
        var dest:Object = {};
        for each (var key:String in options) {
            dest[key] = src[key];
        }

        return dest;
    }

    public static function extend(deep:Boolean, target:Object, ...addObjs) : Object {
        var options:Object, name:String, src:Object, copy:Object, copyIsArray:Boolean, clone:Object;

        for (var i:int = 0; i < addObjs.length; i++) {
            options = addObjs[i];
            if (null != options) {
                for (name in options) {
                    src = (name in target || target.hasOwnProperty(name)) ? target[name] : null;
                    copy = options[name];

                    if (target == copy) {
                        continue;
                    }

                    if (deep && copy && (isPlainObject(copy) || true == (copyIsArray == Boolean(copy is Array)))) {
                        if (copyIsArray) {
                            copyIsArray = false;
                            clone = src && (src is Array) ? src : [];
                        } else {
                            clone = src && isPlainObject(src) ? src : {};
                        }

                        target[name] = extend(deep, clone, copy);
                    } else if (copy != null) {
                        target[name] = copy;
                    }
                }
            }
        }

        return null;
    }

    private static function isPlainObject(copy:Object) : Boolean {
        return !(!copy || copy.toString() != '[object Object]');
    }

}   
}