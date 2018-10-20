//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package {

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;

import kof.framework.CStandaloneApp;

import kof.framework.INetworking;
import kof.tgs.login.CTGSLoginStage;
import kof.util.CAssertUtils;

/**
 * TGS版本主程序
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class TGSClient extends CMain {

    /**
     * Creates a new CTGSRuntime.
     */
    public function TGSClient() {
        super();
    }

    override protected function get stageClass() : Class {
        return CTGSLoginStage;
    }

    override protected function addedToStage( event : Event = null ) : void {
        super.addedToStage( event );

        stage.addEventListener( "GameResultFinished", _onApplicationRestartEventHandler, true, 0, true );

        CONFIG::debug {
            stage.addEventListener( KeyboardEvent.KEY_UP, _onKeyUpHandler, false, 0, true );
        }
    }

    CONFIG::debug {
        private function _onKeyUpHandler( event : KeyboardEvent ) : void {
            if ( event.keyCode == Keyboard.BACKSPACE ) {
                _closeNetworkingAndPromptToRestart();
            }
        }

        private function _closeNetworkingAndPromptToRestart() : void {
            var pNetworking : INetworking = this.application.runningStage.getSystem( INetworking ) as INetworking;
            CAssertUtils.assertNotNull( pNetworking );
            pNetworking.close();

            this.application.eventDispatcher.addEventListener( CStandaloneApp.RESTART, _onApplicationRestartEventHandler, false, 0, true );
        }
    }

    private function _onApplicationRestartEventHandler( event : Event ) : void {
        stage.removeEventListener( "GameResultFinished", _onApplicationRestartEventHandler);
        this.application.eventDispatcher.removeEventListener( event.type, _onApplicationRestartEventHandler );

        this.restart();
    }

}
}
