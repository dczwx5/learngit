//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/1/21.
 */
package kof.game.gm.view.cmdPage {

import kof.game.gm.*;

import QFLib.DashBoard.CConsolePage;
import QFLib.DashBoard.CDashBoard;
import QFLib.DashBoard.CDashPage;
import QFLib.DashBoard.IConsoleCommand;

import kof.framework.CAppSystem;

public class CGMenuPage extends CDashPage {
    public function CGMenuPage(system:CAppSystem, theDashBoard:CDashBoard) {
        super(theDashBoard);
        _gmSystem = system as CGmSystem;
    }

    public override function dispose() : void {
        super.dispose();
    }

    public override function get name() : String {
        return "GmMenu";
    }

    public override function set visible(bVisible:Boolean) : void {
        super.visible = bVisible;
        var consolePage:CConsolePage = m_theDashBoardRef.findPage("ConsolePage") as CConsolePage;
        var data:Array = consolePage.commandHandler.commandMap.toArray();
        (_gmSystem.getBean(CGmUIHandler) as CGmUIHandler).forceSwitchGMenu(this.pageRoot, visible, data);
    }

    public override function onResize() : void {
        super.onResize();

    }

    public override function update(fDeltaTime:Number) : void {
        super.update(fDeltaTime);
    }

    private var _gmSystem:CGmSystem;

}

}
