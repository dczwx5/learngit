/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2017/1/9.
 */
package QFLib.QEngine.Renderer.Textures
{
    import QFLib.QEngine.Renderer.*;

    public class RenderTexture extends RenderTarget
    {
        public function RenderTexture( x : int, y : int, width : int, height : int )
        {
            super();
        }
        private var m_Texture : Texture = null;

        [inline]
        public function get texture() : Texture
        { return m_Texture; }

        override public function dispose() : void
        {
            m_Texture.dispose();
            m_Texture = null;

            super.dispose();
        }

        public function updateTexture() : void
        {

        }
    }
}
