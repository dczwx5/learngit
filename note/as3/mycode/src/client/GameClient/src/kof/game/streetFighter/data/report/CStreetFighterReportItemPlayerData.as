//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/21.
 */
package kof.game.streetFighter.data.report {

import kof.data.CObjectData;
import kof.game.player.data.CPlayerHeroData;

public class CStreetFighterReportItemPlayerData extends CObjectData {
    public function CStreetFighterReportItemPlayerData() {

    }

    public override function updateDataByData(data:Object) : void {
        super.updateDataByData(data);
        if (!heroData) this.addChild(CPlayerHeroData);
        heroData.updateDataByData(data["enemyFightHero"]);
    }

    [Inline]
    public function get playerUID() : int { return _data["enemyRoleID"]; }
    [Inline]
    public function get enemyRoleID() : Number { return _data["enemyRoleID"]; }
    [Inline]
    public function get name() : String { return _data["enemyName"]; }
    [Inline]
    public function get level() : int { return _data["enemyLevel"]; }
    [Inline]
    public function get peakLevel() : int { return _data["enemyScoreLevelID"]; }

    [Inline]
    public function get heroData() : CPlayerHeroData { return getChild(0) as CPlayerHeroData; }
}
}
