/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved
 * Created by Again on 2017/1/4.
 */
package QFLib.QEngine.Renderer.Material.Passes
{
    import QFLib.QEngine.Renderer.Material.IPass;
    import QFLib.QEngine.Renderer.Material.Shaders.FBase;
    import QFLib.QEngine.Renderer.Material.Shaders.FFilterDisplacementMap;
    import QFLib.QEngine.Renderer.Material.Shaders.VTintTC;
    import QFLib.QEngine.Renderer.Textures.Texture;

    import flash.display3D.Context3DBlendFactor;

    public class PFilterDisplacementMap extends PassBase implements IPass
    {
        public static const sName : String = "PFilterDisplacementMap";
        //first two number is distance to border for smooth, and follow two number is unused.
        private static const sSmoothBorder : Vector.<Number> = Vector.<Number>( [ 0.1, 0.1, 1.0, 1.0 ] );
        //const variable: x:0.5, y:2, z:1, w:0.
        private static const sConstVal : Vector.<Number> = Vector.<Number>( [ 0.5, 2.0, 1.0, 0.0 ] );

        public function PFilterDisplacementMap()
        {
            super();
            _passName = sName;

            _currentTime[ 0 ] = 0;
            _currentTime[ 1 ] = 0;
            _currentTime[ 2 ] = 0;
            _currentTime[ 3 ] = 0;
            registerVector( FFilterDisplacementMap.otherConstVal, sConstVal );
            registerVector( FFilterDisplacementMap.smoothBorder, sSmoothBorder );
            registerVector( "color", _tintColor );
            registerVector( FFilterDisplacementMap.currentTime, _currentTime );
            registerVector( FFilterDisplacementMap.intensityAndScrolling, _intensityAndScrolling );
            registerVector( FFilterDisplacementMap.maskRect, _maskRect );

            setTexture( FFilterDisplacementMap.displacementMapTexture, _displacementMapTex );
        }

        private var _tintColor : Vector.<Number> = new Vector.<Number>( 4 );
        private var _currentTime : Vector.<Number> = new Vector.<Number>( 4 );
        private var _displacementMapTex : Texture = null;
        private var _intensityAndScrolling : Vector.<Number> = new Vector.<Number>( 4 );
        private var _maskRect : Vector.<Number> = new Vector.<Number>( 4 );

        public override function get vertexShader() : String
        {
            return VTintTC.Name;
        }

        public override function get fragmentShader() : String
        {
            return FFilterDisplacementMap.Name;
        }

        public override function set texture( value : Texture ) : void
        {
            if( value != null )
            {
                setTexture( FBase.mainTexture, value );
            }
        }

        public override function get srcOp() : String
        {
            return Context3DBlendFactor.SOURCE_ALPHA;
        }

        public override function get dstOp() : String
        {
            return Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
            ;
        }

        public override function equal( other : IPass ) : Boolean
        {
            var otherAlias : PFilterDisplacementMap = other as PFilterDisplacementMap;
            if( otherAlias == null ) return false;

            if( super.innerEqual( otherAlias ) )
            {
                for( var i : int = 0; i < 4; ++i )
                {
                    if( _tintColor[ i ] != otherAlias._tintColor[ i ] ) return false;
                    if( _currentTime[ i ] != otherAlias._currentTime[ i ] ) return false;
                    if( _intensityAndScrolling[ i ] != otherAlias._intensityAndScrolling[ i ] ) return false;
                    if( _maskRect[ i ] != otherAlias._maskRect[ i ] ) return false;
                }

                if( _displacementMapTex && otherAlias._displacementMapTex )
                {
                    if( _displacementMapTex.base != otherAlias._displacementMapTex.base )
                        return false;
                }
                else if( _displacementMapTex || otherAlias._displacementMapTex )
                {
                    return false;
                }
            }

            return true;
        }

        public override function copy( other : IPass ) : void
        {
            super.copy( other );
            var otherAlias : PFilterDisplacementMap = other as PFilterDisplacementMap;
            if( otherAlias == null ) return;

            for( var i : int = 0; i < 4; ++i )
            {
                _tintColor[ i ] = otherAlias._tintColor[ i ];
                _currentTime[ i ] = otherAlias._currentTime[ i ];
                _intensityAndScrolling[ i ] = otherAlias._intensityAndScrolling[ i ];
                _maskRect[ i ] != otherAlias._maskRect[ i ];
            }
            registerVector( "color", _tintColor );
            registerVector( FFilterDisplacementMap.currentTime, _currentTime );
            registerVector( FFilterDisplacementMap.intensityAndScrolling, _intensityAndScrolling );
            registerVector( FFilterDisplacementMap.maskRect, _maskRect );
            setDisplacementMapTexture( otherAlias._displacementMapTex );

            if( otherAlias.getTexture( FBase.mainTexture ) )
                setTexture( FBase.mainTexture, otherAlias.getTexture( FBase.mainTexture ) );
        }

        public override function clone() : IPass
        {
            var clonePass : PFilterDisplacementMap = new PFilterDisplacementMap();
            clonePass.copy( this );
            return clonePass;
        }

        public function setTintColor( value : Vector.<Number> ) : void
        {
            for( var i : int = 0; i < 4; ++i )
            {
                _tintColor[ i ] = value[ i ];
            }

            registerVector( "color", value );
        }

        public function setCurrentTime( value : Number ) : void
        {
            _currentTime[ 0 ] = value;
            registerVector( FFilterDisplacementMap.currentTime, _currentTime );
        }

        public function setDisplacementMapTexture( tex : Texture ) : void
        {
            _displacementMapTex = tex;
            setTexture( FFilterDisplacementMap.displacementMapTexture, tex );
        }

        public function setIntensityAndScrolling( value : Vector.<Number> ) : void
        {
            for( var i : int = 0; i < 4; ++i )
            {
                _intensityAndScrolling[ i ] = value[ i ];
            }
            registerVector( FFilterDisplacementMap.intensityAndScrolling, _intensityAndScrolling );
        }

        public function setMaskRect( value : Vector.<Number> ) : void
        {
            for( var i : int = 0; i < 4; ++i )
            {
                _maskRect[ i ] = value[ i ];
            }
            registerVector( FFilterDisplacementMap.maskRect, _maskRect );
        }

    }
}
