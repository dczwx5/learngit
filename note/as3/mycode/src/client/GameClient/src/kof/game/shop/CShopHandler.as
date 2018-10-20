//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Maniac on 2017/5/4.
 */
package kof.game.shop {

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.INetworking;
import kof.game.common.CLang;
import kof.game.common.system.CNetHandlerImp;
import kof.game.instance.CInstanceSystem;
import kof.game.level.CLevelSystem;
import kof.game.shop.data.CShopInfoData;
import kof.game.shop.data.CShopItemData;
import kof.game.shop.enum.EShopType;
import kof.game.shop.event.CShopEvent;
import kof.game.shop.view.CShopBuyViewHandler;
import kof.message.CAbstractPackMessage;
import kof.message.Shop.BuyShopItemRequest;
import kof.message.Shop.RefreshShopRequest;
import kof.message.Shop.RefreshShopResponse;
import kof.message.Shop.ShopInfoRequest;
import kof.message.Shop.ShopInfoResponse;
import kof.message.Shop.ShopItemUpdateResponse;
import kof.message.Shop.ShopUpdateResponse;
import kof.table.GamePrompt;
import kof.table.Shop;
import kof.ui.CUISystem;

/**
 * C2S || S2C
 * 商店请求处理
 */
public class CShopHandler extends CNetHandlerImp {

    public function CShopHandler() {
        super();
    }

    override protected function onSetup() : Boolean {
        var ret:Boolean = super.onSetup();
        this.bind(ShopInfoResponse,_onShopInfoResponseHandler);
        this.bind(ShopUpdateResponse,_onShopUpdateResponseHandler);
        this.bind(ShopItemUpdateResponse,_onShopItemUpdateResponseHandler);

        this.bind(RefreshShopResponse,_onShopRefreshResponseHandler);


        this.onShopListRequest();//186
        return ret;
    }

    /******************************S2C**************************************/

    /**商品信息改变反馈*/
    private function _onShopItemUpdateResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return;
        var response:ShopItemUpdateResponse = message as ShopItemUpdateResponse;
        shopManager.updateShopItemInfo(response);
        if( response.updateShopItemInfo.isBuyShopItemUpdate ){
            (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert(CLang.LANG_00015);
            shopBuyView.flyItem();
            system.dispatchEvent(new CShopEvent(CShopEvent.SHOP_ITEM_UPDATE));
        }
    }

    /**商店信息改变反馈*/
    private function _onShopUpdateResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return;
        var response:ShopUpdateResponse = message as ShopUpdateResponse;
        var shopInfo:CShopInfoData = null;
        var shop:Shop = null;
        for each(var obj:Object in response.updateShopInfos){
            shopInfo = new CShopInfoData(system);
            shopInfo.updateDataByData(obj);
            if(obj.updateType == 1){
                //新增
                shop = shopManager.getShopTableByID(shopInfo.shopID);
                if( shop.type == EShopType.SHOP_TYPE_1 ){
                    if(instanceSysTem){
                        instanceSysTem.callWhenInMainCity(_onShopRemindcom,null,null,null,1)
                    }
                }
                shopManager.addShopInfo(shopInfo);
            }else if(obj.updateType == 2){
                //删除
                shopManager.deleteShopInfo(shopInfo.shopID);
            }else if(obj.updateType == 3){
                //更新（整个替换）
                shopManager.updateShopList(obj);
            }
        }

        var proStr:String = getGamePromptStr(response.gamePromptID);
        if( proStr != null){

            if ( response.contents && response.contents.length ) {
                for ( var s : int = 0, e : int = response.contents.length; s < e; s++ ) {
                    proStr = proStr.replace( '{' + s + '}', response.contents[ s ] );
                }
            }
            var replaceTokens : Array = proStr.match( /\{\d\}/g );
            if ( replaceTokens && replaceTokens.length > 1 ) {
                for ( s = 0, e = response.contents.length; s < e; s++ ) {
                    proStr = proStr.replace( replaceTokens[ s ], '' );
                }
            }
            (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert(proStr);
        }

        system.dispatchEvent(new CShopEvent(CShopEvent.SHOP_LIST_UPDATE));
    }

    /**商店列表信息反馈*/
    private function _onShopInfoResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return;
        var response:ShopInfoResponse = message as ShopInfoResponse;
        var shopInfo:CShopInfoData = null;
        for each(var data:Object in response.allShopInfos){
            shopInfo = new CShopInfoData(system);
            shopInfo.updateDataByData(data);
            shopManager.addShopInfo(shopInfo);
        }
    }

    /**刷新商店反馈*/
    private function _onShopRefreshResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return;
        var response:RefreshShopResponse = message as RefreshShopResponse;

        shopManager.m_bShopRefreshClock = false;
    }



    private function _onShopRemindcom():void {
        system.dispatchEvent(new CShopEvent(CShopEvent.SHOP_REMIND_COME));
    }
    /******************************C2S**************************************/

    /**请求商店物品列表*/
    public function onShopListRequest():void
    {
        var request:ShopInfoRequest = new ShopInfoRequest();
        request.shopInfo = 1;
        networking.post(request);
    }

    /**请求购买商店物品*/
    public function onBuyShopItemRequest(shopID:int,shopItemID:int,shopItemNum:int):void
    {
        var request:BuyShopItemRequest = new BuyShopItemRequest();
        request.shopID = shopID;
        request.shopItemID = shopItemID;
        request.shopItemNum = shopItemNum;
        networking.post(request);
    }

    /**请求刷新商店*/
    public function onRefreshShopRequest(shopID:int):void
    {
        shopManager.m_bShopRefreshClock = true;
        var request:RefreshShopRequest = new RefreshShopRequest();
        request.shopID = shopID;
        networking.post(request);
    }

    public function get shopManager():CShopManager
    {
        return system.getBean(CShopManager) as CShopManager;
    }

    public function get shopBuyView():CShopBuyViewHandler
    {
        return system.getBean(CShopBuyViewHandler) as CShopBuyViewHandler;
    }

    private function get instanceSysTem() : CInstanceSystem {
        return system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
    }

    /******************************table**************************************/
    private function getGamePromptStr(gamePromptID:int):String {
        var pTable:IDataTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.GAME_PROMPT);
        var configInfo:GamePrompt = pTable.findByPrimaryKey(gamePromptID) as GamePrompt;
        var pStr:String = null;
        if(configInfo){
            pStr = configInfo.content;
        }
        return pStr;
    }

}
}
