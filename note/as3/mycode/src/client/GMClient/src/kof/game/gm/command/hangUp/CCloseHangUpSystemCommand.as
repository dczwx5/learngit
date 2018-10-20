//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by dendi on 2018/4/24.
 */
package kof.game.gm.command.hangUp {

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;
import kof.game.hook.CHookSystem;

public class CCloseHangUpSystemCommand extends CAbstractConsoleCommand {
    public function CCloseHangUpSystemCommand( ) {
        super();

        name = "close_hangUpSystem";
        description = "取消挂机，Usage：" + this.name;
        this.label = "取消挂机";

        this.syncToServer = false;
    }

    override public function onCommand(args:Array):Boolean
    {
//        super.onCommand(args);

        var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        var hookSystem:CHookSystem = system.stage.getSystem(CHookSystem) as CHookSystem;
        var systemBundle:ISystemBundle = pSystemBundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.HOOK));
        pSystemBundleCtx.setUserData( systemBundle , "activated", false );
        pSystemBundleCtx.unregisterSystemBundle(hookSystem);
        return true;
    }
}
}
