//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/5/19
//----------------------------------------------------------------------------------------------------------------------

package QFLib.Math
{

    public class CVector4
    {
        public static const ZERO : CVector4 = new CVector4( 0.0, 0.0, 0.0, 0.0 );
        public static const ONE : CVector4 = new CVector4( 1.0, 1.0, 1.0, 1.0 );
        public static const X_AXIS : CVector4 = new CVector4( 1.0, 0.0, 0.0, 0.0 );
        public static const Y_AXIS : CVector4 = new CVector4( 0.0, 1.0, 0.0, 0.0 );
        public static const Z_AXIS : CVector4 = new CVector4( 0.0, 0.0, 1.0, 0.0 );
        public static const NEGATIVE_X_AXIS : CVector4 = new CVector4( -1.0, 0.0, 0.0, 0.0 );
        public static const NEGATIVE_Y_AXIS : CVector4 = new CVector4( 0.0, -1.0, 0.0, 0.0 );
        public static const NEGATIVE_Z_AXIS : CVector4 = new CVector4( 0.0, 0.0, -1.0, 0.0 );

        public function CVector4( x : Number = 0.0, y : Number = 0.0, z : Number = 0.0, w : Number = 0.0 )
        {
            this.x = x;
            this.y = y;
            this.z = z;
            this.w = w;
        }

        [Inline]
        final public function clone() : CVector4
        {
            return new CVector4( this.x, this.y, this.z, this.w );
        }

        public function toString() : String
        {
            var s : String = "";
            s += x.toString();
            s += ", ";
            s += y.toString();
            s += ", ";
            s += z.toString();
            s += ", ";
            s += w.toString();
            return s;
        }
        public function toFixed( numFixed : * = 0 ) : String
        {
            var s : String = "";
            s += x.toFixed( numFixed );
            s += ", ";
            s += y.toFixed( numFixed );
            s += ", ";
            s += z.toFixed( numFixed );
            s += ", ";
            s += w.toFixed( numFixed );
            return s;
        }

        public function toArray() : Array
        {
            var aArray : Array = new Array( 4 );
            aArray[ 0 ] = x;
            aArray[ 1 ] = y;
            aArray[ 2 ] = z;
            aArray[ 3 ] = w;
            return aArray;
        }

        [Inline]
        final public function set( v : CVector4 ) : void { this.x = v.x; this.y = v.y; this.z = v.z; this.w = v.w; }
        [Inline]
        final public function setTo( v : CVector4 ) : void { set( v ); }
        [Inline]
        final public function setValueXYZW( x : Number, y : Number, z : Number, w : Number ) : void { this.x = x; this.y = y; this.z = z; this.w = w; }
        [Inline]
        final public function zero() : void { this.x = 0.0; this.y = 0.0; this.z = 0.0; this.w = 0.0; }

        [Inline]
        final public function isZero() : Boolean { if( x != 0.0 || y != 0.0 || z != 0.0 || w != 0.0 ) return false; else return true; }
        [Inline]
        final public function isNearZero() : Boolean
        { 
            if( ( CMath.abs( x ) > CMath.EPSILON ) || ( CMath.abs( y ) > CMath.EPSILON ) || ( CMath.abs( z ) > CMath.EPSILON ) || ( CMath.abs( w ) > CMath.EPSILON ) ) return false;
            else return true; 
        }

        [Inline]
        final public function length() : Number { return CMath.sqrt( x * x + y * y + z * z + w * w ); }
        [Inline]
        final public function lengthSqr() : Number { return x * x + y * y + z * z + w * w; }
        [Inline]
        final public function distance() : Number { return length(); }

        public function normalize( fLen : Number = 0.0 ) : Number
        {  
            if( fLen == 0.0 ) fLen = length();
            if( fLen > CMath.EPSILON )
            {
                x /= fLen; y /= fLen; z /= fLen; w /= fLen;
                return fLen;
            }
            else return 0.0;
        }

        [Inline]
        final public function dot( rhs : CVector4 ) : Number { return ( x * rhs.x ) + ( y * rhs.y ) + ( z * rhs.z ) + ( w * rhs.w ); }

        [Inline]
        final public function add( rhs : CVector4 ) : CVector4 { return new CVector4( this.x + rhs.x, this.y + rhs.y, this.z + rhs.z, this.w + rhs.w ); }
        [Inline]
        final public function addValue( f : Number ) : CVector4 { return new CVector4( this.x + f, this.y + f, this.z + f, this.w + f ); }
        [Inline]
        final public function addValueXYZW( fX : Number, fY : Number, fZ : Number, fW : Number ) : CVector4 { return new CVector4( this.x + fX, this.y + fY, this.z + fZ, this.w + fW ); }
        [Inline]
        final public function sub( rhs : CVector4 ) : CVector4 { return new CVector4( this.x - rhs.x, this.y - rhs.y, this.z - rhs.z, this.w - rhs.w ); }
        [Inline]
        final public function subValue( f : Number ) : CVector4 { return new CVector4( this.x - f, this.y - f, this.z - f, this.w - f ); }
        [Inline]
        final public function subValueXYZW( fX : Number, fY : Number, fZ : Number, fW : Number ) : CVector4 { return new CVector4( this.x - fX, this.y - fY, this.z - fZ, this.w - fW ); }
        [Inline]
        final public function mul( rhs : CVector4 ) : CVector4 { return new CVector4( this.x * rhs.x, this.y * rhs.y, this.z * rhs.z, this.w * rhs.w ); }
        [Inline]
        final public function mulValue( f : Number ) : CVector4 { return new CVector4( this.x * f, this.y * f, this.z * f, this.w * f ); }
        [Inline]
        final public function mulValueXYZW( fX : Number, fY : Number, fZ : Number, fW : Number ) : CVector4 { return new CVector4( this.x * fX, this.y * fY, this.z * fZ, this.w * fW ); }
        [Inline]
        final public function div( rhs : CVector4 ) : CVector4 { return new CVector4( this.x / rhs.x, this.y / rhs.y, this.z / rhs.z, this.w / rhs.w ); }
        [Inline]
        final public function divValue( f : Number ) : CVector4 { return new CVector4( this.x / f, this.y / f, this.z / f, this.w / f ); }
        [Inline]
        final public function divValueXYZW( fX : Number, fY : Number, fZ : Number, fW : Number ) : CVector4 { return new CVector4( this.x / fX, this.y / fY, this.z / fZ, this.w / fW ); }
        [Inline]
        final public function negate() : CVector4 { return new CVector4( -this.x, -this.y, -this.z, -this.w ); }

        [Inline]
        final public function addOn( rhs : CVector4 ) : void { this.x += rhs.x; this.y += rhs.y; this.z += rhs.z; this.w += rhs.w; }
        [Inline]
        final public function addOnValue( f : Number ) : void { this.x += f; this.y += f; this.z += f; this.w += f; }
        [Inline]
        final public function addOnValueXYZW( fX : Number, fY : Number, fZ : Number, fW : Number ) : void { this.x += fX; this.y += fY; this.z += fZ; this.w += fW; }
        [Inline]
        final public function subOn( rhs : CVector4 ) : void { this.x -= rhs.x; this.y -= rhs.y; this.z -= rhs.z; this.w -= rhs.w; }
        [Inline]
        final public function subOnValue( f : Number ) : void { this.x -= f; this.y -= f; this.z -= f; this.w -= f; }
        [Inline]
        final public function subOnValueXYZW( fX : Number, fY : Number, fZ : Number, fW : Number ) : void { this.x -= fX; this.y -= fY; this.z -= fZ; this.w -= fW; }
        [Inline]
        final public function mulOn( rhs : CVector4 ) : void { this.x *= rhs.x; this.y *= rhs.y; this.z *= rhs.z; this.w *= rhs.w; }
        [Inline]
        final public function mulOnValue( f : Number ) : void { this.x *= f; this.y *= f; this.z *= f; this.w *= f; }
        [Inline]
        final public function mulOnValueXYZW( fX : Number, fY : Number, fZ : Number, fW : Number ) : void { this.x *= fX; this.y *= fY; this.z *= fZ; this.w *= fW; }
        [Inline]
        final public function divOn( rhs : CVector4 ) : void { this.x /= rhs.x; this.y /= rhs.y; this.z /= rhs.z; this.w /= rhs.w; }
        [Inline]
        final public function divOnValue( f : Number ) : void { this.x /= f; this.y /= f; this.z /= f; this.w /= f; }
        [Inline]
        final public function divOnValueXYZW( fX : Number, fY : Number, fZ : Number, fW : Number ) : void { this.x /= fX; this.y /= fY; this.z /= fZ; this.w /= fW; }
        [Inline]
        final public function negateOn() : void { this.x = -this.x; this.y = -this.y; this.z = -this.z; this.w = -this.w; }

        [Inline]
        final public function equals( rhs : CVector4 ) : Boolean
        {
            if( x != rhs.x || y != rhs.y || z != rhs.z || w != rhs.w ) return false;
            else return true;
        }
        [Inline]
        final public function equalsValue( fX : Number, fY : Number, fZ : Number, fW : Number ) : Boolean
        {
            if( x != fX || y != fY || z != fZ || w != fW ) return false;
            else return true;
        }

        [Inline]
        final public function equalsWithinError( rhs : CVector4, fError : Number = CMath.EPSILON ) : Boolean
        {
            if( Math.abs( x - rhs.x ) > fError || Math.abs( y - rhs.y ) > fError || Math.abs( w - rhs.w ) > fError ) return false;
            else return true;
        }
        [Inline]
        final public function equalsValueWithinError( fX : Number, fY : Number, fZ : Number, fW : Number, fError : Number = CMath.EPSILON ) : Boolean
        {
            if( Math.abs( x - fX ) > fError || Math.abs( y - fY ) > fError || Math.abs( z - fZ ) > fError || Math.abs( w - fW ) > fError ) return false;
            else return true;
        }

        [Inline]
        final public function dump( aArray : Array ) : void
        {
            aArray[ 0 ] = x;
            aArray[ 1 ] = y;
            aArray[ 2 ] = z;
            aArray[ 2 ] = w;
        }

        [Inline]
        final public function get r() : Number { return x; }
        [Inline]
        final public function get g() : Number { return y; }
        [Inline]
        final public function get b() : Number { return z; }
        [Inline]
        final public function get a() : Number { return w; }
        [Inline]
        final public function set r( value : Number ) : void { x = value; }
        [Inline]
        final public function set g( value : Number ) : void { y = value; }
        [Inline]
        final public function set b( value : Number ) : void { z = value; }
        [Inline]
        final public function set a( value : Number ) : void { w = value; }

        //
        [Inline]
        public static function lerp( vFrom : CVector4, vTo : CVector4, fWeight : Number ) : CVector4
        {
            return new CVector4( vFrom.x * ( 1.0 - fWeight ) + vTo.x * fWeight,
                                   vFrom.y * ( 1.0 - fWeight ) + vTo.y * fWeight,
                                   vFrom.z * ( 1.0 - fWeight ) + vTo.z * fWeight,
                                   vFrom.w * ( 1.0 - fWeight ) + vTo.w * fWeight );
        }

        [Inline]
        public static function zero() : CVector4
        {
            return new CVector4( 0.0, 0.0, 0.0, 0.0 );
        }
        [Inline]
        public static function one() : CVector4
        {
            return new CVector4( 1.0, 1.0, 1.0, 1.0 );
        }

        //
        //
        public var x : Number;
        public var y : Number;
        public var z : Number;
        public var w : Number;
    }

}

