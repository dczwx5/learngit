//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by david on 2016/11/2.
 */
package QFLib.Math
{

    import QFLib.Foundation;

    /**
     * Left Hand Coordinate System
     */
    public class CQuaternion
    {
        public static const IDENTITY : CQuaternion = new CQuaternion( 0, 0, 0, 1 );
        public static const ZERO : CQuaternion = new CQuaternion( 0, 0, 0, 0 );

        private static const sVectorHelper : CVector3 = CVector3.zero ();
        private static const sRawDataHelper : Vector.<Number> = new <Number>[ 1.0, 0.0, 0.0, 0.0,
            0.0, 1.0, 0.0, 0.0,
            0.0, 0.0, 1.0, 0.0,
            0.0, 0.0, 0.0, 1.0 ];

        public static function get zero() : CQuaternion
        {
            return new CQuaternion( 0, 0, 0, 0 );
        }

        public static function get identity () : CQuaternion
        {
            return new CQuaternion ( 0, 0, 0, 1 );
        }

        public function CQuaternion ( x:Number = 0, y:Number = 0, z:Number = 0, w:Number = 1 )
        {
            mX = x; mY = y; mZ = z; mW = w;
        }

        public function clone () : CQuaternion
        {
            var cQuaternion : CQuaternion = new CQuaternion ();
            mX = cQuaternion.mX; mY = cQuaternion.mY; mZ = cQuaternion.mZ; mW = cQuaternion.mW;
            return cQuaternion;
        }

        [Inline]
        final public function copy ( source : CQuaternion ) : void
        {
            mX = source.mX; mY = source.mY; mZ = source.mZ; mW = source.mW;
        }

        [Inline]
        final public function setValueXYZW ( x : Number, y : Number, z : Number, w : Number ) : void
        {
            mX = x; mY = y; mZ = z; mW = w;
        }

        [Inline]
        final public function equal ( other : CQuaternion ) : Boolean
        {
            return !( mX != other.mX ||
                        mY != other.mY ||
                        mZ != other.mZ ||
                        mW != other.mW );
        }

        [Inline]
        final public function identity() : void
        {
            mW = 1.0; mX = mY = mZ = 0;
        }

        public function getInverse () :CQuaternion
        {
            if ( mInverse == null ) mInverse = CQuaternion.identity;

            if ( mInverseDirty )
            {
                mInverseDirty = false;

                var mag : Number = magnitude ();
                if ( mag < CMath.EPSILON ) return zero;

                var sqrMag : Number = mag * mag;
                var conjugate : CQuaternion = getConjugate ();

                mInverse.mX = conjugate.mX / sqrMag;
                mInverse.mY = conjugate.mY / sqrMag;
                mInverse.mZ = conjugate.mZ / sqrMag;
                mInverse.mW = conjugate.mW / sqrMag;
            }

            return mInverse;
        }

        public function normalize () : void
        {
            var magnitude : Number = Math.sqrt( mX * mX + mY * mY + mZ * mZ + mW * mW );
            if( magnitude > 0 && Math.abs( magnitude - 1.0 ) > CMath.EPSILON )
            {
                mX /= magnitude; mY /= magnitude; mZ /= magnitude; mW /= magnitude;
            }
        }

        [Inline]
        final public function magnitude () : Number
        {
            if ( mMagnitudeDirty )
            {
                mMagnitudeDirty = false;
                mMagnitude = Math.sqrt( mX * mX + mY * mY + mZ * mZ + mW * mW );
            }

            return mMagnitude;
        }

        /**
         * s = cos(theta / 2), t = sin(theta / 2);
         * if vector n is the rotate axis, mX = t * n.x, mY = t * n.y, mZ = t * n.z;
         * @param axis
         * @param angle
         */
        public function setupNormAxisRotate ( axis : uint, angle : Number ) : void
        {
            var thetaOver2 : Number = angle * 0.5;
            var s : Number = Math.cos ( thetaOver2 );
            var t : Number = Math.sin ( thetaOver2 );

            identity();

            switch ( axis )
            {
                case CMath.X_Axis:
                    mW = s; mX = t; break;
                case CMath.Y_Axis:
                    mW = s; mY = t; break;
                case CMath.Z_Axis:
                    mW = s; mZ = t; break;
                default:
                    Foundation.Log.logWarningMsg("There are only x, y, z axis, please use setupAxisRotate!");
                    break;
            }
        }

        /**
         *
         * @param angle
         * @param n: rotate axis
         */
        public function setupAxisRotate ( angle : Number, n : CVector3 ) : void
        {
            var thetaOver2 : Number = angle * 0.5;
            var s : Number = Math.cos ( thetaOver2 );
            var t : Number = Math.sin ( thetaOver2 );

            var vector : CVector3 = sVectorHelper;
            vector.set( n );
            vector.normalize();

            mW = s;
            mX = t * vector.x; mY = t * vector.y; mZ = t * vector.z;
        }

        /**
         * Premultiply: a quaternion q multiply with a quaternion rhq like: q * rhq * v, it means a vector v rotate by rhq first, and then rotate by q.
         *  result = q * rhq = Sq * Srhq - dot(Vq, Vrhq) + Sq * Vrhq + Srhq * Vq + crossProduct(Vq, Vrhq); Sq == mW, Vq:(mX, mY, mZ)
         *
         * @param rhq
         */
        public function premultipyQuaternion ( rhq : CQuaternion ) : void
        {
            mW = mW * rhq.mW - mX * rhq.mX - mY * rhq.mY - mZ * rhq.mZ;
            mX = mW * rhq.mX + mX * rhq.mW + mY * rhq.mZ - mZ * rhq.mY;
            mY = mW * rhq.mY + mY * rhq.mW + mX * rhq.mZ - mZ * rhq.mX;
            mZ = mW * rhq.mZ + mZ * rhq.mW + mX * rhq.mY - mY * rhq.mX;
        }

        /**
         * Postmultiply:
         *
         * @param ltq
         */
        public function postmultiplyQuaternion ( ltq : CQuaternion ) : void
        {
            mW = ltq.mW * mW - ltq.mX * mX - ltq.mY * mY - ltq.mZ * mZ;
            mX = ltq.mW * mX + ltq.mX * mW + ltq.mY * mZ - ltq.mZ * mY;
            mY = ltq.mW * mY + ltq.mY * mW + ltq.mX * mZ - ltq.mZ * mX;
            mZ = ltq.mW * mZ + ltq.mZ * mW + ltq.mX * mY - ltq.mY * mX;
        }

        /**
         * vector rotation: p1 = p * cos(theta) + crossProduct(n, p) * sin(theta) + dot(n, p) * p * (1 - cos(theta));
         * quaternion rotation, q is a quaternion, s = q.w, n is a normalized vector, v = t * n, : q p q^-1 = (s^2 - t^2) * p + 2 * s * t * crossProduct(n, p) + 2 * t^2 * dot(n, p) * p;
         * @param rhv
         * @return
         */
        public function premultiplyVector ( rhv : CVector3 ) : CVector3
        {
            //converte the vector (rhv) to a quaternion
            var vecQuat : CQuaternion = new CQuaternion( rhv.x, rhv.y, rhv.z, 0 );

            //Should be normalized?
            //vecQuat.normalize();

            vecQuat.premultipyQuaternion( getConjugate() );
            vecQuat.postmultiplyQuaternion( this );

            return new CVector3( vecQuat.mX, vecQuat.mY, vecQuat.mZ );
        }

        [Inline]
        final public function multiplyNumber ( value : Number ) : void
        {
            mX *= value; mY *= value; mZ *= value; mW *= value;
        }

        /**
         * Linear lerp
         * @param start
         * @param end
         * @param t
         */
        public function lerp ( start : CQuaternion, end : CQuaternion, t : Number ) : void
        {
            var oneMinusT : Number = 1 - t;
            mX = start.mX * oneMinusT + end.mX * t;
            mY = start.mY * oneMinusT + end.mY * t;
            mZ = start.mZ * oneMinusT + end.mZ * t;
            mW = start.mW * oneMinusT + end.mW * t;

            normalize();
        }

        /**
         * Sphereric lerp
         * @param start
         * @param end
         * @param t
         */
        public function slerp( start : CQuaternion, end : CQuaternion, t : Number ) : void
        {
            var cosTheta : Number = start.dotProduct( end );

            var x : Number = end.mX;
            var y : Number = end.mY;
            var z : Number = end.mZ;
            var w : Number = end.mW;
            if( cosTheta < 0.0 )
            {
                x *= -1; y *= -1; z *= -1; w *= -1;
            }

            var k0 : Number;
            var k1 : Number;
            if( cosTheta - 1.0 < CMath.EPSILON )
            {
                k0 = 1 - t;
                k1 = t;
            }
            else
            {
                var sinTheta : Number = Math.sqrt( 1 - cosTheta * cosTheta );
                var radian : Number = Math.atan2( sinTheta, cosTheta );
                var invSinTheta : Number = 1 / sinTheta;
                k0 = Math.sin( ( 1 - t ) * radian ) * invSinTheta;
                k1 = Math.sin( t * radian ) * invSinTheta;
            }

            mX = start.mX * k0 + x * k1;
            mY = start.mY * k0 + y * k1;
            mZ = start.mZ * k0 + z * k1;
            mW = start.mW * k0 + w * k1;

            normalize();
        }

        public function dotProduct ( rhq : CQuaternion) : Number
        {
            return mX * rhq.mX + mY * rhq.mY + mZ * rhq.mZ + mW * rhq.mW;
        }

        /**
         *  quaternion to rotation matrix:
         *  | 1 - 2y^2 - 2z^2, 2xy - 2wz, 2zx + 2wy |
         *  | 2xy + 2zw, 1 - 2x^2 - 2z^2, 2yz - 2wx |
         *  | 2zx - 2wy, 2yz + 2wx, 1 - 2x^2 - 2y^2 |
         * @param result
         * @return
         */
        public function toMatrix4 ( result : CMatrix4 = null ) : CMatrix4
        {
            if ( result == null )
                result = new CMatrix4( null );

            var x2 : Number = 2 * mX;
            var y2 : Number = 2 * mY;
            var z2 : Number = 2 * mZ;

            var xy2 : Number = x2 * mY;
            var yz2 : Number = y2 * mZ;
            var zx2 : Number = z2 * mX;

            var wx2 : Number = x2 * mW;
            var wy2 : Number = y2 * mW;
            var wz2 : Number = z2 * mW;

            var squreX2 : Number = x2 * mX;
            var squreY2 : Number = y2 * mY;
            var squreZ2 : Number = z2 * mZ;

            result.matrix3D.copyRawDataTo ( sRawDataHelper );
            var rawData : Vector.<Number> = sRawDataHelper;
            rawData[ 0 ] = 1 - squreY2 - squreZ2; rawData[ 4 ] = xy2 - wz2;             rawData[ 8 ] = zx2 + wy2;
            rawData[ 1 ] = xy2 + wz2;             rawData[ 5 ] = 1 - squreX2 - squreZ2; rawData[ 9 ] = yz2 - wx2;
            rawData[ 2 ] = zx2 - wy2;             rawData[ 6 ] = yz2 + wx2;             rawData[ 10 ] = 1- squreX2 - squreY2;
            rawData[ 3 ] = rawData[ 7 ] = rawData[ 11 ] = 0; rawData[ 15 ] = 1;
            result.matrix3D.copyRawDataFrom ( rawData );

            return result;
        }

        /**
         *  rotation matrix in quaternion component format:
         *  | 1 - 2y^2 - 2z^2, 2xy - 2wz, 2zx + 2wy |
         *  | 2xy + 2zw, 1 - 2x^2 - 2z^2, 2yz - 2wx |
         *  | 2zx - 2wy, 2yz + 2wx, 1 - 2x^2 - 2y^2 |
         *
         * @param matrix: rotation matrix
         * for unit quaternion q = (x, y, z, w), there must be one component magnitude is at least 1/2, we should avoid unnumerical stability
         */
        public function fromMatrix4 ( matrix : CMatrix4 ) : void
        {
            matrix.matrix3D.copyRawDataTo ( sRawDataHelper );
            var rawData : Vector.<Number> = sRawDataHelper;
            //trace = m00 + m11 + m22 = 4( 1 - x^2 - y^2 - z^2 ) - 1 = 4w^2 - 1
            var trace : Number = rawData[ 0 ] + rawData[ 5 ] + rawData[ 10 ];

            //if w magnitude is at least 1/2
            if( trace > 0 )
            {
                var w2 : Number = Math.sqrt( trace + 1 );

                this.mW = w2 * 0.5;

                //scale factor : 1 / 4w;
                var t : Number = ( 1.0 / w2 ) * 0.5;

                this.mZ = ( rawData[ 1 ] - rawData[ 4 ] ) * t;
                this.mY = ( rawData[ 8 ] - rawData[ 2 ] ) * t;
                this.mX = ( rawData[ 6 ] - rawData[ 9 ] ) * t;
            }
            else
            {
                //scale may be 1/4x, 1/4y or 1/4z
                var i : uint = 0;
                if( rawData[ 5 ] > rawData[ 0 ] ) i = 1;
                if( rawData[ 10 ] > rawData[ 10 ] ) i = 2;

                var scaleFactor : Number;
                if( i == 0 )
                {
                    //scaleFactor = 1/4x
                    this.mX = Math.sqrt ( ( rawData[ 0 ] - ( rawData[ 5 ] + rawData[ 10 ] ) + 1 ) ) * 0.5;
                    scaleFactor = ( 1.0 / this.mX ) * 0.5;

                    this.mW = ( rawData[ 6 ] - rawData[ 9 ] ) * scaleFactor;
                    this.mY = ( rawData[ 1 ] + rawData[ 4 ] ) * scaleFactor;
                    this.mZ = ( rawData[ 2 ] + rawData[ 8 ] ) * scaleFactor;
                }
                else if( i == 1 )
                {
                    //scaleFactor = 1/4y
                    this.mY = Math.sqrt ( ( rawData[ 5 ] - ( rawData[ 0 ] + rawData[ 10 ] ) + 1 ) ) * 0.5;
                    scaleFactor = ( 1.0 / this.mY ) * 0.5;

                    this.mW = ( rawData[ 8 ] - rawData[ 2 ] ) * scaleFactor;
                    this.mX = ( rawData[ 1 ] + rawData[ 4 ] ) * scaleFactor;
                    this.mZ = ( rawData[ 6 ] + rawData[ 9 ] ) * scaleFactor;
                }
                else
                {
                    //scaleFactor = 1/4z
                    this.mZ = Math.sqrt ( ( rawData[ 10 ] - ( rawData[ 5 ] + rawData[ 10 ] ) + 1 ) ) * 0.5;
                    scaleFactor = ( 1.0 / this.mZ ) * 0.5;

                    this.mW = ( rawData[ 1 ] - rawData[ 4 ] ) * scaleFactor;
                    this.mX = ( rawData[ 2 ] + rawData[ 8 ] ) * scaleFactor;
                    this.mY = ( rawData[ 6 ] + rawData[ 9 ] ) * scaleFactor;
                }
            }
        }

        /**
         * w^2 + x^2 + y^2 + z^2 = 1
         * @return
         */
        public function getRotateAxis () : CVector3
        {
            var sinThetaOver2SQ : Number = 1 - mW * mW;
            if( sinThetaOver2SQ <= 0.0 )
                return new CVector3 ( 1.0, 0.0, 0.0 );

            var result : CVector3 = new CVector3 ( mX, mY, mZ );
            result.mulOnValue ( Math.sqrt ( sinThetaOver2SQ ) );

            return result;
        }

        public function getConjugate ( ) : CQuaternion
        {
            if ( mConjugate == null )
                return mConjugate = new CQuaternion ( -mX, -mY, -mZ, mW );

            if ( mConjugateDirty )
            {
                mConjugateDirty = false;
                mConjugate.setValueXYZW( -mX, -mY, -mZ, mW );
            }
            return mConjugate;
        }

        public function getRotateAngle () : Number
        {
            if( mW <= -1.0 ) return Math.PI;
            else if( mW >= 1.0 ) return 0.0;

            return 2 * Math.acos ( mW );
        }

        public var mX : Number = 0;
        public var mY : Number = 0;
        public var mZ : Number = 0;
        public var mW : Number = 1;

        private var mInverse : CQuaternion = null;
        private var mConjugate : CQuaternion = null;
        private var mMagnitude : Number = 1.0;

        private var mConjugateDirty : Boolean = true;
        private var mInverseDirty : Boolean = true;
        private var mMagnitudeDirty : Boolean = true;
    }
}
