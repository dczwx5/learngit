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

public class CFocusLostOpenCommand extends CAbstractConsoleCommand {
    public function CFocusLostOpenCommand()
    {
        super();

        name = "open_focusLost_tip";
        description = "打开焦点丢失提示，Usage：" + this.name;
        this.label = "打开焦点丢失提示";

        this.syncToServer = false;
    }

    override public function onCommand(args:Array):Boolean
    {
//        super.onCommand(args);

        (system.stage.getSystem(CReciprocalSystem).getHandler(CFocusLostViewHandler) as CFocusLostViewHandler).openFocusLostTip();

        return true;
    }
}
}
