/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Material.Shaders
{
    import QFLib.QEngine.Renderer.Material.IVertexShader;

    public class VFilterBlur extends VBase implements IVertexShader
    {
        public static const Name : String = "filter.blur";

        static private const cMatrixMVP : String = "vc0";
        static public const cUVExpand : String = "vc1";

        public function VFilterBlur()
        {
            registerParam( 0, matrixMVP, true );
            registerParam( 1, "uvExpand" );
        }

        public function get name() : String
        {
            return Name;
        }

        public function get code() : String
        {
            var vs : String =
                    GA.m44( GA.outPos, inPosition, cMatrixMVP ) +	// 4x4 matrix transform to output space
                    GA.mov( vUV0, inTexCoord ) +							// pos:  0 |
                    GA.sub( vUV1, inTexCoord, cUVExpand + ".zwxx" ) +	// pos: -2 |
                    GA.sub( vUV2, inTexCoord, cUVExpand + ".xyxx" ) +	// pos: -1 | --> kernel positions
                    GA.add( vUV3, inTexCoord, cUVExpand + ".xyxx" ) +	// pos: +1 |     (only 1st two parts are relevant)
                    GA.add( vUV4, inTexCoord, cUVExpand + ".zwxx" );	// pos: +2 |
            return vs;
        }
    }
}