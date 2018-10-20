//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package QFLib.Graphics.RenderCore.render.shader
{
    import QFLib.Graphics.RenderCore.render.IVertexShader;

    public class VRimLight extends VBase implements IVertexShader
    {
        public static const Name : String = "v.rimlight";

        private static const cMatrixMVP : String = "vc0";

        public function VRimLight ()
        {
            registerParam ( 0, matrixMVP, true );
        }

        public function get name () : String
        {
            return Name;
        }

        public function get code () : String
        {
            return GA.m44(outPos, inPosition, cMatrixMVP) +
                    GA.mov(outColor, inColor) +
                    GA.mov(outTexCoord,	inTexCoord);
        }
    }
}
