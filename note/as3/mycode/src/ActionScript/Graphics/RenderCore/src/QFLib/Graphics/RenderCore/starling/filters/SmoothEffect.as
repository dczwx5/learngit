//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by david on 2017/5/18.
 */
package QFLib.Graphics.RenderCore.starling.filters
{
    import QFLib.Graphics.RenderCore.render.RenderCommand;
    import QFLib.Graphics.RenderCore.render.material.MSmooth;
    import QFLib.Graphics.RenderCore.starling.core.RenderSupport;
    import QFLib.Graphics.RenderCore.starling.core.Starling;
    import QFLib.Graphics.RenderCore.starling.display.DisplayObject;
    import QFLib.Graphics.RenderCore.starling.textures.Texture;

    public class SmoothEffect extends FilterEffect
    {
        public static const Name : String = "Smooth";

        public function SmoothEffect ( pFilter : ObjectFilter )
        {
            super ( pFilter );
            m_Material = new MSmooth ();
        }

        override public function dispose () : void
        {
            super.dispose ();
        }

        [Inline] override public function get name () : String { return Name; }

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

        override protected function getRenderCommand () : RenderCommand
        {
            var matSmooth : MSmooth = m_Material as MSmooth;
            matSmooth.mainTexture = m_pInTexture;
            matSmooth.pma = m_pInTexture.premultipliedAlpha;
            mUVOffsets[ 0 ] = 1.0 / m_pInTexture.width;
            mUVOffsets[ 2 ] = 1.0 / m_pInTexture.height;
            matSmooth.uvOffsets = mUVOffsets;
            return super.getRenderCommand ();
        }

        private var mUVOffsets : Vector.<Number> = new <Number>[ 1.0, 0.0, 1.0, 4.0 ];
    }
}
