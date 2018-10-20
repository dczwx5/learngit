/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2016/11/9.
 */
package QFLib.QEngine.Renderer.Device
{
    import QFLib.Foundation.CMap;
    import QFLib.Interface.IDisposable;
    import QFLib.QEngine.Core.Engine_Internal;

    import flash.display.Stage;

    public class RenderDeviceManager implements IDisposable
    {
        private static var sInstance : RenderDeviceManager;

        [Inline]
        public static function getInstance() : RenderDeviceManager
        {
            if( !sInstance ) sInstance = new RenderDeviceManager();
            return sInstance;
        }

        function RenderDeviceManager()
        {
            m_mapRenderDevices = new CMap();
        }
        private var m_mapRenderDevices : CMap = null;
        private var m_pCurrentDevice : RenderDevice = null;

        [Inline]
        final public function get deviceCount() : int
        { return m_mapRenderDevices.length; }

        [Inline]
        final public function get current() : RenderDevice
        { return m_pCurrentDevice; }

        public function dispose() : void
        {
            m_mapRenderDevices.clear();
            m_mapRenderDevices = null;

            m_pCurrentDevice = null;
        }

        [Inline]
        final public function makeCurrent( device : RenderDevice ) : void
        { m_pCurrentDevice = device; }

        Engine_Internal function _addRenderDevice( pDevice : RenderDevice, stage : Stage ) : int
        {
            var i : uint = 0;
            var len : uint = stage.stage3Ds.length;

            while( i < len )
            {
                if( !m_mapRenderDevices[ i ] )
                {
                    m_mapRenderDevices.add( i, pDevice, true );
                    return i;
                }
                i++;
            }

            throw new Error( "Too many Stage3D instances used!" );
            return -1;
        }

        Engine_Internal function _removeRenderDevice( index : int ) : void
        {
            m_mapRenderDevices.remove( index );
        }
    }
}