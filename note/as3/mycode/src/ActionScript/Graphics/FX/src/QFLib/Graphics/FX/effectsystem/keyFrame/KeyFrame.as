package QFLib.Graphics.FX.effectsystem.keyFrame
{
    import QFLib.Graphics.FX.utils.ColorArgb;
    import QFLib.Math.CVector2;

    public class KeyFrame
    {
        private static const _sHelperSize : CVector2 = new CVector2 ( 100, 100 );

        private var _colorKeys : Vector.<ColorKey>;
        private var _sizeKeys : Vector.<SizeKey>;

        public function KeyFrame ()
        {
            _colorKeys = new Vector.<ColorKey> ();
            _sizeKeys = new Vector.<SizeKey> ();
        }

        public function clear () : void
        {
            _colorKeys.fixed = false;
            _colorKeys.length = 0;
            _colorKeys.fixed = true;

            _sizeKeys.fixed = false;
            _sizeKeys.length = 0;
            _sizeKeys.fixed = true;
        }

        public function addColorKey ( time : Number, color : ColorArgb ) : void
        {
            var i : int = 0;
            var n : int = _colorKeys.length;
            for ( ; i < n; i++ )
            {
                if ( _colorKeys[ i ].time > time )
                    break;
            }

            var k : ColorKey = new ColorKey ();

            k.time = time;
            k.color.copyFrom ( color );

            _colorKeys.fixed = false;
            if ( i == n )
                _colorKeys[ _colorKeys.length ] = k;
            else
                _colorKeys.splice ( i, 0, k );

            _colorKeys.fixed = true;
        }

        public function addSizeKey ( time : Number, size : CVector2 ) : void
        {
            var i : int = 0;
            var n : int = _sizeKeys.length;
            for ( ; i < n; i++ )
            {
                if ( _sizeKeys[ i ].time > time )
                    break;
            }

            var k : SizeKey = new SizeKey ();

            k.time = time;
            k.size.set ( size );

            _sizeKeys.fixed = false;
            if ( i == n )
                _sizeKeys[ _sizeKeys.length ] = k;
            else
                _sizeKeys.splice ( i, 0, k );

            _sizeKeys.fixed = true;
        }

        public function getColor ( time : Number ) : uint
        {
            if ( _colorKeys.length == 0 )
                return 0xFFFFFFFF;

            var len : int = _colorKeys.length;
            for ( var i : int = 0, n : int = len; i < n; ++i )
            {
                if ( _colorKeys[ i ].time < time )
                    continue;

                if ( i == 0 )
                    return _colorKeys[ 0 ].color.rgba;
                else
                {
                    var colorKey : ColorKey = _colorKeys[ i - 1 ];
                    var colorKeyNext : ColorKey = _colorKeys[ i ];
                    var f : Number = (time - colorKey.time) / (colorKeyNext.time - colorKey.time);
                    return ColorArgb.lerp ( colorKey.color, colorKeyNext.color, f );
                }
            }

            return _colorKeys[ len - 1 ].color.rgba;
        }

        public function getSize ( time : Number ) : CVector2
        {
            var len : int = _sizeKeys.length;
            if ( len == 0 )
                return _sHelperSize;

            for ( var i : int = 0, n : int = len; i < n; ++i )
            {
                if ( _sizeKeys[ i ].time < time )
                    continue;

                if ( i == 0 )
                    return _sizeKeys[ 0 ].size;
                else
                {
                    var sizeKey : SizeKey = _sizeKeys[ i - 1 ];
                    var sizeKeyNext : SizeKey = _sizeKeys[ i ];
                    var f : Number = (time - sizeKey.time) / (sizeKeyNext.time - sizeKey.time);
                    return CVector2.lerp ( sizeKey.size, sizeKeyNext.size, f );
                }
            }
            return _sizeKeys[ len - 1 ].size;
        }

        public function loadFromObject ( data : Object ) : void
        {
            var i : int = 0;
            var n : int = 0;

            if ( data.hasOwnProperty ( "colorKeys" ) )
            {
                var colorKeyArray : Array = data.colorKeys;
                _colorKeys.fixed = false;
                _colorKeys.length = 0;
                for ( i = 0, n = colorKeyArray.length; i < n; ++i )
                {
                    var ckey : ColorKey = new ColorKey ();

                    ckey.time = colorKeyArray[ i ].time;
                    ckey.color.r = Math.min ( uint ( colorKeyArray[ i ].color.r * 255 ), 255 );
                    ckey.color.g = Math.min ( uint ( colorKeyArray[ i ].color.g * 255 ), 255 );
                    ckey.color.b = Math.min ( uint ( colorKeyArray[ i ].color.b * 255 ), 255 );
                    ckey.color.a = Math.min ( uint ( colorKeyArray[ i ].color.a * 255 ), 255 );

                    _colorKeys[ _colorKeys.length ] = ckey;
                }
                _colorKeys.fixed = true;
            }

            if ( data.hasOwnProperty ( "sizeKeys" ) )
            {
                var sizeKeyArray : Array = data.sizeKeys;

                _sizeKeys.fixed = false;
                _sizeKeys.length = 0;
                for ( i = 0, n = sizeKeyArray.length; i < n; ++i )
                {
                    var skey : SizeKey = new SizeKey ();

                    skey.time = sizeKeyArray[ i ].time;
                    skey.size.x = sizeKeyArray[ i ].size.x;
                    skey.size.y = sizeKeyArray[ i ].size.y;

                    _sizeKeys[ _sizeKeys.length ] = skey;
                }
                _sizeKeys.fixed = true;
            }
        }

        public function dispose () : void
        {
            _colorKeys.fixed = false;
            _colorKeys.length = 0;
            _colorKeys = null;

            _sizeKeys.fixed = false;
            _sizeKeys.length = 0;
            _sizeKeys = null;
        }
    }
}
