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
    public class CQson implements IDisposable
    {
        public function CQson()
        {
        }

        public function dispose() : void
        {
            if( m_theQsonStream != null )
            {
                m_theQsonStream.dispose();
                m_theQsonStream = null;
            }
        }

        [Inline]
        public static function parse( stream : ByteArray ) : Object
        {
            return s_theQson.parse( stream );
        }

        public function parse( stream : ByteArray ) : Object
        {
            if( m_theQsonStream != null ) m_theQsonStream.dispose();
            m_theQsonStream = new CQsonStream( stream );
            if( m_theQsonStream.parseHeader() == false ) return null;

            try
            {
                // parse binary format qson
                var jsonObject : Object = _startParseJsonContainerBinary();
                if( jsonObject == null )
                {
                    m_theQsonStream.dispose();
                    m_theQsonStream = null;
                    Foundation.Log.logErrorMsg( "Failed parsing qson stream." );
                    return null;
                }

                m_theQsonStream.dispose();
                m_theQsonStream = null;
                return jsonObject;
            }
            catch( error : Error )
            {
                m_theQsonStream.dispose();
                m_theQsonStream = null;
                Foundation.Log.logErrorMsg( "Failed parsing qson stream: " + error.message );
                return null;
            }
        }
        
        protected function _startParseJsonContainerBinary() : Object
        {
            var jsonObject : Object = null;

            var iType : int = m_theQsonStream.readByte();
            if( iType == CTokenType.Object )
            {
                jsonObject = _parseJsonObjectBinary();
            }
            else if( iType == CTokenType.Array )
            {
                jsonObject = _parseJsonArrayBinary();
            }

            return jsonObject;
        }

        protected function _parseJsonObjectBinary( theKeyGroup : CKeyGroup  = null ) : Object
        {
            var iPropertyCounts : int;
            iPropertyCounts = m_theQsonStream.readInt();

            var jsonObject : Object = new Object();
            if( iPropertyCounts == 0 ) return jsonObject;

            var jsonValue : Object;
            var eValueType : int;

            if( theKeyGroup != null )
            {
                var bParseEachValueType : Boolean = m_theQsonStream.readBoolean();

                var vKeyTypesList : Vector.<CKeyType> = theKeyGroup.keyTypesList;
                for each( var keyType : CKeyType in vKeyTypesList )
                {
                    // for speed up reason, implement following codes here instead of calling _parseJsonTypeValueBinary()
                    //jsonValue = _parseJsonTypeValueBinary( stream, bParseEachValueType, keyType.m_eValueType, null );
                    {
                        if( bParseEachValueType ) eValueType = m_theQsonStream.readByte();
                        else eValueType = keyType.m_eValueType;

                        if( eValueType == CTokenType.Integer ) jsonValue = m_theQsonStream.readIntFromIndices();
                        else if( eValueType == CTokenType.Float ) jsonValue = m_theQsonStream.readFloatFromIndices();
                        else if( eValueType == CTokenType.String ) jsonValue = m_theQsonStream.readStringFromIndices();
                        else if( eValueType == CTokenType.Boolean ) jsonValue = m_theQsonStream.readBoolean();
                        else if( eValueType == CTokenType.Object ) jsonValue = _parseJsonObjectBinary();
                        else if( eValueType == CTokenType.Array ) jsonValue = _parseJsonArrayBinary();
                        else if( eValueType == CTokenType.Null ) jsonValue = new Object();
                        else if( eValueType == CTokenType.None ) { jsonValue = null; }
                        else Foundation.Log.logErrorMsg( "Exporting an unknown type: " + eValueType.toString() );
                    }

                    if( jsonValue != null ) jsonObject[ keyType.m_sKey ] = jsonValue;
                    // jsonValue == null means no this property(only occurred in using CKeyGroup situation)
                }
            }
            else
            {
                var sTheKey : String;

                for( var i : int = 0; i < iPropertyCounts; i++ )
                {
                    // load the key
                    sTheKey = m_theQsonStream.readKeyFromIndices();
                    if( sTheKey == null )
                    {
                        Foundation.Log.logErrorMsg( "Key index not found: " + sTheKey );
                        return null;
                    }

                    // for speed up reason, implement following codes here instead of calling _parseJsonTypeValueBinary()
                    //jsonValue = _parseJsonTypeValueBinary( stream );
                    {
                        eValueType = m_theQsonStream.readByte();

                        if( eValueType == CTokenType.Integer ) jsonValue = m_theQsonStream.readIntFromIndices();
                        else if( eValueType == CTokenType.Float ) jsonValue = m_theQsonStream.readFloatFromIndices();
                        else if( eValueType == CTokenType.String ) jsonValue = m_theQsonStream.readStringFromIndices();
                        else if( eValueType == CTokenType.Boolean ) jsonValue = m_theQsonStream.readBoolean();
                        else if( eValueType == CTokenType.Object ) jsonValue = _parseJsonObjectBinary( theKeyGroup );
                        else if( eValueType == CTokenType.Array ) jsonValue = _parseJsonArrayBinary();
                        else if( eValueType == CTokenType.Null ) jsonValue = new Object();
                        else if( eValueType == CTokenType.None ) { jsonValue = null; }
                        else Foundation.Log.logErrorMsg( "Exporting an unknown type: " + eValueType.toString() );
                    }

                    if( jsonValue == null )
                    {
                        Foundation.Log.logErrorMsg( "the output jsonValue should not be null here for key: " + sTheKey );
                        return null;
                    }

                    jsonObject[ sTheKey ] = jsonValue;
                }
            }

            return jsonObject;
        }

        protected function _parseJsonArrayBinary() : Object
        {
            var iArrayCounts : int = m_theQsonStream.readInt();

            var jsonArray : Array = new Array( iArrayCounts );
            if( iArrayCounts == 0 ) return jsonArray;

            var iArrayJsonType : int = m_theQsonStream.readByte();

            var theKeyGroup : CKeyGroup = null;
            if( iArrayJsonType == CTokenType.Object )
            {
                theKeyGroup = m_theQsonStream.readKeyGroupFromIndices();
            }

            var jsonValue : Object;

            for( var i : int = 0; i < iArrayCounts; i++ )
            {
                // for speed up reason, implement following codes here instead of calling _parseJsonTypeValueBinary()
                //jsonValue = _parseJsonTypeValueBinary( stream, false, iArrayJsonType, theKeyGroup );
                {
                    //var eValueType : int;
                    //eValueType = iArrayJsonType;

                    if( iArrayJsonType == CTokenType.Integer ) jsonValue = m_theQsonStream.readIntFromIndices();
                    else if( iArrayJsonType == CTokenType.Float ) jsonValue = m_theQsonStream.readFloatFromIndices();
                    else if( iArrayJsonType == CTokenType.String ) jsonValue = m_theQsonStream.readStringFromIndices();
                    else if( iArrayJsonType == CTokenType.Boolean ) jsonValue = m_theQsonStream.readBoolean();
                    else if( iArrayJsonType == CTokenType.Object ) jsonValue = _parseJsonObjectBinary( theKeyGroup );
                    else if( iArrayJsonType == CTokenType.Array ) jsonValue = _parseJsonArrayBinary();
                    else if( iArrayJsonType == CTokenType.Null ) jsonValue = new Object();
                    else if( iArrayJsonType == CTokenType.None ) { jsonValue = null; }
                    else Foundation.Log.logErrorMsg( "Exporting an unknown type: " + iArrayJsonType.toString() );
                }

                if( jsonValue == null )
                {
                    Foundation.Log.logErrorMsg( "the output jsonValue should not be null here in array..." );
                    return null;
                }

                jsonArray[ i ] = jsonValue;
            }

            return jsonArray;
        }

        protected function _parseJsonTypeValueBinary( stream : ByteArray, bParseValueType : Boolean = true, eSpecifiedValueType : int = 0/*JTokenType.None*/, theKeyGroup : CKeyGroup = null ) : Object
        {
            var eValueType : int;
            if( bParseValueType ) eValueType = m_theQsonStream.readByte();
            else eValueType = eSpecifiedValueType;

            var jsonValue : Object;

            if( eValueType == CTokenType.Integer ) jsonValue = m_theQsonStream.readIntFromIndices();
            else if( eValueType == CTokenType.Float ) jsonValue = m_theQsonStream.readFloatFromIndices();
            else if( eValueType == CTokenType.String ) jsonValue = m_theQsonStream.readStringFromIndices();
            else if( eValueType == CTokenType.Boolean ) jsonValue = m_theQsonStream.readBoolean();
            else if( eValueType == CTokenType.Object ) jsonValue = _parseJsonObjectBinary( theKeyGroup );
            else if( eValueType == CTokenType.Array ) jsonValue = _parseJsonArrayBinary();
            else if( eValueType == CTokenType.Null ) jsonValue = new Object();
            else if( eValueType == CTokenType.None ) { jsonValue = null; }
            else Foundation.Log.logErrorMsg( "Exporting an unknown type: " + eValueType.toString() );

            return jsonValue;
        }

        //
        protected var m_theQsonStream : CQsonStream = null;

        private static var s_theQson : CQson = new CQson();
    }
}
