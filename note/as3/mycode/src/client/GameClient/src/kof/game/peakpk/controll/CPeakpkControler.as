//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/11/27.
 */
package kof.game.peakpk.controll {

import kof.game.common.view.control.CControlBase;
import kof.game.peakpk.CPeakpkNetHandler;
import kof.game.peakpk.CPeakpkSystem;
import kof.game.peakpk.CPeakpkUIHandler;
import kof.game.peakpk.data.CPeakpkData;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;

public class CPeakpkControler extends CControlBase {
    [Inline]
    public function get uiHandler() : CPeakpkUIHandler {
        return _wnd.viewManagerHandler as CPeakpkUIHandler;
    }
    [Inline]
    public function get system() : CPeakpkSystem {
        return _system as CPeakpkSystem;
    }
    [Inline]
    public function get netHandler() : CPeakpkNetHandler {
        return system.netHandler;
    }
    [Inline]
    public function get data() : CPeakpkData {
        return system.data;
    }
    public function get playerData() : CPlayerData {
        return (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
    }
}
}
