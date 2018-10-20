//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/7/25.
//----------------------------------------------------------------------
package kof.game.character.fight.skilleffect {

import QFLib.Foundation;
import QFLib.Interface.IDisposable;
import QFLib.Interface.IUpdatable;

import kof.framework.CAbstractHandler;

import kof.game.character.fight.IIterable;
import kof.game.character.fight.skill.CComponentUtility;
import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.fight.skill.CSkillDebugLog;
import kof.game.character.fight.skill.CSkillHit;
import kof.game.character.fight.skilleffect.extendsEffects.CMissileHitDirectlyEffect;
import kof.game.character.fight.skilleffect.util.EExtensionEffectType;
import kof.game.core.CGameObject;
import kof.table.Aero;
import kof.table.Emitter;
import kof.table.Skill.EEffectType;

/**
 * just a container ,add or remove effect in a skill's time line. the effects implement their owned logic
 */
public class CSkillEffectContainer implements IDisposable, IUpdatable {

    public function CSkillEffectContainer( owner : CGameObject = null, commonUty : CComponentUtility = null ) {
        m_effectList = new <CAbstractSkillEffect>[];
        m_pOwner = owner;
        m_pUtilityComp = commonUty;
    }

    public function dispose() : void {
        removeAllEffect();

        /* for each( var effect : CAbstractSkillEffect in m_effectList )
         {
         effect.dispose();
         effect = null;
         }
         if( m_effectList )
         {
         m_effectList.splice(0 , m_effectList.length );
         }*/

        m_effectList = null;

        m_pOwner = null;
        m_pUtilityComp = null;
        if ( m_emitterIDs )
            m_emitterIDs.splice( 0, m_emitterIDs.length );
        m_emitterIDs = null;
    }

    /**
     *
     * @param sData 是一个组里面带EffectTyep ，EffectTime，EffectDes，HiteventSignal的标准效果数据结构
     * @param ContainerParent  效果的拥有者
     * @param comUty 效果拥有包装的CComponentUtility结构。
     */
    public function buildEffectList( sData : *, ContainerParent : CGameObject = null, comUty : CComponentUtility = null,
                                     nType : int = 0, entityInfo : * = null, ignoreList : Array = null ) : void {
        var effIndex : int = 0;
        var effectEntity : CAbstractSkillEffect;

        if ( ContainerParent == null )
            ContainerParent = m_pOwner;
        if ( comUty == null )
            comUty = m_pUtilityComp;

        m_nTypeEntityEnter = nType;
        m_entityInfo = entityInfo;

        for each( var effType : int in sData.EffectType ) {
            if ( ignoreList && ignoreList.indexOf( effType ) >= 0 ) {
                effIndex++;
                continue;
            }

            if ( effType > 0 ) {
                var eId : int = sData.EffectID[ effIndex ];
                var esf : Number = sData.EffectTime[ effIndex ];
                var edes : String = sData.EffectDes[ effIndex ];
                var ehitEvent : String = sData.HitEventSignal[ effIndex ];
                var eDuration : Number = NaN;
                if ( 'fDuration' in sData )
                    eDuration = sData.fDuration[ effIndex ];

                buildEffectItem( ContainerParent, comUty, effType, eId, esf, eDuration, edes, ehitEvent );
            }
            effIndex++;
        }
    }

    public function buildEffectItem( ContainerParent : CGameObject, comUty : CComponentUtility, nEffectType : int,
                                     nEffectID : int, fEffectTime : Number, fDuration : Number, sEffectDes : String = "", sEffectEvent : String = "" ) : CAbstractSkillEffect {
        if ( nEffectType != 0 ) {
            var effectEntity : CAbstractSkillEffect;
            effectEntity = CSkillEffectContainer.createEffectByType( nEffectType, nEffectID, fEffectTime, fDuration, sEffectEvent, sEffectDes );
            if ( effectEntity ) {
                addSkillEffect( effectEntity );
                switch ( nEffectType ) {
                    case EEffectType.E_CHAIN :
                    case EEffectType.E_HIT :
                    case EEffectType.E_MOTION :
                    case EEffectType.E_CATCH:
                    case EEffectType.E_CATCH_END:
                    case EEffectType.E_TURN:
                        effectEntity.initData( comUty );
                        break;
                    case EEffectType.E_BULLET :
                        effectEntity.initData( ContainerParent );
                        if ( m_emitterIDs == null ) m_emitterIDs = [];
                        _getRelativeMissileEmitter( nEffectID );
                        break;
                    case EEffectType.E_SCREENEFF:
                    case EEffectType.E_BUFF:
                    case EEffectType.E_SCREENEFFECT:
                    case EEffectType.E_STATUS:
                        effectEntity.initData( ContainerParent );
                        break;
                    case EEffectType.E_TELETPORT:
                    case EEffectType.E_HEALING:
                    case EEffectType.E_RUSH:
                    case EEffectType.E_MISSILE_HIT:
                    case EEffectType.E_SUMMONER:
                        effectEntity.initData();
                        break;
                    //extension effects
                    case EExtensionEffectType.E_MISSILE_HIT:
                        effectEntity.initData();
                        break;
                    default:
                        Foundation.Log.logTraceMsg( "cast a skill with an invalid effect type @ CSkillCasterContext" + nEffectType );
                        return null;
                }
            }
            return effectEntity;
        }

        Foundation.Log.logTraceMsg( "cast a skill with an invalid effect type @ CSkillCasterContext" + nEffectType );
        return null;
    }

    public function get owner() : CGameObject {
        return m_pOwner;
    }

    public function update( delta : Number ) : void {
        for each( var eff : CAbstractSkillEffect in m_effectList ) {
            eff.update( delta );
        }
    }

    private function _getRelativeMissileEmitter( EmitterID : int ) : void {
        var emitterInfo : Emitter = CSkillCaster.skillDB.getEmmiterByID( EmitterID );
        var missileId : int = emitterInfo.MissileID;
        var missileInfo : Aero = CSkillCaster.skillDB.getAeroByID( missileId );
        var missileEffectTypes : Array = missileInfo.EffectType;
        m_emitterIDs.push( EmitterID );
        for ( var i : int = 0; i < missileEffectTypes.length; i++ ) {
            if ( missileEffectTypes[ i ] == EEffectType.E_BULLET ) {
                _getRelativeMissileEmitter( missileInfo.EffectID[ i ] );
            }
        }
    }

    public function lastUpdate( delta : Number ) : void {
        for each( var eff : CAbstractSkillEffect in m_effectList ) {
            eff.lastUpdate( delta );
        }
    }

    //暂时没用先 效果不是通过缓存来实现的了
    public function resetEffects() : void {
        for each( var sEff : CAbstractSkillEffect in m_effectList ) {
            sEff.resetEffect();
        }
    }

    public function addSkillEffect( skillEffect : CAbstractSkillEffect ) : CAbstractSkillEffect {
        if ( !skillEffect ) return null;

        var index : int = m_effectList.indexOf( skillEffect );
        if ( index < 0 ) {
            skillEffect.setContainer( this );
            m_effectList.push( skillEffect );
            CSkillDebugLog.logTraceMsg( "**@CSkillEffectContainer：技能添加一个效果 效果类型为" + skillEffect.effectType + "效果ID为 ：" + skillEffect.effectID + "当前效果数：" + m_effectList.length );
            return skillEffect;
        }
        else {
            Foundation.Log.logWarningMsg( " a dup effect added to effect list in a skill (@CSkillEffectContainer) " );
        }
        return null;

    }

    public function removeSkillEffect( skillEffect : CAbstractSkillEffect ) : void {
        var sEffect : CAbstractSkillEffect;
        var pIndex : int = m_effectList.indexOf( skillEffect );

        if ( pIndex != -1 ) {
            sEffect = m_effectList.splice( pIndex, 1 )[ 0 ];
            CSkillDebugLog.logTraceMsg( "**@CSkillEffectContainer：删除一个效果 效果类型为" + skillEffect.effectType + "效果ID为 ：" + skillEffect.effectID );
            sEffect.dispose();
            sEffect = null;
        }
    }

    public function sortSkillEffectsByTime() : void {
        if ( m_effectList ) {
            m_effectList.sort( desSortByTime );
        }
    }

    public function desSortByTime( e0 : CAbstractSkillEffect, e1 : CAbstractSkillEffect ) : int {
        if ( e0.effectStartTime > e1.effectStartTime )
            return 1;
        return -1;
    }

    public function getSkillEffectByID( id : int ) : CAbstractSkillEffect {
        for each( var skillEffect : CAbstractSkillEffect in m_effectList ) {
            if ( skillEffect.effectID == id ) {
                return skillEffect;
            }
        }

        return null;
    }

    public function getEffectsByType( nType : int ) : Array {
        var effRlt : Array = [];

        for each( var skillEffect : CAbstractSkillEffect in m_effectList ) {
            if ( skillEffect.effectType == nType ) {
                effRlt.push( skillEffect );
            }
        }

        if ( effRlt.length == 0 )
            effRlt = null;

        return effRlt;
    }

    public function get emitterIDs() : Array {
        return m_emitterIDs;
    }

    //类型跟ID获取效果事件
    public function getEffect( type : int, id : int ) : CAbstractSkillEffect {
        for each( var skillEffect : CAbstractSkillEffect in m_effectList ) {
            if ( skillEffect.effectID == id && skillEffect.effectType == type ) {
                return skillEffect;
            }
        }

        return null;
    }

    //delete specify effect type
    public function removeEffectByType( nType : int ) : void {
        for each( var skillEffect : CAbstractSkillEffect in m_effectList ) {
            if ( skillEffect.effectType == nType ) {
                removeSkillEffect( skillEffect );
            }
        }

    }

    public function removeAllEffect() : void {
        var splitEffects : Vector.<CAbstractSkillEffect> = m_effectList.slice();

        for each( var skillEffect : CAbstractSkillEffect in splitEffects ) {
            removeSkillEffect( skillEffect );
        }

        if ( m_emitterIDs )
            m_emitterIDs.length = 0;

        m_effectList.length = 0;
    }

    //协议的效果在傀儡端不随技能结束移除
    public function removePuppetAllEffect() : void {
        var splitEffects : Vector.<CAbstractSkillEffect> = m_effectList.slice();

        for each( var skillEffect : CAbstractSkillEffect in splitEffects ) {
            if ( !skillEffect.boSyncEffect )
                removeSkillEffect( skillEffect );
        }
    }

    public function get iterator() : IIterable {
        if ( !m_pIterator ) {
            m_pIterator = new CIterDelegate( m_effectList );
        }
        return m_pIterator;
    }

    public function get size() : int {
        return m_effectList.length;
    }

    public function setContainerEntity( type : int, info : * ) : void {
        m_nTypeEntityEnter = type;
        m_entityInfo = info;
    }

    public function get entityType() : int {
        return m_nTypeEntityEnter;
    }

    public function get entityInfo() : * {
        return m_entityInfo;
    }

    /**
     *
     * @param effType  type of effect
     * @param effectId   id of effect
     * @param effectStartFrame   the start frame of effect
     * @param effectDuration the duration of effect
     * @param effectHitEvent  the hit event of the effect( just for hitting)
     * @param effectDes   the description of the effect;
     * @return the object of the  Skill Effect
     */
    public static function createEffectByType( effType : int, effectId : Number, effectStartFrame : Number, effectDuration : Number, effectHitEvent : String, effectDes : String ) : CAbstractSkillEffect {
        var effectEntity : CAbstractSkillEffect;

        switch ( effType ) {
            case EEffectType.E_CHAIN :
                effectEntity = new CSkillChainEffect( effectId, effectStartFrame, effectHitEvent, effType, effectDes );
                break;
            case EEffectType.E_HIT :
                effectEntity = new CSkillHit( effectId, effectStartFrame, effectHitEvent, effType, effectDes );
                break;
            case EEffectType.E_MOTION :
                effectEntity = new CSkillMotionEffect( effectId, effectStartFrame, effectHitEvent, effType, effectDes );
                break;
            case EEffectType.E_BULLET :
                //子弹自己逻辑处理
                effectEntity = new CEmitterEffect( effectId, effectStartFrame, effectHitEvent, effType, effectDes );
                break;
            case EEffectType.E_SCREENEFF:
                effectEntity = new CScreenEffect( effectId, effectStartFrame, effectHitEvent, effType, effectDes );
                break;
            case EEffectType.E_STATUS:
                effectEntity = new CStateChanceEffect( effectId, effectStartFrame, effectHitEvent, effType, effectDes );
                break;
            case EEffectType.E_BUFF:
                effectEntity = new CSkillBuffEffect( effectId, effectStartFrame, effectHitEvent, effType, effectDes );
                break;
            case EEffectType.E_SCREENEFFECT:
                effectEntity = new CScreenColorEffect( effectId, effectStartFrame, effectHitEvent, effType, effectDes );
                break;
            case EEffectType.E_TURN:
                effectEntity = new CSkillTurnEffect( effectId, effectStartFrame, effectHitEvent, effType, effectDes );
                break;
            case EEffectType.E_CATCH:
                effectEntity = new CSkillCatchEffect( effectId, effectStartFrame, effectHitEvent, effType, effectDes );
                break;
            case EEffectType.E_CATCH_END:
                effectEntity = new CSkillCatchEndEffect( effectId, effectStartFrame, effectDuration, effectHitEvent, effType, effectDes );
                break;
            case EEffectType.E_TELETPORT:
                effectEntity = new CSkillTeleportEffect( effectId, effectStartFrame, effectHitEvent, effType, effectDes );
                break;
            case EEffectType.E_HEALING:
                effectEntity = new CSkillHealingEffect( effectId, effectStartFrame, effectHitEvent, effType, effectDes );
                break;
            case EEffectType.E_RUSH:
                effectEntity = new CSkillRushEffect( effectId, effectStartFrame, effectHitEvent, effType, effectDes );
                break;
            case EEffectType.E_MISSILE_HIT:
                effectEntity = new CSkillMissileHitEffect( effectId, effectStartFrame, effectHitEvent, effType, effectDes );
                break;
            case EExtensionEffectType.E_MISSILE_HIT:
                effectEntity = new CMissileHitDirectlyEffect( effectId, effectStartFrame, effectHitEvent, effType, effectDes );
                break;
            case EEffectType.E_SUMMONER:
                effectEntity = new CSkillSummonEffect(  effectId, effectStartFrame, effectHitEvent, effType, effectDes );
                break;
            case EEffectType.E_AWAY_TRUNK:
                effectEntity = new CSkillAwayTrunkEffect( effectId, effectStartFrame, effectHitEvent, effType, effectDes );
                break;
            default:
                Foundation.Log.logTraceMsg( "cast a skill with an invalid effect type @ CSkillCasterContext" );
        }

        return effectEntity;
    }

    public function createExtensionEffectByType( effType : int, effectId : Number, effectStartFrame : Number, effectDuration : Number, effectHitEvent : String, effectDes : String ) : CAbstractSkillEffect {
        var effectEntity : CAbstractSkillEffect;
        switch ( effType ) {
            case EExtensionEffectType.E_MISSILE_HIT:
                effectEntity = new CMissileHitDirectlyEffect( effectId, effectStartFrame, effectHitEvent, effType, effectDes );
                break;
        }
        return effectEntity;
    }

    private var m_effectList : Vector.<CAbstractSkillEffect>
    private var m_pIterator : IIterable;
    private var m_pOwner : CGameObject;
    private var m_pUtilityComp : CComponentUtility
    private var m_nTypeEntityEnter : int;
    private var m_entityInfo : *;
    private var m_emitterIDs : Array;
}
}

import flash.utils.Proxy;
import flash.utils.flash_proxy;

import kof.game.character.fight.IIterable;
import kof.game.character.fight.skilleffect.CAbstractSkillEffect;
import kof.util.CAssertUtils;

dynamic class CIterDelegate extends Proxy implements IIterable {

    private var m_pTarget : Vector.<CAbstractSkillEffect>;

    function CIterDelegate( target : Vector.<CAbstractSkillEffect > ) {
        this.m_pTarget = target;
        CAssertUtils.assertNotNull( m_pTarget );
    }

    override flash_proxy function nextNameIndex( index : int ) : int {
        if ( 0 > index || index >= m_pTarget.length )
            return 0;
        return index + 1;
    }

    override flash_proxy function nextName( index : int ) : String {
        if ( 0 > index || index >= m_pTarget.length )
            return "undefined";
        return index.toString();
    }

    override flash_proxy function nextValue( index : int ) : * {
        return m_pTarget[ index - 1 ];
    }

}
