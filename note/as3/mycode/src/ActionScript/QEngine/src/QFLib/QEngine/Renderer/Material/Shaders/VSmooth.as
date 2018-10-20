/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2016/12/12.
 */
package QFLib.QEngine.Renderer.Material.Shaders
{
    import QFLib.QEngine.Renderer.Material.IVertexShader;

    public class VSmooth extends VBase implements IVertexShader
    {
        public static const Name : String = "v.smooth";

        private static const cUVOffsets : String = "vc0";

        public function VSmooth()
        {
            registerParam( 0, "uvOffsets" );
        }

        public function get name() : String
        {
            return Name;
        }

        public function get code() : String
        {
            var s : String =
                    GA.mov( GA.outPos, inPosition ) +
                    GA.mov( vUV0, inTexCoord ) +

                    GA.sub( vUV1, inTexCoord, cUVOffsets + ".xyxx" ) +
                    GA.add( vUV2, inTexCoord, cUVOffsets + ".xyxx" ) +

                    GA.sub( vUV3, inTexCoord, cUVOffsets + ".yzxx" ) +
                    GA.add( vUV4, inTexCoord, cUVOffsets + ".yzxx" );

            return s;
        }
    }
}
