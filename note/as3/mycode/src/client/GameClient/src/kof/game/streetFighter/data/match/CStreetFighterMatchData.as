//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/21.
 */
package kof.game.streetFighter.data.match {

import kof.game.common.loading.CMatchData;
import kof.game.streetFighter.data.CStreetFighterHeroHpListData;

public class CStreetFighterMatchData extends CMatchData {
    public function CStreetFighterMatchData() {
    }

    public override function updateDataByData(data:Object) : void {
        super.updateDataByData(data);
        if (enmeyHeroHpList == null) {
            this.addChild(CStreetFighterHeroHpListData);
        }
        enmeyHeroHpList.resetChild();
        enmeyHeroHpList.updateDataByData(data["enemyHeroStates"]);
    }

    [Inline]
    public function get enemyBattleValue() : int { return _data["enemyBattleValue"]; }

    [Inline]
    public function get enemyScore() : int { return _data["enemyScore"]; } // 对手积分

    [Inline]
    public function get enmeyHeroHpList() : CStreetFighterHeroHpListData { return getChild(1) as CStreetFighterHeroHpListData; } // 对手英雄血量数据
}
}
