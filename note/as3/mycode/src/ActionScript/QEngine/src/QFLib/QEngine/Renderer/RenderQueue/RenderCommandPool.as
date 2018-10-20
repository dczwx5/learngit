/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2017/3/21.
 */
package QFLib.QEngine.Renderer.RenderQueue
{
    import QFLib.Memory.CResourcePool;
    import QFLib.QEngine.Renderer.*;

    public class RenderCommandPool
    {
        private static var sRenderCommandPool : CResourcePool = new CResourcePool( "RenderCommandPool", RenderCommand );
        private static var sUpdateInternalTime : Number = 5.0;
        private static var sCurrentTime : Number = 0.0;

        public static function getRenderCommand() : IRenderCommand
        {
            return sRenderCommandPool.allocate() as IRenderCommand;
        }

        public static function recycleRenderCommand( rcmd : IRenderCommand ) : void
        {
            sRenderCommandPool.recycle( rcmd );
        }

        public static function tightRenderCommand() : void
        {
            sRenderCommandPool.cleanUpRecycledObjects( 5 );
        }

        public static function update( deltaTime : Number ) : void
        {
            sCurrentTime += deltaTime;
            if( sCurrentTime > sUpdateInternalTime )
            {
                tightRenderCommand();
                sCurrentTime %= sUpdateInternalTime;
            }
        }
    }
}
