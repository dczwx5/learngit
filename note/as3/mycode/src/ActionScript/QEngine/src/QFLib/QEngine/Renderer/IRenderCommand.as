/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2016/11/1.
 */
package QFLib.QEngine.Renderer
{
    import QFLib.Math.CMatrix4;
    import QFLib.QEngine.Renderer.Material.IMaterial;
    import QFLib.QEngine.Renderer.Utils.VertexData;

    import flash.display3D.IndexBuffer3D;
    import flash.display3D.VertexBuffer3D;

    public interface IRenderCommand
    {
        function get material() : IMaterial;

        function set material( value : IMaterial ) : void;

        function get vertices() : VertexData;

        function set vertices( value : VertexData ) : void;

        function get indices() : Vector.<uint>;

        function set indices( value : Vector.<uint> ) : void

        function get indicesOffset() : int;

        function set indicesOffset( value : int ) : void;

        function get vertexBuffer() : VertexBuffer3D;

        function set vertexBuffer( value : VertexBuffer3D ) : void;

        function get indexBuffer() : IndexBuffer3D;

        function set indexBuffer( value : IndexBuffer3D ) : void;

        function get numTriangles() : int;

        function set numTriangles( value : int ) : void;

        function get worldMatrix() : CMatrix4;

        function set worldMatrix( value : CMatrix4 ) : void;

        function get zDistance() : Number;
    }
}
