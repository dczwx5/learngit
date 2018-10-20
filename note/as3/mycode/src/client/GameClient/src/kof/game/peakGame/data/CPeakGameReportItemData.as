//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/7.
 */
package kof.game.peakGame.data {

import kof.data.CObjectData;
import kof.game.player.data.CPlayerHeroListData;

public class CPeakGameReportItemData extends CObjectData {
    public function CPeakGameReportItemData() {

    }

    public override function updateDataByData(data:Object) : void {
        super.updateDataByData(data);
        if (!enemyData) addChild(CPeakGameReportItemPlayerData);
        enemyData.updateDataByData(data);

        if (!selfData) addChild(CPlayerHeroListData);
        selfData.updateDataByData(data["fightHeros"]);
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
    public function get scoreLevelID() : int { return _data["scoreLevelID"]; } // 自己的段位

    public function get fightUUID() : String { return _data["fightUUID"]; } // 战斗的唯一id

    [Inline]
    public function get selfData() : CPlayerHeroListData {
        return getChild(1) as CPlayerHeroListData;
    }
    [Inline]
    public function get enemyData() : CPeakGameReportItemPlayerData {
        return getChild(0) as CPeakGameReportItemPlayerData;
    }

    public static const _time:String = "time";
}
}
