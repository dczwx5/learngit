//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun CNetwork Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.net {

import kof.framework.CAppStage;
import kof.framework.CAppSystem;
import kof.framework.INetworking;
import kof.message.Common.PingPongResponse;
import kof.util.CAssertUtils;

/**
 * Socket心跳包，TCP KeepAlive.
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CHeartbeatSystem extends CAppSystem {

    /**
     * Creates a CHeartbeatSystem instance.
     */
    public function CHeartbeatSystem() {
        super();
    }

    /** Ref of INetworking */
    private var _networkingRef:INetworking;

    override protected virtual function onSetup():Boolean {
        var ret:Boolean = super.onSetup();

        ret = ret && (_networkingRef = stage.getSystem(INetworking) as INetworking);
        CAssertUtils.assertNotNull(_networkingRef);

        if (ret) {
            _networkingRef.bind(PingPongResponse).toHandler(pingPongMessageHandler);
        }

        return ret;
    }

    private function pingPongMessageHandler():void {
        // TODO: handle PingPongResponse.
    }

    override protected function enterStage(appStage:CAppStage):void {
        super.enterStage(appStage);

        // start ping-pong ball.
    }

} // class CHeartbeatSystem
}
