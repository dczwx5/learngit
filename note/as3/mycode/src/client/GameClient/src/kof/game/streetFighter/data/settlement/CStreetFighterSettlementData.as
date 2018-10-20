//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/21.
 */
package kof.game.streetFighter.data.settlement {

import kof.data.CObjectData;
import kof.game.common.hero.CCommonHeroData;

public class CStreetFighterSettlementData extends CObjectData {
    public function CStreetFighterSettlementData() {
        this.addChild(CCommonHeroData);
        this.addChild(CCommonHeroData);
    }

    public override function updateDataByData(data:Object) : void {
        super.updateDataByData(data);
        if (data.hasOwnProperty(_fightHero)) {
            myHeroData.updateDataByData(data[_fightHero]);
        }

        if (data.hasOwnProperty(_enemyFightHero)) {
            enemyHeroData.updateDataByData(data[_enemyFightHero]);
        }
    }

    [Inline]
    public function get result() : int { return _data["result"]; } // 结果 : 0 : 失败, 1 : 成功, 2 : 战平, 3 : 完胜
    [Inline]
    public function get updateScore() : int { return _data["updateScore"]; }

    [Inline]
    public function get enemyUpdateScore() : int { return _data["enemyUpdateScore"]; }
    [Inline]
    public function get enemyName() : String { return _data["enemyName"]; }

    public function get fightUUID() : String { return _data["fightUUID"]; } // 战斗的唯一id

    public function get myHeroData()  : CCommonHeroData { return this.getChild(0) as CCommonHeroData; } // 出战格斗家
    public function get enemyHeroData()  : CCommonHeroData { return this.getChild(1) as CCommonHeroData; } // 对手出战格斗家
    public static const _fightHero:String = "fightHero"; // 出战格斗家
    public static const _enemyFightHero:String = "enemyFightHero";

}
}
