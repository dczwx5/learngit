/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Material.Shaders
{
    import QFLib.QEngine.Renderer.Material.ParamConst;

    public class VBase
    {
        protected static const inPosition : String = "va0";
        protected static const inColor : String = "va1";
        protected static const inTexCoord : String = "va2";
        protected static const inGeneric0 : String = "va3";
        protected static const inGeneric1 : String = "va4";
        protected static const inGeneric2 : String = "va5";
        protected static const inNormal : String = "va6";
        protected static const inTangent : String = "va7";
        protected static const outPos : String = "op";

        //以下常量与renderer里的预设值对应
        public static const matrixWorld : String = "matrixWorld";
        public static const matrixView : String = "matrixView";
        public static const matrixProj : String = "matrixProj";
        public static const matrixVP : String = "matrixVP";
        public static const matrixMVP : String = "matrixMVP";

        //以下变量与SFBase是互相对应的
        public static const outColor : String = "v0";
        public static const outTexCoord : String = "v1";

        //后效一些特别的处理需要使用
        public static const vUV0 : String = "v0";
        public static const vUV1 : String = "v1";
        public static const vUV2 : String = "v2";
        public static const vUV3 : String = "v3";
        public static const vUV4 : String = "v4";
        public static const vUV5 : String = "v5";
        public static const vUV6 : String = "v6";
        public static const vUV7 : String = "v7";

        private var _paramLayout : Vector.<ParamConst> = new Vector.<ParamConst>();

        public function get paramLayout() : Vector.<ParamConst>
        {
            return _paramLayout;
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