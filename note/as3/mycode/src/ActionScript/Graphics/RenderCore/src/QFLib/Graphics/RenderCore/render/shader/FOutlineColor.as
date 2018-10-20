////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

package QFLib.Graphics.RenderCore.render.shader
{
    import QFLib.Graphics.RenderCore.render.IFragmentShader;

    public class FOutlineColor extends FBase implements IFragmentShader
    {
        public static const Name : String = "f.outline.color";

        private static const cSobelWeight : String = "fc0";
        private static const cUVExpand : String = "fc1";
        private static const cOutlineColor : String = "fc2";

        private static const tUV : String = "ft0";
        private static const tAddedColorX : String = "ft1";
        private static const tAddedColorY : String = "ft2";
        private static const tTempColorX : String = "ft3";
        private static const tTempColorY : String = "ft4";

        public function FOutlineColor ()
        {
            super ();

            registerTex ( 0, mainTexture );
            registerParam ( 0, "sobelWeight" );
            registerParam ( 1, "uvExpand" );
            registerParam ( 2, "outlineColor" );
        }

        public function get name () : String
        {
            return Name;
        }

        public function get code () : String
        {
            return GA.sub ( tUV, inTexCoord, cUVExpand + ".xyxx" ) +            //x-pos, y-pos: (-1,-1)
                    GA.tex ( tAddedColorX, tUV, 0 ) +
                    GA.muls ( tAddedColorX, cSobelWeight + ".yyyy" ) +           //x-color
                    GA.mov ( tAddedColorY, tAddedColorX ) +                      //y-color

                    GA.sub ( tUV, inTexCoord, cUVExpand + ".xwxx" ) +            //x-pos: (-1, 0)
                    GA.tex ( tTempColorX, tUV, 0 ) +
                    GA.muls ( tTempColorX, cSobelWeight + ".wwww" ) +
                    GA.adds ( tAddedColorX, tTempColorX ) +                       //x-color

                    GA.sub ( tUV, inTexCoord, cUVExpand + ".wyxx" ) +             //y-pos: ( 0, -1)
                    GA.tex ( tTempColorY, tUV, 0 ) +
                    GA.muls ( tTempColorY, cSobelWeight + ".wwww" ) +
                    GA.adds ( tAddedColorY, tTempColorY ) +                      //y-color

                    GA.mov ( tUV, cUVExpand ) +
                    GA.mul ( tUV + ".x", tUV + ".x", tUV + ".z" ) +
                    GA.add ( tUV, inTexCoord, tUV + ".xyxx" ) +           //x-pos, y-pos: (-1, 1)
                    GA.tex ( tTempColorX, tUV, 0 ) +
                    GA.mov ( tTempColorY, tTempColorX ) +
                    GA.muls ( tTempColorX, cSobelWeight + ".yyyy" ) +
                    GA.muls ( tTempColorY, cSobelWeight + ".xxxx" ) +
                    GA.adds ( tAddedColorX, tTempColorX ) +                      //x-color
                    GA.adds ( tAddedColorY, tTempColorY ) +                      //y-color

                    GA.mov ( tUV, cUVExpand ) +
                    GA.mul ( tUV + ".y", tUV + ".y", tUV + ".z" ) +
                    GA.add ( tUV, inTexCoord, cUVExpand + ".xyxx" ) +            //x-pos, y-pos: (1, -1)
                    GA.tex ( tTempColorX, tUV, 0 ) +
                    GA.mov ( tTempColorY, tTempColorX ) +
                    GA.muls ( tTempColorX, cSobelWeight + ".xxxx" ) +
                    GA.muls ( tTempColorY, cSobelWeight + ".yyyy" ) +
                    GA.adds ( tAddedColorX, tTempColorX ) +                      //x-color
                    GA.adds ( tAddedColorY, tTempColorY ) +                      //y-color

                    GA.add ( tUV, inTexCoord, cUVExpand + ".xwxx" ) +           //x-pos: (1, 0)
                    GA.tex ( tTempColorX, tUV, 0 ) +
                    GA.muls ( tTempColorX, cSobelWeight + ".zzzz" ) +
                    GA.adds ( tAddedColorX, tTempColorX ) +

                    GA.add ( tUV, inTexCoord, cUVExpand + ".wyxx" ) +            //y-pos: (0, 1)
                    GA.tex ( tTempColorY, tUV, 0 ) +
                    GA.muls ( tTempColorY, cSobelWeight + ".zzzz" ) +
                    GA.adds ( tAddedColorY, tTempColorY ) +                      //y-color

                    GA.add ( tUV, inTexCoord, cUVExpand + ".xyxx" ) +           //x-pos, y-pos: (1, 1)
                    GA.tex ( tTempColorX, tUV, 0 ) +
                    GA.muls ( tTempColorX, cSobelWeight + ".xxxx" ) +
                    GA.adds ( tAddedColorX, tTempColorX ) +                      //x-color
                    GA.adds ( tAddedColorY, tTempColorX ) +                      //y-color

                    GA.abs ( tAddedColorX, tAddedColorX ) +
                    GA.abs ( tAddedColorY, tAddedColorY ) +

                    GA.add ( tTempColorX, tAddedColorX, tAddedColorY ) +
                    GA.mul ( outColor, tTempColorX + ".wwww", cOutlineColor );
        }
    }
}
