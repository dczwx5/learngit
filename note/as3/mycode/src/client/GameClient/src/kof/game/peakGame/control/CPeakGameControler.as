//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/03/06.
 */
package kof.game.peakGame.control {

import kof.game.common.view.control.CControlBase;
import kof.game.peakGame.CPeakGameHandler;
import kof.game.peakGame.CPeakGameSystem;
import kof.game.peakGame.CPeakGameUIHandler;
import kof.game.peakGame.data.CPeakGameData;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;

public class CPeakGameControler extends CControlBase {
    [Inline]
    public function get uiHandler() : CPeakGameUIHandler {
        return _wnd.viewManagerHandler as CPeakGameUIHandler;
    }
    [Inline]
    public function get system() : CPeakGameSystem {
        return _system as CPeakGameSystem;
    }
    [Inline]
    public function get netHandler() : CPeakGameHandler {
        return (_system as CPeakGameSystem).netHandler;
    }
    [Inline]
    public function get peakGameData() : CPeakGameData {
        return (_system as CPeakGameSystem).peakGameData;
    }
    [Inline]
    public function get playerData() : CPlayerData {
        return (_system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
    }

}
}
