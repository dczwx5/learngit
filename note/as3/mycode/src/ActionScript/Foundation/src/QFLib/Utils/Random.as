//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package QFLib.Utils
{
    public final class Random
    {
        [inline]
        public static function get seed01 () : Number { return Math.random (); }

        [inline]
        public static function get seed11 () : Number { return range ( -1, 1 ); }

        public static function range ( min : Number, max : Number ) : Number { return seed01 * (max - min) + min; }
    }
}
