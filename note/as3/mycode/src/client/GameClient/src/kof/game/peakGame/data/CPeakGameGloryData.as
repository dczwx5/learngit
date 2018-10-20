//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/29.
 */
package kof.game.peakGame.data {

import kof.data.CObjectData;

public class CPeakGameGloryData extends CObjectData {
    public function CPeakGameGloryData() {
    }

    public override function updateDataByData(data:Object) : void {
        this.resetChild();
        super.updateDataByData(data);
        if (rankList == null) this.addChild(CPeakGameRankListData);
        if (data.hasOwnProperty("rankDatas")) {
            rankList.updateDataByData(data["rankDatas"]);
        }
    }

    public function get season() : int { return _data[_season]; }
    public static const _season:String = "season";

    public function getByPlayerUID(uid:int) : CPeakGameRankItemData {
        return rankList.getByPrimary(uid) as CPeakGameRankItemData;
    }
    public function getByRanking(ranking:int) : CPeakGameRankItemData {
        return rankList.getByRanking(ranking);
    }
    [Inline]
    public function get rankList() : CPeakGameRankListData {
        return this.getChild(0) as CPeakGameRankListData;
    }
}
}
