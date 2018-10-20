/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Utils
{
    /** Returns the next power of two that is equal to or bigger than the specified number. */
    public function GetNextPowerOfTwo( number : int ) : int
    {
        if( number > 0 && (number & (number - 1)) == 0 ) // see: http://goo.gl/D9kPj
            return number;
        else
        {
            var result : int = 1;
            while( result < number ) result <<= 1;
            return result;
        }
    }
}