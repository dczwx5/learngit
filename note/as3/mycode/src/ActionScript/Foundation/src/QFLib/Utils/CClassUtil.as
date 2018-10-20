//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package QFLib.Utils
{

import QFLib.Foundation;

import flash.net.getClassByAlias;

/**
 * Class utilities.
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public final class CClassUtil
{

    /**
     * No error report when the specified class was not found.
     *
     * @see flash.net.getClassByAlias()
     */
    public static function getClassByAliasName( name : String, defaultClass : Class = null ) : Class
    {
        var clz : Class = defaultClass;
        try
        {
            clz = getClassByAlias( name );
        }
        catch ( e : Error )
        {
            // ignore.
            Foundation.Log.logWarningMsg( "Cannot found the alias class: " + name + ", " + e.message );
        }

        return clz;
    }

    public static function registerClassAlias( name : String, clazz : Class ) : void
    {
        flash.net.registerClassAlias( name, clazz );
    }

    public function CClassUtil()
    {
    }

}
}
