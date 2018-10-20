/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Material
{
    public final class VertexLayout
    {
        static public var IDX_POSITION : int = 0;
        static public var IDX_COLOR0 : int = 1;
        static public var IDX_TEXCOORD0 : int = 2;
        static public var IDX_TEXCOORD1 : int = 3;
        static public var IDX_TEXCOORD2 : int = 4;
        static public var IDX_TEXCOORD3 : int = 5;
        static public var IDX_COLOR1 : int = 6;
        static public var IDX_COLOR2 : int = 7;
        static public var IDX_COUNT : int = 8;

        static public function flag( position : Boolean,
                                     color0 : Boolean,
                                     texcoord0 : Boolean,
                                     texcoord1 : Boolean,
                                     texcoord2 : Boolean,
                                     texcoord3 : Boolean,
                                     color1 : Boolean,
                                     color2 : Boolean ) : uint
        {
            var flag : uint = 0;
            var flagModifier : uint;
            if( position )    flag |= 1 << IDX_POSITION;
            if( color0 )        flag |= 1 << IDX_COLOR0;
            if( texcoord0 )    flag |= 1 << IDX_TEXCOORD0;
            if( texcoord1 )    flag |= 1 << IDX_TEXCOORD1;
            if( texcoord2 )    flag |= 1 << IDX_TEXCOORD2;
            if( texcoord3 )    flag |= 1 << IDX_TEXCOORD3;
            if( color1 )        flag |= 1 << IDX_COLOR1;
            if( color2 )        flag |= 1 << IDX_COLOR2;
            return flag;
        }
    }
}