//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package QFLib.Foundation {

/**
 * Disposes the <code>obj</code> freed by VM.
 */
public function free( obj : Object ) : void {
    if ( !obj )
        return;

    var disposeFunc : Function = 'dispose' in obj ? obj[ 'dispose' ] as Function : null;
    if ( null != disposeFunc )
        obj.dispose();
}
}