/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by xandy on 2015/9/7.
 */
package QFLib.QEngine.Renderer.Material.Shaders
{
    import QFLib.QEngine.Renderer.Material.IFragmentShader;

    public class FCompositorFake extends FBase implements IFragmentShader
    {
        public static const Name : String = "compositor.fake";
        public static const GrayFactor : String = "grayFactor";

        static private const cGrayFactor : String = "fc0";

        public function FCompositorFake()
        {
            registerTex( 0, mainTexture );
            registerParam( 0, GrayFactor );
        }

        public function get name() : String
        {
            return Name;
        }

        public function get code() : String
        {
            var fragmentProgramCode : String =
                    GA.tex( "ft0", inTexCoord, 0 ) +
                    GA.dot3s( "ft0.xyz", cGrayFactor + ".xyz" ) +
                    GA.mov( "ft0.w", cGrayFactor + ".w" ) +
                    GA.mov( outColor, "ft0" );

            return fragmentProgramCode;
        }
    }
}
