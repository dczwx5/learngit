/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Material
{
    import QFLib.Foundation.CMap;
    import QFLib.QEngine.Renderer.Textures.Texture;

    public interface IMaterial
    {
        function get isTransparent() : Boolean;

        function get isShadowCaster() : Boolean;

        function get isShadowReceiver() : Boolean;

        function get passes() : Vector.<IPass>;

        function get inactivePasses() : CMap;

        function get orignalPass() : IPass;

        function get useTexcoord() : Boolean;

        function get useColor() : Boolean;

        function set texture( value : Texture ) : void;

        function setTintColorWithAlpha( red : Number, green : Number, blue : Number, alpha : Number ) : void;

        function equal( other : IMaterial ) : Boolean;

        function setPass( passName : String, firstPass : Boolean ) : String;

        function addInactivePass( pass : IPass ) : void;

        function addInactivePassByName( passName : String, className : Class ) : IPass;

        function cleanInactivePasses() : void;

        function clone() : IMaterial;

        function dispose() : void;
    }
}