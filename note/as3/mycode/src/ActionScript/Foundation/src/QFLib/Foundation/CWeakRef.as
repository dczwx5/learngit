//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package QFLib.Foundation {

import flash.utils.Dictionary;

/**
 * AS3 Weak reference wrapper.
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public final class CWeakRef extends Dictionary {

    public function CWeakRef( ptr : * = undefined ) {
        super( true );
        if ( ptr )
            this.ptr = ptr;
    }

    /**
     * Retrieves the actual ptr.
     */
    public function get ptr() : * {
        //noinspection JSUnusedAssignment
        var k : * = null;
        //noinspection LoopStatementThatDoesntLoopJS
        for ( k in this ) {
            break;
        }
        return k;
    }

    public function set ptr( value : * ) : void {
        this._clear();
        if ( null != value || undefined != value )
            this[ value ] = true;
    }

    final private function _clear() : void {
        var k : *;
        for ( k in this ) {
            //noinspection JSUnfilteredForInLoop
            delete this[ k ];
        }
    }

}
}
