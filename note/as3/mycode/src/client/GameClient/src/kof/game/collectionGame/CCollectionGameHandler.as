//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by dendi on 2017/12/13.
 */
package kof.game.collectionGame {

import kof.framework.INetworking;
import kof.game.common.system.CNetHandlerImp;
import kof.message.CAbstractPackMessage;
import kof.message.Player.CollectionGameRequest;
import kof.message.Player.CollectionGameResponse;

public class CCollectionGameHandler extends CNetHandlerImp {
    public function CCollectionGameHandler() {
        super();
    }

    override protected function onSetup():Boolean {
        var ret:Boolean = super.onSetup();

        this.bind(CollectionGameResponse, _onCollectionGameResponse);

        return ret;
    }

    private function _onCollectionGameResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void{
        if (isError) return;

        var response:CollectionGameResponse = message as CollectionGameResponse;
        if(response.gamePromptID == 0){
            (system.getHandler(CCollectionGameViewHandler) as CCollectionGameViewHandler).flyItem();
            (system.getHandler( CCollectionGameViewHandler ) as CCollectionGameViewHandler)._removeDisplayB();
            (system as CCollectionGameSystem).closeCollectionGameSystem();
        }

    }

    //收藏游戏
    public function sendCollectionGameRequest():void{
        var request : CollectionGameRequest = new CollectionGameRequest();
        request.info = 1;

        networking.post( request );
    }
}
}
