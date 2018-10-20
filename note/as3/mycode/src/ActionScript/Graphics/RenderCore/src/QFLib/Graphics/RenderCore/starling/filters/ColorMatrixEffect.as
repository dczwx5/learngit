//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by david on 2017/5/16.
 */
package QFLib.Graphics.RenderCore.starling.filters
{
    import QFLib.Graphics.RenderCore.render.ICamera;
    import QFLib.Graphics.RenderCore.starling.core.RenderSupport;
    import QFLib.Graphics.RenderCore.starling.display.DisplayObject;
    import QFLib.Graphics.RenderCore.starling.textures.Texture;

    public class ColorMatrixEffect extends FilterEffect
    {
        public static const Name : String = "ColorMatrix";

        public function ColorMatrixEffect ( pFilter : ObjectFilter )
        {
            super ( pFilter );
        }

        override public function dispose () : void
        {
            super.dispose ();
        }

        [inline] override public function get name () : String { return Name; }

        override public function render ( pOnwer : DisplayObject, support : RenderSupport, alpha : Number, pInTexture : Texture ) : Boolean
        {
            if ( super.render ( pOnwer, support, alpha, pInTexture ) )
            {
                return true;
            }

            return false;
        }

        override public function postRender ( support : RenderSupport, pCamera : ICamera ) : void
        {
            super.postRender ( support, pCamera );
        }
    }
}
