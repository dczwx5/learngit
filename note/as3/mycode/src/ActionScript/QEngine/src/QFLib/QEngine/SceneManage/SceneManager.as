/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2016/11/8.
 */
package QFLib.QEngine.SceneManage
{
    import QFLib.Interface.IDisposable;
    import QFLib.QEngine.Core.Engine_Internal;
    import QFLib.QEngine.Core.SceneNode;
    import QFLib.QEngine.Renderer.*;
    import QFLib.QEngine.Renderer.Camera.Camera;
    import QFLib.QEngine.Renderer.Camera.Frustum;
    import QFLib.QEngine.Renderer.Device.RenderDevice;
    import QFLib.QEngine.Renderer.Device.RenderDeviceManager;
    import QFLib.QEngine.Renderer.Pipeline.ForwardRenderPipeline;
    import QFLib.QEngine.Renderer.RenderQueue.ESortMode;
    import QFLib.QEngine.Renderer.RenderQueue.RenderCommandSet;
    import QFLib.QEngine.Renderer.RenderQueue.RenderQueue;
    import QFLib.QEngine.Renderer.RenderQueue.RenderQueueGroup;

    import flash.display3D.Context3DCompareMode;
    import flash.display3D.Context3DTriangleFace;

    public class SceneManager implements IDisposable
    {
        use namespace Engine_Internal;

        function SceneManager( renderSystem : RenderSystem )
        {
            m_pRenderSystem = renderSystem;
            m_RenderQueue = new RenderQueue();
            m_vecCamera = new Vector.<Camera>();
        }
        private var m_SceneRoot : SceneNode = null;
        private var m_RenderQueue : RenderQueue = null;
        private var m_vecCamera : Vector.<Camera> = null;
        private var m_pRenderSystem : RenderSystem = null;
        private var m_pActiveCamera : Camera = null;
        private var m_pLastCamera : Camera = null;
        private var ForwadPipeline : ForwardRenderPipeline = ForwardRenderPipeline.getInstance();
        private var m_bCameraListDirty : Boolean = false;
        private var m_bTightCameraList : Boolean = false;

        public function get root() : SceneNode
        {
            if( m_SceneRoot == null )
            {
                return m_SceneRoot = createSceneNode( null );
            }

            return m_SceneRoot;
        }

        [Inline]
        final public function get rendreQueue() : RenderQueue
        { return m_RenderQueue; }

        public function dispose() : void
        {
            if( m_SceneRoot )
                m_SceneRoot.dispose();
            m_SceneRoot = null;

            m_RenderQueue.dispose();
            m_pRenderSystem = null;

            //dispose cameras
            var len : int = m_vecCamera.length;
            for( var i : int = 0; i < len; i++ )
            {
                m_vecCamera[ i ].dispose();
                m_vecCamera[ i ] = null;
            }
            m_vecCamera.fixed = false;
            m_vecCamera.length = 0;
            m_vecCamera = null;
        }

        public function createSceneNode( parent : SceneNode ) : SceneNode
        {
            var sceneNode : SceneNode = new SceneNode( parent, this );
            return sceneNode;
        }

        public function createCamera( pRenderTarget : RenderTarget, pParent : SceneNode, frustumType : int = Frustum.PERSPECTIVE, cullingMask : uint = 0x00, clearMask : uint = 0xffffffff, backGroundColor : uint = 0xffffffff, order : int = 0 ) : Camera
        {
            var camera : Camera = new Camera( pRenderTarget, this, frustumType, pParent, cullingMask, clearMask, backGroundColor, order );
            var len : int = m_vecCamera.length;
            for( var i : int = 0; i < len; i++ )
            {
                if( m_vecCamera[ i ] == null )
                {
                    m_vecCamera[ i ] = camera;
                    break;
                }
            }

            if( i == len )
            {
                m_vecCamera.fixed = false;
                m_vecCamera.length += 1;
                m_vecCamera[ i ] = camera;
                m_vecCamera.fixed = true;
            }

            m_bCameraListDirty = true;
            return camera;
        }

        public function destroyCamera( pCamera : Camera ) : void
        {
            var len : int = m_vecCamera.length;
            for( var i : int = 0; i < len; i++ )
            {
                if( pCamera == m_vecCamera[ i ] )
                {
                    m_vecCamera[ i ].dispose();
                    m_vecCamera[ i ] = null;
                    break;
                }
                continue;
            }

            m_bTightCameraList = true;
        }

        public function render() : void
        {
            var len : int = m_vecCamera.length;
            if( len == 0 ) return;

            preRender();

            for( var i : int = 0; i < len; i++ )
            {
                m_pActiveCamera = m_vecCamera[ i ];

                if( i > 0 ) m_pLastCamera = m_pActiveCamera;
                else m_pLastCamera = null;

                if( m_pActiveCamera == null || !m_pActiveCamera.enable ) continue;

                renderScene();
            }

            postRender();
        }

        private function preRender() : void
        {
            tightCameraList();
            sortCameraList();
        }

        private function postRender() : void
        {
            //one frame finished
        }

        /**
         * tight camera list
         */
        private function tightCameraList() : void
        {
            if( m_bTightCameraList )
            {

            }
        }

        /**
         * sort camera list
         */
        private function sortCameraList() : void
        {
            if( m_bCameraListDirty )
            {
                m_vecCamera.sort( function ( node1 : Camera, node2 : Camera ) : int
                {
                    if( node1.order > node2.order ) return 1;
                    else if( node1.order < node2.order ) return -1;

                    return 0;
                } );
                m_bCameraListDirty = false;
            }
        }

        private function renderScene() : void
        {
            prepareRenderQueue();
            walkTree();

            ForwadPipeline.prepare( m_pLastCamera, m_pActiveCamera );
            renderAllVisibleObjects();
            ForwadPipeline.finish( m_pActiveCamera );
        }

        /**
         * eg: clear render queue
         */
        private function prepareRenderQueue() : void
        {
            m_RenderQueue.clear();
        }

        /**
         * find the visiblity objects
         */
        private function walkTree() : void
        {
            m_SceneRoot.walkTree( m_pActiveCamera, m_RenderQueue );
        }

        private function renderAllVisibleObjects() : void
        {
            var pQueueGroup : RenderQueueGroup = null;
            var length : int = m_RenderQueue.length;
            var i : int = 0;
            while( i < length )
            {
                pQueueGroup = m_RenderQueue.getRenderQueueGroupByID( i );
                ++i;

                if( pQueueGroup == null ) continue;
                renderQueueGroupObjects( pQueueGroup );
            }
        }

        private function renderQueueGroupObjects( pGroup : RenderQueueGroup ) : void
        {
            var pCurDevice : RenderDevice = RenderDeviceManager.getInstance().current;
            //render solid objects
            var solids : RenderCommandSet = pGroup.getSolids();
            if( solids.count > 0 )
            {
                solids.sort( ESortMode.SORT_ASCEND_DISTANCE );
                pCurDevice.setDepthTest( true, Context3DCompareMode.LESS_EQUAL );
                pCurDevice.setCullingMode( Context3DTriangleFace.BACK );
                ForwadPipeline.execute( solids );
            }

            //render shadow objects
            var shadows : RenderCommandSet = pGroup.getShadows();
            if( shadows.count > 0 )
            {
                shadows.sort( ESortMode.NEEDNOT_SORT );
                pCurDevice.setDepthTest( true, Context3DCompareMode.LESS_EQUAL );
                pCurDevice.setCullingMode( Context3DTriangleFace.NONE );
                ForwadPipeline.execute( shadows );
            }

            //render transparent objects
            var transparents : RenderCommandSet = pGroup.getTransparents();
            if( transparents.count > 0 )
            {
                transparents.sort( ESortMode.SORT_DESCEND_DISTANCE );
                pCurDevice.setDepthTest( false, Context3DCompareMode.LESS_EQUAL );
                pCurDevice.setCullingMode( Context3DTriangleFace.NONE );
                ForwadPipeline.execute( transparents );
            }
        }
    }
}