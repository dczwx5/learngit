/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Utils
{
    // TODO: add number formatting options

    /** Formats a String in .Net-style, with curly braces ("{0}"). Does not support any
     *  number formatting options yet. */
    public function FormatString( format : String, ...args ) : String
    {
        for( var i : int = 0; i < args.length; ++i )
            format = format.replace( new RegExp( "\\{" + i + "\\}", "g" ), args[ i ] );

        return format;
    }
}