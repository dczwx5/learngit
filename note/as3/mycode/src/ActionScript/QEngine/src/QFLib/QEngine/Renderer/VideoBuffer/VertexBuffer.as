/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2017/2/24.
 */
package QFLib.QEngine.Renderer.VideoBuffer
{
    import QFLib.Interface.IDisposable;

    import flash.display3D.VertexBuffer3D;

    public class VertexBuffer implements IDisposable
    {
        public function VertexBuffer()
        {
        }
        private var m_VertexBuffer3D : VertexBuffer3D = null;

        public function dispose() : void
        {}
    }
}
