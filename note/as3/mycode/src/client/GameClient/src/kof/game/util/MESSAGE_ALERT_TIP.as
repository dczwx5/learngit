//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.util {

import kof.framework.CAppSystem;
import kof.game.reciprocation.CReciprocalSystem;
import kof.ui.CMsgAlertHandler;

public function MESSAGE_ALERT_TIP( pAppSystem : CAppSystem, strMsg : String, type : int = CMsgAlertHandler.NORMAL, bPlaySound : Boolean = true ) : void {
    if ( !pAppSystem )
        return;

    var pReciprocal : CReciprocalSystem = pAppSystem.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem;
    if ( pReciprocal ) {
        pReciprocal.showMsgAlert( strMsg, type, bPlaySound );
    }
}

}
