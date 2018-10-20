/**
 * Created by david on 2016/11/30.
 */

package QFLib.Graphics.RenderCore.render.material
{
    import QFLib.Graphics.RenderCore.render.IMaterial;
    import QFLib.Graphics.RenderCore.render.pass.PGaussianBlur;
    import QFLib.Graphics.RenderCore.starling.textures.Texture;

    public class MGaussianBlur extends MaterialBase implements IMaterial
    {
        private var _passGaussianBlur : PGaussianBlur = new PGaussianBlur ();
        private var _uvExpand : Vector.<Number> = new Vector.<Number> ( 4 );
        private var _weights : Vector.<Number> = new Vector.<Number> ( 4 );
        private var _centerWeightExAndOffsets : Vector.<Number> = new <Number>[ 1.0, 1.0, 0.0, 1.0 ];
        private var _glowColor : Vector.<Number> = new <Number> [ 1.0, 1.0, 0.0, 0.0 ];
        private var _glowStrenthen : Vector.<Number> = new <Number> [ 0.0, 0.01, 0.0, 0.0 ];

        public function MGaussianBlur ()
        {
            super ( 1 );

            _passGaussianBlur.uvExpand = _uvExpand;
            _passGaussianBlur.weights = _weights;
            _passGaussianBlur.centerWeightAndOffsets = _centerWeightExAndOffsets;
            _passGaussianBlur.glowColor = _glowColor;
            _passGaussianBlur.glowStrenthen = _glowStrenthen;
            _passGaussianBlur.enable = true;
            _passes[ 0 ] = _passGaussianBlur;
        }

        override public function dispose () : void
        {
            super.dispose ();
        }

        override public function reset () : void
        {
            setAllPassEnable ( false );
            _passGaussianBlur.enable = true;
        }

        [Inline] override public function set pma ( value : Boolean ) : void
        {
            super.pma = value;
            _passGaussianBlur.pma = value;
        }

        public function set uvExpand ( value : Vector.<Number> ) : void
        {
            for ( var i : int = 0; i < 4; i++ )
            {
                _uvExpand[ i ] = value[ i ];
            }
        }

        public function set weights ( value : Vector.<Number> ) : void
        {
            for ( var i : int = 0; i < 4; i++ )
            {
                _weights[ i ] = value[ i ];
            }
        }

        public function set centerWeightAndOffsets ( value : Vector.<Number> ) : void
        {
            for ( var i : int = 0; i < 4; i++ )
            {
                _centerWeightExAndOffsets[ i ] = value[ i ];
            }
        }

        public function set glowColor ( value : Vector.<Number> ) : void
        {
            for ( var i : int = 0; i < 4; i++ )
            {
                _glowColor[ i ] = value [ i ];
            }
        }

        public function set glowStrenthen ( strenthen : Number ) : void
        {
            _glowStrenthen[ 0 ] = strenthen;
        }

        override public function set mainTexture ( value : Texture ) : void
        {
            super.mainTexture = value;
            _passGaussianBlur.mainTexture = value;
        }

        public function equal ( other : IMaterial ) : Boolean
        {
            if ( other == null ) return false;
            var otherAlias : MGaussianBlur = other as MGaussianBlur;
            if ( otherAlias == null ) return false;

            return super.innerEqual ( otherAlias );
        }
    }
}
