//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by dendi on 2018/4/12.
 */
package kof.game.gm.command.hangUp {

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;

public class COpenHangUpViewCommand extends CAbstractConsoleCommand {
    public function COpenHangUpViewCommand( ) {
        super();

        name = "open_hangUpView";
        description = "打开挂机面板，Usage：" + this.name;
        this.label = "打开挂机面板";

        this.syncToServer = false;

    }

    override public function onCommand(args:Array):Boolean
    {
//        super.onCommand(args);

        var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        var systemBundle:ISystemBundle = null;
        systemBundle = pSystemBundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.HOOK));
        pSystemBundleCtx.setUserData( systemBundle , "activated", true );

        return true;
    }
}
}
