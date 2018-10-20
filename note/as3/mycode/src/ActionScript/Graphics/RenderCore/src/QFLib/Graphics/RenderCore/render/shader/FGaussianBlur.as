////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

/**
 * Created by david on 2016/12/7.
 */
package QFLib.Graphics.RenderCore.render.shader
{

    import QFLib.Graphics.RenderCore.render.IFragmentShader;

    public class FGaussianBlur extends FBase implements IFragmentShader
    {
        public static const Name : String = "f.gaussian.blur";

        private static const cWeight : String = "fc0";
        private static const cWeightOffsets : String = "fc1";
        private static const cBlurFactor : String = "fc1.www";
        private static const cGlowColor : String = "fc2";
        private static const cGlowFactor : String = "fc2.www";
        private static const cGlowStrenthen : String = "fc3.x";
        private static const cAlphaBias : String = "fc3.y";

        private static const tAddedColor : String = "ft0";
        private static const tTempColor : String = "ft1";

        public function FGaussianBlur()
        {
            registerTex( 0, mainTexture );
            registerParam ( 0, "weights" );
            registerParam ( 1, "centerWeightAndOffsets" );
            registerParam ( 2, "glowColor" );
            registerParam ( 3, "glowStrenthen" );
        }

        public function get name () : String
        {
            return Name;
        }

        public function get code():String
        {
            var fs : String =
                    GA.tex ( tAddedColor, VBase.vUV0, 0 ) +  		// read center pixel
                    GA.muls ( tAddedColor, cWeightOffsets + ".xxxx" ) +

                    GA.tex ( tTempColor, VBase.vUV1, 0 ) +
                    GA.muls ( tTempColor, cWeight + ".xxxx" ) +
                    GA.adds( tAddedColor, tTempColor ) +
                    GA.tex ( tTempColor, VBase.vUV5, 0 ) +
                    GA.muls ( tTempColor, cWeight + ".xxxx" ) +
                    GA.adds( tAddedColor, tTempColor ) +

                    GA.tex ( tTempColor, VBase.vUV2, 0 ) +
                    GA.muls ( tTempColor, cWeight + ".yyyy" ) +
                    GA.adds( tAddedColor, tTempColor ) +
                    GA.tex ( tTempColor, VBase.vUV6, 0 ) +
                    GA.muls ( tTempColor, cWeight + ".yyyy" ) +
                    GA.adds( tAddedColor, tTempColor ) +

                    GA.tex ( tTempColor, VBase.vUV3, 0 ) +
                    GA.muls ( tTempColor, cWeight + ".zzzz" ) +
                    GA.adds( tAddedColor, tTempColor ) +
                    GA.tex ( tTempColor, VBase.vUV7, 0 ) +
                    GA.muls ( tTempColor, cWeight + ".zzzz" ) +
                    GA.adds ( tAddedColor, tTempColor ) +

//                    GA.tex ( tTempColor, VCompositorGaussianBlur.vUV4, 0 ) +
//                    GA.muls ( tTempColor, cWeight + ".wwww" ) +
//                    GA.adds( tAddedColor, tTempColor ) +

                    GA.mov ( "ft3.w", tAddedColor + ".w" ) +
                    GA.subs ( "ft3.w", cAlphaBias ) +
                    GA.kil ( "ft3.w" ) +
                    GA.mov ( tTempColor, cGlowColor ) +
                    GA.muls ( tTempColor + ".xyz", tAddedColor + ".www" ) +
                    GA.adds ( tTempColor + ".w", cGlowStrenthen ) +
                    GA.muls ( tAddedColor + ".xyz", cBlurFactor ) +
                    GA.muls ( tTempColor + ".xyz", cGlowFactor ) +
                    GA.adds ( tAddedColor + ".xyz", tTempColor + ".xyz" ) +

                    GA.mov ( outColor, tAddedColor );
            return fs;
        }
    }
}