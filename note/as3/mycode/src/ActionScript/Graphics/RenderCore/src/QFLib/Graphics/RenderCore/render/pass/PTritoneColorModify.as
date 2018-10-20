////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

/**
 * Created by david on 2016/12/20.
 */
package QFLib.Graphics.RenderCore.render.pass
{
    import QFLib.Graphics.RenderCore.render.IPass;
    import QFLib.Graphics.RenderCore.render.shader.FTritoneColor;
    import QFLib.Graphics.RenderCore.render.shader.VColorTC;

    import flash.display3D.Context3DBlendFactor;

    public class PTritoneColorModify extends PassBase implements IPass
    {
        public static const sName : String = "PTritoneColorModify";

        private static const sConstVal : Vector.<Number> = Vector.<Number> ( [ 1, 0.5, 2, 0.2 ] );
        private static const sRGBToGray : Vector.<Number> = Vector.<Number> ( [ 299, 587, 114, 0.001 ] );

        public function PTritoneColorModify ( ...args )
        {
            _passName = sName;

            registerVector ( "rgbToGray", sRGBToGray );
            registerVector ( "constVal", sConstVal );
            registerVector ( "highLightColor", _highLightColor );
            registerVector ( "middleColor", _middleColor );
            registerVector ( "lowKeyColor", _lowKeyColor );
        }

        public override function get vertexShader () : String
        {
            return VColorTC.Name;
        }

        public override function get fragmentShader () : String
        {
            return FTritoneColor.Name;
        }

        public override function get srcOp () : String
        {
            return Context3DBlendFactor.SOURCE_ALPHA;
        }

        public override function get dstOp () : String
        {
            return Context3DBlendFactor.ZERO;
        }

        private var _highLightColor : Vector.<Number> = Vector.<Number> ( [ 1.0, 1.0, 1.0, 1.0 ] );

        public function set highLightColor ( value : Vector.<Number> ) : void
        {
            for ( var i : int = 0; i < 4; ++i )
            {
                _highLightColor[ i ] = value[ i ];
            }
        }

        private var _middleColor : Vector.<Number> = Vector.<Number> ( [ 1.0, 1.0, 0.0, 1.0 ] );

        public function set middleColor ( value : Vector.<Number> ) : void
        {
            for ( var i : int = 0; i < 4; ++i )
            {
                _middleColor[ i ] = value[ i ];
            }
        }

        private var _lowKeyColor : Vector.<Number> = Vector.<Number> ( [ 0.0, 0.0, 0.0, 1.0 ] );

        public function set lowKeyColor ( value : Vector.<Number> ) : void
        {
            for ( var i : int = 0; i < 4; ++i )
            {
                _lowKeyColor[ i ] = value[ i ];
            }
        }

        public override function dispose () : void
        {
            super.dispose ();
        }

        public override function equal ( other : IPass ) : Boolean
        {
            var otherAlias : PTritoneColorModify = other as PTritoneColorModify;
            if ( otherAlias == null ) return false;

            if ( super.innerEqual ( otherAlias ) )
            {
                for ( var i : int = 0; i < 4; ++i )
                {
                    if ( _highLightColor[ i ] != otherAlias._highLightColor[ i ] ) return false;
                    if ( _middleColor[ i ] != otherAlias._middleColor[ i ] ) return false;
                    if ( _lowKeyColor[ i ] != otherAlias._lowKeyColor[ i ] ) return false;
                }
            }
            else
            {
                return false;
            }

            return true;
        }

        public override function copy ( other : IPass ) : void
        {
            var otherAlias : PTritoneColorModify = other as PTritoneColorModify;
            if ( otherAlias == null ) return;

            super.innerCopyFrom ( otherAlias );

            for ( var i : int = 0; i < 4; ++i )
            {
                _highLightColor[ i ] = otherAlias._highLightColor[ i ];
                _middleColor[ i ] = otherAlias._middleColor[ i ];
                _lowKeyColor[ i ] = otherAlias._lowKeyColor[ i ];
            }
        }

        public override function clone () : IPass
        {
            var clonePass : PTritoneColorModify = new PTritoneColorModify ();
            clonePass.copy ( this );

            return clonePass;
        }
    }
}
