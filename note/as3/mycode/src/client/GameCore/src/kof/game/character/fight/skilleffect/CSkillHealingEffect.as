//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/4/11.
//----------------------------------------------------------------------
package kof.game.character.fight.skilleffect {

import QFLib.Foundation.CMap;
import QFLib.Math.CAABBox3;
import QFLib.Math.CMath;
import QFLib.Math.CVector3;

import kof.game.character.CCharacterDataDescriptor;

import kof.game.character.audio.CAudioMediator;
import kof.game.character.collision.CCollisionComponent;
import kof.game.character.fight.CCharacterNetworkInput;
import kof.game.character.fight.buff.buffentity.IBuff;
import kof.game.character.fight.emitter.CMasterCompomnent;
import kof.game.character.fight.event.CFightTriggleEvent;

import kof.game.character.fight.skill.CHitStateInfo;

import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.fight.skill.CSkillDataBase;
import kof.game.character.fight.skill.CSkillUtil;
import kof.game.character.fight.skillcalc.CFightCalc;
import kof.game.character.fight.skillcalc.hurt.CFightDamageComponent;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.character.fight.sync.CCharacterSyncBoard;
import kof.game.character.fx.CFXMediator;
import kof.game.character.property.CCharacterProperty;
import kof.game.character.property.CMissileProperty;
import kof.game.character.scripts.CFightFloatSprite;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.core.CGameObject;

import kof.table.Healing;
import kof.table.Skill.EEffectType;

public class CSkillHealingEffect extends CAbstractSkillEffect {
    public function CSkillHealingEffect( id : int, startFrame : Number, hitEvent : String, etype : int, des : String = "" ) {
        super( id, startFrame, hitEvent, etype, des );
    }

    override public function initData( ... arg ) : void {
        super.initData( null );
        m_theHealData = CSkillCaster.skillDB.getHealingEffectByID( effectID ) as Healing;
        m_targetDic = new CMap( true );
    }

    override public function dispose() : void {
        if ( m_targetDic )
            m_targetDic.clear();
        m_targetDic = null;
    }

    override public function lastUpdate( delta : Number ) : void {

    }

    override public function doStart() : void {
        super.doStart();
    }

    override public function doRunning( delta : Number ) : void {
        super.doRunning( delta );
        _updateHealingElapseTime( delta );
        var healTargets : Array = _findTargets();
        if ( !healTargets || !healTargets.length )
            return;

        var maxCount : int = m_theHealData.TargetNum > healTargets.length ? healTargets.length : m_theHealData.TargetNum;
        healTargets = healTargets.splice( 0, maxCount );
        var hitInfo : CHitStateInfo;
        for each( var target : CGameObject in healTargets ) {
            hitInfo = _addToTargetDic( target );
        }

        var healInfos : Array = _executeHeals( healTargets );
//      if ( resTarget != null && resTarget.length != 0 ) {
//           _syncUpdateToSev( resTarget );
//      }

        if ( healInfos != null && healInfos.length != 0 ) {
            _syncHealEffectToSev( healInfos );
        }
    }

    override public function doEnd() : void {
        super.doEnd();
    }

    private function _executeHeals( collisedTargets : Array ) : Array {
        var healTargets : Array = [];
        var hitInfo : CHitStateInfo;
        var healInfo : Object;
        var nextHealCount : int;
        var healCount : int;
        var currentHP : int;
        for each ( var target : CGameObject in collisedTargets ) {
            hitInfo = m_targetDic.find( target );
            healCount = hitInfo.hitCount;
            if ( !hitInfo.boNotReachMaxHit( m_theHealData.TimesAtOneTarget ) )
                continue;
            nextHealCount = int( hitInfo.elapsTime / ( m_theHealData.EffectSpan * CSkillDataBase.TIME_IN_ONEFRAME ) ) + 1 - healCount;
            for ( var healIndex : int = 0; healIndex < nextHealCount && healIndex < m_theHealData.TimesAtOneTarget; healIndex++ ) {
                healInfo = _healTarget( target, m_theHealData );
            }

            var pCharacterProperty : CCharacterProperty = target.getComponentByClass( CCharacterProperty, true ) as CCharacterProperty;
            if ( pCharacterProperty )
                currentHP = pCharacterProperty.HP;
            if ( healInfo ) {
                healInfo.cnt = nextHealCount;
                healInfo.ID = CCharacterDataDescriptor.getID( target.data );
                healInfo.type = CCharacterDataDescriptor.getType( target.data );
                healInfo[ CCharacterSyncBoard.CURRENT_HP ] = currentHP;

                hitInfo.hitCount = healCount + nextHealCount;
                hitInfo.beingHitted = true;

                healTargets.push( healInfo );
            }
        }

        return healTargets;
    }

    private function _syncHealEffectToSev( healInfos : Array ) : void {

        var pNetOutputComp : CCharacterNetworkInput = owner.getComponentByClass( CCharacterNetworkInput, true ) as CCharacterNetworkInput;
        var pFightTrigger : CCharacterFightTriggle = owner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
        if ( pFightTrigger != null ) {
            var aliasSkillID : int;
            var missileSeq : Number;
            var pSkillCaster : CSkillCaster = owner.getComponentByClass( CSkillCaster, true ) as CSkillCaster;
            if ( pSkillCaster )
                aliasSkillID = pSkillCaster.skillID;
            var masterComp : CMasterCompomnent = owner.getComponentByClass( CMasterCompomnent, true ) as CMasterCompomnent;
            if ( masterComp ) {
                aliasSkillID = masterComp.aliasSkillID;
                var pPropery : CMissileProperty = owner.getComponentByClass( CMissileProperty, true ) as CMissileProperty;
                if ( pPropery )
                    missileSeq = pPropery.missileSeq;
                if ( masterComp.master ) {
                    pFightTrigger = masterComp.master.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
                    pNetOutputComp = masterComp.master.getComponentByClass( CCharacterNetworkInput, true ) as CCharacterNetworkInput;
                }
            }

            if ( pFightTrigger && pNetOutputComp != null )
                pFightTrigger.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.REQUEST_SYNC_HEAL, null, [ aliasSkillID, m_theHealData.ID, healInfos, missileSeq ] ) );
        }
    }

    private function getAliaseSkillID() : int {
        var aliasSkillID : int;
        var pSkillCaster : CSkillCaster = owner.getComponentByClass( CSkillCaster, true ) as CSkillCaster;
        if ( pSkillCaster )
            aliasSkillID = pSkillCaster.skillID;
        var masterComp : CMasterCompomnent = owner.getComponentByClass( CMasterCompomnent, true ) as CMasterCompomnent;
        if ( masterComp ) {
            aliasSkillID = masterComp.aliasSkillID;
        }
        return aliasSkillID;
    }

    private function _healTarget( target : CGameObject, healInfo : Healing = null, hitPos : CVector3 = null ) : Object {
        var healData : Healing = healInfo;
        var tFxMediator : CFXMediator = target.getComponentByClass( CFXMediator, true ) as CFXMediator;
        var tSoundComp : CAudioMediator = target.getComponentByClass( CAudioMediator, true ) as CAudioMediator;
        var tCollisionComp : CCollisionComponent = target.getComponentByClass( CCollisionComponent, true ) as CCollisionComponent;

        if ( healData.ElementEffect != null && healData.ElementEffect.length != 0 )
            tFxMediator.playComhitEffects( healData.ElementEffect );
        if ( healData.HitSoundEffect != null && healData.HitSoundEffect.length != 0 )
            tSoundComp.playAudioByName( healData.HitSoundEffect );

        if ( healData.HitSFXName != null && healData.HitSFXName.length != 0 ) {
            var collisedArea : CAABBox3 = tCollisionComp.getCollisedArea( hitEventSignal, target );
            var collisedPosition : CVector3;
            if ( collisedArea )
                collisedPosition = tCollisionComp.getHitPosition( collisedArea );
            tFxMediator.playBindHitEffect( healData.HitSFXName, collisedPosition, 20 );
        }

        var healRetInfo : Object = _healingTarget( target );
        _showInfo( target, healRetInfo );
        return healRetInfo;

    }

    private function _showInfo( target : CGameObject, healRetInfo : Object ) : void {
        var showInfo : Object = healRetInfo;
        var tFloatSprite : CFightFloatSprite = target.getComponentByClass( CFightFloatSprite, true ) as CFightFloatSprite;
        var tProperty : CCharacterProperty = target.getComponentByClass( CCharacterProperty, true ) as CCharacterProperty;
        if ( tProperty == null || tFloatSprite == null )
            return;

        var healValue : int;
        for ( var key : String in showInfo ) {
            healValue = showInfo[ key ];
            switch ( key ) {
                case "healHP":
                    tProperty.HP = _calRetLimitMax( tProperty.MaxHP, tProperty.HP, healValue );
                    break;
                case "healAP":
                    tProperty.AttackPower = _calRetLimitMax( tProperty.MaxAttackPower, tProperty.AttackPower, healValue );
                    break;
                case "healDP":
                    tProperty.DefensePower = _calRetLimitMax( tProperty.MaxDefensePower, tProperty.DefensePower, healValue );
                    break;
                case "healRP":
                    tProperty.RagePower = _calRetLimitMax( tProperty.MaxRagePower, tProperty.RagePower, healValue );
                    break;
            }
            if ( healValue < 0 ) {
                var boShowHeroStyle : Boolean = CCharacterDataDescriptor.isHero( owner.data );
                var pMaster : CMasterCompomnent = owner.getComponentByClass( CMasterCompomnent, true ) as CMasterCompomnent;
                if ( pMaster != null )
                    boShowHeroStyle = CCharacterDataDescriptor.isHero( pMaster.master ? pMaster.master.data : null );

                tFloatSprite.createNumText( healValue, boShowHeroStyle );
            }
            else
                tFloatSprite.createGreenNumText( healValue );
        }
    }

    private function _calRetLimitMax( max : int, source : int, value : int ) : int {
        return CMath.max( source + value > max ? max : source + value, 0 );
    }

    private function _healTargetHP( target : CGameObject ) : void {
        var resultHP : int;
        var tFloatSprite : CFightFloatSprite = target.getComponentByClass( CFightFloatSprite, true ) as CFightFloatSprite;
        var tProperty : CCharacterProperty = target.getComponentByClass( CCharacterProperty, true ) as CCharacterProperty;
        resultHP = _calHealingHp( target );
        if ( tProperty == null || tFloatSprite == null )
            return;

        tProperty.HP = tProperty.HP + resultHP > tProperty.MaxHP ? tProperty.MaxHP : tProperty.HP + resultHP;
        if ( resultHP != 0 )
            tFloatSprite.createGreenNumText( resultHP );
    }

    private function _calHealingHp( target : CGameObject ) : int {
        var resultHP : int = 0;
        var tProperty : CCharacterProperty = target.getComponentByClass( CCharacterProperty, true ) as CCharacterProperty;
        var baseAttack : int = pCharacterProperty.Attack;
        resultHP += m_theHealData.BaseHealing;
        if ( tProperty == null )
            return 0;
        var maxHp : int = tProperty.MaxHP;
        var curHp : int = tProperty.HP;
        resultHP += baseAttack * m_theHealData.HealingPer / CFightCalc.CONST_THOUSAND;
        resultHP += maxHp * m_theHealData.RateOfHPLimit / CFightCalc.CONST_THOUSAND;
        resultHP += curHp * m_theHealData.RateOfHPNow / CFightCalc.CONST_THOUSAND;

        return resultHP;
    }

    private function _findTargets() : Array {
        var rets : Array;

        var targets : Array = pCriteriaComp.getTargetByCollision( hitEventSignal, m_theHealData.TargetFilter );
        if ( targets != null && targets.length > 0 )
            rets = targets.filter( _filterTargets );
        return rets;
    }

    private function _filterTargets( item : Object, index : int, arr : Array ) : Boolean {
        var vObj : CGameObject = item as CGameObject;
        if ( vObj ) {

            var pProperty : CCharacterProperty = vObj.getComponentByClass( CCharacterProperty, true ) as CCharacterProperty;
            if ( pProperty && pProperty.HP == 0 )
                return false;

            var ret : Boolean = true;
            var targetStateBoard : CCharacterStateBoard = vObj.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
            if ( targetStateBoard &&
                    (m_theHealData.BaseHealing < 0 || m_theHealData.HealingPer < 0 || m_theHealData.RateOfHPNow < 0 || m_theHealData.RateOfHPLimit ) )
                ret = targetStateBoard.getValue( CCharacterStateBoard.CAN_BE_ATTACK );
            return ret;
        }
        return false;
    }

    private function _updateHealingElapseTime( delta : Number ) : void {
        var keyObj : CGameObject;
        for ( keyObj in m_targetDic ) {
            var targetInfo : CHitStateInfo = m_targetDic[ keyObj ] as CHitStateInfo;
            if ( targetInfo.beingHitted )
                targetInfo.elapsTime = targetInfo.elapsTime + delta;
        }
    }

    private function _healingTarget( target : CGameObject ) : Object {
        var healingObj : Object = {};
        var healHP : int;
        var healAP : int;
        var healDP : int;
        var healRP : int;

        //healHP
        var baseAttack : int;
        var maxHP : int;
        var curHP : int;

        var targetPro : CCharacterProperty = target.getComponentByClass( CCharacterProperty, true ) as CCharacterProperty;
        if ( targetPro ) {
            maxHP = targetPro.MaxHP;
            curHP = targetPro.HP;
        }
//        if ( curHP == 0 )
//            return null;

        baseAttack = pCharacterProperty.Attack;
        healHP = _calResultHealingProperty( baseAttack, m_theHealData.HealingPer,
                maxHP, m_theHealData.RateOfHPLimit,
                curHP, m_theHealData.RateOfHPNow, m_theHealData.BaseHealing );

        if ( healHP != 0 ) {
            var pFightDamageComponent : CFightDamageComponent = owner.getComponentByClass( CFightDamageComponent, true ) as CFightDamageComponent;
            if ( pFightDamageComponent ) {
                if ( pFightDamageComponent.bNeedSkillRevision ) {
                    var aliasSkillID : int = getAliaseSkillID();
                    healHP = int( pFightDamageComponent.getSkillDamageRevision( CSkillUtil.getMainSkill(aliasSkillID) ) * healHP );
                }
            }

            healingObj.healHP = healHP;
        }

        //HealAP
        var maxAP : int;
        var curAP : int;
        maxAP = targetPro.MaxAttackPower;
        curAP = targetPro.AttackPower;

        healAP = _calResultHealingProperty( 0, 0,
                maxAP, m_theHealData.RateOfAPLimit,
                curAP, m_theHealData.RateOfAPNow, m_theHealData.BaseAP );

        if ( healAP != 0 )
            healingObj.healAP = healAP;

        //healDP
        var maxDP : int;
        var curDP : int;

        maxDP = targetPro.MaxDefensePower;
        curDP = targetPro.DefensePower;

        healDP = _calResultHealingProperty( 0, 0,
                maxDP, m_theHealData.RateOfDPLimit,
                curDP, m_theHealData.RateOfDPNow, m_theHealData.BaseDP );

        if ( healDP != 0 )
            healingObj.healDP = healDP;

        //healRP
        var maxRP : int;
        var curRP : int;
        maxRP = targetPro.MaxRagePower;
        curRP = targetPro.RagePower;

        healRP = _calResultHealingProperty( 0, 0,
                maxRP, m_theHealData.RateOfPGPLimit,
                curRP, m_theHealData.RateOfPGPNow, m_theHealData.BasePGP );

        if ( healRP != 0 )
            healingObj.healRP = healRP;

        return healingObj;
    }

    private function _calResultHealingProperty( basePerValue : int, healingPer : int,
                                                baseMaxValue : int, healingLimit : int,
                                                baseNowValue : int, healingRateNow : int,
                                                baseConst : int = 0 ) : int {
        var retHealing : int = baseConst;
        retHealing += basePerValue * healingPer / CFightCalc.CONST_THOUSAND;
        retHealing += baseMaxValue * healingLimit / CFightCalc.CONST_THOUSAND;
        retHealing += baseNowValue * healingRateNow / CFightCalc.CONST_THOUSAND;
        return retHealing;
    }

    private function _syncUpdateToSev( targets : Array ) : void {
        if ( entityType == EEffectType.E_BUFF ) {
            var theBuff : IBuff = entityInfo as IBuff;
            if ( theBuff ) {
                var healID : int = effectID;
                var buffId : int = theBuff.id;
                var effectTargets : Array = [];
                var randomSeed : int = theBuff.randomSeed;
                var target : CGameObject;

                var decodeObj : Object;
                for each( target in targets ) {
                    decodeObj = {};
                    decodeObj.type = CCharacterDataDescriptor.getID( target.data );
                    decodeObj.targetId = CCharacterDataDescriptor.getType( target.data );
                    effectTargets.push( decodeObj );
                }
                var pFTrigger : CCharacterFightTriggle = owner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
                if ( pFTrigger ) {
                    pFTrigger.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.REQUEST_SYNC_EFFECT, null,
                            [ healID, buffId, effectTargets, randomSeed ] ) );
                }
            }
        } else {

        }

    }

    private function _addToTargetDic( target : CGameObject ) : CHitStateInfo {
        var hitInfo : CHitStateInfo = m_targetDic.find( target ) as CHitStateInfo;
        if ( hitInfo != null ) {
            return hitInfo;
        } else {
            hitInfo = new CHitStateInfo();
            m_targetDic.add( target, hitInfo );
        }

        return hitInfo;
    }

    private var m_targetDic : CMap;
    private var m_theHealData : Healing;
}
}
