//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/7.
 */
package kof.game.common.loading {

import kof.data.CObjectData;
import kof.game.player.data.CPlayerHeroListData;

public class CMatchData extends CObjectData {
    public function CMatchData() {
        this.addChild(CPlayerHeroListData);
    }

    public override function updateDataByData(data:Object) : void {
        super.updateDataByData(data);
        myProgress = 0;

        heroList.resetChild();
        if (data.hasOwnProperty("enemyFightHeros")) {
            heroList.updateDataByData(data["enemyFightHeros"]);
        }
    }

    [Inline]
    public function get instanceID() : int { return _data["instanceID"]; }
    [Inline]
    public function get enemyPlayerUID() : int { return _data["enemyRoleID"]; }
    [Inline]
    public function get enemyName() : String { return _data["enemyName"]; } // 战队名
    [Inline]
    public function get enemyLevel() : int { return _data["enemyLevel"]; }
    [Inline]
    public function get enemyIcon() : int { return _data["enemyIcon"]; } // 头像ID
    [Inline]
    public function get enemyScoreLevelID() : int {
        return _data["enemyScoreLevelID"];
    }

    [Inline]
    public function get matchData() : int { return _data["matchData"]; } // ?
    public function get isSelfP1() : Boolean { return _data["myLocation"] == 1; } // 我的位置, 1为1p, 2为2p
    [Inline]
    public function get scoreLevelID() : int {
        return _data["scoreLevelID"];
    }
    public var myProgress:int; // 我的加载进度

    [Inline]
    public function get heroList() : CPlayerHeroListData { return getChild(0) as CPlayerHeroListData; } // 对手英雄数据
}
}
