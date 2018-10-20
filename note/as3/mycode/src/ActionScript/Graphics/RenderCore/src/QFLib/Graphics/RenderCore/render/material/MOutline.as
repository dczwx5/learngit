////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

/**
 * Created by david on 2017/5/9.
 */
package QFLib.Graphics.RenderCore.render.material
{
    import QFLib.Graphics.RenderCore.render.IMaterial;
    import QFLib.Graphics.RenderCore.render.pass.POutlineColor;
    import QFLib.Graphics.RenderCore.render.pass.PSpriteTexture;
    import QFLib.Graphics.RenderCore.starling.textures.Texture;

    public class MOutline extends MaterialBase implements IMaterial
    {
        public function MOutline ()
        {
            super ( 2 );

            var outlineColor : POutlineColor = new POutlineColor ();
            outlineColor.enable = true;
            _passes[ 0 ] = outlineColor;

            var spriteTexture : PSpriteTexture = new PSpriteTexture ();
            spriteTexture.enable = true;
            _passes[ 1 ] = spriteTexture;
        }

        override public function dispose () : void
        {
            super.dispose ();
        }

        [Inline] override public function set mainTexture ( value : Texture ) : void
        {
            super.mainTexture = value;
            _passes[ 0 ].mainTexture = value;
            _passes[ 1 ].mainTexture = value;
            _passes[ 0 ].pma = value.premultipliedAlpha;
            _passes[ 1 ].pma = value.premultipliedAlpha;
        }

        [Inline] public function set outlineColor ( value : Vector.<Number> ) : void
        {
            ( _passes[ 0 ] as POutlineColor ).outlineColor = value;
        }

        [Inline] public function set uvExpand ( value : Vector.<Number> ) : void
        {
            ( _passes[ 0 ] as POutlineColor ).uvExpand = value;
        }

        public function equal ( other : IMaterial ) : Boolean
        {
            return false;
        }
    }
}
