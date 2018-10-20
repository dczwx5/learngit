/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2016/7/26.
 */
package QFLib.QEngine.Renderer.Material.Shaders
{
    import QFLib.QEngine.Renderer.Material.IFragmentShader;

    public class FColorTexture extends FBase implements IFragmentShader
    {
        public static const Name : String = "color.texture";

        private static const cAlphaBias : String = "fc0.x";
        private static const cMaskColor : String = "fc1";

        public function FColorTexture()
        {
            registerTex( 0, mainTexture );
            registerParam( 0, "_bias" );
            registerParam( 1, "maskColor" )
        }

        public function get name() : String
        {
            return Name;
        }

        public function get code() : String
        {
            return GA.tex( "ft0", inTexCoord, 0 ) +
                    GA.mov( "ft1.w", "ft0.w" ) +
                    GA.subs( "ft1.w", cAlphaBias ) +
                    GA.kil( "ft1.w" ) +
                    GA.muls( "ft0.xyz", cMaskColor + ".www" ) +
                    GA.adds( "ft0.xyz", cMaskColor + ".xyz" ) +
                    GA.mul( outColor, "ft0", inColor );
        }
    }
}
