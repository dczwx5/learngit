//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by dendi on 2017/12/14.
 */
package kof.game.weiClient {

import kof.framework.INetworking;
import kof.game.common.system.CNetHandlerImp;
import kof.message.CAbstractPackMessage;
import kof.message.Player.MicroClientRewardRequest;
import kof.message.Player.MicroClientRewardResponse;

public class CWeiClientHandler extends CNetHandlerImp {
    public function CWeiClientHandler() {
        super();
    }
    override protected function onSetup():Boolean {
        var ret:Boolean = super.onSetup();

        this.bind(MicroClientRewardResponse, _onMicroClientRewardResponse);

        return ret;
    }

    private function _onMicroClientRewardResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void{
        if (isError) return;

        var response:MicroClientRewardResponse = message as MicroClientRewardResponse;
        if(response.gamePromptID == 0){
            (system.getHandler(CWeiClientViewHandler) as CWeiClientViewHandler).flyItem();
            (system.getHandler( CWeiClientViewHandler ) as CWeiClientViewHandler).removeDisplay();
            (system as CWeiClientSystem).closeWeiClientSystem();
        }

    }

    //领取微端奖励
    public function sendMicroClientRewardRequest():void{
        var request : MicroClientRewardRequest = new MicroClientRewardRequest();
        request.info = 1;

        networking.post( request );
    }

}
}
