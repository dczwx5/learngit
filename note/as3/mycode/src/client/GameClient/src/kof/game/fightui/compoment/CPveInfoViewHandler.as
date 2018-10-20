//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2016/12/2.
 */
package kof.game.fightui.compoment {

import kof.framework.CViewHandler;
import kof.game.core.CGameObject;
import kof.ui.demo.FightUI;

public class CPveInfoViewHandler extends CViewHandler {

    private var m_fightUI:FightUI;

    public function CPveInfoViewHandler($fightUI:FightUI) {
        super();
        m_fightUI = $fightUI;
        m_fightUI.box_pveinfo.visible = false;
    }
    public function setData(hero:CGameObject):void {
        if ( !m_fightUI || !hero )
            return;
    }
    public function hide(removed:Boolean = true):void {

    }
}
}
