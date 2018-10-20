//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Maniac on 2017/6/14.
 */
package kof.game.vip {

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.INetworking;
import kof.game.common.CRewardUtil;
import kof.game.common.system.CNetHandlerImp;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardListData;
import kof.game.player.CPlayerSystem;
import kof.game.vip.event.CVIPEvent;
import kof.message.CAbstractPackMessage;
import kof.message.VIP.VipEverydayRewardRequest;
import kof.message.VIP.VipEverydayRewardResponse;
import kof.message.VIP.VipGiftRequest;
import kof.message.VIP.VipGiftResponse;
import kof.message.VIP.VipLevelRewardRequest;
import kof.message.VIP.VipLevelRewardResponse;
import kof.table.GamePrompt;
import kof.table.Item;
import kof.table.VipLevel;
import kof.ui.CUISystem;

public class CVIPHandler extends CNetHandlerImp {
    public function CVIPHandler() {
        super();
    }

    override protected function onSetup() : Boolean {
        var ret:Boolean = super.onSetup();
        this.bind(VipGiftResponse,_onBuyVipGiftResponseHandler);//IP:10.10.17.141
        this.bind(VipLevelRewardResponse,_onGetFreeVipGiftResponseHandler);
        this.bind(VipEverydayRewardResponse,_onVipEverydayRewardResponseHandler);
        return ret;
    }

    /******************************S2C**************************************/

    public function _onBuyVipGiftResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return;

        var response:VipGiftResponse = message as VipGiftResponse;
        if( response.gamePromptID == 0 ){
            //购买成功
            playSystem.playerData.vipData.vipGifts.push(response.vipLevel);
            //特权列表
            var vipLvTable:VipLevel = vipManager.getVipLevelTableByID( response.vipLevel );
            if( vipLvTable ){
                var itemTable:Item = getItemTableByID( vipLvTable.gift );
                if( itemTable ){
                    var rewardData:CRewardListData = CRewardUtil.createByDropPackageID( vipSysTem.stage, int(itemTable.param2) );
                    if( rewardData ){
                        (system.stage.getSystem(CItemSystem) as CItemSystem).showRewardFull(rewardData);
                    }
                }
            }
            system.dispatchEvent(new CVIPEvent(CVIPEvent.VIP_BUYGIFT));
        }else{
            var proStr:String = getGamePromptStr(response.gamePromptID);
            if( proStr != null){
                (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert(proStr);
            }
        }
    }

    public function _onGetFreeVipGiftResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return;

        var response:VipLevelRewardResponse = message as VipLevelRewardResponse;
        if( response.gamePromptID == 0 ){
            //购买成功
            playSystem.playerData.vipData.vipRewards.push(response.vipLevel);
            system.dispatchEvent(new CVIPEvent(CVIPEvent.VIP_GET_FREE_GIFT));
            ((system as CVIPSystem).getBean( CVIPViewHandler ) as CVIPViewHandler).flyItem();
        }else{
            var proStr:String = getGamePromptStr(response.gamePromptID);
            if( proStr != null){
                (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert(proStr);
            }
        }
    }
    public function _onVipEverydayRewardResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return;

        var response:VipEverydayRewardResponse = message as VipEverydayRewardResponse;
        if( response.gamePromptID == 0 ){
            //购买成功
            playSystem.playerData.vipData.vipEverydayReward.push(response.vipLevel);
            system.dispatchEvent(new CVIPEvent(CVIPEvent.VIP_GET_EVERYDAYREWARD));
        }else{
            var proStr:String = getGamePromptStr(response.gamePromptID);
            if( proStr != null){
                (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert(proStr);
            }
        }
    }

    /******************************C2S**************************************/

    public function onBuyVipGiftRequestHandler(vipLv:int):void {
        var request:VipGiftRequest = new VipGiftRequest();
        request.vipLevel = vipLv;
        networking.post(request);
    }

    public function onGetFreeVipGiftRequestHandler(vipLv:int):void {
        var request:VipLevelRewardRequest = new VipLevelRewardRequest();
        request.vipLevel = vipLv;
        networking.post(request);
    }
    public function onVipEverydayRewardRequestHandler(vipLv:int):void {
        var request:VipEverydayRewardRequest = new VipEverydayRewardRequest();
        request.vipLevel = vipLv;
        networking.post(request);
    }

    //===========================================================

    private function get playSystem() : CPlayerSystem {
        return system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
    }

    private function get vipSysTem() : CVIPSystem {
        return system as CVIPSystem;
    }

    private function get vipManager() : CVIPManager {
        return system.getBean( CVIPManager ) as CVIPManager;
    }

    private function getGamePromptStr(gamePromptID:int):String {
        var pTable:IDataTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.GAME_PROMPT);
        var configInfo:GamePrompt = pTable.findByPrimaryKey(gamePromptID) as GamePrompt;
        var pStr:String = null;
        if(configInfo){
            pStr = configInfo.content;
        }
        return pStr;
    }

    public function getItemTableByID(id:int) : Item{
        var itemTable:IDataTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.ITEM);
        return itemTable.findByPrimaryKey(id);
    }



}
}
