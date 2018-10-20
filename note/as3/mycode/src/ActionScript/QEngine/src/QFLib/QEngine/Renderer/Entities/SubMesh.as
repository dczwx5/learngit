/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2017/3/17.
 */
package QFLib.QEngine.Renderer.Entities
{
    import QFLib.Interface.IDisposable;
    import QFLib.Math.CVector3;
    import QFLib.QEngine.Renderer.Device.RenderDevice;
    import QFLib.QEngine.Renderer.Device.RenderDeviceManager;
    import QFLib.QEngine.Renderer.IRenderCommand;
    import QFLib.QEngine.Renderer.Material.IMaterial;
    import QFLib.QEngine.Core.Engine_Internal;
    import QFLib.QEngine.Renderer.Textures.Texture;
    import QFLib.QEngine.Renderer.Utils.VertexData;

    import flash.display3D.Context3DBufferUsage;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.VertexBuffer3D;

    public class SubMesh implements IDisposable
    {
        public function SubMesh( vertNum : int = 0, pma : Boolean = false, triangles : Vector.<uint> = null, pSharedVertices : VertexData = null,
                                 offset : int = -1, triangleCount : int = -1, useSharedVertices : Boolean = false )
        {
            m_bUseSharedVertices = useSharedVertices;
            if( vertNum <= 2 ) m_iDrawTriangleCount = 0;
            else m_iDrawTriangleCount = triangleCount <= 0 ? vertNum - 2 : triangleCount;
            if( !m_bUseSharedVertices )
            {
                m_pSharedVertices = m_Vertices = new VertexData( vertNum, pma, true );
            }
            else
            {
                m_pSharedVertices = pSharedVertices;
                m_iSharedVerticesOffset = offset;
            }

            m_Indices = new Vector.<uint>( 3 * m_iDrawTriangleCount );
            if( triangles != null )
            {
                var i : int = 0, length : int = triangles.length;
                while( i < length )
                {
                    m_Indices[ i ] = triangles[ i ];
                    ++i;
                }
            }

            m_bVerticesDirty = true;
            m_bIndicesDirty = true;
        }
        private var m_Vertices : VertexData = null;
        private var m_Indices : Vector.<uint> = null;
        private var m_Material : IMaterial = null;
        private var m_pVertexBuffer : VertexBuffer3D = null;
        private var m_pIndexBuffer : IndexBuffer3D = null;
        private var m_pSharedVertices : VertexData = null;
        private var m_pSharedMaterial : IMaterial = null;
        private var m_iSharedVerticesOffset : int = -1;
        private var m_iDrawTriangleCount : int = 0;
        private var m_iDrawTriangleOffset : int = 0;
        private var m_bUseSharedVertices : Boolean = false;
        private var m_bVerticesDirty : Boolean = true;
        private var m_bIndicesDirty : Boolean = true;

        public function dispose() : void
        {
            /*** destroy vertices/indices ***/
            if( m_Vertices != null )
            {
                m_Vertices.dispose();
                m_Vertices = null;
            }
            if( m_Indices != null )
            {
                m_Indices.length = 0;
                m_Indices = null;
            }
            m_pSharedVertices = null;

            /*** destroy vertex/index buffer ***/

            /*** destroy material ***/
            if( m_Material != null )
            {
                m_Material.dispose();
                m_Material = null;
            }
            m_pSharedMaterial = null;

            destroyVideoBuffer();
        }

        private function updateVertexBuffer() : void
        {
            if( m_pVertexBuffer == null )
                throw new Error( "vertex buffer is null pointer!" );

            var pCurRenderDevice : RenderDevice = RenderDeviceManager.getInstance().current;
            pCurRenderDevice.uploadVertexBufferData( m_pVertexBuffer, m_pSharedVertices.rawData, 0, m_pSharedVertices.numVertices );
        }

        private function updateIndexBuffer() : void
        {
            if( m_pIndexBuffer == null )
                throw new Error( "index buffer is null pointer" );

            var pCurRenderDevice : RenderDevice = RenderDeviceManager.getInstance().current;
            pCurRenderDevice.uploadIndexBufferData( m_pIndexBuffer, m_Indices, 0, m_Indices.length )
        }

        private function destroyVideoBuffer() : void
        {
            var pCurRenderDevice : RenderDevice = RenderDeviceManager.getInstance().current;
            if( m_pVertexBuffer != null )
            {
                pCurRenderDevice.destroyVertexBuffer( m_pVertexBuffer );
                m_pVertexBuffer = null;
            }

            if( m_pIndexBuffer != null )
            {
                pCurRenderDevice.destroyIndexBuffer( m_pIndexBuffer );
                m_pIndexBuffer = null;
            }
        }

        [Inline]
        final Engine_Internal function get _useSharedVertices() : Boolean
        { return m_bUseSharedVertices; }

        [Inline]
        final Engine_Internal function get _triangleCount() : int
        { return m_iDrawTriangleCount; }

        [Inline]
        final Engine_Internal function get _vertices() : VertexData
        { return m_pSharedVertices; }

        [Inline]
        final Engine_Internal function get _indices() : Vector.<uint>
        { return m_Indices; }

        [Inline]
        final Engine_Internal function set _drawTriangleOffset( value : int ) : void
        { m_iDrawTriangleOffset = value; }

        [Inline]
        final Engine_Internal function _setVerticesDirty() : void
        { m_bVerticesDirty = true; }

        [Inline]
        final Engine_Internal function _setIndicesDirty() : void
        { m_bVerticesDirty = true; }

        [Inline]
        final Engine_Internal function get _sharedMaterial() : IMaterial
        { return m_pSharedMaterial; }

        [Inline]
        final Engine_Internal function set _sharedMaterial( value : IMaterial ) : void
        { m_pSharedMaterial = value; }

        [Inline]
        final Engine_Internal function get _material() : IMaterial
        {
            if( m_pSharedMaterial != m_Material )
            {
                if( m_Material != null )
                {
                    m_Material.dispose();
                    m_Material = null
                }
                if( m_pSharedMaterial != null ) m_Material = m_pSharedMaterial.clone();
                m_pSharedMaterial = m_Material;
            }

            return m_Material;
        }

        [Inline]
        final Engine_Internal function set _material( value : IMaterial ) : void
        {
            if( value != null )
            {
                if( m_Material != null )
                {
                    m_Material.dispose();
                    m_Material = null;
                }
                m_pSharedMaterial = m_Material = value.clone();
            }
        }

        Engine_Internal function _setSharedVertices( vertNum : int, pSharedVertices : VertexData, triangles : Vector.<uint>, offset : int, triangleCount : int = -1 ) : void
        {
            if( m_Vertices != null )
            {
                m_Vertices.dispose();
                m_Vertices = null;
            }

            Engine_Internal::_setIndices( triangles );

            if( vertNum <= 2 ) m_iDrawTriangleCount = 0;
            else m_iDrawTriangleCount = triangleCount <= 0 ? vertNum - 2 : triangleCount;
            m_iSharedVerticesOffset = offset;
            m_pSharedVertices = pSharedVertices;
            m_bVerticesDirty = true;
            m_bUseSharedVertices = true;
        }

        Engine_Internal function _setSharedUVs( uvs : Vector.<Number> ) : void
        {
            var uvIndex : int = 0;
            for( var i : int = 0, numVertices : int = m_pSharedVertices.numVertices; i < numVertices; i++ )
            {
                uvIndex = 2 * i;
                m_pSharedVertices.setTexCoords( m_iSharedVerticesOffset + i, uvs[ uvIndex ], uvs[ uvIndex + 1 ] );
            }
            m_bVerticesDirty = true;
        }

        Engine_Internal function _setSubMeshFromVertexData( vertexData : VertexData, triangles : Vector.<uint>, useSharedVertices : Boolean = true, firstIndex : int = -1 ) : void
        {
            if( useSharedVertices )
            {
                if( m_Vertices != null )
                {
                    m_Vertices.dispose();
                    m_Vertices = null;
                }
                m_pSharedVertices = vertexData;
                m_iSharedVerticesOffset = firstIndex;
            }
            else
            {
                var numVertices : int = vertexData.numVertices;
                if( m_Vertices == null ) m_Vertices = new VertexData( numVertices, vertexData.premultipliedAlpha, true );
                vertexData.copyTo( m_Vertices, 0, 0, numVertices );
                m_pSharedVertices = m_Vertices;
            }
            m_bVerticesDirty = true;
            m_bUseSharedVertices = useSharedVertices;

            Engine_Internal::_setIndices( triangles );
        }

        Engine_Internal function _setSubMeshFromRawData2D( vertices : Vector.<Number>, uvs : Vector.<Number>, triangles : Vector.<uint>, pma : Boolean = false ) : void
        {
            Engine_Internal::_setVertices2D( vertices, uvs, pma );
            Engine_Internal::_setIndices( triangles );
        }

        Engine_Internal function _setSubMeshFromRawData( vertices : Vector.<Number>, uvs : Vector.<Number>, triangles : Vector.<uint>, triangleCount : int = -1, pma : Boolean = false ) : void
        {
            Engine_Internal::_setVertices( vertices, uvs, triangleCount, pma );
            Engine_Internal::_setIndices( triangles );
        }

        Engine_Internal function _setVertices2D( vertices : Vector.<Number>, uvs : Vector.<Number>, pma : Boolean = false, triangleCount : int = -1 ) : void
        {
            var numVertices : int = vertices.length >> 1;
            if( m_Vertices == null || m_Vertices.numVertices != numVertices )
            {
                if( m_Vertices != null ) m_Vertices.numVertices = numVertices;
                else m_Vertices = new VertexData( numVertices, pma );
            }

            var index : int = 0;
            for( var i : int = 0; i < numVertices; ++i )
            {
                index = 2 * i;
                m_Vertices.setPosition( i, vertices[ index ], vertices[ index + 1 ], 0.0 );
                m_Vertices.setTexCoords( i, uvs[ index ], uvs[ index + 1 ] );
            }

            m_iDrawTriangleCount = triangleCount <= 0 ? m_Vertices.numVertices - 2 : triangleCount;
            m_pSharedVertices = m_Vertices;
            m_bVerticesDirty = true;
            m_bUseSharedVertices = false;
        }

        Engine_Internal function _setVertices( vertices : Vector.<Number>, uvs : Vector.<Number>, triangleCount : int = -1, pma : Boolean = false ) : void
        {
            var numVertices : int = vertices.length / 3;
            if( m_Vertices == null || m_Vertices.numVertices != numVertices )
            {
                if( m_Vertices != null ) m_Vertices.numVertices = numVertices;
                else m_Vertices = new VertexData( numVertices, pma );
            }

            var vertIndex : int = 0;
            var uvIndex : int = 0;
            for( var i : int = 0; i < numVertices; ++i )
            {
                vertIndex = 3 * i;
                uvIndex = 2 * i;
                m_Vertices.setPosition( i, vertices[ vertIndex ], vertices[ vertIndex + 1 ], 0.0 );
                m_Vertices.setTexCoords( i, uvs[ uvIndex ], uvs[ uvIndex + 1 ] );
            }

            m_iDrawTriangleCount = triangleCount <= 0 ? m_Vertices.numVertices - 2 : triangleCount;
            m_pSharedVertices = m_Vertices;
            m_bVerticesDirty = true;
            m_bUseSharedVertices = false;
        }

        Engine_Internal function _setIndices( triangles : Vector.<uint> ) : void
        {
            if( triangles == null ) return;
            if( m_Indices == null )
            {
                m_Indices = triangles.concat();
            }
            else
            {
                var length : int = m_Indices.length = triangles.length;
                var k : int = 0;
                while( k < length )
                {
                    m_Indices[ k ] = triangles[ k ];
                    ++k;
                }
            }

            m_bIndicesDirty = true;
        }

        Engine_Internal function _setUVs( uvs : Vector.<Number> ) : void
        {
            var uvIndex : int = 0;
            for( var i : int = 0, numVertices : int = m_Vertices.numVertices; i < numVertices; ++i )
            {
                uvIndex = 2 * i;
                m_Vertices.setTexCoords( i, uvs[ uvIndex ], uvs[ uvIndex + 1 ] );
            }
            m_bVerticesDirty = true;
        }

        Engine_Internal function _setColor( color : uint, pma : Boolean = false ) : void
        {
            m_Vertices.setPremultipliedAlpha( pma, false );
            m_Vertices.setColor( color );
            m_bVerticesDirty = true;
        }

        Engine_Internal function _setColorsPerVertex( colors : Vector.<uint>, pma : Boolean = false ) : void
        {
            m_Vertices.setPremultipliedAlpha( pma, false );
            var numVertices : int = m_Vertices.numVertices;
            var i : int = 0;
            while( i < numVertices )
            {
                m_Vertices.setVertexColor( i, colors[ i ] );
                ++i;
            }
            m_bVerticesDirty = true;
        }

        Engine_Internal function _setAlpha( alpha : Number ) : void
        {
            m_Vertices.setAlpha( alpha );
            m_bVerticesDirty = true;
        }

        Engine_Internal function _setAlphaPerVertex( alphas : Vector.<Number> ) : void
        {
            var numVertices : int = m_Vertices.numVertices;
            var i : int = 0;
            while( i < numVertices )
            {
                m_Vertices.setVertexAlpha( i, alphas[ i ] );
                ++i;
            }
            m_bVerticesDirty = true;
        }

        Engine_Internal function _setPremultiplyAlpha( pma : Boolean ) : void
        {
            if( pma == m_Vertices.premultipliedAlpha ) return;
            m_Vertices.setPremultipliedAlpha( pma, true );
            m_bVerticesDirty = true;
        }

        Engine_Internal function _setNormals( normals : Vector.<CVector3> ) : void
        {}

        Engine_Internal function _setTangents( tangents : Vector.<CVector3> ) : void
        {}

        [Inline]
        final Engine_Internal function _setTexture( texture : Texture ) : void
        { m_pSharedMaterial.texture = texture; }

        Engine_Internal function get _vertexBuffer() : VertexBuffer3D
        {
            var pCurRenderDevice : RenderDevice = RenderDeviceManager.getInstance().current;
            if( m_pVertexBuffer == null )
            {
                m_pVertexBuffer = pCurRenderDevice.createVertexBuffer( m_pSharedVertices.numVertices, VertexData.ELEMENTS_PER_VERTEX, Context3DBufferUsage.STATIC_DRAW );
            }

            if( m_bVerticesDirty )
            {
                updateVertexBuffer();
                m_bVerticesDirty = false;
            }

            return m_pVertexBuffer;
        }

        Engine_Internal function get _indexBuffer() : IndexBuffer3D
        {
            var pCurRenderDevice : RenderDevice = RenderDeviceManager.getInstance().current;
            if( m_pIndexBuffer == null )
            {
                m_pIndexBuffer = pCurRenderDevice.createIndexBuffer( m_Indices.length, Context3DBufferUsage.STATIC_DRAW );
            }

            if( m_bIndicesDirty )
            {
                updateIndexBuffer();
                m_bIndicesDirty = false;
            }

            return m_pIndexBuffer;
        }

        Engine_Internal function _getRenderCommand( cmd : IRenderCommand ) : void
        {
            cmd.indexBuffer = Engine_Internal::_indexBuffer;
            cmd.vertexBuffer = Engine_Internal::_vertexBuffer;
            cmd.indices = m_Indices;
            cmd.vertices = m_pSharedVertices;
            cmd.material = m_pSharedMaterial;
            cmd.numTriangles = m_iDrawTriangleCount;
            cmd.indicesOffset = m_iDrawTriangleOffset;
        }
    }
}