/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2017/3/22.
 */
package QFLib.QEngine.Renderer.Entities.SpineExtension
{
    import QFLib.Interface.IDisposable;
    import QFLib.QEngine.Renderer.Textures.Texture;
    import QFLib.QEngine.Renderer.Utils.VertexData;

    public class RendererObject implements IDisposable
    {
        public function RendererObject( vertNum : int = 0, uvs : Vector.<Number> = null, triangles : Vector.<uint> = null, texture : Texture = null )
        {
            this.numVertices = vertNum;
            this.uvs = uvs;
            this.indices = triangles;
            m_pTexture = texture;
        }
        private var m_Vertices : VertexData = null;
        private var m_UVs : Vector.<Number> = null;
        private var m_Triangles : Vector.<uint> = null;
        private var m_pTexture : Texture = null;

        [Inline]
        final public function get vertices() : VertexData
        { return m_Vertices; }

        [Inline]
        final public function get uvs() : Vector.<Number>
        { return m_UVs; }

        public function set uvs( uvs : Vector.<Number> ) : void
        {
            if( uvs == null ) return;
            for( var i : int = 0, num : int = m_UVs.length; i < num; i++ )
            {
                m_UVs[ i ] = uvs[ i ];
            }
        }

        [Inline]
        final public function get indices() : Vector.<uint>
        { return m_Triangles; }

        public function set indices( triangles : Vector.<uint> ) : void
        {
            if( triangles == null ) return;
            for( var i : int = 0, num : int = m_Triangles.length; i < num; i++ )
            {
                m_Triangles[ i ] = triangles[ i ];
            }
        }

        [inline]
        public function get texture() : Texture
        { return m_pTexture; }

        public function set texture( texture : Texture ) : void { m_pTexture = texture; }

        public function set numVertices( value : int ) : void
        {
            if( m_Vertices == null ) m_Vertices = new VertexData( value, false, true );
            else m_Vertices.numVertices = value;

            if( m_UVs == null ) m_UVs = new Vector.<Number>( value << 1 );
            else m_UVs.length = value << 1;

            value = value <= 2 ? 0 : ( value - 2 ) * 3;
            if( m_Triangles == null ) m_Triangles = new Vector.<uint>( value );
            else m_Triangles.length = value;
        }

        public function dispose() : void
        {
            if( m_Vertices != null )
            {
                m_Vertices.dispose();
                m_Vertices = null;
            }

            if( m_UVs != null )
            {
                m_UVs.fixed = false;
                m_UVs.length = 0;
                m_UVs = null;
            }

            if( m_Triangles != null )
            {
                m_Triangles.fixed = false;
                m_Triangles.length = 0;
                m_Triangles = null;
            }

            m_pTexture = null;
        }
    }
}
