/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Material
{
    import QFLib.QEngine.Renderer.Textures.Texture;

    import flash.geom.Matrix3D;

    public interface IPass
    {
        function get name() : String;

        function get vertexShader() : String;

        function get fragmentShader() : String;

        function get shaderName() : Number;

        function set texture( value : Texture ) : void;

function get blendMode() : String;

        function set blendMode( value : String ) : void;

        function get pma() : Boolean;

        function set pma( value : Boolean ) : void;

                function get srcOp() : String;	//see class BlendMode;

        function get dstOp() : String;

        function get renderTarget() : Texture;

        function get usingRTT() : Boolean;

        function get texFlagList() : Vector.<String>;

        function getTexture( name : String ) : Texture;

        function getVector( name : String ) : Vector.<Number>;

        function getMatrix( name : String ) : Matrix3D;

        function equal( other : IPass ) : Boolean;

        function copy( other : IPass ) : void;

        function clone() : IPass;

        function dispose() : void;
    }
}
