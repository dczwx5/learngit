//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.Tutorial.tutorPlay.action {

import kof.framework.CAppSystem;
import kof.framework.events.CEventPriority;
import kof.game.Tutorial.data.CTutorActionInfo;
import kof.game.instance.IInstanceFacade;
import kof.game.instance.event.CInstanceEvent;

/**
 *
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CTutorActionRoleTeamUpgrade extends CTutorActionGuideClick {

    public function CTutorActionRoleTeamUpgrade( actionInfo : CTutorActionInfo, system : CAppSystem ) {
        super( actionInfo, system );
    }

    override public function dispose() : void {
        var pSystem : CAppSystem = _system;
        super.dispose();

        if ( pSystem ) {
            var pInstanceSys : IInstanceFacade = pSystem.stage.getSystem( IInstanceFacade ) as IInstanceFacade;
            if ( pInstanceSys && pInstanceSys.eventDelegate ) {
                pInstanceSys.eventDelegate.removeEventListener( CInstanceEvent.WIN, _instanceSys_onWinEventHandler );
            }
        }
    }

    override public virtual function start() : void {
        super.start();

        // 副本通关，就算完成
        var pInstanceSys : IInstanceFacade = _system.stage.getSystem( IInstanceFacade ) as IInstanceFacade;
        if ( pInstanceSys && pInstanceSys.eventDelegate ) {
            pInstanceSys.eventDelegate.addEventListener( CInstanceEvent.WIN, _instanceSys_onWinEventHandler, false,
                    CEventPriority.DEFAULT, true );
        }
    }

    private function _instanceSys_onWinEventHandler( event : CInstanceEvent ) : void {
        event.currentTarget.removeEventListener( CInstanceEvent.WIN, _instanceSys_onWinEventHandler );

        saveToServerIfAbsent();
    }

}
}

// vim:ft=as3 tw=120 ts=4 sw=4 expandtab
