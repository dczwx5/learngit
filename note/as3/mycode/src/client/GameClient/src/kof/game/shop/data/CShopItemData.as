//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Maniac on 2017/5/4.
 */
package kof.game.shop.data {

import QFLib.Foundation.CMap;

import kof.data.CObjectData;
import kof.data.KOFTableConstants;
import kof.table.ShopItem;

/**
 * 商店售卖物品信息
 */
public class CShopItemData extends CObjectData{

    public function CShopItemData() {
        super();
        _data = new CMap();
    }

    public function get shopItemID() : int { return _data[_shopItemID]; }
    public function get alreadyBuyNum() : int { return _data[_alreadyBuyNum]; }
    public function get currentSellNum() : int { return _data[_currentSellNum]; }
    public function get restoreTime() : Number { return _data[_restoreTime]; }
    public function get discount() : int { return _data[_discount]; }

    public function get shopItemData() : ShopItem {
        if (_shopItem == null) {
            _shopItem = _databaseSystem.getTable(KOFTableConstants.SHOP_ITEM).findByPrimaryKey(this.shopItemID);
        }
        return _shopItem;
    }

    public static const _shopItemID:String = "shopItemID";//商品ID
    public static const _alreadyBuyNum:String = "alreadyBuyNum";//该商品已购买数量
    public static const _currentSellNum:String = "currentSellNum";//该商品当前上架数量
    public static const _restoreTime:String = "restoreTime";//该商品下次恢复上架的时间点（0代表该商品不会恢复上架）
    public static const _discount:String = "discount";//该商品折扣 （1-9分别代表1折到9折, 0代表免费，10表示原价）

    private var _shopItem:ShopItem;
}
}
