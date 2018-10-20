//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/2/4
//----------------------------------------------------------------------------------------------------------------------

package QFLib.Foundation
{

    //
    //
    //
    public class CPath
    {
        public function CPath( sPath : String, bFile : Boolean = true, bNormalizeSeparatorSign : Boolean = false, cDirSeparator : String = '/' )
        {
            m_cDirSeparator = cDirSeparator;
            reset( sPath, bFile, bNormalizeSeparatorSign );
        }

        public function reset( sPath : String, bFile : Boolean = true, bNormalizeSeparatorSign : Boolean = false ) : void
        {
            m_sDriver = m_sDir = m_sName = m_sExt = "";

            if( bNormalizeSeparatorSign ) sPath = this.normalizeAllSeparatorSign( sPath );

            var iBegin : int = 0;
            var iEnd : int = sPath.length - 1;
            if( iEnd < 0 ) return ;

            // extract driver
            var iIdx : int = sPath.indexOf(  ':' );
            if( iIdx >= 0 )
            {
                m_sDriver = sPath.substr(  0, iIdx + 1 );
                iBegin = iIdx + 1;
                if( iBegin > iEnd ) return ;
            }

            if( bFile ) // the path is a file
            {
                // find m_cDirSeparator from the end
                iIdx = sPath.lastIndexOf( '\\' );
                var iIdx2 : int = sPath.lastIndexOf( '/' );
                if( iIdx < iIdx2 ) iIdx = iIdx2;

                // extract name
                if( iIdx >= iBegin )
                {
                    m_sName = sPath.substr( iIdx + 1, iEnd - iIdx );
                    iEnd = iIdx;

                    // extract dir
                    m_sDir = sPath.substr( iBegin, iEnd - iBegin + 1 );
                }
                else m_sName = sPath.substr( iBegin, iEnd - iBegin + 1 );

                // extract ext from name
                iEnd = m_sName.length - 1;
                iIdx = m_sName.lastIndexOf( '.' );
                if( iIdx >= 0 )
                {
                    m_sExt  = m_sName.substr( iIdx, iEnd - iIdx + 1 );
                    m_sName = m_sName.substr( 0, iIdx );
                }
            }
            else // the path is a directory
            {
                // extract dir
                m_sDir = sPath.substr( iBegin, iEnd - iBegin + 1 );
                var cEnd : String = sPath.charAt( iEnd );
                if( cEnd != '/' && cEnd != '\\' ) m_sDir += m_cDirSeparator;
            }
        }

        public function set( sDriver : String, sDir : String, sName : String, sExt : String, bNormalizeSeparatorSign : Boolean = false ) : void
        {
            if( bNormalizeSeparatorSign )
            {
                this.driver = this.normalizeAllSeparatorSign( sDriver );
                this.dir = this.normalizeAllSeparatorSign( sDir );
                this.name = this.normalizeAllSeparatorSign( sName );
                this.ext = this.normalizeAllSeparatorSign( sExt );
            }
            else
            {
                this.driver = sDriver;
                this.dir = sDir;
                this.name = sName;
                this.ext = sExt;
            }
        }

        public function normalizeAllSeparatorSign( sPath : String ) : String
        {
            if( m_cDirSeparator == "/" ) sPath = sPath.split( "\\" ).join( m_cDirSeparator );
            else sPath = sPath.split( "/" ).join( m_cDirSeparator );
            return sPath;
        }

        public function get driver() : String
        {
            return m_sDriver;
        }
        public function get dir() : String
        {
            return m_sDir;
        }
        public function get name() : String
        {
            return m_sName;
        }
        public function get ext() : String
        {
            return m_sExt;
        }
        public function nameExt() : String
        {
            if( m_sExt.length == 0 ) return m_sName;
            else
            {
                var s : String = m_sName;
                s += m_sExt;
                return s;
            }
        }
        public function full() : String
        {
            return m_sDriver + m_sDir + m_sName + m_sExt;
        }
        public function driverDir( bWithEndSeparatorSign : Boolean = true ) : String
        {
            if( m_sDriver.length == 0 )
            {
                if( m_sDir.length == 0 ) return "";
                else
                {
                    if( bWithEndSeparatorSign ) return m_sDir;
                    else return m_sDir.substr( 0, m_sDir.length - 1 );
                }
            }
            else
            {
                var sPath : String;
                if( m_sDir.length == 0 )
                {
                    sPath = m_sDriver;
                    if( bWithEndSeparatorSign ) sPath += m_cDirSeparator;

                    return sPath;
                }
                else
                {
                    sPath = m_sDriver;
                    sPath += m_sDir;
                    if( bWithEndSeparatorSign == false )
                    {
                        sPath = sPath.substr( 0, sPath.length - 1 );
                    }

                    return sPath;
                }
            }
        }
        public function driverDirName() : String
        {
            var sPathName : String = driverDir( true );
            sPathName += this.name;
            return sPathName;
        }

        public function set driver( s : String ) : void
        {
            var iIdx : int = s.indexOf( ':' );
            if( iIdx >= 0 )
            {
                m_sDriver = s.substr( 0, iIdx + 1 );
            }
            else
            {
                m_sDriver = s;
                if( m_sDriver.length != 0 ) m_sDriver += ":";
            }
        }
        public function set dir( s : String ) : void
        {
            m_sDir = "";
            var iLen : int = s.length;
            if( iLen == 0 ) return ;

            var iBegin : int = s.indexOf( ':' );
            if( iBegin < 0 ) iBegin = 0;
            else iBegin += 1;

            m_sDir = s.substr( iBegin, iLen - iBegin );

            var cLastChar : String = s.charAt( iLen - 1 );
            if( cLastChar != '/' && cLastChar != '\\' ) m_sDir += m_cDirSeparator;
        }
        public function set name( s : String ) : void
        {
            m_sName = "";
            var iLen : int = s.length;
            if( iLen == 0 ) return ;

            var iBegin : int = s.indexOf( ':' );
            if( iBegin < 0 ) iBegin = 0;
            else iBegin += 1;

            var iBegin2 : int = s.lastIndexOf( '/' );
            var iBegin3 : int = s.lastIndexOf( '\\' );
            if( iBegin3 > iBegin2 ) iBegin2 = iBegin3;

            if( iBegin2 >= iBegin )
            {
                iBegin = iBegin2 + 1;
            }

            var iEnd : int = s.lastIndexOf( '.' );
            if( iEnd < 0 ) iEnd = iLen - 1;
            else iEnd -= 1;

            if( iEnd >= iBegin ) m_sName = s.substr( iBegin, iEnd - iBegin + 1 );
        }
        public function set ext( s : String ) : void
        {
            m_sExt = "";
            var iLen : int = s.length;
            if( iLen == 0 ) return ;

            var iBegin : int = s.lastIndexOf( '.' );
            if( iBegin < 0 )
            {
                m_sExt = ".";
                m_sExt += s.substr( 0, iLen );
            }
            else m_sExt = s.substr( iBegin, iLen - iBegin );
        }

        public function assignFrom( rhs : CPath ) : void
        {
            m_sDriver = rhs.m_sDriver;
            m_sDir    = rhs.m_sDir;
            m_sName   = rhs.m_sName;
            m_sExt    = rhs.m_sExt;
        }

        public function isEqual( rhs : CPath ) : Boolean
        {
            if( m_sDriver != rhs.m_sDriver ) return false;
            if( m_sName   != rhs.m_sName )   return false;
            if( m_sExt    != rhs.m_sExt )    return false;
            if( m_sDir    != rhs.m_sDir )
            {
                // check related path
                var iIdxLHS : int = m_sDir.indexOf( "../" );
                if( iIdxLHS == -1 ) iIdxLHS = m_sDir.indexOf( "..\\" );

                var iIdxRHS : int = rhs.m_sDir.indexOf( "../" );
                if( iIdxRHS == -1 ) iIdxRHS = rhs.m_sDir.indexOf( "..\\" );

                if( (iIdxLHS == -1 && iIdxRHS == -1 ) || (iIdxLHS != -1 && iIdxRHS != -1 ) ) return false;

                // check related path
                iIdxLHS = m_sDir.indexOf( "./" );
                if( iIdxLHS == -1 ) iIdxLHS = m_sDir.indexOf( ".\\" );

                iIdxRHS = rhs.m_sDir.indexOf( "./" );
                if( iIdxRHS == -1 ) iIdxRHS = rhs.m_sDir.indexOf( ".\\" );

                if( (iIdxLHS == -1 && iIdxRHS == -1 ) || (iIdxLHS != -1 && iIdxRHS != -1 ) ) return false;
            }

            return true;
        }

        //
        // static functions
        //
        public static function driver( sPath : String ) : String
        {
            m_GlobalPath.reset( sPath );
            return m_GlobalPath.driver;
        }
        public static function dir( sPath : String, bFile : Boolean = true, bNormalizeSeparatorSign : Boolean = false ) : String
        {
            m_GlobalPath.reset( sPath, bFile, bNormalizeSeparatorSign );
            return m_GlobalPath.dir;
        }
        public static function name( sPath : String ) : String
        {
            m_GlobalPath.reset( sPath );
            return m_GlobalPath.name;
        }
        public static function ext( sPath : String ) : String
        {
            m_GlobalPath.reset( sPath );
            return m_GlobalPath.ext;
        }
        public static function driverDir( sPath : String, bWithEndSeparatorSign : Boolean = true, bFile : Boolean = true, bNormalizeSeparatorSign : Boolean = false ) : String
        {
            m_GlobalPath.reset( sPath, bFile, bNormalizeSeparatorSign );
            return m_GlobalPath.driverDir( bWithEndSeparatorSign );
        }
        public static function driverDirParent( sPath : String, bWithEndSeparatorSign : Boolean = true, iNumParentLayers : int = 1, bFile : Boolean = true, bNormalizeSeparatorSign : Boolean = false ) : String
        {
            if( iNumParentLayers < 1 ) return driverDir( sPath, bWithEndSeparatorSign, bFile, bNormalizeSeparatorSign );

            var sDir : String = sPath;
            for( var i : int = 0; i < iNumParentLayers; i++ )
            {
                sDir = driverDir( sDir, false );
            }
            return driverDir( sDir, bWithEndSeparatorSign, bFile, bNormalizeSeparatorSign );
        }
        public static function nameExt( sPath : String ) : String
        {
            m_GlobalPath.reset( sPath );
            return m_GlobalPath.nameExt();
        }
        public static function driverDirName( sPath : String, bFile : Boolean = true, bNormalizeSeparatorSign : Boolean = false ) : String
        {
            m_GlobalPath.reset( sPath, bFile, bNormalizeSeparatorSign );
            return m_GlobalPath.driverDirName();
        }
        public static function full( sPath : String, bFile : Boolean = true, bNormalizeSeparatorSign : Boolean = false ) : String
        {
            m_GlobalPath.reset( sPath, bFile, bNormalizeSeparatorSign );
            return m_GlobalPath.full();
        }
        public static function removeRightSlash( sDir : String ) : String
        {
            var iLen : int = sDir.length;

            while( true )
            {
                if( iLen == 0 ) break;
                var  iLastCharIdx : int = iLen - 1;

                var cLastChar : String = sDir.charAt( iLastCharIdx );
                if( cLastChar == '/' || cLastChar == '\\' ) iLen--;
                else break;
            }

            sDir = sDir.substr( 0, iLen );
            return sDir;
        }
        public static function addRightSlash( sDir : String, cDirSeparator : String = '/' ) : String
        {
             var iLastCharIdx : int = sDir.length - 1;
            if( iLastCharIdx < 0 ) return sDir;

            var cLast : String = sDir.charAt( iLastCharIdx );
            if( cLast != '/' && cLast != '\\' ) sDir += cDirSeparator;
            return sDir;
        }

        //
        //
        private var m_sDriver : String ="";
        private var m_sDir : String = "";
        private var m_sName : String = "";
        private var m_sExt : String = "";
        private var m_cDirSeparator : String = "/";

        private static var m_GlobalPath : CPath = new CPath( "" );

   }
    ;


}