//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/5/17.
 */
package kof.game.cultivate.data.cultivate {

import kof.data.CObjectListData;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;

public class CCultivateLevelDefenderListData extends CObjectListData {
    public function CCultivateLevelDefenderListData() {
        super (CCultivateLevelDefenderData, null);
    }

    public function get battleValue() : int {
        var ret:int = 0;
        for each (var data:CCultivateLevelDefenderData in list) {
            ret += data.battleValue;
        }
        return ret;
    }
//    public function getDefender(monsterID:int) : CCultivateLevelDefenderData {
//        return this.getByPrimary(monsterID) as CCultivateLevelDefenderData;
//    }
    // 不以monsterID来找对象, 而且根据关卡刷怪点ID来取, 服务器会保存0,1,2ID刷点怪的血, entityID对应3个点的索引
//    public function getByIndex(index:int) : CCultivateLevelDefenderData {
//        return this.getByKey(CCultivateLevelDefenderData._entityID, index) as CCultivateLevelDefenderData;
//
//    }
}
}
