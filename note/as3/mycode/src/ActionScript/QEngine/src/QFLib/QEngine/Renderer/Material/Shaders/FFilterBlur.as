/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Material.Shaders
{
    import QFLib.QEngine.Renderer.Material.IFragmentShader;

    public final class FFilterBlur extends FBase implements IFragmentShader
    {
        public static const Name : String = "filter.blur";

        private static var cWeight : String = "fc0";

        public function FFilterBlur()
        {
            registerTex( 0, mainTexture );
            registerParam( 0, "weights" );
        }

        public function get name() : String
        {
            return Name;
        }

        public function get code() : String
        {
            // v0-v4 - kernel position
            // fs0   - input texture
            // fc0   - weight data
            // fc1   - color (optional)
            // ft0-4 - pixel color from texture
            // ft5   - output color

            var fs : String =
                    GA.tex( "ft0", VBase.vUV0, 0 ) +  		// read center pixel
                    GA.tex( "ft1", VBase.vUV1, 0 ) +
                    GA.tex( "ft2", VBase.vUV2, 0 ) +
                    GA.tex( "ft3", VBase.vUV3, 0 ) +
                    GA.tex( "ft4", VBase.vUV4, 0 ) +
                    GA.mul( "ft5", "ft0", cWeight + ".xxxx" ) +	// multiply with center weight
                    GA.muls( "ft1", cWeight + ".zzzz" ) +
                    GA.muls( "ft2", cWeight + ".yyyy" ) +
                    GA.muls( "ft3", cWeight + ".yyyy" ) +
                    GA.muls( "ft4", cWeight + ".zzzz" ) +
                    GA.adds( "ft5", "ft1" ) +
                    GA.adds( "ft5", "ft2" ) +
                    GA.adds( "ft5", "ft3" ) +
                    GA.add( outColor, "ft5", "ft4" );
            return fs;
        }
    }
}
