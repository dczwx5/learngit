/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Material.Shaders
{
    import QFLib.QEngine.Renderer.Material.IVertexShader;

    public class VLightTC extends VBase implements IVertexShader
    {
        public static const Name : String = "light.tc";

        static private const cLightColor : String = "vc0";
        static private const cMatrixMVP : String = "vc1";

        public function VLightTC()
        {
            registerParam( 0, "lightColor" );
            registerParam( 1, matrixMVP, true );
        }

        public function get name() : String
        {
            return Name;
        }

        public function get code() : String
        {
            var shader : String =
                    GA.m44( outPos, inPosition, cMatrixMVP ) +
                    GA.mov( "vt0", cLightColor ) +
                    GA.muls( "vt0.rgb", inColor ) +
                    GA.mov( outColor, "vt0" ) +
                    GA.mov( outTexCoord, inTexCoord );
            return shader;
        }
    }
}