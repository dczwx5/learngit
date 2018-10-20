//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by david on 2017/5/15.
 */
package QFLib.Graphics.RenderCore.render.shader
{
    import QFLib.Graphics.RenderCore.render.IFragmentShader;

    public class FRimLight extends FBase implements IFragmentShader
    {
        public static const Name : String = "f.rimlight";

        private static const cConstVal : String = "fc0";
        private static const cUVExpand : String = "fc1";
        private static const cAlphaBias : String = "fc1.w";

        private static const tUV : String = "ft0";
        private static const tAddedColor : String = "ft1";
        private static const tTempColor : String = "ft2";
        private static const tTempColor2 : String = "ft3";

        public function FRimLight ()
        {
            registerTex ( 0, mainTexture );
            registerParam ( 0, "constVal" );
            registerParam ( 1, "uvExpand" );
        }

        public function get name () : String
        {
            return Name;
        }

        public function get code () : String
        {
//            return GA.add ( tUV, inTexCoord, cUVExpand + ".yzxx" ) +                       //pos: (-1.0, 0.0)
//                    GA.tex ( tAddedColor, tUV, 0 ) +
//                    GA.muls ( tAddedColor, cConstVal + ".yyyy") +
//
//                    GA.add ( tUV, inTexCoord, cUVExpand + ".xzxx" ) +                      //pos: (1.0, 0.0)
//                    GA.tex ( tTempColor, tUV, 0 ) +
//                    GA.muls ( tTempColor, cConstVal + ".xxxx" ) +
//
//                    GA.adds ( tAddedColor, tTempColor ) +
//                    GA.slt ( tTempVal, tAddedColor + ".w", cZero ) +
//                    GA.mul ( tScaleValL, cScale + ".x", tTempVal ) +
//                    GA.slt ( tTempVal, cZero, tAddedColor + ".w" ) +
//                    GA.mul ( tScaleValR, cScale + ".y", tTempVal ) +
//                    GA.add ( tScaleVal, tScaleValL, tScaleValR ) +
//
//                    GA.mul ( tUV, inTexCoord, tScaleVal + ".wwww" ) +
//                    GA.tex ( tTempColor, tUV, 0 ) +
//                    GA.mul ( outColor, tTempColor + ".wwww", inColor );
            return GA.add ( tUV, inTexCoord, cUVExpand + ".yyxx" ) +            //(-1,-1)
                    GA.tex ( tTempColor, tUV, 0 ) +
                    GA.muls ( tTempColor, cConstVal + ".xxxx" ) +
                    GA.mov ( tAddedColor, tTempColor ) +

                    GA.add ( tUV, inTexCoord, cUVExpand + ".yzxx" ) +          //(-1, 0)
                    GA.tex ( tTempColor, tUV, 0 ) +
                    GA.muls ( tTempColor, cConstVal + ".xxxx" ) +
                    GA.adds ( tAddedColor, tTempColor ) +

                    GA.add ( tUV, inTexCoord, cUVExpand + ".yxxx" ) +                //(-1, 1)
                    GA.tex ( tTempColor, tUV, 0 ) +
                    GA.muls ( tTempColor, cConstVal + ".xxxx" ) +
                    GA.adds ( tAddedColor, tTempColor ) +

                    GA.add ( tUV, inTexCoord, cUVExpand + ".zyxx" ) +                   //(0, -1)
                    GA.tex ( tTempColor, tUV, 0 ) +
                    GA.muls ( tTempColor, cConstVal + ".xxxx" ) +
                    GA.adds ( tAddedColor, tTempColor ) +

                    GA.add ( tUV, inTexCoord, cUVExpand + ".zxxx" ) +                   //(0, 1)
                    GA.tex ( tTempColor, tUV, 0 ) +
                    GA.muls ( tTempColor, cConstVal + ".xxxx" ) +
                    GA.adds ( tAddedColor, tTempColor ) +

                    GA.add ( tUV, inTexCoord, cUVExpand + ".xyxx" ) +                   //(1, -1)
                    GA.tex ( tTempColor, tUV, 0 ) +
                    GA.muls ( tTempColor, cConstVal + ".xxxx" ) +
                    GA.adds ( tAddedColor, tTempColor ) +

                    GA.add ( tUV, inTexCoord, cUVExpand + ".xzxx" ) +                   //(1, 0)
                    GA.tex ( tTempColor, tUV, 0 ) +
                    GA.muls ( tTempColor, cConstVal + ".xxxx" ) +
                    GA.adds ( tAddedColor, tTempColor ) +

                    GA.add ( tUV, inTexCoord, cUVExpand + ".xxxx" ) +                   //(1, 1)
                    GA.tex ( tTempColor, tUV, 0 ) +
                    GA.muls ( tTempColor, cConstVal + ".xxxx" ) +
                    GA.adds ( tAddedColor, tTempColor ) +

                    GA.tex ( tTempColor, inTexCoord, 0 ) +                  //(0, 0)
                    GA.mov ( "ft6", tTempColor ) +
                    GA.muls ( tTempColor, cConstVal + ".yyyy" ) +
                    GA.adds ( tAddedColor, tTempColor ) +

                            //GA.mul ( outColor, tAddedColor, inColor );
                    GA.slt ( "ft5.w", "ft6.w", cAlphaBias ) +
                    GA.slt ( tTempColor + ".w", cAlphaBias, tAddedColor + ".w" ) +
                    GA.mul ( tTempColor2, tTempColor + ".wwww", "ft5.wwww" ) +
                    GA.mul ( outColor, tTempColor2, inColor );
        }
    }
}
