//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/23.
 */
package kof.game.peak1v1.data {

import kof.data.CObjectListData;


public class CPeak1v1RankingListData extends CObjectListData {

    public function CPeak1v1RankingListData() {
        super (CPeak1v1RankingData, null);
    }

    public override function get needSync() : Boolean {
        return true;
    }


}
}
