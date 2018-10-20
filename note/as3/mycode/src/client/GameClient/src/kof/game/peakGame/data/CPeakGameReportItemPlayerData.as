//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/7.
 */
package kof.game.peakGame.data {

import kof.data.CObjectData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.data.CPlayerHeroListData;

public class CPeakGameReportItemPlayerData extends CObjectData {
    public function CPeakGameReportItemPlayerData() {

    }

    public override function updateDataByData(data:Object) : void {
        super.updateDataByData(data);
        if (!heroList) this.addChild(CPlayerHeroListData);
        heroList.updateDataByData(data["enemyFightHeros"]);
    }

    [Inline]
    public function get playerUID() : int { return _data["enemyRoleID"]; }
    [Inline]
    public function get name() : String { return _data["enemyName"]; }
    [Inline]
    public function get level() : int { return _data["enemyLevel"]; }
    [Inline]
    public function get peakLevel() : int { return _data["enemyScoreLevelID"]; }

    [Inline]
    public function get heroList() : CPlayerHeroListData { return getChild(0) as CPlayerHeroListData; }
}
}
