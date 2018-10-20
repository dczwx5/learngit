//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/7/4
//----------------------------------------------------------------------------------------------------------------------

package QFLib.Foundation
{

//
    //
    //
    public class CAverager
    {
        public function CAverager( iLength : int )
        {
            m_theArray = new Array( iLength );
        }

        public function count( fNumber : Number ) : Number
        {
            m_theArray[ m_iCurIdx ] = fNumber;
            if( m_iCurIdx >= m_theArray.length )
            {
                m_iCurIdx = 0;
                m_bFull = true;
            }

            var fSum : Number = 0.0;

            var iLen : int = m_theArray.length;
            if( m_bFull == false ) iLen = m_iCurIdx + 1;
            for( var i : int = 0; i < iLen; i++ )
            {
                fSum += m_theArray[ i ];
            }

            fSum /= iLen;
            return fSum;
        }


        //
        protected var m_theArray : Array = null;
        protected var m_iCurIdx : int = 0;
        protected var m_bFull : Boolean = false;
    }
 }
