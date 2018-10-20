//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.reciprocation {

import kof.framework.CAbstractHandler;
import kof.framework.INetworking;
import kof.message.Account.ComplementIDCardResponse;
import kof.message.CAbstractPackMessage;
import kof.message.Character.AntiAddictionRespon;
import kof.ui.IUICanvas;

/**
 * 防沉迷控制器
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CAntiAddictionHandler extends CAbstractHandler {

    public function CAntiAddictionHandler() {
        super();
    }

    override public function dispose() : void {
        super.dispose();
    }

    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        const pNet : INetworking = this.networking;
        if ( pNet ) {
            pNet.bind( AntiAddictionRespon ).toHandler( _onAntiAddictionMessageHandler );
            pNet.bind( ComplementIDCardResponse ).toHandler( _onComplementIDCardMessageHandler );
        }

        return ret;
    }

    override protected function onShutdown() : Boolean {
        var ret : Boolean = super.onShutdown();

        const pNet : INetworking = this.networking;
        if ( pNet ) {
            pNet.unbind( AntiAddictionRespon );
        }
        return ret;
    }

    public function get networking() : INetworking {
        return system.stage.getBean( INetworking ) as INetworking;
    }

    final private function _onAntiAddictionMessageHandler( pNet : INetworking, response : CAbstractPackMessage ) : void {

        var pConcreteMessage : AntiAddictionRespon = response as AntiAddictionRespon;

        var strMsgText : String = pConcreteMessage ? pConcreteMessage.notice : null;

        if ( null == strMsgText )
            strMsgText = '';

        const pUICanvas : IUICanvas = system.stage.getBean( IUICanvas ) as IUICanvas;

        if ( pUICanvas ) {
            pUICanvas.showMsgBox( strMsgText, null, null, false );
        }
    }

    private function _onComplementIDCardMessageHandler(pNet : INetworking, message : CAbstractPackMessage):void
    {
        var response : ComplementIDCardResponse = message as ComplementIDCardResponse;

        if(response)
        {
            (system.getHandler(CAntiAddictionViewHandler ) as CAntiAddictionViewHandler).addDisplay();
        }
    }

}
}

// vim:ft=as3 ts=4 sw=4 expandtab tw=120
