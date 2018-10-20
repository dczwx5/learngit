//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/21.
 */
package kof.game.streetFighter.data.report {

import kof.data.CObjectData;
import kof.game.player.data.CPlayerHeroData;

public class CStreetFighterReportItemData extends CObjectData {
    public function CStreetFighterReportItemData() {

    }

    public override function updateDataByData(data:Object) : void {
        super.updateDataByData(data);
        if (!enemyData) addChild(CStreetFighterReportItemPlayerData);
        enemyData.updateDataByData(data);

        if (!selfData) addChild(CPlayerHeroData);
        selfData.updateDataByData(data["fightHero"]);
    }

    [Inline]
    public function get result() : int { return _data["result"]; } // 0：失败 1：成功 2: 战平 3：完胜
    [Inline]
    public function get updateScore() : int { return _data["updateScore"]; } // 变化的积分
    [Inline]
    public function get time() : Number { return _data[_time]; }

    // self data
    [Inline]
    public function get level() : int { return _data["level"]; } // 自己的等级
    [Inline]
    public function get name() : String { return _data["name"]; } // 战队名
    [Inline]
    public function get fightUUID() : String { return _data["fightUUID"]; } // 战斗的唯一id

    [Inline]
    public function get selfData() : CPlayerHeroData {
        return getChild(1) as CPlayerHeroData;
    }
    [Inline]
    public function get enemyData() : CStreetFighterReportItemPlayerData {
        return getChild(0) as CStreetFighterReportItemPlayerData;
    }

    public static const _time:String = "time";
}
}
