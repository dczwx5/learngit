/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Material.Shaders
{
    import QFLib.QEngine.Renderer.Material.IFragmentShader;

    public final class FColorAlpha extends FBase implements IFragmentShader
    {
        public static const Name : String = "color.alpha";

        static private const cAlphaBias : String = "fc1.x";
        static private const brightness : String = "fc2.x";
        static private const cMaskColor : String = "fc3";

        public function FColorAlpha()
        {
            registerTex( 0, mainTexture );
            registerParam( 1, "bias" );
            registerParam( 2, "brightness" );
            registerParam( 3, "maskColor" );
        }

        public function get name() : String
        {
            return Name;
        }

        public function get code() : String
        {
            var fragmentProgramCode : String =
                    GA.tex( "ft0", inTexCoord, 0 ) +
                    GA.sub( "ft1.x", "ft0.w", cAlphaBias ) +
                    GA.kil( "ft1.x" ) +
                    GA.mov( "ft2", inColor ) +
                    GA.muls( "ft2.xyz", cMaskColor + ".www" ) +
                    GA.adds( "ft2.xyz", cMaskColor + ".xyz" ) +
                    GA.muls( "ft2", brightness ) +
                    GA.mul( outColor, "ft0", "ft2" );
            return fragmentProgramCode;
        }
    }
}