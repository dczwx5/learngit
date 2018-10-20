//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/1/9.
 */
package kof.game.platform {

import kof.game.platform.data.CPlatformBaseData;
import kof.game.player.CPlayerSystem;

public class CPlatformBuilderHandler extends CPlatformModuleHandler {
    public function CPlatformBuilderHandler() {

    }
    public override function dispose() : void {
        super.dispose();
    }
    protected override function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        return ret;
    }

    public function build(platformInfo:Object) : CPlatformBaseData {
        if (platformInfo == null) {
            platformInfo = new Object();
        }

        var sPlatform:String = platformInfo["platform"];
        // 如果platform为空, 则使用默认的
        if (sPlatform == null || sPlatform.length == 0) {
            sPlatform = EPlatformType.PLATFORM_DEFAULT;
        }
        var data:Object = platformInfo["data"];

        var functionData:CPlatformFunctionData = platformHandler.functionMap.getByType(sPlatform);
        if (!functionData) {
            // 不存在的platform, 创建默认的处理
            functionData = (platformHandler.getBean(CPlatformInitializeHandler) as CPlatformInitializeHandler).createDefaultData(sPlatform, CPlatformBaseData);
            platformHandler.functionMap.addData(functionData.platform, functionData);
        }

        var platformData:CPlatformBaseData = new (functionData.dataClass)();
        platformData.platform = sPlatform;
        platformData.platformServerID =  _system.stage.configuration.getInt( 'external.ptsid', _system.stage.configuration.getInt( 'ptsid' ) );
        platformData.account = _system.stage.configuration.getString( 'external.account', _system.stage.configuration.getString( 'account' ) );
        platformData.updateData(data);

        return platformData;
    }

    private function get _system() : CPlayerSystem
    {
        return system as CPlayerSystem;
    }
}
}
