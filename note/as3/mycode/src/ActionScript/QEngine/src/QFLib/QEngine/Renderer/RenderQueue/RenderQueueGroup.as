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
    import QFLib.QEngine.Renderer.Material.IMaterial;

    public class RenderQueueGroup implements IDisposable
    {
        function RenderQueueGroup( groupID : int )
        {
            m_SolidsCMDSet = new RenderCommandSet();
            m_ShadowsCMDSet = new RenderCommandSet();
            m_TransparentsCMDSet = new RenderCommandSet();
            m_GroupID = groupID;
        }
        private var m_SolidsCMDSet : RenderCommandSet = null;
        private var m_ShadowsCMDSet : RenderCommandSet = null;
        private var m_TransparentsCMDSet : RenderCommandSet = null;
        private var m_GroupID : int;

        [Inline]
        final public function get groupID() : int
        { return m_GroupID; }

        public function dispose() : void
        {
            m_SolidsCMDSet.dispose();
            m_ShadowsCMDSet.dispose();
            m_TransparentsCMDSet.dispose();
        }

        public function clear() : void
        {
            m_SolidsCMDSet.clear();
            m_ShadowsCMDSet.clear();
            m_TransparentsCMDSet.clear();
        }

        [Inline]
        final public function getSolids() : RenderCommandSet
        { return m_SolidsCMDSet; }

        [Inline]
        final public function getShadows() : RenderCommandSet
        { return m_ShadowsCMDSet; }

        [Inline]
        final public function getTransparents() : RenderCommandSet
        { return m_TransparentsCMDSet; }

        public function addRenderCommand( pRenderCMD : IRenderCommand, pCamera : Camera ) : void
        {
            var pMaterial : IMaterial = pRenderCMD.material;
            if( pMaterial.isTransparent ) m_TransparentsCMDSet.add( pRenderCMD );
            else if( pMaterial.isShadowReceiver ) m_ShadowsCMDSet.add( pRenderCMD );
            else m_SolidsCMDSet.add( pRenderCMD );
        }

        public function tightRenderQueueGroup() : void
        {
            m_SolidsCMDSet.tightRCMDsSet();
            m_ShadowsCMDSet.tightRCMDsSet();
            m_TransparentsCMDSet.tightRCMDsSet();
        }
    }
}
