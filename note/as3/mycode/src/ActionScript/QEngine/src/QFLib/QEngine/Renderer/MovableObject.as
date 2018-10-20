/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2016/11/1.
 */
package QFLib.QEngine.Renderer
{

    import QFLib.Interface.IDisposable;
    import QFLib.Math.CAABBox2;
    import QFLib.Math.CAABBox3;
    import QFLib.Math.CMath;
    import QFLib.QEngine.Core.Engine_Internal;
    import QFLib.QEngine.Core.Node;
    import QFLib.QEngine.Core.SceneNode;
    import QFLib.QEngine.Renderer.Camera.Camera;
    import QFLib.QEngine.Renderer.RenderQueue.ERenderQueueGoupIDs;
    import QFLib.QEngine.Renderer.RenderQueue.RenderQueueGroup;

    public class MovableObject implements IDisposable, IMovableObject
    {
        public function MovableObject( pParent : SceneNode )
        {
            setParent( pParent );
        }

        protected var m_pParentNode : SceneNode = null;
        protected var m_IndexInParent : int = -1;
        protected var m_ZOrder : int = 0;
        protected var m_GroupID : int = ERenderQueueGoupIDs.ENTITIES;
        protected var m_Enable : Boolean = true;

        [Inline]
        final public function get enable() : Boolean
        { return m_Enable;}

        [Inline]
        final public function set enable( value : Boolean ) : void
        { m_Enable = value; }

        public function get visible() : Boolean
        { return false; }

        public function set visible( value : Boolean ) : void
        { }

        public function get color() : uint
        { return 0; }

        public function set color( value : uint ) : void
        { }

        public function get alpha() : Number
        { return 0; }

        public function set alpha( value : Number ) : void
        {}

        [Inline]
        final public function get indexInParent() : int
        { return m_IndexInParent; }

        [Inline]
        final public function get zOrder() : int
        { return m_ZOrder; }

        [Inline]
        final public function set zOrder( value : int ) : void
        { m_ZOrder = value; }

        [Inline]
        final public function get groupID() : int
        { return m_GroupID; }

        [Inline]
        final public function set groupID( value : int ) : void
        { m_GroupID = value; }

        public function dispose() : void
        {
            m_pParentNode.detachObject( this );
            m_pParentNode = null;
        }

        public function setParent( pParentNode : SceneNode ) : void
        {
            if( pParentNode != null )
                pParentNode.attachObject( this );
        }

        [Inline]
        final public function getParent() : Node
        { return m_pParentNode; }

        public function setColorWithAlpha( red : Number, green : Number, blue : Number, alpha : Number ) : void
        {}

        public function attachToSceneNode( sceneNode : SceneNode ) : void
        {
            if( sceneNode != null )
                sceneNode.attachObject( this );
        }

        public function detachFromSceneNode() : void
        {
            if( m_pParentNode != null )
                m_pParentNode.detachObject( this );
        }

        public function getAABBox3( targetSpace : int = CMath.SPACE_GLOBAL ) : CAABBox3 { return null; }

        public function getAABBox2( targetSpace : int = CMath.SPACE_GLOBAL ) : CAABBox2 { return null; }

        virtual public function update( deltaTime : Number ) : void
        {
            if( !m_Enable ) return;
        }

        public function updateRenderQueueGroup( pGroup : RenderQueueGroup, pCamera : Camera ) : void { }

        Engine_Internal function _notifyAttachedToParent( pParent : SceneNode, index : int ) : void
        {
            m_pParentNode = pParent;
            m_IndexInParent = index;
        }

        Engine_Internal function _notifyDetachedFromParent() : void
        {
            m_pParentNode = null;
            m_IndexInParent = -1;
        }
    }
}