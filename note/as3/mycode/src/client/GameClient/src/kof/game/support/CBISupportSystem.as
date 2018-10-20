//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.support {

import kof.framework.CAppSystem;

public class CBISupportSystem extends CAppSystem {

    public function CBISupportSystem() {
        super();
    }

    override public function dispose() : void {
        super.dispose();
    }

    override protected virtual function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        if ( ret ) {
            this.addBean( new CCrashLogHandler() );
            this.addBean( new CDisconnectLogHandler() );
            this.addBean( new CStaticReloadHandler() );
        }
        return ret;
    }

}
}
