//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/10/11.
//----------------------------------------------------------------------
package kof.game.character.fight.skillcalc.hurt {

import QFLib.Foundation;
import QFLib.Interface.IDisposable;
import QFLib.Math.CMath;
import QFLib.Math.CMath;

import kof.game.character.CFacadeMediator;
import kof.game.character.fight.skill.property.ISkillItemProperty;

import kof.game.character.fight.skillcalc.CFightCalc;

import kof.game.character.property.CCharacterProperty;
import kof.game.character.state.CCharacterStateBoard;

import kof.game.core.CGameObject;
import kof.table.Damage;

/**
 * 外部调用伤害接口
 */
public class CFightHurtFacade implements IDisposable {

    public function CFightHurtFacade( owner : CGameObject ) {
        m_owner = owner;
        m_DamageFormula = new CFightDamageFormula( m_owner );
    }

    public function dispose() : void
    {
        if( m_DamageFormula )
            m_DamageFormula.dispose();
        m_DamageFormula = null;

        m_owner = null;
    }

    /**
     * 格挡伤害
     * @param target
     * @param damageInfo
     * @return
     */
    public function executeGuardHurt( target : CGameObject , damageInfo : Damage , skillUpInfo : ISkillItemProperty , revision : Number ) : int
    {
        var retDamage : int;

        //my property
        var skillDamageConst : int = 0;
        var skillDamageFactor : Number = 0.0;

        if( m_DamageFormula == null || target == null || !target.isRunning )
                return 0;
        //对自己计算属性
        calSelfFightProperty( target , damageInfo );

        if( damageInfo ) {
            skillDamageFactor = damageInfo.DamagePer / CFightProperty.TENTHOU ;
            skillDamageConst = damageInfo.BaseDamage;
        }else{
            Foundation.Log.logTraceMsg( "damageInfo should not be null in fact , pls check the hit-damageID data" );
        }

        if( skillUpInfo ){
            skillDamageFactor = skillDamageFactor + skillUpInfo.DamagePer /  CFightProperty.TENTHOU;
            skillDamageConst = skillDamageConst + skillUpInfo.BaseDamage;
        }

        var ctargetFP : CFightProperty = target.getComponentByClass( CFightProperty , true ) as CFightProperty;

        var pFightProperty : CFightProperty = this.pFightProperty;

        if( pFightProperty == null || ctargetFP == null ) return 0;

        //对目标计算属性
        calTargetFightProperty( target );

        var trueDamage : int = pFightProperty.fightTrueDamage;
        var trueResist : int = ctargetFP.fightTrueResist;
        {
            retDamage = m_DamageFormula.getGuardDamage( pFightProperty.fightBlockHurtChance, skillDamageFactor , ctargetFP.fightDefense , skillDamageConst , trueDamage , trueResist);
        }

        if( !isNaN(revision) )
                retDamage = int( retDamage * revision );

        hurtTarget( target , retDamage );

        return retDamage;
    }

    /**
     * 受伤状态计算
     * @param target
     * @param damageInfo
     * @return
     */
    public function executeHurt(  target : CGameObject , damageInfo : Damage , skillUpInfo : ISkillItemProperty , revision : Number ) : int
    {
        var finalDamage: int;
        if( target == null || !target.isRunning || m_DamageFormula == null)
                return 0;

        var pTargetStateBoard : CCharacterStateBoard = target.getComponentByClass( CCharacterStateBoard , true ) as CCharacterStateBoard;
        var realCritChance : Number;
        var boCounter : Boolean = false;
        var boCri : Boolean = true;

        if( null == pFightCal )
                return 0;

        var pFightPropertyFacade : CFightPropertyFacade = pFightCal.fightPropertyFacade;
        if( pFightPropertyFacade )
            realCritChance = pFightPropertyFacade.getFightCritChance( damageInfo , target );


        if( CMath.rand() <= realCritChance )
        {
            /** 暴击 */
            pTargetStateBoard.setValue( CCharacterStateBoard.CRITICAL_HIT , true );
            boCri = true;
        }
        else {
            pTargetStateBoard.setValue( CCharacterStateBoard.CRITICAL_HIT, false );
            boCri =false;
        }

        boCounter = pTargetStateBoard.getValue( CCharacterStateBoard.COUNTER );

        //my property
        var skillDamageConst : int = 0;
        var skillDamageFactor : Number = 0.0;

        if( damageInfo != null ) {
            skillDamageConst = damageInfo.BaseDamage;
            skillDamageFactor = damageInfo.DamagePer / CFightProperty.TENTHOU;
        }else{
            Foundation.Log.logTraceMsg( "damageInfo should not be null in fact , pls check the hit-damageID data" );
        }

        if( skillUpInfo ){
            skillDamageFactor = skillDamageFactor + skillUpInfo.DamagePer  / CFightProperty.TENTHOU ;
            skillDamageConst = skillDamageConst + skillUpInfo.BaseDamage;
        }
        calSelfFightProperty( target , damageInfo );
        //对目标计算属性
        calTargetFightProperty( target );
        calSelfCritCounterFightProperty( target , damageInfo , skillUpInfo);

        var ctargetFP : CFightProperty = target.getComponentByClass( CFightProperty , true ) as CFightProperty;
        if( !pFightPropertyFacade || !m_DamageFormula )
                return 0;

        var targetDefense : int = ctargetFP != null? ctargetFP.fightDefense : 0;
        var trueDamage : int = pFightProperty.fightTrueDamage;
        var trueResist : int = ctargetFP.fightTrueResist;

        if( boCri )
        {
            //计算暴击破招
            if( boCounter ) {
                finalDamage = m_DamageFormula.getCounterStrikeDamage( pFightProperty.fightExCounterAttack,
                        pFightProperty.fightCritHurtChance, skillDamageFactor, targetDefense , skillDamageConst , trueDamage , trueResist );
            }
            else
            {
                //计算暴击
                finalDamage = m_DamageFormula.getCritDamage( pFightProperty.fightCritHurtChance,
                        skillDamageFactor,targetDefense,  skillDamageConst , trueDamage , trueResist );
            }

        }else if( boCounter )
        {
            //计算破招
            finalDamage = m_DamageFormula.getCounterDamage( pFightProperty.fightExCounterAttack ,
                    skillDamageFactor , targetDefense , skillDamageConst ,trueDamage,trueResist );
        }
        else
        {
            //计算基础伤害
            finalDamage = m_DamageFormula.getBasicDamage(  skillDamageFactor, targetDefense , skillDamageConst , trueDamage , trueResist );
        }

        if( !isNaN(revision) )
             finalDamage = int( finalDamage * revision );
        //对目标计算属性
        hurtTarget( target , finalDamage );

        return finalDamage;
    }

    /**
     * 实际上算伤害要首先计算战中属性这一步 基本的属性值
     * @param target
     * @param damageInfo
     */
    private function calSelfFightProperty( target : CGameObject , damageInfo : Damage ) : void
    {
        if( !pFightCal )
                return;
        var pFightPropertyFacade : CFightPropertyFacade = pFightCal.fightPropertyFacade;
        //算实际伤害值
        pFightPropertyFacade.calFightAttack( damageInfo , target );
        pFightPropertyFacade.calFightDamageEnhance( target , damageInfo );
        pFightPropertyFacade.calFightDamageJobEnhance( target );
        pFightPropertyFacade.calFightBlockHurtChance( target );

    }

    private function calSelfCritCounterFightProperty( target : CGameObject , damageInfo : Damage , skillUpInfo : ISkillItemProperty) : void
    {
        var realCritHurtChance : Number;
        var realExCounterAttack : Number;

        var pFightPropertyFacade : CFightPropertyFacade = pFightCal.fightPropertyFacade;

        realCritHurtChance = pFightPropertyFacade.getFightCritHurtChance( damageInfo , target  );
        realExCounterAttack = pFightPropertyFacade.getFightExCounterAttack( damageInfo , target , skillUpInfo );
    }

    private function calTargetFightProperty( target : CGameObject ) : void
    {
        var targetRealDefense : int;
        var pTargetFightCalc : CFightCalc = target.getComponentByClass( CFightCalc , true  ) as CFightCalc;
        var pTargetPropertyFacade : CFightPropertyFacade = pTargetFightCalc.fightPropertyFacade;

        targetRealDefense = pTargetPropertyFacade.calFightDefense( m_owner );
    }

    /**
     *
     * @param target
     */
    private function hurtTarget( target : CGameObject , damage : int ) : void
    {
        var targetCharacterProperty : CCharacterProperty = target.getComponentByClass( CCharacterProperty , true ) as CCharacterProperty;
        var pMediator : CFacadeMediator = target.getComponentByClass( CFacadeMediator , true) as CFacadeMediator;

        //fixme 主角暂时不能死亡
//        if( pMediator.isPlayer && targetCharacterProperty.hp - damage <= 0 )
//                return ;

        targetCharacterProperty.HP = CMath.max( targetCharacterProperty.HP - damage , 0 );
    }

    final private function get pCharacterProperty() : CCharacterProperty
    {
        return m_owner.getComponentByClass( CCharacterProperty  , true ) as CCharacterProperty;
    }

    final private function get pFightProperty() : CFightProperty
    {
        return m_owner.getComponentByClass( CFightProperty , true ) as CFightProperty;
    }

    final private function get pFightCal( ) : CFightCalc
    {
        return m_owner.getComponentByClass( CFightCalc , true ) as CFightCalc;
    }

    private var m_owner : CGameObject;
    private var m_DamageFormula : CFightDamageFormula;

}
}
