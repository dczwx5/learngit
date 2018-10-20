//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/5/19
//----------------------------------------------------------------------------------------------------------------------

package QFLib.Math
{

    public class CVector3
    {
        public static const ZERO : CVector3 = new CVector3( 0.0, 0.0, 0.0 );
        public static const ONE : CVector3 = new CVector3( 1.0, 1.0, 1.0 );
        public static const X_AXIS : CVector3 = new CVector3( 1.0, 0.0, 0.0 );
        public static const Y_AXIS : CVector3 = new CVector3( 0.0, 1.0, 0.0 );
        public static const Z_AXIS : CVector3 = new CVector3( 0.0, 0.0, 1.0 );
        public static const NEGATIVE_X_AXIS : CVector3 = new CVector3( -1.0, 0.0, 0.0 );
        public static const NEGATIVE_Y_AXIS : CVector3 = new CVector3( 0.0, -1.0, 0.0 );
        public static const NEGATIVE_Z_AXIS : CVector3 = new CVector3( 0.0, 0.0, -1.0 );

        public function CVector3( x : Number = 0.0, y : Number = 0.0, z : Number = 0.0 )
        {
            this.x = x;
            this.y = y;
            this.z = z;
        }

        [Inline]
        final public function clone() : CVector3
        {
            return new CVector3( this.x, this.y, this.z );
        }

        public function toString() : String
        {
            var s : String = "";
            s += x.toString();
            s += ", ";
            s += y.toString();
            s += ", ";
            s += z.toString();
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
            return s;
        }

        public function toArray() : Array
        {
            var aArray : Array = new Array( 3 );
            aArray[ 0 ] = x;
            aArray[ 1 ] = y;
            aArray[ 2 ] = z;
            return aArray;
        }

        [Inline]
        final public function set( v : CVector3 ) : void { this.x = v.x; this.y = v.y; this.z = v.z; }
        [Inline]
        final public function setTo( v : CVector3 ) : void { set( v ); }
        [Inline]
        final public function setValueXYZ( x : Number, y : Number, z : Number ) : void { this.x = x; this.y = y; this.z = z; }
        [Inline]
        final public function zero() : void { this.x = 0.0; this.y = 0.0; this.z = 0.0; }

        [Inline]
        final public function isZero() : Boolean  { if( x != 0.0 || y != 0.0 || z != 0.0 ) return false; else return true; }
        [Inline]
        final public function isNearZero() : Boolean { if( ( CMath.abs( x ) > CMath.EPSILON ) || ( CMath.abs( y ) > CMath.EPSILON ) || ( CMath.abs( z ) > CMath.EPSILON ) ) return false; else return true; }

        [Inline]
        final public function length() : Number { return CMath.sqrt( x * x + y * y + z * z ); }
        [Inline]
        final public function lengthSqr() : Number { return x * x + y * y + z * z; }
        [Inline]
        final public function distance() : Number { return length(); }

        public function normalize( fLen : Number = 0.0 ) : Number
        {  
            if( fLen == 0.0 ) fLen = length();
            if( fLen > CMath.EPSILON )
            {
                x /= fLen; y /= fLen; z /= fLen;
                return fLen;
            }
            else return 0.0;
        }

        public function cross( rhs : CVector3 ) : CVector3
        {
            var fX : Number = this.y * rhs.z - this.z * rhs.y;
            var fY : Number = this.z * rhs.x - this.x * rhs.z;
            var fZ : Number = this.x * rhs.y - this.y * rhs.x;

            return new CVector3( fX, fY, fZ );
        }
        public function crossProduct( rhs : CVector3, result : CVector3 ) : void
        {
            var fX : Number = this.y * rhs.z - this.z * rhs.y;
            var fY : Number = this.z * rhs.x - this.x * rhs.z;
            var fZ : Number = this.x * rhs.y - this.y * rhs.x;

            result.x = fX;
            result.y = fY;
            result.z = fZ;
        }

        [Inline]
        final public function dot( rhs : CVector3 ) : Number { return ( x * rhs.x ) + ( y * rhs.y ) + ( z * rhs.z ); }

        public function angleRad( rhs : CVector3 ) : Number
        { 
            var f : Number = this.length() * rhs.length();
            if( f == 0.0 ) return 0.0;

            f = CMath.acosRad( this.dot( rhs ) / f );
            return ( f >= 0.0 ? f : ( f + CMath.PI ) );
        }

        [Inline]
        final public function angleDeg( rhs : CVector3 ) : Number { return CMath.radToDeg( angleRad( rhs ) ); }

        [Inline]
        final public function add( rhs : CVector3 ) : CVector3 { return new CVector3( this.x + rhs.x, this.y + rhs.y, this.z + rhs.z ); }
        [Inline]
        final public function addValue( f : Number ) : CVector3 { return new CVector3( this.x + f, this.y + f, this.z + f ); }
        [Inline]
        final public function addValueXYZ( fX : Number, fY : Number, fZ : Number ) : CVector3 { return new CVector3( this.x + fX, this.y + fY, this.z + fZ ); }
        [Inline]
        final public function sub( rhs : CVector3 ) : CVector3 { return new CVector3( this.x - rhs.x, this.y - rhs.y, this.z - rhs.z ); }
        [Inline]
        final public function subValue( f : Number ) : CVector3 { return new CVector3( this.x - f, this.y - f, this.z - f ); }
        [Inline]
        final public function subValueXYZ( fX : Number, fY : Number, fZ : Number ) : CVector3 { return new CVector3( this.x - fX, this.y - fY, this.z - fZ ); }
        [Inline]
        final public function mul( rhs : CVector3 ) : CVector3 { return new CVector3( this.x * rhs.x, this.y * rhs.y, this.z * rhs.z ); }
        [Inline]
        final public function mulValue( f : Number ) : CVector3 { return new CVector3( this.x * f, this.y * f, this.z * f ); }
        [Inline]
        final public function mulValueXYZ( fX : Number, fY : Number, fZ : Number ) : CVector3 { return new CVector3( this.x * fX, this.y * fY, this.z * fZ ); }
        [Inline]
        final public function div( rhs : CVector3 ) : CVector3 { return new CVector3( this.x / rhs.x, this.y / rhs.y, this.z / rhs.z ); }
        [Inline]
        final public function divValue( f : Number ) : CVector3 { return new CVector3( this.x / f, this.y / f, this.z / f ); }
        [Inline]
        final public function divValueXYZ( fX : Number, fY : Number, fZ : Number ) : CVector3 { return new CVector3( this.x / fX, this.y / fY, this.z / fZ ); }
        [Inline]
        final public function negate() : CVector3 { return new CVector3( -this.x, -this.y, -this.z ); }

        [Inline]
        final public function addOn( rhs : CVector3 ) : void { this.x += rhs.x; this.y += rhs.y; this.z += rhs.z; }
        [Inline]
        final public function addOnValue( f : Number ) : void { this.x += f; this.y += f; this.z += f; }
        [Inline]
        final public function addOnValueXYZ( fX : Number, fY : Number, fZ : Number ) : void { this.x += fX; this.y += fY; this.z += fZ; }
        [Inline]
        final public function subOn( rhs : CVector3 ) : void { this.x -= rhs.x; this.y -= rhs.y; this.z -= rhs.z; }
        [Inline]
        final public function subOnValue( f : Number ) : void { this.x -= f; this.y -= f; this.z -= f; }
        [Inline]
        final public function subOnValueXYZ( fX : Number, fY : Number, fZ : Number ) : void { this.x -= fX; this.y -= fY; this.z -= fZ; }
        [Inline]
        final public function mulOn( rhs : CVector3 ) : void { this.x *= rhs.x; this.y *= rhs.y; this.z *= rhs.z; }
        [Inline]
        final public function mulOnValue( f : Number ) : void { this.x *= f; this.y *= f; this.z *= f; }
        [Inline]
        final public function mulOnValueXYZ( fX : Number, fY : Number, fZ : Number ) : void { this.x *= fX; this.y *= fY; this.z *= fZ; }
        [Inline]
        final public function divOn( rhs : CVector3 ) : void { this.x /= rhs.x; this.y /= rhs.y; this.z /= rhs.z; }
        [Inline]
        final public function divOnValue( f : Number ) : void { this.x /= f; this.y /= f; this.z /= f; }
        [Inline]
        final public function divOnValueXYZ( fX : Number, fY : Number, fZ : Number ) : void { this.x /= fX; this.y /= fY; this.z /= fZ; }
        [Inline]
        final public function negateOn() : void { this.x = -this.x; this.y = -this.y; this.z = -this.z; }

        [Inline]
        final public function equals( rhs : CVector3 ) : Boolean
        {
            if( x != rhs.x || y != rhs.y || z != rhs.z ) return false;
            else return true;
        }
        [Inline]
        final public function equalsValue( fX : Number, fY : Number, fZ : Number ) : Boolean
        {
            if( x != fX || y != fY || z != fZ ) return false;
            else return true;
        }

        [Inline]
        final public function equalsWithinError( rhs : CVector3, fError : Number = CMath.EPSILON ) : Boolean
        {
            if( Math.abs( x - rhs.x ) > fError || Math.abs( y - rhs.y ) > fError || Math.abs( z - rhs.z ) > fError ) return false;
            else return true;
        }
        [Inline]
        final public function equalsValueWithinError( fX : Number, fY : Number, fZ : Number, fError : Number = CMath.EPSILON ) : Boolean
        {
            if( Math.abs( x - fX ) > fError || Math.abs( y - fY ) > fError || Math.abs( z - fZ ) > fError ) return false;
            else return true;
        }

        [Inline]
        final public function dump( aArray : Array ) : void
        {
            aArray[ 0 ] = x;
            aArray[ 1 ] = y;
            aArray[ 2 ] = z;
        }

        [Inline]
        final public function get r() : Number { return x; }
        [Inline]
        final public function get g() : Number { return y; }
        [Inline]
        final public function get b() : Number { return z; }
        [Inline]
        final public function set r( value : Number ) : void { x = value; }
        [Inline]
        final public function set g( value : Number ) : void { y = value; }
        [Inline]
        final public function set b( value : Number ) : void { z = value; }

        //
        [Inline]
        public static function lerp( vFrom : CVector3, vTo : CVector3, fWeight : Number ) : CVector3
        {
            return new CVector3( vFrom.x * ( 1.0 - fWeight ) + vTo.x * fWeight,
                                   vFrom.y * ( 1.0 - fWeight ) + vTo.y * fWeight,
                                   vFrom.z * ( 1.0 - fWeight ) + vTo.z * fWeight );
        }

        [Inline]
        public static function zero() : CVector3
        {
            return new CVector3( 0.0, 0.0, 0.0 );
        }
        [Inline]
        public static function one() : CVector3
        {
            return new CVector3( 1.0, 1.0, 1.0 );
        }

        //
        //
        public var x : Number;
        public var y : Number;
        public var z : Number;
    }

}

