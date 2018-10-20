//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/12/13.
 */
package kof.game.playerTeam.control {

import kof.game.common.view.control.CControlBase;
import kof.game.player.data.CPlayerData;
import kof.game.playerTeam.CPlayerTeamHandler;
import kof.game.playerTeam.CPlayerTeamSystem;
import kof.game.playerTeam.CPlayerTeamUIHandler;

public class CPlayerTeamControlerBase extends CControlBase {

    public function get uiHandler() : CPlayerTeamUIHandler {
        return _wnd.viewManagerHandler as CPlayerTeamUIHandler;
    }
    public function get system() : CPlayerTeamSystem {
        return _system as CPlayerTeamSystem;
    }
    public function get netHandler() : CPlayerTeamHandler {
        return system.netHandler;
    }
    public function get playerData() : CPlayerData {
        return system.playerData;
    }


}
}
