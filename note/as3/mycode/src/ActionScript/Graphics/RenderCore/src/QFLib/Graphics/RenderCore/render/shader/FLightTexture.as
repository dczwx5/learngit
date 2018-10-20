//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by david on 2016/7/25.
 */
package QFLib.Graphics.RenderCore.render.shader
{
    import QFLib.Graphics.RenderCore.render.IFragmentShader;

    public final class FLightTexture extends FBase implements IFragmentShader
    {
        public static const Name:String = "light.texture";

        private static const inContrast:String = "fc0";
        private static const cAlphaBias:String = "fc1.x";
        private static const cMaskColor:String = "fc2";
        private static const cDstBlendFactor:String = "fc2.www";

        public function FLightTexture()
        {
            registerTex(0, mainTexture);
            registerParam(0, "lightContrast");
            registerParam(1, "bias");
            registerParam(2, "maskColor");
        }

        public function get name():String
        {
            return Name;
        }

        public function get code():String
        {
            //"ft3.w" = 1.0 mean that the texture has not tpremultiply alpha
            return GA.tex("ft1", inTexCoord, 0) +
                    GA.muls("ft1", inColor) +
                    GA.add("ft3.w", "ft1.w", "fc1.y") +
                    GA.sat("ft3.w", "ft3.w") +
                    GA.sub( "ft5.w", "ft3.w", cAlphaBias) +
                    GA.kil("ft5.w") +
                    GA.divs("ft1.xyz", "ft3.www") +
                    GA.muls("ft1.xyz", cDstBlendFactor ) +
                    GA.adds("ft1.xyz", cMaskColor + ".xyz" ) +
                    GA.subs("ft1.xyz",inContrast+".www") +
                    GA.muls("ft1.xyz", inContrast+".zzz") +
                    GA.adds("ft1.xyz",inContrast+".www")+
                    GA.muls("ft1.xyz", "ft1.www") +
                    GA.mov(outColor, "ft1");
        }
    }
}
