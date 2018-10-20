//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.fight {

import QFLib.Foundation;
import QFLib.Foundation.CTimeDog;
import QFLib.Foundation.CWeakRef;
import QFLib.Framework.CFX;
import QFLib.Framework.CFramework;
import QFLib.Graphics.Character.CAnimationBounds;
import QFLib.Interface.IUpdatable;
import QFLib.Math.CVector3;

import flash.events.Event;

import flash.geom.Point;
import flash.utils.getTimer;

import kof.framework.CAppSystem;
import kof.framework.INetworking;
import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.CCharacterEvent;
import kof.game.character.ai.CAIComponent;
import kof.game.character.ai.CAIHandler;
import kof.game.character.animation.IAnimation;
import kof.game.character.display.IDisplay;
import kof.game.character.fight.buff.CBuffContainer;
import kof.game.character.fight.catches.CSkillCatcher;
import kof.game.character.fight.emitter.CMissileContainer;
import kof.game.character.fight.emitter.CMissileIdentifersRepository;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.fight.skill.CSkillDebugLog;
import kof.game.character.fight.skillcalc.CCalcEntity;
import kof.game.character.fight.skillcalc.CFightCDCalc;
import kof.game.character.fight.skillcalc.CFightCalc;
import kof.game.character.fight.skillcalc.ERPRecoveryType;
import kof.game.character.fight.skillcalc.hurt.CFightProperty;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.character.fight.skilleffect.util.CSkillScreenIns;
import kof.game.character.fight.sync.CCharacterResponseQueue;
import kof.game.character.fight.sync.CCharacterSyncBoard;
import kof.game.character.fight.sync.synctimeline.CFightTimeLineFacade;
import kof.game.character.fight.sync.synctimeline.base.CFightSyncNodeData;
import kof.game.character.fight.sync.synctimeline.base.CFightTimeLine;
import kof.game.character.fight.sync.synctimeline.base.action.EFighterActionType;
import kof.game.character.fight.targetfilter.CFightEvent;
import kof.game.character.fx.CFXMediator;
import kof.game.character.handler.CPlayHandler;
import kof.game.character.property.CCharacterProperty;
import kof.game.character.scripts.CPlayerIndexSprite;
import kof.game.character.scripts.CRootRingSpirte;
import kof.game.character.state.CCharacterActionStateConstants;
import kof.game.character.state.CCharacterAttackState;
import kof.game.character.state.CCharacterDodgeState;
import kof.game.character.state.CCharacterIdleState;
import kof.game.character.state.CCharacterInput;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.character.state.CCharacterStateMachine;
import kof.game.core.CECSLoop;
import kof.game.core.CGameObject;
import kof.game.core.CGameSystemHandler;
import kof.game.instance.IInstanceFacade;
import kof.game.scene.CSceneEvent;
import kof.game.scene.CSceneSystem;
import kof.game.scene.ISceneFacade;
import kof.message.CAbstractPackMessage;
import kof.message.Fight.AskPropertyResponse;
import kof.message.Fight.CatchResponse;
import kof.message.Fight.DodgeResponse;
import kof.message.Fight.ExitSkillResponse;
import kof.message.Fight.FightMissileAbsorbRequest;
import kof.message.Fight.FightMissileAbsorbResponse;
import kof.message.Fight.FightMissileActivateResponse;
import kof.message.Fight.FightMissileDeadRequest;
import kof.message.Fight.FightMissileDeadResponse;
import kof.message.Fight.FightMissileIdsResponse;
import kof.message.Fight.FightTimeLineResponse;
import kof.message.Fight.FighterDeadResponse;
import kof.message.Fight.HealResponse;
import kof.message.Fight.HitResponse;
import kof.message.Fight.JumpInputResponse;
import kof.message.Fight.SkillCastResponse;
import kof.message.Fight.SynPropertyResponse;
import kof.message.Pvp.AddBufferResponse;
import kof.message.Pvp.RemoveBufferResponse;
import kof.message.Pvp.UpdateBuffResponse;
import kof.util.CAssertUtils;

/**
 * 战斗系统
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CFightHandler extends CGameSystemHandler implements IUpdatable {

    static public const SUPER_SKILL_FROZEN_DURATION : Number = 0.5;

    /** @private 镜头特写对象，大招定帧者（弱引用） */
    private var m_pClosenessQueue : Vector.<CWeakRef>; // <CGameObject>
    private var m_pClosenessTimeDog : CTimeDog;
    private var m_pClosenessFrozens : Vector.<CWeakRef>; // <CGameObject>

    private var m_pSceneFacade : ISceneFacade;
    private var m_pPlayHandler : CPlayHandler;
    private var m_pFightTimeLine : CFightTimeLine;
    private var m_currentClosenessTime : Number;
    private var m_pFramework : CFramework;
    private var m_pAIHandler : CAIHandler;

    private var m_pInstanceFacade : IInstanceFacade;

    /** */
    public function CFightHandler() {
        super( CSkillCaster );

        m_pClosenessQueue = new <CWeakRef>[];
        m_pClosenessFrozens = new <CWeakRef>[];
        m_pFightTimeLine = _initFightTimeLine();
    }

    public function update( delta : Number ) : void {
        if ( m_pFightTimeLine )
            m_pFightTimeLine.update( delta );
    }

    override protected function enterSystem( system : CAppSystem ) : void {
        super.enterSystem( system );
        m_pSceneFacade = system.stage.getSystem( ISceneFacade ) as ISceneFacade;
        var pGameSystem : CECSLoop = system.stage.getSystem( CECSLoop ) as CECSLoop;
        CAssertUtils.assertNotNull( pGameSystem );
        m_pPlayHandler = pGameSystem.getBean( CPlayHandler ) as CPlayHandler;
        m_pAIHandler = pGameSystem.getBean( CAIHandler ) as CAIHandler;
        m_pFramework = sceneSys.graphicsFramework;
        m_pInstanceFacade = system.stage.getSystem( IInstanceFacade ) as IInstanceFacade;

        CSkillScreenIns.getSkillScreenEffIns().setUpSceneFacade( m_pSceneFacade );
    }

    override protected function onEnabled( value : Boolean ) : void {
        if ( !value ) {
            dispatchEvent( new CFightEvent( CFightEvent.STOP_FIGHT_HDL ) );
        }
    }

    protected override function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        if ( ret ) {
            var networking : INetworking = system.stage.getSystem( INetworking ) as INetworking;
            CAssertUtils.assertNotNull( networking, "INetworking required in CMovementHandler." );
            if ( networking ) {
                networking.bind( SkillCastResponse ).toHandler( onSkillCasterHandler );
                networking.bind( HitResponse ).toHandler( onHitHandler );
                networking.bind( DodgeResponse ).toHandler( onDodgeHandler );
                networking.bind( ExitSkillResponse ).toHandler( onExitSkillHandler );
                networking.bind( FighterDeadResponse ).toHandler( onCharacterDead );
                networking.bind( JumpInputResponse ).toHandler( onJumpInputHandler );
                networking.bind( SynPropertyResponse ).toHandler( onSyncPropertyResponse );
                networking.bind( AddBufferResponse ).toHandler( _onAddBuffResponse );
                networking.bind( RemoveBufferResponse ).toHandler( _onRemoveBuffResponse );
                networking.bind( UpdateBuffResponse ).toHandler( _onTriggerBuffResponse );
                networking.bind( CatchResponse ).toHandler( _onCatchResponse );
                networking.bind( FightTimeLineResponse ).toHandler( _onFightTimeLineRespose );
                networking.bind( HealResponse ).toHandler( _onHealhandler );
                networking.bind( FightMissileIdsResponse ).toHandler( _onMissileIdsResponse );
                networking.bind( FightMissileDeadResponse ).toHandler( _onMissileDeadResponse );
                networking.bind( FightMissileAbsorbResponse ).toHandler( _onMissileAbsorb );
                networking.bind( FightMissileActivateResponse ).toHandler( _onMissileActivate );
                networking.bind( AskPropertyResponse ).toHandler( _onAskProperty );
            }

        }
        return ret;
    }

    override public function dispose() : void {
        super.dispose();
        if ( m_pClosenessQueue && m_pClosenessQueue.length ) {
            m_pClosenessQueue.splice( 0, m_pClosenessQueue.length );
        }
        m_pClosenessQueue = null;

        if ( m_pClosenessFrozens && m_pClosenessFrozens.length )
            m_pClosenessFrozens.splice( 0, m_pClosenessFrozens.length );
        m_pClosenessFrozens = null;
        if ( m_pFightTimeLine )
            m_pFightTimeLine.dispose();
        m_pFightTimeLine = null;
    }

    public function indexClosenessObject( obj : CGameObject ) : int {
        if ( !m_pClosenessQueue )
            return -1;
        for ( var i : int = 0; i < m_pClosenessQueue.length; ++i ) {
            if ( m_pClosenessQueue[ i ].ptr == obj )
                return i;
        }
        return -1;
    }

    public function addClosenessObject( obj : CGameObject ) : void {
        if ( !m_pClosenessQueue )
            m_pClosenessQueue = new <CWeakRef>[];
        if ( -1 == indexClosenessObject( obj ) )
            m_pClosenessQueue.push( new CWeakRef( obj ) );
    }

    public function removeClosenessObject( obj : CGameObject ) : void {
        var idx : int = -1;
        if ( -1 != (idx = indexClosenessObject( obj ) ) )
            m_pClosenessQueue.splice( idx, 1 );
    }

    public function clearAllClosenessObjects() : void {
        if ( m_pClosenessQueue )
            m_pClosenessQueue.splice( 0, m_pClosenessQueue.length );
    }

    public function indexClosenessFrozenObject( obj : CGameObject ) : int {
        if ( !m_pClosenessFrozens )
            return -1;
        for ( var i : int = 0; i < m_pClosenessFrozens.length; ++i ) {
            if ( m_pClosenessFrozens[ i ].ptr == obj )
                return i;
        }
        return -1;
    }

    public function addClosenessFrozenObject( obj : CGameObject, duration : Number = NaN ) : Boolean {
        if ( !m_pClosenessFrozens )
            m_pClosenessFrozens = new <CWeakRef>[];
        if ( -1 == indexClosenessFrozenObject( obj ) ) {
            m_currentClosenessTime = duration;
            m_pClosenessFrozens.push( new CWeakRef( obj ) );
            return true;
        }
        return false;
    }

    public function removeClosenessFrozenObject( obj : CGameObject ) : Boolean {
        var idx : int = -1;
        if ( -1 != ( idx = indexClosenessFrozenObject( obj )) ) {
            m_pClosenessFrozens.splice( idx, 1 );
            return true;
        }
        return false;
    }

    public function clearAllClosenessFrozenObjects() : void {
        if ( m_pClosenessFrozens )
            m_pClosenessFrozens.splice( 0, m_pClosenessFrozens.length );
    }

    override public function tickValidate( delta : Number, obj : CGameObject ) : Boolean {
        var pValidated : Boolean = super.tickValidate( delta, obj );
        if ( !pValidated ) {
            var pRootRing : CRootRingSpirte = obj.getComponentByClass( CRootRingSpirte, true ) as CRootRingSpirte;
            if ( pRootRing ) {
                pRootRing.enabled = false;
            }
            return false;
        }

        var pAnimation : IAnimation = obj.getComponentByClass( IAnimation, true ) as IAnimation;
        if ( !pAnimation || !pAnimation.isFrameFrozen ) {
            var pAIComponent : CAIComponent = obj.getComponentByClass( CAIComponent, true ) as CAIComponent;
            if ( m_pAIHandler != null && ( !CCharacterDataDescriptor.isHero( obj.data ) || m_pAIHandler.bAutoFight) &&
                    pAIComponent && pAIComponent.enabled )
                pAIComponent.externalUpdateForSyncSkillTime( delta );

            var pSkillCaster : CSkillCaster = obj.getComponentByClass( CSkillCaster, true ) as CSkillCaster;
            if ( pSkillCaster ) {
                pSkillCaster.update( delta );
            }

        }

        var pSkillCatch : CSkillCatcher = obj.getComponentByClass( CSkillCatcher, true ) as CSkillCatcher;
        if ( pSkillCatch ) {
            pSkillCatch.update( delta );
        }

        var buffContaniner : CBuffContainer = obj.getComponentByClass( CBuffContainer, true ) as CBuffContainer;
        if ( buffContaniner != null )
            buffContaniner.update( delta );

        var tRootRing : CRootRingSpirte = obj.getComponentByClass( CRootRingSpirte, true ) as CRootRingSpirte;
        if ( tRootRing ) {
            if ( pAnimation && pAnimation.modelDisplay ) {
                tRootRing.enabled = pAnimation.modelDisplay.visible;
            }

            tRootRing.update( delta );
        }

        var pIndexSprite : CPlayerIndexSprite = obj.getComponentByClass( CPlayerIndexSprite, true ) as CPlayerIndexSprite;
        if ( pIndexSprite ) {
            if ( pAnimation && pAnimation.modelDisplay ) {
                pIndexSprite.enabled = pAnimation.modelDisplay.visible;
            }
            if ( pIndexSprite.enabled )
                pIndexSprite.update( delta );
        }

        var pResponseQueue : CCharacterResponseQueue = obj.getComponentByClass( CCharacterResponseQueue, true ) as CCharacterResponseQueue;
        if ( pResponseQueue ) {
            pResponseQueue.update( delta );
        }

        var fightCalc : CFightCalc = obj.getComponentByClass( CFightCalc, true ) as CFightCalc;
        if ( fightCalc ) {
            fightCalc.update( delta );
        }

        var fightProperty : CFightProperty = obj.getComponentByClass( CFightProperty, true ) as CFightProperty;
        if ( fightProperty ) {
            fightProperty.update( delta );
        }

        var pHealRecovery : CAutoRecoveryComponent = obj.getComponentByClass( CAutoRecoveryComponent, true ) as CAutoRecoveryComponent;
        if ( pHealRecovery ) {
            if ( pHealRecovery.enabled )
                pHealRecovery.update( delta );
        }

        return true;
//        return m_pClosenessTimeDog && m_pClosenessTimeDog.running;
    }

    override public function tickUpdate( delta : Number, obj : CGameObject ) : void {
        super.tickUpdate( delta, obj );

        if ( m_pClosenessTimeDog && m_pClosenessTimeDog.running ) {
            if ( m_pClosenessQueue && m_pClosenessQueue.length ) {
                var pRef : CWeakRef = m_pClosenessQueue[ 0 ];
                if ( obj != pRef.ptr ) {
                    if ( this.addClosenessFrozenObject( obj ) ) {
                        this.frozenGameObject( obj );
                    }
                }
            }
        }
    }

    override public function beforeTick( delta : Number ) : void {
    }

    override public function afterTick( delta : Number ) : void {
        if ( !m_pClosenessQueue || !m_pClosenessQueue.length )
            return;

        // 大招定帧控制
        if ( !m_pClosenessTimeDog || !m_pClosenessTimeDog.running ) {
            if ( !m_pClosenessTimeDog )
                m_pClosenessTimeDog = new CTimeDog( _onClosenessTimeEnd );

            var duration : Number = m_currentClosenessTime;
            if ( isNaN( duration ) ) duration = SUPER_SKILL_FROZEN_DURATION;

            m_pClosenessTimeDog.start( duration );
//            m_pClosenessTimeDog.start( SUPER_SKILL_FROZEN_DURATION );
        } else {
            m_pClosenessTimeDog.update( delta );
        }
    }

    private function _onClosenessTimeEnd() : void {
        m_pClosenessQueue.shift();

        if ( m_pClosenessFrozens && m_pClosenessFrozens.length )
            m_pClosenessFrozens.splice( 0, m_pClosenessFrozens.length );

        if ( !m_pClosenessQueue.length ) {
            m_pClosenessTimeDog.dispose();
            m_pClosenessTimeDog = null;
        }
    }

    private function onSkillCasterHandler( net : INetworking, message : CAbstractPackMessage ) : void {
        var msg : SkillCastResponse = message as SkillCastResponse;

        if ( msg ) {
            var obj : CGameObject;
            if ( msg.type == 1 ) { // player.
                obj = m_pSceneFacade.findPlayer( msg.ID );
            } else if ( msg.type == 2 ) { // monster.
                obj = m_pSceneFacade.findMonster( msg.ID );
            } else {
                LOG.logWarningMsg( "Unknown type of SkillCastResponse: " + msg.type );
            }

            if ( obj == null || !obj.isRunning ) {
                LOG.logWarningMsg( " can not find target to Spell skill: " + msg.type );
                return;
            }

            //ignore self msg
            if ( m_pPlayHandler && m_pPlayHandler.hero ) {
                if ( obj.data.id == m_pPlayHandler.hero.data.id &&
                        obj.data.type == m_pPlayHandler.hero.data.type ) {
                    LOG.logWarningMsg( "Received CharacterMoveResponse self by self!!!)" );
                    return;
                }
            }

            if ( obj ) {
                var pTriggle : CCharacterFightTriggle = obj.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
                if ( pTriggle )
                    pTriggle.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.RESPONSE_FIGHT_SKILL, null, [ msg ] ) );

                var pTimeLineFacade : CFightTimeLineFacade = obj.getComponentByClass( CFightTimeLineFacade, true ) as CFightTimeLineFacade;
                if ( pTimeLineFacade ) {

                }
            }
        }
    }

    private function onExitSkillHandler( net : INetworking, message : CAbstractPackMessage ) : void {
        var msg : ExitSkillResponse = message as ExitSkillResponse;

        if ( msg ) {
            var obj : CGameObject;
            if ( msg.type == 1 ) { // player.
                obj = m_pSceneFacade.findPlayer( msg.ID );
            } else if ( msg.type == 2 ) { // monster.
                obj = m_pSceneFacade.findMonster( msg.ID );
            } else {
                LOG.logWarningMsg( "Unknown type of SkillCastResponse: " + msg.type );
            }

            if ( obj == null || !obj.isRunning ) {
                LOG.logWarningMsg( "Can not find targer for  exitSkill: " + msg.ID );
                return;
            }


            //ignore self msg
            if ( m_pPlayHandler && m_pPlayHandler.hero ) {
                if ( obj.data.id == m_pPlayHandler.hero.data.id && obj.data.type == m_pPlayHandler.hero.data.type ) {
                    LOG.logWarningMsg( "Received CharacterMoveResponse self by self!!!)" );
                    return;
                }
            }

            if ( obj ) {

                var pTriggle : CCharacterFightTriggle = obj.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
                if ( pTriggle )
                    pTriggle.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.RESPONSE_FIGHT_SKILL_EXIT, null, [ msg ] ) );
            }
        }
    }

    private function onCharacterDead( net : INetworking, message : CAbstractPackMessage ) : void {
        var msg : * = message;
        if ( msg ) {
            var obj : CGameObject;
            if ( msg.type == 1 ) { // player.
                obj = m_pSceneFacade.findPlayer( msg.ID );
                system.dispatchEvent( new CCharacterEvent( CCharacterEvent.DIE, obj ) );
            } else if ( msg.type == 2 ) { // monster.
                obj = m_pSceneFacade.findMonster( msg.ID );
            } else {
                LOG.logWarningMsg( "Unknown type of SkillCastResponse: " + msg.type );
            }

            if ( obj == null || !obj.isRunning ) {
                LOG.logWarningMsg( "Can not find targer for Dead response: " + msg.ID );
                return;
            }

            if ( obj ) {
                var pCharacterProperty : CCharacterProperty = obj.getComponentByClass( CCharacterProperty, true ) as CCharacterProperty;
                if ( pCharacterProperty )
                    pCharacterProperty.HP = 0;
                var stateBoard : CCharacterStateBoard = obj.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
                if ( stateBoard )
                    stateBoard.setValue( CCharacterStateBoard.DEAD, true );

                var fsm : CCharacterStateMachine = obj.getComponentByClass( CCharacterStateMachine, true ) as CCharacterStateMachine;
                if ( fsm )
                    fsm.actionFSM.on( CCharacterActionStateConstants.EVENT_DEAD );
            }

            //计算攻击者增加的怒气
            var attacker : CGameObject;
            var attackerId : Number;
            var attackerType : int;
            attackerId = msg.dynamicStates && msg.dynamicStates.hasOwnProperty( "id" ) ? msg.dynamicStates[ "id" ] : 0;
            attackerType = msg.dynamicStates && msg.dynamicStates.hasOwnProperty( "type" ) ? msg.dynamicStates[ "type" ] : 0;
            attacker = _findTargetByType( attackerType, attackerId );
            if ( attacker ) {
                var calcComp : CFightCalc = attacker.getComponentByClass( CFightCalc, true ) as CFightCalc;
                if ( calcComp )
                    calcComp.battleEntity.increaseRagePowerByType( ERPRecoveryType.TYPE_KILL_TARGET, obj );
            }

            //队友增加的怒气
            var allHero : Vector.<Object> = m_pSceneFacade.playerIterator as Vector.<Object>;
            var deadSide : int = CCharacterDataDescriptor.getOperateSide( obj.data );
            for each ( var playerObj : CGameObject in allHero ) {
                if ( CCharacterDataDescriptor.getOperateSide( playerObj.data ) != deadSide || deadSide == 0 )
                    continue;
                var mateComp : CFightCalc = obj.getComponentByClass( CFightCalc, true ) as CFightCalc;
                if ( mateComp ) {
                    mateComp.battleEntity.increaseRagePowerByType( ERPRecoveryType.TYPE_MATE_DEAD );
                }

            }
        }
    }

    private function onJumpInputHandler( net : INetworking, message : CAbstractPackMessage ) : void {
        var msg : JumpInputResponse = message as JumpInputResponse;
        if ( msg ) {
            var obj : CGameObject;
            if ( msg.type == 1 ) { // player.
                obj = m_pSceneFacade.findPlayer( msg.ID );
            } else if ( msg.type == 2 ) { // monster.
                obj = m_pSceneFacade.findMonster( msg.ID );
            } else {
                LOG.logWarningMsg( "Unknown type of SkillCastResponse: " + msg.type );
            }

            if ( obj == null || !obj.isRunning ) {
                LOG.logWarningMsg( "Can not find target for Jump response: " + msg.ID );
                return;
            }

            if ( obj ) {
                var pInput : CCharacterInput = obj.getComponentByClass( CCharacterInput, true ) as CCharacterInput;

                var nodeTime : Number = msg.dynamicStates[ CCharacterSyncBoard.QUEUE_SEQ_TIME ];
                var timelineFacade : CFightTimeLineFacade = obj.getComponentByClass( CFightTimeLineFacade, true ) as CFightTimeLineFacade;
                if ( timelineFacade ) {
                    timelineFacade.insertMsgByType( EFighterActionType.E_JUMP_ACTION, nodeTime, msg );
                }

                if ( pInput ) {
                    pInput.wheel = new Point( msg.dirX, msg.dirY );
                }
            }
        }
    }

    private function onSyncPropertyResponse( net : INetworking, message : CAbstractPackMessage ) : void {
        var msg : SynPropertyResponse = message as SynPropertyResponse;
        if ( msg ) {
            for each( var targetInfo : Object in msg.property ) {
                var heroId : Number;
                var obj : CGameObject;
                heroId = targetInfo.id;

                if ( heroId != 0 ) { // player.
                    if ( CCharacterDataDescriptor.TYPE_MONSTER == targetInfo.type )
                        obj = m_pSceneFacade.findMonster( heroId );
                    if ( CCharacterDataDescriptor.TYPE_PLAYER == targetInfo.type )
                        obj = m_pSceneFacade.findPlayer( heroId );
                } else {
                    LOG.logWarningMsg( "Unknown type of SkillCastResponse: " + heroId );
                    return;
                }

                if ( obj == null || !obj.isRunning ) {
                    LOG.logWarningMsg( "Can not find target for Sync response: " + heroId );
                    return;
                }

                {
                    delete targetInfo[ 'id' ];
                    delete targetInfo[ 'type' ];
                }

                if ( obj && obj.isRunning ) {
                    var pCharacterProperty : CCharacterProperty = obj.getComponentByClass( CCharacterProperty, true ) as CCharacterProperty;
                    if ( pCharacterProperty ) {
                        if ( targetInfo.hasOwnProperty( "fightProperty" ) )
                            pCharacterProperty.updateFightProperty( targetInfo.fightProperty );
                        delete  targetInfo[ "fightProperty" ];

                        if ( targetInfo.hasOwnProperty( "skillcdlist" ) ) {
                            var pFightCal : CFightCalc = obj.getComponentByClass( CFightCalc, true ) as CFightCalc;
                            if ( pFightCal ) {
                                var cdCal : CFightCDCalc = pFightCal.fightCDCalc;
                                if ( cdCal ) {
                                    cdCal.decodeCDPool( targetInfo[ "skillcdlist" ] );
                                }
                            }
                            delete targetInfo[ "skillcdlist" ];
                        }

                        var pFxMediator : CFXMediator = obj.getComponentByClass( CFXMediator, true ) as CFXMediator;
                        if ( targetInfo.hasOwnProperty( "resetDodgeCD" ) ) {
                            var pFightCall : CFightCalc = obj.getComponentByClass( CFightCalc, true ) as CFightCalc;
                            if ( pFightCall && targetInfo[ "resetDodgeCD" ] != 0 ) {
                                pFightCall._resetDodgeCD();

                                var pCharacterProp : CCharacterProperty = obj.getComponentByClass( CCharacterProperty, true ) as CCharacterProperty;
                                if( pFxMediator) {
                                    pFxMediator.stopComHitEffects( pCharacterProp.quickStandFx );
                                    pFxMediator.stopComHitEffects( pCharacterProp.getUpFx );
                                }
                            }
                        }

                        if ( targetInfo.hasOwnProperty( "bRollBack" ) ) {
                            var bRBack : Boolean = Boolean( targetInfo[ 'bRollBack' ] );
                            var pStateMachine : CCharacterStateMachine = obj.getComponentByClass( CCharacterStateMachine, true ) as CCharacterStateMachine;
                            //强制播放特效吧
                            if ( bRBack ) {
                                if ( pFxMediator ) {
                                    pFxMediator.playSceneEffect( "combined_effect_model/netlost", 1.0, false, CFX.NOFULLSCREEN, false, false, new CVector3( 0, 150, 0 ), null, true );
                                }
                            }

                            bRBack = bRBack && (pStateMachine.actionFSM.currentState is CCharacterAttackState ||
                                    pStateMachine.actionFSM.currentState is CCharacterIdleState || pStateMachine.actionFSM.currentState is CCharacterDodgeState );
                            if ( bRBack ) {
                                _rollbackState( obj, targetInfo );

                            }
                        }
                    }
                }
            }

        }
    }

    private static function _rollbackState( obj : CGameObject, targetInfo : Object ) : void {
        var pStateMachine : CCharacterStateMachine = obj.getComponentByClass( CCharacterStateMachine, false ) as CCharacterStateMachine;
        var pFightTrigger : CCharacterFightTriggle = obj.getComponentByClass( CCharacterFightTriggle, false ) as CCharacterFightTriggle;
        var pSkillCaster : CSkillCaster = obj.getComponentByClass( CSkillCaster, false ) as CSkillCaster;
        if ( pFightTrigger ) {
            var skillId : int;
            if ( pSkillCaster )
                skillId = pSkillCaster.skillID;
            pFightTrigger.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.RESPONSE_ROLL_BACK, obj, [ skillId ] ) );
        }

        var bForceExit : Boolean = true;
        var pAnimation : IAnimation = obj.getComponentByClass( IAnimation, false ) as IAnimation;
        var bRet : Boolean = pStateMachine.actionFSM.on( CCharacterActionStateConstants.EVENT_POP , false ,  bForceExit );//EVENT_ATTACK_END
        if ( bRet && pAnimation ) {
            pAnimation.playAnimation( CCharacterActionStateConstants.IDLE, true );
        }

        var inputComp : CCharacterInput = obj.getComponentByClass( CCharacterInput, false ) as CCharacterInput;
        if ( inputComp )
            inputComp.wheel = new Point( 0, 0 );
        var targetDisplay : IDisplay = obj.getComponentByClass( IDisplay, false ) as IDisplay;
        if ( targetDisplay && targetDisplay.modelDisplay ) {
            if ( targetInfo.hasOwnProperty( "posX" ) && targetInfo.hasOwnProperty( "posY" ) && targetInfo.hasOwnProperty( CCharacterSyncBoard.NHEIGHT_PLAYER ) ) {
                targetDisplay.modelDisplay.setPositionToFrom2D( targetInfo[ "posX" ], targetInfo[ "posY" ], targetInfo[ CCharacterSyncBoard.NHEIGHT_PLAYER ] );
                obj.transform.x = targetDisplay.modelDisplay.position.x;
                obj.transform.y = targetDisplay.modelDisplay.position.z;
                obj.transform.z = targetDisplay.modelDisplay.position.y;
            }
        }

    }

    private function _onAddBuffResponse( net : INetworking, message : CAbstractPackMessage ) : void {
        var msg : AddBufferResponse = message as AddBufferResponse;

        if ( msg != null ) {
            var srcOwner : CGameObject;
            srcOwner = _findTargetByType( msg.srcType, msg.srcId );
            if ( srcOwner == null ) {
                Foundation.Log.logTraceMsg( "对目标添加buff失效，Buff 释放者ID :" + msg.srcId + "  type : " + msg.srcType + "死亡或者不存在" );
            }
            var target : CGameObject;
            var buffContainComp : CBuffContainer;
            target = _findTargetByType( msg.type, msg.targetId );
            if ( target && target.isRunning ) {
                buffContainComp = target.getComponentByClass( CBuffContainer, true ) as CBuffContainer;
                if ( buffContainComp ) {
                    buffContainComp.addBuffListFromSev( msg.buffers, srcOwner );
                }
            }
        }
    }

    private function _onRemoveBuffResponse( net : INetworking, message : CAbstractPackMessage ) : void {
        var msg : RemoveBufferResponse = message as RemoveBufferResponse;
        if ( msg ) {
            var target : CGameObject = _findTargetByType( msg.type, msg.targetId );
            if ( target && target.isRunning ) {
                var buffContainComp : CBuffContainer = target.getComponentByClass( CBuffContainer, true ) as CBuffContainer;
                if ( buffContainComp ) {
                    buffContainComp.removeBuffByID( msg.bufferId );
                }
            }
        }
    }

    private function _onTriggerBuffResponse( net : INetworking, message : CAbstractPackMessage ) : void {
        var msg : UpdateBuffResponse = message as UpdateBuffResponse;
        if ( msg ) {
            var target : CGameObject = _findTargetByType( msg.type, msg.targetId );
            if ( target && target.isRunning ) {
                var buffContainComp : CBuffContainer = target.getComponentByClass( CBuffContainer, true ) as CBuffContainer;
                if ( buffContainComp ) {
                    buffContainComp.triggerBuffByID( msg.buffId, msg.buffIndex, msg.randomSeed );
                    CSkillDebugLog.logTraceMsg( "buff生效触发时间" + getTimer() );
                }
            }
        }
        else {
            Foundation.Log.logMsg( "receive a null UpdateBuffResponse msg  " )
        }
    }

    private function _onCatchResponse( net : INetworking, message : CAbstractPackMessage ) : void {
        var msg : CatchResponse = message as CatchResponse;
        if ( msg ) {
            var obj : CGameObject;
            if ( msg.type == 1 ) { // player.
                obj = m_pSceneFacade.findPlayer( msg.ID );
            } else if ( msg.type == 2 ) { // monster.
                obj = m_pSceneFacade.findMonster( msg.ID );
            } else {
                LOG.logWarningMsg( "Unknown type of CatchResponse: " + msg.type );
            }

            if ( obj == null || !obj.isRunning ) {
                LOG.logWarningMsg( "Can not find target for catch response: " + msg.ID );
                return;
            }

            if ( m_pPlayHandler && m_pPlayHandler.hero ) {
                if ( obj.data.id == m_pPlayHandler.hero.data.id && obj.data.type == m_pPlayHandler.hero.data.type ) {
                    LOG.logWarningMsg( "Received CatchResponse self by self!!!)" );
                    return;
                }
            }

            if ( obj ) {
                var responseQueue : CCharacterResponseQueue = obj.getComponentByClass( CCharacterResponseQueue, true ) as CCharacterResponseQueue;
                responseQueue.handleCatchMsg( msg );
            }
        }
    }

    private function _findTargetByType( type : int, targetID : int ) : CGameObject {
        var target : CGameObject;
        if ( type == CCharacterDataDescriptor.TYPE_PLAYER ) {
            target = m_pSceneFacade.findPlayer( targetID );
        } else if ( type == CCharacterDataDescriptor.TYPE_MONSTER ) {
            target = m_pSceneFacade.findMonster( targetID );
        } else {
            LOG.logWarningMsg( "Unknow type of Character " );
        }

        return target;
    }

    private function _findTargetByData( data : Object, idRecStr : String ) : CGameObject {
        var target : CGameObject;
        if ( CCharacterDataDescriptor.isPlayer( data ) ) {
            target = m_pSceneFacade.findPlayer( data[ idRecStr ] );
        } else if ( CCharacterDataDescriptor.isMonster( data ) ) {
            target = m_pSceneFacade.findMonster( data[ idRecStr ] );
        } else {
            LOG.logWarningMsg( "Unknow type of Character " );
        }

        return target;
    }

    private function onHitHandler( net : INetworking, message : CAbstractPackMessage ) : void {
        var msg : HitResponse = message as HitResponse;

        if ( msg ) {
            var obj : CGameObject;
            if ( msg.type == 1 ) { // player.
                obj = m_pSceneFacade.findPlayer( msg.ID );
            } else if ( msg.type == 2 ) { // monster.
                obj = m_pSceneFacade.findMonster( msg.ID );
            } else {
                LOG.logWarningMsg( "Unknown type of HitResponse: " + msg.type );
            }

            if ( obj == null || !obj.isRunning ) {
                LOG.logWarningMsg( "Can not find target for hit response: " + msg.ID );
                return;
            }

            if ( m_pPlayHandler && m_pPlayHandler.hero ) {
                if ( obj.data.id == m_pPlayHandler.hero.data.id && obj.data.type == m_pPlayHandler.hero.data.type ) {
                    LOG.logWarningMsg( "Received HitResponse self by self!!!)" );
                    return;
                }
            }

            if ( obj ) {
                var responseQueue : CCharacterResponseQueue = obj.getComponentByClass( CCharacterResponseQueue, true ) as CCharacterResponseQueue;
                if ( responseQueue )
                    responseQueue.handleHitResponse( msg );
            }

        }
    }

    private function _onMissileAbsorb( net : INetworking, message : CAbstractPackMessage ) : void {
        var msg : FightMissileAbsorbResponse = message as FightMissileAbsorbResponse;
        if ( msg ) {
            var obj : CGameObject;
            obj = _findTargetByType( msg.type, msg.ID );
            if ( obj && obj.isRunning ) {
                var responseQueue : CCharacterResponseQueue = obj.getComponentByClass( CCharacterResponseQueue, true ) as CCharacterResponseQueue;
                responseQueue.handleMissileAbsorb( msg );
            }
        }
    }

    private function _onMissileActivate( net : INetworking, message : CAbstractPackMessage ) : void {
        var msg : FightMissileActivateResponse = message as FightMissileActivateResponse;
        if ( msg ) {
            var obj : CGameObject;
            obj = _findTargetByType( msg.type, msg.ID );
            if ( obj ) {
                var responseQueue : CCharacterResponseQueue = obj.getComponentByClass( CCharacterResponseQueue, true ) as CCharacterResponseQueue;
                responseQueue.handleMissileActivate( msg );
            }
        }
    }

    private function _onAskProperty( net : INetworking, message : CAbstractPackMessage ) : void {
        var msg : AskPropertyResponse = message as AskPropertyResponse;
        if ( msg ) {
            var obj : CGameObject;
            obj = _findTargetByType( msg.type, msg.ID );
            if ( obj && obj.isRunning ) {
                var pFightTrigger : CCharacterFightTriggle = obj.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
                var time : Number = msg.time;
                if ( pFightTrigger )
                    pFightTrigger.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.REQUEST_ASK_PROPERTY, null, [ time ] ) );

            }
        }
    }

    private function _onHealhandler( net : INetworking, message : CAbstractPackMessage ) : void {
        var msg : HealResponse = message as HealResponse;
        if ( msg ) {
            var obj : CGameObject;
            obj = _findTargetByType( msg.type, msg.ID );

            if ( obj == null || !obj.isRunning ) {
                LOG.logWarningMsg( "Can not find target for heal response: " + msg.ID );
                return;
            }

            if ( m_pPlayHandler && m_pPlayHandler.hero ) {
                if ( CCharacterDataDescriptor.getID( obj.data ) == m_pPlayHandler.hero.data.id
                        && CCharacterDataDescriptor.getType( obj.data ) == m_pPlayHandler.hero.data.type ) {
                    LOG.logWarningMsg( "Recieve Heal By self " );
                    return;
                }
            }

            if ( obj ) {
                var responseQueue : CCharacterResponseQueue = obj.getComponentByClass( CCharacterResponseQueue, true ) as CCharacterResponseQueue;
                if ( responseQueue )
                    responseQueue.handleHealResponse( msg );
            }
        }
    }

    private function onDodgeHandler( net : INetworking, message : CAbstractPackMessage ) : void {
        var msg : DodgeResponse = message as DodgeResponse;

        if ( msg ) {
            var obj : CGameObject;
            if ( msg.type == 1 ) { // player.
                obj = m_pSceneFacade.findPlayer( msg.ID );
            } else if ( msg.type == 2 ) { // monster.
                obj = m_pSceneFacade.findMonster( msg.ID );
            } else {
                LOG.logWarningMsg( "Unknown type of HitResponse: " + msg.type );
            }

            if ( obj == null || !obj.isRunning ) {
                LOG.logWarningMsg( "Can not find dodge for heal response: " + msg.ID );
                return;
            }

            if ( m_pPlayHandler && m_pPlayHandler.hero ) {
                if ( obj.data.id == m_pPlayHandler.hero.data.id && obj.data.type == m_pPlayHandler.hero.data.type ) {
                    LOG.logWarningMsg( "Received HitResponse self by self!!!)" );
                    return;
                }
            }

            if ( obj ) {

                var pTriggle : CCharacterFightTriggle = obj.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
                if ( pTriggle )
                    pTriggle.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.RESPONSE_DODGE, null, [ msg ] ) );
            }

        }
    }

    public function _onMissileIdsResponse( net : INetworking, message : CAbstractPackMessage ) : void {
        var msg : FightMissileIdsResponse = message as FightMissileIdsResponse;

        if ( msg ) {
            var obj : CGameObject;
            obj = _findTargetByType( msg.type, msg.ID );
            if ( obj ) {
                var missileRepository : CMissileIdentifersRepository = obj.getComponentByClass( CMissileIdentifersRepository, true ) as CMissileIdentifersRepository;
                if ( missileRepository ) {
                    missileRepository.setIDs( msg.idsForEmitter );
                }
            }
        }
    }

    public function _onMissileDeadResponse( net : INetworking, message : CAbstractPackMessage ) : void {
        var msg : FightMissileDeadResponse = message as FightMissileDeadResponse;
        var obj : CGameObject;
        if ( msg ) {
            obj = m_pSceneFacade.findMissile( msg.missileId );
            m_pSceneFacade.dispatchEvent( new CSceneEvent( CSceneEvent.MISSILE_REMOVE , msg.missileId ));

            if ( obj ) {
                var pFTrigger : CCharacterFightTriggle = obj.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
                if ( pFTrigger ) {
                    pFTrigger.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.MISSILE_DEAD, null ) );
                }
            }
        }
    }

    private function frozenGameObject( pObj : CGameObject, fDuration : Number = 0.5 ) : void {
        if ( !pObj )
            return;

        var pAnimation : IAnimation = pObj.getComponentByClass( IAnimation, true ) as IAnimation;
        if ( pAnimation )
            pAnimation.frozenFrame( fDuration );
    }

    private function _onFightTimeLineRespose( net : INetworking, message : CAbstractPackMessage ) : void {
        if ( m_pInstanceFacade ) {
            if ( m_pInstanceFacade.isMainCity && m_pInstanceFacade.isPVE ) {
                if ( m_pFightTimeLine )
                    m_pFightTimeLine.dispose();
                m_pFightTimeLine = null;
            } else {
                var msg : FightTimeLineResponse = message as FightTimeLineResponse;
                if ( m_pFightTimeLine ) {
                    m_pFightTimeLine.recycle();
                } else {
                    m_pFightTimeLine = _initFightTimeLine();
                }
                if ( msg ) {
                    m_pFightTimeLine.setStartAtTime( 0.0 );
                }
            }
        }
    }

    private function _initFightTimeLine() : CFightTimeLine {
        if ( null == m_pFightTimeLine )
            return new CFightTimeLine( "synctimeLine" );
        return m_pFightTimeLine;
    }

    public function get fightTimeLine() : CFightTimeLine {
        return m_pFightTimeLine;
    }

    final private function get sceneSys() : CSceneSystem {
        return system.stage.getSystem( CSceneSystem ) as CSceneSystem;
    }

}
}
