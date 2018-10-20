//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.util {

import kof.framework.CAppSystem;
import kof.game.reciprocation.CReciprocalSystem;

public function MESSAGE_ALERT_BOX( pAppSystem : CAppSystem, strMsg : String, okFun : Function = null, closeFun : Function = null, cancelIsVisible : Boolean = true, okLable : String = null, cancelLable : String = null ) : void {
    if ( !pAppSystem )
        return;

    var pReciprocal : CReciprocalSystem = pAppSystem.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem;
    if ( pReciprocal ) {
        pReciprocal.showMsgBox( strMsg, okFun, closeFun, cancelIsVisible, okLable, cancelLable );
    }
}

}