//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/12/20.
 */
package kof.game.platform {

import kof.framework.CAbstractHandler;
import kof.game.platform.data.CPlatformBaseData;
import kof.game.platform.sevenK.C7KData;
import kof.game.platform.tx.data.CTXData;
import kof.game.platform.view.CPlatformGetSignatureViewHandler;
import kof.game.platform.view.CPlatformSignatureRenderHandler;
import kof.game.platform.xiyou.CXiyouDataManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.player.event.CPlayerEvent;

public class CPlatformHandler extends CAbstractHandler {
    public function CPlatformHandler() {

    }
    public override function dispose() : void {
        super.dispose();
    }
    protected override function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        addBean(_functionMap = new CPlatformFunctionMapHandler());
        addBean(_builder = new CPlatformBuilderHandler());
        addBean(_signatureRender = new CPlatformSignatureRenderHandler());
        addBean(_getSignatureView = new CPlatformGetSignatureViewHandler());
        addBean(_initializeHandler = new CPlatformInitializeHandler());
        addBean(_xiyouManager = new CXiyouDataManager());
        _initializeHandler.initialize();

        _system.addEventListener(CPlayerEvent.PLAYER_DATA_INITIAL, _onInitialData);

        return ret;
    }

    private function _onInitialData(e:CPlayerEvent) : void {
        _system.removeEventListener(CPlayerEvent.PLAYER_DATA_INITIAL, _onInitialData);
        _data = _builder.build(_playerData.platformData.platformInfo);
        //暂时只有西游平台需要
        if(data.platform == EPlatformType.PLATFORM_XIYOU)
        {
            //载入游戏后同时请求支付宝和微信二维码
            _xiyouManager.onQrcodeXiyouRequest(1);
            _xiyouManager.onQrcodeXiyouRequest(2);
        }
    }

    [Inline]
    private function get _playerData() : CPlayerData {
        return _system.playerData;
    }
    [Inline]
    private function get _system() : CPlayerSystem {
        return system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
    }


    [Inline]
    public function get txData() : CTXData {
        return _data as CTXData;
    }

    public function get sevenKData():C7KData
    {
        return _data as C7KData;
    }

    [Inline]
    public function get data() : CPlatformBaseData {
        return _data;
    }
    public function get builder() : CPlatformBuilderHandler {
        return _builder;
    }
    public function get functionMap() : CPlatformFunctionMapHandler {
        return _functionMap;
    }
    public function get signatureRender() : CPlatformSignatureRenderHandler {
        return _signatureRender;
    }
    public function get getSignatureViewHandler() : CPlatformGetSignatureViewHandler {
        return _getSignatureView;
    }
    private var _data:CPlatformBaseData;

    private var _builder:CPlatformBuilderHandler;
    private var _functionMap:CPlatformFunctionMapHandler;
    private var _signatureRender:CPlatformSignatureRenderHandler;
    private var _getSignatureView:CPlatformGetSignatureViewHandler;
    private var _initializeHandler:CPlatformInitializeHandler;
    private var _xiyouManager : CXiyouDataManager;

}
}
