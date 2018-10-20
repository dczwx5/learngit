//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/5/3.
 */
package kof.game.guildWar.data.fightActivation {

import kof.data.CObjectData;

/**
 * 公会战战斗激活数据
 */
public class CGuildWarBuffData extends CObjectData {

    public static const Hp:String = "hp";// 生命
    public static const Attack:String = "attack";// 攻击
    public static const Defense:String = "defense";// 防御
    public static const HpPercent:String = "hpPercent";// 生命万分值
    public static const AttackPercent:String = "attackPercent";// 攻击万分值
    public static const DefensePercent:String = "defensePercent";// 防御万分值
    public static const OrdinaryBuffCount:String = "ordinaryBuffCount";// 普通鼓舞次数
    public static const DiamondBuffCount:String = "diamondBuffCount";// 钻石鼓舞次数
    public static const BuffRecords:String = "buffRecords";// 激活日志

    public function CGuildWarBuffData()
    {
        super();
        addChild(CGuildWarBuffRecordListData);
    }

    override public function updateDataByData(value:Object):void
    {
        super.updateDataByData(value);

        if(recordData && value.hasOwnProperty(BuffRecords))
        {
            recordData.clearAll();
            recordData.updateDataByData(value[BuffRecords]);
        }
    }

    public function get hp() : int { return _data[Hp]; }
    public function get attack() : int { return _data[Attack]; }
    public function get defense() : int { return _data[Defense]; }
    public function get hpPercent() : int { return _data[HpPercent]; }
    public function get attackPercent() : int { return _data[AttackPercent]; }
    public function get defensePercent() : int { return _data[DefensePercent]; }
    public function get ordinaryBuffCount() : int { return _data[OrdinaryBuffCount]; }
    public function get diamondBuffCount() : int { return _data[DiamondBuffCount]; }

    public function set hp(value:int):void
    {
        _data[Hp] = value;
    }

    public function set attack(value:int):void
    {
        _data[Attack] = value;
    }

    public function set defense(value:int):void
    {
        _data[Defense] = value;
    }

    public function set hpPercent(value:int):void
    {
        _data[HpPercent] = value;
    }

    public function set attackPercent(value:int):void
    {
        _data[AttackPercent] = value;
    }

    public function set defensePercent(value:int):void
    {
        _data[DefensePercent] = value;
    }

    public function set ordinaryBuffCount(value:int):void
    {
        _data[OrdinaryBuffCount] = value;
    }

    public function set diamondBuffCount(value:int):void
    {
        _data[DiamondBuffCount] = value;
    }

    public function get recordData():CGuildWarBuffRecordListData
    {
        return getChild(0) as CGuildWarBuffRecordListData;
    }
}
}
