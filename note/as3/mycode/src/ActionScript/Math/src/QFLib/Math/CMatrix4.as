//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by david on 2016/11/3.
 */
package QFLib.Math
{

    import QFLib.Foundation;

    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;

    /**
     * Left Hand Coordinate System
     */
    public class CMatrix4
    {
        private static const sVector3DHelper : Vector3D = new Vector3D ();
        private static const sVectorHelper : CVector4 = CVector4.zero ();
        private static const sRawDataHelperL : Vector.<Number> = new <Number>[ 1.0, 0.0, 0.0, 0.0,
            0.0, 1.0, 0.0, 0.0,
            0.0, 0.0, 1.0, 0.0,
            0.0, 0.0, 0.0, 1.0 ];
        private static const sRawDataHelperR : Vector.<Number> = new <Number>[ 1.0, 0.0, 0.0, 0.0,
            0.0, 1.0, 0.0, 0.0,
            0.0, 0.0, 1.0, 0.0,
            0.0, 0.0, 0.0, 1.0 ];

        public static function matrixMultiplyNumber ( number : Number, matrix : CMatrix4, result : CMatrix4 = null ) : CMatrix4
        {
            if( result == null ) result = new CMatrix4 ();

            result.matrix3D.copyRawDataTo ( sRawDataHelperL );
            var i : int = 0;
            while ( i < 16 )
            {
                sRawDataHelperL[ i++ ] *= number;
            }
            result.matrix3D.copyRawDataFrom ( sRawDataHelperL );

            return result;
        }

        public static function matrixAddMatrix ( ltm : CMatrix4, rhm : CMatrix4, result : CMatrix4 = null ) : CMatrix4
        {
            ltm.matrix3D.copyRawDataTo ( sRawDataHelperL );
            rhm.matrix3D.copyRawDataTo ( sRawDataHelperR );
            var i : int = 0;
            while ( i < 16 )
            {
                sRawDataHelperL[ i ] += sRawDataHelperR[ i ];
                ++i;
            }

            if( result == null )
                result = new CMatrix4 ();

            result.matrix3D.copyRawDataFrom ( sRawDataHelperL );
            return result;
        }

        public function CMatrix4 ( rawData : Vector.<Number> = null )
        {
            matrix3D = new Matrix3D ( rawData );
        }

        public function copy ( source : CMatrix4 ) : void
        {
            source.matrix3D.copyRawDataTo ( sRawDataHelperL );
            matrix3D.copyRawDataFrom ( sRawDataHelperL );
        }

        public function clone () : CMatrix4
        {
            var cloneMatrix : CMatrix4 = new CMatrix4 ();
            cloneMatrix.copy ( this );

            return cloneMatrix;
        }

        [Inline] final public function identity () : void { matrix3D.identity (); }

        /**
         *  append: eg. two matrix, M and OtherM, if ResultM = OtherM * M, it's called M append OtherM
         *
         * @param ltm
         */
        public function append ( ltm : CMatrix4 ) : void { this.matrix3D.append ( ltm.matrix3D ); }

        /**
         * prepend：eg. two matrix, M and OtherM, if ResultM = M * OtherM, it's called M prepend OtherM
         *
         * @param rhm
         */
        public function prepend ( rhm : CMatrix4 ) : void { this.matrix3D.prepend ( rhm.matrix3D ); }

        public function transformVector ( v : CVector4 ) : CVector4
        {
            var vector : Vector3D = sVector3DHelper;
            vector.x = v.x;
            vector.y = v.y;
            vector.z = v.z;
            vector.w = v.w;
            var vec : Vector3D = this.matrix3D.transformVector ( vector );
            return new CVector4 ( vec.x, vec.y, vec.z, vec.w );
        }

        public function transformVectors ( vin : Vector.<Number>, vout : Vector.<Number> ) : void
        {
            this.matrix3D.transformVectors ( vin, vout );
        }

        public function premultilyVector4( rhv : CVector4 ) : CVector4
        {
            var vec : CVector4 = this.transformVector ( rhv );
            return vec;
        }

        public function premultiplyVector3 ( rhv : CVector3 ) : CVector3
        {
            var resutlt : CVector4 = new CVector4( rhv.x, rhv.y, rhv.z, 1.0 );
            resutlt = premultilyVector4( resutlt );

            return new CVector3( resutlt.x, resutlt.y, resutlt.z );
        }

        public function multiplyNumber ( number : Number ) : void
        {
            this.matrix3D.copyRawDataTo ( sRawDataHelperL );
            var i : int = 0;
            while ( i < 16 )
            {
                sRawDataHelperL[ i++ ] *= number;
            }
            this.matrix3D.copyRawDataFrom ( sRawDataHelperL );
        }

        public function addMatrix ( rhm : CMatrix4 ) : void
        {
            this.matrix3D.copyRawDataTo ( sRawDataHelperL );
            rhm.matrix3D.copyRawDataTo ( sRawDataHelperR );
            var i : int = 0;
            while ( i < 16 )
            {
                sRawDataHelperL[ i ] += sRawDataHelperR[ i ];
                ++i;
            }
            this.matrix3D.copyRawDataFrom ( sRawDataHelperL );
        }

        /**
         *
         * @param axis : x axis, y axis, z aixs
         * @param angle : should be radian
         */
        public function setupNormAxisRotate ( axis : uint, angle : Number) : void
        {
            var cos : Number = Math.cos ( angle );
            var sin : Number = Math.sin ( angle );
            identity ();

            this.matrix3D.copyRawDataTo ( sRawDataHelperL );
            var rawData : Vector.<Number> = sRawDataHelperL;
            switch ( axis )
            {
                case CMath.X_Axis:
                    rawData[ 5 ] = cos; rawData[ 9 ] = -sin;
                    rawData[ 6 ] = sin; rawData[ 10 ] = cos;
                    break;
                case CMath.Y_Axis:
                    rawData[ 0 ] = -sin; rawData[ 8 ] = cos;
                    rawData[ 2 ] = cos; rawData[ 10 ] = sin;
                    break;
                case CMath.Z_Axis:
                    rawData[ 0 ] = cos; rawData[ 4 ] = -sin;
                    rawData[ 1 ] = sin; rawData[ 5 ] = cos;
                    break;
                default:
                    Foundation.Log.logWarningMsg ( "There are only x, y and z axis, please use setupRotate!" );
                    break;
            }
            this.matrix3D.copyRawDataFrom ( rawData );
        }

        /**
         *rotate matrix: v rotate with M => M mul v
         *
         *
         *
         *
         * @param angle
         * @param n
         */
        public function setupRotate ( angle : Number, n : CVector3) : void
        {
            var cos : Number = Math.cos ( angle );
            var oneMimusCos : Number = 1.0 - cos;
            var sin : Number = Math.sin ( angle );

            var nNormal : CVector3 = new CVector3( n.x, n.y, n.z );
            nNormal.normalize ();

            var nxOneMinusCos : Number = nNormal.x * oneMimusCos;
            var nyOneMinusCos : Number = nNormal.y * oneMimusCos;
            var nzOneMinusCos : Number = nNormal.z * oneMimusCos;

            var nxSin : Number = nNormal.x * sin;
            var nySin : Number = nNormal.y * sin;
            var nzSin : Number = nNormal.z * sin;

            this.matrix3D.copyRawDataTo ( sRawDataHelperL );
            var rawData : Vector.<Number> = sRawDataHelperL;
            rawData[ 0 ] = cos + nxOneMinusCos * nNormal.x;       rawData[ 4 ] = -nzSin + nxOneMinusCos * nNormal.y;    rawData[ 8 ] = nySin + nxOneMinusCos * nNormal.z;
            rawData[ 1 ] = nzSin + nyOneMinusCos * nNormal.x;     rawData[ 5 ] = cos + nyOneMinusCos * nNormal.y;       rawData[ 9 ] = -nxSin + nyOneMinusCos * nNormal.z;
            rawData[ 2 ] = nySin + nzOneMinusCos * nNormal.x;     rawData[ 6 ] = -nxSin + nzOneMinusCos * nNormal.y;    rawData[ 10 ] = cos + nzOneMinusCos * nNormal.z;
            rawData[ 3 ] = rawData[ 7 ] = rawData[ 11 ] = 0; rawData[ 15 ] = 1;
            this.matrix3D.copyRawDataFrom ( rawData );
        }

        public function setupNormAxisScale ( axis : uint, k : Number ) : void
        {
            identity ();

            this.matrix3D.copyRawDataTo ( sRawDataHelperL );
            var rawData : Vector.<Number> = sRawDataHelperL;
            switch ( axis )
            {
                case CMath.X_Axis:
                    rawData[ 0 ] = k; break;
                case CMath.Y_Axis:
                    rawData[ 5 ] = k; break;
                case CMath.Z_Axis:
                    rawData[ 10 ] = k; break;
                default:
                    Foundation.Log.logWarningMsg("There are only x, y and z axis, please use setupScale!");
                    break;
            }
            this.matrix3D.copyRawDataFrom ( rawData );
        }

        /**
         *scale matrix
         *| 1 + (k - 1) * nx * nx,  (k - 1) * nx * ny,          (k - 1) * nx * nz       |
         *| (k - 1) * nx * ny,      1 + (k - 1) * ny * ny,      (k - 1) * n             |
         *| (k - 1) * nx * nz,      (k - 1) * ny * nz,          1 + (k - 1) * nz * nz   |
         * @param n
         * @param k
         */
        public function setupAxisScale ( n : CVector3, k : Number ) : void
        {
            var kMinusOne : Number = k - 1;
            var nxMinusK : Number = n.x * kMinusOne;
            var nyMinusK : Number = n.y * kMinusOne;
            var nzMinusK : Number = n.z * kMinusOne;

            this.matrix3D.copyRawDataTo ( sRawDataHelperL );
            var rawData : Vector.<Number> = sRawDataHelperL;
            rawData[ 0 ] = 1 + nxMinusK * n.x;   rawData[ 4 ] = nxMinusK * n.y;       rawData[ 8 ] = nxMinusK * n.z;
            rawData[ 1 ] = nyMinusK * n.x;       rawData[ 5 ] = 1 + nyMinusK * n.y;   rawData[ 9 ] = nyMinusK * n.z;
            rawData[ 2 ] = nzMinusK * n.x;       rawData[ 6 ] = nzMinusK * n.y;       rawData[ 10 ] = 1 + nzMinusK * n.z;
            rawData[ 3 ] = rawData[ 7 ] = rawData[ 11 ] = 0; rawData[ 15 ] = 1;
            this.matrix3D.copyRawDataFrom ( rawData );
        }

        public function setupScale ( scale : CVector3 ) : void
        {
            identity ();

            this.matrix3D.copyRawDataTo ( sRawDataHelperL );
            var rawData : Vector.<Number> = sRawDataHelperL;
            rawData[ 0 ] = scale.x; rawData[ 5 ] = scale.y; rawData[ 10 ] = scale.z;
            this.matrix3D.copyRawDataFrom ( rawData );
        }

        public function setupTranslation ( translation : CVector3 ) : void
        {
            var vector : Vector3D = sVector3DHelper;
            vector.x = translation.x; vector.y = translation.y; vector.z = translation.z;
            vector.w = 1.0;
            this.matrix3D.copyColumnFrom ( 3, vector );
        }

        /**
         *
         * @param axis
         * @param k: indicate the relect plane, like x = k, y = k or z = k
         */
        public function setupNormAxisReflect ( axis : uint, k : Number ) : void
        {
            identity ();

            this.matrix3D.copyRawDataTo ( sRawDataHelperL );
            var rawData : Vector.<Number> = sRawDataHelperL;
            switch ( axis )
            {
                case CMath.X_Axis:
                    rawData[ 0 ] = -1; rawData[ 12 ] = 2 * k; break;
                case CMath.Y_Axis:
                    rawData[ 5 ] = -1; rawData[ 13 ] = 2 * k; break;
                case CMath.Z_Axis:
                    rawData[ 10 ] = -1; rawData[ 14 ] = 2 * k; break;
                default:
                    Foundation.Log.logWarningMsg ( "There are only x, y and z axis, please use setupReflect!" );
                    break;
            }
            this.matrix3D.copyRawDataFrom ( sRawDataHelperL );
        }

        /**
         *
         * @param n: the n vector is perpendicular to the reflect plane
         */
        public function setupReflect ( n : CVector3 ) : void
        {
            var nNormal : CVector3 = new CVector3( n.x, n.y, n.z );
            nNormal.normalize ();

            var nxy : Number = -2 * nNormal.x * nNormal.y;
            var nxz : Number = -2 * nNormal.x * nNormal.z;
            var nyz : Number = -2 * nNormal.y * nNormal.z;

            this.matrix3D.copyRawDataTo ( sRawDataHelperL );
            var rawData : Vector.<Number> = sRawDataHelperL;
            rawData[ 0 ] = 1 - 2 * nNormal.x * nNormal.x;    rawData[ 4 ] = nxy;                              rawData[ 8 ] = nxz;
            rawData[ 1 ] = nxy;                              rawData[ 5 ] = 1 - 2 * nNormal.y * nNormal.y;    rawData[ 9 ] = nyz;
            rawData[ 2 ] = nxz;                              rawData[ 6 ] = nyz;                              rawData[ 10 ] = 1 - 2 * nNormal.z * nNormal.z;
            rawData[ 3 ] = rawData[ 7 ] = rawData[ 11 ] = 0; rawData[ 15 ] = 1;
            this.matrix3D.copyRawDataFrom ( sRawDataHelperL );
        }

        /**
         *projection matrix:
         *
         *
         * @param axis: xAxis means yz plane, yAxis means xz plane, and zAxis mean xy plane
         * @param k
         */
        public function setupNormAxisProjection ( axis : uint, k : Number ) : void
        {
            identity ();

            this.matrix3D.copyRawDataTo ( sRawDataHelperL );
            var rawData : Vector.<Number> = sRawDataHelperL;
            switch ( axis )
            {
                case CMath.X_Axis:
                    rawData[ 0 ] = 0; rawData[ 12 ] = k; break;
                case CMath.Y_Axis:
                    rawData[ 5 ] = 0; rawData[ 13 ] = k; break;
                case CMath.Z_Axis:
                    rawData[ 10 ] = 0; rawData[ 14 ] = k; break;
                default:
                    Foundation.Log.logWarningMsg ( "There are only x, y and z axis, please use setupProjection!" );
                    break;
            }
            this.matrix3D.copyRawDataFrom ( sRawDataHelperL );
        }

        /**
         * projection matrix:
         *
         *
         * @param nNormal : the nNormal vector perpendicular to the projection plane
         */
        public function setupProjection ( n : CVector3 ) : void
        {
            var nNormal : CVector3 = new CVector3( n.x, n.y, n.z );
            nNormal.normalize ();

            var nxy : Number = -nNormal.x * nNormal.y;
            var nxz : Number = -nNormal.x * nNormal.z;
            var nyz : Number = -nNormal.y * nNormal.z;

            this.matrix3D.copyRawDataTo ( sRawDataHelperL );
            var rawData : Vector.<Number> = sRawDataHelperL;
            rawData[ 0 ] = 1 - nNormal.x * nNormal.x;    rawData[ 4 ] = nxy;                          rawData[ 8 ] = nxz;
            rawData[ 1 ] = nxy;                          rawData[ 5 ] = 1 - nNormal.y * nNormal.y;    rawData[ 9 ] = nyz;
            rawData[ 2 ] = nxz;                          rawData[ 6 ] = nyz;                          rawData[ 10 ] = 1 - nNormal.z * nNormal.z;
            rawData[ 3 ] = rawData[ 7 ] = rawData[ 11 ] = 0; rawData[ 15 ] = 1;
            this.matrix3D.copyRawDataFrom ( sRawDataHelperL );
        }

        public function setupNormAxisShear ( axis : uint, s : Number, t : Number) : void
        {
            identity ();

            this.matrix3D.copyRawDataTo ( sRawDataHelperL );
            var rawData : Vector.<Number> = sRawDataHelperL;
            switch ( axis )
            {
                case CMath.X_Axis:
                    rawData[ 1 ] = s; rawData[ 2 ] = t; break;
                case CMath.Y_Axis:
                    rawData[ 4 ] = s; rawData[ 5 ] = t; break;
                case CMath.Z_Axis:
                    rawData[ 8 ] = s; rawData[ 9 ] = t; break;
                default:
                    Foundation.Log.logWarningMsg("There are only x, y and z axis!");
                    break;
            }
            this.matrix3D.copyRawDataFrom ( sRawDataHelperL );
        }

        /**
         * rotation matrix
         * @param quaternion
         */
        public function fromQuaternion ( quaternion : CQuaternion ) : void
        {
            var q : CQuaternion = new CQuaternion ( quaternion.mX, quaternion.mY, quaternion.mZ, quaternion.mW );
            q.normalize ();
            identity ();

            q.toMatrix4( this );
        }

        /**
         * rotation matrix to quaterinion
         * @return
         */
        public function toQuaternion() : CQuaternion
        {
            var result : CQuaternion = new CQuaternion ();
            result.fromMatrix4( this );

            return result;
        }

        public function determinant () : Number { return matrix3D.determinant; }

        public function inverse () : CMatrix4
        {
            var matrix : CMatrix4 = this.clone ();
            matrix.matrix3D.invert ();
            return matrix;
        }

        public function getXScale () : Number
        {
            var vector : Vector3D = sVector3DHelper;
            this.matrix3D.copyColumnTo ( 0, vector );
            var xScale : Number = Math.sqrt( vector.x * vector.x + vector.y * vector.y + vector.z * vector.z );
            if( Math.abs( xScale - 1.0 ) > CMath.EPSILON )
                return xScale;
            else
                return 1.0;
        }

        public function getYScale () : Number
        {
            var vector : Vector3D = sVector3DHelper;
            this.matrix3D.copyColumnTo ( 1, vector );
            var yScale : Number = Math.sqrt( vector.x * vector.x + vector.y * vector.y + vector.z * vector.z  );
            if( Math.abs( yScale - 1.0 ) > CMath.EPSILON )
                return yScale;
            else
                return 1.0;
        }

        public function getZScale () : Number
        {
            var vector : Vector3D = sVector3DHelper;
            this.matrix3D.copyColumnTo ( 2, vector );
            var zScale : Number = Math.sqrt( vector.x * vector.x + vector.y * vector.y + vector.z * vector.z  );
            if( Math.abs( zScale - 1.0 ) > CMath.EPSILON )
                return zScale;
            else
                return 1.0;
        }

        public function getTranslation ( result : CVector3  = null ) : CVector3
        {
            if ( result == null )
                result = CVector3.zero ();
            var vector : Vector3D = sVector3DHelper;
            this.matrix3D.copyColumnTo ( 3, vector );
            result.setValueXYZ ( vector.x, vector.y, vector.z );
            return result;
        }

        /**
         * every four elements makes one column of matrix,
         * rawData[ 12 ] = tx; rawData[ 13 ] = tx; rawData[ 14 ] = tx; rawData[ 15 ] = tx;
         */
        public var matrix3D : Matrix3D = null;
    }
}