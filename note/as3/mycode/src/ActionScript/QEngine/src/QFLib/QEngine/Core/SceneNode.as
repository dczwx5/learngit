/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2016/11/1.
 */
package QFLib.QEngine.Core
{
    import QFLib.Foundation.CMap;
    import QFLib.Interface.IUpdatable;
    import QFLib.QEngine.Renderer.*;
    import QFLib.QEngine.Renderer.Camera.Camera;
    import QFLib.QEngine.Renderer.RenderQueue.RenderQueue;
    import QFLib.QEngine.SceneManage.SceneManager;

    use namespace Engine_Internal;

    public class SceneNode extends Node implements IUpdatable
    {
        public function SceneNode( pParent : SceneNode, sceneMgr : SceneManager )
        {
            super( pParent );
            m_pSceneManger = sceneMgr;
            m_mapObjects = new CMap();
            m_Transform = new Transform( this );
        }
        /**
         *  movable objects which attach to this scene node
         */
        private var m_mapObjects : CMap = null;
        private var m_Transform : Transform = null;
        private var m_pSceneManger : SceneManager = null;
        /**
         * default layer value : zero, the node won't be culled by camera culling mask
         */
        private var m_iLayer : uint = 0;
        private var m_isInSceneGraph : Boolean = false;

        public function get isInSceneGraph() : Boolean
        {
            return m_isInSceneGraph;
        }

        [Inline]
        final public function get transform() : Transform
        { return m_Transform; }

        override public function dispose() : void
        {
            var object : MovableObject;
            for( var i : int = 0, n : int = m_mapObjects.count; i < n; i++ )
            {
                object = m_mapObjects.find( i );
                detachObject( object );
            }

            m_mapObjects = null;

            super.dispose();

            m_Transform.dispose();
            m_Transform = null;
        }

        override public function setParent( parent : Node ) : void
        {
            super.setParent( parent );

            var parentSceneNode : SceneNode = parent as SceneNode;
            if( parentSceneNode == null )
                setInSceneGraph( true );
            else
                setInSceneGraph( parentSceneNode.isInSceneGraph );
        }

        override Engine_Internal function _notifyAddChild( child : Node ) : void
        {
            var sceneNode : SceneNode = child as SceneNode;
            sceneNode.setInSceneGraph( m_isInSceneGraph );
            m_Transform._notifyAddChild( sceneNode.transform );

            super._notifyAddChild( child );
        }

        override Engine_Internal function _notifyRemoveChild( child : Node ) : void
        {
            var sceneNode : SceneNode = child as SceneNode;
            sceneNode.setInSceneGraph( false );
            m_Transform._notifyRemoveChild( sceneNode.transform );

            super._notifyRemoveChild( child );
        }

        public function attachObject( object : MovableObject ) : void
        {
            if( !m_mapObjects.find( object ) )
            {
                var count : int = m_mapObjects.count;
                object._notifyAttachedToParent( this, m_mapObjects.count );
                m_mapObjects.add( count, object, true );
            }
        }

        public function detachObject( object : MovableObject ) : void
        {
            if( m_mapObjects.find( object.indexInParent ) )
            {
                object._notifyDetachedFromParent();
                m_mapObjects.remove( object.indexInParent );
            }
        }

        /**
         *
         * @param value : is the scene node in the scenegraph
         * @param force : force the scene node and its children in scenegraph
         */
        public function setInSceneGraph( value : Boolean, force : Boolean = false ) : void
        {
            m_isInSceneGraph = value;

            var child : SceneNode;
            for( var i : int = 0, n : int = m_mapChildren.count; i < n; i++ )
            {
                child = m_mapChildren[ i ];
                if( force )
                    child.setInSceneGraph( value );
                else
                    child.setInSceneGraph( child.isInSceneGraph && value );
            }
        }

        public function update( deltaTime : Number ) : void
        {
            if( !m_Enable || !m_isInSceneGraph ) return;
        }

        /**
         * nothing would be culled by the camera when its culling mask equals to zero
         * @param pCamera
         * @param pRenderQueue
         */
        Engine_Internal function walkTree( pCamera : Camera, pRenderQueue : RenderQueue ) : void
        {
            if( !m_isInSceneGraph ) return;

            var culled : Boolean = ( pCamera.cullingMask != 0 && m_iLayer != 0 ) ? ( ( pCamera.cullingMask & ( m_iLayer ) ) == 0 ) : false;
            if( culled ) return;

            /** render queue process */
            var pMovable : MovableObject = null;
            var i : int;
            var count : int;
            for( i = 0, count = m_mapObjects.count; i < count; i++ )
            {
                pMovable = m_mapObjects[ i ];
                if( !pMovable.visible ) continue;

                pRenderQueue.process( pMovable, pCamera );
            }

            /** traversal children */
            var child : SceneNode = null;
            for( i = 0, count = m_mapChildren.count; i < count; i++ )
            {
                child = m_mapChildren[ i ];
                child.walkTree( pCamera, pRenderQueue );
            }
        }

        Engine_Internal function _notifyUpdateChildrenTransform() : void
        {
            var child : SceneNode = null;
            for( var i : int = 0, count : int = m_mapChildren.count; i < count; i++ )
            {
                child = m_mapChildren.find( i ) as SceneNode;
                child.transform._worldMatrixDirty = true;
            }
        }
    }
}
