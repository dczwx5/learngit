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


public class CPeak1v1MatchData extends CObjectData {

    public function CPeak1v1MatchData() {
        this.addChild(CCommonHeroData);
    }

    public override function updateDataByData(data:Object) : void {
        super.updateDataByData(data);

        if (data.hasOwnProperty(_enemyFightHero)) {
            enemyHeroData.updateDataByData(data[_enemyFightHero]);
        }
    }

    public function get myLocation() : int { return _data[_myLocation]; } // 1 == 1P, 2 = 2P
    public function get instanceID() : int { return _data[_instanceID]; } // 副本ID
    public function get enemyRoleID() : int { return _data[_enemyRoleID]; } // 对手角色ID
    public function get enemyName() : String { return _data[_enemyName]; } // 对手战队名
    public function get enemyBattleValue() : String { return _data[_enemyBattleValue]; } // 对手战队战斗力
    public function get enemyLevel() : int { return _data[_enemyLevel]; } // 对手等级
    public function get enemyScore() : int { return _data[_enemyScore]; } // 对手等级

    public function get enemyHeroData()  : CCommonHeroData { return this.getChild(0) as CCommonHeroData; } // 对手出战格斗家


    public static const _myLocation:String = "myLocation";
    public static const _instanceID:String = "instanceID";
    public static const _enemyRoleID:String = "enemyRoleID";
    public static const _enemyLevel:String = "enemyLevel";
    public static const _enemyName:String = "enemyName";
    public static const _enemyBattleValue:String = "enemyBattleValue";
    public static const _enemyFightHero:String = "enemyFightHero";
    public static const _enemyScore:String = "enemyScore";

}
}
