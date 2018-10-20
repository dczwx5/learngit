//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package QFLib.AirRuntime.FileSystem {

import QFLib.Foundation.IURLFileStream;

import flash.events.ErrorEvent;

import flash.events.Event;

import flash.events.EventDispatcher;
import flash.events.HTTPStatusEvent;
import flash.events.IEventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.URLRequest;
import flash.net.URLStream;
import flash.utils.ByteArray;
import flash.utils.IDataInput;

/**
 * 通过调用load方法对比本地与请求URL的差异选择如何提供对应的ByteArray
 * 根据不同的方式读取Stream，应当正确适配相应的事件处理。
 */
public class CMixURLFileStream extends EventDispatcher implements IURLFileStream {

    private static function _s_encodeURL( url : String ) : String
    {
        return encodeURIComponent( url ).replace( _s_pRegExp, _s_replaceInner );
    }

    private static function _s_replaceInner(...args ) : String
    {
        return "%" + args[ 0 ].charCodeAt( 0 ).toString( 16 );
    }

    private static var _s_pRegExp : RegExp = /[!'()*]/g;

    public function CMixURLFileStream( delegater : Class = null ) {
        if ( null == delegater ) {
            delegater = URLStream;
        }

        this._m_pDelegaterClass = delegater;
    }

    public function dispose() : void {
        close();

        _m_pDelegaterClass = null;
        _m_pDelegater = null;
        _m_pDataInput = null;

        _m_bDisposed = true;
    }

    public function get connected() : Boolean {
        return _m_bConnected;
    }

    public function close() : void {
        if ( _m_pFile )
        {
            try { _m_pFile.cancel(); }catch ( er: Error ){}
            _m_pFile.removeEventListener( Event.OPEN, _onOpen );
            _m_pFile.removeEventListener( Event.COMPLETE, _onUrlStreamLoadingFinished );
            _m_pFile.removeEventListener( ProgressEvent.PROGRESS, _onProgress );
            _m_pFile.removeEventListener( IOErrorEvent.IO_ERROR, _onUrlStreamLoadingIOError );
            _m_pFile.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, _onUrlStreamLoadingSecurityError );
            _m_pFile = null;
        }

        if ( _m_pDelegater )
        {
            try { _m_pDelegater["close"](); } catch ( er : Error ){}
            _m_pDelegater.removeEventListener( Event.OPEN, _onOpen );
            _m_pDelegater.removeEventListener( Event.COMPLETE, _onUrlStreamLoadingFinished );
            _m_pDelegater.removeEventListener( ProgressEvent.PROGRESS, _onProgress );
            _m_pDelegater.removeEventListener( IOErrorEvent.IO_ERROR, _onUrlStreamLoadingIOError );
            _m_pDelegater.removeEventListener( HTTPStatusEvent.HTTP_STATUS, _onHttpStatus );
            _m_pDelegater.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, _onUrlStreamLoadingSecurityError );
            _m_pDelegater = null;
        }

        _m_bConnected = false;
    }

    public function load( request : URLRequest ) : void {
        var url : String = request.url;
        _m_sLoadingUrl = url;
        _m_sEncodedLoadingUrl = _s_encodeURL( _m_sLoadingUrl );
        try
        {
            cancel();

            var cachedFile : File = File.applicationStorageDirectory;
            cachedFile = cachedFile.resolvePath( _m_sEncodedLoadingUrl );
            if ( cachedFile.exists )
            {
                trace( "AIR Loading in cached! Reading the file : " + _m_sEncodedLoadingUrl );
                _m_pFile = cachedFile;

                _m_pFile.addEventListener( Event.OPEN, _onOpen );
                _m_pFile.addEventListener( Event.COMPLETE, _onFileLoadingFinish );
                _m_pFile.addEventListener( ProgressEvent.PROGRESS, _onProgress );
                _m_pFile.addEventListener( IOErrorEvent.IO_ERROR, _onUrlStreamLoadingIOError );
                _m_pFile.addEventListener( SecurityErrorEvent.SECURITY_ERROR, _onUrlStreamLoadingSecurityError );
                _m_pFile.load();
            }
            else
            {
                trace( "AIR No caching! Starting load : " + _m_sEncodedLoadingUrl );
                _usingUrlStreamToLoad();
            }
        }
        catch ( er : Error )
        {
            _dispatchEvent( new ErrorEvent( ErrorEvent.ERROR ) );
        }
    }

    private function _usingUrlStreamToLoad() : void
    {
        try
        {
            try
            {
                if ( _m_pDelegater )
                {
                    _m_pDelegater["close"]();
                }
            }
            catch ( innerEr : Error )
            {
                //noop
            }

            if ( _m_pDelegater == null )
            {
                _m_pDelegater = new URLStream();

                _m_pDataInput = _m_pDelegater as IDataInput;

                _m_pDelegater.addEventListener( Event.OPEN, _onOpen );
                _m_pDelegater.addEventListener( Event.COMPLETE, _onUrlStreamLoadingFinished );
                _m_pDelegater.addEventListener( ProgressEvent.PROGRESS, _onProgress );
                _m_pDelegater.addEventListener( IOErrorEvent.IO_ERROR, _onUrlStreamLoadingIOError );
                _m_pDelegater.addEventListener( HTTPStatusEvent.HTTP_STATUS, _onHttpStatus );
                _m_pDelegater.addEventListener( SecurityErrorEvent.SECURITY_ERROR, _onUrlStreamLoadingSecurityError );
            }

            var urlReq : URLRequest = new URLRequest( _m_sLoadingUrl );

            _m_pDelegater["load"]( urlReq );
        }
        catch ( er : Error )
        {
            _dispatchEvent( new ErrorEvent( ErrorEvent.ERROR ) );
        }
    }

    public function cancel() : void
    {
        if ( _m_bLoading )
        {
            _m_bLoading = false;

            if ( _m_pFile )
            {
                _m_pFile.removeEventListener( Event.COMPLETE,  _onFileLoadingFinish );
                _m_pFile.cancel();
            }
            if ( _m_pDelegater )
            {
                _m_pDelegater.removeEventListener( Event.OPEN, _onOpen );
                _m_pDelegater.removeEventListener( Event.COMPLETE, _onUrlStreamLoadingFinished );
                _m_pDelegater.removeEventListener( ProgressEvent.PROGRESS, _onProgress );
                _m_pDelegater.removeEventListener( IOErrorEvent.IO_ERROR, _onUrlStreamLoadingIOError );
                _m_pDelegater.removeEventListener( HTTPStatusEvent.HTTP_STATUS, _onHttpStatus );
                _m_pDelegater.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, _onUrlStreamLoadingSecurityError );
            }
        }
    }

    private function _onOpen( e : Event ) : void
    {
        e.target.removeEventListener( Event.OPEN,  _onFileLoadingFinish );
        _m_bConnected = true;
    }

    private function _onFileLoadingFinish( e : Event ) : void
    {
        var file : File = e.target as File;
        file.removeEventListener( Event.COMPLETE, _onFileLoadingFinish );

        var targetFile : File = File.applicationStorageDirectory; //a;
        targetFile = targetFile.resolvePath( _m_sEncodedLoadingUrl );
        if ( targetFile.isDirectory && targetFile.exists == false )
        {
            targetFile.createDirectory();
        }

        _m_pBytes = e.target.data;
        _m_pBytes.position = 0;
        _m_pDataInput = _m_pBytes;

        _dispatchEvent( new Event( Event.COMPLETE ) );
    }

    private function _writeFile( bytes : ByteArray, file : File, callback : Function = null ) : void
    {
        var fileSys : FileStream = new FileStream();
        fileSys.open( file, FileMode.UPDATE );
        fileSys.writeBytes( bytes );
        fileSys.close();
        if ( callback != null )
        {
            callback();
        }
    }

    private function _onHttpStatus( e : HTTPStatusEvent ) : void
    {
        _dispatchEvent( e );
    }

    private function _onProgress( e : ProgressEvent ) : void
    {
        _dispatchEvent( e );
    }

    private function _onUrlStreamLoadingFinished( e : Event ) : void
    {
        _m_pDelegater.removeEventListener( Event.COMPLETE, _onUrlStreamLoadingFinished );

        _m_pBytes = new ByteArray();
        _m_pDelegater["readBytes"](_m_pBytes);
        _m_pBytes.position = 0;

        _m_pDataInput = _m_pDelegater as IDataInput;

        var cachedFile : File = File.applicationStorageDirectory;
        cachedFile = cachedFile.resolvePath( _m_sEncodedLoadingUrl );
        if ( cachedFile.exists == false )
        {
            var checkedDir : File = cachedFile.isDirectory ? cachedFile : cachedFile.parent;
            if ( checkedDir.exists == false )
            {
                checkedDir.createDirectory();
            }
            _writeFile( _m_pBytes, cachedFile, function() : void
            {
                _dispatchEvent( e );
            } );
        }
        else
        {
            _dispatchEvent( e );
        }
    }

    private function _dispatchEvent( e : Event ) : void
    {
        dispatchEvent( e );
    }

    private function _onUrlStreamLoadingIOError( e : IOErrorEvent ) : void
    {
        _dispatchEvent( e );
    }

    private function _onUrlStreamLoadingSecurityError( e : SecurityErrorEvent ) : void
    {
        _dispatchEvent( e );
    }

    public function get position() : uint {
        return _m_pBytes ? _m_pBytes.position : 0;
    }

    public function set position( value : uint ) : void {
        if ( _m_pBytes ) _m_pBytes.position = value;
    }

    public function get target() : Object {
        return null;
    }

    public function readBytes( bytes : ByteArray, offset : uint = 0, length : uint = 0 ) : void {
        if ( _m_pBytes )
        {
            _m_pBytes.readBytes(bytes, offset, length);
        }
    }

    public function readBoolean() : Boolean {
        return _m_pBytes ? _m_pBytes.readBoolean() : false;
    }

    public function readByte() : int {
        return _m_pBytes ? _m_pBytes.readByte() : 0;
    }

    public function readUnsignedByte() : uint {
        return _m_pBytes ? _m_pBytes.readUnsignedByte() : 0;
    }

    public function readShort() : int {
        return _m_pBytes ? _m_pBytes.readShort() : 0;
    }

    public function readUnsignedShort() : uint {
        return _m_pBytes ? _m_pBytes.readUnsignedShort() : 0;
    }

    public function readInt() : int {
        return _m_pBytes ? _m_pBytes.readInt() : 0;
    }

    public function readUnsignedInt() : uint {
        return _m_pBytes ? _m_pBytes.readUnsignedInt() : 0;
    }

    public function readFloat() : Number {
        return _m_pBytes ? _m_pBytes.readFloat() : 0;
    }

    public function readDouble() : Number {
        return _m_pBytes ? _m_pBytes.readDouble() : 0;
    }

    public function readMultiByte( length : uint, charSet : String ) : String {
        return _m_pBytes ? _m_pBytes.readMultiByte( length, charSet ) : "";
    }

    public function readUTF() : String {
        return _m_pBytes ? _m_pBytes.readUTF() : "";
    }

    public function readUTFBytes( length : uint ) : String {
        return _m_pBytes ? _m_pBytes.readUTFBytes( length ) : "";
    }

    public function get bytesAvailable() : uint {
        return _m_pBytes ? _m_pBytes.bytesAvailable : 0;
    }

    public function readObject() : * {
        return _m_pBytes ? _m_pBytes.readObject() : null;
    }

    public function get objectEncoding() : uint {
        return _m_pBytes ? _m_pBytes.objectEncoding : 0;
    }

    public function set objectEncoding( version : uint ) : void {
        if ( _m_pBytes )
        {
            _m_pBytes.objectEncoding = version;
        }
    }

    public function get endian() : String {
        return _m_pBytes ? _m_pBytes.endian : "";
    }

    public function set endian( type : String ) : void {
        if ( _m_pBytes )
        {
            _m_pBytes.endian = type;
        }
    }

    private var _m_pFile : File;
    private var _m_pBytes : ByteArray;

    private var _m_pDelegaterClass : Class;
    private var _m_pDelegater : IEventDispatcher;
    private var _m_pDataInput : IDataInput;

    private var _m_bDisposed : Boolean;
    private var _m_bLoading : Boolean;

    private var _m_sEncodedLoadingUrl : String;
    private var _m_sLoadingUrl : String;

    private var _m_bConnected : Boolean;
}
}
