/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2016/12/12.
 */
package QFLib.QEngine.Renderer.Material.Shaders
{
    import QFLib.QEngine.Renderer.Material.IFragmentShader;

    public class FSmooth extends FBase implements IFragmentShader
    {
        public static const Name : String = "f.smooth";

        private static const cWeight : String = "fc0";
        private static const tAddedColor : String = "ft0";
        private static const tTempColor : String = "ft1";

        public function FSmooth()
        {
            registerTex( 0, mainTexture );
            registerParam( 0, "uvOffsets" );
        }

        public function get name() : String
        {
            return Name;
        }

        public function get code() : String
        {
            var s : String =
                    GA.tex( tAddedColor, VBase.vUV0, 0 ) +  		// read center pixel

                    GA.tex( tTempColor, VBase.vUV1, 0 ) +
                    GA.adds( tAddedColor, tTempColor ) +

                    GA.tex( tTempColor, VBase.vUV2, 0 ) +
                    GA.adds( tAddedColor, tTempColor ) +

                    GA.tex( tTempColor, VBase.vUV3, 0 ) +
                    GA.adds( tAddedColor, tTempColor ) +

                    GA.tex( tTempColor, VBase.vUV4, 0 ) +
                    GA.adds( tAddedColor, tTempColor ) +

                    GA.divs( tAddedColor, cWeight + ".wwww" ) +
                    GA.mov( outColor, tAddedColor );
            return s;
        }
    }
}
