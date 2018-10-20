//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/9/22.
 */
package kof.game.gm.command.focusLost {

import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;
import kof.game.reciprocation.CFocusLostViewHandler;
import kof.game.reciprocation.CReciprocalSystem;

public class CFocusLostCancelCommand extends CAbstractConsoleCommand {
    public function CFocusLostCancelCommand()
    {
        super();

        name = "close_focusLost_tip";
        description = "关闭焦点丢失提示，Usage：" + this.name;
        this.label = "关闭焦点丢失提示";

        this.syncToServer = false;
    }

    override public function onCommand(args:Array):Boolean
    {
//        super.onCommand(args);

        (system.stage.getSystem(CReciprocalSystem ).getHandler(CFocusLostViewHandler) as CFocusLostViewHandler).closeFocusLostTip();

        return true;
    }
}
}
