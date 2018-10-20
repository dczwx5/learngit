//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Demi.Liu on 2018-06-01.
 */
package kof.game.redPacket {

import kof.SYSTEM_ID;
import kof.framework.INetworking;
import kof.game.HeroTreasure.CHeroTreasureSystem;
import kof.game.HeroTreasure.CHeroTreasureViewHandler;
import kof.game.KOFSysTags;
import kof.game.activityHall.CActivityHallSystem;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.common.system.CNetHandlerImp;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.IInstanceFacade;
import kof.game.player.view.playerTrain.CPlayerHeroTrainViewHandler;
import kof.game.redPacket.data.CRedPacketInfo;
import kof.message.CAbstractPackMessage;
import kof.message.FighterTreasure.OpenRedEnvelopeRequest;
import kof.message.FighterTreasure.OpenRedEnvelopeResponse;
import kof.message.FighterTreasure.WholeServerRedEnvelopeResponse;

/**
 *@author Demi.Liu
 *@data 2018-06-01
 */
public class CRedPacketHandler extends CNetHandlerImp {
    public function CRedPacketHandler() {
        super();
    }

    override protected function onSetup():Boolean {
        var ret:Boolean = super.onSetup();

        networking.bind(WholeServerRedEnvelopeResponse ).toHandler( _onWholeServerRedEnvelopeResponseHandler);
        networking.bind(OpenRedEnvelopeResponse ).toHandler( _onOpenRedEnvelopeResponseHandler);

        return ret;
    }

    /**********************Request********************************/
    /*打开红包请求*/
    public function onOpenRedEnvelopeRequest(envelopeId:Number ):void{
        var request:OpenRedEnvelopeRequest = new OpenRedEnvelopeRequest();
        request.decode([envelopeId]);

        networking.post(request);
    }

    /**********************Response********************************/
    // 十连抽全服红包事件
    public function _onWholeServerRedEnvelopeResponseHandler( net:INetworking, message:CAbstractPackMessage):void{
        var response:WholeServerRedEnvelopeResponse = message as WholeServerRedEnvelopeResponse;
        var data:CRedPacketInfo = new CRedPacketInfo(response);
        _redPacketManager.redPacketInfoList.push(data);

		//判断红包界面是否为显示状态
        if(!_redPacketManager.isShow){
            var instanceSystem:CInstanceSystem = system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
            instanceSystem.callWhenInMainCity(showRedPacket,null,null,null,1);
        }
    }

    private function showRedPacket():void{
        var pBundle:ISystemBundle = (system as CBundleSystem).ctx.getSystemBundle(SYSTEM_ID(KOFSysTags.RED_PACKET));
        (system as CBundleSystem).ctx.setUserData(pBundle, CBundleSystem.ACTIVATED, true);
    }

    // 打开红包响应
    public function _onOpenRedEnvelopeResponseHandler(net:INetworking, message:CAbstractPackMessage):void{
        var response:OpenRedEnvelopeResponse = message as OpenRedEnvelopeResponse;
        _redPacketManager.openRedPacketInfo = response;
        system.dispatchEvent(new CRedPacketEvent(CRedPacketEvent.openRedPacketResponse,null));
    }

    private function get _redPacketManager():CRedPacketManager{
        return system.getBean(CRedPacketManager) as CRedPacketManager;
    }
}
}
