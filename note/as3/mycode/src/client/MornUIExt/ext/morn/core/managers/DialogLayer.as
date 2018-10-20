//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package morn.core.managers {

import flash.events.Event;
import flash.events.MouseEvent;

import morn.core.components.Box;
import morn.core.components.Dialog;

/**
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class DialogLayer extends DialogManager {

    private var m_pBox : Box;

    /**
     * Creates a new DialogLayer.
     */
    public function DialogLayer() {
        super();

        this.m_pBox = this.getChildAt( 0 ) as Box;
    }

    override public function show( dialog : Dialog, closeOther : Boolean = false ) : void {
        if ( !dialog )
            return;

        if ( m_pBox == dialog.parent ) {
            // already in the displayList.
            m_pBox.setChildIndex( dialog, m_pBox.numChildren - 1 );
        } else {
            super.show( dialog );
            dialog.addEventListener( MouseEvent.MOUSE_DOWN, _onDialogMouseClickToActivated, false, 0, true );
//            dialog.addEventListener( Event.ACTIVATE, _onDialogActivated, false, 0, true );
//            dialog.addEventListener( Event.DEACTIVATE, _onDialogDeactivated, false, 0, true );
        }
    }

    private function _onDialogMouseClickToActivated( event : MouseEvent ) : void {
//        event.currentTarget.dispatchEvent( new Event( Event.ACTIVATE, false ) );
        this.show( event.currentTarget as Dialog );
    }

    override public function close( dialog : Dialog ) : void {
        if ( dialog ) {
            dialog.removeEventListener( MouseEvent.MOUSE_DOWN, _onDialogMouseClickToActivated );
//            dialog.removeEventListener( Event.ACTIVATE, _onDialogActivated );
//            dialog.removeEventListener( Event.DEACTIVATE, _onDialogDeactivated );
        }
        super.close( dialog );
    }

    private function _onDialogDeactivated( event : Event ) : void {
        //
    }

    private function _onDialogActivated( event : Event ) : void {
        this.show( event.currentTarget as Dialog );
    }

}
}
