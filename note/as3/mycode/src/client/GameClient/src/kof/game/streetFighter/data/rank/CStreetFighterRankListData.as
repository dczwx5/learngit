//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/21.
 */
package kof.game.streetFighter.data.rank {

import kof.data.CObjectListData;

public class CStreetFighterRankListData extends CObjectListData {
    public function CStreetFighterRankListData() {
        super (CStreetFighterRankItemData, CStreetFighterRankItemData._playerUID);
    }

    public function getByRanking(ranking:int) : CStreetFighterRankItemData {
        return this.getByKey(CStreetFighterRankItemData._ranking, ranking) as CStreetFighterRankItemData;
    }

}
}
