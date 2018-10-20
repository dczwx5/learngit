/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2017/1/17.
 */
package QFLib.QEngine.Renderer.RenderQueue
{
    import QFLib.Interface.IDisposable;
    import QFLib.QEngine.Renderer.*;
    import QFLib.QEngine.Renderer.Camera.Camera;

    public class RenderQueue implements IDisposable
    {
        public function RenderQueue()
        {
            m_vecQueueGroup = new Vector.<RenderQueueGroup>();
            createRenderQueueGroup( ERenderQueueGoupIDs.BACKGROUND );
            createRenderQueueGroup( ERenderQueueGoupIDs.SKIES );
            createRenderQueueGroup( ERenderQueueGoupIDs.ENTITIES );
            createRenderQueueGroup( ERenderQueueGoupIDs.FOREGROUND );
            createRenderQueueGroup( ERenderQueueGoupIDs.OVERLAY );
        }
        private var m_vecQueueGroup : Vector.<RenderQueueGroup> = null;

        [Inline]
        final public function get length() : int
        { return m_vecQueueGroup.length; }

        public function dispose() : void
        {
            for each ( var queueGroup : RenderQueueGroup in m_vecQueueGroup )
            {
                if( queueGroup == null ) continue;
                queueGroup.clear();
                queueGroup.dispose();
                queueGroup = null;
            }
            m_vecQueueGroup = null;
        }

        [Inline]
        final public function getRenderQueueGroupByID( groupID : int ) : RenderQueueGroup
        { return m_vecQueueGroup[ groupID ]; }

        public function firstRenderQueueGroup() : RenderQueueGroup { return getRenderQueueGroupByID( 0 ); }

        public function clear() : void
        {
            for each ( var group : RenderQueueGroup in m_vecQueueGroup )
            {
                if( group == null ) continue;
                group.clear();
            }
        }

        public function process( pMovable : MovableObject, pCamera : Camera ) : void
        {
            var culled : Boolean = false;
            if( pCamera.enableCulling )
            {}

            if( culled ) return;

            var groupID : int = pMovable.groupID;
            var pGroup : RenderQueueGroup = m_vecQueueGroup[ groupID ];
            if( pGroup == null )
                pGroup = createRenderQueueGroup( groupID );

            pMovable.updateRenderQueueGroup( pGroup, pCamera );
        }

        public function tightRenderQueue() : void
        {
            for each ( var group : RenderQueueGroup in m_vecQueueGroup )
            {
                if( group == null ) continue;
                group.tightRenderQueueGroup();
            }
        }

        private function createRenderQueueGroup( groupID : int ) : RenderQueueGroup
        {
            var queueGroup : RenderQueueGroup = new RenderQueueGroup( groupID );
            var length : int = m_vecQueueGroup.length;
            var num : int = groupID - length + 1;
            if( num > 0 )
            {
                m_vecQueueGroup.fixed = false;
                m_vecQueueGroup.length += num;
                m_vecQueueGroup.fixed = true;
            }
            m_vecQueueGroup[ groupID ] = queueGroup;

            return queueGroup;
        }
    }
}
