//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/1.
 */

// 奖励
package kof.game.item.data {

import kof.framework.IDatabase;
import kof.game.currency.enum.ECurrencyType;
import kof.game.item.CItemData;

public class CRewardData extends CItemData {
    // ID
    // 货币 : 代表哪种货币
    // item : 代表哪个item
    public function CRewardData() {
    }
    public function get isItem() : Boolean {
        return getTypeByID(ID) == TYPE_ITEM;
    }
    public function get isCurrency() : Boolean {
        return getTypeByID(ID) == TYPE_CURRENCY;
    }
    public function get isGold() : Boolean {
        return ID == ECurrencyType.GOLD;
    }
    public function get isBindDiamod() : Boolean {
        return ID == ECurrencyType.BIND_DIAMOND;
    }
    public function get isDiamond() : Boolean {
        return ID == ECurrencyType.DIAMOND;
    }
    public function get isVit() : Boolean {
        return ID == ECurrencyType.VIT;
    }
    public function get isHonor() : Boolean {
        return ID == ECurrencyType.HONOR;
    }
    public function get isTrial() : Boolean {
        return ID == ECurrencyType.TRIAL;
    }
    public function get isGuild() : Boolean {
        return ID == ECurrencyType.GUILD;
    }
    public function get isPlayerExp() : Boolean {
        return ID == ECurrencyType.PLAYER_EXP;
    }
    public function get isHeroExp() : Boolean {
        return ID == ECurrencyType.HERO_EXP;
    }

    public static function buildData(rewardType:int, ID:int, num:Number) : Object {
        return {rewardType:rewardType, ID:ID, num:num};
    }
    public static function getTypeByID(ID:int) : int {
        if (ID < 100) return TYPE_CURRENCY;
        return TYPE_ITEM;
    }
    public static function CreateRewardData(rewardItemID:int, num:int, database:IDatabase) : CRewardData {
        var wardType:int = CRewardData.getTypeByID(rewardItemID);
        var wardData:Object = CRewardData.buildData(wardType, rewardItemID, num);
        var rewardData:CRewardData = new CRewardData();
        rewardData._databaseSystem = database;
        rewardData.updateDataByData(wardData);
        return rewardData;
    }

    public function getString() : String {
        return name + " : " + num;
    }

    public function get type() : int {
        return getTypeByID(ID);
    }
//    public function get num() : int { return _data[_num]; }
//    public static const _num:String = "num";
//
//    public function set num(value:int):void
//    {
//        _data[_num] = value;
//    }


    // 服务器有这个类型, 但是, 不用....使用type
    // public function get rewardType() : int { return _data["rewardType"]; }
    // 奖励类型 1:货币 2：物品
    public static const TYPE_CURRENCY:int = 1;
    public static const TYPE_ITEM:int = 2;

}
}
