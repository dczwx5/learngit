/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2016/11/9.
 */
package QFLib.QEngine.Renderer
{
    import QFLib.Interface.IDisposable;
    import QFLib.QEngine.Core.Engine_Internal;
    import QFLib.QEngine.Renderer.Device.RenderDevice;

    public class RenderTarget implements IDisposable
    {
        use namespace Engine_Internal;

        public function RenderTarget()
        {
            RenderSystem.getInstance()._addRenderTarget( this );
        }
        protected var m_pRenderDevice : RenderDevice = null;

        [Inline]
        final public function get renderDevice() : RenderDevice
        { return m_pRenderDevice; }

        [Inline]
        final public function set renderDevice( value : RenderDevice ) : void
        { m_pRenderDevice = value; }

        public function dispose() : void
        {
            RenderSystem.getInstance()._removeRenderTarget( this );
            m_pRenderDevice = null;
        }
    }
}
