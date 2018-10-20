//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/7.
 */
package kof.game.peakGame.data {

import flash.utils.getTimer;

import kof.data.CObjectData;

public class CPeakGameRankData extends CObjectData {
    public function CPeakGameRankData() {

    }

    public override function updateDataByData(data:Object) : void {
        super.updateDataByData({type:data[_type], rankDatas:data[_rankDatas]});
        if (list == null) this.addChild(CPeakGameRankListData);
        list.updateDataByData(rankDatas);
    }

    [Inline]
    public function hasData() : Boolean {
        return list.list.length > 0;
    }

    public function getByPlayerUID(uid:int) : CPeakGameRankItemData {
        if (!list) {
            return null;
        }
        return list.getByPrimary(uid) as CPeakGameRankItemData;
    }
    public function setPlayerScore(uid:int, score:int) : void {
        var pRankItem:CPeakGameRankItemData = getByPlayerUID(uid);
        if (pRankItem) {
            pRankItem.score = score;
        }
    }
    public function sortVirtual() : void {
        if (!list) return ;
        if (list.list == null || list.list.length == 0) return ;

        var listData:Array = list.list;
        listData.sortOn("score", Array.NUMERIC | Array.DESCENDING); // 分数排名
        for (var i:int = 0; i < listData.length; i ++) {
            var pRankItem:CPeakGameRankItemData = listData[i];
            if (pRankItem) {
                pRankItem.ranking = (i+1);
            }
        }
    }
    public function getPlayerRanking(playerUID:int) : int {
        var pRankItem:CPeakGameRankItemData = getByPlayerUID(playerUID);
        if (!pRankItem) return -1;

        return pRankItem.ranking;
    }

    [Inline]
    public function get type() : int { return _data[_type]; } // 1 本服排行榜 ; 2 连服排行榜
    [Inline]
    public function get rankDatas() : Array { return _data[_rankDatas]; }

    public static const _rankDatas:String = "rankDatas";
    public static const _type:String = "type";
    public static const TYPE_ONE:int = 1;
    public static const TYPE_MULTI:int = 2;
    [Inline]
    public function get list() : CPeakGameRankListData {
        return this.getChild(0) as CPeakGameRankListData;
    }
    // private var _list:CPeakGameRankListData;

    private var _lastSyncTime:int;
    public override function sync() : void {
        _lastSyncTime = getTimer();
    }
    public override function get needSync() : Boolean {
        if (_lastSyncTime == 0) return true;
        return getTimer() - _lastSyncTime > 600000; // 10分钟 60000
    }

}
}
