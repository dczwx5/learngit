/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Material.Shaders
{
    import QFLib.QEngine.Renderer.Material.IVertexShader;

    public final class VColorTC extends VBase implements IVertexShader
    {
        public static const Name : String = "color.tc";

        static private const cMatrixMVP : String = "vc0";

        public function VColorTC()
        {
            registerParam( 0, matrixMVP, true );
        }

        public function get name() : String
        {
            return Name;
        }

        public function get code() : String
        {
            return GA.m44( outPos, inPosition, cMatrixMVP ) +
                    GA.mov( outColor, inColor ) +
                    GA.mov( outTexCoord, inTexCoord );
        }
    }
}