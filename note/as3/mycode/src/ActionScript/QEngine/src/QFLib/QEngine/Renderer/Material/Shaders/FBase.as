/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Material.Shaders
{
    import QFLib.QEngine.Renderer.Material.ParamConst;
    import QFLib.QEngine.Renderer.Material.ParamTex;

    public class FBase
    {
        protected static const outColor : String = "oc";
        //以下SVBase是互相对应的
        protected static const inColor : String = VBase.outColor;
        protected static const inTexCoord : String = VBase.outTexCoord;

        public static const mainTexture : String = "texture";

        private var _paramLayout : Vector.<ParamConst> = new Vector.<ParamConst>();

        public function get paramLayout() : Vector.<ParamConst>
        {
            return _paramLayout;
        }

        private var _textureLayout : Vector.<ParamTex> = new Vector.<ParamTex>();

        public function get textureLayout() : Vector.<ParamTex>
        {
            return _textureLayout;
        }

        protected function registerTex( index : int, name : String ) : void
        {
            var textureParam : ParamTex = new ParamTex();
            textureParam.index = index;
            textureParam.name = name;
            _textureLayout.push( textureParam );
        }

        protected function registerParam( index : int, name : String, isMatrix : Boolean = false, transpose : Boolean = true ) : void
        {
            var param : ParamConst = new ParamConst();
            param.index = index;
            param.name = name;
            param.isMatrix = isMatrix;
            param.transpose = transpose;
            _paramLayout.push( param );
        }
    }
}