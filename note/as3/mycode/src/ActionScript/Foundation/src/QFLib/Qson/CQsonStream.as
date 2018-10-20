//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/7/4
//----------------------------------------------------------------------------------------------------------------------

package QFLib.Qson
{
    import QFLib.Foundation;
    import QFLib.Interface.IDisposable;
    import flash.utils.ByteArray;
    //
    //
    //
    public class CQsonStream implements IDisposable
    {
        public function CQsonStream( stream : ByteArray )
        {
            setStream( stream );
        }

        public function dispose() : void
        {
            _clearAllIndices();

            m_sFormat = null;
            m_byVersion = 0;
            m_theStream.dispose();
        }

        public function parseHeader() : Boolean
        {
            confirmStream();

            // read header
            m_sFormat = readString();
            m_byVersion = readByte();

            try
            {
                // load key indices
                _clearAllIndices();
                var iResult : int = _parseKeyIndicesMapBinary();
                if( iResult != 0 )
                {
                    Foundation.Log.logErrorMsg( "Failed parsing key indices from stream." );
                    return false;
                }

                return true;
            }
            catch( error : Error )
            {
                _clearAllIndices();
                Foundation.Log.logErrorMsg( "Failed parsing qson stream: " + error.message );
                return false;
            }
        }

        public function setStream( stream : ByteArray ) : void
        {
            m_theStream = new CStream(stream);
        }

        public function confirmStream() : void
        {
            m_theStream.setSelfStream();
        }

        //
        [Inline]
        final public function readString() : String
        {
            return m_theStream.readString();
        }

        [Inline]
        final public function readInt() : int
        {
            return m_theStream.readInt();
        }
        [Inline]
        final public function readUnsignedShort() : uint
        {
            return m_theStream.readUnsignedShort();
        }
        [Inline]
        final public function readByte() : int
        {
            return m_theStream.readByte();
        }
        [Inline]
        final public function readBoolean() : Boolean
        {
            return m_theStream.readBoolean();
        }
        [Inline]
        final public function readFloat() : Number
        {
           return m_theStream.readFloat();
        }

        [Inline]
        final public function readIntFromIndices() : int
        {
            return m_vIntegerValueReverseIndices[ readUnsignedShort() ];
        }
        [Inline]
        final public function readFloatFromIndices() : Number
        {
            return m_vFloatValueReverseIndices[ readUnsignedShort() ];
        }
        [Inline]
        final public function readStringFromIndices() : String
        {
            return m_vStringValueReverseIndices[ readUnsignedShort() ];
        }
        [Inline]
        final public function readKeyFromIndices() : String
        {
            return m_vKeyReverseIndices[ readUnsignedShort() ];
        }
        [Inline]
        final public function readKeyGroupFromIndices() : CKeyGroup
        {
            return m_vKeyGroupReverseIndices[ readInt() ] as CKeyGroup;
        }

        //
        //
        protected function _parseKeyIndicesMapBinary() : int
        {
            var iIndicesCount : int;
            var sKey : String;
            var fKey : Number;
            var iKey : int;
            var nValue : uint;
            var i : int;

            iIndicesCount = readInt();
            m_vKeyReverseIndices.length = iIndicesCount + 1; // index begins from 1
            for( i = 0; i < iIndicesCount; i++ )
            {
                sKey = readString();
                nValue = readUnsignedShort();

                m_vKeyReverseIndices[ nValue ] = sKey;
            }

            iIndicesCount = readInt();
            m_vStringValueReverseIndices.length = iIndicesCount + 1; // index begins from 1
            for( i = 0; i < iIndicesCount; i++ )
            {
                sKey = readString();
                nValue = readUnsignedShort();

                m_vStringValueReverseIndices[ nValue ] = sKey;
            }

            iIndicesCount = readInt();
            m_vFloatValueReverseIndices.length = iIndicesCount + 1; // index begins from 1
            for( i = 0; i < iIndicesCount; i++ )
            {
                fKey = readFloat();
                nValue = readUnsignedShort();

                m_vFloatValueReverseIndices[ nValue ] = fKey;
            }

            iIndicesCount = readInt();
            m_vIntegerValueReverseIndices.length = iIndicesCount + 1; // index begins from 1
            for( i = 0; i < iIndicesCount; i++ )
            {
                iKey = readInt();
                nValue = readUnsignedShort();

                m_vIntegerValueReverseIndices[ nValue ] = iKey;
            }

            iIndicesCount = readInt();
            m_vKeyGroupReverseIndices.length = iIndicesCount + 1; // index begins from 1
            for( i = 0; i < iIndicesCount; i++ )
            {
                var theKeyGroup : CKeyGroup = new CKeyGroup();
                if( theKeyGroup.read( this ) == false ) return -1;
                m_vKeyGroupReverseIndices[ theKeyGroup.groupIndex ] = theKeyGroup;
            }

            if( m_vKeyReverseIndices.length > 65535 )
            {
                Foundation.Log.logErrorMsg( "Key indices cannot exceed more than 65535:(current key indices count: " + m_vKeyReverseIndices.length );
                return -1010;
            }
            if( m_vStringValueReverseIndices.length > 65535 )
            {
                Foundation.Log.logErrorMsg( "String Value indices cannot exceed more than 65535:(current string value indices count: " + m_vStringValueReverseIndices.length );
                return -1011;
            }
            if( m_vFloatValueReverseIndices.length > 65535 )
            {
                Foundation.Log.logErrorMsg( "Float Value indices cannot exceed more than 65535:(current float value indices count: " + m_vFloatValueReverseIndices.length );
                return -1012;
            }
            if( m_vIntegerValueReverseIndices.length > 65535 )
            {
                Foundation.Log.logErrorMsg( "Integer Value indices cannot exceed more than 65535:(current int value indices count: " + m_vIntegerValueReverseIndices.length );
                return -1012;
            }
            if( m_vKeyGroupReverseIndices.length > 65535 )
            {
                Foundation.Log.logErrorMsg( "KeyGroup indices cannot exceed more than 65535:(current keyGroup indices count: " + m_vKeyGroupReverseIndices.length );
                return -1013;
            }

            return 0;
        }

        protected function _clearAllIndices() : void
        {
            m_vKeyReverseIndices.length = 0;
            m_vStringValueReverseIndices.length = 0;
            m_vFloatValueReverseIndices.length = 0;
            m_vIntegerValueReverseIndices.length = 0;
            m_vKeyGroupReverseIndices.length = 0;
        }

        //
        protected var m_vKeyReverseIndices : Vector.<String> = new Vector.<String>();
        protected var m_vStringValueReverseIndices : Vector.<String> = new Vector.<String>();
        protected var m_vFloatValueReverseIndices : Vector.<Number> = new Vector.<Number>();
        protected var m_vIntegerValueReverseIndices : Vector.<int> = new Vector.<int>();
        protected var m_vKeyGroupReverseIndices : Vector.<Object> = new Vector.<Object>();

        protected var m_sFormat : String = null;
        protected var m_byVersion : int = 0;

        private var m_theStream : CStream;
    }
}
