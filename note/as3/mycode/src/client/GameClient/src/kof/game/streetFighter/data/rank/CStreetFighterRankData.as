//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/21.
 */
package kof.game.streetFighter.data.rank {

import flash.utils.getTimer;
import kof.data.CObjectData;

public class CStreetFighterRankData extends CObjectData {
    public function CStreetFighterRankData() {

    }

    public override function updateDataByData(data:Object) : void {
        super.updateDataByData({rankDatas:data});
        if (list == null) this.addChild(CStreetFighterRankListData);
        list.updateDataByData(rankDatas);
    }

    [Inline]
    public function hasData() : Boolean {
        return list.list.length > 0;
    }

    public function getByPlayerUID(uid:int) : CStreetFighterRankItemData {
        if (!list) {
            return null;
        }
        return list.getByPrimary(uid) as CStreetFighterRankItemData;
    }
//    public function setPlayerScore(uid:int, score:int) : void {
//        var pRankItem:CStreetFighterRankItemData = getByPlayerUID(uid);
//        if (pRankItem) {
//            pRankItem.score = score;
//        }
//    }
//    public function sortVirtual() : void {
//        if (!list) return ;
//        if (list.list == null || list.list.length == 0) return ;
//
//        var listData:Array = list.list;
//        listData.sortOn("score", Array.NUMERIC | Array.DESCENDING); // 分数排名
//        for (var i:int = 0; i < listData.length; i ++) {
//            var pRankItem:CStreetFighterRankItemData = listData[i];
//            if (pRankItem) {
//                pRankItem.ranking = (i+1);
//            }
//        }
//    }
    public function getPlayerRanking(playerUID:int) : int {
        var pRankItem:CStreetFighterRankItemData = getByPlayerUID(playerUID);
        if (!pRankItem) return -1;

        return pRankItem.ranking;
    }

    [Inline]
    public function get rankDatas() : Array { return _data[_rankDatas]; }

    public static const _rankDatas:String = "rankDatas";
    [Inline]
    public function get list() : CStreetFighterRankListData {
        return this.getChild(0) as CStreetFighterRankListData;
    }

    private var _lastSyncTime:int;
    public override function sync() : void {
        _lastSyncTime = getTimer();
    }
    public override function get needSync() : Boolean {
        if (_lastSyncTime == 0) return true;
        return getTimer() - _lastSyncTime > 3000; // 10分钟 60000
    }

}
}
