//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/12/13.
 */
package kof.game.player.control {

import kof.game.common.view.control.CControlBase;
import kof.game.player.CEquipmentNetHandler;
import kof.game.player.CHeroNetHandler;
import kof.game.player.CPlayerHandler;
import kof.game.player.CPlayerSystem;
import kof.game.player.CPlayerUIHandler;
import kof.game.player.data.CPlayerData;

public class CPlayerControler extends CControlBase {

    public function get uiHandler() : CPlayerUIHandler {
        return _wnd.viewManagerHandler as CPlayerUIHandler;
    }
    public function get system() : CPlayerSystem {
        return _system as CPlayerSystem;
    }
    public function get netHandler() : CPlayerHandler {
        return system.netHandler;
    }
    public function get heroNetHandler() : CHeroNetHandler {
        return system.heroNetHandler;
    }
    public function get equipNetHandler() : CEquipmentNetHandler {
        return system.equipNetHandler;
    }
    public function get playerData() : CPlayerData {
        return system.playerData;
    }
}
}
