//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/5/5.
 */
package kof.game.Tutorial.control {

import kof.game.Tutorial.CTutorHandler;
import kof.game.Tutorial.CTutorSystem;
import kof.game.Tutorial.CTutorUIHandler;
import kof.game.Tutorial.data.CTutorData;
import kof.game.common.view.control.CControlBase;


public class CTutorControler extends CControlBase {
    [Inline]
    public function get uiHandler() : CTutorUIHandler {
        return _wnd.viewManagerHandler as CTutorUIHandler;
    }
    [Inline]
    public function get system() : CTutorSystem {
        return _system as CTutorSystem;
    }
    [Inline]
    public function get netHandler() : CTutorHandler {
        return system.netHandler;
    }
    [Inline]
    public function get tutorData() : CTutorData {
        return system.tutorData;
    }

}
}
