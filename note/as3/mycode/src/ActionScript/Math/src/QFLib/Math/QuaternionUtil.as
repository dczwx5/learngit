//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by david on 2017/1/11.
 */
package QFLib.Math
{
    public class QuaternionUtil
    {
        public static function normalized ( quat : CQuaternion ) : CQuaternion
        {
            var normQuat : CQuaternion = new CQuaternion ( quat.mX, quat.mY, quat.mZ, quat.mW );
            var magnitude : Number = normQuat.magnitude ();
            if ( magnitude > 0 && Math.abs ( magnitude - 1.0 ) > CMath.EPSILON )
            {
                normQuat.mX /= magnitude;
                normQuat.mY /= magnitude;
                normQuat.mZ /= magnitude;
                normQuat.mW /= magnitude;
            }

            return normQuat;
        }

        public static function quaternionMultiple ( ltq : CQuaternion, rhq : CQuaternion, result : CQuaternion = null ) : CQuaternion
        {
            if ( result == null )
            {
                result = CQuaternion.identity;
            }

            var x : Number;
            var y : Number;
            var z : Number;
            var w : Number;
            w = ltq.mW * rhq.mW - ltq.mX * rhq.mX - ltq.mY * rhq.mY - ltq.mZ * rhq.mZ;
            x = ltq.mW * rhq.mX + ltq.mX * rhq.mW + ltq.mY * rhq.mZ - ltq.mZ * rhq.mY;
            y = ltq.mW * rhq.mY + ltq.mY * rhq.mW + ltq.mX * rhq.mZ - ltq.mZ * rhq.mX;
            z = ltq.mW * rhq.mZ + ltq.mZ * rhq.mW + ltq.mX * rhq.mY - ltq.mY * rhq.mX;

            result.setValueXYZW( x, y, z, w );
            return result;
        }
    }
}
