//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/17.
 */
package {

    public function log(...args) : void {
        var str:String = "";
        for (var i:int = 0; i < args.length; i++) {
            str += args[i].toString() + " ";
        }
        trace(str);
    }
}
