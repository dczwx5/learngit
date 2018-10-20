/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2017/1/18.
 */
package QFLib.QEngine.Renderer.RenderQueue
{
    import QFLib.Interface.IDisposable;
    import QFLib.Math.CMatrix4;
    import QFLib.QEngine.Renderer.*;
    import QFLib.QEngine.Renderer.Material.IMaterial;
    import QFLib.QEngine.Renderer.Utils.VertexData;

    import flash.display3D.IndexBuffer3D;
    import flash.display3D.VertexBuffer3D;

    public class RenderCommand implements IRenderCommand, IDisposable
    {
        function RenderCommand() {}
        private var m_pVertices : VertexData = null;
        private var m_pIndices : Vector.<uint> = null;
        private var m_pVertexBuffer : VertexBuffer3D = null;
        private var m_pIndexBuffer : IndexBuffer3D = null;
        private var m_pMaterial : IMaterial = null;
        private var m_pWorldMatrix : CMatrix4 = null;
        private var m_zDistance : Number = 0.0;
        private var m_iNumTriangls : int = 0;
        private var m_iTriangleOffset : int = 0;

        [Inline]
        final public function get vertices() : VertexData
        { return m_pVertices; }

        [Inline]
        final public function set vertices( value : VertexData ) : void
        { m_pVertices = value; }

        [Inline]
        final public function get indices() : Vector.<uint>
        { return m_pIndices; }

        [Inline]
        final public function set indices( value : Vector.<uint> ) : void
        { m_pIndices = value; }

        [Inline]
        final public function get indicesOffset() : int
        { return m_iTriangleOffset; }

        [Inline]
        final public function set indicesOffset( value : int ) : void
        { m_iTriangleOffset = value; }

        [Inline]
        final public function get vertexBuffer() : VertexBuffer3D
        { return m_pVertexBuffer; }

        [Inline]
        final public function set vertexBuffer( value : VertexBuffer3D ) : void
        { m_pVertexBuffer = value; }

        [Inline]
        final public function get indexBuffer() : IndexBuffer3D
        { return m_pIndexBuffer; }

        [Inline]
        final public function set indexBuffer( value : IndexBuffer3D ) : void
        { m_pIndexBuffer = value; }

        [Inline]
        final public function get material() : IMaterial
        { return m_pMaterial; }

        [Inline]
        final public function set material( value : IMaterial ) : void
        { m_pMaterial = value; }

        [Inline]
        final public function get numTriangles() : int
        { return m_iNumTriangls; }

        [Inline]
        final public function set numTriangles( value : int ) : void
        { m_iNumTriangls = value; }

        [Inline]
        final public function get worldMatrix() : CMatrix4
        { return m_pWorldMatrix; }

        [Inline]
        final public function set worldMatrix( value : CMatrix4 ) : void
        { m_pWorldMatrix = value; }

        [Inline]
        final public function get zDistance() : Number
        { return m_zDistance; }

        [Inline]
        final public function set zDistance( value : Number ) : void
        { m_zDistance = value; }

        public function dispose() : void
        {
            m_pMaterial = null;
            m_pVertices = null;
            m_pIndices = null;
            m_pVertexBuffer = null;
            m_pIndexBuffer = null;
            m_pWorldMatrix = null;
        }
    }
}