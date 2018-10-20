//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/1/21.
 */
package kof.game.gm.view.cmdPage {

import QFLib.DashBoard.CDashBoard;
import QFLib.DashBoard.CDashPage;

import kof.framework.CAppSystem;
import kof.game.gm.CGmSystem;
import kof.game.gm.CGmUIHandler;

public class CGmPage extends CDashPage {
    public function CGmPage(system:CAppSystem, theDashBoard:CDashBoard) {
        super(theDashBoard);
        _gmSystem = system as CGmSystem;
    }

    public override function dispose() : void {
        super.dispose();
    }

    public override function get name() : String {
        return "GmPage";
    }

    public override function set visible(bVisible:Boolean) : void {
        super.visible = bVisible;

        (_gmSystem.getBean(CGmUIHandler) as CGmUIHandler).forceSwitchGmView(this.pageRoot, visible, _gmSystem.gmData);
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
