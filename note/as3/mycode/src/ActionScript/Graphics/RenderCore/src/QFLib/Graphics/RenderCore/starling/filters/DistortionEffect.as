//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by david on 2017/5/16.
 */
package QFLib.Graphics.RenderCore.starling.filters
{
    import QFLib.Graphics.RenderCore.render.ICamera;
    import QFLib.Graphics.RenderCore.render.RenderCommand;
    import QFLib.Graphics.RenderCore.render.material.MDistortion;
    import QFLib.Graphics.RenderCore.starling.core.RenderSupport;
    import QFLib.Graphics.RenderCore.starling.core.Starling;
    import QFLib.Graphics.RenderCore.starling.display.DisplayObject;
    import QFLib.Graphics.RenderCore.starling.textures.Texture;

    public class DistortionEffect extends FilterEffect
    {
        public static const Name : String = "Distortion";

        public function DistortionEffect ( pFilter : ObjectFilter )
        {
            super ( pFilter );
            m_Material = m_matDistortion = new MDistortion ();
        }

        override public function dispose () : void
        {
            super.dispose ();
            m_matDistortion = null;
        }

        [Inline] override public function get name () : String { return Name; }

        [Inline] public function set distortionSize ( value : Vector.<Number> ) : void
        {
            if ( m_matDistortion == null ) return;
            m_matDistortion.distortionSize = value;
        }

        [Inline] public function set currentPos ( value : Vector.<Number> ) : void
        {
            if ( m_matDistortion == null ) return;
            m_matDistortion.currentPos = value;
        }

        [Inline] public function set range ( value : Vector.<Number> ) : void
        {
            if ( m_matDistortion == null ) return;
            m_matDistortion.range = value;
        }

        [Inline] public function set direction ( value : Vector.<Number> ) : void
        {
            if ( m_matDistortion == null ) return;
            m_matDistortion.direction = value;
        }

        override public function render ( pOnwer : DisplayObject, support : RenderSupport, alpha : Number, pInTexture : Texture ) : Boolean
        {
            if ( super.render ( pOnwer, support, alpha, pInTexture ) )
            {
                var pInstance : Starling = Starling.current;
                pInstance.addToRender ( getRenderCommand() );

                return true;
            }

            return false;
        }

        override public function postRender ( support : RenderSupport, pCamera : ICamera ) : void
        {
            super.postRender ( support, pCamera );
        }

        override protected function getRenderCommand () : RenderCommand
        {
            m_matDistortion.mainTexture = m_pInTexture;
            m_matDistortion.pma = m_pInTexture.premultipliedAlpha;
            return super.getRenderCommand ();
        }

        private var m_matDistortion : MDistortion = null;
    }
}
