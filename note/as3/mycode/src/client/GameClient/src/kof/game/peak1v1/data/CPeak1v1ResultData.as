//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/25.
 */
package kof.game.peak1v1.data {

import kof.data.CObjectData;
import kof.game.common.hero.CCommonHeroData;
import kof.game.item.data.CRewardListData;


public class CPeak1v1ResultData extends CObjectData {

    public function CPeak1v1ResultData() {
        this.addChild(CCommonHeroData);
        this.addChild(CCommonHeroData);
        this.addChild(CRewardListData);
    }

    public override function updateDataByData(data:Object) : void {
        super.updateDataByData(data);
        if (data.hasOwnProperty(_fightHero)) {
            myHeroData.updateDataByData(data[_fightHero]);
        }

        if (data.hasOwnProperty(_enemyFightHero)) {
            enemyHeroData.updateDataByData(data[_enemyFightHero]);
        }

        if (data.hasOwnProperty(_rewards)) {
            rewardData.updateDataByData(data[_rewards]);
        }
    }

    public function get result() : int { return _data[_result]; } // 结果 0：失败 1：成功 2: 战平 3：完胜
    // 自己的
    public function get alwaysWinScore() : int { return _data[_alwaysWinScore]; } // 连胜积分
    public function get rebelKillScore() : int { return _data[_rebelKillScore]; } // 反杀积分
    public function get damageScore() : int { return _data[_damageScore]; } // 伤害积分
    public function get updateScore() : int { return _data[_updateScore]; } // 积分变化
    public function get myHeroData()  : CCommonHeroData { return this.getChild(0) as CCommonHeroData; } // 出战格斗家

    // 对手的
    public function get enemyName() : String { return _data[_enemyName]; } // 对手战队名
    public function get enemyUpdateScore() : int { return _data[_enemyUpdateScore]; } // 对手积分变化
    public function get enemyHeroData()  : CCommonHeroData { return this.getChild(1) as CCommonHeroData; } // 对手出战格斗家

    public function get rewardData()  : CRewardListData { return this.getChild(2) as CRewardListData; } // 奖励

    public function get fightUUID() : String { return _data["fightUUID"]; } // 战斗的唯一id


    public static const _result:String = "result";
    public static const _alwaysWinScore:String = "alwaysWinScore";
    public static const _rebelKillScore:String = "rebelKillScore";
    public static const _damageScore:String = "damageScore";
    public static const _updateScore:String = "updateScore";

    public static const _rewards:String = "rewards";
    public static const _fightHero:String = "fightHero"; // 出战格斗家

    public static const _enemyUpdateScore:String = "enemyUpdateScore";
    public static const _enemyFightHero:String = "enemyFightHero";
    public static const _enemyName:String = "enemyName";

}
}
