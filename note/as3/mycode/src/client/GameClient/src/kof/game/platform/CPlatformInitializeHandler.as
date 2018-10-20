//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/1/15.
 */
package kof.game.platform {

import kof.game.platform.data.CPlatformBaseData;
import kof.game.platform.sevenK.C7KData;
import kof.game.platform.tx.data.CTXData;
import kof.game.platform.tx.view.CTXGetSignatureView;
import kof.game.platform.tx.view.CTXSignatureRender;
import kof.game.platform.view.CPlatformGetSignatureViewHandler;
import kof.game.platform.view.CPlatformSignatureRenderHandler;
import kof.game.platform.view.CQFGetSignatureView;
import kof.game.platform.view.CQFSignatureRender;
import kof.game.platform.yy.data.CYYData;


public class CPlatformInitializeHandler extends CPlatformModuleHandler {
    public function initialize() : void {
        var functionMapHandler:CPlatformFunctionMapHandler = platformHandler.functionMap;
        var signatureRenderHandler:CPlatformSignatureRenderHandler = platformHandler.signatureRender;
        var getSignatureViewHandler:CPlatformGetSignatureViewHandler = platformHandler.getSignatureViewHandler;

        var functionData:CPlatformFunctionData;
        functionData = new CPlatformFunctionData(EPlatformType.PLATFORM_TX, CTXData, CTXSignatureRender, CTXGetSignatureView);
        functionMapHandler.addData(functionData.platform, functionData);

        functionData = new CPlatformFunctionData(EPlatformType.PLATFORM_7K, C7KData, CQFSignatureRender, CQFGetSignatureView);
        functionMapHandler.addData(functionData.platform, functionData);

        functionData = new CPlatformFunctionData(EPlatformType.PLATFORM_YY, CYYData, CQFSignatureRender, CQFGetSignatureView);
        functionMapHandler.addData(functionData.platform, functionData);

        // 添加getSgingature处理和signatureRender处理到CPlatformSignatureRenderHandler和CPlatformGetSignatureViewHandler
        functionMapHandler.loop(function (key:String, functionData:CPlatformFunctionData) : void {
            var signatureRenderClass:Class = functionData.signatureRenderClass;
            if (signatureRenderClass) {
                signatureRenderHandler.addBean(new signatureRenderClass());
            }

            var getSignatureViewClass:Class = functionData.getSignatureViewClass;
            if (getSignatureViewClass) {
                getSignatureViewHandler.addBean(new getSignatureViewClass());
            }
        });
    }

    public function createDefaultData(platform:String, dataClass:Class) : CPlatformFunctionData {
        var functionData:CPlatformFunctionData;
        functionData = new CPlatformFunctionData(platform, CPlatformBaseData, CQFSignatureRender, CQFGetSignatureView);
        return functionData;
    }

}
}
