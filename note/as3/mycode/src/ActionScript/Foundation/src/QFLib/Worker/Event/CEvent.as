package QFLib.Worker.Event
{
    import flash.utils.ByteArray;
    import flash.utils.getQualifiedClassName;

    public class CEvent
	{
        public function CEvent()
        {
            m_theJson.eventInfoClassName = getQualifiedClassName( this );
            m_theJson.eventInfoIndex = 0;
            m_theJson.eventInfoByteArrayLength = 0;
        }

        [Inline]
        public final function get eventClassName() : String { return m_theJson.eventInfoClassName; }
        [Inline]
        public final function get eventNumByteArrays() : int { return m_theJson.eventInfoByteArrayLength; }
        [Inline]
        public final function get eventIndex() : uint { return m_theJson.eventInfoIndex; }
        [Inline]
        public final function set eventIndex( iIdx : uint ) : void { m_theJson.eventInfoIndex = iIdx; }

        [Inline]
        public final function get jsonObject() : Object { return m_theJson; }
        [Inline]
        public final function set jsonObject( jsonObject : Object ) : void { m_theJson = jsonObject; }

        //
        public final function setByteArray( iIdx : int, aBytes : ByteArray ) : void
        {
            if( m_aByteArrays == null ) m_aByteArrays = new Array();
            if( iIdx >= m_aByteArrays.length ) m_aByteArrays.length = iIdx + 1;
            m_aByteArrays[ iIdx ] = aBytes;
        }
        public final function getByteArray( iIdx : int ) : ByteArray
        {
            if( m_aByteArrays == null ) return null;
            if( iIdx >= m_aByteArrays.length ) return null;
            return m_aByteArrays[ iIdx ]
        }
        public final function getNumByteArrays() : int
        {
            if( m_aByteArrays == null ) return 0;
            else return m_aByteArrays.length;
        }

        //
        public function serialize() : ByteArray
        {
            if( m_aByteArrays != null )
            {
                m_theJson.eventInfoByteArrayLength = m_aByteArrays.length;
                for( var i : int = 0; i < m_aByteArrays.length; i++ )
                {
                    if( m_aByteArrays[ i ] != null ) m_aByteArrays[ i ].shareable = true;
                }
            }

            var aBytes : ByteArray = new ByteArray();
            aBytes.writeObject( m_theJson );
            aBytes.position = 0;
            aBytes.shareable = true;
            return aBytes;
        }
        public static function unSerialize( aBytes : ByteArray ) : Object
        {
            aBytes.position = 0;
            var jsonObject : Object = aBytes.readObject();
            return jsonObject;
        }

        //
        protected var m_theJson : Object = new Object;
        protected var m_aByteArrays : Array = null;
	}
}