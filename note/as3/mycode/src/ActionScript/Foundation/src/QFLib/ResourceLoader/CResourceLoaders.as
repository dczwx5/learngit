//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/3/12
//----------------------------------------------------------------------------------------------------------------------

package QFLib.ResourceLoader
{

import QFLib.Foundation;
import QFLib.Foundation.*;
import QFLib.Interface.IDisposable;
import QFLib.Memory.CResourcePool;
import QFLib.Memory.CResourcePools;
import QFLib.Memory.CSmartObject;
import QFLib.ResourceLoader.Worker.CFileCheckResponseEvent;
import QFLib.Worker.CWorkerRef;
import QFLib.Worker.CWorkerSystem;

import flash.events.TimerEvent;
import flash.utils.Timer;

//
    //
    //
    public class CResourceLoaders extends CSmartObject
    {
        public static function instance() : CResourceLoaders
        {
            if( s_theInstance == null ) s_theInstance = new CResourceLoaders();
            return s_theInstance;
        }

        public function CResourceLoaders( iMaxRunningInstances : int = 4, bForceLowerCaseFilename : Boolean = false,
                                            fFPS : Number = 15.0 /* set fFPS to non-zero if you want CResourceLoader call Update() itself */,
                                            theResourceCache : CResourceCache = null )
        {
            m_iMaximumRunningInstances = iMaxRunningInstances;

            var i : int;
            for( i = 0; i < ELoadingPriority.NUM_PRIORITIES; i++ )
            {
                m_vQueuingLoaderInstances[ i ] = new Vector.<CBaseLoader>();
                m_vWaitingLoaderInstances[ i ] = new Vector.<CBaseLoader>();
            }

            registerLoader( CByteArrayLoader );
            registerLoader( CFileCorrectionLoader );
            registerLoader( CJsonLoader );
            registerLoader( CQsonLoader );
            registerLoader( CXmlLoader );
            registerLoader( CMP3Loader );
            registerLoader( CQbinLoader );
            registerLoader( CPackedJsonLoader );
            registerLoader( CPackedQsonLoader );
            registerLoader( CSwfLoader );

            if( fFPS > 0.0 )
            {
                var iMilliSec : int = 1000.0 / fFPS;

                m_theRunTimer = new Timer( iMilliSec );
                m_theRunTimer.addEventListener( TimerEvent.TIMER, _onTimer );
                m_theRunTimer.start();

                m_theTimer = new CTimer();
                m_theTimer.reset();
            }

            m_bForceLowerCaseFilename = bForceLowerCaseFilename;
            m_theResourceCache = theResourceCache;
            if( m_theResourceCache == null ) m_theResourceCache = CResourceCache.instance();
        }
        public override function dispose() : void
        {
            super.dispose();

            m_theRunTimer.removeEventListener( TimerEvent.TIMER, _onTimer );
            m_theRunTimer.stop();
            m_theRunTimer = null;

            m_theTimer = null;

            clearAll();

            m_mapResourceLoaders.clear();
            m_mapResourceLoaders = null;

            m_mapFatalFailedCallbacks.clear();
            m_mapFatalFailedCallbacks = null;

            m_theWorkerSystem.dispose();
            m_theWorkerSystem = null;

            m_sAbsoluteURI = "";

            if( this == s_theInstance ) s_theInstance = null;
        }

        public function clearAll() : void
        {
            var i : int;
            var obj : IDisposable;

            for( var j : int = 0; j < ELoadingPriority.NUM_PRIORITIES; j++ )
            {
                for( i = 0; i < m_vQueuingLoaderInstances[ j ].length; i++ )
                {
                    obj = m_vQueuingLoaderInstances[ j ][ i ] as IDisposable;
                    if( obj != null ) obj.dispose();
                }
                m_vQueuingLoaderInstances[ j ].length = 0;

                for( i = 0; i < m_vWaitingLoaderInstances[ j ].length; i++ )
                {
                    obj = m_vWaitingLoaderInstances[ j ][ i ] as IDisposable;
                    if( obj != null ) obj.dispose();
                }
                m_vWaitingLoaderInstances[ j ].length = 0;
            }

            for( i = 0; i < m_vRunningLoaderInstances.length; i++ )
            {
                obj = m_vRunningLoaderInstances[ i ] as IDisposable;
                if( obj != null ) obj.dispose();
            }
            m_vRunningLoaderInstances.length = 0;

            m_theLoaderPools.dispose();
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

        [Inline]
        final public function registerLoader( clsLoader : Class ) : void
        {
            m_mapResourceLoaders.add( clsLoader.NAME.toUpperCase(), clsLoader );
        }
        [Inline]
        final public function unregisterLoader( clsLoader : Class ) : void
        {
            m_mapResourceLoaders.remove( clsLoader.NAME.toUpperCase() );
        }

        [Inline]
        final public function get assetVersion() : CAssetVersion
        {
            return m_theAssetVersion;
        }
        [Inline]
        final public function insertAssetVersion( assetVersion : CAssetVersion ) : void
        {
            m_theAssetVersion = assetVersion;
        }

        //
        // callback: function fnOnFinished( file : CURLFile, idErrorCode : int ) : void
        // iFileVersion : 0: unspecified, 1: using format generated from 'svn list -v -R', 2: using format generated from StarAutobuild(with md5 checksum)
        //
        [Inline]
        final public function createAssetVersion( sFilename : String, sAssetPath : String = null, pfnFinished : Function = null, iFileVersion : int = 2, urlVersion : String = null ) : void
        {
            m_theAssetVersion = new CAssetVersion();
            m_theAssetVersion.loadFile( sFilename, sAssetPath, pfnFinished, iFileVersion, urlVersion );
        }

        [Inline]
        final public function createAssetVersionByData(  sFilename : String, sAssetVerData : String, sAssetPath : String = null, iFileVersion : int = 2 ) : void
        {
            m_theAssetVersion = new CAssetVersion();
            m_theAssetVersion.loadFile2( sFilename, sAssetVerData, sAssetPath, iFileVersion );
        }

        //
        // function onWorkerStartFinished( sName : String, sFilename : String, theWorkerRef : CWorkerRef, idErrorCode : int ) : void
        //
        [Inline]
        final public function createResourceWorker( sSWFFilename : String ) : Boolean
        {
            return m_theWorkerSystem.createWorker( "FoundationResourceWorker", sSWFFilename, _onWorkerStartFinished, ELoadingPriority.CRITICAL, true, true );
        }
        [Inline]
        final public function get resourceWorkerRef() : CWorkerRef
        {
            return m_theResourceWorkerRef;
        }

        [Inline]
        final public function get numMaximumRunningInstances() : int { return m_iMaximumRunningInstances; }
        [Inline]
        final public function get numCurrentRunningInstances() : int { return m_vRunningLoaderInstances.length; }

        [Inline]
        final public function get absoluteURI() : String { return m_sAbsoluteURI; }
        [Inline]
        final public function set absoluteURI( sURI : String ) : void
        {
            if( sURI == null ) sURI = "";
            m_sAbsoluteURI = sURI;
            if ( m_theAssetVersion ) m_theAssetVersion.absoluteURI = sURI;
        }

        [Inline]
        final public function get enableFileExistencePreChecking() : Boolean
        {
            return m_bEnableFileExistenceCheckingInAssetVersion;
        }
        [Inline]
        final public function set enableFileExistencePreChecking( bValue : Boolean ) : void
        {
            m_bEnableFileExistenceCheckingInAssetVersion = bValue;
        }

        [Inline]
        final public function get enableFileCheckLevel() : int
        {
            return m_iEnableFileCheckLevel;
        }
        [Inline]
        final public function set enableFileCheckLevel( iLevel : int ) : void
        {
            m_iEnableFileCheckLevel = iLevel;
        }

        [Inline]
        final public function get forceLowerCaseFilename() : Boolean
        {
            return m_bForceLowerCaseFilename;
        }
        [Inline]
        final public function set forceLowerCaseFilename( bForceLowerCase : Boolean ) : void
        {
            m_bForceLowerCaseFilename = bForceLowerCase;
        }

        [Inline]
        final public function get resourceCache() : CResourceCache // default the same as CResourceCache.instance()
        {
            return m_theResourceCache;
        }

        public function addFatalFailedCallback( pfnFatalFailed : Function )  : void
        {
            if ( null != pfnFatalFailed )
                m_mapFatalFailedCallbacks.add( pfnFatalFailed, true, true );
        }

        public function countAccumulatedLoaderTasks() : int
        {
            var iNumTasks : int = 0;
            for( var j : int = 0; j < ELoadingPriority.NUM_PRIORITIES; j++ )
            {
                iNumTasks += m_vAccumulatedLoaderTasks[ j ];
            }
            return iNumTasks;
        }
        public function countQueuingLoaderInstancesAll() : int
        {
            var iNumInstances : int = 0;
            for( var j : int = 0; j < ELoadingPriority.NUM_PRIORITIES; j++ )
            {
                iNumInstances += m_vQueuingLoaderInstances[ j ].length;
                iNumInstances += m_vWaitingLoaderInstances[ j ].length;
            }
            return iNumInstances;
        }
        public function countQueuingLoaderInstancesWithPriority( iPriority : int, bAndAbove : Boolean = true ) : int
        {
            if( iPriority >= 0 && iPriority < ELoadingPriority.NUM_PRIORITIES )
            {
                if( bAndAbove )
                {
                    var iNumInstances : int = 0;
                    for( var j : int = iPriority; j < ELoadingPriority.NUM_PRIORITIES; j++ )
                    {
                        iNumInstances += m_vQueuingLoaderInstances[ j ].length;
                        iNumInstances += m_vWaitingLoaderInstances[ j ].length;
                    }
                    return iNumInstances;
                }
                else return m_vQueuingLoaderInstances[ iPriority ].length + m_vWaitingLoaderInstances[ iPriority ].length;
            }
            else return 0;
        }
        public function countRunningLoaderInstancesWithPriority( iPriority : int, bAndAbove : Boolean = true ) : int
        {
            var j : int;
            var iNumInstances : int = 0;
            var iLen : int = m_vRunningLoaderInstances.length;
            if( bAndAbove )
            {
                for( j = 0; j < iLen; j++ )
                {
                    if( m_vRunningLoaderInstances[ j ].priority >= iPriority ) iNumInstances++;
                }
            }
            else
            {
                for( j = 0; j < iLen; j++ )
                {
                    if( m_vRunningLoaderInstances[ j ].priority == iPriority ) iNumInstances++;
                }
            }
            return iNumInstances;
        }
        [Inline]
        final public function countAllLoaderInstancesWithPriority( iPriority : int, bAndAbove : Boolean = true ) : int
        {
            return countRunningLoaderInstancesWithPriority( iPriority, bAndAbove ) + countQueuingLoaderInstancesWithPriority( iPriority, bAndAbove );
        }

        //
        // callback: function _onLoadFinished( loader : CBaseLoader, idErrorCode : int ) : void
        // callback: function _onLoadProgress( loader : CBaseLoader, iNumByteRead : Number, iTotalBytes : Number ) : void
        //
        public function startLoadFile( sFilename : String, fnOnFinished : Function, sSpecifiedLoaderName : String = null,
                                         iPriority : int = ELoadingPriority.NORMAL, bSuppressLoadErrorMsg : Boolean = false, bRandomVersion : Boolean = false,
                                         fnOnProgress : Function = null, ...args ) : void
        {
            var vFilenames : Vector.<String> = new Vector.<String>( 1 );
            vFilenames[ 0 ] = sFilename;
            //startLoadFileFromPathSequence( vFilenames, fnOnFinished, sSpecifiedLoaderName, iPriority, bSuppressLoadErrorMsg, fnOnProgress, args );
            startLoadFileFromPathSequence.apply( null, [ vFilenames, fnOnFinished, sSpecifiedLoaderName, iPriority, bSuppressLoadErrorMsg, bRandomVersion, fnOnProgress ].concat(args) );
        }
        public function startLoadFileFromPathSequence( vFilenames : Vector.<String>, fnOnFinished : Function, sSpecifiedLoaderName : String = null,
                                                         iPriority : int = ELoadingPriority.NORMAL, bSuppressLoadErrorMsg : Boolean = false, bRandomVersion : Boolean = false,
                                                         fnOnProgress : Function = null, ...args ) : void
        {
            for( var j : int = 0; j < vFilenames.length; j++ )
            {
                if( m_bForceLowerCaseFilename ) vFilenames[ j ] =  vFilenames[ j ].toLowerCase();
                if ( m_sAbsoluteURI != null && m_sAbsoluteURI.length > 0 ) vFilenames[ j ] = CPath.addRightSlash( m_sAbsoluteURI ) + vFilenames [ j ];
                if( this.assetVersion != null )
                {
                    vFilenames[ j ] = this.assetVersion.mappingFilename( vFilenames[ j ] ); // mapping to its original filename
                }
            }

            var vExt : String;
            if( sSpecifiedLoaderName != null ) vExt = sSpecifiedLoaderName.toUpperCase();
            else vExt = CPath.ext( vFilenames[ 0 ] ).toUpperCase();

            var theLoaderInstance : CBaseLoader = null;

            var theLoaderPool : CResourcePool = m_theLoaderPools.getPool( vExt );
            if( theLoaderPool != null ) theLoaderInstance = theLoaderPool.allocate() as CBaseLoader;
            if( theLoaderInstance == null )
            {
                var clsLoader : Class = m_mapResourceLoaders.find( vExt ) as Class;
                if( clsLoader != null ) theLoaderInstance = new clsLoader( this );
                else
                {
                    theLoaderInstance = new CBaseLoader( this );
                    if( bSuppressLoadErrorMsg == false )
                    {
                        Foundation.Log.logErrorMsg( "The file loader cannot be found, use default file loader instead: '" + vExt + "' for file: " + vFilenames[ 0 ] );
                        //throw new IOErrorEvent( "Loader can not be found: " + vExt, false, false, "The file loader cannot be found: '" + vExt + "' for file: " + vFilenames[0], -1 )
                    }
                }
            }

            theLoaderInstance.streamLoaderClass = this.streamLoaderClass;

            theLoaderInstance.set( vFilenames[ 0 ], fnOnFinished, iPriority, bSuppressLoadErrorMsg, bRandomVersion, fnOnProgress );
            for( var i : int = 1; i < vFilenames.length; i++ )
            {
                theLoaderInstance.filenames.push( vFilenames[ i ] );
            }
            theLoaderInstance.arguments = args;
            theLoaderInstance.m_fnOnFatalErrorNotifier = this._onLoadFatalFailed;

            //check if file existed in assetVersion
            var iBeginLoadingIndex : int = 0;
            if( m_bEnableFileExistenceCheckingInAssetVersion )
            {
                for( var k : int = 0; k < vFilenames.length; k++ )
                {
                    if( this.assetVersion.mappingFileVersion( vFilenames[ k ] ) == null ) iBeginLoadingIndex++;
                    else break;
                }
            }
            if( iBeginLoadingIndex == vFilenames.length )
            {
                theLoaderInstance._directFinished( iBeginLoadingIndex - 1, false, 2032 ); // file not found
                _recycleInstance( theLoaderInstance );
            }
            else
            {
                theLoaderInstance.beginLoadingIndex = iBeginLoadingIndex;

                // try find it in cache
                var iFoundLoadingIndex : int = _findInCache( theLoaderInstance );
                if( iFoundLoadingIndex >= 0 )
                {
                    theLoaderInstance._directFinished( iFoundLoadingIndex, true );
                    _recycleInstance( theLoaderInstance );
                }
                else _addLoaderInstance( theLoaderInstance, iPriority );
            }
        }

        public function update( fDeltaTime : Number ) : void
        {
            while( m_vRunningLoaderInstances.length > 0 )
            {
                if( _recycleAnInstance() == false ) break;
            }

            while( m_vRunningLoaderInstances.length < m_iMaximumRunningInstances )
            {
                if( _startAnInstance() == false ) break;
            }

            for each( var loader : CBaseLoader in m_vRunningLoaderInstances ) loader.update();
            m_theLoaderPools.update( fDeltaTime );
        }

        public function dump( bDetail : Boolean, bXmlFormat : Boolean = false, sWithFilter : String = null ) : String
        {
            var sContext : String = "";

            if( bXmlFormat ) sContext += "<font face =\"Terminal\" size=\"" + 12 + "\" color=\"#FFFFFF\">";

            sContext = "ResourceLoader: " + this.countQueuingLoaderInstancesAll() + " / " + this.countAccumulatedLoaderTasks() +
                       " => " + this.numCurrentRunningInstances + " / " + this.numMaximumRunningInstances;

            sContext += " [";
            var iBegin : int = ELoadingPriority.NUM_PRIORITIES - 1;
            for( var i : int = iBegin; i >= 0; i-- )
            {
                if( i != iBegin ) sContext += ", ";
                sContext += ELoadingPriority.PRIORITY_TITLES[ i ] + ": " + this.countAllLoaderInstancesWithPriority( i, false ) + " / " + m_vAccumulatedLoaderTasks[ i ];
            }
            sContext += "]";

            sContext += "\nResource Check Status: " + m_iNumFilesCheckPassed + " / " + m_iNumFilesChecked + " [ Corrected: " + m_iNumFilesCorrected + ", Failed: " + m_iNumFilesCorrectFailed + " ]";

            if( bXmlFormat ) sContext += "</font>";

            if( bDetail )
            {
                var sName : String;
                var loader : CBaseLoader;

                if( bXmlFormat ) sContext += "<font face =\"Terminal\" size=\"" + 12 + "\" color=\"#FFFFFF\">";

                sContext += "\n\n-Running Loaders: " + m_vRunningLoaderInstances.length;
                for each( loader in m_vRunningLoaderInstances )
                {
                    if( loader.loadingFilename != null ) sName = loader.loadingFilename;
                    else sName = loader.filename;

                    if( sWithFilter == null || sName.indexOf( sWithFilter ) >= 0 )
                    {
                        sContext += "\n--> " + sName;
                    }
                }

                for( var j : int = iBegin; j >= 0; j-- )
                {
                    sContext += "\n\n-Queuing Loaders(" + ELoadingPriority.PRIORITY_TITLES[ j ] + "): " + m_vQueuingLoaderInstances[ j ].length;
                    for each( loader in m_vQueuingLoaderInstances[ j ] )
                    {
                        if( loader == null ) continue;

                        if( loader.loadingFilename != null ) sName = loader.loadingFilename;
                        else sName = loader.filename;

                        if( sWithFilter == null || sName.indexOf( sWithFilter ) >= 0 )
                        {
                            sContext += "\n--> " + sName;
                        }
                    }
                }

                if( bXmlFormat ) sContext += "</font>";
            }

            return sContext;
        }

        //
        //
        private function _onLoadFatalFailed( file : CURLFile, idError : int ) : void
        {
//            Foundation.Log.logWarningMsg("CResourceLoaders._onLoadFatalFailed: callbacks's count: " + m_mapFatalFailedCallbacks.count );
            if ( m_mapFatalFailedCallbacks && m_mapFatalFailedCallbacks.count ) {
                for ( var pFn : Function in m_mapFatalFailedCallbacks ) {
                    if ( null != pFn ) {
                        try {
                            pFn( file, idError );
                        } catch ( e : Error ) {}
                    }
                }
            }
        }

        //
        //
        private function _onTimer( e:TimerEvent ) : void
        {
            update( m_theTimer.seconds() );
            m_theTimer.reset();
        }

        private function _findInCache( loaderInstance : CBaseLoader ) : int
        {
            var iLen : int = loaderInstance.filenames.length;
            for( var j : int = 0; j < iLen; j++ )
            {
                if( m_theResourceCache.isExisted( loaderInstance.filenames[ j ], loaderInstance.name ) ) return j;
            }
            return -1;
        }

        private function _addLoaderInstance( loaderInstance : CBaseLoader, iPriority : int = ELoadingPriority.NORMAL ) : void
        {
            if( iPriority < 0 || iPriority >= ELoadingPriority.NUM_AVAILABLE_PRIORITIES ) return ;

            loaderInstance._setLoaderTaskID( m_iLoaderSequenceIDCounter++ );
            if( m_iLoaderSequenceIDCounter > 10000 ) m_iLoaderSequenceIDCounter = 0;

            var iDependentSequenceID : int = _findAndAdjustDependency( loaderInstance, iPriority );
            if( iDependentSequenceID >= 0 )
            {
                loaderInstance._setDependentToLoaderTaskID( iDependentSequenceID );
                m_vWaitingLoaderInstances[ iPriority ].push( loaderInstance );
            }
            else
            {
                m_vQueuingLoaderInstances[ iPriority ].push( loaderInstance );
                if( m_vRunningLoaderInstances.length < m_iMaximumRunningInstances ) _startAnInstance(); // start loading immediately
            }

            m_vAccumulatedLoaderTasks[ iPriority ]++;
        }

        private function _startAnInstance() : Boolean
        {
            if( m_theAssetVersion != null )
            {
                if( m_theAssetVersion.isLoading ) return false; // wait for asset version file load finished
            }

            for( var j : int = ELoadingPriority.NUM_PRIORITIES - 1; j >= 0; j-- )
            {
                var loaderInstance : CBaseLoader = null;
                while( m_vQueuingLoaderInstances[ j ].length > 0 )
                {
                    loaderInstance = m_vQueuingLoaderInstances[ j ].shift();
                    if( loaderInstance != null ) break;
                }
                if( loaderInstance == null ) continue;

                loaderInstance.start();
                m_vRunningLoaderInstances.push( loaderInstance );
                return true;
            }

            return false;
        }
        private function _recycleAnInstance() : Boolean
        {
            if( m_vRunningLoaderInstances.length == 0 ) return false;
            if( m_vRunningLoaderInstances[ 0 ].isDone() == false ) return false;

            var loaderInstance : CBaseLoader = m_vRunningLoaderInstances.shift();
            var iFinishedTaskID : int = loaderInstance.loaderTaskID;

            _recycleInstance( loaderInstance );

            _WakeupLoaderInstancesInWaitingList( iFinishedTaskID );
            return true;
        }

        private function _recycleInstance( loaderInstance : CBaseLoader ) : Boolean
        {
            if( loaderInstance.isDone() == false )
            {
                Foundation.Log.logErrorMsg( "cannot recycle an non-Done loader: " + loaderInstance.name );
                return false;
            }

            var theLoaderPool : CResourcePool = m_theLoaderPools.getPool( loaderInstance.name );
            if( theLoaderPool == null )
            {
                theLoaderPool = new CResourcePool( loaderInstance.name, null );
                m_theLoaderPools.addPool( loaderInstance.name, theLoaderPool );
            }

            theLoaderPool.recycle( loaderInstance );
            return true;
        }

        private function _findAndAdjustDependency( theLoaderInstance : CBaseLoader, iPriority : int ) : int
        {
            var loaderInstance : CBaseLoader;
            var i : int;
            var j : int;
            var k : int;

            // find in m_vRunningLoaderInstances
            for( i = 0; i < m_vRunningLoaderInstances.length; i++ )
            {
                loaderInstance = m_vRunningLoaderInstances[ i ];

                for( j = 0; j < loaderInstance.filenames.length; j++ )
                {
                    for( k = 0; k < theLoaderInstance.filenames.length; k++ )
                    {
                        if( loaderInstance.filenames[ j ] == theLoaderInstance.filenames[ k ] )
                        {
                            return loaderInstance.loaderTaskID;
                        }
                    }
                }
            }

            // find in m_vQueuingLoaderInstances
            if( iPriority > ELoadingPriority.NUM_PRIORITIES - 1 ) iPriority = ELoadingPriority.NUM_PRIORITIES - 1;
            for( var l : int = ELoadingPriority.NUM_PRIORITIES - 1; l >= 0; l-- )
            {
                for( i = 0; i < m_vQueuingLoaderInstances[ l ].length; i++ )
                {
                    loaderInstance = m_vQueuingLoaderInstances[ l ][ i ];
                    if( loaderInstance == null ) continue;

                    for( j = 0; j < loaderInstance.filenames.length; j++ )
                    {
                        for( k = 0; k < theLoaderInstance.filenames.length; k++ )
                        {
                            if( loaderInstance.filenames[ j ] == theLoaderInstance.filenames[ k ] )
                            {
                                if( iPriority > l )
                                {
                                    // up-lift the priority
                                    m_vQueuingLoaderInstances[ l ][ i ] = null;
                                    m_vQueuingLoaderInstances[ iPriority ].push( loaderInstance );
                                }
                                return loaderInstance.loaderTaskID;
                            }
                        }
                    }
                }
            }

            return -1;
        }
        private function _WakeupLoaderInstancesInWaitingList( iFinishedTaskID : int ) : void
        {
            var loaderInstance : CBaseLoader;
            var firstLoaderInstance : CBaseLoader;
            var iLoaderIndex : int = -1;

            for( var j : int = ELoadingPriority.NUM_AVAILABLE_PRIORITIES - 1; j >= 0; j-- )
            {
                for( var i : int = 0; i < m_vWaitingLoaderInstances[ j ].length; i++ )
                {
                    loaderInstance = m_vWaitingLoaderInstances[ j ][ i ];
                    if( loaderInstance != null && loaderInstance.dependentToLoaderTaskID == iFinishedTaskID )
                    {
                        iLoaderIndex++;
                        if( iLoaderIndex == 0 )
                        {
                            firstLoaderInstance = loaderInstance;
                            m_vQueuingLoaderInstances[ ELoadingPriority.HOT_CRITICAL ].push( loaderInstance );
                            m_vWaitingLoaderInstances[ j ][ i ] = null;
                            continue;
                        }
                        loaderInstance._setDependentToLoaderTaskID( firstLoaderInstance.loaderTaskID );
                    }
                }

                // clear instances that already add into m_vQueuingLoaderInstances
                while( m_vWaitingLoaderInstances[ j ].length > 0 && m_vWaitingLoaderInstances[ j ][ 0 ] == null )
                {
                    m_vWaitingLoaderInstances[ j ].shift();
                }
            }
        }

        //
        private function _onWorkerStartFinished( sName : String, sFilename : String, theWorkerRef : CWorkerRef, idErrorCode : int ) : void
        {
            if( idErrorCode == 0 )
            {
                theWorkerRef.registerMessageHandler( CFileCheckResponseEvent, _onFileCheckResponseEvent );
                m_theResourceWorkerRef = theWorkerRef;
                Foundation.Log.logMsg( "Worker started: " + theWorkerRef.name );
            }
            else
            {
                Foundation.Log.logErrorMsg( "start worker failed: " + sName + "(" + sFilename + "), error code: " + idErrorCode );
            }
        }

        private function _onFileCheckResponseEvent( theWorkerRef : CWorkerRef, event : CFileCheckResponseEvent ) : void
        {
            m_iNumFilesChecked++;

            if( event.result != 0 )
            {
                Foundation.Log.logWarningMsg( "file checksum FAILED: " + event.filename + ": (error code:" + event.result + "), try correcting this error..." );
                var sOrgFilename : String = event.filename.substr( this.absoluteURI.length );
                this.startLoadFile( sOrgFilename, _onFileCorrectionLoadFinished, CFileCorrectionLoader.NAME, ELoadingPriority.CRITICAL, true, true );
            }
            else m_iNumFilesCheckPassed++;
        }

        //
        private function _onFileCorrectionLoadFinished( loader : CBaseLoader, idErrorCode : int ) : void
        {
            if( idErrorCode == 0 )
            {
                Foundation.Log.logWarningMsg( "file correction finished: " + loader.loadingFilename );
                m_iNumFilesCorrected++;
            }
            else
            {
                Foundation.Log.logErrorMsg( "file checksum correction FAILED: " + loader.loadingFilename + ": (error code:" + idErrorCode + "), this file CAN NOT be corrected..." );
                m_iNumFilesCorrectFailed++;
            }
        }

        //
        //
        private var m_theRunTimer : Timer = null;
        private var m_theTimer: CTimer = null;

        private var m_mapResourceLoaders : CMap = new CMap();
        private var m_mapFatalFailedCallbacks : CMap = new CMap();

        private var m_vQueuingLoaderInstances : Vector.< Vector.<CBaseLoader> > = new Vector.< Vector.<CBaseLoader> >( ELoadingPriority.NUM_PRIORITIES );
        private var m_vWaitingLoaderInstances : Vector.< Vector.<CBaseLoader> > = new Vector.< Vector.<CBaseLoader> >( ELoadingPriority.NUM_PRIORITIES );
        private var m_vAccumulatedLoaderTasks : Vector.< int > = new Vector.< int >( ELoadingPriority.NUM_PRIORITIES );
        private var m_vRunningLoaderInstances : Vector.<CBaseLoader> = new Vector.<CBaseLoader>;

        private var m_theLoaderPools : CResourcePools = new CResourcePools();
        private var m_theResourceCache : CResourceCache = null;
        private var m_theAssetVersion : CAssetVersion = null;

        private var m_theWorkerSystem :  CWorkerSystem = new CWorkerSystem();
        private var m_theResourceWorkerRef : CWorkerRef = null;
        private var m_iEnableFileCheckLevel : int = EFileCheckLevel.NONE;

        private var m_iMaximumRunningInstances : int = 0;
        private var m_iLoaderSequenceIDCounter : int = 0;

        private var m_bForceLowerCaseFilename : Boolean = false;
        private var m_bEnableFileExistenceCheckingInAssetVersion : Boolean = false;

        private var m_sAbsoluteURI : String = "";

        private var m_iNumFilesChecked : int = 0;
        private var m_iNumFilesCheckPassed : int = 0;
        private var m_iNumFilesCorrected : int = 0;
        private var m_iNumFilesCorrectFailed : int = 0;

        private var m_pStreamLoaderClass : Class;

        private static var s_theInstance : CResourceLoaders = null;

    }

}
