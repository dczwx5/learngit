//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/7/4
//----------------------------------------------------------------------------------------------------------------------

package QFLib.Qson
{
    import QFLib.Foundation.*;
    //
    //
    //
    internal class CKeyGroup
    {

        //
        public function CKeyGroup()
        {
        }

        public function reset() : void
        {
            m_mapKeyIndices.clear();
            m_vKeyTypes.length = 0;
            m_iGroupIndex = 0;
        }

        [Inline]
        final public function get groupIndex() : int
        {
            return m_iGroupIndex;
        }
        [Inline]
        final public function set groupIndex( iIndex : int ) : void
        {
            m_iGroupIndex = iIndex;
        }
        [Inline]
        final public function get keyTypesList() : Vector.<CKeyType>
        {
            return m_vKeyTypes;
        }

        [Inline]
        final public function find( iKeyIndex : int ) : int
        {
            return m_mapKeyIndices.find( iKeyIndex );
        }
        public function add( iKeyIndex : int, sKey : String, eValueType : int ) : void
        {
            var keyType : CKeyType;

            if( m_mapKeyIndices.find( iKeyIndex ) == null )
            {
                m_mapKeyIndices.add( iKeyIndex, m_vKeyTypes.length );

                keyType = new CKeyType( iKeyIndex, sKey, eValueType );
                m_vKeyTypes.push( keyType );
            }
            else
            {
                var iIndexInList : int  = m_mapKeyIndices.find( iKeyIndex ) as int;
                keyType = m_vKeyTypes[ iIndexInList ];
                if( keyType.m_eValueType == CTokenType.Integer && eValueType == CTokenType.Float )
                {
                    keyType.m_eValueType = CTokenType.Float;
                }
            }
        }

        public function read( theQsonStream : CQsonStream ) : Boolean
        {
            m_iGroupIndex = theQsonStream.readInt();

            var iCounts : int;
            var iKeyIndex : int;
            var iValueType : int;
            var sKey : String;
            var keyType : CKeyType;

            iCounts = theQsonStream.readInt();
            m_vKeyTypes.length = iCounts;
            for( var i : int = 0; i < iCounts; i++ )
            {
                iKeyIndex = theQsonStream.readInt();
                sKey = theQsonStream.readString();
                iValueType = theQsonStream.readInt();

                keyType = new CKeyType( iKeyIndex, sKey, iValueType );
                m_mapKeyIndices.add( iKeyIndex, i );
                m_vKeyTypes[ i ] = keyType;
            }

            return true;
        }


        //
        protected var m_mapKeyIndices : CMap = new CMap();
        protected var m_vKeyTypes : Vector.<CKeyType> = new Vector.<CKeyType>();
        protected var m_iGroupIndex : int = 0;
    }
}
