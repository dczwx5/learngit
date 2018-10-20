/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2016/11/30.
 */
package QFLib.QEngine.Renderer.Material.Shaders
{
    import QFLib.QEngine.Renderer.Material.IVertexShader;

    public final class VGaussianBlur extends VBase implements IVertexShader
    {
        public static const Name : String = "v.compositor.gaussian.blur";

        private static const cUVExpand : String = "vc1";
        private static const cOffsets : String = "vc2.yz";

        private static const tTempExpand : String = "vt0";
        private static const tTempHelper : String = "vt1";

        public function VGaussianBlur()
        {
            registerParam( 1, "uvExpand" );
            registerParam( 2, "centerWeightAndOffsets" );
        }

        public function get name() : String
        {
            return Name;
        }

        public function get code() : String
        {
            var vs : String =
                    GA.mov( GA.outPos, inPosition ) +
                    GA.mov( vUV0, inTexCoord ) +							        // pos:  0 |
                    GA.mov( tTempExpand, cUVExpand ) +

                    GA.mul( tTempHelper + ".xy", cOffsets, tTempExpand + ".xx" ) +
                    GA.sub( vUV1, inTexCoord, tTempHelper + ".xyxx" ) +             //pos: -1
//                    GA.add ( vUV1 + ".zw", inTexCoord, tTempHelper + ".xy") +
                    GA.add( vUV5, inTexCoord, tTempHelper + ".xyxx" ) +             //pos: +1

                    GA.mul( tTempHelper + ".xy", cOffsets, tTempExpand + ".yy" ) +
                    GA.sub( vUV2, inTexCoord, tTempHelper + ".xyxx" ) +       //pos: -2
//                    GA.add ( vUV2 + ".zw", inTexCoord, tTempHelper + ".xy") +
                    GA.add( vUV6, inTexCoord, tTempHelper + ".xyxx" ) +             //pos: +2

                    GA.mul( tTempHelper + ".xy", tTempExpand + ".zz", cOffsets ) +
                    GA.sub( vUV3, inTexCoord, tTempHelper + ".xyxx" ) +   //pos: -3
//                    GA.add ( vUV3 + ".zw", inTexCoord + ".xy", tTempHelper + ".xy") +
                    GA.add( vUV7, inTexCoord, tTempHelper + ".xyxx" );                 //pos: +3

//                    GA.mul ( tTempHelper + ".xy", tTempExpand + ".ww", cOffsets ) +
//                    GA.sub ( vUV4, inTexCoord, tTempHelper + ".xyxx") ;
//                    GA.add ( vUV4 + ".zw", inTexCoord + ".xy", tTempHelper + ".xy");
            return vs;
        }
    }
}
