//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/6/7.
//----------------------------------------------------------------------
package kof.game.character.fight.skill {


import QFLib.Foundation;
import QFLib.Foundation.CMap;
import QFLib.Foundation.CPath;
import QFLib.Foundation.CURLJson;
import QFLib.Foundation.free;
import QFLib.Framework.CFramework;
import QFLib.Interface.IUpdatable;
import QFLib.Math.CMath;
import QFLib.Math.CVector2;
import QFLib.Math.CVector3;
import QFLib.ResourceLoader.CJsonLoader;
import QFLib.ResourceLoader.CPackedQsonLoader;
import QFLib.ResourceLoader.CResource;
import QFLib.ResourceLoader.CResourceLoaders;
import QFLib.ResourceLoader.ELoadingPriority;

import kof.data.KOFTableConstants;

import kof.framework.IDataTable;


import kof.framework.IDatabase;
import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.CCharacterEvent;
import kof.game.character.CEventMediator;
import kof.game.character.CFacadeMediator;
import kof.game.character.animation.CBaseAnimationDisplay;
import kof.game.character.animation.IAnimation;
import kof.game.character.display.CBaseDisplay;
import kof.game.character.fight.CCharacterNetworkInput;
import kof.game.character.fight.CFightHandler;
import kof.game.character.fight.catches.CSkillCatcher;
import kof.game.character.fight.emitter.CEmitterContainer;
import kof.game.character.fight.emitter.CEmmiterController;
import kof.game.character.fight.emitter.CMissileContainer;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skill.model.CSkillEffectInfo;
import kof.game.character.fight.skill.property.CLogicFrameLoop;
import kof.game.character.fight.skill.property.CSkillPropertyComponent;
import kof.game.character.fight.skillcalc.CPropertyRecovery;
import kof.game.character.fight.skillcalc.ERPRecoveryType;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.character.fight.skilleffect.CAbstractSkillEffect;
import kof.game.character.fight.skilleffect.CSkillBuffEffect;
import kof.game.character.fight.skilleffect.CSkillCatchEffect;
import kof.game.character.fight.skilleffect.CSkillCatchEndEffect;
import kof.game.character.fight.skilleffect.CSkillEffectContainer;
import kof.game.character.fight.skilleffect.CSkillMotionEffect;
import kof.game.character.fight.skilleffect.CSkillMotionEffect;
import kof.game.character.fight.skilleffect.CSkillTeleportEffect;
import kof.game.character.fight.skilleffect.CStateChanceEffect;
import kof.game.character.fight.skilleffect.CStateChanceEffect;
import kof.game.character.fight.skilleffect.extendsEffects.CMissileHitDirectlyEffect;
import kof.game.character.fight.sync.CCharacterSyncBoard;
import kof.game.character.fight.targetfilter.CFightEvent;
import kof.game.character.property.CCharacterProperty;
import kof.game.character.state.CCharacterActionStateConstants;
import kof.game.character.state.CCharacterAttackState;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.character.state.CCharacterStateMachine;
import kof.game.character.state.CGameBaseStateConstants;
import kof.game.core.CGameComponent;
import kof.game.core.CGameObject;
import kof.table.ActionSeq;
import kof.table.ActionSeq.EActionSeqType;
import kof.table.Emitter;
import kof.table.HitShake;
import kof.table.Skill;
import kof.table.Skill.ECastType;
import kof.table.Skill.EEffectType;
import kof.table.Skill.ESkillType;
import kof.util.CAssertUtils;

/**
 * 技能容器  里面 提供各种技能组件的接口
 */
public class CSkillCaster extends CGameComponent implements IUpdatable,ISkillInfoRes {

    public function CSkillCaster( pFightHandler : CFightHandler, missileContainer : CMissileContainer ) {
        super( "skillcontainer" );
        this.m_pFightHandler = pFightHandler;
        this.m_pMissileContainer = missileContainer;
    }

    override public function dispose() : void {
        super.dispose();

        this.m_pFightHandler = null;
        this.m_pMissileContainer = null;
        free( this.m_ActionResource );
        m_ActionResource = null;

        free( this.m_timelineEffectResource );
        m_timelineEffectResource = null;

        free( this.m_collisionEffectResource );
        m_collisionEffectResource = null;

        if ( m_packedResource != null ) {
            m_packedResource.dispose();
            m_packedResource = null;
        }
        m_fnLoadPackedFinished = null;
    }

    override protected function onEnter() : void {
        super.onEnter();

        if ( null == m_theLogicFrameLoop )
            m_theLogicFrameLoop = new CLogicFrameLoop( _skillAtomTick );

        if ( m_pFightHandler )
            m_pFightHandler.addEventListener( CFightEvent.STOP_FIGHT_HDL, _onFightSysEnd );
        if ( null == m_skillContextMap ) {
            m_skillContextMap = new CMap();
        }

        var pDBSys : IDatabase = m_pMissileContainer.system.stage.getSystem( IDatabase ) as IDatabase;

        if ( null == skillDB && null != pDBSys ) {
            m_skillDB = CSkillDataBase.createSkillDataBase( pDBSys );
        }

        if ( null == m_pComUtility )
            m_pComUtility = new CComponentUtility( owner );

        if ( null == m_effectContainer ) {
            m_effectContainer = new CSkillEffectContainer( owner, m_pComUtility );
        }

        if ( null == m_emmiterContainer ) {
            m_emmiterContainer = new CEmitterContainer();
        }

        if ( null == m_skillEvaluator )
            m_skillEvaluator = new CSkillEvaluator();
        m_skillEvaluator.skillOwner = owner;

        var pEventMediator : CEventMediator = owner.getComponentByClass( CEventMediator, true ) as CEventMediator;
        if ( pEventMediator ) {
            pEventMediator.addEventListener( CCharacterEvent.DISPLAY_READY, _onAnimationReady );
        }
    }

    override protected function onDataUpdated() : void {
        super.onDataUpdated();
        if ( pProperty ) {
            modelName = pProperty.skinName;
        }
    }

    override protected function onExit() : void {

        if ( m_skillContextMap )
            m_skillContextMap.clear();
        m_skillContextMap = null;
        m_skillAnimationEndCB = null;

        if ( null != m_effectContainer )
            m_effectContainer.dispose();
        m_effectContainer = null;

        if ( m_emmiterContainer )
            m_emmiterContainer.dispose();
        m_emmiterContainer = null;

        if ( m_pComUtility )
            m_pComUtility.dispose();
        m_pComUtility = null;

        if ( m_actionsMap )
            m_actionsMap.clear();
        m_actionsMap = null;

        if ( m_collisionEffectsMap )
            m_collisionEffectsMap.clear();
        m_collisionEffectsMap = null;

        if ( m_timelineEffectsMap )
            m_timelineEffectsMap.clear();
        m_timelineEffectsMap = null;

        if ( m_theLogicFrameLoop )
            m_theLogicFrameLoop.dispose();
        m_theLogicFrameLoop = null;

        var pEventMediator : CEventMediator = owner.getComponentByClass( CEventMediator, true ) as CEventMediator;
        if ( pEventMediator ) {
            pEventMediator.removeEventListener( CCharacterEvent.DISPLAY_READY, _onAnimationReady );
        }

        if ( m_pFightHandler )
            m_pFightHandler.removeEventListener( CFightEvent.STOP_FIGHT_HDL, _onFightSysEnd );

        super.onExit();

    }

    public function update( delta : Number ) : void {
        _tickLegacyState()
        if ( m_theLogicFrameLoop )
            m_theLogicFrameLoop.update( delta );

        //test
//        if( owner.data.skin.indexOf("banqiliang")>=0)
//        CSkillDebugLog.logMsg("班启辽动作时间帧" + delta );
    }

    public function updateOld( delta : Number ) : void {
        var speedDelta : Number = delta * skillSpeed;

        if ( speedDelta < SKILL_MAX_LATENESS_TOLERAT ) {
            while ( speedDelta > SKILL_ATOM_FRAME ) {
                _skillAtomTick( SKILL_ATOM_FRAME );
                speedDelta = speedDelta - SKILL_ATOM_FRAME;
            }
        }

        _skillAtomTick( speedDelta );

    }

    private function _skillAtomTick( atomDelta : Number ) : void {
        m_bAtomRoundBegine = true;

        if ( m_bAtomRoundBegine && m_pCurrentSkillContext ) {
            m_pCurrentSkillContext.update( atomDelta );
        }

        if ( m_bAtomRoundBegine && null != m_effectContainer && m_effectContainer.size > 0 )
            m_effectContainer.update( atomDelta );


        if ( m_bAtomRoundBegine && null != m_emmiterContainer )
            m_emmiterContainer.update( atomDelta );

        _skillAtomLastUpdate( atomDelta );
        m_bAtomRoundBegine = false;
    }

    public function _skillAtomLastUpdate( atomDelta : Number ) : void {

        if ( m_pCurrentSkillContext ) {
            m_pCurrentSkillContext.lastUpdate( atomDelta );
        }

        if ( null != m_effectContainer ) {
            m_effectContainer.lastUpdate( atomDelta );
        }

        if ( null != m_emmiterContainer ) {
            m_emmiterContainer.lastUpdate( atomDelta );
        }

        m_pComUtility.collisionComponent.collisionsFadeOut( atomDelta );
    }

    private function _onFightSysEnd( event : CFightEvent ) : void {
        var pFacadeMediator : CFacadeMediator = owner.getComponentByClass( CFacadeMediator, true ) as CFacadeMediator;
        pFacadeMediator.forceCancelAttakState();
    }

    private function _tickLegacyState() : void {
        var m_pState : CCharacterStateBoard = pStateboard;
        if ( m_pState )
            if ( m_pState.getValue( CCharacterStateBoard.LEGACY_NEED_UPDATE ) ) {
                m_pState.resetValue( CCharacterStateBoard.LEGACY_NEED_UPDATE );
                var theAnimation : IAnimation = pAnimation;
                if( theAnimation )
                        theAnimation.inTurnning = false;
            }
    }

    private function _onSkillEnd() : void {
        if ( skillContext )
            skillContext.fightTriggle.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.SPELL_SKILL_END, null, [ skillID ] ) );
        if ( skillAnimationEndCB )
            skillAnimationEndCB();
        boToExitSkill = false;
    }

    private function buildUpSkillContexByID( nSkillID : int ) : CSkillCasterContext {
        m_nSkillID = nSkillID;
        m_pCurrentSkillContext = m_skillContextMap.find( m_nSkillID ) as CSkillCasterContext;

        if ( m_pCurrentSkillContext ) {
            m_pCurrentSkillContext.resetSkill();
            Foundation.Log.logTraceMsg( "**@CSkillCaster 从缓存中加载成功context** ID ：" + nSkillID );
        }

        if ( null == m_pCurrentSkillContext ) {
            m_pCurrentSkillContext = new CSkillCasterContext( owner );
            //存在技能ID则丢入技能map，
            if ( m_pCurrentSkillContext.initWithSkillID( getComponent( IDatabase ) as IDatabase, nSkillID ) ) {
                m_skillContextMap.add( nSkillID, m_pCurrentSkillContext );
                CONFIG::debug {
                    Foundation.Log.logTraceMsg( "**@CSkillCaster构建成功context** ID ：" + nSkillID );
                }
            }
            else {
                m_pCurrentSkillContext.dispose();
                m_pCurrentSkillContext = null;
                CONFIG::debug {
                    Foundation.Log.logTraceMsg( "**@CSkillCaster构建技能context失败** ID ：" + nSkillID );
                }
                return null;
            }
        }

        if ( skillContext ) {
            _buildupEffects( nSkillID );
        }

        var pSkillPropertyComp : CSkillPropertyComponent = owner.getComponentByClass( CSkillPropertyComponent, true ) as CSkillPropertyComponent;
        if ( pSkillPropertyComp ) {
            var buffList : Array = pSkillPropertyComp.getBuffList( nSkillID );
            for each ( var buffID : int in buffList ) {
                castBuffEmitterEffect( buffID, "SkillUp_0" );
            }
        }

        return m_pCurrentSkillContext;
    }

    private function _buildupEffects( skillID : int ) : void {

        var skillInfo : Skill = skillDB.getSkillDataByID( skillID, CCharacterDataDescriptor.getSimpleDes( owner.data ) );
        var pNetComp : CCharacterNetworkInput = owner.getComponentByClass( CCharacterNetworkInput, true ) as CCharacterNetworkInput;
        var boIsPuppet : Boolean;
        if ( pNetComp )
            boIsPuppet = pNetComp.isAsPuppet;

        if ( null == skillInfo )  return;

        if ( m_timelineEffectsMap ) {
            var timeLineEffects : Array = m_timelineEffectsMap.find( skillInfo.ActionFlag );
            var effectInfo : CSkillEffectInfo;

            if ( null != timeLineEffects ) {
                var objEffect : Object;
                for ( var timeLineIndex : int = 0; timeLineIndex < timeLineEffects.length; timeLineIndex++ ) {
                    objEffect = timeLineEffects[ timeLineIndex ];
                    if ( objEffect == null || boIsPuppet && isExclusiveEffectType( objEffect.EffectType ) )
                        continue;

                    effectInfo = new CSkillEffectInfo();
                    effectInfo.loadFromData( objEffect );
                    appendSkillEffect( effectInfo );
                }
            } else {
                CSkillDebugLog.logTraceMsg( "skill : " + skillID + "has no timeline effect" );
            }
        }
        //setup hit effect ，buff effect ， emitter effect
        if ( m_collisionEffectsMap ) {
            var collisionEffect : Object = m_collisionEffectsMap.find( skillInfo.ActionFlag );
            var collisionEffectInfo : CSkillEffectInfo;
            for ( var colKey : String in collisionEffect ) {
                var colKeyEffects : Array = collisionEffect[ colKey ] as Array;
                if ( colKeyEffects ) {
                    var objCollisionEffect : Object;
//                    for each( var colEffect : Object in colKeyEffects ) {
                    for ( var i : int = 0; i < colKeyEffects.length; i++ ) {
                        objCollisionEffect = colKeyEffects[ i ];
                        if ( objCollisionEffect == null || boIsPuppet && isExclusiveEffectType( objCollisionEffect.EffectType ) )
                            continue;

                        collisionEffectInfo = new CSkillEffectInfo();
                        collisionEffectInfo.loadFromData( objCollisionEffect );
                        collisionEffectInfo.HitEventSignal = colKey;
                        appendSkillEffect( collisionEffectInfo );
                    }
                }
            }
        }

        sortSkillEffectsByEffectTime();
    }

    public static function isExclusiveEffectType( type : int ) : Boolean {
        return S_EXCLUSI_EFFECT.indexOf( type ) >= 0;
    }

    public function isInSameMainSkill( nSkillId : int ) : Boolean {
        if ( skillID == 0 || nSkillId == 0 ) return false;
        var targetMainSkill : int = CSkillUtil.getMainSkill( nSkillId );
        var currMainSkill : int = CSkillUtil.getMainSkill( skillID );
        return targetMainSkill == currMainSkill;
    }

    public function isPlayingSkill() : Boolean {
        return m_nSkillID != 0;
    }

    public function isInSpecifySkill( nSkillID : int ) : Boolean {
        return skillID == nSkillID;
    }

    public function isInSuperSkill() : Boolean {
        if ( skillID == 0 )
            return false;

        return CSkillUtil.boSuperSkill( skillID );
    }

    public function isAllowRecoveryAttackPower() : Boolean {
        if ( m_nSkillID == 0 ) return true;
        var skillInfo : Skill = CSkillCaster.skillDB.getSkillDataByID( skillID );
        CAssertUtils.assertNotNull( skillInfo );
        return skillInfo.StopAP == 0;
    }

    /**
     * append a new skillEffect
     * @param skillEffect
     */
    public function appendSkillEffect( skillEffect : CSkillEffectInfo ) : CAbstractSkillEffect {
        var eId : int = skillEffect.EffectID;
        var esf : Number = skillEffect.EffectTime;
        var edes : String = skillEffect.EffectDes;
        var ehitEvent : String = skillEffect.HitEventSignal;
        var effType : int = skillEffect.EffectType;
        var eDuration : Number = skillEffect.Duration;

        return m_effectContainer.buildEffectItem( owner, m_pComUtility, effType, eId, esf, eDuration, edes, ehitEvent );
    }

    public function buildSkillEffects( data : *, subEntity : int = 0, entityInfo : * = null, ignoreList : Array = null ) : void {
        if ( m_effectContainer )
            m_effectContainer.buildEffectList( data, null, null, subEntity, entityInfo, ignoreList );
    }

    public function removeSkillEffects() : void {
        if ( m_effectContainer )
            m_effectContainer.removeAllEffect();
    }

    public function sortSkillEffectsByEffectTime() : void {
        if ( m_effectContainer )
            m_effectContainer.sortSkillEffectsByTime();
    }

    public function set modelName( modelName : String ) : void {
        if ( m_modelName == modelName )
            return;

        this.m_modelName = modelName;
        if ( m_modelName != null && m_modelName.length != 0 ) {
            var fileName : String = new CPath( m_modelName ).name;

            var actionsUrl : String = _getRespositUrl() + m_modelName + "/" + fileName + "_actionseq.json";
            var timeLineUrl : String = _getRespositUrl() + m_modelName + "/" + fileName + "_timelineeffect.json";
            var collisionUrl : String = _getRespositUrl() + m_modelName + "/" + fileName + "_collisioneffect.json";

            function loadCharacterSkillFile() : void {
                CResourceLoaders.instance().startLoadFile( actionsUrl, _onActionsLoaded, CJsonLoader.NAME, ELoadingPriority.NORMAL, true );
                CResourceLoaders.instance().startLoadFile( timeLineUrl, _onTimeLineEffectsLoaded, CJsonLoader.NAME, ELoadingPriority.NORMAL, true );
                CResourceLoaders.instance().startLoadFile( collisionUrl, _onCollisionEffectsLoaded, CJsonLoader.NAME, ELoadingPriority.NORMAL, true );
            }

            if ( CPackedQsonLoader.enablePackedQsonLoading == true ) {
                var vPackedFile : Vector.<String> = new Vector.<String>( 2 );
                vPackedFile[ 0 ] = _getRespositUrl() + m_modelName + "/" + fileName + "_packed.qson";
                vPackedFile[ 1 ] = _getRespositUrl() + m_modelName + "/" + fileName + "_packed.json";
                m_fnLoadPackedFinished = loadCharacterSkillFile;
                CResourceLoaders.instance().startLoadFileFromPathSequence( vPackedFile, _onPackedFileLoaded, CPackedQsonLoader.NAME );
            }
            else {
                loadCharacterSkillFile();
            }
        }
    }

    public function castHitToTargets( hitID : int, targets : Array, collidedArea : Array = null,
                                      bIgnoreGuard : Boolean = false, hitPosition : Array = null, distanceDiscreaseList : Array = null ) : CSkillHit {
        var pHitEffect : CSkillHit;
        {
            var effecInfo : CSkillEffectInfo = _createBasicEffectInfo( EEffectType.E_HIT, hitID, "hit Directly" );
            pHitEffect = appendSkillEffect( effecInfo ) as CSkillHit;
            if ( pHitEffect )
                pHitEffect.hitTargetDirectly( targets, collidedArea, bIgnoreGuard, hitPosition, distanceDiscreaseList );
        }

        return pHitEffect;
    }

    public function castAbsorbMissiles( absorbId : int, targets : Array, collidedArea : Array = null ) : void {
        var pAbsorbMissileEffect : CMissileHitDirectlyEffect;
        {
            var effecInfo : CSkillEffectInfo = _createBasicEffectInfo( EEffectType.E_HIT, absorbId, "hit Directly" );
            pAbsorbMissileEffect = appendSkillEffect( effecInfo ) as CMissileHitDirectlyEffect;
            if ( pAbsorbMissileEffect )
                pAbsorbMissileEffect.doHitDirectlyToMissiles( targets, collidedArea );
        }
    }

    public function castHostHitToTargets( hitID : int, skillHitQueueId : int, targets : Array, boIngoreGuard : Boolean,
                                          hitPosition : Array = null, distanceDiscreaseList : Array = null, damageInofos : Array = null ,missileSeq : int = -1 , skillID : int = -1) : void {
        var pHitEffect : CSkillHit;
        {
            var effecInfo : CSkillEffectInfo = _createBasicEffectInfo( EEffectType.E_HIT, hitID, "hit Directly" );
            pHitEffect = appendSkillEffect( effecInfo ) as CSkillHit;
            if ( pHitEffect ) {
                pHitEffect.HostHitTargetDirectly( targets, skillHitQueueId, boIngoreGuard, hitPosition, distanceDiscreaseList, damageInofos, missileSeq, skillID );
                pHitEffect.update(0.01);
            }

        }
    }

    public function castCatchToTargets( catchID : int, targets : Array, bFromHost : Boolean = false, nDirX : int = 0 ) : void {
        var theCatchEffect : CSkillCatchEffect;
        {
            var effecInfo : CSkillEffectInfo = _createBasicEffectInfo( EEffectType.E_CATCH, catchID, "catch Directly" );
            theCatchEffect = appendSkillEffect( effecInfo ) as CSkillCatchEffect;
            if ( theCatchEffect ) {
                var targetsVec : Vector.<CGameObject> = new <CGameObject>[];
                for each( var tar : CGameObject in targets ) {
                    targetsVec.push( tar );
                }
                theCatchEffect.catchTargetsDirectly( targetsVec, bFromHost, nDirX );
            }
        }
    }

    public function castCatchEndToTarget( catchEndID : int, targets : Array ) : void {
        var theCatchEffect : CSkillCatchEndEffect;
        {
            var effecInfo : CSkillEffectInfo = _createBasicEffectInfo( EEffectType.E_CATCH_END, catchEndID, "catch end Directly" );
            theCatchEffect = appendSkillEffect( effecInfo ) as CSkillCatchEndEffect;
            if ( theCatchEffect ) {
                theCatchEffect.catchEndTargetDirectly( targets );
            }
        }
    }

    //直接传送到目标点
    public function castTeleportToTarget( teleId : int, toTarget : CGameObject = null, onEndCallBack : Function = null ) : void {
        var pTeleEffect : CSkillTeleportEffect;
        {
            var effectInfo : CSkillEffectInfo = _createBasicEffectInfo( EEffectType.E_TELETPORT, teleId, 'Teleport to Position directly ' );
            pTeleEffect = appendSkillEffect( effectInfo ) as CSkillTeleportEffect;
            if ( pTeleEffect )
                pTeleEffect.doTeleportDirectlyToTarget( toTarget, onEndCallBack );
        }
    }

    //直接传送到坐标点
    public function castTeleportToPosition( teleId : int, position : CVector2, onEndCallBack : Function = null ) : void {
        var pTeleEffect : CSkillTeleportEffect;
        {
            var effectInfo : CSkillEffectInfo = _createBasicEffectInfo( EEffectType.E_TELETPORT, teleId, 'Teleport to Position directly ' );
            pTeleEffect = appendSkillEffect( effectInfo ) as CSkillTeleportEffect;
            if ( pTeleEffect )
                pTeleEffect.doTeleportDirectlyToPosition2D( position, onEndCallBack );
        }
    }

    public function castBuffEmitterEffect( buffEmitterId : int, hitEvent : String ) : void {
        {
            var effectInfo : CSkillEffectInfo = _createBasicEffectInfo( EEffectType.E_BUFF, buffEmitterId, "buff effect", 0.0, hitEvent );
            appendSkillEffect( effectInfo ) as CSkillBuffEffect;
        }
    }

    public function castMotionEffect( motionId : int, dirX : int = 0 ) : void {
        var effectInfo : CSkillEffectInfo = _createBasicEffectInfo( EEffectType.E_MOTION, motionId, "motion effect", 0.0 );
        var motionEffect : CSkillMotionEffect = appendSkillEffect( effectInfo ) as CSkillMotionEffect;
        if ( dirX != 0 )
            motionEffect.setDirX( dirX );
    }

    private function _createBasicEffectInfo( type : int, effectID : int,
                                             des : String, startTime : Number = 0.0, hitEvent : String = '' ) : CSkillEffectInfo {
        var effectInfo : CSkillEffectInfo = new CSkillEffectInfo();
        effectInfo.EffectType = type;
        effectInfo.EffectID = effectID;
        effectInfo.EffectDes = des;
        effectInfo.EffectTime = startTime;
        effectInfo.HitEventSignal = hitEvent;
        return effectInfo;
    }

    private function _getRespositUrl() : String {
        return "assets/character/";
    }

    public function spellSkill( nSkillID : int, skillEndCallBack : Function = null ) : void {

        CSkillDebugLog.logTraceMsg( "**开始释放技能** ID ：" + nSkillID );
        if ( !m_boSkillReady ) {
            var fTrigger : CCharacterFightTriggle = getComponent( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
            if ( fTrigger ) {
                fTrigger.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.SPELL_SKILL_FAILED, null ) );
                CSkillDebugLog.logTraceMsg( "> <' 技能数据没准备好，别烦我" );
            }

            return;
        }

        if ( m_nSkillID != 0 ) {

            var boForceCancel : Boolean;
            boForceCancel = m_skillEvaluator.evaluateInterruptLogic( m_nSkillID, nSkillID );
            if ( !boForceCancel ) {
                pComUtility.fightTriggle.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.SPELL_SKILL_FAILED, owner ) );
                return;
            }

            pComUtility.pFightCalc.otherFightCalc.boForceCancel = boForceCancel;
            //enough cancel pre skill.
            if ( CSkillUtil.isActiveSkill( nSkillID ) ) {
                var cAP : int = CSkillCaster.skillDB.getSkillDataByID( m_nSkillID ).CancelConsumeAP;
                pComUtility.pFightCalc.battleEntity.calcAttackPower( -cAP );
                if ( cAP > 0 ) {
                    pComUtility.pFightCalc.recovery.resetAttackPowerRecovery();  //resetRecoveryByType( CPropertyRecovery.RECOVERY_TYPE_AP );
                    pComUtility.pFightCalc.battleEntity.increaseRagePowerByType( ERPRecoveryType.TYPE_COMSUME_AP, cAP );
                }

                CSkillDebugLog.logTraceMsg( "强制取消技能消耗 ：" + -CSkillCaster.skillDB.getSkillDataByID( m_nSkillID ).CancelConsumeAP );
            }
        }

        //先移除先前的技能的击打效果
        m_effectContainer.removeAllEffect();
        pComUtility.collisionComponent.clearAtkBounds();
        m_nSkillID = nSkillID;

        if ( skillEndCallBack )
            m_skillAnimationEndCB = skillEndCallBack;

        if ( m_pCurrentSkillContext )
            m_pCurrentSkillContext.resetSkill();

        var skillContext : CSkillCasterContext = buildUpSkillContexByID( skillID );

        //扣除攻击值，回复怒气值
        {
            var pSkillProComp : CSkillPropertyComponent = owner.getComponentByClass( CSkillPropertyComponent, true ) as CSkillPropertyComponent;
            var consumeAp : int = pSkillProComp.getSkillConsumeAp( nSkillID );
            pComUtility.pFightCalc.battleEntity.calcAttackPower( -consumeAp );
            skillContext.fightTriggle.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.REQUEST_SYNC_FIGHT_STATE_VALUE, null, [ CCharacterSyncBoard.ATTACK_POWER_DELTA, consumeAp ] ) );
            if ( consumeAp > 0 ) {
                pComUtility.pFightCalc.recovery.resetAttackPowerRecovery();//resetRecoveryByType( CPropertyRecovery.RECOVERY_TYPE_AP );
                pComUtility.pFightCalc.battleEntity.increaseRagePowerByType( ERPRecoveryType.TYPE_COMSUME_AP, consumeAp );
            }

            //释放技能回复
            pComUtility.pFightCalc.battleEntity.increaseRagePowerByType( ERPRecoveryType.TYPE_SPELL_SKILL, pSkillProComp.getSkillRagePowerRecoverty( nSkillID ) );

        }

        if ( skillContext.skillData.SkillType == ESkillType.SKILL_SPOWER ){ //&& skillContext.skillData.CastType == ECastType.NORMAL ) {
            var ConsumePGP : int;
            if ( pSkillProComp )
                ConsumePGP = pSkillProComp.getSkillConsumePGP( skillID );

            pComUtility.pFightCalc.battleEntity.calcRagePower( -ConsumePGP );
            var pSyncComp : CCharacterSyncBoard = owner.getComponentByClass( CCharacterSyncBoard, true ) as CCharacterSyncBoard;
            if ( pSyncComp )
                pSyncComp.setValue( CCharacterSyncBoard.CONSUME_RAGE_POWER, ConsumePGP );
        }

        if ( skillContext.skillData.TimeStopLast > 0 && m_pFightHandler )
            m_pFightHandler.addClosenessObject( owner );

        skillContext.fightTriggle.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.REQUEST_SYNC_FIGHT_STATE, null, [ CCharacterSyncBoard.SKILL_CD_LIST ] ) );

        pComUtility.pFightCalc.fightCDCalc.addSkillCD( nSkillID );

        var skillProComp : CSkillPropertyComponent = owner.getComponentByClass( CSkillPropertyComponent, true ) as CSkillPropertyComponent;
        var skillCd : Number = skillProComp.getSkillCD( nSkillID );

        var emitterIDs : Array = m_effectContainer.emitterIDs;
        var stateChangeEffects : Array = m_effectContainer.getEffectsByType( EEffectType.E_STATUS );
        var subStateInfos : Object;
        var effectInfo : Object;
        var effect : CStateChanceEffect;
        for each( var stateEffect : CStateChanceEffect in stateChangeEffects ) {
            effect = stateEffect;
            effectInfo = effect.stateInfo;
            if ( effect && effectInfo ) {
                if ( !subStateInfos )
                    subStateInfos = {};
                for ( var key : * in effectInfo ) {
                    subStateInfos[ key ] = effectInfo[ key ];
                }
            }
        }

        skillContext.fightTriggle.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.SPELL_SKILL_BEGIN, null, [ nSkillID, skillCd, emitterIDs, subStateInfos ] ) );
        m_bAtomRoundBegine = false;
    }

    private function _createEmitter( emitter : CEmmiterController ) : void {
        m_emmiterContainer.addEmmitter( emitter );
    }

    public function createEmitterWithID( id : int, collsionSign : String, pos : CVector3 = null, targets : Array = null ) : CEmmiterController {
        var emitterCtr : CEmmiterController;
        var emitterInfo : Emitter;
        emitterInfo = skillDB.getEmmiterByID( id ) as Emitter;
        emitterCtr = new CEmmiterController( this, emitterInfo, collsionSign, pos, targets );
        _createEmitter( emitterCtr );
        return emitterCtr;
    }

    public function isJumpSkill( nSkillID : int ) : Boolean {
        var bJump : Boolean = false;
        var sActionFlag : String;
        sActionFlag = CSkillUtil.getSkillFlag( nSkillID );

        if ( sActionFlag ) {
            var pSkillInfoRes : ISkillInfoRes = owner.getComponentByClass( ISkillInfoRes, true ) as ISkillInfoRes;
            if ( pSkillInfoRes ) {
                var pActionSeq : ActionSeq = pSkillInfoRes.getSkillActionsByActionFlag( sActionFlag );
                if ( pActionSeq && pActionSeq.Type == EActionSeqType.JUMP )
                    bJump = true;
            }
        }
        return bJump;
    }

    public function removeEmitter( emitter : CEmmiterController ) : void {
        m_emmiterContainer.removeEmmiter( emitter );
    }

    /**
     *
     * @param shakeID
     */
    public function playCharacterShake( shakeID : int, fFrozenTime : Number ) : void {
        var hShake : HitShake;
        if ( shakeID != 0 )
            hShake = CSkillCaster.skillDB.getHitShakeByID( shakeID );
        if ( null == hShake )
            return;

        var mDiplay : IAnimation = m_pComUtility.cAnimation;

        if ( 0 == hShake.Frequency )
            return;

        var shakeDuration : Number = hShake.Count * (1 / hShake.Frequency);
        shakeDuration = shakeDuration > fFrozenTime ? fFrozenTime : shakeDuration;
        mDiplay.shakeXY( hShake.Extent * CMath.cosDeg( hShake.Direction ),
                hShake.Extent * CMath.sinDeg( hShake.Direction ),
                shakeDuration,
                1 / hShake.Frequency );
    }

    final public function get skillEvaluator() : CSkillEvaluator {
        return m_skillEvaluator;
    }

    public function cancelSkill() : void {
        if ( m_pCurrentSkillContext != null ) {
            m_pCurrentSkillContext.cancelSkill();
            m_nSkillID = 0;
            m_nSkillSpeed = 1.0;
            //重置改技能碰撞框数据
            pComUtility.cAnimation.setCurrentAnimationTag( "", "0" );
        }

        m_pCurrentSkillContext = null;
        if ( pFightNetwork && pFightNetwork.isAsPuppet )
            m_effectContainer.removePuppetAllEffect();
        else
            m_effectContainer.removeAllEffect();
        CSkillDebugLog.logTraceMsg( "**@CSkillCaster 技能结束 skillid = " + m_nSkillID );
    }

    final public function get skillID() : int {
        return m_nSkillID;
    }

    final public function get skillContext() : CSkillCasterContext {
        return m_pCurrentSkillContext;
    }

    // exit current attack state;
    final internal function get skillAnimationEndCB() : Function {
        return m_skillAnimationEndCB;
    }

    public static function get skillDB() : CSkillDataBase {
        return m_skillDB;
    }

    final public function get pProperty() : CCharacterProperty {
        return owner.getComponentByClass( CCharacterProperty, true ) as CCharacterProperty;
    }

    final private function get pStateboard() : CCharacterStateBoard {
        return owner.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
    }

    public function getRunningHitEffect( hitID : int ) : CSkillHit {
        return _getRunningSkillEffect( EEffectType.E_HIT, hitID ) as CSkillHit;
    }

    private function _getRunningSkillEffect( effType : int, effID : int ) : CAbstractSkillEffect {
        return m_effectContainer.getEffect( effType, effID );
    }

    public function removeRunningTypeEffect( effType : int ) : void {
        var effes : Array = m_effectContainer.getEffectsByType( effType );
        for each( var item : CAbstractSkillEffect in effes ) {
            if ( item.isRunning )
                m_effectContainer.removeSkillEffect( item );
        }
    }

    public function getEffectsByType( effType : int ) : Array{
        return m_effectContainer.getEffectsByType( effType );
    }

    public function removeSkillEffect( eff : CAbstractSkillEffect ) : void{
        m_effectContainer.removeSkillEffect( eff );
    }

    public function removeEffectByType( effType : int ) : void {
        m_effectContainer.removeEffectByType( effType );
    }

    final public function get pComUtility() : CComponentUtility {
        return m_pComUtility;
    }

    final public function get missileContainer() : CMissileContainer {
        return m_pMissileContainer;
    }

    final private function get pAnimation() : IAnimation {
        return owner.getComponentByClass( IAnimation, true ) as IAnimation;
    }

    private function _onEffectsLoaded( theEffJson : CURLJson, iError : int ) : void {
        if ( iError == 0 ) {
            m_timelineEffectsMap = new CMap();
            var parseJson : Object = theEffJson.jsonObject.timelineeffect;
            for ( var key : String in parseJson ) {
                m_timelineEffectsMap.add( key, parseJson[ key ] as Array )
            }
            ;

            m_collisionEffectsMap = new CMap();
            parseJson = theEffJson.jsonObject.collisioneffect;
            for ( key in parseJson ) {
                m_collisionEffectsMap.add( key, parseJson[ key ] );
            }
            m_boEffectReady = m_boEffectReady;
        }
        else {
            CSkillDebugLog.logTraceMsg( "the model " + m_modelName + "load skill effect json fail , pls check the file" );
        }
    }

    private function _onTimeLineEffectsLoaded( theEffJson : CJsonLoader, iError : int ) : void {
        if ( iError == 0 ) {
            m_timelineEffectsMap = new CMap();
            m_timelineEffectResource = theEffJson.createResource();
            var parseJson : Object = m_timelineEffectResource.theObject.timelineEffect;
            for ( var key : String in parseJson ) {
                m_timelineEffectsMap.add( key, parseJson[ key ] as Array )
            }
            ;
        } else {
            CSkillDebugLog.logTraceMsg( "the model " + m_modelName + "load skill timelineeffect json fail , pls check the file" );
        }

        _setReady( TIMELINE_READY );
    }

    private function _onCollisionEffectsLoaded( theEffJson : CJsonLoader, iError : int ) : void {
        if ( iError == 0 ) {
            m_collisionEffectsMap = new CMap();
            m_collisionEffectResource = theEffJson.createResource();
            var parseJson : Object = m_collisionEffectResource.theObject.collisioneffect;
            for ( var key : String in parseJson ) {
                m_collisionEffectsMap.add( key, parseJson[ key ] );
            }
        } else {
            CSkillDebugLog.logTraceMsg( "the model " + m_modelName + "load skill collisioneffect json fail , pls check the file" );
        }

        _setReady( COLLISION_READY );
    }

    private function _onPackedFileLoaded( loader : CPackedQsonLoader, iError : int ) : void {
        if ( iError == 0 ) {
            m_packedResource = loader.createResource();
        }

        if ( m_fnLoadPackedFinished != null ) m_fnLoadPackedFinished();
    }

    private function _onActionsLoaded( theActionJson : CJsonLoader, iError : int ) : void {
        if ( iError == 0 ) {
            m_actionsMap = new CMap();
            m_ActionResource = theActionJson.createResource();
            var actionJson : Object = m_ActionResource.theObject.actionseq;
            m_actionsMap.append( actionJson, "skillName", ActionSeq );
            _buildAnimation();
        }
        else {
            CSkillDebugLog.logTraceMsg( "the model " + m_modelName + "load ActionSeq json fail , pls check the file " );
        }
        _setReady( ACTION_READY );
    }

    private function _setReady( flag : int ) : void {
        switch ( flag ) {
            case COLLISION_READY:
                m_boCollisionReady = true;
                break;
            case TIMELINE_READY:
                m_boTimeLineReady = true;
                break;
            case ACTION_READY :
                m_boActionReady = true;
                break;
        }

        if ( m_boActionReady && m_boTimeLineReady && m_boCollisionReady ) {
            var pEventMediator : CEventMediator = this.getComponent( CEventMediator ) as CEventMediator;
            if ( pEventMediator ) {
                m_boSkillReady = true;
                pEventMediator.dispatchEvent( new CCharacterEvent( CCharacterEvent.SKILL_COMP_READY, owner ) );
            }
        }
    }

    private function _onAnimationReady( e : CCharacterEvent ) : void {
        if ( !m_boActionBuild )
            _buildAnimation();
    }


    private function _buildAnimation() : void {
        if ( owner == null ) return;
        var pDisplay : CBaseDisplay = owner.getComponentByClass( CBaseDisplay, true ) as CBaseDisplay;
        if ( pDisplay == null ) return;

        if ( pDisplay.isReady ) {
            if ( m_actionsMap ) {
                for ( var key : String in m_actionsMap ) {
                    if ( "AnimationName" in m_actionsMap[ key ] ) {
                        var pAnimationNames : Array = m_actionsMap[ key ].AnimationName;
                        for each( var aniName : String in pAnimationNames ) {
                            if ( !aniName.length ) continue;
                            pAnimation.addSkillAnimationState( aniName.toUpperCase(), aniName );
                        }
                    }
                }
                m_boActionBuild = true;
            }
        }
    }

    public function getSkillActionsByActionFlag( actionFlag : String ) : ActionSeq {
        return m_actionsMap[ actionFlag ] as ActionSeq;
    }

    public function getSkillEffectsByActionFlag( actionFlag : String ) : Array {
        return null;
    }

    final public function get AnimationSeqTime() : Number {
        if ( m_pCurrentSkillContext == null ) return 0.0;
        return m_pCurrentSkillContext.AnimationSeqTime;
    }

    public function get boToExitSkill() : Boolean {
        return m_boToExitSkill;
    }

    public function set boToExitSkill( boExit : Boolean ) : void {
        m_boToExitSkill = boExit;
    }

    public function get boSkillReady() : Boolean {
        return m_boSkillReady;
    }

    public function findMissile( missileID : int, missileSeq : int ) : CGameObject {
        return m_pMissileContainer.findMissile( missileID, missileSeq );
    }

    public function findMissileBySeq( missileSeq : int ) : CGameObject {

        return m_pMissileContainer.findMissileByUniqID( missileSeq );
    }

    public function set skillSpeed( speed : Number ) : void {
        if ( speed == this.m_nSkillSpeed ) return;
        this.m_nSkillSpeed = speed;

        m_pComUtility.cAnimation.speedUpAnimation( m_nSkillSpeed );
    }

    public function get skillSpeed() : Number {
        return m_nSkillSpeed;
    }

    [inline]
    final private function get pSkillCatchers() : CSkillCatcher {
        return owner.getComponentByClass( CSkillCatcher, true ) as CSkillCatcher;
    }

    final private function get pFightNetwork() : CCharacterNetworkInput {
        return owner.getComponentByClass( CCharacterNetworkInput, true ) as CCharacterNetworkInput;
    }

    private var m_skillContextMap : CMap;
    private var m_pCurrentSkillContext : CSkillCasterContext;
    private var m_fTickTime : Number;
    private var m_nSkillID : int;
    private var m_skillAnimationEndCB : Function;
    private static var m_skillDB : CSkillDataBase;
    public static var logSkillMsg : Boolean = true;
    private var m_effectContainer : CSkillEffectContainer;
    private var m_emmiterContainer : CEmitterContainer;
    private var m_pComUtility : CComponentUtility;
    private var m_skillEvaluator : CSkillEvaluator;
    private var m_pMissileContainer : CMissileContainer;
    private var m_pFightHandler : CFightHandler;
    private var m_modelName : String;
    private var m_timelineEffectsMap : CMap;
    private var m_collisionEffectsMap : CMap;
    private var m_actionsMap : CMap;
    private var m_boActionBuild : Boolean;
    private var m_boActionReady : Boolean;
    private var m_boEffectReady : Boolean;
    private var m_boTimeLineReady : Boolean;
    private var m_boCollisionReady : Boolean;
    private var m_boToExitSkill : Boolean;
    private var m_boSkillReady : Boolean;
    private var m_nSkillSpeed : Number = 1.0;

    private var m_fnLoadPackedFinished : Function;

    private var m_packedResource : CResource;
    private var m_ActionResource : CResource;
    private var m_collisionEffectResource : CResource;
    private var m_timelineEffectResource : CResource;
    private var m_bAtomRoundBegine : Boolean;

    private const COLLISION_READY : int = 1;
    private const TIMELINE_READY : int = 2;
    private const ACTION_READY : int = 3;
    private const SKILL_ATOM_FRAME : Number = 0.018;
    private const SKILL_MAX_LATENESS_TOLERAT : Number = 0.33;
    private var m_theLogicFrameLoop : CLogicFrameLoop;
    static public const S_EXCLUSI_EFFECT : Array = [ EEffectType.E_HIT, EEffectType.E_HEALING,
        EEffectType.E_TELETPORT, EEffectType.E_CATCH,
        EEffectType.E_CATCH_END, EEffectType.E_BULLET ];

}
}
