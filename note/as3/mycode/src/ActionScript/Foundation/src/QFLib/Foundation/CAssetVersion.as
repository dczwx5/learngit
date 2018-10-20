//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/7/4
//----------------------------------------------------------------------------------------------------------------------

package QFLib.Foundation
{
import QFLib.Foundation;
import QFLib.Interface.IDisposable;
import QFLib.Interface.IUpdatable;

//
    //
    //
    public dynamic class CAssetVersion implements IDisposable, IUpdatable
    {
        public function CAssetVersion()
        {
        }

        public function dispose() : void
        {
            if( m_theFile != null )
            {
                m_theFile.dispose();
                m_theFile = null;
            }
        }

        public function update( delta : Number ) : void {
            if ( m_theFile && m_theFile.isLoading )
                m_theFile.update();
        }

        [Inline]
        final public function get assetPath() : String
        {
            return m_sAssetPath;
        }

        [Inline]
        final public function get absoluteURI() : String {
            return m_sAbsoluteURI;
        }

        [Inline]
        final public function set absoluteURI( sURI : String ) : void {
            if( sURI == null ) sURI = "";
            m_sAbsoluteURI = sURI;
            m_sAbsoluteURILowerCase = m_sAbsoluteURI.toLowerCase();
        }

        [Inline]
        final public function get isLoading() : Boolean
        {
            if( m_theFile == null ) return false;
            return m_theFile.isLoading;
        }

        //
        // callback: function fnOnFinished( file : CURLFile, idErrorCode : int ) : void
        // iFileVersion : 0: unspecified, 1: using format generated from 'svn list -v -R', 2: using format generated from StarAutobuild(with md5 checksum)
        //
        public function loadFile( sFilename : String, sAssetPath : String = null, pfnFinished : Function = null, iFileVersion : int = 2, urlVersion : String = null ) : void
        {
            if( sAssetPath == null ) sAssetPath = CPath.driverDir( sFilename, true, true, true );
            m_sAssetPath = CPath.addRightSlash( sAssetPath );
            m_sAssetPathLowerCase = m_sAssetPath.toLowerCase();
            m_iFileVersion = iFileVersion;

            m_theFile = new CURLFile( sFilename );
            m_theFile.urlVersion = urlVersion == null ? CTime.startTime.toString() : urlVersion;
            m_theFile.startLoad( _inlineLoadFinished );

            function _inlineLoadFinished( file : CURLFile, idErrorCode : int ) : void {
                _onLoadFinished( file, idErrorCode );

                if ( null != pfnFinished ) {
                    pfnFinished( file, idErrorCode );
                }
            }
        }

        public function loadFile2( sFileName : String, sAssetVerData : String, sAssetPath : String = null, iFileVersion : int = 2 ) : void
        {
            if ( sAssetPath == null ) sAssetPath = CPath.driverDir( sFileName, true, true, true );
            m_sAssetPath = CPath.addRightSlash( sAssetPath );
            m_sAssetPathLowerCase = m_sAssetPath.toLowerCase();
            m_iFileVersion = iFileVersion;
            
            _loadData( sAssetVerData, "CAssetVersion.loadFile2()" );
        }

        [Inline]
        final public function add( sFilename : String, sVersion : String, uiSize : uint, sChecksum : String ) : void
        {
            m_mapFileVersions.add( sFilename.toLowerCase(), new _CAssetInfo( sFilename, sVersion, uiSize, sChecksum ));
        }

        final public function findVersion( sSubFilename : String, bToLowerCase : Boolean = true ) : String
        {
            if( bToLowerCase ) sSubFilename = sSubFilename.toLowerCase();
            var theAssetInfo : _CAssetInfo = m_mapFileVersions.find( sSubFilename ) as _CAssetInfo;
            if( theAssetInfo != null ) return theAssetInfo.m_sVersion;
            else return null;
        }
        final public function findSize( sSubFilename : String, bToLowerCase : Boolean = true ) : uint
        {
            if( bToLowerCase ) sSubFilename = sSubFilename.toLowerCase();
            var theAssetInfo : _CAssetInfo = m_mapFileVersions.find( sSubFilename ) as _CAssetInfo;
            if( theAssetInfo != null ) return theAssetInfo.m_uiSize;
            else return -1;
        }
        final public function findChecksum( sSubFilename : String, bToLowerCase : Boolean = true ) : String
        {
            if( bToLowerCase ) sSubFilename = sSubFilename.toLowerCase();
            var theAssetInfo : _CAssetInfo = m_mapFileVersions.find( sSubFilename ) as _CAssetInfo;
            if( theAssetInfo != null ) return theAssetInfo.m_sChecksum;
            else return "";
        }

        public function mappingFilename( sFullFilename : String ) : String
        {
            var sAbsoluteAssetPathLowerCase : String = CPath.addRightSlash( m_sAbsoluteURILowerCase ) + m_sAssetPathLowerCase;
            sAbsoluteAssetPathLowerCase = CPath.addRightSlash( sAbsoluteAssetPathLowerCase );

            sFullFilename = CPath.full( sFullFilename, true, true );
            var sFullFilenameLowerCase : String = sFullFilename.toLowerCase();
            var iIdx : int = sFullFilenameLowerCase.indexOf( sAbsoluteAssetPathLowerCase, 0 );
            if( iIdx == 0 )
            {
                var sSubFilename : String = sFullFilenameLowerCase.substring( sAbsoluteAssetPathLowerCase.length );
                var theAssetInfo : _CAssetInfo = m_mapFileVersions.find( sSubFilename ) as _CAssetInfo;
                if( theAssetInfo != null )
                {
                    var sAbsoluteAssetPath : String = CPath.addRightSlash( m_sAbsoluteURI ) + m_sAssetPath;
                    sAbsoluteAssetPath = CPath.addRightSlash( sAbsoluteAssetPath );
                    return sAbsoluteAssetPath + theAssetInfo.m_sOriginalPath;
                }
            }

            return sFullFilename;
        }
        public function mappingFileVersion( sFullFilename : String ) : String
        {
            var sAbsoluteAssetPathLowerCase : String = CPath.addRightSlash( m_sAbsoluteURILowerCase ) + m_sAssetPathLowerCase;
            sAbsoluteAssetPathLowerCase = CPath.addRightSlash( sAbsoluteAssetPathLowerCase );

            sFullFilename = CPath.full( sFullFilename, true, true );
            var sFullFilenameLowerCase : String = sFullFilename.toLowerCase();
            var iIdx : int = sFullFilenameLowerCase.indexOf( sAbsoluteAssetPathLowerCase, 0 );
            if( iIdx == 0 )
            {
                var sSubFilename : String = sFullFilenameLowerCase.substring( sAbsoluteAssetPathLowerCase.length );
                return this.findVersion( sSubFilename, false );
            }

            return null;
        }
        public function mappingFilenameWithVersion( sFullFilename : String ) : String
        {
            if( m_sAssetPathLowerCase == null ) return sFullFilename;

            var sAbsoluteAssetPathLowerCase : String = CPath.addRightSlash( m_sAbsoluteURILowerCase ) + m_sAssetPathLowerCase;
            sAbsoluteAssetPathLowerCase = CPath.addRightSlash( sAbsoluteAssetPathLowerCase );

            sFullFilename = CPath.full( sFullFilename, true, true );
            var sFilenameLowerCase : String = sFullFilename.toLowerCase();
            var iIdx : int = sFilenameLowerCase.indexOf( sAbsoluteAssetPathLowerCase, 0 );
            if( iIdx == 0 )
            {
                var sSubFilename : String = sFilenameLowerCase.substring( sAbsoluteAssetPathLowerCase.length );
                var theAssetInfo : _CAssetInfo = m_mapFileVersions.find( sSubFilename ) as _CAssetInfo;
                if( theAssetInfo != null )
                {
                    var sAbsoluteAssetPath : String = CPath.addRightSlash( m_sAbsoluteURI ) + m_sAssetPath;
                    sAbsoluteAssetPath = CPath.addRightSlash( sAbsoluteAssetPath );
                    return sAbsoluteAssetPath + theAssetInfo.m_sOriginalPath + "?_=" + theAssetInfo.m_sVersion;
                }
            }
            return sFullFilename;
        }

        public function findFilesWith( sPath : String, sExt : String, bRecursive : Boolean ) : Array
        {
            sPath = CPath.full( sPath, false, true );
            sPath = sPath.toLowerCase();
            if( sExt != null ) sExt = sExt.toLowerCase();

            var setFiles : CSet = new CSet();
            var sThePath : String;
            var info : _CAssetInfo;
            var sFileKey : String;
            for( sFileKey in m_mapFileVersions )
            {
                if( sFileKey.indexOf( sPath ) == 0 && ( sExt == null || CPath.ext( sFileKey ) == sExt ) )
                {
                    info = m_mapFileVersions.find( sFileKey ) as _CAssetInfo;
                    if( bRecursive )
                    {
                        setFiles.add( info.m_sOriginalPath );
                    }
                    else
                    {
                        sThePath = CPath.driverDir( sFileKey );
                        if( sThePath == sPath ) setFiles.add( info.m_sOriginalPath );
                    }
                }
            }

            return setFiles.toArray();
        }

        public function findDirectoriesWith( sPath : String, bRecursive : Boolean, bWithEndSeparatorSign : Boolean = true ) : Array
        {
            sPath = CPath.full( sPath, false, true );
            sPath = sPath.toLowerCase();

            var setDirs : CSet = new CSet();
            var sThePath : String;
            var info : _CAssetInfo;
            var sFileKey : String;
            for( sFileKey in m_mapFileVersions )
            {
                if( sFileKey.indexOf( sPath ) == 0 )
                {
                    info = m_mapFileVersions.find( sFileKey ) as _CAssetInfo;
                    if( bRecursive )
                    {
                        sThePath = CPath.driverDir( info.m_sOriginalPath, bWithEndSeparatorSign );
                        setDirs.add( sThePath );
                    }
                    else
                    {
                        sThePath = CPath.driverDirParent( sFileKey );
                        if( sThePath == sPath )
                        {
                            sThePath = CPath.driverDir( info.m_sOriginalPath, bWithEndSeparatorSign );
                            setDirs.add( sThePath );
                        }
                    }
                }
            }

            return setDirs.toArray();
        }

        //
        protected function _onLoadFinished( file : CURLFile, idErrorCode : int ) : void
        {
            if( idErrorCode == 0 )
            {
                _loadData( file.readAllText(), file.loadingURL );

                Foundation.Log.logMsg( "Asset version file loaded: " + file.loadingURL + ", total recorded files: " + m_mapFileVersions.count );
            }
        }

        private function _loadData( sText : String, from : String = null ) : void
        {
            var textParser : CTextParser;

            Foundation.Perf.sectionBegin( "CAssetVersion_Parse" );

            if( m_iFileVersion == 1 ) // using format generated from 'svn list -v -R'
            {
                textParser = new CTextParser( "\"\n" );
                textParser.bindStream( sText );
                _parseAssetVersionFileFormat1( textParser, from );
                textParser.dispose();
            }
            else if( m_iFileVersion == 2 ) // using format generated from StarAutobuild(with md5 checksum)
            {
                textParser = new CTextParser( "\"" );
                textParser.bindStream( sText );
                _parseAssetVersionFileFormat2( textParser );
                textParser.dispose();
            }
            else
            {
                Foundation.Log.logErrorMsg( "Asset version file format not support: " + m_iFileVersion );
            }

            Foundation.Perf.sectionEnd( "CAssetVersion_Parse" );
        }
        /*protected function _onLoadFinished( file : CURLFile, idErrorCode : int ) : void
        {
            if( idErrorCode == 0 )
            {
                var sText : String = file.readAllText();
                var textParser : CTextParser = new CTextParser( "\"\n" );
                textParser.bindStream( sText );

                Foundation.Perf.sectionBegin( "CAssetVersion_Parse" );

                var sFilename : String;
                var sVersion : String;
                var sSize : String;
                var sParam : String;
                var sLast : String = null;
                var sLast2 : String = null;

                var iLine : int = 1;
                while( ( sVersion = textParser.getNextQuotedToken( "\"" ) ) != null )
                {
                    sParam = textParser.getNextQuotedToken( "\"" ); // author
                    if( sParam == null ) break;

                    sSize = textParser.getNextQuotedToken( "\"" ); // size
                    if( sSize == null ) break;

                    while( ( sParam = textParser.getNextQuotedToken( "\"" ) ) != null )
                    {
                        if( sParam == "\n" )
                        {
                            sFilename = sLast;
                            if( sLast2 != null && sLast2.indexOf( "-" ) < 0 && sLast2.indexOf( ":" ) < 0 )
                            {
                                Foundation.Log.logErrorMsg( "Filename format not allowed at '" + file.loadingURL + ":" + iLine + "'(..." + sLast2 + "..." + sLast + ")" );
                            }
                            iLine++;
                            sLast = sLast2 = null;
                            break;
                        }
                        else
                        {
                            sLast2 = sLast;
                            sLast = sParam;
                        }
                    }

                    // set size to 0 if it is a directory
                    sParam = sFilename.charAt( sFilename.length - 1 );
                    if( sParam == "/" || sParam == "\\" ) sSize = "0";

                    sFilename = CPath.full( sFilename, true, true );
                    this.add( sFilename, sVersion, int( sSize ) );
                }

                Foundation.Perf.sectionEnd( "CAssetVersion_Parse" );

                textParser.dispose();
                Foundation.Log.logMsg( "Asset version file loaded: " + file.loadingURL + ", total recorded files: " + m_mapFileVersions.count );
            }
        }*/

        //
        // using format generated from 'svn list -v -R'
        //
        protected function _parseAssetVersionFileFormat1( textParser : CTextParser, from : String = null ) : void
        {
            var sFilename : String;
            var sVersion : String;
            var sSize : String;
            var sParam : String;
            var sLast : String = null;
            var sLast2 : String = null;

            var iLine : int = 1;
            while( ( sVersion = textParser.getNextQuotedToken( "\"" ) ) != null )
            {
                sParam = textParser.getNextQuotedToken( "\"" ); // author
                if( sParam == null ) break;

                sSize = textParser.getNextQuotedToken( "\"" ); // size
                if( sSize == null ) break;

                while( ( sParam = textParser.getNextQuotedToken( "\"" ) ) != null )
                {
                    if( sParam == "\n" )
                    {
                        sFilename = sLast;
                        if( sLast2 != null && sLast2.indexOf( "-" ) < 0 && sLast2.indexOf( ":" ) < 0 )
                        {
                            Foundation.Log.logErrorMsg( "Filename format not allowed at '" + from + ":" + iLine + "'(..." + sLast2 + "..." + sLast + ")" );
                        }
                        iLine++;
                        sLast = sLast2 = null;
                        break;
                    }
                    else
                    {
                        sLast2 = sLast;
                        sLast = sParam;
                    }
                }

                // set size to 0 if it is a directory
                sParam = sFilename.charAt( sFilename.length - 1 );
                if( sParam == "/" || sParam == "\\" ) sSize = "0";

                sFilename = CPath.full( sFilename, true, true );
                this.add( sFilename, sVersion, int( sSize ), "" );
            }
        }

        //
        // using format generated from StarAutobuild(with md5 checksum)
        //
        protected function _parseAssetVersionFileFormat2( textParser : CTextParser ) : void
        {
            var sFilename : String;
            var sVersion : String;
            var sSize : String;
            var sChecksum : String;
            while( ( sFilename = textParser.getNextQuotedToken( "\"" ) ) != null )
            {
                sVersion = textParser.getNextToken();
                if( sVersion == null ) break;

                sSize = textParser.getNextToken();
                if( sSize == null ) break;

                sChecksum = textParser.getNextToken();
                if( sChecksum == null ) break;

                sFilename = CPath.full( sFilename, true, true );
                this.add( sFilename, sVersion, uint( sSize ), sChecksum );
            }
        }

        //
        //
        protected var m_sAssetPath : String = "";
        protected var m_sAssetPathLowerCase : String = "";
        protected var m_sAbsoluteURI : String = "";
        protected var m_sAbsoluteURILowerCase : String = "";
        protected var m_theFile : CURLFile = null;
        protected var m_mapFileVersions : CMap = new CMap();
        protected var m_iFileVersion : int = 0;
    }

}

class _CAssetInfo
{
    public function _CAssetInfo( sOriginalPath : String, sVersion : String, uiSize : uint, sChecksum : String )
    {
        m_sOriginalPath = sOriginalPath;
        m_sVersion = sVersion;
        m_uiSize = uiSize;
        m_sChecksum = sChecksum;
    }

    public var m_sOriginalPath : String = null;
    public var m_sVersion : String = null;
    public var m_sChecksum : String = null;
    public var m_uiSize : uint = 0;
 }
