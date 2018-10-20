//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.framework.vfs {

import QFLib.Foundation;
import QFLib.Foundation.CURLFile;
import QFLib.Memory.CSmartObject;

import com.adobe.flascc.vfs.FileHandle;
import com.adobe.flascc.vfs.IVFS;

import flash.utils.ByteArray;
import flash.utils.Dictionary;

import mx.utils.StringUtil;

/**
 * The default ActionScript 3 implementation of IFile interface.
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CActionScript3File extends CSmartObject implements IFile {

    /**
     * Creates a CActionScript3File instance describes the given path over the given VFS implementation.
     *
     * @param vfs The VFS implementation.
     * @param path The path
     * @return a CActionScript3File instance or null if non-exists.
     */
    public static function createWithVFS( vfs : IVFS, path : String ) : CActionScript3File {
        var ret : CActionScript3File;

        if ( !vfs )
            throw new Error( "Null VFS implementation." );

        if ( !path || StringUtil.trim( path ) == "" )
            return null;

        ret = new CActionScript3File();

        if ( ret.initWithVFSPath( vfs, path ) ) {
            return ret;
        }

        return null;
    }

    public function CActionScript3File() {
        super();
    }

    private var _vfs : IVFS;
    private var _path : String;
    private var _callbacks : Dictionary;

    public function get path() : String {
        return _path;
    }

    private var _handle : FileHandle;

    public function get handle() : FileHandle {
        return _handle;
    }

    public function open( pfnReady : Function = null, pfnProgress : Function = null ) : void {
        if ( _handle && !_handle.isDirectory ) {
            if ( _handle.bytes && _handle.bytes.bytesAvailable ) {
                if ( null != pfnReady )
                    pfnReady( _handle.bytes, this );
            }
        } else {
            var curlFile : CURLFile = new CURLFile( _path );
            curlFile.startLoad( _onCURLFileFinished );

            if ( null != pfnReady ) {
                if ( !_callbacks )
                    _callbacks = new Dictionary( true );
                _callbacks [ curlFile ] = [ pfnReady, pfnProgress ];
            }
        }
    }

    private function _onCURLFileFinished( cf : CURLFile, idErr : int ) : void {
        // Removes callee from the _callbacks first.
        var cbs : Array = null;
        if ( _callbacks ) {
            cbs = _callbacks[ cf ];
            delete _callbacks[ cf ];
        }

        if ( idErr == 0 ) {
            if ( cf ) {
                var bytes : ByteArray = cf.readAllBytes();
                _vfs.addFile( cf.loadingURL, bytes );
                if ( cbs )
                    ( cbs[ 0 ] as Function )( bytes, this );
            }
        } else {
            // error caught.
            Foundation.Log.logErrorMsg( "Open CURLFile [" + cf.loadingURL + "] failed." );
            if ( cbs )
                ( cbs[ 0 ] as Function )( null, this );
        }

        if ( cbs )
            cbs.splice( 0, cbs.length );

        cf && cf.dispose();
    }

    protected function initWithVFSPath( vfs : IVFS, path : String ) : Boolean {
        this._vfs = vfs;
        this._path = path;

        if ( vfs ) {
            this._handle = vfs.getFileHandleFromPath( path );
            return true;
        }

        return false;
    }

    public function close( dispose : Boolean = false ) : void {
        super.dispose();

        this._vfs = null;
        this._handle = null;
        this._callbacks = null;
    }

}
}
