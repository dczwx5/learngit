//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Lune on 2018/9/11.
 * 本地缓存接口
 */
package kof.util {

import flash.net.SharedObject;

public class CSharedObject {
    static private const LOGIN_STORAGE_NAME : String = "KOF_DebugLoginInfo";
    public function CSharedObject() {
    }

    public static function readFromSharedObject(key : String) : * {
        var so : SharedObject = SharedObject.getLocal( LOGIN_STORAGE_NAME, "/" );

        if(so.data[key] != null)
        {
            return so.data[key];
        }
        return null;
    }

    public static function writeToSharedObject(key : String, value : *) : void
    {
        var so : SharedObject = SharedObject.getLocal( LOGIN_STORAGE_NAME, "/" );
        so.data[key] = value;
        try
        {
            so.flush();
        }
        catch (e : Error)
        {
            App.log.warn( e.message);
        }

    }

}
}
