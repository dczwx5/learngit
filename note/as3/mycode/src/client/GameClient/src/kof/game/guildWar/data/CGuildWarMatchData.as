//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/4/25.
 */
package kof.game.guildWar.data {

import kof.data.CObjectData;

public class CGuildWarMatchData extends CObjectData {

    public static const MyLocation:String = "myLocation";// 1 == 1P, 2 = 2P
    public static const MyScore:String = "myScore";// 我的积分
    public static const InstanceID:String = "instanceID";// 副本ID
    public static const EnemyRoleID:String = "enemyRoleID";// 对手角色ID
    public static const EnemyName:String = "enemyName";// 对手战队名
    public static const EnemyBattleValue:String = "enemyBattleValue";// 对手战队战斗力
    public static const EnemyLevel:String = "enemyLevel";// 对手等级
    public static const EnemyScore:String = "enemyScore";// 对手积分
    public static const EnemyFightHero:String = "enemyFightHero";// 对手出战格斗家

    public function CGuildWarMatchData()
    {
        super();

        addChild(CEnemyFightHeroData);
    }

    public function get myLocation() : int { return _data[MyLocation]; }
    public function get myScore() : int { return _data[MyScore]; }
    public function get instanceID() : int { return _data[InstanceID]; }
    public function get enemyRoleID() : Number { return _data[EnemyRoleID]; }
    public function get enemyName() : String { return _data[EnemyName]; }
    public function get enemyBattleValue() : Number { return _data[EnemyBattleValue]; }
    public function get enemyLevel() : int { return _data[EnemyLevel]; }
    public function get enemyScore() : int { return _data[EnemyScore]; }
    public function get enemyFightHero() : Object { return _data[EnemyFightHero]; }

    override public function updateDataByData(value:Object):void
    {
        super.updateDataByData(value);

        if(enemyFightHero)
        {
            updateEnemyFightHero(enemyFightHero);
        }
    }

    public function set myLocation(value:int):void
    {
        _data[MyLocation] = value;
    }

    public function set myScore(value:int):void
    {
        _data[MyScore] = value;
    }

    public function set instanceID(value:int):void
    {
        _data[InstanceID] = value;
    }

    public function set enemyRoleID(value:Number):void
    {
        _data[EnemyRoleID] = value;
    }

    public function set enemyName(value:String):void
    {
        _data[EnemyName] = value;
    }

    public function set enemyBattleValue(value:Number):void
    {
        _data[EnemyBattleValue] = value;
    }

    public function set enemyLevel(value:int):void
    {
        _data[EnemyLevel] = value;
    }

    public function set enemyScore(value:int):void
    {
        _data[EnemyScore] = value;
    }

    public function set enemyFightHero(value:Object):void
    {
        _data[EnemyFightHero] = value;
    }

    public function updateEnemyFightHero(data:Object):void
    {
        enemyHeroData.updateDataByData(data);
    }

    public function get enemyHeroData():CEnemyFightHeroData
    {
        return this.getChild(0) as CEnemyFightHeroData;
    }

}
}
