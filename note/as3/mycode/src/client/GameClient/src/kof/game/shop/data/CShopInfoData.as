/**
 * Created by Maniac on 2017/5/9.
 */
package kof.game.shop.data {

import QFLib.Foundation.CMap;

import kof.data.CDatabaseSystem;

import kof.data.CObjectData;
import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.table.Shop;

public class CShopInfoData extends CObjectData{

    private var _shopItemList:Array = [];
    private var _system:CAppSystem;

    public function CShopInfoData(system:CAppSystem) {
        super();
        _system = system;
        _data = new CMap();
    }

    override public function updateDataByData( data : Object ) : void {
//        super.updateDataByData( data );
        if (!data) return ;
        for (var key:String in data) {
            if(key == _shopItemInfos){
                for each(var item:Object in data[key]){
                    var itemData:CShopItemData = new CShopItemData();
                    itemData.updateDataByData(item);
                    _shopItemList.push(itemData);
                    _data[key] = _shopItemList;
                }
            }else{
                _data[key] = data[key];
            }
        }
    }

    public function clearShopList():void {
        _shopItemList = [];
    }

    public function get shopID() : int { return _data[_shopID]; }
    public function get alreadyRefreshNum() : int { return _data[_alreadyRefreshNum]; }
    public function get time() : Number { return _data[_time]; }
    public function get shopItemInfos() : Array { return _data[_shopItemInfos]; }

    public function get shopName() : String {
        if(shopData == null)return null;
        return shopData.name;
    }

    public function get shopData() : Shop {
        if (_shop == null) {
            _shop = (_system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.SHOP ).findByPrimaryKey(this.shopID);
        }
        return _shop;
    }

    public static const _shopID:String = "shopID";//商店ID
    public static const _alreadyRefreshNum:String = "alreadyRefreshNum";//该商店已刷新次数
    public static const _time:String = "time";//对神秘商店来说表示刷新时间点（需要倒计时），对其他商店来说表示下一次刷新时间点
    public static const _shopItemInfos:String = "shopItemInfos";//商店商品信息列表

    private var _shop:Shop;
}
}
