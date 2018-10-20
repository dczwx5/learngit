//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2016/10/10.
 */
package kof.game.bag {

import QFLib.Interface.IUpdatable;

import kof.framework.CSystemHandler;
import kof.framework.INetworking;
import kof.game.common.CItemUtil;
import kof.game.common.CRewardUtil;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardListData;
import kof.message.CAbstractPackMessage;
import kof.message.Item.ItemListRequest;
import kof.message.Item.ItemListResponse;
import kof.message.Item.ItemRewardsShowResponse;
import kof.message.Item.ItemSellRequest;
import kof.message.Item.ItemUpdateResponse;
import kof.message.Item.ItemUseRequest;
import kof.ui.CMsgAlertHandler;
import kof.ui.CUISystem;
import kof.ui.IUICanvas;

public class CBagHandler extends CSystemHandler implements IUpdatable {

    private var _isDispose:Boolean;

    public function CBagHandler() {
        super();

        _isDispose = false;
    }

    public override function dispose() : void {
        if (_isDispose) return ;
        super.dispose();
        networking.unbind(ItemListResponse);
        networking.unbind(ItemUpdateResponse);


        _isDispose = true;
    }
    override protected function onSetup():Boolean {
        networking.bind(ItemListResponse).toHandler(_onItemListResponseHandler);
        networking.bind(ItemUpdateResponse).toHandler(_onItemUpdateResponseHandler);
        networking.bind(ItemRewardsShowResponse).toHandler(_onItemRewardsShowResponseHandler);

        this.onItemListRequest();
        return true;
    }

    /**********************Request********************************/

    public function onItemListRequest() : void {
        var request:ItemListRequest = new ItemListRequest();
        request.decode([1]);

        networking.post(request);
    }

    public function onItemUseRequest(uid:Number,num:int = 0,param:String = ""):void{
        var request:ItemUseRequest = new ItemUseRequest();
        request.decode([uid,num,param]);

        networking.post(request);
    }
    public function onItemSellRequest(uid:Number,num:int):void{
        var request:ItemSellRequest = new ItemSellRequest();
        request.decode([uid,num]);

        networking.post(request);
    }


    /**********************Response********************************/

    private final function _onItemListResponseHandler(net:INetworking, message:CAbstractPackMessage):void {
        var response:ItemListResponse = message as ItemListResponse;
        (system.getBean(CBagManager) as CBagManager).initialBagData(response);
    }
    private final function _onItemUpdateResponseHandler(net:INetworking, message:CAbstractPackMessage):void {
        var response:ItemUpdateResponse = message as ItemUpdateResponse;
        (system.getBean(CBagManager) as CBagManager).updateBagData(response);
        system.dispatchEvent(new CBagEvent(CBagEvent.BAG_UPDATE));
    }

    /**
     * 展示使用礼包获得的物品/货币
     * @param net
     * @param message
     */
    private final function _onItemRewardsShowResponseHandler(net:INetworking, message:CAbstractPackMessage):void {
        var response:ItemRewardsShowResponse = message as ItemRewardsShowResponse;
        if(response)
        {
            if(response.type == 1)// 货币
            {
                if(response.rewardList && response.rewardList.length)
                {
                    for each(var data:Object in response.rewardList)
                    {
                        var currencyName:String = CItemUtil.getCurrencyNameById(data.ID);
                        (system.stage.getSystem(IUICanvas) as CUISystem).showMsgAlert("获得" + currencyName + "x" + data.num,
                                CMsgAlertHandler.NORMAL);
                    }
                }
            }
            else// 礼包
            {
                var rewardListData:CRewardListData = CRewardUtil.createByList(system.stage, response.rewardList);
                if(rewardListData)
                {
                    (system.stage.getSystem(CItemSystem) as CItemSystem).showRewardFull(rewardListData);
                }
            }
        }
    }

    public function update(delta:Number) : void {

    }
}
}
