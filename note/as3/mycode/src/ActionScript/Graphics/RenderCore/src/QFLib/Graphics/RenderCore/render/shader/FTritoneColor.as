////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

/**
 * Created by david on 2016/12/20.
 */
package QFLib.Graphics.RenderCore.render.shader
{
    import QFLib.Graphics.RenderCore.render.IFragmentShader;

    public class FTritoneColor extends FBase implements IFragmentShader
    {
        public static const Name : String = "tritoneColor";

        private static const cHighLightColor : String = "fc0";
        private static const cMiddleColor : String = "fc1";
        private static const cLowKeyColor : String = "fc2";

        private static const cConstVal : String = "fc3";
        private static const cRGBToGray : String = "fc4";

        private static const tGray : String = "ft0.x";
        private static const tSat : String = "ft1.x";
        private static const tInvSat : String = "ft1.y";
        private static const tGrayMoreThanPointFive : String = "ft1.z";
        private static const tFactor : String = "ft1.w";
        private static const tTempFactor : String = "ft0.y";
        private static const tInvFactor : String = "ft0.z";


        private static const tStartColor : String = "ft2";
        private static const tEndColor : String = "ft3";

        private static const tTempColor0 : String = "ft4";
        private static const tTempColor1 : String = "ft5";

        private static const tFragColor : String = "ft6";

        public function FTritoneColor ()
        {
            super ();

            registerTex ( 0, mainTexture );

            registerParam ( 0, "highLightColor" );
            registerParam ( 1, "middleColor" );
            registerParam ( 2, "lowKeyColor" );
            registerParam ( 3, "constVal" );
            registerParam ( 4, "rgbToGray" );
        }

        public function get name () : String
        {
            return Name;
        }

        public function get code () : String
        {
            var s : String =
                    GA.tex ( tFragColor, inTexCoord, 0 ) +
                    GA.muls ( tFragColor, inColor ) +
                    GA.sub ( "ft1.x", tFragColor + ".w", cConstVal + ".w" ) +
                    GA.kil ( "ft1.x" ) +
                    GA.dot3 ( tGray, tFragColor + ".xyz", cRGBToGray + ".xyz" ) +
                    GA.muls ( tGray, cRGBToGray + ".w" ) +
                    GA.sub ( tGrayMoreThanPointFive, tGray, cConstVal + ".y" ) +
                    GA.mul ( tSat, tGray, cConstVal + ".z" ) +
                    GA.sat ( tSat, tSat ) +
                    //GA.sge ( tSat, tSat, cConstVal + ".x") +
                    GA.sub ( tInvSat, cConstVal + ".x", tSat ) +
                    GA.mul ( tTempColor0, cLowKeyColor, tInvSat ) +
                    GA.mul ( tTempColor1, cMiddleColor, tSat ) +
                    GA.add ( tStartColor, tTempColor0, tTempColor1 ) +
                    GA.mul ( tTempColor0, cMiddleColor, tInvSat ) +
                    GA.mul ( tTempColor1, cHighLightColor, tSat ) +
                    GA.add ( tEndColor, tTempColor0, tTempColor1 ) +
                    GA.mul ( tTempFactor, tGray, tInvSat ) +
                    GA.mov ( tFactor, tTempFactor ) +
                    GA.mul ( tTempFactor, tGrayMoreThanPointFive, tSat ) +
                    GA.adds ( tFactor, tTempFactor ) +
                    GA.muls ( tFactor, cConstVal + ".z" ) +
                    GA.sub ( tInvFactor, cConstVal + ".x", tFactor ) +
                    GA.muls ( tStartColor, tInvFactor ) +
                    GA.muls ( tEndColor, tFactor ) +
                    GA.adds ( tEndColor, tStartColor ) +
                    GA.adds ( tFragColor + ".xyz", tEndColor + ".xyz" ) +
                    GA.mov ( outColor, tFragColor );
            return s;
        }
    }
}
