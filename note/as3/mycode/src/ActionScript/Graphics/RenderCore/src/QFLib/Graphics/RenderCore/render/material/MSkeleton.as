package QFLib.Graphics.RenderCore.render.material
{

import QFLib.Graphics.RenderCore.render.IMaterial;
import QFLib.Graphics.RenderCore.render.pass.PSkeletonSink;
import QFLib.Graphics.RenderCore.starling.textures.Texture;

public class MSkeleton extends MaterialBase implements IMaterial
    {
        private var _tintColor : Vector.<Number> = new Vector.<Number> ( 4 );
        private var _maskColor : Vector.<Number> = new Vector.<Number> ( 4 );
        private var _lightColor : Vector.<Number> = new Vector.<Number> ( 4 );
        private var _lightContrast : Vector.<Number> = new Vector.<Number> ( 4 );
        private var _sinkParam : Vector.<Number> = new Vector.<Number> ( 4 );

        private var _sink : Boolean = false;

        public function MSkeleton ()
        {
            super ( 1 );

            for ( var i : int = 0; i < 4; ++i )
            {
                _tintColor[ i ] = 1.0;
                _maskColor[ i ] = 0.0;
                _lightColor[ i ] = 1.0;
                _sinkParam[ i ] = 0.0;
            }
            _maskColor[ 3 ] = 1.0;

            _sinkParam[ 1 ] = 0.75;

            _lightContrast[ 0 ] = 1.0;
            _lightContrast[ 1 ] = 0.0;
            _lightContrast[ 2 ] = 1.0;
            _lightContrast[ 3 ] = 1.0;

            var passSink : PSkeletonSink = new PSkeletonSink ();
            passSink.tintColor = _tintColor;
            passSink.maskColor = _maskColor;
            passSink.lightColor = _lightColor;
            passSink.lightContrast = _lightContrast;
            passSink.sinkParam = _sinkParam;
            passSink.enable = true;
            _passes[ 0 ] = passSink;
        }

        public override function dispose () : void
        {
            if ( _tintColor )
            {
                _tintColor.length = 0;
                _tintColor = null;
            }

            if ( _maskColor )
            {
                _maskColor.length = 0;
                _maskColor = null;
            }

            if ( _lightColor )
            {
                _lightColor.length = 0;
                _lightColor = null;
            }

            if ( _lightContrast )
            {
                _lightContrast.length = 0;
                _lightContrast = null;
            }

            if ( _sinkParam )
            {
                _sinkParam.length = 0;
                _sinkParam = null;
            }

            super.dispose ();
        }

        override public function reset () : void
        {
            setAllPassEnable ( false );
            _passes[ 0 ].enable = true;
        }

        public override function set mainTexture ( value : Texture ) : void
        {
            if ( _mainTexture != value )
            {
                _mainTexture = value;

                for ( var i : int = 0, count : int = _passes.length; i < count; i++ )
                {
                    _passes[ i ].mainTexture = value;
                }
            }
        }

        public function set blendMode ( value : String ) : void
        {
            for ( var i : int = 0, count : int = _passes.length; i < count; i++ )
            {
                _passes[ i ].blendMode = value;
            }
        }

        public override function set pma ( value : Boolean ) : void
        {
            for ( var i : int = 0, count : int = _passes.length; i < count; i++ )
            {
                _passes[ i ].pma = value;
            }
            _premultiplyAlpha = value;
        }

        public function set tintColor ( value : Vector.<Number> ) : void
        {
            _tintColor[ 0 ] = value[ 0 ];
            _tintColor[ 1 ] = value[ 1 ];
            _tintColor[ 2 ] = value[ 2 ];
            _tintColor[ 3 ] = value[ 3 ];
        }

        public function set maskColor ( value : Vector.<Number> ) : void
        {
            _maskColor[ 0 ] = value[ 0 ] * value[ 3 ];
            _maskColor[ 1 ] = value[ 1 ] * value[ 3 ];
            _maskColor[ 2 ] = value[ 2 ] * value[ 3 ];
            _maskColor[ 3 ] = 1.0 - value[ 3 ];
        }

        public function get lightColor () : Vector.<Number> { return _lightColor; }

        public function set lightColor ( value : Vector.<Number> ) : void
        {
            for ( var i : int = 0; i < 4; ++i )
            {
                _lightColor[ i ] = value[ i ];
            }
        }

        public function setLightColorAndContrast ( r : Number, g : Number, b : Number, alpha : Number, contrast : Number ) : void
        {
            _lightColor[ 0 ] = r;
            _lightColor[ 1 ] = g;
            _lightColor[ 2 ] = b;
            _lightColor[ 3 ] = alpha;
            this.contrast = contrast;
        }

        public function get lightContrast () : Vector.<Number> { return _lightContrast; }

        public function set contrast ( value : Number ) : void
        {
            if ( 1.0 < value )
                value = 1.0;
            else if ( value < -1.0 )
                value = -1.0;

            _lightContrast[ 1 ] = value;
            _lightContrast[ 2 ] = _lightContrast[ 1 ] + 1.0;
            _lightContrast[ 3 ] = 0.2;
        }

        public function get sink () : Boolean
        {
            return _sink;
        }

        public function set sink ( value : Boolean ) : void
        {
            if ( _sink != value )
            {
                _sink = value;
            }
        }

        public function set sinkHeight ( value : Number ) : void
        {
            _sinkParam[ 0 ] = value;
        }

        public function equal ( other : IMaterial ) : Boolean
        {
            if ( other == null ) return false;
            var otherAlias : MSkeleton = other as MSkeleton;
            if ( otherAlias == null )
                return false;

            if ( !super.innerEqual ( otherAlias ) )
                return false;

            if ( _sink != otherAlias._sink
                    || _parentAlpha != otherAlias._parentAlpha
                    || _selfAlpha != otherAlias._selfAlpha )
            {
                return false;
            }

            if ( _sinkParam[ 0 ] != otherAlias._sinkParam[ 0 ] )
                return false;

            if ( _lightContrast[ 1 ] != otherAlias._lightContrast[ 1 ] )
                return false;

            for ( var i : int = 0; i < 4; ++i )
            {
                if ( _tintColor[ i ] != otherAlias._tintColor[ i ] )
                {
                    return false;
                }

                if ( _maskColor[ i ] != otherAlias._maskColor[ i ] )
                {
                    return false
                }

                if ( _lightColor[ i ] != otherAlias._lightColor[ i ] )
                {
                    return false;
                }
            }
            return true;
        }
    }
}