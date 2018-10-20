//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by david on 2016/11/10.
 */
package QFLib.Math
{
    /**
     * Left Hand Coordinate System
     */
    public class CEuler
    {
        private static const sRawDataHelper : Vector.<Number> = new <Number>[ 1.0, 0.0, 0.0, 0.0,
            0.0, 1.0, 0.0, 0.0,
            0.0, 0.0, 1.0, 0.0,
            0.0, 0.0, 0.0, 1.0 ];
        public function CEuler ( x : Number = 0, y : Number = 0, z : Number = 0 )
        {
            m_Heading = y;
            m_Pitch = x;
            m_Bank = z;
        }

        public function copy ( source : CEuler ) : void
        {
            m_Heading = source.m_Heading;
            m_Pitch = source.m_Pitch;
            m_Bank = source.m_Bank;
        }

        public function clone () : CEuler
        {
            return new CEuler ( this.m_Heading, this.m_Pitch, this.m_Bank );
        }

        public function identity () : void
        {
            m_Heading = m_Pitch = m_Bank = 0;
        }

        /**
         * rotate y axis
         * @param value;
         */
        public function setHeading ( value : Number ) : void
        {
            m_Heading = value;
        }

        /**
         * rotate x axis
         * @param value;
         */
        public function setPitch ( value : Number ) : void
        {
            m_Pitch = value;
        }

        /**
         * rotate z axis
         * @param value;
         */
        public function setBank ( value : Number ) : void
        {
            m_Bank = value;
        }

        public function get Heading () : Number
        {
            return m_Heading;
        }

        public function get Pitch () : Number
        {
            return m_Heading;
        }

        public function get Bank () : Number
        {
            return m_Heading;
        }

        /**
         * m_Heading-[-kPi, kPi], m_Pitch-(-kPiOver2, kPiOver2), m_Bank-[-kPi, kPi]
         */
        public function canonize () : void
        {
            m_Heading = CMath.wrapPi ( m_Heading );
            m_Bank = CMath.wrapPi ( m_Bank );

            m_Pitch = CMath.wrapPi ( m_Pitch );
            if ( m_Pitch < -CMath.PIOver2 )
            {
                m_Pitch = -CMath.PI - m_Pitch;
                m_Heading += CMath.PI;
                m_Bank += CMath.PI;
            }
            else if ( m_Pitch > CMath.PIOver2 )
            {
                m_Pitch = CMath.PI - m_Pitch;
                m_Heading += CMath.PI;
                m_Bank += CMath.PI;
            }

            //check gimbal lock
            if ( Math.abs ( m_Pitch ) + 0.00001 > CMath.PIOver2 )
            {
                m_Heading += m_Bank;
                m_Bank = 0.0;
            }
            else
            {
                m_Bank = CMath.wrapPi ( m_Bank );
            }

            m_Heading = CMath.wrapPi ( m_Heading );
        }

        /**
         * @param mat
         * mat = M(-h) * M(-p) * M(-b), we use column vector, so mat = M(-b)M(-p)M(-h)
         * M(-h) = | cos(-h),  0,    sin(-h) |   M(-p) = | 1,    0,                0    |   M(-b) = | cos(-b),  -sin(-b), 0 |
         *         | 0,        1,    0       |           | 0,    cos(-p),    -sin(-p)   |           | sin(-b),  cos(-b),  0 |
         *         | -sin(-h), 0,    cos(-h) |           | 0,    sin(-p),    cos(-p)    |           | 0,         0,       1 |
         *
         * mat =  | cos(h)cos(b) + sin(h)sin(p)sin(b),            sin(b)cos(p),    -sin(h)cos(b) + cos(h)sin(p)sin(b)  |
         *        | -cos(h)sin(b) + sin(h)sin(p)cos(b),            cos(b)cos(p),    sin(b)sin(h) + con(h)sin(p)cons(b) |
         *        | sin(h)cos(p),                                    -sin(p),        cos(h)cos(p)                      |
         * (Remember that we use left hand coordinate system, column vector)
         *
         */
        public function fromInertialToObjectMatrix ( mat : CMatrix4 ) : void
        {
            var rawData : Vector.<Number> = mat.matrix3D.rawData;
            var sp : Number = -rawData[ 6 ];
            if ( sp <= -1.0 )
            {
                m_Pitch = -CMath.PIOver2;
            }
            else if ( sp >= 1.0 )
            {
                m_Pitch = CMath.PIOver2;
            }
            else
            {
                m_Pitch = Math.asin ( sp );
            }

            //avoid gimbal lock
            if ( Math.abs ( sp - 1.0 ) > CMath.EPSILON )
            {
                m_Bank = 0.0;
                m_Heading = Math.atan2 ( -rawData[ 8 ], rawData[ 0 ] );
            }
            else
            {
                m_Heading = Math.atan2 ( rawData[ 2 ], rawData[ 10 ] );
                m_Bank = Math.atan2 ( rawData[ 4 ], rawData[ 5 ] );
            }
        }

        /**
         * @param mat
         * mat is transposed matrix of matrix that inertial to object
         */
        public function fromObjectToInertialMatrix ( mat : CMatrix4 ) : void
        {
            var rawData : Vector.<Number> = mat.matrix3D.rawData;
            var sp : Number = -rawData[ 9 ];
            if ( sp <= -1.0 )
            {
                m_Pitch = -CMath.PIOver2;
            }
            else if ( sp >= 1.0 )
            {
                m_Pitch = CMath.PIOver2;
            }
            else
            {
                m_Pitch = Math.asin ( sp );
            }

            //avoid gimbal lock
            if ( Math.abs ( sp ) > 0.9999 )
            {
                m_Bank = 0.0;
                m_Heading = Math.atan2 ( -rawData[ 2 ], rawData[ 0 ] );
            }
        else
            {
                m_Heading = Math.atan2 ( rawData[ 8 ], rawData[ 10 ] );
                m_Bank = Math.atan2 ( rawData[ 4 ], rawData[ 5 ] );
            }
        }

        /**
         * @param result: rotation matrix
         * | cos(h)cos(b) + sin(h)sin(p)sin(b),            sin(b)cos(p),    -sin(h)cos(b) + cos(h)sin(p)sin(b)  |
         * | -cos(h)sin(b) + sin(h)sin(p)cos(b),            cos(b)cos(p),    sin(b)sin(h) + cos(h)sin(p)cons(b) |
         * | sin(h)cos(p),                                    -sin(p),        cos(h)cos(p)                      |
         */
        public function toInertialToObjectMatrix ( result : CMatrix4 = null ) : CMatrix4
        {
            if ( result == null ) result = new CMatrix4 ();

            var sp : Number = Math.sin ( m_Pitch );
            var cp : Number = Math.cos ( m_Pitch );
            var sh : Number = Math.sin ( m_Heading );
            var ch : Number = Math.cos ( m_Heading );
            var sb : Number = Math.sin ( m_Bank );
            var cb : Number = Math.cos ( m_Bank );

            var chcb : Number = ch * cb;
            var chsb : Number = ch * sb;
            var shsp : Number = sh * sp;

            var rawData : Vector.<Number> = sRawDataHelper;
            rawData[ 0 ] = chcb + shsp * sb;
            rawData[ 4 ] = sb * cp;
            rawData[ 8 ] = -sh * cb + chsb * sp;
            rawData[ 1 ] = -chsb;
            rawData[ 5 ] = cb * cp;
            rawData[ 9 ] = sb * sh + chcb * sp;
            rawData[ 2 ] = sh * cp;
            rawData[ 6 ] = -sp;
            rawData[ 10 ] = ch * cp;

            rawData[ 12 ] = rawData[ 13 ] = rawData[ 14 ] = 0.0;
            result.matrix3D.copyRawDataFrom ( rawData );

            return result;
        }


        /**
         * transposed of inertial to object matrix
         * @param result
         */
        public function toObjectToInertialMatrix ( result : CMatrix4 = null ) : CMatrix4
        {
            if ( result == null ) result = new CMatrix4 ();

            var sp : Number = Math.sin ( m_Pitch );
            var cp : Number = Math.cos ( m_Pitch );
            var sh : Number = Math.sin ( m_Heading );
            var ch : Number = Math.cos ( m_Heading );
            var sb : Number = Math.sin ( m_Bank );
            var cb : Number = Math.cos ( m_Bank );

            var chcb : Number = ch * cb;
            var chsb : Number = ch * sb;
            var shsp : Number = sh * sp;

            var rawData : Vector.<Number> = sRawDataHelper;
            rawData[ 0 ] = chcb + shsp * sb;
            rawData[ 1 ] = sb * cp;
            rawData[ 2 ] = -sh * cb + chsb * sp;
            rawData[ 4 ] = -chsb;
            rawData[ 5 ] = cb * cp;
            rawData[ 6 ] = sb * sh + chcb * sp;
            rawData[ 8 ] = sh * cp;
            rawData[ 9 ] = -sp;
            rawData[ 10 ] = ch * cp;

            rawData[ 12 ] = rawData[ 13 ] = rawData[ 14 ] = 0.0;
            result.matrix3D.copyRawDataFrom ( rawData );

            return result;
        }

        /**
         * refer to the quaternion rotation matrix and eluer rotation matrix
         * @param quat
         */
        public function fromInertialToObjectQuaternion ( quat : CQuaternion ) : void
        {
            var sp : Number = -2.0 * ( quat.mY * quat.mZ + quat.mW * quat.mX );

            //avoid gimbal locl
            if ( Math.abs ( sp ) > 0.9999 )
            {
                m_Pitch = CMath.PIOver2 * sp;
                m_Bank = 0.0;
                m_Heading = Math.atan2 ( -quat.mX * quat.mZ - quat.mW * quat.mY,
                        0.5 - quat.mY * quat.mY - quat.mZ * quat.mZ );
            }
            else
            {
                m_Pitch = Math.asin ( sp );

                m_Heading = Math.atan2 ( quat.mX * quat.mZ - quat.mW * quat.mY,
                        0.5 - quat.mX * quat.mX - quat.mY * quat.mY );

                m_Bank = Math.atan2 ( quat.mX * quat.mY - quat.mW * quat.mZ,
                        0.5 - quat.mX * quat.mX - quat.mZ * quat.mZ );
            }
        }

        /**
         * quat is conjugate of inertial to object quaternion
         * @param quat
         */
        public function fromObjectToInertialQuaternion ( quat : CQuaternion ) : void
        {
            var sp : Number = -2.0 * ( quat.mY * quat.mZ - quat.mW * quat.mX );

            //avoid gimbal locl
            if ( Math.abs ( sp ) > 0.9999 )
            {
                m_Pitch = CMath.PIOver2 * sp;
                m_Bank = 0.0;
                m_Heading = Math.atan2 ( -quat.mX * quat.mZ + quat.mW * quat.mY,
                        0.5 - quat.mY * quat.mY - quat.mZ * quat.mZ );
            }
            else
            {
                m_Pitch = Math.asin ( sp );

                m_Heading = Math.atan2 ( quat.mX * quat.mZ + quat.mW * quat.mY,
                        0.5 - quat.mX * quat.mX - quat.mY * quat.mY );

                m_Bank = Math.atan2 ( quat.mX * quat.mY + quat.mW * quat.mZ,
                        0.5 - quat.mX * quat.mX - quat.mZ * quat.mZ );
            }
        }

        /**
         * @param result
         * result = Q(-h) * Q(-p) * Q(-b)
         * result.w = cos(h/2)cos(p/2)cos(b/2) + sin(h/2)sin(p/2)sin(b/2)
         * result.x = -cos(h/2)sin(p/2)cos(b/2) -sin(h/2)cos(p/2)sin(b/2)
         * result.y = cos(h/2)sin(p/2)sin(b/2) - sin(h/2)cos(p/2)cos(b/2)
         * result.z = sin(h/2)sin(p/2)cos(b/2) - cos(h/2)cos(p/2)sin(b/2)
         */
        public function toInertialToObjectQuaternion ( result : CQuaternion ) : CQuaternion
        {
            if ( result == null ) result = new CQuaternion ();

            var hOver2 : Number = m_Heading * 0.5;
            var pOver2 : Number = m_Pitch * 0.5;
            var bOver2 : Number = m_Bank * 0.5;

            var ch : Number = Math.cos ( hOver2 );
            var cp : Number = Math.cos ( pOver2 );
            var cb : Number = Math.cos ( bOver2 );
            var sh : Number = Math.sin ( hOver2 );
            var sp : Number = Math.sin ( pOver2 );
            var sb : Number = Math.sin ( bOver2 );

            var chcp : Number = ch * cp;
            var shsp : Number = sh * sp;
            var cpcb : Number = cp * cb;
            var spsb : Number = sp * sb;

            result.mW = chcp * cb + shsp * sb;
            result.mX = -ch * sp * cb - sh * cp * sb;
            result.mY = ch * spsb - sh * cpcb;
            result.mZ = shsp * cb - chcp * sb;

            return result;
        }

        /**
         * get conjugate of inertial to object quaternion
         * Q^-1 = Q^* / |Q|^2, Q is unit quaternion, so |Q|^2 = 1, Q^* is conjugate of Q
         * @param result
         */
        public function toObjectToInertialQuaternion ( result : CQuaternion ) : CQuaternion
        {
            if ( result == null ) result = new CQuaternion ();

            var hOver2 : Number = m_Heading * 0.5;
            var pOver2 : Number = m_Pitch * 0.5;
            var bOver2 : Number = m_Bank * 0.5;

            var ch : Number = Math.cos ( hOver2 );
            var cp : Number = Math.cos ( pOver2 );
            var cb : Number = Math.cos ( bOver2 );
            var sh : Number = Math.sin ( hOver2 );
            var sp : Number = Math.sin ( pOver2 );
            var sb : Number = Math.sin ( bOver2 );

            var chcp : Number = ch * cp;
            var shsp : Number = sh * sp;
            var cpcb : Number = cp * cb;
            var spsb : Number = sp * sb;

            result.mW = chcp * cb + shsp * sb;
            result.mX = ch * sp * cb + sh * cp * sb;
            result.mY = sh * cpcb - ch * spsb;
            result.mZ = chcp * sb - shsp * cb;

            return result;
        }

        //define the rotate order in object coordinate system: heading, pitch, bank
        public var m_Heading : Number = 0;
        public var m_Pitch : Number = 0;
        public var m_Bank : Number = 0;
    }
}
