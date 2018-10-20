////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

/**
 * Created by david on 2017/5/26.
 */
package QFLib.Graphics.RenderCore.render.material
{
    import QFLib.Graphics.RenderCore.render.IMaterial;
    import QFLib.Graphics.RenderCore.render.pass.PDistortion;
    import QFLib.Graphics.RenderCore.starling.textures.Texture;

    public class MDistortion extends MaterialBase implements IMaterial
    {
        public function MDistortion ()
        {
            super ( 1 );

            var passDistortion : PDistortion = new PDistortion ();
            passDistortion.enable = true;
            _passes[ 0 ] = passDistortion;
        }

        override public function dispose () : void
        {
            super.dispose ();
        }

        [Inline]
        override public function set mainTexture ( value : Texture ) : void
        {
            super.mainTexture = value;
            ( _passes[ 0 ] as PDistortion ).pma = value.premultipliedAlpha;
            ( _passes[ 0 ] as PDistortion ).mainTexture = value;
        }

        public function set distortionSize ( value : Vector.<Number> ) : void
        {
            for ( var i : int = 0; i < 4; i++ )
            {
                _distortionSize[ i ] = value[ i ];
            }

            ( _passes[ 0 ] as PDistortion ).distortionSize = _distortionSize;
        }

        public function set range ( value : Vector.<Number> ) : void
        {
            for ( var i : int = 0; i < 4; i++ )
            {
                _range[ i ] = value[ i ];
            }

            ( _passes[ 0 ] as PDistortion ).range = _range;
        }

        public function set currentPos ( value : Vector.<Number> ) : void
        {
            for ( var i : int = 0; i < 4; i++ )
            {
                _currentPos[ i ] = value[ i ];
            }

            ( _passes[ 0 ] as PDistortion ).currentPos = _currentPos;
        }

        public function set direction ( value : Vector.<Number> ) : void
        {
            for ( var i : int = 0; i < 4; i++ )
            {
                _direction[ i ] = value[ i ];
            }

            ( _passes[ 0 ] as PDistortion ).direction = _direction;
        }

        public function equal ( other : IMaterial ) : Boolean
        {
            return false;
        }

        private var _distortionSize : Vector.<Number> = Vector.<Number> ( [0.05, 0.0, 0.0, 0.0 ] );
        private var _range : Vector.<Number> = Vector.<Number> ( [ 0.0, 1.0, 0.0, 1.0 ] );
        private var _currentPos : Vector.<Number> = Vector.<Number> ( [ 0.0, 0.0, 0.0, 0.0 ] );
        private var _direction : Vector.<Number> = Vector.<Number> ( [ 0.0, 1.0, 1.0, -1.0 ] );
    }
}
