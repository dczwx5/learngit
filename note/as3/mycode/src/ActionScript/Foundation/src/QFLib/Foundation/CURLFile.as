//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/1/29
//----------------------------------------------------------------------------------------------------------------------

package QFLib.Foundation
{
    import QFLib.Foundation;
    import QFLib.Memory.CSmartObject;

    import flash.events.Event;
    import flash.events.HTTPStatusEvent;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.net.URLRequest;
    import flash.utils.ByteArray;

    //
    //
    //
    public class CURLFile extends CSmartObject
    {
        public static const OPEN_TIMEOUT : Number = 15.0;
        public static const PROGRESS_TIMEOUT : Number = 10.0;

        public function CURLFile( sURL : String = "", sURLVersion : String = null, bLoadFileWithVersionOnly : Boolean = false, pStreamLoaderClass : Class = null )
        {
            m_vURLs = new Vector.<String>( 1 );
            m_vURLs[ 0 ] = sURL;

            if( sURLVersion != null )
            {
                m_vURLVersions = new Vector.<String>( 1 );
                m_vURLVersions[ 0 ] = sURLVersion;
            }

            m_bLoadFileWithVersionOnly = bLoadFileWithVersionOnly;
            m_pUrlStreamDelegaterClass = pStreamLoaderClass;
            m_pUrlStreamDelegaterClass = m_pUrlStreamDelegaterClass || CURLFileStream;
        }

        public override function dispose() : void
        {
            super.dispose();
            close( true );
            m_byStreamBuffer = null;
            m_vURLs = null;
            m_vURLVersions = null;

            if ( m_pUrlStreamDelegater )
                m_pUrlStreamDelegater.dispose();
            m_pUrlStreamDelegater = null;
            m_pUrlStreamDelegaterClass = null;
        }

        public virtual function close( bFullCleanUp : Boolean = false ) : void
        {
            if( m_pUrlStreamDelegater )
            {
                m_pUrlStreamDelegater.removeEventListener( Event.OPEN, _onOpened );
                m_pUrlStreamDelegater.removeEventListener( Event.COMPLETE, _onCompleted );
                m_pUrlStreamDelegater.removeEventListener( ProgressEvent.PROGRESS, _onProgress );
                m_pUrlStreamDelegater.removeEventListener( IOErrorEvent.IO_ERROR, _onError );
                m_pUrlStreamDelegater.removeEventListener( HTTPStatusEvent.HTTP_STATUS, _onHttpStatus );
                m_pUrlStreamDelegater.close();
            }

            if( m_byStreamBuffer )
            {
                if( bFullCleanUp ) m_byStreamBuffer = null;
                else m_byStreamBuffer.clear(); // reserve m_byStreamBuffer for later use
            }

            m_fnOnFinished = null;
            m_fnOnProgress = null;

            m_iErrorCode = 0;
            m_iNumLoadedBytes = 0;
            m_iNumTotalBytes = 0;

            m_theProgressTimer = null;

            m_bSuppressLoadErrorMsg = false;
            m_bUseStreamBufferMode = m_bInStreamBufferMode = false;
            m_bAutoCloseAfterLoadFinished = true;
            m_iLoadingIdx = -1;
            m_iNumProgressTimeouts = 0;
        }

        [Inline]
        final public function get streamLoaderClass() : Class
        {
            return m_pUrlStreamDelegaterClass;
        }

        [Inline]
        final public function set streamLoaderClass( value : Class ) : void {
            m_pUrlStreamDelegaterClass = value;
        }

        [Inline]
        final public function get url() : String
        {
            return m_vURLs[ 0 ];
        }
        [Inline]
        final public function set url( sURL : String ) : void
        {
            m_vURLs[ 0 ] = sURL;
        }
        [Inline]
        final public function get urls() : Vector.<String>
        {
            return m_vURLs;
        }
        [Inline]
        final public function set urls( vURLs : Vector.<String> ) : void
        {
            m_vURLs = vURLs;
        }

        [Inline]
        final public function get urlVersion() : String
        {
            if( m_vURLVersions == null ) return null;
            return m_vURLVersions[ 0 ];
        }
        [Inline]
        final public function set urlVersion( sURLVersion : String ) : void
        {
            if( m_vURLVersions == null ) m_vURLVersions = new Vector.<String>( 1 );
            m_vURLVersions[ 0 ] = sURLVersion;
        }
        [Inline]
        final public function get urlVersions() : Vector.<String>
        {
            return m_vURLVersions;
        }
        [Inline]
        final public function set urlVersions( vURLVersions : Vector.<String> ) : void
        {
            m_vURLVersions = vURLVersions;
        }

        [Inline]
        public function get loadingURL() : String
        {
            if( m_iLoadingIdx < 0 ) return null;
            return m_vURLs[ m_iLoadingIdx ];
        }
        public function get loadingURLVersion() : String
        {
            if( m_iLoadingIdx < 0 || m_vURLVersions == null ) return null;
            else if( m_iLoadingIdx >= m_vURLVersions.length ) return null;
            else return m_vURLVersions[ m_iLoadingIdx ];
        }
        [Inline]
        public function getURLVersion( iLoadingIdx : int ) : String
        {
            if( m_vURLVersions == null ) return null;
            if( iLoadingIdx >= m_vURLVersions.length ) return null;
            else return m_vURLVersions[ iLoadingIdx ];
        }

        [Inline]
        public function get loadFileWithVersionOnly() : Boolean
        {
            return m_bLoadFileWithVersionOnly;
        }
        [Inline]
        public function set loadFileWithVersionOnly( bEnable : Boolean ) : void
        {
            m_bLoadFileWithVersionOnly = bEnable;
        }

        [Inline]
        public function get autoCloseAfterLoadFinished() : Boolean
        {
            return m_bAutoCloseAfterLoadFinished;
        }
        [Inline]
        public function set autoCloseAfterLoadFinished( bAutoClose : Boolean ) : void
        {
            m_bAutoCloseAfterLoadFinished = bAutoClose;
        }

        virtual protected function createStreamLoader() : IURLFileStream {
            return new this.streamLoaderClass();
        }

        //
        // callback: function fnOnFinished( file : CURLFile, idErrorCode : int ) : void
        // callback: function fnOnPregress( file : CURLFile, iNumBytesLoaded : int, iNumBytesTotal : int ) : void
        //
        public virtual function startLoad( fnOnFinished : Function, fnOnProgress : Function = null,
                                               bSuppressLoadErrorMsg : Boolean = false, bUseStreamBufferMode : Boolean = false, bAutoCloseAfterLoadFinished : Boolean = true,
                                               iBeginLoadingIdx : int = 0, sAdditionalVersionTag : String = "" ) : void
        {
            m_fnOnFinished = fnOnFinished;
            m_fnOnProgress = fnOnProgress;
            m_bSuppressLoadErrorMsg = bSuppressLoadErrorMsg;
            m_bUseStreamBufferMode = bUseStreamBufferMode;
            m_bAutoCloseAfterLoadFinished = bAutoCloseAfterLoadFinished;

            m_pUrlStreamDelegater = this.createStreamLoader();
            m_pUrlStreamDelegater.addEventListener( Event.OPEN, _onOpened );
            m_pUrlStreamDelegater.addEventListener( Event.COMPLETE, _onCompleted );
            m_pUrlStreamDelegater.addEventListener( ProgressEvent.PROGRESS, _onProgress );
            m_pUrlStreamDelegater.addEventListener( IOErrorEvent.IO_ERROR, _onError );
            m_pUrlStreamDelegater.addEventListener( HTTPStatusEvent.HTTP_STATUS, _onHttpStatus );

            m_theProgressTimer = new CTimer( OPEN_TIMEOUT );

            try
            {
                // start loading
                var bFoundLegalURL : Boolean = false;
                for( iBeginLoadingIdx; iBeginLoadingIdx < m_vURLs.length; iBeginLoadingIdx++ )
                {
                    if( m_vURLs[ iBeginLoadingIdx ] != null && m_vURLs[ iBeginLoadingIdx ].length > 0 )
                    {
                        bFoundLegalURL = true;
                        if( m_bLoadFileWithVersionOnly )
                        {
                            var sBeginLoadingVersion : String = this.getURLVersion( iBeginLoadingIdx );
                            if( sBeginLoadingVersion != null && sBeginLoadingVersion != "" ) break;
                        }
                        else break;
                    }
                }
                if( iBeginLoadingIdx == m_vURLs.length && bFoundLegalURL == false )
                {
                    throw new IOErrorEvent( "No legal URLs to startLoad.", false, false, "No legal URLs to startLoad.", -1 );
                }

                m_iLoadingIdx = iBeginLoadingIdx;

                var sVersion : String = this.loadingURLVersion;
                if( sVersion != null && sVersion != "" ) m_pUrlStreamDelegater.load( new URLRequest( m_vURLs[ m_iLoadingIdx ] + "?_=" + sVersion + sAdditionalVersionTag ) );
                else
                {
                    if( m_bLoadFileWithVersionOnly )
                    {
                        _onError( new IOErrorEvent( "Skip startLoad due to it's URL version is null.", false, false, "Skip startLoad due to it's URL version is null.", -2 ) );
                    }
                    else m_pUrlStreamDelegater.load( new URLRequest( m_vURLs[ m_iLoadingIdx ] ) );
                }
            }
            catch( error : Error )
            {
                if ( !m_bSuppressLoadErrorMsg )
                    Foundation.Log.logErrorMsg( "Error happened when loading file: " + m_vURLs[ m_iLoadingIdx ] +
                                                ", " + error.toString() );
            }
        }

        [Inline]
        final virtual public function stopLoad() : void
        {
            close();
        }

        [Inline]
        final public function get numAvailableBytes() : uint
        {
            if( m_bInStreamBufferMode )
            {
                return m_byStreamBuffer.length - m_byStreamBuffer.position;
            }
            else
            {
                if( m_pUrlStreamDelegater == null ) return 0;
                return m_pUrlStreamDelegater.bytesAvailable;
            }
        }

        [Inline]
        final public function set position( iPos : uint ) : void
        {
            if( m_bInStreamBufferMode )
            {
                m_byStreamBuffer.position = iPos;
            }
            else
            {
                if ( m_pUrlStreamDelegater == null ) return;
                m_pUrlStreamDelegater.position = iPos;
            }
        }
        [Inline]
        final public function get position() : uint
        {
            if( m_bInStreamBufferMode )
            {
                return m_byStreamBuffer.position;
            }
            else
            {
                if ( m_pUrlStreamDelegater == null ) return 0;
                return m_pUrlStreamDelegater.position;
            }
        }

        public function retrieveBytes( byData : ByteArray, iLen : int ) : Boolean
        {
            if( m_bInStreamBufferMode )
            {
                if( m_byStreamBuffer.position + iLen > m_byStreamBuffer.length ) return false;
                m_byStreamBuffer.readBytes( byData, 0, iLen );
                return true;
            }
            else
            {
                if ( m_pUrlStreamDelegater == null ) return false;
                m_pUrlStreamDelegater.readBytes( byData, 0, iLen );
                return true;
            }
        }

        public function readAllBytes() : ByteArray
        {
            var byData : ByteArray = new ByteArray();
            if( m_bInStreamBufferMode )
            {
                m_byStreamBuffer.readBytes( byData, 0, m_byStreamBuffer.length - m_byStreamBuffer.position );
            }
            else
            {
                if ( m_pUrlStreamDelegater == null ) return null;
                m_pUrlStreamDelegater.readBytes( byData, 0, m_pUrlStreamDelegater.bytesAvailable );
            }
            return byData;
        }

        public function readAllText() : String
        {
            var sText : String;
            if( m_bInStreamBufferMode )
            {
                sText = m_byStreamBuffer.toString();
                m_byStreamBuffer.position = m_byStreamBuffer.length - 1;
                return sText;
            }
            else
            {
                if ( m_pUrlStreamDelegater == null ) return null;
                if ( m_pUrlStreamDelegater.bytesAvailable == 0 ) return null;

                if ( m_byStreamBuffer == null ) m_byStreamBuffer = new ByteArray();
                else m_byStreamBuffer.clear();

                m_pUrlStreamDelegater.readBytes( m_byStreamBuffer, 0, m_pUrlStreamDelegater.bytesAvailable );

                sText = m_byStreamBuffer.toString();
                m_byStreamBuffer.clear();
            }
            return sText;
        }

        [Inline]
        final public function get errorCode() : int
        {
            return m_iErrorCode;
        }
        [Inline]
        final public function get numLoadedBytes() : int
        {
            return m_iNumLoadedBytes;
        }
        [Inline]
        final public function get numTotalBytes() : int
        {
            return m_iNumTotalBytes;
        }
        [Inline]
        final public function get isLoading() : Boolean
        {
            return ( m_iLoadingIdx >= 0 ) ? true : false;
        }
        [Inline]
        final public function get loadingIndex() : int
        {
            return m_iLoadingIdx;
        }

        [Inline]
        final public function get stream() : IURLFileStream
        {
            return m_pUrlStreamDelegater;
        }
        [Inline]
        final public function get streamBuffer() : ByteArray
        {
            if( m_bInStreamBufferMode ) return m_byStreamBuffer;
            else return null;
        }

        [Inline]
        final public function get isInStreamBufferMode() : Boolean
        {
            return m_bInStreamBufferMode;
        }

        [Inline]
        final public function isProgressTimerTimeOut() : Boolean
        {
            if( m_theProgressTimer == null ) return false;
            if( m_iNumLoadedBytes == m_iNumTotalBytes && m_iNumTotalBytes != 0 ) return false;
            return m_theProgressTimer.isOnTime();
        }

        public virtual function update() : void
        {
            if( this.isProgressTimerTimeOut() )
            {
                m_iNumProgressTimeouts++;
                if( m_iNumProgressTimeouts > 2 )
                {
                    Foundation.Log.logErrorMsg( "Fail loading file of '" + m_vURLs[ m_iLoadingIdx ] + "' due to loading progress timeout!(" + m_iNumProgressTimeouts + ")" );
                    _onError( new IOErrorEvent( "File loading progress timeout!", false, false, "Fail loading file of '" + m_vURLs[ m_iLoadingIdx ] + "' due to loading progress timeout!(" + m_iNumProgressTimeouts + ")", -3 ) );
                }
                else
                {
                    Foundation.Log.logWarningMsg( "Restart file loading progress of '" + m_vURLs[ m_iLoadingIdx ] + "' due to loading progress timeout!(" + m_iNumProgressTimeouts + ")" );
                    var fnOnFinished : Function = m_fnOnFinished;
                    var fnOnProgress : Function = m_fnOnProgress;
                    var bSuppressLoadErrorMsg : Boolean = m_bSuppressLoadErrorMsg;
                    var bUseStreamBufferMode : Boolean = m_bUseStreamBufferMode;
                    var bAutoCloseAfterLoadFinished : Boolean = m_bAutoCloseAfterLoadFinished;

                    var iBeginLoadingIdx : int = m_iLoadingIdx;
                    var iNumProgressTimeouts : int = m_iNumProgressTimeouts;

                    close();
                    m_iNumProgressTimeouts = iNumProgressTimeouts;
                    startLoad( fnOnFinished, fnOnProgress, bSuppressLoadErrorMsg, bUseStreamBufferMode, bAutoCloseAfterLoadFinished, iBeginLoadingIdx, "_" + m_iNumProgressTimeouts );
                }
            }
        }

        //
        protected function _switchToStreamBufferMode() : Boolean
        {
            if( m_bInStreamBufferMode ) return false;

            if( m_pUrlStreamDelegater == null ) return false;
            if( m_pUrlStreamDelegater.bytesAvailable != m_iNumTotalBytes || m_iNumTotalBytes == 0 ) return false;

            Foundation.Perf.sectionBegin( "File_SwitchToStreamBufferMode" );

            if( m_byStreamBuffer == null ) m_byStreamBuffer = new ByteArray();
            else m_byStreamBuffer.clear();

            m_pUrlStreamDelegater.readBytes( m_byStreamBuffer, 0, m_pUrlStreamDelegater.bytesAvailable );
            m_bInStreamBufferMode = true;

            Foundation.Perf.sectionEnd( "File_SwitchToStreamBufferMode" );

            return true;
        }


        //
        //
        protected virtual function _onOpened( e : Event ) : void
        {
            m_theProgressTimer.reset();
            m_theProgressTimer.interval = PROGRESS_TIMEOUT;
        }
        protected virtual function _onCompleted( e : Event ) : void
        {
            m_iErrorCode = 0;

            if( m_bUseStreamBufferMode ) _switchToStreamBufferMode();
            if( m_fnOnFinished != null ) m_fnOnFinished( this, 0 );
            if( m_bAutoCloseAfterLoadFinished ) close();
        }

        protected virtual function _onError( e : IOErrorEvent ) : void
        {
            // check next available file to load
            var iNextLoadingIdx : int = m_iLoadingIdx + 1;
            for( iNextLoadingIdx; iNextLoadingIdx < m_vURLs.length; iNextLoadingIdx++ )
            {
                if( m_vURLs[ iNextLoadingIdx ] != null && m_vURLs[ iNextLoadingIdx ].length > 0 )
                {
                    if( m_bLoadFileWithVersionOnly )
                    {
                        var sNextLoadingVersion : String = this.getURLVersion( iNextLoadingIdx );
                        if( sNextLoadingVersion != null && sNextLoadingVersion != "" ) break;
                    }
                    else break;
                }
            }

            if( iNextLoadingIdx < m_vURLs.length )
            {
                m_iLoadingIdx = iNextLoadingIdx;

                var sVersion : String = this.loadingURLVersion;
                if( sVersion != null && sVersion != "" ) m_pUrlStreamDelegater.load( new URLRequest( m_vURLs[ m_iLoadingIdx ] + "?_=" + sVersion ) );
                else m_pUrlStreamDelegater.load( new URLRequest( m_vURLs[ m_iLoadingIdx ] ) );
            }
            else
            {
                m_iErrorCode = e.errorID;

                if( m_fnOnFinished != null ) m_fnOnFinished( this, e.errorID );

                if( m_bSuppressLoadErrorMsg == false )
                {
                    Foundation.Log.logErrorMsg( "Load failed: " + ( m_vURLs ? m_vURLs[ m_iLoadingIdx ] : "unknown" ) +
                                                ", error: " + e.toString() );
                }

                if( m_bAutoCloseAfterLoadFinished ) close();
            }
        }

        protected virtual function _onProgress( e : ProgressEvent ) : void
        {
            m_theProgressTimer && m_theProgressTimer.reset();

            m_iNumLoadedBytes = e.bytesLoaded;
            m_iNumTotalBytes = e.bytesTotal;
            if( m_fnOnProgress != null ) m_fnOnProgress( this, e.bytesLoaded, e.bytesTotal );
        }

        protected virtual function _onHttpStatus( e : HTTPStatusEvent ) : void
        {
            if( e.status != 0 && e.status != 200 )
            {
                Foundation.Log.logMsg( "Http url: " + ( m_vURLs ? m_vURLs[ m_iLoadingIdx ] : "unknown" ) +
                                       ", status: " + e.toString() );
            }
        }

        //
        //
        protected var m_vURLs : Vector.<String> = null;
        protected var m_vURLVersions : Vector.<String> = null;

        private var m_pUrlStreamDelegaterClass : Class = null;
        private var m_pUrlStreamDelegater : IURLFileStream = null;
        private var m_byStreamBuffer : ByteArray = null;

        protected var m_fnOnFinished : Function = null;
        protected var m_fnOnProgress : Function = null;

        protected var m_theProgressTimer : CTimer = null;
        private var m_iNumProgressTimeouts : int = 0;

        protected var m_iErrorCode : int = 0;
        private var m_iNumLoadedBytes : int = 0;
        private var m_iNumTotalBytes : int = 0;

        protected var m_iLoadingIdx : int = -1;
        protected var m_bLoadFileWithVersionOnly : Boolean = false;
        protected var m_bSuppressLoadErrorMsg : Boolean = false;
        protected var m_bUseStreamBufferMode : Boolean = false;
        protected var m_bInStreamBufferMode : Boolean = false;
        protected var m_bAutoCloseAfterLoadFinished : Boolean = true;
    }

}
