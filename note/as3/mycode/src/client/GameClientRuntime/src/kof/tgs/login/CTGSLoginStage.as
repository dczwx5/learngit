//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.tgs.login {

import kof.framework.CAppStage;
import kof.game.audio.CAudioSystem;
import kof.io.CVFSSystem;
import kof.ui.CUISystem;

/**
 * TGS登陆Stage
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CTGSLoginStage extends CAppStage {

    public function CTGSLoginStage() {
        super();
    }

    override protected function doStart() : Boolean {
        var ret : Boolean = super.doStart();

        if ( ret ) {
            this.addSystem( new CVFSSystem() );
            this.addSystem( new CUISystem() );

            this.addSystem( new CAudioSystem() );
            this.addSystem( new CTGSLoginSystem() );

        }

        return ret;
    }

}
}
