//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Maniac on 2017/5/4.
 */
package kof.game.shop {

import QFLib.Interface.IUpdatable;

import flash.utils.Dictionary;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;

import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.game.shop.data.CShopInfoData;
import kof.game.shop.data.CShopItemData;
import kof.message.Shop.ShopItemUpdateResponse;
import kof.table.Shop;
import kof.table.ShopItem;
import kof.table.ShopRefresh;

/**
 * 商店数据
 */
public class CShopManager extends CAbstractHandler implements IUpdatable {

    private var _shopTable:IDataTable;
    private var _shopItemTable:IDataTable;
    private var _shopRefreshTable:IDataTable;
    
    private var _shopDic:Dictionary;//商店列表
    public var m_bShopRefreshClock:Boolean = false;

    public function CShopManager() {
        super();
        _shopDic = new Dictionary();
    }

    override public function dispose() : void {
        super.dispose();
    }

    override protected virtual function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        _shopItemTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.SHOP_ITEM);
        _shopTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.SHOP);
        _shopRefreshTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.SHOP_REFRESH);

        return ret;
    }

    public function getShopInfoByShopId(shopID:int):CShopInfoData {
        return _shopDic[shopID];
    }

//    public function updateShopList(info:CShopInfoData):void {
//        _shopDic[info.shopID] = info;
//    }

    public function updateShopList(data:Object):void {
        var oldData:CShopInfoData = _shopDic[data.shopID];
        if(oldData){
            oldData.clearShopList();
            oldData.updateDataByData(data);
        }
    }

    public function addShopInfo(info:CShopInfoData):void {
        _shopDic[info.shopID] = info;
    }

    public function deleteShopInfo(shopID:int):void {
        if(_shopDic[shopID]){
            delete _shopDic[shopID];
        }
    }

    public function getShopList():Array{
        var arr:Array = [];
        for each(var obj:Object in _shopDic){
            arr.push(obj);
        }
        arr.sortOn("shopID",Array.NUMERIC);
        return arr;
    }

    /**
     * 获取商店页签
     * @return
     */
    public function getTabList():String {
        var shop:Shop = null;
        var str:String = "";
        var shopArr:Array = getShopList();
        for each(var info:CShopInfoData in shopArr){
            shop = getShopTableByID(info.shopID);
            if(shop.show == 1){
                //0不显示1显示
                str += shop.name + ",";
            }
        }
        return str.substring(0,str.length-1);
    }
    /**
     * 获取商店页签(新)
     * @return
     */
    public function getTabListByType( type : int ):String {
        var shop:Shop = null;
        var str:String = "";
        var shopArr:Array = getShopList();
        for each(var info:CShopInfoData in shopArr){
            shop = getShopTableByID(info.shopID);
            if(shop.shopGroup == type && shop.show == 1){
                str += shop.name + ",";
            }
        }
        return str.substring(0,str.length-1);
    }

    public function getGroupTypeByType( type:int ):int{
        var ary : Array = getShopTableByType( type );
        var shop : Shop = ary[0] as Shop;
        return shop.shopGroup;
    }

    public function getShopByName(shopName:String):Shop {
        for each(var shopInfo:CShopInfoData in _shopDic){
            if(shopInfo.shopName == shopName){
                var shop:Shop = _shopTable.findByPrimaryKey(shopInfo.shopID);
                return shop;
            }
        }
        return null;
    }

    public function getShopListByName(shopName:String):Array {
        for each(var shopInfo:CShopInfoData in _shopDic){
            if(shopInfo.shopName == shopName){
                return shopInfo.shopItemInfos;
            }
        }
        return null;
    }

    public function isHaveShopByType(type:int):Boolean {
        var shop:Shop = null;
        for each(var shopInfo:CShopInfoData in _shopDic){
            shop = getShopTableByID(shopInfo.shopID);
            if(shop.type == type){
                return true;
            }
        }
        return false;
    }

    /**
     * 更新商品信息
     * @param
     */
    public function updateShopItemInfo(response:ShopItemUpdateResponse):void {
        var shopID:int = response.shopID;
        var updateType:int = response.updateType;
        var shopItemID:int = response.updateShopItemInfo.shopItemID;
        if(_shopDic[shopID]){
            var shopInfo:CShopInfoData = _shopDic[shopID];
            var index:int = 0;
            var shopItemInfo:CShopItemData = null;
            for each(var itemInfo:CShopItemData in shopInfo.shopItemInfos){
                if(itemInfo.shopItemID == shopItemID){
                    if(updateType == 1){
                        //新增
                        shopItemInfo = new CShopItemData();
                        shopItemInfo.updateDataByData(response.updateShopItemInfo);
                        shopInfo.shopItemInfos.push(shopItemInfo);
                    }else if(updateType == 2){
                        //删除
                        index = shopInfo.shopItemInfos.indexOf(itemInfo);
                        shopInfo.shopItemInfos.splice(index,1);
                    }else if(updateType == 3){
                        //更新
                        itemInfo.updateDataByData(response.updateShopItemInfo);
                    }
                }
            }
        }
    }

    public function getShopItemTableByID(id:int) : ShopItem {
        return _shopItemTable.findByPrimaryKey(id) as ShopItem;
    }

    public function getShopTableByID(id:int) : Shop {
        return _shopTable.findByPrimaryKey(id) as Shop;
    }

    public function getShopTableByType(type:int) : Array {
        return _shopTable.findByProperty("type",type) as Array;
    }

    public function getShopRefreshTable( shopID:int,refreshNum:int) : ShopRefresh {
        var shopArr:Array = _shopRefreshTable.findByProperty("shopID",shopID);
        if( shopArr == null || shopArr.length <= 0)return null;
        for each(var shopRe:ShopRefresh in shopArr){
            if(shopRe.refreshNum == (refreshNum+1)){
                return shopRe;
            }
        }
        return null;
    }

    public function update( delta : Number ) : void {

    }

}
}
