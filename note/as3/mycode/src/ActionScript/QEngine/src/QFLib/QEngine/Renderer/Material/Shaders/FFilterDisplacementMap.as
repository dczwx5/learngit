/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved
 * Created by Again on 2017/1/3.
 */
package QFLib.QEngine.Renderer.Material.Shaders
{
    import QFLib.QEngine.Renderer.Material.IFragmentShader;

    public class FFilterDisplacementMap extends FBase implements IFragmentShader
    {
        public static const Name : String = "filterDisplacement_map";

        public static const displacementMapTexture : String = "displacementMapTex";
        public static const currentTime : String = "currentTime";
        public static const intensityAndScrolling : String = "intensityAndScrolling";
        public static const maskRect : String = "maskRect";
        public static const smoothBorder : String = "smoothBorder";
        //other const variable: x:0.5, y:2, z:1, w:0.
        public static const otherConstVal : String = "otherConst";

        private static const displacementMapTexIndex : int = 1;

        private static const cCurrTime : String = "fc0";
        private static const cIntensityAndScrolling : String = "fc1";
        private static const cMaskRect : String = "fc2";
        private static const cSmoothBorder : String = "fc3";
        //other const variable: x:0.5, y:2, z:1, w:0.
        private static const cOtherConstVal : String = "fc4";

        private static const tMinCoord : String = "ft0";
        private static const tMaxCoord : String = "ft1";
        private static const tStrength : String = "ft2";
        private static const tCoord : String = "ft3";
        private static const tTexCoordOfDisplacementMap : String = "ft4";
        private static const tScollSize : String = "ft5";
        private static const tTempTimeVal : String = "ft6";
        private static const tOffset : String = "ft6";
        private static const tTempMaskRectSize : String = "ft0";
        private static const tTempVal : String = "ft5";
        private static const tTexColor : String = "ft0";
        private static const tTexCoord : String = "ft1";

        public function FFilterDisplacementMap()
        {
            registerTex( 0, mainTexture );
            registerTex( 1, displacementMapTexture );

            registerParam( 0, currentTime );
            registerParam( 1, intensityAndScrolling );
            registerParam( 2, maskRect );
            registerParam( 3, smoothBorder );
            registerParam( 4, otherConstVal );
        }

        public function get name() : String
        {
            return Name;
        }

        public function get code() : String
        {
            var fragmentProgramCode : String =
                    GA.mov( tMinCoord + ".xy", cMaskRect + ".xy" ) +
                        //calculate max coordinate.
                    GA.mov( tMaxCoord + ".xy", cMaskRect + ".xy" ) +
                    GA.adds( tMaxCoord + ".xy", cMaskRect + ".zw" ) +
                        //init strength to 0
                    GA.mov( tStrength + ".x", cOtherConstVal + ".w" ) +
                        //clamp coordinate into border rectangle.
                        //because strength will tend to zero when coordinate tend to border.
                        //so we can set coordinate out of border to coordinate of border.
                    GA.min( tCoord + ".xy", tMaxCoord + ".xy", inTexCoord + ".xy" ) +
                    GA.maxs( tCoord + ".xy", tMinCoord + ".xy" ) +
                        //calculate current uv of displacement map
                        //here must written four component value to tTexCoordOfDisplacementMap. if not, tex call will error.
                    GA.sub( tTexCoordOfDisplacementMap, tCoord + ".xyxy", cMaskRect + ".xyxy" ) +
                    GA.divs( tTexCoordOfDisplacementMap + ".xy", cMaskRect + ".zw" ) +
                        //move uv of displacement map over time
                    GA.mov( tTempTimeVal + ".xx", cCurrTime + ".xx" ) +
                    GA.mul( tScollSize + ".xy", tTempTimeVal + ".xx", cIntensityAndScrolling + ".zw" ) +
                    GA.adds( tTexCoordOfDisplacementMap + ".xy", tScollSize + ".xy" ) +
                        //get offset from displacement map texture
                    GA.tex( tOffset, tTexCoordOfDisplacementMap, displacementMapTexIndex ) +
                    GA.muls( tOffset + ".xy", cOtherConstVal + ".yy" ) +
                    GA.subs( tOffset + ".xy", cOtherConstVal + ".zz" ) +
                    GA.muls( tOffset + ".xy", cIntensityAndScrolling + ".xy" ) +
                        //this make strength equal to zero when coordinate tend to border.
                        //and value is in range [0, 1].
                        //the SmoothBorder.xy is the border size in x and y axis.
                        //the SmoothBorder.zw is rate of reducing to zero.
                    GA.add( tTempVal + ".xy", tMaxCoord + ".xy", tMinCoord + ".xy" ) +
                    GA.muls( tTempVal + ".xy", cOtherConstVal + ".xx" ) +
                    GA.sub( tTempVal + ".xy", tCoord + ".xy", tTempVal + ".xy" ) +
                    GA.abss( tTempVal + ".xy" ) +
                    GA.mov( tTempMaskRectSize + ".xy", cMaskRect + ".zw" ) +
                    GA.mul( tTempMaskRectSize + ".xy", tTempMaskRectSize + ".xy", cOtherConstVal + ".xx" ) +
                    GA.sub( tTempVal + ".xy", tTempMaskRectSize + ".xy", tTempVal + ".xy" ) +
                        //why here tTempMaskRectSize don't use zw axis. otherwise tTempVal value finally is less than
                        // 0 if use zw axis.
//                GA.mov(tTempMaskRectSize + ".zw", cMaskRect + ".zw") +
//                GA.mul(tTempMaskRectSize + ".zw", tTempMaskRectSize + ".zw", cOtherConstVal + ".xx") +
//                GA.sub(tTempVal + ".xy", tTempMaskRectSize + ".zw", tTempVal + ".xy") +
                    GA.divs( tTempVal + ".xy", cSmoothBorder + ".xy" ) +
                        //GA.muls(tTempVal + ".xy", cSmoothBorder + ".zw") +
                    GA.mins( tTempVal + ".xy", cOtherConstVal + ".zz" ) +
                    GA.mul( tStrength + ".x", tTempVal + ".x", tTempVal + ".y" ) +

                    GA.muls( tOffset + ".xy", tStrength + ".xx" ) +
                    GA.add( tTexCoord, inTexCoord + ".xy", tOffset + ".xy" ) +
                    GA.tex( tTexColor, tTexCoord, 0 ) +
                    GA.mul( outColor, tTexColor, inColor );

            return fragmentProgramCode;
        }
    }
}
