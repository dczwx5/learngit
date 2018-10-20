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

public class CPeakGameRankItemData extends CObjectData {
    public function CPeakGameRankItemData() {
        this.addChild(CPlayerHeroListData);
    }

    public override function updateDataByData(data:Object) : void {
        super.updateDataByData(data);
        heroList.updateDataByData(data["fightHeros"]);
    }

    [Inline]
    public function get roleID() : int { return _data[_playerUID]; }
    public function get clubName() : String { return _data["clubName"]; }

    [Inline]
    public function get ranking() : int { return _data[_ranking]; }
    [Inline]
    public function get name() : String { return _data["name"]; }
    [Inline]
    public function get level() : int { return _data["level"]; }
    [Inline]
    public function get peakLevel() : int { return _data["scoreLevelID"]; }
    [Inline]
    public function get score() : int { return _data["score"]; }
    public function set score(v:int) : void { _data["score"] = v; }
    [Inline]
    public function get winPercent() : int { return _data["winPercent"]; } // 胜率
    public function get fightCount() : int { return _data["fightCount"]; } // 出战次数
    public function get winCount() : int { return _data["winCount"]; } // 胜利次数
    public function get battleValue() : int { return _data["battleValue"]; } // 战队战力 // 出战格斗家总战力
    [Inline]
    public function get winPercentString() : String { return (winPercent/100).toFixed(0) + "%"; } // 胜率串

    public function set ranking(v:int) : void {
        _data[_ranking] = v;
    }

    [Inline]
    public function get heroList() : CPlayerHeroListData { return getChild(0) as CPlayerHeroListData; }

    public static const _playerUID:String = "roleID";
    public static const _ranking:String = "ranking";

}
}
