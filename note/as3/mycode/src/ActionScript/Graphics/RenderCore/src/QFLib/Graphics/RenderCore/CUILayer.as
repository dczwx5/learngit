////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

/**
 * Created by david on 2017/7/21.
 */
package QFLib.Graphics.RenderCore
{
    import QFLib.Graphics.RenderCore.render.Camera;
    import QFLib.Graphics.RenderCore.starling.core.Starling;
    import QFLib.Math.CMath;

    import flash.events.Event;

    public class CUILayer extends CBaseObject
    {
        public static var UILAYER_INDEX : int = 26;

        public function CUILayer ( theRenderer : CRenderer )
        {
            super ( theRenderer );

            m_pUICamera = Starling.current.uiCamera as Camera;
            m_pUICamera.setOrthoSize ( m_fWidth, m_fHeight );
            m_pUICamera.setPosition ( 0.0, 0.0 );
            m_pUICamera.depth = UILAYER_INDEX;
            m_pUICamera.cullingMask = 1 << ( UILAYER_INDEX - 1 );

            this.usingCamera = m_pUICamera;
            this.layer = UILAYER_INDEX;

            Starling.current.nativeStage.addEventListener( Event.RESIZE, onStageResizeHandler );
        }

        override public function dispose () : void
        {
            Starling.current.nativeStage.removeEventListener( Event.RESIZE, onStageResizeHandler );

            m_pUICamera = null;
            super.dispose ();
        }

        public function setKeepAspectRatio ( bKeepAspectRatio : Boolean ) : void
        {
            m_bKeepAspectRatio = bKeepAspectRatio;
        }

        private function onStageResizeHandler( event : Event ) : void
        {
            var width : Number = event.target.stageWidth;
            var height : Number= event.target.stageHeight;

            if ( Math.abs ( width - m_fWidth ) < CMath.EPSILON &&
                    Math.abs ( height - m_fHeight ) < CMath.EPSILON )
            {
                return;
            }

            if ( m_bKeepAspectRatio )
            {
                var ratio : Number = width / height;
                m_fWidth = m_fHeight * ratio;
            }
            else
            {
                m_fWidth = width;
                m_fHeight = height;
            }

            m_pUICamera.setOrthoSize ( m_fWidth, m_fHeight );
        }

        private var m_fWidth : Number = 1500;
        private var m_fHeight : Number = 900;
        private var m_pUICamera : Camera = null;

        private var m_bKeepAspectRatio : Boolean = true;
    }
}