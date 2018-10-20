/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */
package QFLib.QEngine.Renderer.Material.Shaders
{
    import QFLib.QEngine.Renderer.Material.IFragmentShader;

    public class FFilterAlpha extends FBase implements IFragmentShader
    {
        public static const Name : String = "filter.alpha"
        public static const Alpha : String = "alpha"

        static private const cAlpha : String = "fc0.x";

        public function FFilterAlpha()
        {
            registerTex( 0, mainTexture );
            registerParam( 0, Alpha );
        }

        public function get name() : String
        {
            return Name;
        }

        public function get code() : String
        {
            var fragmentProgramCode : String =
                    GA.tex( "ft0", inTexCoord, 0 ) +
                    GA.mov( "ft1.a", "ft0.a" ) +
                    GA.muls( "ft0.xyz", "ft1.aaa" ) +
                    GA.muls( "ft0", cAlpha ) +
                    GA.mov( outColor, "ft0" );
            return fragmentProgramCode;
        }
    }
}
