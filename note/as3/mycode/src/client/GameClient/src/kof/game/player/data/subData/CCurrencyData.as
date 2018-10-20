//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/17.
 */
package kof.game.player.data.subData {

import kof.data.CObjectData;
import kof.game.currency.enum.ECurrencyType;

public class CCurrencyData extends CObjectData {
    public function CCurrencyData() {
    }

    //optional int64 gold        = 11; // 金币
    //optional int64 blueDiamond = 12; // 蓝钻
    //optional int64 purpleDiamond = 13; // 紫钻
    //optional int64 gloryCoin = 21; // 荣耀币
    //optional int64 practiceCoin = 22; // 试炼币
    public function get gold() : Number { return _rootData.data[_gold] ? _rootData.data[_gold] : 0; } // 金币
    public function get blueDiamond() : Number { return _rootData.data[_blueDiamond] ? _rootData.data[_blueDiamond] : 0; } // 钻石
    public function get purpleDiamond() : Number { return _rootData.data[_purpleDiamond] ? _rootData.data[_purpleDiamond] : 0; } // 绑钻

    public function get honorCoin() : Number { return _rootData.data[_gloryCoin] ? _rootData.data[_gloryCoin] : 0; } // 荣誉
    public function get fairPeakCoin() : Number { return _rootData.data[_fairPeakCoin] ? _rootData.data[_fairPeakCoin] : 0; } // 公平币
    public function get practiceCoin() : Number { return _rootData.data[_practiceCoin] ? _rootData.data[_practiceCoin] : 0; } // 格斗家奖章
    public function get talentPoint():Number {return _rootData.data[_talentPoint] ? _rootData.data[_talentPoint] : 0;} // 天赋
    public function get euro():Number {return _rootData.data[_euro] ? _rootData.data[_euro] : 0;}// 欧币
    public function get guidCoin():Number{return _rootData.data[_societyCoin] ? _rootData.data[_societyCoin] : 0;} // 公会币
    public function get arenaCoin():Number{return _rootData.data[_arenaCoin] ? _rootData.data[_arenaCoin] : 0;} // 竞技
    public function get eggCoin():Number{return _rootData.data[_eggCoin] ? _rootData.data[_eggCoin] : 0;} //
    public function get artifactEnergy():Number{return _rootData.data[_artifactEnergy] ? _rootData.data[_artifactEnergy] : 0;} // 神器能量
    public function get peak1v1Coin():Number{return _rootData.data[_peak1v1Coin] ? _rootData.data[_peak1v1Coin] : 0;} // 巅峰决赛币
    public function get exp():Number{return _rootData.data[_exp] ? _rootData.data[_exp] : 0;} // 经验
    public function get fightMedal():Number{return _rootData.data[_fightMedal] ? _rootData.data[_fightMedal] : 0;} // 大师奖章
    public function get masterMedal():Number{return _rootData.data[_masterMedal] ? _rootData.data[_masterMedal] : 0;} // 拳皇奖章
    public function get kofMedal():Number{return _rootData.data[_kofMedal] ? _rootData.data[_kofMedal] : 0;} // 试炼


    public function get buyGoldCount() : Number {
        return _rootData.data[ _buyGoldCount ];
    }

    public function getValueByType( type:int ) : Number {
        var value:Number = 0;
        switch( type )
        {
            case ECurrencyType.GOLD:
                value = this.gold;
                break;
            case ECurrencyType.BIND_DIAMOND:
                value = this.purpleDiamond;
                break;
            case ECurrencyType.DIAMOND:
                value = this.blueDiamond;
                break;
            case ECurrencyType.VIT:
                value = this.gold;
                break;
            case ECurrencyType.HONOR:
                value = this.honorCoin;
                break;
            case ECurrencyType.FAIR_PEAK_COIN:
                value = this.fairPeakCoin;
                break;
            case ECurrencyType.TRIAL:
                value = this.practiceCoin;
                break;
            case ECurrencyType.EURO:
                value = this.euro;
                break;
            case ECurrencyType.GUILD:
                value = this.guidCoin;
                break;
            case ECurrencyType.TALENT_POINT:
                value = this.talentPoint;
                break;
            case ECurrencyType.ARENA_COIN:
                value = this.arenaCoin;
                break;
            case ECurrencyType.EGG_COIN:
                value = this.eggCoin;
                break;
            case ECurrencyType.ARTIFACT_ENERGY:
                value = this.artifactEnergy;
                break;
            case ECurrencyType.PEAK_1V1_COIN:
                value = this.peak1v1Coin;
                break;

            case ECurrencyType.PLAYER_EXP:
                value = this.exp;
                break;
//            case ECurrencyType.HERO_EXP:
                break;
            case ECurrencyType.FIGHTMEDAL:
                value = this.fightMedal;
                break;
            case ECurrencyType.MASTERMEDAL:
                value = this.masterMedal;
                break;
            case ECurrencyType.KOFMEDAL:
                value = this.kofMedal;
                break;
            default:
                value = 0;
                break;
        }
        return value;
    }


    public static const _gold:String = "gold";
    public static const _blueDiamond:String = "blueDiamond";
    public static const _purpleDiamond:String = "purpleDiamond";

    public static const _gloryCoin:String = "gloryCoin";
    public static const _fairPeakCoin:String = "fairPeakCoin";

    public static const _practiceCoin:String = "practiceCoin";
    public static const _talentPoint:String = "talentPoint";
    public static const _euro:String = "euro";
    public static const _societyCoin:String = "societyCoin";
    public static const _arenaCoin:String = "arenaCoin";
    public static const _eggCoin:String = "eggCoin";

    public static const _artifactEnergy:String = "artifactEnergy";
    public static const _peak1v1Coin:String = "peak1v1Coin";

    public static const _buyGoldCount : String = "buyGoldCount";
    public static const _exp : String = "exp";

    public static const _fightMedal : String = "fightMedal";
    public static const _masterMedal : String = "masterMedal";
    public static const _kofMedal : String = "kofMedal";


}
}
