//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.tgs.login {

import flash.events.Event;

import kof.framework.CAppSystem;
import kof.framework.events.CEventPriority;

/**
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CTGSLoginSystem extends CAppSystem {

    public function CTGSLoginSystem() {
        super();
    }

    override protected virtual function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        if ( ret ) {
            this.addBean( new CTGSLoginHandler() );
            this.addBean( new CTGSLoginViewHandler() );
        }

        return ret;
    }

    override protected virtual function onShutdown() : Boolean {
        var ret : Boolean = super.onShutdown();

        if ( ret ) {
            App.loader.clearResLoaded( "tgs_login.swf" );
        }

        return ret;
    }

    override protected function setStarted() : void {
        super.setStarted();

        var viewHandler : CTGSLoginViewHandler = this.getBean( CTGSLoginViewHandler );
        if ( viewHandler ) {
            viewHandler.addEventListener( "StartGame", _onStartGameUIRequest, false, CEventPriority.DEFAULT, true );
        }
    }

    private function _onStartGameUIRequest( event : Event ) : void {
        this.startGame();
    }

    public function startGame() : void {
        (handler as CTGSLoginHandler).loginWithRandomAccount();
    }

}
}
