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

public class CTutorActionIsOpenSystemBundle extends CTutorActionBase {

    public function CTutorActionIsOpenSystemBundle(actionInfo : CTutorActionInfo, system : CAppSystem ) {
        super( actionInfo, system );
    }

    override public function dispose() : void {
        super.dispose();

    }

    override public virtual function update( delta : Number ) : void {
        super.update( delta );

        if ( !_actionValue ) {
            var sTagID : String = _info.actionParams[0] as String;
            var value:String = _info.actionParams[1] as String;
            var bCheckValue:Boolean;
            if (value.toLowerCase() == "true") {
                bCheckValue = true;
            } else {
                bCheckValue = false;
            }

            var pSystemBundleCtx : ISystemBundleContext = _system.stage.getSystem( ISystemBundleContext ) as
                    ISystemBundleContext;
            if ( pSystemBundleCtx ) {
                var pSystemBundle : ISystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID(sTagID) );
                var bBundleActived:Boolean = pSystemBundleCtx.getUserData( pSystemBundle, CBundleSystem.ACTIVATED );
                if (bBundleActived == bCheckValue) {
                    _actionValue = true;
                }
            }
        }
    }
}
}

