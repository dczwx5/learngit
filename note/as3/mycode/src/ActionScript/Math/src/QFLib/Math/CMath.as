//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/5/19
//----------------------------------------------------------------------------------------------------------------------


package QFLib.Math
{
    import flash.utils.ByteArray;

    //
    //
    public class CMath
    {
        public static const PI : Number = 3.1415926;
        public static const PIOver2 : Number = PI * 0.5;
        public static const DPI : Number = 6.2831852;
        public static const OneOverDPI : Number = 1.0 / DPI;

        public static const EPSILON : Number = 0.00001;
        public static const BIG_EPSILON : Number = 0.0001;

        public static const X_Axis : uint = 1;
        public static const Y_Axis : uint = 2;
        public static const Z_Axis : uint = 3;

        public static const SPACE_LOCAL : int = 0;
        public static const SPACE_PARENT : int = 1;
        public static const SPACE_GLOBAL : int = 2;

        public static function wrapPi ( radian : Number ) : Number
        {
            radian += PI;
            radian -= Math.floor( radian * OneOverDPI ) * DPI;
            radian -= PI;
            return radian;
        }
        [Inline]
        public static function degToRad( degree : Number ) : Number { return ( degree * 0.017453292 ); }
        [Inline]
        public static function radToDeg( radian : Number ) : Number { return ( radian * 57.29578 ); }

        [Inline]
        public static function isZero( f : Number ) : Boolean { return ( abs( f ) < EPSILON ); }
        [Inline]
        public static function isNear( f1 : Number, f2 : Number, fError : Number = EPSILON ) : Boolean { return ( abs( f1 - f2 ) < fError ); }

        [Inline]
        public static function abs( f : Number ) : Number { return f >= 0.0 ? f : -f; }
        [Inline]
        public static function max( f1 : Number, f2 : Number ) : Number { return f1 > f2 ? f1 : f2; }
        [Inline]
        public static function min( f1 : Number, f2 : Number ) : Number { return f1 < f2 ? f1 : f2; }

        [Inline]
        public static function sqrt( f : Number ) : Number { return Math.sqrt( f ); }

        public static function generateRandomVector( iLength : int, fMin : Number, fMax : Number, fMultiply : Number = 1.0 ) : Vector.<Number>
        {
            var vRandom : Vector.<Number> = new Vector.<Number>( iLength );

            var fRange : Number = fMax - fMin;
            var fNumber : Number;
            for( var i : int = 0; i < vRandom.length; i++ )
            {
                fNumber = fMin + Math.random() * fRange;
                fNumber *= fMultiply;
                if( fNumber > fMax ) fNumber = fMax;
                else if( fNumber < fMin ) fNumber = fMin;

                vRandom[ i ] = fNumber;
            }

            return vRandom;
        }

        public static function generateRandomVectorWithMeanValue( iLength : int, fMin : Number, fMax : Number, fMeanValue : Number,
                                                                     fMeanValuePercentage : Number = 0.7, fMeanValueRangePercentage : Number = 0.3 ) : Vector.<Number>
        {
            var vRandom : Vector.<Number> = new Vector.<Number>( iLength );

            var bMeanValue : Boolean = false;
            if( fMeanValuePercentage > 0.0 && fMeanValue <= fMax && fMeanValue >= fMin ) bMeanValue = true;

            var fRange : Number = fMax - fMin;
            var fMeanRange : Number = fRange * fMeanValueRangePercentage;
            var fMeanMin : Number = fMeanValue - fMeanRange * 0.5;
            var fMeanMax : Number = fMeanValue + fMeanRange * 0.5;
            if( fMeanMin < fMin ) fMeanMin = fMin;
            if( fMeanMax > fMax ) fMeanMax = fMax;
            fMeanRange = fMeanMax - fMeanMin;

            var fNumber : Number;
            for( var i : int = 0; i < vRandom.length; i++ )
            {
                if( bMeanValue && Math.random() < fMeanValuePercentage )
                {
                    fNumber = fMeanMin + Math.random() * fMeanRange;
                }
                else
                {
                    fNumber = fMin + Math.random() * fRange;
                }

                vRandom[ i ] = fNumber;
            }

            return vRandom;
        }

        //
        //
        [Inline]
        public static function sinRad( radian : Number ) : Number { return Math.sin( radian ); }
        [Inline]
        public static function sinDeg( degree : Number ) : Number { return sinRad( degToRad( degree ) ); }
        [Inline]
        public static function cosRad( radian : Number ) : Number { return Math.cos( radian ); }
        [Inline]
        public static function cosDeg( degree : Number ) : Number { return cosRad( degToRad( degree ) ); }
        [Inline]
        public static function tanRad( radian : Number ) : Number { return Math.tan( radian ); }
        [Inline]
        public static function tanDeg( degree : Number ) : Number { return tanRad( degToRad( degree ) ); }

        //
        //
        [Inline]
        public static function asinRad( f : Number ) : Number { if( f > 1.0 ) f = 1.0; return Math.asin( f ); }
        [Inline]
        public static function asinDeg( f : Number ) : Number { return radToDeg( asinRad( f ) ); }
        [Inline]
        public static function acosRad( f : Number ) : Number { if( f > 1.0 ) f = 1.0; return Math.acos( f ); }
        [Inline]
        public static function acosDeg( f : Number ) : Number { return radToDeg( acosRad( f ) ); }
        [Inline]
        public static function atanRad( f : Number ) : Number { return Math.atan( f ); }
        [Inline]
        public static function atanDeg( f : Number ) : Number { return radToDeg( atanRad( f ) ); }

        [Inline]
        public static function rand() : Number { return Math.random(); } // 0 ~ int.MaxValue


        //
        // vector2
        //
        [Inline]
        public static function lengthVector2( x1 : Number, y1 : Number, x2 : Number, y2 : Number ) : Number
        {
            return sqrt( lengthSqrVector2( x1, y1, x2, y2 ) );
        }
        [Inline]
        public static function lengthSqrVector2( x1 : Number, y1 : Number, x2 : Number, y2 : Number ) : Number
        {
            var x : Number = x2 - x1;
            var y : Number = y2 - y1;
            return x * x + y * y;
        }
        [Inline]
        public static function is2DVertexIntersectAARect( x1 : Number, y1 : Number,
                                                             minRectX : Number, minRectY : Number, maxRectX : Number, maxRectY : Number ) : Boolean
        {
            if( x1 < minRectX || x1 > maxRectX ) return false;
            if( y1 < minRectY || y1 > maxRectY ) return false;
            return true;
        }
        public static function is2DLineIntersectLine( x1 : Number, y1 : Number, x2 : Number, y2 : Number,
                                                         x3 : Number, y3 : Number, x4 : Number, y4 : Number ) : Boolean
        {
            var iTest1 : int;
            var iTest2 : int;

            iTest1 = checkTriangleClockDirection( x1, y1, x2, y2, x3, y3 );
            iTest2 = checkTriangleClockDirection( x1, y1, x2, y2, x4, y4 );
            if( iTest1 != iTest2 )
            {
                iTest1 = checkTriangleClockDirection( x3, y3, x4, y4, x1, y1 );
                iTest2 = checkTriangleClockDirection( x3, y3, x4, y4, x2, y2 );
                if( iTest1 != iTest2 ) return true;
            }
            return false;

            /* there is a flaw in this method below when x2 - x1 = 0
            var fA : Number = x4 - x3;
            var fB : Number = x2 - x1;
            var fC : Number = y4 - y3;
            var fD : Number = y2 - y1;

            var fAB : Number = fA * fB;
            var fCB : Number = fC * fB;
            var fDA : Number = fD * fA;

            var x : Number = ( ( y1 * fAB ) - ( y3 * fAB ) + ( x3 * fCB ) - ( x1 * fDA ) ) / ( fCB - fDA );
            var t : Number = ( x - x1 ) / fB;
            //float y = y1 + t * fD;

            if( t >= 0.0 && t <= 1.0 ) return true;
            else return true;*/
        }
        public static function is2DLineIntersectAABB( x1 : Number, y1 : Number, x2 : Number, y2 : Number,
                                                         minRectX : Number, minRectY : Number, maxRectX : Number, maxRectY : Number ) : Boolean
        {
            // Check if both vertices of the line intersect the rectangle
            if( is2DVertexIntersectAARect( x1, y1, minRectX, minRectY, maxRectX, maxRectY ) ) return true;
            if( is2DVertexIntersectAARect( x2, y2, minRectX, minRectY, maxRectX, maxRectY ) ) return true;

            // Check if the line intersects with any diagonal of rectangle
            if( is2DLineIntersectLine( x1, y1, x2, y2, minRectX, minRectY, maxRectX, maxRectY ) ) return true;
            if( is2DLineIntersectLine( x1, y1, x2, y2, minRectX, maxRectY, maxRectX, minRectY ) ) return true;

            return false;
        }

        [Inline]
        public static function checkTriangleClockDirection( x1 : Number, y1 : Number, x2 : Number, y2 : Number, x3 : Number, y3 : Number ) : int
        {
            var fTest : Number = ( ( ( x2 - x1 ) * ( y3 - y1 ) ) - ( ( x3 - x1 ) *  ( y2 - y1 ) ) );
            if( fTest > 0.0 ) return -1; // counter clockwise
            else if( fTest < 0.0 ) return 1; // clockwise
            else return 0; // line
        }


        //
        // vector3
        //
        [Inline]
        public static function lengthVector3( x1 : Number, y1 : Number, z1 : Number, x2 : Number, y2 : Number, z2 : Number ) : Number
        {
            return sqrt( lengthSqrVector3( x1, y1, z1, x2, y2, z2 ) );
        }
        [Inline]
        public static function lengthSqrVector3( x1 : Number, y1 : Number, z1 : Number, x2 : Number, y2 : Number, z2 : Number ) : Number
        {
            var x : Number = x2 - x1;
            var y : Number = y2 - y1;
            var z : Number = z2 - z1;
            return x * x + y * y + z * z;
        }

        [Inline]
        public static function is3DVertexIntersectAABB( x : Number, y : Number, z : Number,
                                                           minRectX : Number, minRectY : Number, minRectZ : Number,
                                                           maxRectX : Number, maxRectY : Number, maxRectZ : Number ) : Boolean
        {
            if( x < minRectX || x > maxRectX ) return false;
            if( y < minRectY || y > maxRectY ) return false;
            if( z < minRectZ || z > maxRectZ ) return false;
            return true;
        }
        public static function is3DLineIntersectAABB( x1 : Number, y1 : Number, z1 : Number, x2 : Number, y2 : Number, z2 : Number,
                                                         minRectX : Number, minRectY : Number, minRectZ : Number,
                                                         maxRectX : Number, maxRectY : Number, maxRectZ : Number ) : Boolean
        {
            if( is3DVertexIntersectAABB( x1, y1, z1, minRectX, minRectY, minRectZ, maxRectX, maxRectY, maxRectZ ) ) return true;
            if( is3DVertexIntersectAABB( x2, y2, z2, minRectX, minRectY, minRectZ, maxRectX, maxRectY, maxRectZ ) ) return true;

            // XY Plane
            if( is3DLineIntersectAARectXY( x1, y1, z1, x2, y2, z2, minRectX, minRectY, maxRectX, maxRectY, minRectZ ) ) return true;
            if( is3DLineIntersectAARectXY( x1, y1, z1, x2, y2, z2, minRectX, minRectY, maxRectX, maxRectY, maxRectZ ) ) return true;

            // YZ Plane
            if( is3DLineIntersectAARectYZ( x1, y1, z1, x2, y2, z2, minRectY, minRectZ, maxRectY, maxRectZ, minRectX ) ) return true;
            if( is3DLineIntersectAARectYZ( x1, y1, z1, x2, y2, z2, minRectY, minRectZ, maxRectY, maxRectZ, maxRectX ) ) return true;

            // XZ Plane
            if( is3DLineIntersectAARectXZ( x1, y1, z1, x2, y2, z2, minRectX, minRectZ, maxRectX, maxRectZ, minRectY ) ) return true;
            if( is3DLineIntersectAARectXZ( x1, y1, z1, x2, y2, z2, minRectX, minRectZ, maxRectX, maxRectZ, maxRectY ) ) return true;

            return false;
        }

        public static function is3DLineIntersectAARectXY( x1 : Number, y1 : Number, z1 : Number, x2 : Number, y2 : Number, z2 : Number,
                                                             minRectX : Number, minRectY : Number, maxRectX : Number, maxRectY : Number, theRectZ : Number ) : Boolean
        {
            var dz : Number = z2 - z1;

            if( abs( dz ) < EPSILON )
            {
                // line and plane are in parallel
                dz = z1 - theRectZ;
                if( abs( dz ) < EPSILON ) // line in in the plane
                {
                    if( is2DLineIntersectAABB( x1, y1, x2, y2, minRectX, minRectY, maxRectX, maxRectY ) ) return true;
                }
                return false;
            }

            // check if v0 & v1 are at opposite side of the plane
            if( z1 < theRectZ )
            {
                if( z2 < theRectZ ) return false;
            }
            else if( z1 > theRectZ )
            {
                if( z2 > theRectZ ) return false;
            }

            // check if line intersects point inside the rect
            var t : Number = ( theRectZ - z1 ) / dz;
            var x : Number = x1 + ( x2 - x1 ) * t;
            var y : Number = y1 + ( y2 - y1 ) * t;

            if( x < minRectX || x > maxRectX ) return false;
            if( y < minRectY || y > maxRectY ) return false;

            return true;
        }
        public static function is3DLineIntersectAARectXZ( x1 : Number, y1 : Number, z1 : Number, x2 : Number, y2 : Number, z2 : Number,
                                                             minRectX : Number, minRectZ : Number, maxRectX : Number, maxRectZ : Number, theRectY : Number ) : Boolean
        {
            var dy : Number = y2 - y1;

            if( abs( dy ) < EPSILON )
            {
                // line and plane are in parallel
                dy = y1 - theRectY;
                if( abs( dy ) < EPSILON ) // line in in the plane
                {
                    if( is2DLineIntersectAABB( x1, z1, x2, z2, minRectX, minRectZ, maxRectX, maxRectZ ) ) return true;
                }
                return false;
            }

            // check if v0 & v1 are at opposite side of the plane
            if( y1 < theRectY )
            {
                if( y2 < theRectY ) return false;
            }
            else if( y1 > theRectY )
            {
                if( y2 > theRectY ) return false;
            }

            // check if line intersects point inside the rect
            var t : Number = ( theRectY - y1 ) / dy;
            var x : Number = x1 + ( x2 - x1 ) * t;
            var z : Number = z1 + ( z2 - z1 ) * t;

            if( x < minRectX || x > maxRectX ) return false;
            if( z < minRectZ || z > maxRectZ ) return false;

            return true;
        }
        public static function is3DLineIntersectAARectYZ( x1 : Number, y1 : Number, z1 : Number, x2 : Number, y2 : Number, z2 : Number,
                                                             minRectY : Number, minRectZ : Number, maxRectY : Number, maxRectZ : Number, theRectX : Number ) : Boolean
        {
            var dx : Number = x2 - x1;

            if( abs( dx ) < EPSILON )
            {
                // line and plane are in parallel
                dx = x1 - theRectX;
                if( abs( dx ) < EPSILON ) // line in in the plane
                {
                    if( is2DLineIntersectAABB( y1, z1, y2, z2, minRectY, minRectZ, maxRectY, maxRectZ ) ) return true;
                }
                return false;
            }

            // Check if v0 & v1 are at opposite side of the plane
            if( x1 < theRectX )
            {
                if( x2 < theRectX ) return false;
            }
            else if( x1 > theRectX )
            {
                if( x2 > theRectX ) return false;
            }

            // check if line intersects point inside the rect
            var t : Number = ( theRectX - x1 ) / dx;
            var y : Number = y1 + ( y2 - y1 ) * t;
            var z : Number = z1 + ( z2 - z1 ) * t;

            if( y < minRectY || y > maxRectY ) return false;
            if( z < minRectZ || z > maxRectZ ) return false;

            return true;
        }

    }

}

