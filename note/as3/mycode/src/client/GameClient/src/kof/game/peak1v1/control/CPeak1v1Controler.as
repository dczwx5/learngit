//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/03/06.
 */
package kof.game.peak1v1.control {

import kof.game.common.view.control.CControlBase;
import kof.game.peak1v1.CPeak1v1NetHandler;
import kof.game.peak1v1.CPeak1v1System;
import kof.game.peak1v1.CPeak1v1UIHandler;
import kof.game.peak1v1.data.CPeak1v1Data;
import kof.game.peakGame.CPeakGameHandler;
import kof.game.peakGame.CPeakGameSystem;
import kof.game.peakGame.CPeakGameUIHandler;
import kof.game.peakGame.data.CPeakGameData;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;

public class CPeak1v1Controler extends CControlBase {
    [Inline]
    public function get uiHandler() : CPeak1v1UIHandler {
        return _wnd.viewManagerHandler as CPeak1v1UIHandler;
    }
    [Inline]
    public function get system() : CPeak1v1System {
        return _system as CPeak1v1System;
    }
    [Inline]
    public function get netHandler() : CPeak1v1NetHandler {
        return system.netHandler;
    }
    [Inline]
    public function get data() : CPeak1v1Data {
        return system.data;
    }
    public function get playerData() : CPlayerData {
        return (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
    }
}
}
