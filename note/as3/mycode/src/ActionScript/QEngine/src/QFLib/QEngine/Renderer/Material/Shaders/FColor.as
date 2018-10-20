/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Material.Shaders
{
    import QFLib.QEngine.Renderer.Material.IFragmentShader;

    public final class FColor extends FBase implements IFragmentShader
    {
        public static const Name : String = "color";

        private static const cMaskColor : String = "fc0";

        public function FColor()
        {
            registerParam( 0, "maskColor" );
        }

        public function get name() : String
        {
            return Name;
        }

        public function get code() : String
        {
            return GA.mov( "ft0", inColor ) +
                    GA.muls( "ft0.xyz", cMaskColor + ".www" ) +
                    GA.adds( "ft0.xyz", cMaskColor + ".xyz" ) +
                    GA.mov( outColor, "ft0" );
        }
    }
}