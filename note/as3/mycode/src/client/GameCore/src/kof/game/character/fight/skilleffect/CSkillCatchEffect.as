//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.fight.skilleffect {

import QFLib.Collision.CCharacterCollisionBound;
import QFLib.Collision.CCollisionBound;
import QFLib.Foundation;
import QFLib.Graphics.RenderCore.render.material.MOutline;
import QFLib.Math.CAABBox3;
import QFLib.Math.CVector3;
import QFLib.Math.CVector3;

import flash.geom.Matrix3D;
import flash.geom.Point;

import kof.framework.fsm.CFiniteStateMachine;
import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.CTarget;
import kof.game.character.animation.IAnimation;
import kof.game.character.collision.CCollisionComponent;
import kof.game.character.fight.CCharacterNetworkInput;
import kof.game.character.fight.CTargetCriteriaComponet;
import kof.game.character.fight.catches.CKeepAwayTrunk;
import kof.game.character.fight.catches.CSkillCatcher;
import kof.game.character.fight.catches.ICatcherInfo;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skill.CComponentUtility;
import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.fight.skill.CSkillDataBase;
import kof.game.character.fight.skill.CSkillDebugLog;
import kof.game.character.fight.skillcalc.CFightOthersCalc;
import kof.game.character.fight.sync.CCharacterSyncBoard;
import kof.game.character.fx.CFXMediator;
import kof.game.character.level.CLevelMediator;
import kof.game.character.movement.CMotionAction;
import kof.game.character.movement.CMovement;
import kof.game.character.property.interfaces.ICharacterProperty;
import kof.game.character.scene.CSceneMediator;
import kof.game.character.state.CCharacterActionStateConstants;
import kof.game.character.state.CCharacterDeadState;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.character.state.CCharacterStateMachine;
import kof.game.core.CGameObject;
import kof.table.Motion;
import kof.table.Motion.EMotionType;
import kof.table.Motion.ETransWay;
import kof.table.SkillCatch;
import kof.table.SkillCatch.ECatchingPart;
import kof.util.CAssertUtils;

/**
 * 技能中抓取的效果
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CSkillCatchEffect extends CAbstractSkillEffect {

    private var m_pSkillContext : CComponentUtility;
    private var m_pCatchData : SkillCatch;
    private var m_pLevelMediator : CLevelMediator;
    private var m_pCatcher : CSkillCatcher;
    private var m_listCollisionTargets : Array;
    private var m_pTargets : Vector.<CGameObject>;
    private var m_iOwnerDirX : int;
    private var m_boCatchDirectly : Boolean;
    private var m_boCatchFromHost : Boolean;
    private var m_nMotionDirX : int;
    private var m_pKeepAwayTrunk : CKeepAwayTrunk;

    /** Creates a new CSkillCatchEffect object. */
    public function CSkillCatchEffect( id : int, startFrame : Number, hitEvent : String, type : int,
                                       description : String = null ) {
        super( id, startFrame, hitEvent, type, description );
    }

    /** @inheritDoc */
    override public function dispose() : void {
        super.dispose();

        m_pSkillContext = null;
        m_pLevelMediator = null;
        m_pCatchData = null;
        m_pCatcher = null;
        m_pKeepAwayTrunk = null;

        if ( m_listCollisionTargets )
            m_listCollisionTargets.splice( 0, m_listCollisionTargets.length );
        m_listCollisionTargets = null;

        if ( m_theMotionAction ) {
            if ( pMovement )
                pMovement.removeMotionAction( m_theMotionAction );
            m_theMotionAction = null;
        }
        if ( m_pTargets )
            m_pTargets.splice( 0, m_pTargets.length );
        m_pTargets = null;
    }

    final public function get stateBoard() : CCharacterStateBoard {
        return this.getTargetStateBoard( m_pSkillContext.owner );
    }

    final public function get catcher() : CSkillCatcher {
        return m_pCatcher || (m_pCatcher = m_pSkillContext.owner.getComponentByClass( CSkillCatcher, true ) as
                        CSkillCatcher);
    }

    final public function get keepAwayTrunk() : CKeepAwayTrunk {
        return m_pKeepAwayTrunk || ( m_pKeepAwayTrunk = m_pSkillContext.owner.getComponentByClass( CKeepAwayTrunk, true ) as
                        CKeepAwayTrunk);
    }

    final public function get levelMediator() : CLevelMediator {
        return m_pLevelMediator || (m_pLevelMediator = m_pSkillContext.owner.getComponentByClass( CLevelMediator, true )
                        as CLevelMediator);
    }

    final public function get targetCriteriaComp() : CTargetCriteriaComponet {
        return m_pSkillContext.pTargetCriteriaComp;
    }

    final protected function getTargetStateBoard( vObj : CGameObject ) : CCharacterStateBoard {
        if ( !vObj ) return null;
        return vObj.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
    }

    override public function initData( ... args ) : void {
        CONFIG::debug {
            Foundation.Log.logTraceMsg( "**@CSkillCatchEffect: 初始化技能抓取效果，ID：" + effectID );
        }

        if ( !args || !args.length )
            return;

        super.initData( null );
        m_pSkillContext = args[ 0 ] as CComponentUtility;
        CAssertUtils.assertNotNull( m_pSkillContext, "Invalid args[0] as CComponentUtility." );

        var pCatchingData : SkillCatch = CSkillCaster.skillDB.catchTable.findByPrimaryKey( effectID );
        if ( !pCatchingData ) {
            CONFIG::debug {
                Foundation.Log.logWarningMsg( "**@CSKillCatchEffect: 没有找到抓取效果，ID：" + effectID );
            }
            return;
        }

        this.m_pCatchData = pCatchingData;
//        this.m_pLevelMediator = m_pSkillContext.owner.getComponentByClass( CLevelMediator, true ) as CLevelMediator;
//        this.m_pCatcher = m_pSkillContext.owner.getComponentByClass( CSkillCatcher, true ) as CSkillCatcher;

        CAssertUtils.assertNotNull( this.catcher, "Character doesn't have a skill-catcher component but a catch-effect obtained." );
        CAssertUtils.assertNotNull( this.keepAwayTrunk, "Character doesn't have a keepAway component but a catch-effect obtained." );
    }

    public function catchTargetsDirectly( vTargets : Vector.<CGameObject>, bFromHost : Boolean = false, nDirx : int = 0 ) : void {
        var bHitEventDispatched : Boolean = false;
//        if ( nDirx != 0 ) {
//            _doCastMotionEffect( nDirx );
//        }
        m_boCatchDirectly = true;
        m_boCatchFromHost = bFromHost;
        var pStateBoard : CCharacterStateBoard = this.stateBoard;
        if ( pStateBoard ) {
            var pDirRef : Object = pStateBoard.getValue( CCharacterStateBoard.DIRECTION );
            if ( pDirRef )
                m_iOwnerDirX = pDirRef.x;
        }

        Foundation.Log.logTraceMsg( "直接对目标执行抓取效果！！" );
        doCatchTargets( vTargets );

        if ( !m_pTargets )
            m_pTargets = vTargets;
        else
            m_pTargets = m_pTargets.concat( vTargets );

        for each ( var vObj : CGameObject in vTargets ) {
            if ( this.enterTargetFSM( vObj ) ) {
//                if ( keepAwayTrunk ) {
//                    keepAwayTrunk.keepAwayBox = this.findCollisionBox();
//                }
                this.executeTargetStatusUpdated( vObj );

                bHitEventDispatched = true;
            }
        }

        if ( bHitEventDispatched ) {
            updateTargetComp();
            notifyCatchEventDispatched();
        }

    }

    /**
     * @inheritDoc
     */
    override public function update( delta : Number ) : void {
        super.update( delta );
//        _updateSceneblockMotion( delta );
        if ( !m_pCatchData || m_boCatchDirectly )
            return;
        var bHitEventDispatched : Boolean = false;

        if ( !findTargets() )
            return;

        var pStateBoard : CCharacterStateBoard = this.stateBoard;
        if ( pStateBoard ) {
            var pDirRef : Object = pStateBoard.getValue( CCharacterStateBoard.DIRECTION );
            if ( pDirRef )
                m_iOwnerDirX = pDirRef.x;
        }

        // targets found.
        var vCatches : Vector.<CGameObject> = catchTargets( delta );
        if ( vCatches && vCatches.length ) {
            for each ( var vObj : CGameObject in vCatches ) {
                if ( !m_pTargets ) {
                    m_pTargets = new <CGameObject>[];
                }

                m_pTargets.push( vObj );
                CSkillDebugLog.logTraceMsg( "抓取效果时间" + m_fElapseTickTime );
                // XXX: 以下注释为100%破防处理逻辑，抓技逻辑已排除该可能性
                // var pSkillCaster : CSkillCaster = vObj.getComponentByClass( CSkillCaster, true ) as CSkillCaster;
                // var pTargetTrigger : CCharacterFightTriggle = vObj.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
                // if ( pSkillCaster ) {
                //     pSkillCaster.pComUtility.pFightCalc.battleEntity.calcDefensePower( -int.MAX_VALUE >> 1, false, true );
                //     pTargetTrigger.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.REQUEST_SYNC_FIGHT_STATE, null, CCharacterSyncBoard.SYNC_FIGHT_PROPERTY ) );
                // }

                if ( this.enterTargetFSM( vObj ) ) {
                    if ( keepAwayTrunk ) {
                        keepAwayTrunk.keepAwayBox = this.findCollisionBox();
                    }
                    this.executeTargetStatusUpdated( vObj );

                    bHitEventDispatched = true;
                }
            }
        }
//        }

        if ( bHitEventDispatched ) {
            this.boLastUpdateDirty = true;
            updateTargetComp();
            _syncCatchToServ();
//            notifyCatchEventDispatched();
        }
    }

    override public function lastUpdate( delta : Number ) : void {
        if ( this.boLastUpdateDirty ) {
            boLastUpdateDirty = false;
            notifyCatchSucceed();
        }

        if ( this.m_boCatchFromHost ) {
            m_pContainer.removeSkillEffect( this );
        }
    }

    private function _doCastMotionAction( dirX : int ) : void {
        var motionAction : CMotionAction = new CMotionAction();
        if ( motionAction ) {
            motionAction.moveSpeed = 2000;
            motionAction.direction = new Point( dirX, 0 );
            m_theMotionAction = motionAction;
            m_theMotionAction.moveSpeedFactor = 1.0;
            m_fMoveTime = 0.1;
            pMovement.addMotionAction( motionAction );
            m_bCatchFixMove = true;
        }
    }

    protected function updateTargetComp() : void {
        var vTarget : CTarget = m_pSkillContext.owner.getComponentByClass( CTarget, true ) as CTarget;
        if ( vTarget ) {
            vTarget.setTargetObjects( m_pTargets );
        }
    }

    protected function notifyCatchEventDispatched() : void {
        this._syncCatchToServ();
        this.notifyCatchSucceed();
    }

    protected function _syncCatchToServ() : void {
        if ( m_pTargets != null && m_pTargets.length > 0 ) {
            var pNewInput : CCharacterNetworkInput = owner.getComponentByClass( CCharacterNetworkInput, true ) as CCharacterNetworkInput;
            if ( !pNewInput )
                return;
            var catchDuration : Number = CSkillDataBase.TIME_IN_ONEFRAME * m_pCatchData.CatchDuration;
            m_pSkillContext.fightTriggle.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.REQUEST_SYNC_CATCH, null, [ m_pTargets, m_pCatchData.ID, 0, catchDuration, m_nMotionDirX ] ) );

            CSkillDebugLog.logTraceMsg( "抓取成功，并派发抓取事件 catchID ：" + m_pCatchData.ID )
        }
    }

    protected function enterTargetFSM( vObj : CGameObject ) : Boolean {
        var ret : int;
        var pFSM : CCharacterStateMachine = vObj.getComponentByClass( CCharacterStateMachine, true ) as CCharacterStateMachine;
        if ( pFSM ) {
            ret = pFSM.actionFSM.on( CCharacterActionStateConstants.EVENT_CATCH_BEGIN, m_pCatchData.AnimationState, m_iOwnerDirX );
        }
        return ret == CFiniteStateMachine.Result.SUCCEEDED || ret == CFiniteStateMachine.Result.NO_TRANSITION;
    }

    protected function executeTargetStatusUpdated( vObj : CGameObject ) : void {
        if ( !vObj )
            return;

        var vOffset : CVector3 = new CVector3( m_pCatchData.OffsetXY[ 0 ], m_pCatchData.OffsetXY[ 1 ], 0.0 );

        var vTargetOffsetZ : Number = 0.0;
        if ( 0 == m_pCatchData.LayerPriority ) {
            // Owner front.
            vTargetOffsetZ -= 1.0;
        } else if ( 1 == m_pCatchData.LayerPriority ) {
            // Target front.
            vTargetOffsetZ += 1.0;
        }

        if ( m_pCatchData.Alignment == 0 ) {
            vOffset.z = vTargetOffsetZ;
            m_pCatcher.targetOffset( vObj, vOffset );
        } else if ( m_pCatchData.Alignment == 1 ) {
            m_pCatcher.ownerOffset( vObj, vOffset );
            m_pCatcher.targetOffset( vObj, new CVector3( 0, 0, vTargetOffsetZ ) );
        }

        // m_pCatcher.targetRotation( vObj, m_pCatchData.AngleDeg );

        this.executeCatchFX( vObj );
    }

    protected function executeCatchFX( vObj : CGameObject ) : void {
        if ( !vObj )
            return;

        // attach catching FX.
        var bCatched : Boolean = true;
        var sFX : String = bCatched ? m_pCatchData.CatchPassFX : m_pCatchData.CatchElimFX;
//        var pFXMediator : CFXMediator = vObj.getComponentByClass( CFXMediator, true ) as CFXMediator;

        // retrieves the bone's position.
        var vPosition : CVector3 = null;
        var pInfo : ICatcherInfo = this.m_pCatcher.findCatchingInfo( vObj );
        if ( pInfo ) {
            var vTargetMat : Matrix3D = pInfo.targetWorldMat;
            if ( vTargetMat ) {
                vPosition = new CVector3( vTargetMat.position.x, vTargetMat.position.y, vTargetMat.position.z );
            }
        }

        var pFXMediator : CFXMediator = this.pFxMediator;
        if ( pFXMediator && vPosition ) {
            pFXMediator.playBindHitEffect( sFX, vPosition );
        }
    }

    protected function notifyCatchSucceed() : void {
        m_pSkillContext.fightTriggle.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.CATCH_EFFECT_SUCCEED, null ) );
        Foundation.Log.logTraceMsg( "Catch event dispatch at time : " + m_fElapseTickTime );
    }

    private function findTargets() : Boolean {
        var hitTargets : Array = targetCriteriaComp.getTargetByCollision( hitEventSignal, m_pCatchData.TargetFilter );
        if ( !hitTargets || !hitTargets.length )
            return false;

        var filteredTargets : Array = hitTargets.filter( _onFilterTarget );

        if ( !hitTargets || !hitTargets.length )
            return false;

        m_listCollisionTargets = filteredTargets;
        return true;
    }

    private function findCollisionPosition() : CVector3 {
        var collisionComp : CCollisionComponent = owner.getComponentByClass( CCollisionComponent, true ) as CCollisionComponent;
        if ( collisionComp ) {
            var collisionBox : CCharacterCollisionBound = collisionComp.getCollisionBoundByHitEvent( hitEventSignal );
            if ( collisionBox ) {
                var vCollisionBox : CVector3 = collisionBox.characterCollision.testAABBBox.center.clone();
                return vCollisionBox;
            }
        }

        return null;
    }

    private function findCollisionBox() : CAABBox3 {
        var collisionComp : CCollisionComponent = owner.getComponentByClass( CCollisionComponent, true ) as CCollisionComponent;
        if ( collisionComp ) {
            var collisionBox : CCharacterCollisionBound = collisionComp.getCollisionBoundByHitEvent( hitEventSignal );
            if ( collisionBox ) {
                CSkillDebugLog.logTraceMsg("抓取后退标识 " + hitEventSignal );
                var vCollisionBox : CAABBox3 = collisionBox.characterCollision.testAABBBox;
                return vCollisionBox;
            }
        }

        return null;
    }

    private function _onFilterTarget( item : Object, index : int, arr : Array ) : Boolean {
        var vObj : CGameObject = item as CGameObject;
        if ( vObj && this.levelMediator ) {
            // TODO: 过滤正在被别人抓取的目标
            var ret : Boolean = true;

            ret = ret && this.isCatchable( vObj );

            return ret;
        }
        return false;
    }

    /**
     * 判定目标对象是否可以被抓取
     *
     * 判定规则：
     *     - CCharacterStateBoard中的CAN_BE_CATCH状态是否标识为true。
     *     - 目标对象是否不在被抓取状态中（判定CCharacterStateBoard的IN_CATCH状态标识），如果已经处于被抓取状态，则判定
     *     - 是否owner的抓取目标列表中已经存在该对象。
     */
    virtual protected function isCatchable( vObj : CGameObject ) : Boolean {
        if ( !vObj )
            return false;

        var ret : Boolean = true; // 默认是可以被抓取，当作目标没有状态逻辑处理的情况
        var pStateBoard : CCharacterStateBoard = getTargetStateBoard( vObj );
        var pStateMach : CCharacterStateMachine = vObj.getComponentByClass( CCharacterStateMachine, true ) as CCharacterStateMachine;

        if ( pStateBoard ) {
            ret = pStateBoard.getValue( CCharacterStateBoard.CAN_BE_CATCH );

            ret = ret && ( pStateMach == null || !(pStateMach.actionFSM.currentState is CCharacterDeadState));
            // Condition 1.
            if ( ret && pStateBoard.getValue( CCharacterStateBoard.IN_CATCH ) ) {
                // Condition 2.
                var vCatcher : CSkillCatcher = this.catcher;
                if ( vCatcher && !vCatcher.findCatchingInfo( vObj ) )
                    ret = false;
            }
        }
        return ret;
    }

    protected function queryBoneNameByCatchPart( vPart : int ) : String {
        switch ( vPart ) {
            case ECatchingPart.HEAD:
                return "01_Tou";
            case ECatchingPart.FEET:
                // TODO: Find L/R Xie which mostly nearby the caster.
                // return "03_L_Xie";
                // XXX: Fallback to root as L/R_Xie.
                return "root";
            default:
                Foundation.Log.logWarningMsg( "未知抓取部件配置项：" + m_pCatchData.CatchPart + "，Fallback到默认值：" + ECatchingPart.CHEST );
            case ECatchingPart.CHEST:
//                return "01_StiB";
                return "Zxin";
        }
    }

    protected function catchTargets( delta : Number ) : Vector.<CGameObject> {
        var vCatcher : CSkillCatcher = m_pSkillContext.owner.getComponentByClass( CSkillCatcher, true ) as CSkillCatcher;

        var v_iMaxNum : uint = m_pCatchData.TargetNum; // If zero it's, unlimited instead.

        if ( m_pTargets && v_iMaxNum <= m_pTargets.length )
            return null;

        if ( 0 == v_iMaxNum )
            v_iMaxNum = m_listCollisionTargets.length;

        v_iMaxNum = Math.min( v_iMaxNum, m_listCollisionTargets.length );

        if ( m_listCollisionTargets.length >= 2 ) {
            m_listCollisionTargets.sort( function ( obj1 : CGameObject, obj2 : CGameObject ) : int {
                if ( !obj1 ) return 1;
                if ( !obj2 ) return -1;

                // 默认将已经在抓取列表中的对象排在前面
                var v_bCatching_1 : Boolean = vCatcher.findCatchingInfo( obj1 );
                var v_bCatching_2 : Boolean = vCatcher.findCatchingInfo( obj2 );
                if ( v_bCatching_1 && v_bCatching_2 ) return 0;
                else if ( v_bCatching_1 && !v_bCatching_2 ) return -1;
                else if ( !v_bCatching_1 && v_bCatching_2 ) return 1;
                else return 0;

            } );
        }

        var vTargets : Vector.<CGameObject> = new Vector.<CGameObject>( v_iMaxNum, true );
        for ( var i : int = 0; i < v_iMaxNum; ++i ) {
            vTargets[ i ] = m_listCollisionTargets[ i ];
        }

        return doCatchTargets( vTargets );
    }

    protected function doCatchTargets( vTargets : Vector.<CGameObject> ) : Vector.<CGameObject> {
        if ( !vTargets || !vTargets.length )
            return null;

        var ret : Vector.<CGameObject> = null;
        var v_pTargetStateBoard : CCharacterStateBoard;
        var vInfo : ICatcherInfo;
        var vCatcher : CSkillCatcher = m_pSkillContext.owner.getComponentByClass( CSkillCatcher, true ) as CSkillCatcher;

        for each ( var vObj : CGameObject in vTargets ) {
            /* for ( var i : int = 0; i < v_iMaxNum; ++i ) { */
//            var vObj : CGameObject = m_listCollisionTargets[ i ] as CGameObject;
            if ( m_pTargets && -1 != m_pTargets.indexOf( vObj ) )
                continue;

            v_pTargetStateBoard = this.getTargetStateBoard( vObj );

            var v_bInAttack : Boolean = v_pTargetStateBoard.getValue( CCharacterStateBoard.IN_ATTACK );
            var v_bInHurting : Boolean = v_pTargetStateBoard.getValue( CCharacterStateBoard.IN_HURTING );
            var v_bInLying : Boolean = v_pTargetStateBoard.getValue( CCharacterStateBoard.LYING );
            var v_bInCatch : Boolean = v_pTargetStateBoard.getValue( CCharacterStateBoard.IN_CATCH );

            // XXX: v_bForcedCatches 表示目标对象在GamePlay的设定中为直接跳过防御值判定条件
            var v_bForcedCatches : Boolean = v_bInAttack || v_bInHurting || v_bInLying || v_bInCatch || m_boCatchDirectly;

            if ( !v_bForcedCatches ) {
                var guard : Boolean = false;

                if ( m_pCatchData.NeedNoDef ) {
                    var vTargetProperty : ICharacterProperty = vObj.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty;
                    if ( vTargetProperty && vTargetProperty.DefensePower > 0 )
                        guard = true;
//                    if ( !m_boCatchFromHost )
//                        guard = v_pTargetStateBoard.getValue( CCharacterStateBoard.IN_GUARD );
                }

                if ( guard )
                    continue;
            }

            // Counter detected 抓取破招
            if ( v_bInAttack ) {
                v_pTargetStateBoard.setValue( CCharacterStateBoard.COUNTER, true );
                m_pSkillContext.fightTriggle.dispatchEvent( new CFightTriggleEvent(
                        CFightTriggleEvent.EVT_PLAYER_COUNTER, null ) );
            } else {
                v_pTargetStateBoard.setValue( CCharacterStateBoard.COUNTER, false );
            }

//             _resetTargetVelocity( vObj );
            vInfo = vCatcher.catches( m_pCatchData.ID, m_pCatchData.CatchBone, vObj,
                    queryBoneNameByCatchPart( m_pCatchData.CatchPart ),
                    m_pCatchData.Alignment,
                    m_pCatchData.LayerPriority,
                    m_pCatchData.Flip == 1 || m_pCatchData.Flip == 3,
                    m_pCatchData.Flip == 2 || m_pCatchData.Flip == 3,
                    false,
                    false,
                    m_pCatchData.AngleDeg
            );

            CONFIG::debug {
                Foundation.Log.logTraceMsg( "Catching with: " + m_pCatchData.ID + ", " + m_pCatchData.Description + ", " + m_pCatchData.AnimationState + ", ObjID: " + CCharacterDataDescriptor.getID( vObj.data ) );
            }

            // 抓取成功100%算连击
//            var pFightCalc : CFightOthersCalc = m_pSkillContext.pFightCalc.otherFightCalc;
//
//            if ( pFightCalc ) {
//                if ( v_bInHurting || v_bInLying )
//                    pFightCalc.boResetNext = false;
//
//                pFightCalc.increaseCHitWithCount( 1 );
//            }

            if ( !ret )
                ret = new <CGameObject>[];

            ret.push( vObj );
        }
        return ret;
    }

    private function _resetTargetVelocity( vObj : CGameObject ) : void {
        if ( !vObj ) return;
        var pAnimation : IAnimation;
        pAnimation = vObj.getComponentByClass( IAnimation, true ) as IAnimation;
        if ( pAnimation && pAnimation.modelDisplay ) {
            pAnimation.modelDisplay.velocity.setValueXYZ( 0.0, 0.0, 0.0 );
        }

    }

    private function get pSceneMediator() : CSceneMediator {
        return owner.getComponentByClass( CSceneMediator, true ) as CSceneMediator;
    }

    private function get pFxMediator() : CFXMediator {
        return owner.getComponentByClass( CFXMediator, true ) as CFXMediator;
    }

    private function get pMovement() : CMovement {
        return owner.getComponentByClass( CMovement, true ) as CMovement;
    }

    private function get pStateMachine() : CCharacterStateMachine {
        return owner.getComponentByClass( CCharacterStateMachine, true ) as CCharacterStateMachine;
    }

    private var m_bCatchFixMove : Boolean;
    private var m_fMoveTime : Number;
    private var m_theMotionAction : CMotionAction;

}
} // package kof.game.character.fight.skilleffect
// vim:ft=as3:ts=4:sw=4:expandtab:tw=120

