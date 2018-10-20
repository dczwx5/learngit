//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/9/30
//----------------------------------------------------------------------------------------------------------------------

package QFLib.Foundation
{
    import QFLib.Foundation;
    import QFLib.Interface.IDisposable;

    //
    //
    //
    public class CTextParser implements IDisposable
    {
        public function CTextParser( sTokenCharSet : String = null, sSeparatorCharSet : String = null ) // vTokenCharSet: each char in this string will be treated as a token,
        {
            m_theTextStream = null;

            var i : int;
            if( sTokenCharSet != null )
            {
                m_vTokenChars = new Vector.<String>( sTokenCharSet.length );
                for( i = 0; i < sTokenCharSet.length; i++ ) m_vTokenChars[ i ] = sTokenCharSet.charAt( i );
            }
            else m_vTokenChars = new Vector.<String>( 0 );

            if( sSeparatorCharSet != null )
            {
                m_vSeparatorChars = new Vector.<String>( sSeparatorCharSet.length );
                for( i = 0; i < sSeparatorCharSet.length; i++ ) m_vSeparatorChars[ i ] = sSeparatorCharSet.charAt( i );
            }
            else
            {
                m_vSeparatorChars = new Vector.<String>( s_aSeparatorCharSet.length );
                for( i = 0; i < s_aSeparatorCharSet.length; i++ )
                {
                    m_vSeparatorChars[ i ] = s_aSeparatorCharSet[ i ];
                }
            }

            _removeTokenCharsFromSeparatorChars();

            m_vCachedTokens = new Vector.<String>();

            m_iCurParsingLine = 0;
            m_cCacheChar = null;
            m_cNextLineFlag = null;
        }

        public function dispose() : void
        {
            if( m_theTextStream != null )
            {
                m_theTextStream.close();
                m_theTextStream = null;
            }
        }

        public function bindStream( str : String ) : void // once the parser exists, the stream that passed into this should always valid.
        {
            if( m_theTextStream != null )
            {
                m_theTextStream.close();
                m_theTextStream = null;
            }

            m_iCurParsingLine = 0;
            m_theTextStream = new _CStringStream( str );
        }

        public function get tokenChars() : Vector.<String>
        {
            return m_vTokenChars;
        }
        public function set tokenChars( vChars : Vector.<String> ) : void
        {
            m_vTokenChars = vChars;
            _removeTokenCharsFromSeparatorChars();
        }
        public function get separatorChars() : Vector.<String>
        {
            return m_vSeparatorChars;
        }
        public function set separatorChars( vChars : Vector.<String> ) : void
        {
            m_vSeparatorChars = vChars;
            _removeTokenCharsFromSeparatorChars();
        }

        public function hasMoreToken() : Boolean
        {
            var s : String;
            if( ( s = getNextToken() ) == null ) return false;
            ungetToken( s );
            return true;
        }

        public function getNextToken( bToUpper : Boolean = false ) : String // get next token
        {
            var sToken : String;

            // check token stack
            if( m_vCachedTokens.length > 0 )
            {
                var iTailIdx : int = m_vCachedTokens.length - 1;
                sToken = m_vCachedTokens[ iTailIdx ];
                m_vCachedTokens.pop();
                if( bToUpper ) sToken = sToken.toUpperCase();
                return sToken;
            }

            if( m_theTextStream == null ) return null;

            sToken = "";
            var ch : String;
            while( true )
            {
                ch = _getNextChar();
                if( ch == null ) return null;

                if( _isSeparatorChar( ch ) ) continue;
                else if( _isTokenChar( ch ) )
                {
                    sToken += ch;
                    if( bToUpper ) sToken = sToken.toUpperCase();
                    return sToken; // find a reserved token char
                }
                else break;
            }

            // Set first char
            sToken += ch;

            // Add following char
            while( ( ch = _getNextChar() ) != null )
            {
                if( _isTokenChar( ch ) || _isSeparatorChar( ch ) ) // unget char even it is a separator-char
                {
                    _ungetNextChar( ch );
                    break;
                }
                else sToken += ch;
            }

            if( sToken.length > 0 )
            {
                if( bToUpper ) sToken = sToken.toUpperCase();
                return sToken;
            }
            else return null;
        }

        public function ungetToken( sToken : String ) : void
        {
            if( sToken == null ) return ;
            m_vCachedTokens.push( sToken ); // push back
        }

        public function readLine() : String
        {
            if( m_theTextStream == null ) return null;

            var ch : String = _getNextChar();
            if( ch == null ) return null; // end of file

            var sLine : String = "";

            while( true )
            {
                if( ch == s_aLineStopCharSet[0] || ch == s_aLineStopCharSet[1] ) break;
                else sLine += ch; // sLine += ch; // not found

                if( ( ch = _getNextChar() ) == null )
                {
                    return sLine; // the line has retrieved
                }
            }

            // get next char to determine whether next char is the other part of "\n\r"
            var ch2 : String = _getNextChar();
            if( ch2 == null ) return sLine; // the line has retrieved

            if( ch2 == s_aLineStopCharSet[0] || ch2 == s_aLineStopCharSet[1] )
            {
                if( ch2 == ch ) _ungetNextChar( ch2 ); // ch2 is another line, so unget it
            }
            else _ungetNextChar( ch2 ); // ch2 is another line, so unget it

            return sLine;
        }
        public function readUntil( sStopCharSet : String, bUngetStopChar : Boolean = true ) : String
        {
            if( m_theTextStream == null ) return null;

            var ch : String = _getNextChar();
            if( ch == null ) return null; // end of file

            var sString : String = "";

            if( sStopCharSet.length == 0 )
            {
                // Read until end
                do
                {
                    sString += ch; //sString += ch;
                }
                while( ( ch = _getNextChar() ) != null );
            }
            else
            {
                var iLen : int = sStopCharSet.length;
                while( true )
                {
                    var i : int;
                    for( i = 0 ; i <  iLen; i++ )
                    {
                        if( ch == sStopCharSet.charAt( i ) ) break;
                    }
                    if( i == iLen ) sString += ch; //sString += ch; // not found
                    else break;

                    if( ( ch = _getNextChar() ) == null )
                    {
                        return null; // end of file
                    }
                }

                if( bUngetStopChar ) _ungetNextChar( ch );
            }

            return sString;
        }

        public function getNextQuotedToken( sQuoteCharSet : String, bToUpper : Boolean = false ) : String // make sure the quote symbol is in the pcTokenCharSet
        {
            var sToken : String;
            if( ( sToken = getNextToken() ) != null )
            {
                if( sToken.length == 0 ) return null;

                var iLen : int = sQuoteCharSet.length;
                for( var i : int = 0; i < iLen; i++ )
                {
                    if( sToken == sQuoteCharSet.charAt( i ) )
                    {
                        sToken = readUntil( sQuoteCharSet, false );
                        if( sToken != null )
                        {
                            if( bToUpper ) sToken = sToken.toUpperCase();
                            return sToken;
                        }
                        else return null;
                    }
                }

                return sToken;
            }
            return null;
        }

        public function getCurParsingLine() : int // current parse line number
        {
            return m_iCurParsingLine + 1;
        }

        private function _getNextChar() : String
        {
            var ch : String;
            if( m_cCacheChar != null )
            {
                ch = m_cCacheChar;
                m_cCacheChar = null;

                if( ch == "\n" || ch == "\r" ) // handle '\n' on Unix, "\n\r" on Windows, '\r' on Mac
                {
                    if( m_cNextLineFlag == null || m_cNextLineFlag == ch )
                    {
                        m_iCurParsingLine++; // count lines
                        m_cNextLineFlag = ch;
                    }
                    else m_cNextLineFlag = null;
                }
                else m_cNextLineFlag = null;

                return ch;
            }

            // Call TextStream to get char
            ch = m_theTextStream.getChar();
            if( ch != null )
            {
                if( ch == "\n" || ch == "\r" ) // handle '\n' on Unix, "\n\r" on Windows, '\r' on Mac
                {
                    if( m_cNextLineFlag == null || m_cNextLineFlag == ch )
                    {
                        m_iCurParsingLine++; // count lines
                        m_cNextLineFlag = ch;
                    }
                    else m_cNextLineFlag = null;
                }
                else m_cNextLineFlag = null;

                return ch;
            }
            else return null;
        }

        private function  _ungetNextChar( ch : String ) : void
        {
            m_cCacheChar = ch;
            if( ch == "\n" || ch == "\r" ) // handle '\n' on Unix, "\n\r" on Windows, '\r' on Mac
            {
                if( m_cNextLineFlag == null || m_cNextLineFlag == ch )
                {
                    m_iCurParsingLine--;
                    m_cNextLineFlag = ch;
                }
                else m_cNextLineFlag = null;
            }
            else m_cNextLineFlag = null;
        }
        private function _isSeparatorChar( ch : String ) : Boolean
        {
            var iLen : int = m_vSeparatorChars.length;
            for( var i : int = 0; i < iLen; i++ )
            {
                if( ch == m_vSeparatorChars[ i ] ) return true;
            }

            return false;
        }
        private function _isTokenChar( ch : String ) : Boolean
        {
            var iLen : int = m_vTokenChars.length;
            for( var i : int = 0; i < iLen; i++ )
            {
                if( ch == m_vTokenChars[ i ] ) return true;
            }

            return false;
        }
        private function _removeTokenCharsFromSeparatorChars() : void
        {
            var vSeparatorChars : Vector.<String> = new Vector.<String>();

            for each( var ch : String in m_vSeparatorChars )
            {
                var bFound : Boolean = false;
                for each( var ch2 : String in m_vTokenChars )
                {
                    if( ch == ch2 ) { bFound = true; break; }
                }

                if( bFound == false ) vSeparatorChars.push( ch );
            }

            m_vSeparatorChars = vSeparatorChars;
        }

        //
        //
        protected static const s_aSeparatorCharSet : Array = [ ' ', '\n', '\r', '\t' ];
        protected static const s_aLineStopCharSet : Array = [ '\n', '\r' ];

        protected var m_theTextStream : _ITextStream; // Source stream
        protected var m_vTokenChars : Vector.<String>; // each char in this string will be treated as a token
        protected var m_vSeparatorChars : Vector.<String>; // parser will use these chars as token separators

        protected var m_vCachedTokens : Vector.<String>;     // List of token in cache for unget
        protected var m_iCurParsingLine : int;
        protected var m_cCacheChar : String; // Char cache for unget
        protected var m_cNextLineFlag : String; // Char cache for unget
    }

}

interface _ITextStream
{
    function getChar() : String
    function close() : void
}

class _CStringStream implements _ITextStream
{
    public function _CStringStream( s : String )
    {
        //var iLen : int = s.length;
        //m_vString = new Vector.<String>( iLen );
        //for( var i : int = 0; i < iLen; i++ ) m_vString[i] = s.charAt( i );
        m_String = s;
        m_iIndex = 0;
    }
    public function getChar() : String
    {
        //if( m_iIndex < m_vString.length ) return m_vString[ m_iIndex++ ];
        if( m_iIndex < m_String.length ) return m_String.charAt( m_iIndex++ );
        else return null;
    }
    public function close() : void
    {
    }

    //protected var m_vString : Vector.<String>;
    protected var m_String : String;
    protected var m_iIndex : int;
}

