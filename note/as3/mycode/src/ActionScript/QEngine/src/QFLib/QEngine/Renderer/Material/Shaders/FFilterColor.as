/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Material.Shaders
{
    import QFLib.QEngine.Renderer.Material.IFragmentShader;

    public final class FFilterColor extends FBase implements IFragmentShader
    {
        public static const Name : String = "filter.color";
        public static const ColorMatrix : String = "colorMatrix";
        public static const MinColor : String = "minColor";

        static private const cColorMatrix : String = "fc0";
        static private const cColorOffset : String = "fc4";
        static private const cMinColor : String = "fc5";

        public function FFilterColor()
        {
            registerTex( 0, mainTexture );
            registerParam( 0, ColorMatrix );
            registerParam( 5, MinColor );
        }

        public function get name() : String
        {
            return Name;
        }

        public function get code() : String
        {
            var fs : String =
                    GA.tex( "ft0", inTexCoord, 0 ) +				// read texture color
                    GA.maxs( "ft0", cMinColor ) + 				// avoid division through zero in next step
                    GA.divs( "ft0.xyz", "ft0.www" ) +				// restore original (non-PMA) RGB values
                    GA.m44( "ft0", "ft0", cColorMatrix ) + 	// multiply color with 4x4 matrix
                    GA.adds( "ft0", cColorOffset ) +				// add color offset
                    GA.muls( "ft0.xyz", "ft0.www" ) + 				// multiply with alpha again (PMA)
                    GA.mov( outColor, "ft0" );						// copy to output;
            return fs;
        }
    }
}