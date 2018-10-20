//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/7/4
//----------------------------------------------------------------------------------------------------------------------

package QFLib.Qson
{
//
    internal class CKeyType
    {
        public function CKeyType( iKeyIndex : int, sKey : String, eValueTypes : int )
        {
            m_iKeyIndex = iKeyIndex;
            m_sKey = sKey;
            m_eValueType = eValueTypes;
        }

        public var m_sKey : String;
        public var m_eValueType : int;
        public var m_iKeyIndex : int;
    }
}
