/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2017/3/8.
 */
package QFLib.QEngine.Renderer.Entities
{
    import QFLib.QEngine.Core.SceneNode;
    import QFLib.QEngine.Renderer.Material.IMaterial;
    import QFLib.QEngine.Renderer.Material.Materials.MSprite;
    import QFLib.QEngine.Renderer.Textures.Texture;
    import QFLib.QEngine.Renderer.Utils.Color;

    public class Image extends Quad
    {
        public function Image( parentNode : SceneNode, width : Number = 1.0, height : Number = 1.0, pTexture : Texture = null )
        {
            super( parentNode, Color.WHITE, 1.0, width, height, false );
            this.texture = pTexture;
        }
        private var m_Material : IMaterial = null;
        private var m_pTexture : Texture = null;

        [Inline]
        final public function get texture() : Texture
        { return m_pTexture; }

        [Inline]
        final public function set texture( value : Texture ) : void
        {
            m_pTexture = value;
            m_Vertices.setTexCoords( 0, 0.0, 1.0 );
            m_Vertices.setTexCoords( 1, 1.0, 1.0 );
            m_Vertices.setTexCoords( 2, 1.0, 0.0 );
            m_Vertices.setTexCoords( 3, 0.0, 0.0 );
            m_Material.texture = texture;
            if( texture != null ) premultiplyAlpha = texture.premultipliedAlpha;
        }

        override public function dispose() : void
        {
            m_pTexture = null;
            super.dispose();
        }

        override protected function initializeEntity() : void
        {
            super.initializeEntity();
            m_Material = new MSprite();
            setSubEntityMaterial( 0, m_Material );
        }

        override protected function destroyEntity() : void
        {
            m_pTexture = null;
            if( m_Material != null )
            {
                m_Material.dispose();
                m_Material = null;
            }
            super.destroyEntity();
        }
    }
}
