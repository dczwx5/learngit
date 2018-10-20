/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2016/11/9.
 */
package QFLib.QEngine.Renderer
{
    import QFLib.QEngine.Renderer.Device.RenderDevice;
    import QFLib.QEngine.Renderer.Events.RendererEvent;

    import flash.display.Stage;

    public class RenderView extends RenderTarget
    {
        public function RenderView( stage : Stage, renderMode : String = "auto", profile : Object = "baselineConstrained", onCreatedCallBack : Function = null )
        {
            super();
            renderDevice = m_RenderDevice = new RenderDevice( stage, renderMode, profile );
            m_RenderDevice.addEventListener( RendererEvent.CONTEXT3D_CREATED, onCreatedCallBack );
        }
        private var m_RenderDevice : RenderDevice = null;

        override public function dispose() : void
        {
            m_RenderDevice.dispose();
            m_RenderDevice = null;
            super.dispose();
        }
    }
}