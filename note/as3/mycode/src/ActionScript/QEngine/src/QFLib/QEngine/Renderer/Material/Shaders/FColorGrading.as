/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Material.Shaders
{
    import QFLib.QEngine.Renderer.Material.IFragmentShader;

    public class FColorGrading extends FBase implements IFragmentShader
    {
        public static const Name : String = "compositor.colorGrading";

        private static const grid : String = "fc0";

        private static const blue : String = "ft0.b";
        private static const row : String = "ft1.x";
        private static const col : String = "ft1.y";
        private static const tmpBlue : String = "ft0.z";

        public function FColorGrading()
        {
            registerTex( 0, mainTexture );
            registerTex( 1, "colorGrading" );

            registerParam( 0, "grid" );
        }

        public function get name() : String
        {
            return Name;
        }

        public function get code() : String
        {
            var fragmentProgramCode : String =
                    GA.tex( "ft0", inTexCoord, 0 ) +
                    GA.mul( tmpBlue, blue, grid + ".z" ) +
                    GA.frc( "ft1.w", tmpBlue ) +
                    GA.subs( tmpBlue, "ft1.w" ) +
                    GA.grid( row, col, tmpBlue, grid + ".y" ) +
                    GA.adds( "ft1.xy", "ft0.rg" ) +
                    GA.muls( "ft1.xy", grid + ".xx" ) +
                    GA.tex( outColor, "ft1.yx", 1 );

            return fragmentProgramCode;
        }
    }
}
