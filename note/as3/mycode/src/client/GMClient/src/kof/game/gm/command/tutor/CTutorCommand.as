//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.gm.command.tutor {

import kof.framework.INetworking;
import kof.game.Tutorial.CTutorSystem;
import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;
import kof.util.CAssertUtils;

public class CTutorCommand extends CAbstractConsoleCommand {
    private var _pTutorSystem : CTutorSystem;
    public function CTutorCommand(pTutorSystem : CTutorSystem ) {
        super();

        this._pTutorSystem = pTutorSystem;

        this.name = "startBattleTutor";
        this.description = "执行战斗引导，Usage：" + this.name + " tutor id";
        this.label = "执行战斗引导";
    }

    override public function onCommand( args : Array ) : Boolean {
        // request server for entering instance.
        if (!_pTutorSystem) return false;

        if ( super.onCommand( args ) ) {
            var pNetworking : INetworking = this.networking;
            CAssertUtils.assertNotNull( pNetworking );
            if (args.length > 1) {
                var id:int = args[1];
                _pTutorSystem.startBattleTutor(id);
            } else {
                _pTutorSystem.startBattleTutor();
            }

            return true;
        }
        return false;
    }
}
}
