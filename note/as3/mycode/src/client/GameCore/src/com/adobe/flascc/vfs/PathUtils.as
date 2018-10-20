//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package com.adobe.flascc.vfs {

/**
 * A collection of path handling related functions
 */
public final class PathUtils {

    /**
     * Return a path equivalent to the argument, with these properties:
     * 1. is absolute (will always have a leading '/')
     * 2. doesn't contain '.' or '..'
     * 3. never has a trailing '/', even if the argument path did
     * 4. never has two or more "/" characters in a row
     * TODO: Relative paths are assumed to be relative to the
     * current working directory.
     */
    public static function toCanonicalPath(path:String):String {
        var x:String = path.replace(/\//, "/");
        while (x != path) {
            path = x;
            x = path.replace(/\//, "/");
        }
        var segs:Array = path.split("/");
        var ret:Array = [];
        for (var i:uint = 0; i < segs.length; i++) {
            if (segs[i] == "..") {
                if (ret.length > 0) {
                    ret.pop();
                }
            } else if (segs[i].length != 0 && segs[i] != ".") {
                ret.push(segs[i]);
            }
        }
        return "/" + ret.join("/");
    }

    /**
     * Return everything except the last component of the supplied path.
     */
    public static function getDirectory(path:String):String {
        path = PathUtils.toCanonicalPath(path);
        var i:uint = path.lastIndexOf("/");
        if (!i) {
            return "/";
        } else {
            return path.substring(0, i);
        }
    }

}
}
