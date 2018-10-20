//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun CNetwork Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.login {

import flash.events.ProgressEvent;

import kof.framework.CAppStage;
import kof.framework.IApplication;
import kof.io.CVFSSystem;
import kof.ui.CUISystem;
import kof.game.audio.CAudioSystem;

/**
 * @author Jeremy (jeremy@qifun.com)
 */
public class CLoginStage extends CAppStage {

    /**
     * Constructor
     */
    public function CLoginStage() {
        super( "CLoginStage" );
    }

    override protected function doStart() : Boolean {
        var ret : Boolean = super.doStart();

//        this.addSystem( new CAudioSystem() );
//        this.addSystem( new CVFSSystem() );
//        this.addSystem( new CUISystem() );
        this.addSystem( new CLoginSystem() );

        return ret;
    }

    override protected function doStop() : Boolean {
        return super.doStop();
    }

    override protected function setStarting() : void {
        super.setStarting();

        var pApp : IApplication = this.getBean( IApplication ) as IApplication;
        if ( pApp )
            pApp.eventDispatcher.dispatchEvent( new ProgressEvent( "_applicationProgress", false, false, 1, 2 ) );
    }

}
}
