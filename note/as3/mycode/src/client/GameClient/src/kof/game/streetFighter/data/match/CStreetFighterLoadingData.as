//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/21.
 */
package kof.game.streetFighter.data.match {

import kof.game.common.loading.CMatchData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.streetFighter.data.CStreetFighterHeroHpData;

// 进入loading时的数据
public class CStreetFighterLoadingData extends CMatchData {
    public function CStreetFighterLoadingData() {
        this.addChild(CStreetFighterHeroHpData);
        this.addChild(CPlayerHeroData);
    }

    public override function updateDataByData(data:Object) : void {
        super.updateDataByData(data);
        enemyHeroHpData.clearAll();
        enemyHeroHpData.updateDataByData(data["enemyFightHeroHP"]);
        enemyHeroData.clearAll();
        enemyHeroData.updateDataByData(data["enemyFightHero"]);
    }
    [Inline]
    public function get fightHeroID() : int { return _data["fightHeroID"]; } // 玩家自己出战格斗家ID

    [Inline]
    public function get enemyBattleValue() : int { return _data["enemyBattleValue"]; }

    [Inline]
    public function get enemyScore() : int { return _data["enemyScore"]; } // 对手积分

    [Inline]
    public function get enemyHeroHpData() : CStreetFighterHeroHpData { return getChild(1) as CStreetFighterHeroHpData; } // 对手英雄血量数据
    [Inline]
    public function get enemyHeroData() : CPlayerHeroData { return getChild(2) as CPlayerHeroData; } // 对手英雄
}
}
