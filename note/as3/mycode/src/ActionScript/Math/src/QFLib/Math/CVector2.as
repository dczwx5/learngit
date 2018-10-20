//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/5/19
//----------------------------------------------------------------------------------------------------------------------

package QFLib.Math
{

    public class CVector2
    {
        public static const ZERO : CVector2 = new CVector2( 0.0, 0.0 );
        public static const ONE : CVector2 = new CVector2( 1.0, 1.0 );
        public static const X_AXIS : CVector2 = new CVector2( 1.0, 0.0 );
        public static const Y_AXIS : CVector2 = new CVector2( 0.0, 1.0 );
        public static const NEGATIVE_X_AXIS : CVector2 = new CVector2( -1.0, 0.0 );
        public static const NEGATIVE_Y_AXIS : CVector2 = new CVector2( 0.0, -1.0 );

        private static const vectorHelper : CVector2 = new CVector2( 0.0, 0.0 );

        public function CVector2( x : Number = 0.0, y : Number = 0.0 )
        {
            this.x = x;
            this.y = y;
        }

        [Inline]
        final public function clone() : CVector2
        {
            return new CVector2( this.x, this.y );
        }

        public function toString() : String
        {
            var s : String = "";
            s += x.toString();
            s += ", ";
            s += y.toString();
            return s;
        }

        public function toFixed( numFixed : * = 0 ) : String
        {
            var s : String = "";
            s += x.toFixed( numFixed );
            s += ", ";
            s += y.toFixed( numFixed );
            return s;
        }

        public function toArray() : Array
        {
            var aArray : Array = new Array[ 2 ];
            aArray[ 0 ] = x;
            aArray[ 1 ] = y;
            return aArray;
        }

        [Inline]
        final public function set( v : CVector2 ) : void { this.x = v.x; this.y = v.y; }
        [Inline]
        final public function setTo( v : CVector2 ) : void { set( v ); }
        [Inline]
        final public function setValueXY( x : Number, y : Number ) : void { this.x = x; this.y = y; }
        [Inline]
        final public function zero() : void { this.x = 0.0; this.y = 0.0; }

        [Inline]
        final public function isZero() : Boolean { if( x != 0.0 || y != 0.0 ) return false; else return true; }
        [Inline]
        final public function isNearZero() : Boolean { if( ( CMath.abs( x ) > CMath.EPSILON ) || ( CMath.abs( y ) > CMath.EPSILON ) ) return false; else return true; }

        [Inline]
        final public function length() : Number { return CMath.sqrt( x * x + y * y ); }
        [Inline]
        final public function lengthSqr() : Number { return x * x + y * y; }
        [Inline]
        final public function distance() : Number { return length(); }

        public function normalize( fLen : Number = 0.0 ) : Number
        {
            if( fLen == 0.0 ) fLen = length();
            if( fLen > CMath.EPSILON )
            {
                x /= fLen; y /= fLen;
                return fLen;
            }
            else return 0.0;
        }

        [Inline]
        final public function dot( rhs : CVector2 ) : Number { return ( x * rhs.x ) + ( y * rhs.y ); }

        public function angleRad( rhs : CVector2 ) : Number
        { 
            var f : Number = this.length() * rhs.length();
            if( f == 0.0 ) return 0.0;

            f = CMath.acosRad( this.dot( rhs ) / f );
            return ( f >= 0.0 ? f : ( f + CMath.PI ) );
        }

        [Inline]
        final public function angleDeg( rhs : CVector2 ) : Number{ return CMath.radToDeg( angleRad( rhs ) ); }

        [Inline]
        final public function add( rhs : CVector2 ) : CVector2 { return new CVector2( this.x + rhs.x, this.y + rhs.y ); }
        [Inline]
        final public function addValue( f : Number ) : CVector2 { return new CVector2( this.x + f, this.y + f ); }
        [Inline]
        final public function addValueXY( fX : Number, fY : Number ) : CVector2 { return new CVector2( this.x + fX, this.y + fY ); }
        [Inline]
        final public function sub( rhs : CVector2 ) : CVector2 { return new CVector2( this.x - rhs.x, this.y - rhs.y ); }
        [Inline]
        final public function subValue( f : Number ) : CVector2 { return new CVector2( this.x - f, this.y - f ); }
        [Inline]
        final public function subValueXY( fX : Number, fY : Number ) : CVector2 { return new CVector2( this.x - fX, this.y - fY ); }
        [Inline]
        final public function mul( rhs : CVector2 ) : CVector2 { return new CVector2( this.x * rhs.x, this.y * rhs.y ); }
        [Inline]
        final public function mulValue( f : Number ) : CVector2  { return new CVector2( this.x * f, this.y * f ); }
        [Inline]
        final public function mulValueXY( fX : Number, fY : Number ) : CVector2  { return new CVector2( this.x * fX, this.y * fY ); }
        [Inline]
        final public function div( rhs : CVector2 ) : CVector2 { return new CVector2( this.x / rhs.x, this.y / rhs.y ); }
        [Inline]
        final public function divValue( f : Number ) : CVector2 { return new CVector2( this.x / f, this.y / f ); }
        [Inline]
        final public function divValueXY( fX : Number, fY : Number ) : CVector2 { return new CVector2( this.x / fX, this.y / fY ); }
        [Inline]
        final public function negate() : CVector2 { return new CVector2( -this.x, -this.y ); }

        [Inline]
        final public function addOn( rhs : CVector2 ) : void { this.x += rhs.x; this.y += rhs.y; }
        [Inline]
        final public function addOnValue( f : Number ) : void { this.x += f; this.y += f; }
        [Inline]
        final public function addOnValueXY( fX : Number, fY : Number ) : void { this.x += fX; this.y += fY; }
        [Inline]
        final public function subOn( rhs : CVector2 ) : void { this.x -= rhs.x; this.y -= rhs.y; }
        [Inline]
        final public function subOnValue( f : Number ) : void { this.x -= f; this.y -= f; }
        [Inline]
        final public function subOnValueXY( fX : Number, fY : Number ) : void { this.x -= fX; this.y -= fY; }
        [Inline]
        final public function mulOn( rhs : CVector2 ) : void { this.x *= rhs.x; this.y *= rhs.y; }
        [Inline]
        final public function mulOnValue( f : Number ) : void  { this.x *= f; this.y *= f; }
        [Inline]
        final public function mulOnValueXY( fX : Number, fY : Number ) : void  { this.x *= fX; this.y *= fY; }
        [Inline]
        final public function divOn( rhs : CVector2 ) : void { this.x /= rhs.x; this.y /= rhs.y; }
        [Inline]
        final public function divOnValue( f : Number ) : void { this.x /= f; this.y /= f; }
        [Inline]
        final public function divOnValueXY( fX : Number, fY : Number ) : void { this.x /= fX; this.y /= fY; }
        [Inline]
        final public function negateOn() : void { this.x = -this.x, this.y = -this.y; }

        [Inline]
        final public function equals( rhs : CVector2 ) : Boolean
        {
            if( x != rhs.x || y != rhs.y ) return false;
            else return true;
        }
        [Inline]
        final public function equalsValue( fX : Number, fY : Number ) : Boolean
        {
            if( x != fX || y != fY ) return false;
            else return true;
        }

        [Inline]
        final public function equalsWithinError( rhs : CVector2, fError : Number = CMath.EPSILON ) : Boolean
        {
            if( Math.abs( x - rhs.x ) > fError || Math.abs( y - rhs.y ) > fError ) return false;
            else return true;
        }
        [Inline]
        final public function equalsValueWithinError( fX : Number, fY : Number, fError : Number = CMath.EPSILON ) : Boolean
        {
            if( Math.abs( x - fX ) > fError || Math.abs( y - fY ) > fError ) return false;
            else return true;
        }

        [Inline]
        final public function dump( aArray : Array ) : void
        {
            aArray[ 0 ] = x;
            aArray[ 1 ] = y;
        }

        //
        [Inline]
        public static function lerp( vFrom : CVector2, vTo : CVector2, fWeight : Number ) : CVector2
        {
            vectorHelper.setValueXY( vFrom.x * ( 1.0 - fWeight ) + vTo.x * fWeight,
                    vFrom.y * ( 1.0 - fWeight ) + vTo.y * fWeight );
            return vectorHelper;
        }

        [Inline]
        public static function zero() : CVector2
        {
            return new CVector2( 0.0, 0.0 );
        }
        [Inline]
        public static function one() : CVector2
        {
            return new CVector2( 1.0, 1.0 );
        }

        //
        //
        public var x : Number;
        public var y : Number;
    }

}
