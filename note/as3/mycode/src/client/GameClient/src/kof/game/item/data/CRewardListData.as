//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/1.
 */
package kof.game.item.data {

import kof.data.CObjectListData;
import kof.game.currency.enum.ECurrencyType;
import kof.game.item.CItemData;

public class CRewardListData extends CObjectListData {
    public function CRewardListData() {
        super (CRewardData, CItemData.ITEM_ID);
    }

    public function getRewardString() : String {
        var list:Array = this.list;
        if (list == null || list.length == 0) return "";
        var array:Array = new Array(list.length);
        var i:int = 0;
        for each (var data:CRewardData in list) {
            array[i] = data.getString();
            i++;
        }
        return array.join(",");
    }
    public function get itemList() : Array {
        return _getListByType(CRewardData.TYPE_ITEM);
    }
    public function get currencyList() : Array {
        return _getListByType(CRewardData.TYPE_CURRENCY);
    }
    private function _getListByType(type:int) : Array {
        var ret:Array = new Array();
        var list:Array = this.list;

        for each (var data:CRewardData in list) {
            if (data.type == type) {
                ret.push(data);
            }
        }
        return ret;
    }
    public function get gold() : Number {
        return _getCurrencyByType(ECurrencyType.GOLD);
    }
    public function get bindDiamond() : int {
        return _getCurrencyByType(ECurrencyType.BIND_DIAMOND);
    }
    public function get diamond() : int {
        return _getCurrencyByType(ECurrencyType.DIAMOND);
    }
    public function get vit() : int {
        return _getCurrencyByType(ECurrencyType.VIT);
    }
    public function get honou() : int {
        return _getCurrencyByType(ECurrencyType.HONOR);
    }
    public function get trial() : int {
        return _getCurrencyByType(ECurrencyType.TRIAL);
    }
    public function get guild() : int {
        return _getCurrencyByType(ECurrencyType.GUILD);
    }
    public function get playerExp() : int {
        return _getCurrencyByType(ECurrencyType.PLAYER_EXP);
    }
    public function get heroExp() : int {
        return _getCurrencyByType(ECurrencyType.HERO_EXP);
    }
    public function get badgeExp() : int {
        return _getCurrencyByType(ECurrencyType.BADGE_EXP);
    }
    public function get secretExp() : int {
        return _getCurrencyByType(ECurrencyType.SECRET_EXP);
    }
    public function get skillPoint() : int {
        return _getCurrencyByType(ECurrencyType.SKILL_POINT);
    }

    private function _getCurrencyByType(currentType:int) : int {
        var isCurrencyType:Boolean = CRewardData.getTypeByID(currentType) == CRewardData.TYPE_CURRENCY;
        if (!isCurrencyType) return 0;
        var list:Array = this.list;

        for each (var data:CRewardData in list) {
            if (data.ID == currentType) {
                return data.num;
            }
        }
        return 0;
    }

    public function getByID(itemID:int) : CRewardData {
        return super.getByPrimary(itemID) as CRewardData;
    }
    public function getIndexByID(itemID:int) : int {
        return super.getIndexByPrimary(itemID);
    }


}
}
