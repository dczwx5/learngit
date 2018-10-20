package kof.game.bootstrap {

import kof.framework.CAbstractHandler;
import kof.framework.INetworking;
import kof.message.CAbstractPackMessage;
import kof.message.Common.AskRequest;
import kof.message.Common.AskResponse;

/**
 *
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CServerAskHandler extends CAbstractHandler {

    /** @private */
    public function CServerAskHandler() {
        super();
    }

    public function get networking() : INetworking {
        return system.stage.getSystem( INetworking ) as INetworking;
    }

    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        if ( ret && this.networking ) {
            this.networking.bind( AskResponse ).toHandler( _onAskResponseHandler );
        }

        return ret;
    }

    override protected function onShutdown() : Boolean {
        var ret : Boolean = super.onShutdown();

        if ( ret && this.networking ) {
            this.networking.unbind( AskResponse );
        }

        return ret;
    }

    private function _onAskResponseHandler( net : INetworking, msg : CAbstractPackMessage ) : void {
        var response : AskResponse = msg as AskResponse;
        var request : AskRequest = net.getMessage( AskRequest ) as AskRequest;
        request.time = response.time;
        net.send( request );
    }

}
}

// vim:ft=as3 tw=120 ts=4 sw=4 expandtab
