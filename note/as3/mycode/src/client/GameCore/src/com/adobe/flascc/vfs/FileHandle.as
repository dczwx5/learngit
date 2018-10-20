// Copyright (c) 2013 Adobe Systems Inc

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

package com.adobe.flascc.vfs {

import flash.utils.ByteArray;

/**
 * This class represents open files available to an flascc application. It should be used by implementations of the
 * IKernel interface but not by end-user code.
 */
public class FileHandle {

    /**
     * @private
     */
    public function FileHandle(__backingStore:IBackingStore = null,
                               __backingStoreRelativePath:String = null,
                               __bytes:ByteArray = null,
                               __callback:ISpecialFile = null,
                               __readable:Boolean = true,
                               __writeable:Boolean = false,
                               __appending:Boolean = false,
                               __isDirectory:Boolean = false,
                               __path:String = null,
                               __position:uint = 0) {
        _backingStore = __backingStore;
        _backingStoreRelativePath = __backingStoreRelativePath;
        _bytes = __bytes;
        _callback = __callback;
        readable = __readable;
        writeable = __writeable;
        appending = __appending;
        _isDirectory = __isDirectory;
        _path = __path;
        position = __position;
    }

    /**
     * @private
     */
    public static function makeSpecialFile(specialFile:ISpecialFile):FileHandle {
        var fh:FileHandle = new FileHandle();
        fh.writeable = true;
        fh.readable = true;
        fh._callback = specialFile;
        return fh;
    }

    /**
     * @private
     */
    public static function makeRegularFile(__path:String, __backingStoreRelativePath:String, __backingStore:IBackingStore, __bytes:ByteArray, __isDirectory:Boolean):FileHandle {
        var fh:FileHandle = new FileHandle();
        fh._path = __path;
        fh._backingStore = __backingStore;
        fh._backingStoreRelativePath = __backingStoreRelativePath;
        fh._bytes = __bytes;
        fh._isDirectory = __isDirectory;
        fh.writeable = !__backingStore.readOnly;
        fh.readable = true;
        fh.position = 0;
        return fh;
    }

    /**
     * The BackingStore that owns this FDEntry.
     */
    public function get backingStore():IBackingStore {
        return _backingStore;
    }

    private var _backingStore:IBackingStore = null;

    /**
     * The relative path to the underlying file in the VFS.
     */
    public function get backingStoreRelativePath():String {
        return _backingStoreRelativePath;
    }

    private var _backingStoreRelativePath:String = null;


    /**
     * If this file descriptor refers to a normal file this will contain the contents of the file.
     */
    public function get bytes():ByteArray {
        return _bytes;
    }

    private var _bytes:ByteArray = null;

    /**
     * If this file descriptor refers to a special file this references an object implementing the ISpecialFile interface that will be used to handle read/write requests.
     */
    public function get callback():ISpecialFile {
        return _callback;
    }

    private var _callback:ISpecialFile = null;

    /**
     * True if this file descriptor was opened with O_RDWR or if it was not opened as O_WRONLY.
     */
    public var readable:Boolean;

    /**
     * True if this file descriptor was opened with O_WRONLY or O_RDWR.
     */
    public var writeable:Boolean;

    /**
     * True if this file descriptor was opened with O_APPEND.
     */
    public var appending:Boolean;

    /**
     * True if this file descriptor referes to a directory.
     */
    public function get isDirectory():Boolean {
        return _isDirectory
    }

    private var _isDirectory:Boolean = false;

    /**
     * The full path to the file referenced by this file descriptor
     */
    public function get path():String {
        return _path
    }

    private var _path:String = null;

    /**
     * The position within the file that read/write operations will occur at.
     */
    public var position:uint;
}
}
