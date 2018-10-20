/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Material
{
    public interface IFragmentShader
    {
        function get name() : String;

        function get code() : String;

        function get textureLayout() : Vector.<ParamTex>;

        function get paramLayout() : Vector.<ParamConst>;
    }
}