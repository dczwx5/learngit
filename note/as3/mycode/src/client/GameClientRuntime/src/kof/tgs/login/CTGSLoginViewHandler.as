//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.tgs.login {

import flash.events.MouseEvent;

import kof.framework.CAppSystem;
import kof.framework.CViewHandler;
import kof.game.audio.CAudioConstants;
import kof.game.audio.IAudio;
import kof.ui.tgs.welcome.WelcomeViewUI;
import kof.util.CAssertUtils;

import morn.core.handlers.Handler;

import mx.events.Request;

/**
 * @author Jeremy (jeremy@qifun.com)
 */
public class CTGSLoginViewHandler extends CViewHandler {

    /** @private */
    private var m_pWelcomeView : WelcomeViewUI;
    private var m_strErrorMessage : String;

    public function CTGSLoginViewHandler() {
        super();
    }

    override public function dispose() : void {
        super.dispose();

        this.removeWelcomeView();

        m_pWelcomeView = null;

        App.loader.clearResLoaded( "tgs_login.swf" );
    }

    override protected virtual function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        ret = ret && this._loadAssets();

        return ret;
    }

    override protected virtual function onShutdown() : Boolean {
        var ret : Boolean = super.onShutdown();
        if ( ret ) {
            this.removeWelcomeView();
        }
        return ret;
    }

    private function _loadAssets() : Boolean {
        if ( !App.loader.getResLoaded( "tgs_login.swf" )
                || !App.loader.getResLoaded( "frame_logoloop.swf" )
                || !App.loader.getResLoaded( "frameclip_startbutton.swf" )
        ) {
            App.loader.loadAssets( [
                "tgs_login.swf",
                "frame_logoloop.swf",
                "frameclip_startbutton.swf"
            ], new Handler( _loadUIAssetsCompleted ), null, null, false );
            return false;
        }

        return true;
    }

    private function _loadUIAssetsCompleted( ) : void {
        this.makeStarted();
        this.initialize();

        var audio:IAudio = system.stage.getSystem( IAudio ) as IAudio;
        audio.playMusic(CAudioConstants.GAME_START);
    }

    protected function initialize() : void {
        if ( !m_pWelcomeView ) {
            m_pWelcomeView = new WelcomeViewUI();
            m_pWelcomeView.txtErrorMsg.text = null;

            m_pWelcomeView.btnStart.addEventListener( MouseEvent.CLICK, _onStartClick, false, 0 );
        }
    }

    private function _onStartClick( event : MouseEvent ) : void {
        dispatchEvent( new Request( "StartGame", false, false ) );
    }

    override protected virtual function enterSystem( system : CAppSystem ) : void {
        super.enterSystem( system );

        // show me.
        CAssertUtils.assertNotNull( m_pWelcomeView );

        this.showWelcomeView();
    }

    override protected function updateData() : void {
        super.updateData();

//        if ( !m_pWelcomeView ) {
//            this.invalidateData();
//            return;
//        }
    }

    override protected function updateDisplay() : void {
        super.updateDisplay();
        if ( !m_pWelcomeView ) {
            this.invalidateDisplay();
            return;
        }

        m_pWelcomeView.txtErrorMsg.text = this.errorMessage;
    }

    public function get errorMessage() : String {
        return m_strErrorMessage;
    }

    public function set errorMessage( value : String ) : void {
        this.m_strErrorMessage = value;
        this.invalidateDisplay();
    }

    public function showWelcomeView() : void {
        if ( m_pWelcomeView )
            ui.rootContainer.addChild( m_pWelcomeView );
    }

    public function removeWelcomeView( dispose : Boolean = false ) : void {
        if ( m_pWelcomeView ) {
            if ( m_pWelcomeView.parent ) {
                m_pWelcomeView.parent.removeChild( m_pWelcomeView );
            }
        }
    }

}
}
