//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/21.
 */
package kof.game.streetFighter.data.rank {

import kof.data.CObjectData;
import kof.framework.CAppSystem;
import kof.game.platform.data.CPlatformBaseData;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerHeroListData;

public class CStreetFighterRankItemData extends CObjectData {
    public function CStreetFighterRankItemData() {
        this.addChild(CPlayerHeroListData);
    }

    public override function updateDataByData(data:Object) : void {
        super.updateDataByData(data);
        heroList.updateDataByData(data["fightHeros"]);
    }

    public function get platformData() : CPlatformBaseData {
        if (!_platformData) {
            _platformData = ((_databaseSystem as CAppSystem).stage.getSystem(CPlayerSystem) as CPlayerSystem).createPlatfromData(platformInfo);
        }
        return _platformData;
    }
    private var _platformData:CPlatformBaseData;

    public function get platformInfo() : Object { return _data["platformInfo"]; }
    [Inline]
    public function get roleID() : int { return _data[_playerUID]; }
    [Inline]
    public function get vipLevel() : int { return _data["vipLevel"]; }
    [Inline]
    public function get historyHighScore() : int { return _data["historyHighScore"]; }
    [Inline]
    public function get ranking() : int { return _data[_ranking]; }
    [Inline]
    public function get name() : String { return _data["name"]; }
    [Inline]
    public function get score() : int { return _data["score"]; }
    public function set score(v:int) : void { _data["score"] = v; }
    [Inline]
    public function get fightCount() : int { return _data["fightCount"]; } // 出战次数
    public function get winCount() : int { return _data["winCount"]; } // 胜利次数
    public function get battleValue() : int { return _data["battleValue"]; } // 战队战力 // 出战格斗家总战力

    public function set ranking(v:int) : void {
        _data[_ranking] = v;
    }

    [Inline]
    public function get heroList() : CPlayerHeroListData { return getChild(0) as CPlayerHeroListData; }

    public static const _playerUID:String = "roleID";
    public static const _ranking:String = "ranking";

}
}
