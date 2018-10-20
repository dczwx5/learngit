/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2017/1/18.
 */
package QFLib.QEngine.Renderer
{
    import QFLib.Math.CAABBox2;
    import QFLib.Math.CAABBox3;
    import QFLib.Math.CMath;
    import QFLib.QEngine.Core.SceneNode;
    import QFLib.QEngine.Renderer.Camera.Camera;
    import QFLib.QEngine.Renderer.RenderQueue.RenderQueueGroup;

    public interface IMovableObject
    {
        function get enable() : Boolean;

        function set enable( value : Boolean ) : void;

        function get visible() : Boolean;

        function set visible( value : Boolean ) : void;

        function get color() : uint;

        function set color( value : uint ) : void;

        function get alpha() : Number;

        function set alpha( value : Number ) : void

        function get groupID() : int;

        function set groupID( value : int ) : void;

        function setColorWithAlpha( red : Number, green : Number, blue : Number, alpha : Number ) : void;

        function getAABBox3( targetSpace : int = CMath.SPACE_GLOBAL ) : CAABBox3;

        function getAABBox2( targetSpace : int = CMath.SPACE_GLOBAL ) : CAABBox2;

        function attachToSceneNode( sceneNode : SceneNode ) : void;

        function detachFromSceneNode() : void;

        function updateRenderQueueGroup( pGroup : RenderQueueGroup, pCamera : Camera ) : void;
    }
}
