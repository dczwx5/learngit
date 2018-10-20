//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/6/19.
 */
package kof.game.title.control {

import kof.game.bag.CBagManager;
import kof.game.bag.CBagSystem;
import kof.game.bag.data.CBagData;
import kof.game.common.view.control.CControlBase;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.mainInstance.data.CChapterInstanceData;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.title.CTitleNetHandler;
import kof.game.title.CTitleSystem;
import kof.game.title.CTitleUIHandler;
import kof.game.title.data.CTitleData;

public class CTitleControler extends CControlBase {
    [Inline]
    public function get uiHandler() : CTitleUIHandler {
        return _wnd.viewManagerHandler as CTitleUIHandler;
    }
    [Inline]
    public function get system() : CTitleSystem {
        return _system as CTitleSystem;
    }
    [Inline]
    public function get netHandler() : CTitleNetHandler {
        return (_system as CTitleSystem).netHandler;
    }
    [Inline]
    public function get titleData() : CTitleData {
        return (_system as CTitleSystem).data;
    }
    [Inline]
    public function get playerData() : CPlayerData {
        return (_system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
    }
}
}
