/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2017/1/24.
 */
package QFLib.QEngine.Renderer
{
    import QFLib.Math.CVector3;
    import QFLib.QEngine.Renderer.Camera.Camera;
    import QFLib.QEngine.Renderer.Material.IMaterial;
    import QFLib.QEngine.Renderer.RenderQueue.RenderQueueGroup;

    public interface IRenderer
    {
        function get renderCommand() : IRenderCommand;

        function get sharedMaterial() : IMaterial;

        function set sharedMaterial( value : IMaterial ) : void;

        function addCommandsToGroup( pGroup : RenderQueueGroup, pCamera : Camera ) : void;

        function getMaterial() : IMaterial;

        function setMaterial( value : IMaterial ) : void;

        function setPremultiplyAlpha( value : Boolean, updateData : Boolean = false ) : void;

        function getPremultiplyAlpha() : Boolean;

        function setColor( color : uint ) : void;

        function setColorWithAlpha( color : uint, alpha : Number ) : void;

        function setVertexColor( index : int, color : uint ) : void;

        function setVertexColorWithAlpha( index : int, color : uint, alpha : Number ) : void;

        function setAlpha( alpha : Number ) : void;

        function setVertexAlpha( index : int, alpha : Number ) : void;

        function setVertexPosition( index : int, position : CVector3 ) : void;

        function setVertexPositionByValue( index : int, x : Number, y : Number, z : Number ) : void;

        function translateVertex( index : int, deltaX : Number, deltaY : Number, deltaZ : Number ) : void;

        function setTexcoords( index : int, u : Number, v : Number ) : void
    }
}
