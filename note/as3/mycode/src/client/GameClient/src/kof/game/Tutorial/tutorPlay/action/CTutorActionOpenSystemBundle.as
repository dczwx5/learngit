//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.Tutorial.tutorPlay.action {

import kof.SYSTEM_ID;
import kof.framework.CAppSystem;
import kof.game.Tutorial.data.CTutorActionInfo;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.switching.CSwitchingSystem;

public class CTutorActionOpenSystemBundle extends CTutorActionBase {

    public function CTutorActionOpenSystemBundle(actionInfo : CTutorActionInfo, system : CAppSystem ) {
        super( actionInfo, system );
    }

    override public function dispose() : void {
        super.dispose();

    }

    override public function start() : void {
        super.start();

        var sTagID : String = _info.actionParams[0] as String;
        var value:String = _info.actionParams[1] as String;
        var bTargetValue:Boolean;
        if (value.toLowerCase() == "true") {
            bTargetValue = true;
        } else {
            bTargetValue = false;
        }

        if (sTagID && sTagID.length > 0) {
            var pSystemBundleCtx : ISystemBundleContext = _system.stage.getSystem( ISystemBundleContext ) as
                    ISystemBundleContext;
            if ( pSystemBundleCtx ) {
                var pSystemBundle : ISystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID(sTagID) );
                if (pSystemBundle) {
                    if ((_system.stage.getSystem(CSwitchingSystem) as CSwitchingSystem).isSystemOpen(sTagID)) {
                        pSystemBundleCtx.setUserData( pSystemBundle, CBundleSystem.ACTIVATED, bTargetValue );
                    }
                }
            }
        }

        _actionValue = true;
    }
}
}

