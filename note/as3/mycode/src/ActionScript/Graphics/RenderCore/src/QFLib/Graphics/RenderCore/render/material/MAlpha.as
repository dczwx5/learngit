//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by david on 2017/5/18.
 */
package QFLib.Graphics.RenderCore.render.material
{
    import QFLib.Graphics.RenderCore.render.IMaterial;
    import QFLib.Graphics.RenderCore.render.pass.PAlpha;
    import QFLib.Graphics.RenderCore.starling.textures.Texture;

    public class MAlpha extends MaterialBase implements IMaterial
    {
        public function MAlpha ()
        {
            super ( 1 );

            var passAlpha : PAlpha = new PAlpha ();
            passAlpha.enable = true;
            _passes[ 0 ] = passAlpha;
        }

        override public function dispose () : void
        {
            super.dispose ();
        }

        public function set alpha ( value : Number ) : void
        {
            var passAlpha : PAlpha = _passes[ 0 ] as PAlpha;
            passAlpha.alpha = value;
        }

        [Inline] override public function set mainTexture ( value : Texture ) : void
        {
            super.mainTexture = value;
            _passes[ 0 ].mainTexture = value;
        }

        public function equal ( other : IMaterial ) : Boolean
        {
            return false;
        }
    }
}
