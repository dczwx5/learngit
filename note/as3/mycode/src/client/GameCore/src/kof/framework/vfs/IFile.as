//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.framework.vfs {

import com.adobe.flascc.vfs.FileHandle;

/**
 * File interface describes an abstract file handle in ActionScript 3.
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public interface IFile {

    function get handle() : FileHandle;

    function open( pfnReady : Function = null, pfnProgress : Function = null ) : void;

    function close( dispose : Boolean = false ) : void;

    function get path() : String;

}
}
