/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2017/3/8.
 */
package QFLib.QEngine.Renderer.Entities
{
    import QFLib.Interface.IDisposable;
    import QFLib.QEngine.Renderer.Material.IMaterial;
    import QFLib.QEngine.Core.Engine_Internal;
    import QFLib.QEngine.Renderer.Utils.VertexData;

    public class Mesh implements IDisposable
    {
        public function Mesh( pOwner : Entity )
        {
            m_vecSubMesh = new Vector.<SubMesh>();
            m_pOwner = pOwner;
        }
        private var m_vecSubMesh : Vector.<SubMesh> = null;
        private var m_pOwner : Entity = null;
        private var m_iNumVertices : int = 0;

        [Inline]
        final public function get owner() : Entity
        { return m_pOwner; }

        public function get numVertices() : int
        {
            m_iNumVertices = 0;
            var len : int = m_vecSubMesh.length, i : int = 0;
            while( i < len )
            {
                if( m_vecSubMesh[ i ] != null && !m_vecSubMesh[ i ].Engine_Internal::_useSharedVertices )
                    m_iNumVertices += m_vecSubMesh[ i ].Engine_Internal::_vertices.numVertices;
                ++i;
            }

            return m_iNumVertices;
        }

        public function dispose() : void
        {
            m_pOwner = null;
            clearSubMesh();
        }

        public function createSubMesh( vertNum : int = 0, pma : Boolean = false, triangles : Vector.<uint> = null,
                                       firstVertex : int = -1, pSharedVertices : VertexData = null, triangleCount : int = -1, useSharedVertices : Boolean = false ) : SubMesh
        {
            var subMesh : SubMesh = new SubMesh( vertNum, pma, triangles, pSharedVertices, firstVertex, triangleCount, useSharedVertices );

            m_vecSubMesh.fixed = false;
            var length : int = m_vecSubMesh.length;
            m_vecSubMesh.length += 1;
            m_vecSubMesh[ length ] = subMesh;
            m_vecSubMesh.fixed = true;
            return subMesh;
        }

        public function clearSubMesh() : void
        {
            var len : int = m_vecSubMesh.length;
            for( var i : int = 0; i < len; i++ )
            {
                m_vecSubMesh[ i ].dispose();
            }

            m_vecSubMesh.fixed = false;
            m_vecSubMesh.length = 0;
            m_vecSubMesh = null;
        }

        public function setColorWithAlpha( color : uint, alpha : Number, pma : Boolean = false ) : void
        {
            var len : int = m_vecSubMesh.length, i : int = 0;
            while( i < len )
            {
                if( !m_vecSubMesh[ i ].Engine_Internal::_useSharedVertices )
                {
                    m_vecSubMesh[ i ].Engine_Internal::_setColor( color );
                    m_vecSubMesh[ i ].Engine_Internal::_setAlpha( alpha );
                }
                ++i;
            }
        }

        public function setPremultilyAlpha( value : Boolean ) : void
        {
            var len : int = m_vecSubMesh.length, i : int = 0;
            while( i < len )
            {
                if( !m_vecSubMesh[ i ].Engine_Internal::_useSharedVertices )
                    m_vecSubMesh[ i ].Engine_Internal::_setPremultiplyAlpha( value );
                ++i;
            }
        }

        public function setSubMesh( iSubMesh : int, vertices : Vector.<Number>, uvs : Vector.<Number>, triangles : Vector.<uint>, triangleCount : int = -1,
                                    pma : Boolean = false, offset : int = -1, pSharedVertices : VertexData = null, useSharedVertices : Boolean = false ) : void
        {
            var vertNum : int = vertices.length / 3;
            if( useSharedVertices )
                m_vecSubMesh[ iSubMesh ].Engine_Internal::_setSharedVertices( vertNum, pSharedVertices, triangles, offset, triangleCount );
            else
                m_vecSubMesh[ iSubMesh ].Engine_Internal::_setVertices( vertices, uvs, triangleCount, pma );

            m_vecSubMesh[ iSubMesh ].Engine_Internal::_setIndices( triangles );
        }

        public function setSubMeshVertices( iSubMesh : int, vertices : Vector.<Number>, uvs : Vector.<Number>, triangleCount : int = -1, pma : Boolean = false ) : void
        {
            m_vecSubMesh[ iSubMesh ].Engine_Internal::_setVertices( vertices, uvs, triangleCount, pma );
        }

        public function setSubMeshTriangles( iSubMesh : int, triangles : Vector.<uint> ) : void
        {
            m_vecSubMesh[ iSubMesh ].Engine_Internal::_setIndices( triangles );
        }

        public function setSubMeshTexcoods( iSubMesh : int, uvs : Vector.<Number> ) : void
        {
            m_vecSubMesh[ iSubMesh ].Engine_Internal::_setUVs( uvs );
        }

        public function setSubMeshColor( iSubMesh : int, color : uint, pma : Boolean ) : void
        {
            m_vecSubMesh[ iSubMesh ].Engine_Internal::_setColor( color, pma );
        }

        public function setSubMeshColors( iSubMesh : int, colors : Vector.<uint>, pma : Boolean ) : void
        {
            m_vecSubMesh[ iSubMesh ].Engine_Internal::_setColorsPerVertex( colors, pma );
        }

        public function setSubMeshAlpha( iSubMesh : int, alpha : Number ) : void
        {
            m_vecSubMesh[ iSubMesh ].Engine_Internal::_setAlpha( alpha );
        }

        public function setSubMeshAlphas( iSubMesh : int, alphas : Vector.<Number> ) : void
        {
            m_vecSubMesh[ iSubMesh ].Engine_Internal::_setAlphaPerVertex( alphas );
        }

        public function setSubMeshMaterial( iSubMesh : int, material : IMaterial, useSharedMaterial : Boolean ) : void
        {
            if( useSharedMaterial )
                m_vecSubMesh[ iSubMesh ].Engine_Internal::_sharedMaterial = material;
            else
                m_vecSubMesh[ iSubMesh ].Engine_Internal::_material = material;
        }
    }
}