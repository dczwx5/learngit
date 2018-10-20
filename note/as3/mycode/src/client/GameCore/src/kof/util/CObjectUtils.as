//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun CNetwork Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.util {

import flash.utils.ByteArray;

/**
 * A poor utilities as a <code>Object</code> helper.
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public final class CObjectUtils {

    /**
     * !!! Disallow
     */
    public function CObjectUtils() {
        super();
    }
    
    public static function toObject(src:Object, options:Array):Object {
        options = options || [];
        var dest:Object = {};
        for each (var nameKey:String in options) {
            dest[nameKey] = src[nameKey];
        }
        return dest;
    }

    /**
     * Extends properties of <code>dest</code> Object from <code>src</code> Object.
     */
    public static function extend(...args):Object {
        var options:Object, name:String, src:Object, copy:Object, copyIsArray:Boolean, clone:Object, deep:Boolean;
        var i:int = 1, length:int = args.length;
        var target:Object = length ? args[0] : {};

        // Handle a deep copy situation.
        if (target is Boolean) {
            deep = Boolean(target);

            // Skip the boolean and the target.
            target = length > i ? args[i] : {};
            i++;
        }
        // Handle case when target is a string or something (possible in deep copy).
        if (!(target is Object) && !(target is Function)) {
            target = {};
        }
        // Extend {} if only one argument is passed.
        if (i == length) {
            target = {};
            i--;
        }

        for (; i < length; ++i) {
            // Only deal with non-null/undefined values
            if ((options = args[i]) != null) {
                // Extend the base object.
                for (name in options) {
                    src = (name in target || target.hasOwnProperty(name)) ? target[name] : null;
                    copy = options[name];

                    // Prevent never-ending loop.
                    if (target == copy) {
                        continue;
                    }

                    // Recurse if we're merging plain objects or arrays
                    if (deep && copy && (isPlainObject(copy) || true == (copyIsArray = Boolean(copy is Array)))) {
                        if (copyIsArray) {
                            copyIsArray = false;
                            clone = src && (src is Array) ? src : [];
                        } else {
                            clone = src && isPlainObject(src) ? src : {};
                        }

                        // Never move original objects, clone them
                        target[name] = extend(deep, clone, copy);
                    } else if (copy != null) {
                        target[name] = copy;
                    }
                }
            }
        }

        // Returns the modified object.
        return target;
    }

    private static function isPlainObject(copy:Object):Boolean {
        return !(!copy || copy.toString() != '[object Object]');

    }

    public static function isIterable(obj:Object):Boolean {
        if (null == obj)
            return false;

        //noinspection JSValidateTypes,JSUnusedLocalSymbols,LoopStatementThatDoesntLoopJS
        for (var k:* in obj) {
            return true;
        }

        return false;
    }

    public static function cloneObject(obj:Object):Object {
        if (!obj)
            return null;
        var ba:ByteArray = new ByteArray;
        ba.writeObject(obj);
        ba.position = 0;
        var ret : Object = ba.readObject();
        ba.clear();
        return ret;
    }

}
}
