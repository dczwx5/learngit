/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by David on 2016/10/12.
 */
package QFLib.QEngine.Renderer.Material.Passes
{
    import QFLib.QEngine.Renderer.Material.IPass;
    import QFLib.QEngine.Renderer.Material.Shaders.FAdvColorModify;
    import QFLib.QEngine.Renderer.Material.Shaders.FBase;
    import QFLib.QEngine.Renderer.Material.Shaders.VColorTC;
    import QFLib.QEngine.Renderer.Textures.Texture;

    import flash.display3D.Context3DBlendFactor;

    public class PAdvColorModify extends PassBase implements IPass
    {
        public static const sName : String = "PAdvColorModify";

        //for rgb - gray
        private static const sRGBToGray : Vector.<Number> = Vector.<Number>( [ 299, 587, 114, 0.001 ] );

        //gray level(255)/a const val(1.0)/alpha bias(0.1)
        private static const sConstVal : Vector.<Number> = Vector.<Number>( [ 255, 1.0, 0.2, 0.0 ] );

        public function PAdvColorModify()
        {
            super();

            _passName = sName;

            registerVector( "rgbToGray", sRGBToGray );
            registerVector( "constVal", sConstVal );

            registerVector( "fadeStartColor", _fadeStartColor );
            registerVector( "fadeMidColor1", _fadeMidColor1 );
            registerVector( "fadeMidColor2", _fadeMidColor2 );
            registerVector( "fadeEndColor", _fadeEndColor );
            registerVector( "thresoldAndSum", _thresoldAndFadeSum );

            _blendMode = "custom";
        }

        private var _fadeStartColor : Vector.<Number> = new Vector.<Number>( 4 );
        private var _fadeMidColor1 : Vector.<Number> = new Vector.<Number>( 4 );
        private var _fadeMidColor2 : Vector.<Number> = new Vector.<Number>( 4 );
        private var _fadeEndColor : Vector.<Number> = new Vector.<Number>( 4 );
        private var _thresoldAndFadeSum : Vector.<Number> = new Vector.<Number>( 4 );

        public override function get vertexShader() : String
        {
            return VColorTC.Name;
        }

        public override function get fragmentShader() : String
        {
            return FAdvColorModify.Name;
        }

        override public function set texture( value : Texture ) : void
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
            return Context3DBlendFactor.ZERO;
        }

        //set fade color start/mid/end

        public override function equal( other : IPass ) : Boolean
        {
            var otherAlias : PAdvColorModify = other as PAdvColorModify;
            if( otherAlias == null ) return false;

            if( super.innerEqual( otherAlias ) )
            {
                for( var i : int = 0; i < 4; ++i )
                {
                    if( _fadeStartColor[ i ] != otherAlias._fadeStartColor[ i ] ) return false;
                    if( _fadeMidColor1[ i ] != otherAlias._fadeMidColor1[ i ] ) return false;
                    if( _fadeMidColor2[ i ] != otherAlias._fadeMidColor2[ i ] ) return false;
                    if( _fadeEndColor[ i ] != otherAlias._fadeEndColor[ i ] ) return false;

                    if( _thresoldAndFadeSum[ i ] != otherAlias._thresoldAndFadeSum[ i ] ) return false;
                }
            }
            else
            {
                return false;
            }

            return true;
        }

        public override function copy( other : IPass ) : void
        {
            var otherAlias : PAdvColorModify = other as PAdvColorModify;
            if( otherAlias == null ) return;

            super.innerCopyFrom( otherAlias );

            for( var i : int = 0; i < 4; ++i )
            {
                _fadeStartColor[ i ] = otherAlias._fadeStartColor[ i ];
                _fadeMidColor1[ i ] = otherAlias._fadeMidColor1[ i ];
                _fadeMidColor2[ i ] = otherAlias._fadeMidColor2[ i ];
                _fadeEndColor[ i ] = otherAlias._fadeEndColor[ i ];

                _thresoldAndFadeSum[ i ] = otherAlias._thresoldAndFadeSum[ i ];
            }
        }

        public override function clone() : IPass
        {
            var clonePass : PAdvColorModify = new PAdvColorModify();
            clonePass.copy( this );

            return clonePass;
        }

        public function setFadeStartColor( value : Vector.<Number> ) : void
        {
            for( var i : int = 0; i < 4; ++i )
            {
                _fadeStartColor[ i ] = value[ i ];
            }
        }

        //set thresold start/mid/end and fadeSum

        public function setFadeMidColor1( value : Vector.<Number> ) : void
        {
            for( var i : int = 0; i < 4; ++i )
            {
                _fadeMidColor1[ i ] = value[ i ];
            }
        }

        public function setFadeMidColor2( value : Vector.<Number> ) : void
        {
            for( var i : int = 0; i < 4; ++i )
            {
                _fadeMidColor2[ i ] = value[ i ];
            }
        }

        public function setFadeEndColor( value : Vector.<Number> ) : void
        {
            for( var i : int = 0; i < 4; ++i )
            {
                _fadeEndColor[ i ] = value[ i ];
            }
        }

        public function setThresold( value : Vector.<Number> ) : void
        {
            for( var i : int = 0; i < 4; ++i )
            {
                _thresoldAndFadeSum[ i ] = value[ i ];
            }
        }
    }
}
