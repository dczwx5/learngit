/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Material.Shaders
{
    import QFLib.QEngine.Renderer.Material.IFragmentShader;

    public class FColorAlphaPMA extends FBase implements IFragmentShader
    {
        public static const Name : String = "color.alpha.pma";

        static private const cAlphaBias : String = "fc1.x";
        static private const brightness : String = "fc2.x";
        static private const cMaskColor : String = "fc3";

        public function FColorAlphaPMA()
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
                    GA.rcp( "ft1.x", "ft0.w" ) +
                    GA.muls( "ft0.xyz", "ft1.x" ) +
                    GA.muls( "ft0", inColor ) +
                    GA.muls( "ft0.xyz", cMaskColor + ".www" ) +
                    GA.adds( "ft0.xyz", cMaskColor + ".xyz" ) +
                    GA.muls( "ft0", brightness ) +
                    GA.mov( outColor, "ft0" );
            return fragmentProgramCode;
        }
    }
}