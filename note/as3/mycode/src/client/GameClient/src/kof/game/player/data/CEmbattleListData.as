//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/15.
 */
package kof.game.player.data {

import QFLib.Utils.ArrayUtil;

import kof.data.CObjectListData;

public class CEmbattleListData extends CObjectListData {
    public function CEmbattleListData() {
        super (CEmbattleData, CEmbattleData.POSITION);
    }
    public override function updateDataByData(data:Object) : void {
        _type = data[TYPE];
        resetChild();
        super.updateDataByData(data["embattleList"]);
    }

    public function removeByPos(pos:int) : void {
        this.removeByPrimary(pos);
    }

    // pos : 1开始
    public function getByPos(pos:int) : CEmbattleData {
        return getByPrimary(pos) as CEmbattleData;
    }
    public function getIndexByPos(pos:int) : int {
        return getIndexByPrimary(pos);
    }
    public function getIndexByHero(heroID:int) : int {
        return ArrayUtil.findItemByProp(list, CEmbattleData.HERO_ID, heroID);
    }
    public function getPosByHero(heroID:int) : int {
        var idx:int = ArrayUtil.findItemByProp(list, CEmbattleData.HERO_ID, heroID);
        if (idx == -1) return -1;
        return (list[idx] as CEmbattleData).position;
    }
    public function Set(uid:int, heroID:int, pos:int) : void {
        var objData:Object = CEmbattleData.getCreateData(uid, heroID, pos);
        this.adddData(objData);
    }
    public function isEmpty() : Boolean {
        if (childList == null) return true;
        if (childList.length == 0) return true;
        return false;
    }

    public function export() : Array {
        if (!list || list.length == 0) {
            return [];
        }
        var ret:Array = new Array();
        for each (var emData:CEmbattleData in list) {
            if (emData) {
                ret[ret.length] = emData.export();
            }
        }
        return ret;
    }
    public function getHeroCount() : int {
        var count:int = 0;
        for each (var emData:CEmbattleData in list) {
            if (emData && emData.prosession > 0) {
                count++;
            }
        }
        return count;
    }

    public function get type() : int { return _type; }
    private var _type:int;
    public static const TYPE:String = "type";
}
}
