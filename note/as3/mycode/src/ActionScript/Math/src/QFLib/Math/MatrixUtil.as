//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by david on 2016/11/16.
 */
package QFLib.Math
{
    public class MatrixUtil
    {
        /**
         *
         * @param ltm
         * @param rhm
         * @param result
         * @return
         */
        public static function matrixMultiply ( ltm : CMatrix4, rhm : CMatrix4, result : CMatrix4  = null ) : CMatrix4
        {
            if( result == null )
                result = new CMatrix4 ();

            result.copy ( rhm );
            result.append ( ltm );
            return result;
        }

        public static function matrixPremultipyVector4 ( matrix : CMatrix4, vec : CVector4, result : CVector4 = null ) : CVector4
        {
            result = matrix.transformVector ( vec );
            return result;
        }

        private static var sVectorHelper : CVector4 = new CVector4 ();
    }
}
