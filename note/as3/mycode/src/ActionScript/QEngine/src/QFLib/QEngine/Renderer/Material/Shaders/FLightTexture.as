/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2016/7/25.
 */
package QFLib.QEngine.Renderer.Material.Shaders
{
    import QFLib.QEngine.Renderer.Material.IFragmentShader;

    public final class FLightTexture extends FBase implements IFragmentShader
    {
        public static const Name : String = "light.texture";

        private static const inContrast : String = "fc0";
        private static const cAlphaBias : String = "fc1.x";
        private static const cMaskColor : String = "fc2";

        public function FLightTexture()
        {
            registerTex( 0, mainTexture );
            registerParam( 0, "lightContrast" );
            registerParam( 1, "bias" );
            registerParam( 2, "maskColor" );
        }

        public function get name() : String
        {
            return Name;
        }

        public function get code() : String
        {
            return GA.tex( "ft1", inTexCoord, 0 ) +
                    GA.muls( "ft1", inColor ) +
                    GA.mov( "ft3.w", "ft1.w" ) +
                    GA.subs( "ft3.w", cAlphaBias ) +
                    GA.kil( "ft3.w" ) +
                    GA.muls( "ft1.xyz", cMaskColor + ".www" ) +
                    GA.adds( "ft1.xyz", cMaskColor + ".xyz" ) +
                    GA.muls( "ft1.xyz", inContrast + ".zzz" ) +
                    GA.mov( "ft2.xyz", inContrast + ".www" ) +
                    GA.muls( "ft2.xyz", inContrast + ".yyy" ) +
                    GA.subs( "ft1.xyz", "ft2.xyz" ) +
                    GA.mov( outColor, "ft1" );
        }
    }
}
