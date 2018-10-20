////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

/**
 * Created by david on 2017/5/26.
 */
package QFLib.Graphics.RenderCore.render.shader
{
    import QFLib.Graphics.RenderCore.render.IFragmentShader;

    public class FDistortion extends FBase implements IFragmentShader
    {
        public static const Name : String = "f.distortion";

        private static const cDistortionSize : String = "fc0.x";
        private static const cIntervalSize : String = "fc0.y";
        private static const cAmplitude : String = "fc0.z";
        private static const cCycleSize : String = "fc0.w";
        private static const cRangeXStart : String = "fc1.x";
        private static const cRangeXEnd : String = "fc1.y";
        private static const cRangYStart : String = "fc1.z";
        private static const cRangeYEnd : String = "fc1.w";
        private static const cCurrentStart1 : String = "fc2.x";
        private static const cCurrentEnd1 : String = "fc2.y";
        private static const cCurrentStart2 : String = "fc2.z";
        private static const cCurrentEnd2 : String = "fc2.w";
        private static const cZero : String = "fc3.x";
        private static const cMinusOne : String = "fc3.y";
        private static const cTwoPi : String = "fc3.z";
        private static const cOne : String = "fc3.w";
        private static const cDirection : String = "fc4";

        private static const tTexColor : String = "ft0";
        private static const tTempU1 : String = "ft2.x";
        private static const tTempU2 : String = "ft2.y";
        private static const tTempV1 : String = "ft2.z";
        private static const tTempV2 : String = "ft2.w";
        private static const tMod1 : String = tTempV2;
        private static const tMod2 : String = tTempV1;
        private static const tUV : String = "ft3";
        private static const tFactor1 : String = "ft4.x";
        private static const tFactor2 : String = "ft4.y";
        private static const tFactor3 : String = "ft4.z";
        private static const tTempMulFactor : String = "ft2.x";
        private static const tMulFactor : String = "ft4.w";
        private static const tTempColor : String = "ft5";
        private static const tTempColor2 : String = "ft6";
        private static const tAmplitude : String = "ft7.x";
        private static const tAltitude : String = "ft7.y";
        private static const tAttribute : String = "ft7.z";
        private static const tFactor4 : String = "ft7.w";

        public function FDistortion ()
        {
            super ();

            registerTex ( 0, mainTexture );
            registerParam ( 0, "distortionSize" );
            registerParam ( 1, "range" );
            registerParam ( 2, "currentPos" );
            registerParam ( 3, "constVal" );
            registerParam ( 4, "direction" );
        }

        public function get name () : String
        {
            return Name;
        }

        /**
         * 参照对应的Unity端的实现
         */
        public function get code () : String
        {
            return GA.tex ( tTexColor, inTexCoord, 0 ) +
                    GA.sub ( tTempU1, inTexCoord + ".x", cRangeXStart ) +
                    GA.sub ( tTempU2, inTexCoord + ".x", cRangeXEnd ) +
                    GA.mul ( tFactor1, tTempU1, tTempU2 ) +
                    GA.slt ( tFactor1, cZero, tFactor1 ) +
                    GA.sub ( tTempV1, inTexCoord + ".y", cCurrentStart1 ) +
                    GA.sub ( tTempV2, inTexCoord + ".y", cCurrentEnd1 ) +
                    GA.mul ( tFactor2, tTempV1, tTempV2 ) +
                    GA.slt ( tFactor2, cZero, tFactor2 ) +
                    GA.sub ( tTempV1, inTexCoord + ".y", cCurrentStart2 ) +
                    GA.sub ( tTempV2, inTexCoord + ".y", cCurrentEnd2 ) +
                    GA.mul ( tFactor3, tTempV1, tTempV2 ) +
                    GA.slt ( tFactor3, cZero, tFactor3 ) +
                    GA.muls ( tFactor2, tFactor3 ) +
                    GA.adds ( tFactor1, tFactor2 ) +
                    GA.slt ( tFactor1, cZero, tFactor1 ) +
                    GA.mul ( tTempColor, tTexColor, tFactor1 + "xxx" ) +

                    GA.sub ( tFactor2, cOne, tFactor1 ) +

                    GA.sge ( tFactor1, cZero, tMod2 ) +
                    GA.abs ( tMod2, tMod2 ) +
                    GA.divs ( tMod2, cCycleSize ) +
                    GA.frc ( tMod2, tMod2 ) +
                    GA.muls ( tMod2, cCycleSize ) +
                    GA.muls ( tMod2, tFactor1 ) +

                    GA.sub ( tMod1, inTexCoord + ".y", cCurrentEnd1 ) +
                    GA.divs ( tMod1, cCycleSize ) +
                    GA.frc ( tMod1, tMod1 ) +
                    GA.muls ( tMod1, cCycleSize ) +
                    GA.subs ( tMod1, cIntervalSize ) +
                    GA.sub ( tFactor3, cOne, tFactor1 ) +
                    GA.muls ( tMod1, tFactor3 ) +

                    GA.mul ( tMulFactor, cOne, tFactor1 ) +
                    GA.mul ( tTempMulFactor, cMinusOne, tFactor3 ) +
                    GA.adds ( tMulFactor, tTempMulFactor ) +

                    GA.adds ( tMod1, tMod2 ) +
                    GA.sub ( tFactor1, tMod1, cZero ) +
                    GA.sub ( tFactor4, tMod1, cDistortionSize ) +
                    GA.muls ( tFactor1, tFactor4 ) +
                    GA.slt ( tFactor1, cZero, tFactor1 ) +
                        //GA.slt ( tFactor1, cDistortionSize, tMod1 ) +
                    GA.sub ( tFactor3, cOne, tFactor1 ) +

                    GA.mul ( tTempColor2, tTexColor, tFactor1 + "xxx" ) +
                    GA.muls ( tTempColor2, tFactor2 + "yyy" ) +
                    GA.adds ( tTempColor, tTempColor2 ) +

                    GA.sub ( tAmplitude, inTexCoord + ".y ", cRangeYEnd ) +
                    GA.muls ( tAmplitude, cAmplitude ) +
                    GA.muls ( tAmplitude, tMulFactor ) +
                    GA.div ( tAttribute, tMod1, cDistortionSize ) +
                    GA.muls ( tAttribute, cTwoPi ) +
                    GA.sin ( tAltitude, tAttribute ) +
                    GA.muls ( tAltitude, tAmplitude ) +

                    GA.mov ( tUV, inTexCoord ) +
                    GA.adds ( tUV + ".x", tAltitude ) +
                    GA.tex ( tTempColor2, tUV, 0 ) +
                    GA.muls ( tTempColor2, tFactor2 + "yyy" ) +
                    GA.muls ( tTempColor2, tFactor3 + "zzz" ) +
                    GA.adds ( tTempColor, tTempColor2 ) +
                    //GA.muls ( tTempColor + ".xyz", tTempColor + ".www" ) +
                    GA.mov ( outColor, tTempColor );
        }
    }
}