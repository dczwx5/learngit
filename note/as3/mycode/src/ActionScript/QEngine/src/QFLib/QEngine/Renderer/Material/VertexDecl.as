/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Material
{
    public class VertexDecl
    {
                public static function getDefPositionDecl() : VertexDecl
        {
            return null;
        }		//enum: 0=position 1=color 2:uv;

        public static function getDefColor4Decl() : VertexDecl
        {
            return null;
        }		//index of source stream array

        public static function getDefColor32Decl() : VertexDecl
        {
            return null;
        }	//float2 flaot4 byte4

        public static function getDefTexcoordDecl() : VertexDecl
        {
            return null;
        }		//stride in stream.

        public function VertexDecl()
        {
        }
public var sematic : int = 0;
public var stream : int = 0;
public var dataType : int = 0;
public var offset : int = 0;
    }
}