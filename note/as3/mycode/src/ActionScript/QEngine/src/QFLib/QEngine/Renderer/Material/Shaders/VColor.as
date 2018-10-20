/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Material.Shaders
{
    import QFLib.QEngine.Renderer.Material.IVertexShader;

    public final class VColor extends VBase implements IVertexShader
    {
        public static const Name : String = "color";

        static private const cMatrixMVP : String = "vc0";

        public function VColor()
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
                    GA.mov( outColor, inColor );
        }
    }
}