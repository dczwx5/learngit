/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2017/2/24.
 */
package QFLib.QEngine.Renderer.VideoBuffer
{
    import QFLib.Interface.IDisposable;

    import flash.display3D.IndexBuffer3D;

    public class IndexBuffer implements IDisposable
    {
        public function IndexBuffer()
        {
        }
        private var m_IndexBuffer3D : IndexBuffer3D = null;

        public function dispose() : void
        {
        }
    }
}
