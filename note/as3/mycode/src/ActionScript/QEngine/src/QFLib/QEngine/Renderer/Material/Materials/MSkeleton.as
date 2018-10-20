/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Material.Materials
{
    import QFLib.QEngine.Renderer.Material.IMaterial;
    import QFLib.QEngine.Renderer.Material.Passes.PSkeletonSink;
    import QFLib.QEngine.Renderer.Textures.Texture;

    public class MSkeleton extends MaterialBase implements IMaterial
    {
        public static var _singleton : MSkeleton = new MSkeleton();

        public function MSkeleton()
        {
            super( 1 );

            for( var i : int = 0; i < 4; ++i )
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

            var passSink : PSkeletonSink = new PSkeletonSink();
            _inactivePasses.add( PSkeletonSink.sName, passSink );
            passSink.tintColor = _tintColor;
            passSink.maskColor = _maskColor;
            passSink.lightColor = _lightColor;
            passSink.lightContrast = _lightContrast;
            passSink.sinkParam = _sinkParam;

            _passes[ 0 ] = passSink;
            _orignalPass = passSink;
        }
        private var _tintColor : Vector.<Number> = new Vector.<Number>( 4 );
        private var _maskColor : Vector.<Number> = new Vector.<Number>( 4 );
        private var _sinkParam : Vector.<Number> = new Vector.<Number>( 4 );

        public override function set texture( value : Texture ) : void
        {
            if( _texture != value )
            {
                _texture = value;

                _passes[ 0 ].texture = value;
            }
        }

        public override function set pma( value : Boolean ) : void
        {
            _passes[ 0 ].pma = value;
            _premultiplyAlpha = value;
        }

        private var _lightColor : Vector.<Number> = new Vector.<Number>( 4 );

        public function get lightColor() : Vector.<Number>
        {
            return _lightColor;
        }

        public function set lightColor( value : Vector.<Number> ) : void
        {
            for( var i : int = 0; i < 4; ++i )
            {
                _lightColor[ i ] = value[ i ];
            }
        }

        private var _lightContrast : Vector.<Number> = new Vector.<Number>( 4 );

        public function get lightContrast() : Vector.<Number>
        {
            return _lightContrast;
        }

        private var _sink : Boolean = false;

        public function get sink() : Boolean
        {
            return _sink;
        }

        public function set sink( value : Boolean ) : void
        {
            if( _sink != value )
            {
                _sink = value;
            }
        }

        private var _masking : Boolean = false;

        public function set masking( value : Boolean ) : void
        {
            _masking = value;
            if( !_masking )
            {
                _maskColor[ 0 ] = _maskColor[ 1 ] = _maskColor[ 2 ] = 0.0;
                _maskColor[ 3 ] = 1.0;
            }
        }

        public function set blendMode( value : String ) : void
        {
            _passes[ 0 ].blendMode = value;
        }

        public function set tintColorAndAlpha( value : Vector.<Number> ) : void
        {
            if( _masking )
            {
                _maskColor[ 0 ] = value[ 0 ] * value[ 3 ];
                _maskColor[ 1 ] = value[ 1 ] * value[ 3 ];
                _maskColor[ 2 ] = value[ 2 ] * value[ 3 ];
                _maskColor[ 3 ] = 1.0 - value[ 3 ];
                _tintColor[ 0 ] = _tintColor[ 1 ] = _tintColor[ 2 ] = _tintColor[ 3 ] = 1.0;
            }
            else
            {
                _maskColor[ 0 ] = _maskColor[ 1 ] = _maskColor[ 2 ] = 0;
                _maskColor[ 3 ] = 1.0;
                _tintColor[ 0 ] = value[ 0 ];
                _tintColor[ 1 ] = value[ 1 ];
                _tintColor[ 2 ] = value[ 2 ];
                _tintColor[ 3 ] = value[ 3 ];
            }
        }

        public function set contrast( value : Number ) : void
        {
            if( value < 0 )
            {
                value *= 1.2;
            }
            if( 1.0 < value )
                value = 1.0;
            else if( value < -1.0 )
                value = -1.0;

            _lightContrast[ 1 ] = value;
            _lightContrast[ 2 ] = _lightContrast[ 1 ] + 1.0;
            _lightContrast[ 3 ] = 1.0;
        }

        public function set sinkHeight( value : Number ) : void
        {
            _sinkParam[ 0 ] = value;
        }

        public override function dispose() : void
        {
            if( _tintColor )
            {
                _tintColor.length = 0;
                _tintColor = null;
            }

            if( _maskColor )
            {
                _maskColor.length = 0;
                _maskColor = null;
            }

            if( _lightColor )
            {
                _lightColor.length = 0;
                _lightColor = null;
            }

            if( _lightContrast )
            {
                _lightContrast.length = 0;
                _lightContrast = null;
            }

            if( _sinkParam )
            {
                _sinkParam.length = 0;
                _sinkParam = null;
            }

            super.dispose();
        }

        override public function clone() : IMaterial
        {
            var newMat : MSkeleton = new MSkeleton();
            newMat.copy( this );
            return newMat;
        }

        public function equal( other : IMaterial ) : Boolean
        {
            var otherAlias : MSkeleton = other as MSkeleton;
            if( otherAlias == null )
            {
                return false;
            }

            if( !super.innerEqual( otherAlias ) )
                return false;

            if( _sink != otherAlias._sink
                    || _parentAlpha != otherAlias._parentAlpha
                    || _selfAlpha != otherAlias._selfAlpha
                    || _passes[ 0 ].blendMode != otherAlias._passes[ 0 ].blendMode
                    || _passes[ 0 ].pma != otherAlias._passes[ 0 ].pma )
            {
                return false;
            }

            if( _sinkParam[ 0 ] != otherAlias._sinkParam[ 0 ] )
                return false;

            if( _lightContrast[ 1 ] != otherAlias._lightContrast[ 1 ] )
                return false;

            for( var i : int = 0; i < 4; ++i )
            {
                if( _tintColor[ i ] != otherAlias._tintColor[ i ] )
                {
                    return false;
                }

                if( _maskColor[ i ] != otherAlias._maskColor[ i ] )
                {
                    return false
                }

                if( _lightColor[ i ] != otherAlias._lightColor[ i ] )
                {
                    return false;
                }
            }
            return true;
        }

        public function copy( other : MSkeleton ) : void
        {
            super.innerCopyFrom( other );

            blendMode = other.passes[ 0 ].blendMode;
            pma = other.passes[ 0 ].pma;

            for( var i : int = 0; i < 4; ++i )
            {
                _tintColor[ i ] = other._tintColor[ i ];
                _maskColor[ i ] = other._maskColor[ i ];
                _lightColor[ i ] = other._lightColor[ i ];
                _lightContrast[ i ] = other._lightContrast[ i ];
                _sinkParam[ i ] = other._sinkParam[ i ];
            }

            _sink = other._sink;
            _passes[ 0 ].texture = other._texture;
        }

        public function copySingleton() : IMaterial
        {
            _singleton.copy( this );
            return _singleton;
        }
    }
}