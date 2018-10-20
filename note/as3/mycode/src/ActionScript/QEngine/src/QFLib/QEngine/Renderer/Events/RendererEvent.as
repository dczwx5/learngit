/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2016/11/9.
 */
package QFLib.QEngine.Renderer.Events
{
    import flash.events.Event;

    public class RendererEvent extends flash.events.Event
    {
        public static const CONTEXT3D_CREATED : String = "Context3DCreated";
        public static const CONTEXT3D_DISPOSED : String = "Context3DDisposed";
        public static const CONTEXT3D_RECREATED : String = "Context3DRecreated";
        public static const VIEWPORT_UPDATED : String = "ViewportUpdated";

        public function RendererEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = false )
        {
            super( type, bubbles, cancelable );
        }
    }
}
