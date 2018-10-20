//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/3/12
//----------------------------------------------------------------------------------------------------------------------

/*
*/

package QFLib.ResourceLoader
{

    import QFLib.Foundation;
import QFLib.Foundation.CPath;
import QFLib.Foundation.CURLFile;
    import QFLib.Interface.IRecyclable;
    import QFLib.Memory.CSmartObject;
    import QFLib.ResourceLoader.Worker.CFileCheckRequestEvent;

    import flash.events.IOErrorEvent;
    import flash.utils.ByteArray;

    import flash.utils.getDefinitionByName;
    import flash.utils.getQualifiedClassName;
import flash.utils.getTimer;

public class CBaseLoader extends CSmartObject implements IRecyclable
    {
        public static const NAME : String = "";

        public function CBaseLoader( theBelongResourceLoaderRef : CResourceLoaders )
        {
            super();
            m_theBelongResourceLoadersRef = theBelongResourceLoaderRef;
        }

        public override function dispose() : void
        {
            if( m_bRecycled ) return ; // do not dispose recycled object

            super.dispose();

            close();
            if( m_theURLFile != null )
            {
                m_theURLFile.dispose();
                m_theURLFile = null;
            }
        }

        public virtual function revive() : void
        {
            m_bRecycled = false;
        }

        public virtual function recycle() : void
        {
            close();
            m_bRecycled = true;
        }

        public virtual function disposeRecyclable() : void
        {
            m_bRecycled = false;
            dispose();
        }

        public virtual function close() : void
        {
            if( m_theURLFile != null ) m_theURLFile.close();
            m_fnOnFinished = null;
            m_fnOnProgress = null;
            m_fnOnFatalErrorNotifier = null;
            m_iPriority = ELoadingPriority.NORMAL;
            m_iLoadingIndex = -1;
            m_iLoaderTaskID = m_iDependentToLoaderTaskID = -1;
            m_bDone = false;
            m_bDoneFromCache = false;
            m_bCheckCacheWhenStarted = true;
        }

        public virtual function set( sFilename : String, fnOnFinished : Function, iPriority : int = ELoadingPriority.NORMAL,
                                         bSuppressLoadErrorMsg : Boolean = false, bRandomVersion : Boolean = false,
                                         fnOnProgress : Function = null, iBeginLoadingIdx : int = 0 ) : void
        {
            m_vFilenames.length = 1;
            m_vFilenames[ 0 ] = sFilename;
            m_fnOnFinished = fnOnFinished;
            m_fnOnProgress = fnOnProgress;
            m_iPriority = iPriority;
            m_bSuppressLoadErrorMsg = bSuppressLoadErrorMsg;
            m_bRandomVersion = bRandomVersion;
            m_iBeginLoadingIdx = iBeginLoadingIdx
        }

        // user must implement the following function
        public virtual function createObject( bCleanUp : Boolean = true ) : Object
        {
            Foundation.Log.logErrorMsg( "No createObject feature provided!" );
            return null;
        }

        public virtual function createResource( bCleanUp : Boolean = true ) : CResource
        {
            var theResource : CResource;
            if( m_bDoneFromCache )
            {
                theResource = m_theBelongResourceLoadersRef.resourceCache.create( this.loadingFilename, this.name );
                return theResource;
            }
            else
            {
                theResource = m_theBelongResourceLoadersRef.resourceCache.create( this.loadingFilename, this.name );
                if( theResource == null )
                {
                    var obj : Object = createObject( bCleanUp );
                    if( obj != null )
                    {
                        theResource = new CResource( this.loadingFilename, this.name, obj );
                        m_theBelongResourceLoadersRef.resourceCache.add( this.loadingFilename, this.name, theResource );
                    }
                }

                if ( theResource != null )
                    theResource.resourceSize = this.urlFile.numTotalBytes;

                return theResource;
            }
        }

        public virtual function start() : void
        {
            // try find it in cache
            var iFoundLoadingIndex : int = -1;
            if( m_bCheckCacheWhenStarted )
            {
                for( var j : int = 0; j < m_vFilenames.length; j++ )
                {
                    if( m_theBelongResourceLoadersRef.resourceCache.isExisted( m_vFilenames[ j ], this.name ) )
                    {
                        iFoundLoadingIndex = j;
                        break;
                    }
                }
            }
            if( iFoundLoadingIndex >= 0 )
            {
                _directFinished( iFoundLoadingIndex, true );
            }
            else
            {
                if( m_theURLFile == null ) m_theURLFile = _createURLFile( m_vFilenames[ 0 ] );
                else
                {
                    m_theURLFile.urls.length = 1;
                    m_theURLFile.urls[ 0 ] = m_vFilenames[ 0 ];
                }

                for( var i : int = 1; i < m_vFilenames.length; i++ )
                {
                    m_theURLFile.urls.push(  m_vFilenames[ i ] );
                }

                if( m_theBelongResourceLoadersRef.assetVersion != null )
                {
                    var vVersions : Vector.<String> = new Vector.<String>( m_vFilenames.length );
                    for( var k : int = 0; k < m_vFilenames.length; k++ )
                    {
                        vVersions[ k ] = m_theBelongResourceLoadersRef.assetVersion.mappingFileVersion( m_vFilenames[ k ] );
                        if( m_bRandomVersion ) vVersions[ k ] += "_" + getTimer().toString() + Math.random().toString();
                    }
                    m_theURLFile.urlVersions = vVersions;
                }
                else m_theURLFile.urlVersions = null;

                m_theURLFile.startLoad( _onLoadFinished, _loadOnProgress, m_bSuppressLoadErrorMsg, true, true, m_iBeginLoadingIdx );
            }
        }

        [Inline]
        final public function get streamLoaderClass() : Class
        {
            return m_pStreamLoaderClass;
        }

        [Inline]
        final public function set streamLoaderClass( value : Class ) : void
        {
            m_pStreamLoaderClass = value;
        }

        public function get name() : String
        {
            if( m_sName == null )
            {
                var sClassName : String = getQualifiedClassName( this );
                var ClassReference : Class = getDefinitionByName( sClassName ) as Class;

                m_sName = ClassReference.NAME;
                if( m_sName == null )
                {
                    Foundation.Log.logErrorMsg( "Cannot get the 'NAME' definition of this loader: " + sClassName );
                    throw new IOErrorEvent( "No loader 'NAME' definition", false, false, "Cannot get the 'NAME' definition of this loader: " + sClassName, -1 )
                }
            }
            return m_sName;
        }

        public function get filename() : String
        {
            return m_vFilenames[ 0 ];
        }
        public function get filenames() : Vector.<String>
        {
            return m_vFilenames;
        }
        public function get loadingFilename() : String
        {
            if( m_iLoadingIndex >= 0 ) return m_vFilenames[ m_iLoadingIndex ];
            return null;
        }

        public function get priority() : int
        {
            return m_iPriority;
        }

        public function get arguments() : Array
        {
            return m_aArguments;
        }
        public function set arguments( args : Array ) : void
        {
            m_aArguments = args;
        }

        public function get beginLoadingIndex() : int
        {
            return m_iBeginLoadingIdx;
        }

        public function set beginLoadingIndex( index : int ) : void
        {
            m_iBeginLoadingIdx = index;
        }

        public function isDone() : Boolean
        {
            return m_bDone;
        }

        public function get loaderTaskID() : int
        {
            return m_iLoaderTaskID;
        }
        public function get dependentToLoaderTaskID() : int
        {
            return m_iDependentToLoaderTaskID;
        }

        public function get urlFile() : CURLFile
        {
            return m_theURLFile;
        }

        public function get checkCacheWhenStarted() : Boolean
        {
            return m_bCheckCacheWhenStarted;
        }
        public function set checkCacheWhenStarted( bCheck : Boolean ) : void
        {
            m_bCheckCacheWhenStarted = bCheck;
        }

        public virtual function update() : void
        {
            if( m_theURLFile != null ) m_theURLFile.update();
        }

        //
        internal function _directFinished( iLoadingIndex : int, bDoneFromCache : Boolean, iLoadErrorCode : int = 0 ) : void
        {
            m_iLoadingIndex = iLoadingIndex;
            m_bDoneFromCache = bDoneFromCache;
            m_bDone = true;
            if( m_fnOnFinished != null ) m_fnOnFinished( this, iLoadErrorCode );
        }

        internal function _setLoaderTaskID( iLoaderTaskID : int ) : void
        {
            m_iLoaderTaskID = iLoaderTaskID;
        }
        internal function _setDependentToLoaderTaskID( iDependentToLoaderTaskID : int ) : void
        {
            m_iDependentToLoaderTaskID = iDependentToLoaderTaskID;
        }

        /*internal function _onWorkerCheckFinished( idError : int ) : void // called after worker's finished checking
        {
            m_theURLFile.position = 0;
            _loadFinished( m_theURLFile, idError );
            m_theURLFile.close();
        }*/

        //
        protected virtual function _loadFinished( file : CURLFile, idError : int ) : void
        {
            m_bDone = true;
            if( m_fnOnFinished != null ) m_fnOnFinished( this, idError );
        }
        protected virtual function _loadOnProgress( file : CURLFile, iNumByteRead : Number, iTotalBytes : Number ) : void
        {
            if( m_fnOnProgress != null ) m_fnOnProgress( this, iNumByteRead, iTotalBytes );
        }

        //
        protected virtual function _onLoadFinished( file : CURLFile, idError : int ) : void
        {
//            Foundation.Log.logErrorMsg( "CBaseLoader._onLoadFinished: " + file.loadingURL + ", idError: " + idError );
            m_iLoadingIndex = file.loadingIndex;

            var bCallLoadFinished : Boolean = true;
            if( idError == 0 )
            {
                if( this.m_theBelongResourceLoadersRef.assetVersion != null && this.m_theBelongResourceLoadersRef.enableFileCheckLevel > EFileCheckLevel.NONE )
                {
                    var bDoFileCheck : Boolean = true;
                    if( this.m_theBelongResourceLoadersRef.enableFileCheckLevel == EFileCheckLevel.SIZE_CHECKSUM_BUT_SWF )
                    {
                        bDoFileCheck = CPath.ext( file.loadingURL ).toUpperCase() == ".SWF" ? false : true;
                    }

                    if( bDoFileCheck )
                    {
                        var sOrgFilename : String = file.loadingURL.substr( m_theBelongResourceLoadersRef.absoluteURI.length );
                        var sSubFilename : String = sOrgFilename.substr( m_theBelongResourceLoadersRef.assetVersion.assetPath.length );
                        var iFileSize : uint = this.m_theBelongResourceLoadersRef.assetVersion.findSize( sSubFilename );
                        if( iFileSize == file.numLoadedBytes )
                        {
                            if( m_theBelongResourceLoadersRef.enableFileCheckLevel >= EFileCheckLevel.SIZE_CHECKSUM &&
                                file.streamBuffer != null && m_theBelongResourceLoadersRef.resourceWorkerRef != null )
                            {
                                var sCheckSum : String = m_theBelongResourceLoadersRef.assetVersion.findChecksum( sSubFilename );
                                var aBytes : ByteArray = file.readAllBytes();
                                file.position = 0;

                                // call _loadFinished after worker finish checking and call _onWorkerCheckFinished()
                                //bCallLoadFinished = false;
                                //file.autoCloseAfterLoadFinished = false;

                                var event : CFileCheckRequestEvent = new CFileCheckRequestEvent();
                                event.set( this.loaderTaskID, file.loadingURL, sCheckSum, aBytes );
                                m_theBelongResourceLoadersRef.resourceWorkerRef.send( event );
                            }
                        }
                        else
                        {
                            // file size not match, try reload it for correction
                            Foundation.Log.logWarningMsg( "file size check FAILED: " + file.loadingURL + ": (error code:" + idError + ", " + iFileSize + " != " + file.numLoadedBytes + "), try correcting this error..." );
                            m_theBelongResourceLoadersRef.startLoadFile( sOrgFilename, _onFileCorrectionLoadFinished, CFileCorrectionLoader.NAME, ELoadingPriority.CRITICAL, true, true );
                        }
                    }
                }
            } else if (idError == - 3) { // occurs max retry num, we can't handle this.
                // notify the error stats.
//                Foundation.Log.logErrorMsg( "CBaseLoader._onLoadFinished: Occurs max retry num: " + file.loadingURL + " m_fnOnFatalErrorNotifier is null? " + ( null == m_fnOnFatalErrorNotifier ));
                if ( null != m_fnOnFatalErrorNotifier )
                    m_fnOnFatalErrorNotifier( file, idError );
            }

            if( bCallLoadFinished ) _loadFinished( file, idError );
        }

        //
        protected virtual function _createURLFile( sFilename : String ) : CURLFile
        {
            return new CURLFile( sFilename, null, false, this.streamLoaderClass);
        }

        //
        private function _onFileCorrectionLoadFinished( loader : CBaseLoader, idErrorCode : int ) : void
        {
            if( idErrorCode == 0 ) Foundation.Log.logWarningMsg( "file correction finished: " + loader.loadingFilename );
            else Foundation.Log.logErrorMsg( "file size correction FAILED: " + loader.loadingFilename + ": " + idErrorCode + ", this file CAN NOT be corrected..." );
        }

        //
        //
        protected var m_theBelongResourceLoadersRef : CResourceLoaders = null;
        protected var m_vFilenames : Vector.<String> = new Vector.<String>( 1 );
        protected var m_sName: String = null;

        protected var m_theURLFile : CURLFile = null;
        protected var m_fnOnFinished : Function;
        protected var m_fnOnProgress : Function;
        protected var m_iPriority : int = ELoadingPriority.NORMAL;
        protected var m_aArguments : Array = null;
        protected var m_iBeginLoadingIdx : int = 0;
        protected var m_bSuppressLoadErrorMsg : Boolean = false;
        protected var m_bRandomVersion : Boolean = false;

        protected var m_iLoaderTaskID : int = -1;
        protected var m_iDependentToLoaderTaskID : int = -1;

        protected var m_iLoadingIndex : int = -1;
        protected var m_bDone : Boolean = false;
        protected var m_bDoneFromCache : Boolean = false;
        protected var m_bCheckCacheWhenStarted : Boolean = true;

        protected var m_bRecycled : Boolean = false;

        protected var m_pStreamLoaderClass : Class = null;

        internal var m_fnOnFatalErrorNotifier : Function;
    }

}

