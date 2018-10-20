//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/23.
 */
package kof.game.peak1v1.data {

import kof.data.CObjectData;
import kof.game.common.hero.CCommonHeroData;


public class CPeak1v1ReportData extends CObjectData {

    public function CPeak1v1ReportData() {
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

    public function get round() : int { return _data[_round]; } // 第几轮
    public function get time() : Number { return _data[_time]; } // 时间
    public function get result() : int { return _data[_result]; } // 结果 0：失败 1：成功 2: 战平 3：完胜
    // 自己的
    public function get name() : String { return _data[_name]; } // 自己战队名
    public function get updateScore() : int { return _data[_updateScore]; } // 积分变化
    public function get fightHeroHp() : int { return _data[_fightHeroHp]; } // 出战格斗家开战时血量
    public function get fightHeroHpMax() : int { return _data[_fightHeroHpMax]; } // 出战格斗家总血量
    public function get myHeroData()  : CCommonHeroData { return this.getChild(0) as CCommonHeroData; }
    public function get alwaysWin() : int { return _data[_alwaysWin]; } // 连胜

    // 对手的
    public function get enemyRoleID() : int { return _data[_enemyRoleID]; } // 对手角色ID
    public function get enemyName() : String { return _data[_enemyName]; } // 对手战队名
    public function get enemyUpdateScore() : int { return _data[_enemyUpdateScore]; } // 对手积分变化
    public function get enemyFightHeroHp() : int { return _data[_enemyFightHeroHp]; } // 对手出战格斗家开战时血量
    public function get enemyFightHeroHpMax() : int { return _data[_enemyFightHeroHpMax]; } // 对手出战格斗家总血量
    public function get enemyHeroData()  : CCommonHeroData { return this.getChild(1) as CCommonHeroData; } // 对手出战格斗家
    public function get fightUUID() : String { return _data["fightUUID"]; } // 战斗的唯一id

    public static const _round:String = "round";
    public static const _time:String = "time";
    public static const _result:String = "result";
    public static const _name:String = "name";
    public static const _updateScore:String = "updateScore";
    public static const _fightHeroHp:String = "fightHeroHp";
    public static const _fightHeroHpMax:String = "fightHeroHpMax";
    public static const _fightHero:String = "fightHero";
    public static const _alwaysWin:String = "alwaysWin";


    public static const _enemyRoleID:String = "enemyRoleID";
    public static const _enemyName:String = "enemyName";
    public static const _enemyUpdateScore:String = "enemyUpdateScore";
    public static const _enemyFightHeroHp:String = "enemyFightHeroHp";
    public static const _enemyFightHeroHpMax:String = "enemyFightHeroHpMax";
    public static const _enemyFightHero:String = "enemyFightHero";

}
}
