/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2016/12/7.
 */
package QFLib.QEngine.Renderer.Material.Shaders
{
    import QFLib.QEngine.Renderer.Material.IFragmentShader;

    public class FGaussianBlur extends FBase implements IFragmentShader
    {
        public static const Name : String = "f.compostor.gaussian.blur";

        private static const cWeight : String = "fc0";

        private static const cWeightOffsets : String = "fc1";
        private static const tAddedColor : String = "ft0";
        private static const tTempColor : String = "ft1";
        private static const tTempCoord : String = "ft2";

        public function FGaussianBlur()
        {
            registerTex( 0, mainTexture );
            registerParam( 0, "weights" );
            registerParam( 1, "centerWeightAndOffsets" );
        }

        public function get name() : String
        {
            return Name;
        }

        public function get code() : String
        {
            var fs : String =
                    GA.tex( tAddedColor, VBase.vUV0, 0 ) +  		// read center pixel
                    GA.muls( tAddedColor, cWeightOffsets + ".xxxx" ) +

                    GA.tex( tTempColor, VBase.vUV1, 0 ) +
                    GA.muls( tTempColor, cWeight + ".xxxx" ) +
                    GA.adds( tAddedColor, tTempColor ) +
                    GA.tex( tTempColor, VBase.vUV5, 0 ) +
                    GA.muls( tTempColor, cWeight + ".xxxx" ) +
                    GA.adds( tAddedColor, tTempColor ) +

                    GA.tex( tTempColor, VBase.vUV2, 0 ) +
                    GA.muls( tTempColor, cWeight + ".yyyy" ) +
                    GA.adds( tAddedColor, tTempColor ) +
                    GA.tex( tTempColor, VBase.vUV6, 0 ) +
                    GA.muls( tTempColor, cWeight + ".yyyy" ) +
                    GA.adds( tAddedColor, tTempColor ) +

                    GA.tex( tTempColor, VBase.vUV3, 0 ) +
                    GA.muls( tTempColor, cWeight + ".zzzz" ) +
                    GA.adds( tAddedColor, tTempColor ) +
                    GA.tex( tTempColor, VBase.vUV7, 0 ) +
                    GA.muls( tTempColor, cWeight + ".zzzz" ) +
                    GA.adds( tAddedColor, tTempColor ) +

//                    GA.tex ( tTempColor, VCompositorGaussianBlur.vUV4, 0 ) +
//                    GA.muls ( tTempColor, cWeight + ".wwww" ) +
//                    GA.adds( tAddedColor, tTempColor ) +
                    GA.mov( outColor, tAddedColor );
            return fs;
        }
    }
}
