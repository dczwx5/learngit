//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.skin {

import QFLib.Framework.CFramework;

import kof.game.core.CGameComponent;

/**
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CSkinDisplay extends CGameComponent implements ISkin {

    private var m_pGraphicsFramework : CFramework;

    public function CSkinDisplay( pGraphicsFramework : CFramework ) {
        super();
        m_pGraphicsFramework = pGraphicsFramework;
    }

    override protected virtual function onEnter() : void {
        super.onEnter();
    }

    override protected virtual function onDataUpdated() : void {
        super.onDataUpdated();
    }

    override protected virtual function onExit() : void {
        super.onExit();
    }

}
}
