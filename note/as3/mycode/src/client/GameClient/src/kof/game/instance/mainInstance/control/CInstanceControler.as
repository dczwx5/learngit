//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/12/13.
 */
package kof.game.instance.mainInstance.control {

import kof.game.common.view.control.CControlBase;
import kof.game.embattle.CEmbattleSystem;
import kof.game.instance.CInstanceHandler;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.CInstanceUIHandler;
import kof.game.instance.mainInstance.CMainInstanceHandler;
import kof.game.player.CPlayerSystem;

public class CInstanceControler extends CControlBase {
    public function get uiHandler() : CInstanceUIHandler {
        return _wnd.viewManagerHandler as CInstanceUIHandler;
    }
    [Inline]
    public function get system() : CInstanceSystem {
        return _system as CInstanceSystem;
    }
    public function get embattleSystem() : CEmbattleSystem {
        return _system.stage.getSystem(CEmbattleSystem) as CEmbattleSystem;
    }
    public function get playerSystem() : CPlayerSystem {
        return system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
    }
    [Inline]
    public function get netHandler() : CInstanceHandler {
        return system.netHandler;
    }
    [Inline]
    public function get mainNetHandler() : CMainInstanceHandler {
        return system.mainNetHandler;
    }
}
}
