/**
 * Created by david on 2016/11/30.
 */
package QFLib.Graphics.RenderCore.render.shader
{
    import QFLib.Graphics.RenderCore.render.IVertexShader;

    public final class VGaussianBlur extends VBase implements IVertexShader
    {
        public static const Name : String = "v.gaussian.blur";

        private static const cMatrixMVP : String = "vc2";
        private static const cUVExpand : String = "vc0";
        private static const cOffsets : String = "vc1.yz";

        private static const tTempExpand : String = "vt0";
        private static const tTempHelper : String = "vt1";

        public function VGaussianBlur ()
        {
            registerParam ( 0, "uvExpand" );
            registerParam ( 1, "centerWeightAndOffsets" );
            registerParam ( 2, matrixMVP, true );
        }

        public function get name () : String
        {
            return Name;
        }

        public function get code () : String
        {
            var vs : String =
                    GA.m44 ( GA.outPos, inPosition, cMatrixMVP ) +
                    GA.mov ( vUV0, inTexCoord ) +							        // pos:  0 |
                    GA.mov ( tTempExpand, cUVExpand ) +

                    GA.mul ( tTempHelper + ".xy", cOffsets, tTempExpand + ".xx" ) +
                    GA.sub ( vUV1, inTexCoord, tTempHelper + ".xyxx") +             //pos: -1
//                    GA.add ( vUV1 + ".zw", inTexCoord, tTempHelper + ".xy") +
                    GA.add ( vUV5, inTexCoord, tTempHelper + ".xyxx") +             //pos: +1

                    GA.mul ( tTempHelper + ".xy", cOffsets, tTempExpand + ".yy" ) +
                    GA.sub ( vUV2, inTexCoord, tTempHelper + ".xyxx") +       //pos: -2
//                    GA.add ( vUV2 + ".zw", inTexCoord, tTempHelper + ".xy") +
                    GA.add ( vUV6, inTexCoord, tTempHelper + ".xyxx") +             //pos: +2

                    GA.mul ( tTempHelper + ".xy", tTempExpand + ".zz", cOffsets ) +
                    GA.sub ( vUV3, inTexCoord, tTempHelper + ".xyxx") +   //pos: -3
//                    GA.add ( vUV3 + ".zw", inTexCoord + ".xy", tTempHelper + ".xy") +
                    GA.add ( vUV7, inTexCoord, tTempHelper + ".xyxx");                 //pos: +3

//                    GA.mul ( tTempHelper + ".xy", tTempExpand + ".ww", cOffsets ) +
//                    GA.sub ( vUV4, inTexCoord, tTempHelper + ".xyxx") ;
//                    GA.add ( vUV4 + ".zw", inTexCoord + ".xy", tTempHelper + ".xy");
            return vs;
        }
    }
}
