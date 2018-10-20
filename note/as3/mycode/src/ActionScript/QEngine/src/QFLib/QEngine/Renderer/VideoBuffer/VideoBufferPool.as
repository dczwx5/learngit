/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2017/2/16.
 */
package QFLib.QEngine.Renderer.VideoBuffer
{
    import QFLib.Memory.CResourcePool;
    import QFLib.Memory.CResourcePools;
    import QFLib.QEngine.Renderer.Device.RenderDevice;

    import flash.display3D.IndexBuffer3D;
    import flash.display3D.VertexBuffer3D;

    public class VideoBufferPool extends CResourcePools
    {
        public function VideoBufferPool( pDevice : RenderDevice )
        {
            m_pRenderDevice = pDevice;
            registerPool( EVideoBuffer.VERTEXBUFFER, VertexBuffer3D );
            registerPool( EVideoBuffer.INDEXBUFFER, IndexBuffer3D );
        }
        private var m_pRenderDevice : RenderDevice = null;

        override public function dispose() : void
        {
            super.dispose();
            m_pRenderDevice = null;
        }

        public function createVideoBuffer( type : String = "VertexBuffer" /*EVideoBuffer.VERTEXBUFFER*/ ) : Object
        {
            return super.allocate( type );
        }

        private function registerPool( type : String, classFactory : * ) : void
        {
            var pool : CResourcePool = new CResourcePool( type, classFactory );
            super.addPool( type, pool );
        }
    }
}