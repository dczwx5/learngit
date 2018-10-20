//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/10/12.
//----------------------------------------------------------------------
package kof.game.character.fight.skillcalc.hurt {

import QFLib.Foundation;
import QFLib.Interface.IDisposable;
import QFLib.Math.CMath;

import kof.game.character.property.CCharacterProperty;

import kof.game.core.CGameObject;

/**
 * 战斗伤害计算
 */
public class CFightDamageFormula implements IDisposable {

    public function CFightDamageFormula( owner : CGameObject ) {
        m_owner = owner;
    }

    public function dispose() : void {
        m_owner = null;
    }

    /**
     *
     * @param increaseFactor  g攻方技能伤害万分比
     * * @param decreaseDefense 防守方实际防御值
     * @param increaseConst //攻方技能伤害固定值
     * @return 基础伤害 = max[原始伤害 ，最小伤害值]
     */
    public function getBasicDamage( increaseFactor : Number, decreaseDefense : int, increaseConst : int ,
                                    trueDamage : int , trueResist : int ) : int {
        var rawDamage : Number = calRawDamage( increaseFactor, decreaseDefense, increaseConst , trueDamage , trueResist );
        return CMath.max( int( rawDamage ), minAttack );
    }

    /**
     * @param decreasefightBlockHurtChance 实际格挡减伤万分比
     * @param increaseFactor
     * @param decreaseDefense
     * @param increaseConst
     * @return 格挡伤害 = max[(原始伤害 * (1 - 实际格挡减伤万分比)，最小伤害值)]
     */
    public function getGuardDamage( decreasefightBlockHurtChance : Number,
                                    increaseFactor : Number, decreaseDefense : int, increaseConst : int , trueDamage : int , trueResist : int ) : int {
        var rawDamage : Number = calRawDamage( increaseFactor, decreaseDefense, increaseConst , trueDamage , trueResist );
        CONFIG::debug{
            Foundation.Log.logTraceMsg( "GuardDamage = " + CMath.max( int( rawDamage * ( 1 - decreasefightBlockHurtChance ) ), minAttack ) +
                    " Formula = " +
                    rawDamage + "*" + "(" + 1 + "-" + decreasefightBlockHurtChance + ") " );
        }
        return CMath.max( int( rawDamage * ( 1 - decreasefightBlockHurtChance ) ), minAttack );
    }

    /**
     *
     * @param increaseCounterFactor 实际破招伤害万分比
     * @param increaseFactor  g攻方技能伤害万分比
     * * @param decreaseDefense 防守方实际防御值
     * @param increaseConst //攻方技能伤害固定值
     * @return  破招伤害 = max[原始伤害 * （1+实际破招伤害万分比） ，最小伤害值]
     */
    public function getCounterDamage( increaseCounterFactor : Number,
                                      increaseFactor : Number, decreaseDefense : int, increaseConst : int ,
                                      trueDamage : int , trueResist : int ) : int {
        var rawDamage : Number = calRawDamage( increaseFactor, decreaseDefense, increaseConst , trueDamage , trueResist  );

        CONFIG::debug{
            Foundation.Log.logTraceMsg( "CounterDamage = " + CMath.max( int( rawDamage * ( 1 + increaseCounterFactor) ), minAttack ) +
                    " Formula = " + rawDamage + "*" + "(" + 1 + "+" + increaseCounterFactor + ")" );
        }

        return CMath.max( int( rawDamage * ( 1 + increaseCounterFactor) ), minAttack );
    }

    /**
     *
     * @param increaseStrikeFactor  实际暴击伤害万分比
     * @param increaseFactor  攻方技能伤害万分比
     * * @param decreaseDefense 防守方实际防御值
     * @param increaseConst 攻方技能伤害固定值
     * @return 暴击伤害 = max[原始伤害 * （1+实际暴击伤害万分比 ），最小伤害值]
     */
    public function getCritDamage( increaseStrikeFactor : Number, increaseFactor : Number, decreaseDefense : int, increaseConst : int ,
                                   trueDamage : int , trueResist : int ) : int {
        var rawDamage : Number = calRawDamage( increaseFactor, decreaseDefense, increaseConst , trueDamage , trueResist );
        CONFIG::debug{
            Foundation.Log.logTraceMsg( "CritDamage : " + CMath.max( int( rawDamage * ( 1 + increaseStrikeFactor ) ), minAttack ) +
                    " Formula = " + rawDamage + "*(" + 1 + "+" + increaseStrikeFactor + ")" );
        }
        return CMath.max( int( rawDamage * ( 1 + increaseStrikeFactor ) ), minAttack );
    }

    /**
     *
     * @param increaseCounterFactor  实际破招伤害万分比
     * @param increaseStrikeFactor  实际暴击伤害万分比
     * @param increaseFactor  攻方技能伤害万分比
     * * @param decreaseDefense 防守方实际防御值
     * @param increaseConst 攻方技能伤害固定值
     * @return 暴击破招伤害 = max[原始伤害 * （1+实际暴击伤害万分比） * （1+实际破招伤害万分比） ，最小伤害值]
     */
    public function getCounterStrikeDamage( increaseCounterFactor : Number, increaseStrikeFactor : Number,
                                            increaseFactor : Number, decreaseDefense : int, increaseConst : int ,
                                            trueDamage : int , trueResist : int ) : int {
        var rawDamage : Number = calRawDamage( increaseFactor, decreaseDefense, increaseConst , trueDamage , trueResist );

        CONFIG::debug{
            Foundation.Log.logTraceMsg( "CounterStrikeDamage : " + CMath.max( int( rawDamage * ( 1 + increaseCounterFactor ) * ( 1 + increaseStrikeFactor ) ), minAttack ) +
                    " Formula : " + rawDamage + "* (" + 1 + "+" + increaseCounterFactor + ") * (" + 1 + "+" + increaseStrikeFactor + " )" );
        }
        return CMath.max( int( rawDamage * ( 1 + increaseCounterFactor ) * ( 1 + increaseStrikeFactor ) ), minAttack );
    }

    /**
     *
     * @param increaseFactor  攻方技能伤害万分比
     * * @param decreaseDefense 防守方实际防御值
     * @param increaseConst //攻方技能伤害固定值
     * @return 原始伤害=[实际攻击值 - 实际防御值] * 攻方技能伤害万分比  *（1 + 实际伤害加成万分比）*（1 + 职业克制伤害加成万分比）+ 攻方技能固定伤害
     */
    private function calRawDamage( increaseFactor : Number, decreaseDefense : int, increaseConst : int ,
                                    trueDamage : int , trueResist : int ) : Number {
        var attack : int = fightProperty.fightDamage;
        var attackChance : Number = fightProperty.fightDamageEnhance;
        var jobChance : Number = fightProperty.fightDamageJobEnhance;

        CONFIG::debug{
            Foundation.Log.logTraceMsg(
                "Ret =  " +
                (( 0.1 * attack + 0.9 * CMath.max( attack - (10 / 9 * decreaseDefense), 0 )) *
                ( MULFACTOR * increaseFactor) / MULFACTOR *
                ( MULFACTOR * ( 1.0 + attackChance )) / MULFACTOR *
                ( MULFACTOR * (1.0 + jobChance) ) / MULFACTOR + increaseConst) +
                "   RawDamage : ("+  0.1 + "*" +  attack + " + 0.9" + "*" +  "CMath.max( " + attack +  "-" +  "(10 / 9 *" +  decreaseDefense + "), 0 ))" + "*"
                + "(" +  MULFACTOR + "*" +  increaseFactor + ") /" +  MULFACTOR + "*(" +  MULFACTOR + "*" +  "( 1.0 " + "+" +  attackChance + ")) /" +  MULFACTOR +"*("
                +  MULFACTOR + " * (1.0 +" +  jobChance + ") ) /" +  MULFACTOR + "+" +  increaseConst
            )
            ;
        }

        return (( 0.1 * attack + 0.9 * CMath.max( attack - (10 / 9 * decreaseDefense), 0 ) ) *
                ( MULFACTOR * ( 1.0 + attackChance )) / MULFACTOR *
                ( MULFACTOR * (1.0 + jobChance) ) / MULFACTOR + CMath.max(trueDamage - trueResist , 0 ) ) * ( MULFACTOR * increaseFactor) / MULFACTOR  + increaseConst;
    }

    final private function get characterProperty() : CCharacterProperty {
        return m_owner.getComponentByClass( CCharacterProperty, true ) as CCharacterProperty;
    }

    final private function get minAttack() : int {
        return characterProperty.minAttack;
    }

    final private function get fightProperty() : CFightProperty {
        return m_owner.getComponentByClass( CFightProperty, true ) as CFightProperty;
    }

    private var m_owner : CGameObject;
    private const MULFACTOR : int = 1000; //确保计算不会出现小数点计算
}
}
