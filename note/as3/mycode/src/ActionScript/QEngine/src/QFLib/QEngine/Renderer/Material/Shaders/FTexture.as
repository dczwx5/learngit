/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Material.Shaders
{
    import QFLib.QEngine.Renderer.Material.IFragmentShader;

    public final class FTexture extends FBase implements IFragmentShader
    {
        public static const Name : String = "texture";

        public function FTexture()
        {
            registerTex( 0, mainTexture );
        }

        public function get name() : String
        {
            return Name;
        }

        public function get code() : String
        {
            return GA.tex( outColor, inTexCoord, 0 );
        }

    }
}