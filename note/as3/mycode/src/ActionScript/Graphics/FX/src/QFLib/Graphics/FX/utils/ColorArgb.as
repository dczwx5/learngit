package QFLib.Graphics.FX.utils
{
    public class ColorArgb
    {
        private static var _lerpHelper : ColorArgb = new ColorArgb ();
        public var r : uint;
        public var g : uint;
        public var b : uint;
        public var a : uint;

        public static function fromRgb ( color : uint ) : ColorArgb
        {
            var rgb : ColorArgb = new ColorArgb ();
            rgb.fromRgb ( color );
            return rgb;
        }

        public static function fromArgb ( color : uint ) : ColorArgb
        {
            var argb : ColorArgb = new ColorArgb ();
            argb.fromArgb ( color );
            return argb;
        }

        public static function fromRgba ( color : uint ) : ColorArgb
        {
            var argb : ColorArgb = new ColorArgb ();
            argb.fromRgba ( color );
            return argb;
        }

        public static function fromAbgr ( color : uint ) : ColorArgb
        {
            var argb : ColorArgb = new ColorArgb ();
            argb.fromAbgr ( color );
            return argb;
        }

        [Inline]
        public static function lerp ( a : ColorArgb, b : ColorArgb, f : Number ) : uint
        {
            return lerpColorRaw ( _lerpHelper, a, b, f ).rgba;
        }

        [Inline]
        public static function lerpColor ( a : ColorArgb, b : ColorArgb, f : Number ) : ColorArgb
        {
            var newColor : ColorArgb = new ColorArgb ();
            return lerpColorRaw ( newColor, a, b, f );
        }

        [Inline]
        private static function lerpColorRaw ( color : ColorArgb, a : ColorArgb, b : ColorArgb, f : Number ) : ColorArgb
        {
            var invF : Number = 1.0 - f;
            color.r = a.r * invF + b.r * f;
            color.g = a.g * invF + b.g * f;
            color.b = a.b * invF + b.b * f;
            color.a = a.a * invF + b.a * f;
            return color;
        }

        public function ColorArgb ( red : uint = 0, green : uint = 0, blue : uint = 0, alpha : uint = 0 )
        {
            this.r = red;
            this.g = green;
            this.b = blue;
            this.a = alpha;
        }

        [Inline]
        public final function get noneZero () : Boolean
        {
            return (r != 0 || g != 0 || b != 0 || a != 0);
        }

        [Inline]
        public final function get rgb () : uint
        {
            return (r) << 16 | (g) << 8 | (b);
        }

        [Inline]
        public final function get rgba () : uint
        {
            return (r) << 24 | (g) << 16 | (b) << 8 | a;
        }

        [Inline]
        public final function get abgr () : uint
        {
            return (a) << 24 | (b) << 16 | (g) << 8 | r;
        }

        [Inline]
        public final function get argb () : uint
        {
            return (a) << 24 | (r) << 16 | (g) << 8 | (b);
        }

        [Inline]
        public final function clone () : ColorArgb
        {
            var c : ColorArgb = new ColorArgb ();
            c.copyFrom ( this );
            return c;
        }

        [Inline]
        public final function fromRgb ( color : uint ) : void
        {
            r = (color >> 16 & 0xFF);
            g = (color >> 8 & 0xFF);
            b = (color & 0xFF);
        }

        [Inline]
        public final function fromArgb ( color : uint ) : void
        {
            r = (color >> 16 & 0xFF);
            g = (color >> 8 & 0xFF);
            b = (color & 0xFF);
            a = (color >> 24 & 0xFF);
        }

        [Inline]
        public final function fromRgba ( color : uint ) : void
        {
            r = (color >> 24 & 0xFF);
            g = (color >> 16 & 0xFF);
            b = (color >> 8 & 0xFF);
            a = (color & 0xFF);
        }

        [Inline]
        public final function fromAbgr ( color : uint ) : void
        {
            r = (color & 0xFF);
            g = (color >> 8 & 0xFF);
            b = (color >> 16 & 0xFF);
            a = (color >> 24 & 0xFF);
        }

        [Inline]
        public final function copyFrom ( argb : ColorArgb ) : ColorArgb
        {
            r = argb.r;
            g = argb.g;
            b = argb.b;
            a = argb.a;
            return this;
        }
    }
}