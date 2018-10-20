////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

/**
 * Created by david on 2016/12/12.
 */
package QFLib.Graphics.RenderCore.render.material
{

    import QFLib.Graphics.RenderCore.render.IMaterial;
    import QFLib.Graphics.RenderCore.render.pass.PSmooth;
    import QFLib.Graphics.RenderCore.starling.textures.Texture;

    public class MSmooth extends MaterialBase implements IMaterial
    {
        private var _passSmooth : PSmooth = new PSmooth ();
        private var _uvOffsets : Vector.<Number> = new <Number>[ 1.0, 0.0, 1.0, 4.0 ];

        public function MSmooth ()
        {
            super ( 1 );

            _passSmooth.uvOffsets = _uvOffsets;
            _passSmooth.enable = true;
            _passes[ 0 ] = _passSmooth;
        }

        override public function reset () : void
        {
            setAllPassEnable ( false );
            _passSmooth.enable = true;
        }

        public function set uvOffsets ( value : Vector.<Number> ) : void
        {
            for ( var i : int = 0; i < 4; i++ )
            {
                _uvOffsets[ i ] = value[ i ];
            }
        }

        public override function set mainTexture ( value : Texture ) : void
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
