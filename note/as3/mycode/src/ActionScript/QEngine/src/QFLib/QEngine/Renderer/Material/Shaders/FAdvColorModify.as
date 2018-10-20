/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by David on 2016/10/12.
 */
package QFLib.QEngine.Renderer.Material.Shaders
{
    import QFLib.QEngine.Renderer.Material.IFragmentShader;

    public class FAdvColorModify extends FBase implements IFragmentShader
    {
        public static const Name : String = "advColorModify";

        private static const cFadeStartColor : String = "fc0";
        private static const cFadeMidColor1 : String = "fc1";
        private static const cFadeMidColor2 : String = "fc2";
        private static const cFadeEndColor : String = "fc3";

        private static const cThresold : String = "fc4";
        private static const cRGBToGray : String = "fc5";
        private static const cConstVal : String = "fc6";

        private static const tGray : String = "ft7.x";
        private static const tSat1 : String = "ft7.y";
        private static const tSat2 : String = "ft7.z";
        private static const tSat3 : String = "ft7.w";

        private static const tColor : String = "ft1";
        private static const tTemp : String = "ft2.x";
        private static const tTempColor : String = "ft3";

        public function FAdvColorModify()
        {
            super();

            registerTex( 0, mainTexture );

            registerParam( 0, "fadeStartColor" );
            registerParam( 1, "fadeMidColor1" );
            registerParam( 2, "fadeMidColor2" );
            registerParam( 3, "fadeEndColor" );
            registerParam( 4, "thresoldAndSum" );
            registerParam( 5, "rgbToGray" );
            registerParam( 6, "constVal" );
        }

        public function get name() : String
        {
            return Name;
        }

        public function get code() : String
        {
            return GA.tex( "ft0", inTexCoord, 0 ) +
                    GA.muls( "ft0", inColor ) +
                    GA.sub( "ft1.x", "ft0.w", cConstVal + ".z" ) +
                    GA.kil( "ft1.x" ) +
                    GA.dot3( tGray, "ft0.xyz", cRGBToGray + ".xyz" ) +
                    GA.muls( tGray, cRGBToGray + ".w" ) +
                    GA.muls( tGray, cConstVal + ".x" ) +
                    GA.adds( tGray, cThresold + ".w" ) +
                    GA.divs( tGray, cConstVal + ".x" ) +
                    GA.frc( tGray, tGray ) +
                    GA.muls( tGray, cConstVal + ".x" ) +
                    GA.div( tSat1, tGray, cThresold + ".x" ) +
                    GA.sge( tSat1, tSat1, cConstVal + ".y" ) +
                    GA.div( tSat2, tGray, cThresold + ".y" ) +
                    GA.sge( tSat2, tSat2, cConstVal + ".y" ) +
                    GA.div( tSat3, tGray, cThresold + ".z" ) +
                    GA.sge( tSat3, tSat3, cConstVal + ".y" ) +
                    GA.mul( tColor, cFadeEndColor, tSat3 ) +
                    GA.sub( tTemp, tSat2, tSat3 ) +
                    GA.mul( tTempColor, cFadeMidColor2, tTemp ) +
                    GA.adds( tColor, tTempColor ) +
                    GA.sub( tTemp, tSat1, tSat2 ) +
                    GA.mul( tTempColor, cFadeMidColor1, tTemp ) +
                    GA.adds( tColor, tTempColor ) +
                    GA.sub( tTemp, cConstVal + ".y", tSat1 ) +
                    GA.mul( tTempColor, cFadeStartColor, tTemp ) +
                    GA.adds( tColor, tTempColor ) +
                    GA.mov( tColor + ".w", "ft0.w" ) +
                    GA.mov( outColor, tColor );
        }
    }
}
