//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/11/5.
//----------------------------------------------------------------------
package kof.game.character.fight.sync {

import QFLib.Foundation;
import QFLib.Foundation.CMap;
import QFLib.Framework.CObject;
import QFLib.Interface.IUpdatable;
import QFLib.Math.CMath;
import QFLib.Math.CMath;
import QFLib.Math.CVector2;
import QFLib.Math.CVector3;
import QFLib.Math.CVector3;
import QFLib.ResourceLoader.CMP3Loader;

import flash.geom.Point;
import flash.utils.Dictionary;

import kof.framework.fsm.CFiniteStateMachine;
import kof.game.character.CCharacterDataDescriptor;

import kof.game.character.CFacadeMediator;

import kof.game.character.CKOFTransform;
import kof.game.character.animation.IAnimation;
import kof.game.character.display.IDisplay;
import kof.game.character.fight.CCharacterNetworkInput;
import kof.game.character.fight.CFightTextConst;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.fight.skill.CSkillDataBase;
import kof.game.character.fight.skill.CSkillDebugLog;
import kof.game.character.fight.skill.CSkillHit;
import kof.game.character.fight.skillcalc.CFightCalc;
import kof.game.character.fight.skillcalc.ECalcStateRet;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.character.fight.skilleffect.CSkillCatchEffect;
import kof.game.character.fight.skilleffect.CSkillCatchEndEffect;
import kof.game.character.fight.sync.CCharacterSyncBoard;
import kof.game.character.fight.sync.CCharacterSyncBoard;
import kof.game.character.fight.skill.CHitStateInfo;
import kof.game.character.fight.sync.syncentity.CHitStateSync;
import kof.game.character.fight.sync.synctimeline.CFightTimeLineFacade;
import kof.game.character.fight.sync.synctimeline.base.action.EFighterActionType;
import kof.game.character.fight.sync.synctimeline.base.strategy.base.CBaseStrategy;
import kof.game.character.fx.CFXMediator;
import kof.game.character.movement.CMovement;
import kof.game.character.property.CCharacterProperty;
import kof.game.character.scripts.CFightFloatSprite;
import kof.game.character.state.CCharacterActionStateConstants;
import kof.game.character.state.CCharacterFSMHandler;
import kof.game.character.state.CCharacterInput;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.character.state.CCharacterStateMachine;

import kof.game.core.CGameComponent;
import kof.game.core.CGameObject;
import kof.game.core.CGameObject;
import kof.game.scene.ISceneFacade;

import kof.message.CAbstractPackMessage;
import kof.message.Fight.AskPropertyResponse;
import kof.message.Fight.CatchResponse;
import kof.message.Fight.DodgeResponse;
import kof.message.Fight.ExitSkillResponse;
import kof.message.Fight.FightMissileAbsorbResponse;
import kof.message.Fight.FightMissileActivateResponse;
import kof.message.Fight.HealResponse;
import kof.message.Fight.HitResponse;
import kof.message.Fight.SkillCastResponse;
import kof.table.Hit;
import kof.table.Motion;
import kof.table.Motion.EMotionType;

/**
 * 处理网络输入的战斗序列
 */
public class CCharacterResponseQueue extends CGameComponent implements IUpdatable {

    public function CCharacterResponseQueue( sceneFacade : ISceneFacade ) {
        super( "responseQueue" );
        m_pSceneFacade = sceneFacade;
    }

    override protected function onEnter() : void {
        super.onEnter();
        attackEventListener();

        m_curSkillQueue = new CSkillQueueSeq();
        m_curSkillQueue.queueID = 1;

        m_curHitQueue = new CHitQueueSeq();
        m_curHitQueue.queueID = 1;

        m_msgList = new Vector.<HitResponse>();

        m_dirtyMap = new CMap( false );
        m_msgListMap = new CMap( false );

        m_dirtyMap[ CATCH_MSG ] = false;
        m_msgListMap[ CATCH_MSG ] = new Array;

        m_pStrategysQueue = new <CBaseStrategy>[];

        setDefault();
    }

    public function addResponseStrategy( strategy : CBaseStrategy ) : void {
        if ( null == strategy )
            return;
        m_pStrategysQueue.push( strategy );
    }

    public function delResponseStrategy( stategy : CBaseStrategy ) : void {
        var index : int = m_pStrategysQueue.indexOf( stategy );
        var list : Vector.<CBaseStrategy>;
        if ( index > -1 ) {
            list = m_pStrategysQueue.splice( index, 1 );
            for each( var delStr : CBaseStrategy in list ) {
                delStr.dispose();
                delStr = null;
            }
        }
    }

    public function getStrategyQueueList() : Vector.<CBaseStrategy> {
        var ret : Vector.<CBaseStrategy> = new <CBaseStrategy>[];
        for each( var stategy : CBaseStrategy in m_pStrategysQueue ) {
            var index : int = ret.indexOf( stategy );
            if ( index < 0 )
                ret.push( stategy );
        }

        return ret;
    }

    public function clearStrategyQueue() : void {
        if ( m_pStrategysQueue && m_pStrategysQueue.length > 0 ) {
            m_pStrategysQueue.splice( 0, m_pStrategysQueue.length );
        }
    }


    protected function setDefault() : void {
        var list : Array;
        for ( var key : int in m_msgListMap ) {
            list = m_msgListMap[ key ];
            list.splice( 0, list.length );
            list.length = 0;
        }

        for ( var dirKey : int in m_dirtyMap ) {
            m_dirtyMap[ dirKey ] = false;
        }
    }

    public function addNetordFightMsg( type : int, msg : CAbstractPackMessage ) : void {
        var list : Array;
        list = m_msgListMap[ type ];
        list.push( msg );
        m_msgListMap[ type ] = list;
        m_dirtyMap[ type ] = true;
    }

    override protected function onExit() : void {
        super.onExit();
        dettackEventListener();

        m_curSkillQueue = null;
        m_curHitQueue = null;

        if ( m_msgList ) {
            m_msgList.splice( 0, m_msgList.length );
        }

        m_msgList = null;

        var list : Array;
        for ( var key : int in m_msgListMap ) {
            list = m_msgListMap[ key ];
            list.splice( 0, list.length );
            list = null;
        }

        m_msgListMap.clear();
        m_msgListMap = null;

        for ( key in m_dirtyMap ) {
            m_dirtyMap[ key ] = false;
        }

        if ( m_pStrategysQueue )
            m_pStrategysQueue.splice( 0, m_pStrategysQueue.length );
        m_pStrategysQueue = null;

        m_dirtyMap.clear();
        m_dirtyMap = null;
    }

    private function dettackEventListener() : void {
        var fightTriggle : CCharacterFightTriggle = owner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
        if ( fightTriggle ) {
            fightTriggle.removeEventListener( CFightTriggleEvent.RESPONSE_FIGHT_SKILL, _responseFightSkill );
            fightTriggle.removeEventListener( CFightTriggleEvent.RESPONSE_DODGE, _responseDodge );
            fightTriggle.removeEventListener( CFightTriggleEvent.RESPONSE_FIGHT_SKILL_EXIT, _responseSkillExit );
            fightTriggle.removeEventListener( CFightTriggleEvent.RESPONSE_SYNC_PROPERTY, _responseSyncProperty );
        }
    }

    private function attackEventListener() : void {
        if ( CCharacterDataDescriptor.isRobot( owner.data ) )
            return;
        var fightTriggle : CCharacterFightTriggle = owner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
        if ( fightTriggle ) {
            fightTriggle.addEventListener( CFightTriggleEvent.RESPONSE_FIGHT_SKILL, _responseFightSkill );
            fightTriggle.addEventListener( CFightTriggleEvent.RESPONSE_DODGE, _responseDodge );
            fightTriggle.addEventListener( CFightTriggleEvent.RESPONSE_FIGHT_SKILL_EXIT, _responseSkillExit );
            fightTriggle.addEventListener( CFightTriggleEvent.RESPONSE_SYNC_PROPERTY, _responseSyncProperty );
        }
    }

    private function _responseFightSkill( e : CFightTriggleEvent ) : void {
        var msg : SkillCastResponse;
        msg = e.parmList[ 0 ] as SkillCastResponse;

        if ( msg == null ) {
            CSkillDebugLog.logTraceMsg( "responser has no data" );
            return;
        }
        var nodeTime : Number = msg.dynamicStates[ CCharacterSyncBoard.QUEUE_SEQ_TIME ];
        _syncOthersTimeLine( EFighterActionType.E_SKILL_ACTION, nodeTime, msg );
    }

    /**
     * 同步stateboard状态
     * @param target
     * @param bIgnoreAtkPwd
     * @param bIngnoreDefPwd
     * @param bIgnoreRagePwd
     */
    private function _syncToStateBoard( target : CGameObject, bIgnoreAtkPwd : Boolean = false,
                                        bIngnoreDefPwd : Boolean = false, bIgnoreRagePwd : Boolean = false ) : void {
        var pCharacterProperty : CCharacterProperty = target.getComponentByClass( CCharacterProperty, true ) as CCharacterProperty;
        var pSyncBoard : CCharacterSyncBoard = target.getComponentByClass( CCharacterSyncBoard, true ) as CCharacterSyncBoard;
        var pStateBoard : CCharacterStateBoard = target.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
        if ( pCharacterProperty && pSyncBoard.isDirty ) {
            if ( !bIgnoreRagePwd )
                pCharacterProperty.RagePower = pSyncBoard.getValue( CCharacterSyncBoard.RAGE_POWER );
            if ( !bIgnoreAtkPwd )
                pCharacterProperty.AttackPower = pSyncBoard.getValue( CCharacterSyncBoard.ATTACK_POWER );
            if ( !bIngnoreDefPwd )
                pCharacterProperty.DefensePower = pSyncBoard.getValue( CCharacterSyncBoard.DEFENSE_POWER );

            var dir : int = pSyncBoard.getValue( CCharacterSyncBoard.SKILL_DIR );
            pStateBoard.setValue( CCharacterStateBoard.DIRECTION, new Point( dir, 0 ) );
        }
    }

    private function _reDiretion( target : CGameObject, dirX : Number, dirY : Number, syncForce : Boolean = true ) : void {
        var pInput : CCharacterInput = target.getComponentByClass( CCharacterInput, true ) as CCharacterInput;
        if ( !pInput ) {
            CSkillDebugLog.logTraceMsg( "Character doesn't contains a CCharacterInput, but it's message supported." );
        } else {
            pInput.wheel = new Point( dirX, dirY );
        }
    }

    private function _syncOthersTimeLine( type : int, nodetime : Number, msg : CAbstractPackMessage ) : void {
        var pTimeLineFacade : CFightTimeLineFacade = owner.getComponentByClass( CFightTimeLineFacade, true ) as CFightTimeLineFacade;
        if ( !pTimeLineFacade || !pTimeLineFacade.bStarted )
            return;
        pTimeLineFacade.insertMsgByType( type, nodetime, msg );
    }

    private function _reLocatePosition( target : CGameObject, posX : Number, poxY : Number, boForceNotSync : Boolean = false, fHeight : Number = 0.0 ) : void {
        var targetDisplay : IDisplay = target.getComponentByClass( IDisplay, true ) as IDisplay;
        var targetSyncBoard : CCharacterSyncBoard = target.getComponentByClass( CCharacterSyncBoard, true ) as CCharacterSyncBoard;
        var boGround : Boolean = targetSyncBoard.getValue( CCharacterSyncBoard.BO_ON_GROUND );
        if ( targetDisplay && targetDisplay.modelDisplay ) {
            targetDisplay.modelDisplay.setPositionToFrom2D( posX, poxY, fHeight );
            target.transform.x = targetDisplay.modelDisplay.position.x;
            target.transform.y = targetDisplay.modelDisplay.position.z;
            target.transform.z = targetDisplay.modelDisplay.position.y;
        }
    }

    public function handleCatchMsg( catMsg : CatchResponse ) : void {
        var msg : CatchResponse = catMsg;
        var targets : Array = [];
        var target : CGameObject;

        var nodeTime : Number = msg.dynamicStates[ CCharacterSyncBoard.QUEUE_SEQ_TIME ];
        _syncOthersTimeLine( EFighterActionType.E_CATCH_ACTION, nodeTime, msg );

        return;

        if ( !verifyNetworkCatch( msg ) ) {
            _syncTargetsPropertyFromCatchRes( msg );
            return;
        }

        for each( var obj : Object in msg.targets ) {
            target = _findTargetByType( obj.type, obj.ID );
            targets.push( target );
        }

        if ( msg.bCatchEnd == 0 )
            pSkillCaster.castCatchToTargets( msg.catchId, targets );
        else
            pSkillCaster.castCatchEndToTarget( msg.catchId, targets );
    }

    private function _responseFightHit( hRes : HitResponse ) : void {
        var msg : HitResponse;
        msg = hRes;

        var nodeTime : Number = msg.dynamicStates[ CCharacterSyncBoard.QUEUE_SEQ_TIME ];
        _syncOthersTimeLine( EFighterActionType.E_HIT_ACTION, nodeTime, msg );

    }

    private function _syncTargetsPropertyFromHitRes( msg : HitResponse ) : void {
        _syncTargetsProperty( msg.targets );
    }

    private function _syncTargetsPropertyFromCatchRes( msg : CatchResponse ) : void {
        _syncTargetsProperty( msg.targets );
    }

    /**
     * 无论如何都要同步血 不管有没有击打
     * @param targetsSynsInfo
     */
    private function _syncTargetsProperty( targetsSynsInfo : Array ) : void //msg : HitResponse ) : void
    {
        var targetList : Array = targetsSynsInfo;
        var syncInfo : CSyncHitTargetEntity;
        var targetProperty : CCharacterProperty;
        var targetStateBoard : CCharacterStateBoard;
        if ( targetList != null ) {
            var hitTarget : CGameObject;
            if ( m_pSceneFacade ) {
                for each( var targetInfo : Object in targetList ) {
                    /**同步的时候要验证击打是否有了*/
                    syncInfo = new CSyncHitTargetEntity();
                    syncInfo.createTargetEntity( targetInfo );
                    hitTarget = m_pSceneFacade.findPlayer( syncInfo.ID );
                    if ( hitTarget ) {
                        targetProperty = hitTarget.getComponentByClass( CCharacterProperty, true ) as CCharacterProperty;
                        targetStateBoard = hitTarget.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
                        targetProperty.HP = syncInfo.dynamicStates[ CCharacterSyncBoard.CURRENT_HP ];
                        targetProperty.DefensePower = syncInfo.dynamicStates[ CCharacterSyncBoard.DEFENSE_POWER ] - syncInfo.dynamicStates[ CCharacterSyncBoard.DEFENSE_POWER_DELTA ];

                        var syncDir : int = syncInfo.dynamicStates[ CCharacterSyncBoard.SKILL_DIR ];
                        targetStateBoard.setValue( CCharacterStateBoard.DIRECTION, new Point( syncDir, 0 ) );
                    }
                }
            }
        }
    }

    /**
     * 加入闪避
     * @param e
     */
    private function _responseDodge( e : CFightTriggleEvent ) : void {
        var msg : DodgeResponse;
        msg = e.parmList[ 0 ] as DodgeResponse;

        if ( msg == null ) {
            CSkillDebugLog.logTraceMsg( "responser has no data" );
            return;
        }

        var nodeTime : Number = msg.dynamicStates[ CCharacterSyncBoard.QUEUE_SEQ_TIME ];
        _syncOthersTimeLine( EFighterActionType.E_DODGE_ACTION, nodeTime, msg );

    }

    private function _responseSkillExit( e : CFightTriggleEvent ) : void {
        var msg : ExitSkillResponse;
        msg = e.parmList[ 0 ] as ExitSkillResponse;

        if ( msg == null ) {
            CSkillDebugLog.logTraceMsg( "responser has no data" );
            return;
        }

        var nodeTime : Number = msg.dynamicStates[ CCharacterSyncBoard.QUEUE_SEQ_TIME ];
        _syncOthersTimeLine( EFighterActionType.E_SKILL_END_ACTION, nodeTime, msg );

    }

    private function _responseSyncProperty( e : CFightTriggleEvent ) : void {
        var msg : Object;
        msg = e.parmList[ 0 ] as Object;
        if ( msg == null ) {
            CSkillDebugLog.logTraceMsg( "responser has no data" );
            return;
        }
    }

    /**
     * 验证本地是否可以执行
     * @param localQueueID
     * @param localSkillID
     * @return
     */
    public function verifyFightSkillLocalQueue( localQueueID : int, localSkillID : int ) : Boolean {
        var pNetInput : CCharacterNetworkInput = owner.getComponentByClass( CCharacterNetworkInput, true ) as CCharacterNetworkInput;
        if ( !pNetInput )
            return true;

        if ( pNetworkInput.isAsHost )
            return true;

        if ( localQueueID - 1 == m_curSkillQueue.queueID ) {
            return true;
            Foundation.Log.logTraceMsg( " 技能链 ：本地queueID ： " + localQueueID + " 网络queueID ： " + m_curSkillQueue.queueID );
        }

        return false;
    }

    public function getBoSpellSkillAheadHost() : Boolean {
        if ( !pNetworkInput )
            return true;

        var localSkillQueue : CSkillQueueSeq = pNetworkInput.localSkillQueue;
        if ( pNetworkInput.isAsHost )
            return true;

        if ( currentSkillQueue.queueID <= localSkillQueue.queueID )
            return true;
        return false;
    }

    //验证服务端的击打是否要强制同步
    private function verifyNetworkHitQueue( msg : HitResponse ) : Boolean {
        var pNetInput : CCharacterNetworkInput = owner.getComponentByClass( CCharacterNetworkInput, true ) as CCharacterNetworkInput;
        var targetQueueID : Number;
        var targetList : Array = msg.targets;
        if ( targetList != null ) {
            var syncInfo : CSyncHitTargetEntity = new CSyncHitTargetEntity();
            syncInfo.createTargetEntity( targetList[ 0 ] );
            targetQueueID = syncInfo.queueID;

            m_curHitQueue.queueID = targetQueueID;
            m_curHitQueue.hitID = msg.hitId;
            m_curHitQueue.skillID = msg.skillID;
            m_curHitQueue.queueSeqTime = syncInfo.dynamicStates.queueSeqTime;


            if ( targetQueueID > pNetInput.hitQueueID ) {
                m_boBanNextLocalHit = true;
//                pNetInput.syncHitQueueID( targetQueueID );
                Foundation.Log.logMsg( " 收到网络击打-》 " + " 当前网络包ID:" + targetQueueID + "本地击打ID ：" + pNetInput.hitQueueID );
                return true;

            }
            else {
                return false;
            }
        }

        return false;
    }

    private function verifyNetworkCatch( msg : CatchResponse ) : Boolean {
        var skillCaster : CSkillCaster = pSkillCaster;
        var skillId : int = msg.skillID;
        var catchId : int = msg.catchId;
        var inputCatchIndexID : int = msg.catchQueueID;
        var localCatchQueueID : int;

        if ( skillCaster ) {
            var bStillInSkill : Boolean = skillCaster.isInSpecifySkill( skillId );
            if ( bStillInSkill ) {
                localCatchQueueID = pNetworkInput.skillCatchQueueID;

                if ( inputCatchIndexID > localCatchQueueID ) {
                    //cast new coming catch
                    pNetworkInput.skillCatchIndexID = inputCatchIndexID;
                    return true;
                }
            }
        }
        return false;
    }

    private var m_boBanNextLocalHit : Boolean;

    //验证客户端击打是否可以执行
    public function verifyLocalHitQueue( localQueueID : int, localSkillID : int, localHitID : int ) : Boolean {
        //如果没有网络组件
        var pNetInput : CCharacterNetworkInput = owner.getComponentByClass( CCharacterNetworkInput, true ) as CCharacterNetworkInput;
        if ( pNetInput.isAsHost )
            return true;

        if ( !pNetInput )
            return true;

        if ( CCharacterDataDescriptor.isRobot( owner.data ) )
            return true;

        var syncQueueID : Number = m_curHitQueue.queueID;
        if ( localQueueID < syncQueueID ) {
            if ( pNetInput )
                pNetInput.syncHitQueueID( syncQueueID );
            return false;
        }

        if ( m_boBanNextLocalHit )
            return false;

        //多于2帧则判断本地为无效击打了
        if ( localQueueID > syncQueueID + 1 )
            return false;

        Foundation.Log.logMsg( " 执行本地击打-》 " + " 当前网络包ID:" + syncQueueID + "本地击打ID ：" + localQueueID );
        return true;
    }

    public function update( delta : Number ) : void {
        if ( dirty ) {
            var lastMsg : HitResponse;
            var msgList : Vector.<HitResponse> = m_msgList.splice( 0, m_msgList.length );
            for ( var i : int = 0; i < msgList.length; i++ ) {
                lastMsg = msgList[ i ];
                if ( lastMsg ) {
                    _syncHitResponse( lastMsg );
                }
            }
            dirty = false;
            m_msgList.length = 0;
        }

        var bDirty : Boolean;
        var incomeMsgs : Array;
        for ( var key : int in m_dirtyMap ) {
            bDirty = m_dirtyMap[ key ];

            if ( bDirty ) {
                incomeMsgs = m_msgListMap[ key ];
                if ( key == CATCH_MSG ) {
                    for each( var catchMsg : CatchResponse in incomeMsgs ) {
                        _handleCatchMsg( catchMsg );
                    }
                }
                m_dirtyMap[ key ] = false;
                incomeMsgs.splice( 0, incomeMsgs.length );
                incomeMsgs.length = 0;
                m_msgListMap[ key ] = incomeMsgs;
            }
        }
    }

    private function _handleCatchMsg( catchMsg : CatchResponse ) : void {
        var msg : CatchResponse = catchMsg;
        if ( msg == null )
            return;
        _handleCatchMsg( catchMsg );
    }

    final private function get pFightTrigger() : CCharacterFightTriggle {
        return owner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
    }

    final private function get pStateBoard() : CCharacterStateBoard {
        return owner.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
    }

    final private function get pTransform() : CKOFTransform {
        return owner.getComponentByClass( CKOFTransform, true ) as CKOFTransform;
    }

    final private function get pSkillCaster() : CSkillCaster {
        return owner.getComponentByClass( CSkillCaster, true ) as CSkillCaster;
    }

    final private function get pNetworkInput() : CCharacterNetworkInput {
        return owner.getComponentByClass( CCharacterNetworkInput, true ) as CCharacterNetworkInput;
    }

    final private function get pFXMediator() : CFXMediator {
        return owner.getComponentByClass( CFXMediator, true ) as CFXMediator;
    }

    public function get curHitQueue() : CHitQueueSeq {
        return m_curHitQueue;
    }

    public function get curSkillQueue() : CSkillQueueSeq {
        return m_curSkillQueue;
    }

    public function setCurSkillQueue( skillID : int, queueID : int, seqTime : Number ) : void {
        m_curSkillQueue.skillID = skillID;
        m_curSkillQueue.queueID = queueID;
        m_curSkillQueue.queueSeqTime = seqTime;
    }

    private function _syncHitResponse( lastMsg : HitResponse ) : void {
        _responseFightHit( lastMsg );
    }

    public function handleHitResponse( msg : HitResponse ) : void {
        _syncHitResponse( msg );
    }

    public function handleMissileAbsorb( msg : FightMissileAbsorbResponse ) : void {
        var nodeTime : Number = msg.dynamicStates[ CCharacterSyncBoard.QUEUE_SEQ_TIME ];
        _syncOthersTimeLine( EFighterActionType.E_ABSORB_MISSILE, nodeTime, msg );
    }

    public function handleMissileActivate( msg : FightMissileActivateResponse ) : void{
        var nodeTime : Number = msg.dynamicStates[ CCharacterSyncBoard.QUEUE_SEQ_TIME ];
        _syncOthersTimeLine( EFighterActionType.E_ACTIVATE_MISSILE, nodeTime, msg );
    }

    public function handleHealResponse( msg : HealResponse ) : void {
        var nodeTime : Number = msg.dynamicStates[ CCharacterSyncBoard.QUEUE_SEQ_TIME ];
        _syncOthersTimeLine( EFighterActionType.E_HEAL_ACTION, nodeTime, msg );
    }

    final public function get dirty() : Boolean {
        return m_dirty;
    }

    final public function set dirty( value : Boolean ) : void {
        m_dirty = value;
    }

    private function _findTargetByType( type : int, targetID : int ) : CGameObject {
        var target : CGameObject;
        if ( type == CCharacterDataDescriptor.TYPE_PLAYER ) {
            target = m_pSceneFacade.findPlayer( targetID );
        } else if ( type == CCharacterDataDescriptor.TYPE_MONSTER ) {
            target = m_pSceneFacade.findMonster( targetID );
        } else {
            Foundation.Log.logWarningMsg( "Unknow type of Character " );
        }

        return target;
    }

    public function get currentSkillQueue() : CSkillQueueSeq {
        return m_curSkillQueue;
    }

    private var m_msgList : Vector.<HitResponse>;
    private var m_catchList : Vector.<CatchResponse>;
    private var m_dirty : Boolean;
    private var m_curSkillQueue : CSkillQueueSeq;
    private var m_curHitQueue : CHitQueueSeq;
    private var m_pSceneFacade : ISceneFacade;
    private var m_pStrategysQueue : Vector.<CBaseStrategy>;

    private var m_dirtyMap : CMap;
    private var m_msgListMap : CMap;

    public static const CATCH_MSG : int = 1;
    public static const HIT_MSG : int = 2;
}
}

