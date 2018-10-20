//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character {

import QFLib.Foundation;
import QFLib.Framework.CObject;
import QFLib.Math.CVector2;
import QFLib.Math.CVector2;
import QFLib.Math.CVector3;
import QFLib.Math.CVector3;
import QFLib.Math.CVector3;

import flash.events.Event;
import flash.geom.Point;

import kof.framework.events.CRequestEvent;
import kof.framework.fsm.CFiniteStateMachine;
import kof.game.character.animation.IAnimation;
import kof.game.character.display.IDisplay;
import kof.game.character.display.IDisplay;
import kof.game.character.fight.buff.CSelfBuffInitializer;
import kof.game.character.fight.emitter.CMasterCompomnent;
import kof.game.character.fight.emitter.CMissileContainer;
import kof.game.character.fight.emitter.CMissileIdentifersRepository;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skill.CSimulateSkillCaster;
import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.fight.skill.CSkillDebugLog;
import kof.game.character.fight.skill.CSkillHit;
import kof.game.character.fight.skill.model.CSkillEffectInfo;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.character.fight.sync.CCharacterSyncBoard;
import kof.game.character.fight.sync.synctimeline.ESyncStateType;
import kof.game.character.movement.CNavigation;
import kof.game.character.movement.CNavigationViewDebug;
import kof.game.character.pathing.CPathingMediator;
import kof.game.character.property.CCharacterProperty;
import kof.game.character.property.interfaces.ICharacterProperty;
import kof.game.character.scene.CSceneMediator;
import kof.game.character.state.CCharacterActionStateConstants;
import kof.game.character.state.CCharacterAttackState;
import kof.game.character.state.CCharacterInput;
import kof.game.character.state.CCharacterKnockUpState;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.character.state.CCharacterStateMachine;
import kof.game.core.CGameObject;
import kof.game.core.CSubscribeBehaviour;
import kof.game.pathing.astar.CAStar;
import kof.table.Aero;
import kof.table.Emitter;
import kof.table.Hit.EHurtAnimationCategory;
import kof.table.Motion;
import kof.table.Skill.EEffectType;
import kof.util.CAssertUtils;
import kof.util.CObjectUtils;

/**
 * 角色ECS组件：功能门面调停接口，高阶层API操作
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CFacadeMediator extends CSubscribeBehaviour {

    /** @private Just ref */
    public var m_pSceneFacadeRef : CSceneMediator;

    private var _pPathingMediator : CPathingMediator;

    /** @private Just ref */
    private var m_pGameStateRef : CCharacterStateMachine;

    /** @private */
    private var m_listMovingStopCalls : Vector.<Function>;

    /** Creates a new CFacadeMediator. */
    public function CFacadeMediator() {
        super( "facade" );
    }

    override protected virtual function onEnter() : void {
        super.onEnter();

        if ( !m_pSceneFacadeRef )
            m_pSceneFacadeRef = getComponent( CSceneMediator ) as CSceneMediator;

        if ( !_pPathingMediator ) {
            _pPathingMediator = getComponent( CPathingMediator ) as CPathingMediator;
        }

        CAssertUtils.assertNotNull( m_pSceneFacadeRef );
        CAssertUtils.assertNotNull( _pPathingMediator );
        m_listMovingStopCalls = new <Function>[];

        var pEventMediator : CEventMediator = getComponent( CEventMediator ) as CEventMediator;
        if ( pEventMediator ) {
            pEventMediator.addEventListener( CCharacterEvent.STOP_MOVE, _onCharacterStopMoved, false, 1, true );
        }

        m_pGameStateRef = getComponent( CCharacterStateMachine ) as CCharacterStateMachine;
    }

    override protected virtual function onExit() : void {
        super.onExit();
        if ( m_listMovingStopCalls )
            m_listMovingStopCalls.splice( 0, m_listMovingStopCalls.length );
        m_listMovingStopCalls = null;

        var pEventMediator : CEventMediator = getComponent( CEventMediator ) as CEventMediator;
        if ( pEventMediator ) {
            pEventMediator.removeEventListener( CCharacterEvent.STOP_MOVE, _onCharacterStopMoved );
        }

        m_pGameStateRef = null;
    }

    //----------------------------------
    // Hacking Properties
    //----------------------------------

    final public function get id() : Number {
        return Number( owner.data.id );
    }

    final public function get nickName() : String {
        if ( CCharacterDataDescriptor.isPlayer( owner.data ) )
            return owner.data.name;
        else {
            return (getComponent( ICharacterProperty ) as ICharacterProperty).nickName;
        }
    }

    final public function get level() : uint {
        return uint( owner.data.level );
    }

    final public function get isMonster() : Boolean {
        return CCharacterDataDescriptor.isMonster( owner.data );
    }

    final public function get isPlayer() : Boolean {
        return CCharacterDataDescriptor.isPlayer( owner.data );
    }

    final public function isHero( data : Object ) : Boolean {
        return CCharacterDataDescriptor.isHero( data );
    }

    final public function isTeammate( data : Object ) : Boolean {
        return CCharacterDataDescriptor.isTeammate( data );
    }

    final public function get prototypeID() : uint {
        return uint( owner.data.prototypeID ) || 1;
    }

    final public function isRobot( data : Object ) : Boolean {
        return CCharacterDataDescriptor.isRobot( data );
    }

    /**
     * 检测当前是否正处于攻击状态下
     */
    final public function get isAttacking() : Boolean {
        var pStateBoard : CCharacterStateBoard = getComponent( CCharacterStateBoard ) as CCharacterStateBoard;
        if ( pStateBoard ) {
            return pStateBoard.getValue( CCharacterStateBoard.IN_ATTACK );
        }
        return false;
    }

    /**
     * 检测当前正在防御中
     */
    final public function get isDefensing() : Boolean {
        var pStateBoard : CCharacterStateBoard = getComponent( CCharacterStateBoard ) as CCharacterStateBoard;
        if ( pStateBoard ) {
            return pStateBoard.getValue( CCharacterStateBoard.IN_GUARD );
        }
        return false;
    }

    /**
     * 检查是否正在移动
     **/
    final public function get isMoving() : Boolean {
        var pStateBoard : CCharacterStateBoard = getComponent( CCharacterStateBoard ) as CCharacterStateBoard;
        if ( pStateBoard ) {
            return pStateBoard.getValue( CCharacterStateBoard.MOVING );
        }
        return false;
    }

    /**
     *检查是否处于受伤状态
     **/
    final public function get isHurting() : Boolean {
        var pStateBoard : CCharacterStateBoard = getComponent( CCharacterStateBoard ) as CCharacterStateBoard;
        if ( pStateBoard ) {
            return pStateBoard.getValue( CCharacterStateBoard.IN_HURTING );
        }
        return false;
    }

    final public function get isLaying() : Boolean {
        var pStateBoard : CCharacterStateBoard = getComponent( CCharacterStateBoard ) as CCharacterStateBoard;
        if ( pStateBoard ) {
            return pStateBoard.getValue( CCharacterStateBoard.LYING );
        }
        return false;
    }

    final public function get isDead() : Boolean {
        var pStateBoard : CCharacterStateBoard = this.getComponent( CCharacterStateBoard ) as CCharacterStateBoard;
        if ( pStateBoard ) {
            return pStateBoard.getValue( CCharacterStateBoard.DEAD_SIGNED ) || pStateBoard.getValue( CCharacterStateBoard.DEAD );
        }
        return false;
    }

    final public function get isDieing() : Boolean {
        var pStateBoard : CCharacterStateBoard = this.getComponent( CCharacterStateBoard ) as CCharacterStateBoard;
        if ( pStateBoard ) {
            return pStateBoard.getValue( CCharacterStateBoard.DEAD_SIGNED );
        }
        return false;
    }

    //----------------------------------
    // Movement
    //----------------------------------

    final public function makeRunStop() : void {
        var pInput : CCharacterInput = getComponent( CCharacterInput ) as CCharacterInput;
        if ( pInput ) {
            pInput.wheel = new Point();
        }
    }

    /**
     * 移动到指定的格子坐标
     * 如果目标格子不可行走，将会返回false，反之true
     */
    final public function moveToGrid( gridPoint : Point, pfnFinished : Function = null ) : Boolean {
        if ( !gridPoint )
            return false;
        var pPixelPoint : CVector2 = this.m_pSceneFacadeRef.toPixel( gridPoint.x, gridPoint.y );
        return this.moveToPixel( Vector.<CVector2>( [ pPixelPoint ] ), pfnFinished );
    }

    /**
     * 移动到指定的像素坐标（3D坐标）
     * 如果目标像素点所处格子不可行走，将会返回false，反之true
     */
    public function moveToPixel3D( pixelPointVec : Vector.<CVector2>, pfnFinished : Function = null ) : Boolean {
        if ( !pixelPointVec )
            return false;
        var pathList : Array = [];
        for ( var i : int = 0; i < pixelPointVec.length; i++ ) {
            var f3DHeight : Number = m_pSceneFacadeRef.getTerrainHeight( pixelPointVec[ i ].x, pixelPointVec[ i ].y );
            if ( this.m_pSceneFacadeRef.isWalkable( pixelPointVec[ i ].x, pixelPointVec[ i ].y, f3DHeight ) ) {
                var childArr : Array = [];
                if ( i == 0 || pathList.length == 0 ) {
                    var onwerf3dHeight : Number = m_pSceneFacadeRef.getTerrainHeight( owner.transform.x, owner.transform.y );
                    childArr = _findPath1( new CVector3( owner.transform.x, owner.transform.y, onwerf3dHeight ), new CVector3( pixelPointVec[ i ].x, pixelPointVec[ i ].y, f3DHeight ) );
                }
                else {
                    var lastf3dHeight : Number = m_pSceneFacadeRef.getTerrainHeight( pathList[ pathList.length - 1 ].x, pathList[ pathList.length - 1 ].y );
                    childArr = _findPath1( new CVector3( pathList[ pathList.length - 1 ].x, pathList[ pathList.length - 1 ].y, lastf3dHeight ), new CVector3( pixelPointVec[ i ].x, pixelPointVec[ i ].y, f3DHeight ) );
                }
                if ( childArr ) {
                    pathList = pathList.concat( childArr );
                }
            }
        }
        if ( pathList == null ) return false;
        if ( pathList.length == 0 ) {
            if ( pfnFinished != null ) pfnFinished();
            return true;
        }

        var pNavigation : CNavigation = getComponent( CNavigation ) as CNavigation;
        if ( pNavigation ) {

            pNavigation.clearPath();
            var arr : Array = [];
            for ( var j : int = 0; j < pathList.length; j++ ) {
                arr.push( {x : pathList[ j ].x, y : pathList[ j ].y} );
            }
            pNavigation.setPathListWithArray( arr );

            var iIdx : int = m_listMovingStopCalls.indexOf( pfnFinished );
            if ( iIdx == -1 )
                m_listMovingStopCalls.push( pfnFinished );

            return true;
        }
        return false;
    }

    public static function getKnockUpTime( height : Number, ySpeed : Number, gravity : Number ) : Number {
        gravity = 200 * gravity;
        return (ySpeed / gravity + Math.sqrt( 2 * height / gravity + (ySpeed * ySpeed) / (gravity * gravity) ) ) +
                CCharacterKnockUpState.DEFAULT_LAND_DURATION +
                CCharacterKnockUpState.DEFAULT_LYING_DURATION;
    }

    private function _findPath1( startPos : CVector3, endPos : CVector3 ) : Array {
        var startGridPos : CVector2 = m_pSceneFacadeRef.toGrid( startPos.x, startPos.y, startPos.z );
        var tarGridPos : CVector2 = m_pSceneFacadeRef.toGrid( endPos.x, endPos.y, endPos.z );
        var pathList : Array = _pPathingMediator.findPath( startGridPos.x, startGridPos.y, tarGridPos.x, tarGridPos.y );
        if ( pathList == null || pathList.length == 0 ) return null;
        pathList = _pathingClip( pathList );
        var pDisplay : IDisplay = getComponent( IDisplay ) as IDisplay;
        m_pSceneFacadeRef.transToPixelList( pDisplay.modelDisplay, pathList );
        return pathList;
    }

    /**
     * 移动到指定的像素坐标（2D坐标）
     * 如果目标像素点所处格子不可行走，将会返回false，反之true
     */
    public function moveToPixel( pixelPointVec : Vector.<CVector2>, pfnFinished : Function = null, isWalkFlag : Boolean = false ) : Boolean {
        if ( !pixelPointVec )
            return false;

        var pDisplay : IDisplay = getComponent( IDisplay ) as IDisplay;
        var pathList : Array = [];
        for ( var i : int = 0; i < pixelPointVec.length; i++ ) {
            // 2D to 3D here.
            var pos : CVector3 = new CVector3();
            CObject.get3DPositionFrom2D( pDisplay.modelDisplay, pixelPointVec[ i ].x, pixelPointVec[ i ].y, 0.0, pos );
            if ( this.m_pSceneFacadeRef.isWalkable( pos.x, pos.z, pos.y ) || isWalkFlag ) {
                var childArr : Array = [];
                if ( i == 0 || pathList.length == 0 ) {
                    childArr = _findPath2( new CVector2( owner.transform.x, owner.transform.y ), new CVector2( pos.x, pos.z ) );
                }
                else {
                    childArr = _findPath2( new CVector2( pathList[ pathList.length - 1 ].x, pathList[ pathList.length - 1 ].y ), new CVector2( pos.x, pos.z ) );
                }
                if ( childArr ) {
                    pathList = pathList.concat( childArr );
                }
            }
        }
//        if ( pathList == null ) return false;
        //等于0可以理解为没有可走的点
        if ( pathList.length == 0 ) {
//            if ( pfnFinished != null ) pfnFinished();
            return false;
        }

        var pNavigation : CNavigation = getComponent( CNavigation ) as CNavigation;
        if ( pNavigation ) {

            pNavigation.clearPath();
            var arr : Array = [];
            for ( var j : int = 0; j < pathList.length; j++ ) {
                arr.push( {x : pathList[ j ].x, y : pathList[ j ].y} );
            }
            pNavigation.setPathListWithArray( arr );

            var iIdx : int = m_listMovingStopCalls.indexOf( pfnFinished );
            if ( iIdx == -1 )
                m_listMovingStopCalls.push( pfnFinished );

            return true;
        }
        return false;
    }

    public var isShowRoadLine : Boolean = false;

    /**
     * 移动到指定的世界坐标（3D坐标）
     * 如果目标世界坐标转成2D所处格子不可行走，将会返回false，反之true
     */
    public function moveTo( thePos3DVec2D : CVector2, pfnFinished : Function = null ) : Boolean {
        if ( !thePos3DVec2D )
            return false;

        CAssertUtils.assertNotNaN( thePos3DVec2D.x );
        CAssertUtils.assertNotNaN( thePos3DVec2D.y );

        var f3DHeight : Number = m_pSceneFacadeRef.getTerrainHeight( thePos3DVec2D.x, thePos3DVec2D.y );

        if ( !this.m_pSceneFacadeRef.isWalkable( thePos3DVec2D.x, thePos3DVec2D.y, f3DHeight ) )
            return false;

        var vec3D : CVector3 = new CVector3( thePos3DVec2D.x, thePos3DVec2D.y, f3DHeight );

        var pathList : Array = _findPath( vec3D );

        if ( pathList == null ) return false;
        if ( pathList.length == 0 ) {
            if ( pfnFinished != null ) pfnFinished();
            return true;
        }

        var pNavigation : CNavigation = getComponent( CNavigation ) as CNavigation;
        if ( pNavigation ) {
            pNavigation.clearPath();
            pNavigation.setPathListWithArray( pathList );
            CONFIG::debug{
                if ( isShowRoadLine ) {
                    var pNavigationView : CNavigationViewDebug = getComponent( CNavigationViewDebug ) as CNavigationViewDebug;
                    if ( pNavigationView ) {
                        pNavigationView.addQuad( pathList, m_pSceneFacadeRef, owner );
                    }
                }
            }

            var iIdx : int = m_listMovingStopCalls.indexOf( pfnFinished );
            if ( iIdx == -1 )
                m_listMovingStopCalls.push( pfnFinished );
            return true;
        }
        return false;
    }

    private function _findPath( pos : CVector3 ) : Array {
        var startGridPos : CVector2 = m_pSceneFacadeRef.toGrid( transform.x, transform.y, transform.z );
        var tarGridPos : CVector2 = m_pSceneFacadeRef.toGrid( pos.x, pos.y, pos.z );
        var pathList : Array = _pPathingMediator.findPath( startGridPos.x, startGridPos.y, tarGridPos.x, tarGridPos.y ); // 反转的路径

        if ( pathList == null || pathList.length == 0 ) return null;

        pathList = _pathingClip( pathList );

        var bCutOff : Boolean = false;
        for ( var i : int = 0; i < pathList.length; i++ ) {
            if ( m_pSceneFacadeRef.isBlockedGrid( pathList[ i ].x, pathList[ i ].y ) ) {
                pathList.length = i;
                bCutOff = true;
                break;
            }
        }
        if ( pathList.length == 0 ) return null;

        var pDisplay : IDisplay = getComponent( IDisplay ) as IDisplay;
        m_pSceneFacadeRef.transToPixelList( pDisplay.modelDisplay, pathList );

        if ( bCutOff == false ) {
            var lastPoint : CVector2 = pathList[ pathList.length - 1 ];
            lastPoint.setValueXY( pos.x, pos.y );
        }

        return pathList;
    }

    private function _findPath2( startPos : CVector2, endPos : CVector2 ) : Array {
        var startGridPos : CVector2 = m_pSceneFacadeRef.toGrid( startPos.x, startPos.y );
        var tarGridPos : CVector2 = m_pSceneFacadeRef.toGrid( endPos.x, endPos.y );
        var pathList : Array = _pPathingMediator.findPath( startGridPos.x, startGridPos.y, tarGridPos.x, tarGridPos.y );
        if ( pathList == null || pathList.length == 0 ) return null;
        pathList = _pathingClip( pathList );
        var pDisplay : IDisplay = getComponent( IDisplay ) as IDisplay;
        m_pSceneFacadeRef.transToPixelList( pDisplay.modelDisplay, pathList );
        return pathList;
    }

    // 优化路径点, 目前路径连续有问题
    private function _pathingClip( pathingList : Array ) : Array {
        if ( pathingList == null || pathingList.length == 0 ) return null;

        var preNode : CVector2;
        var pathNode : CVector2;
        var subX : int;
        var subY : int;
        var likeDir : int;
        var curDir : int;
        for ( var i : int = 1; i < pathingList.length; ++i ) {
            preNode = pathingList[ i - 1 ];
            pathNode = pathingList[ i ];
            subX = (pathNode.x - preNode.x);
            subY = (pathNode.y - preNode.y) * 1000;
            curDir = subX + subY;
            if ( likeDir == curDir ) {
                pathingList.splice( i - 1, 1 );
                i--;
            } else {
                likeDir = curDir;
            }
        }
        return pathingList;
    }

    //----------------------------------
    // Fighting
    //----------------------------------

    /**
     * 攻击目标
     */
    public function attackTarget( obj : CGameObject, skillId : int = 0 ) : void {
        if ( !obj )
            return;
        this.directionTo( obj );

        // Attack by the specified skill.
        this.attack( skillId );
    }

    /**
     * 向前方攻击，如果技能需要攻击目标该方法不会被有效执行
     */
    private function attack( skillId : int = 0 ) : Boolean {

        var ret : int = m_pGameStateRef.actionFSM.on( CCharacterActionStateConstants.EVENT_ATTACK_BEGAN, skillId );
        return CFiniteStateMachine.Result.SUCCEEDED == ret || CFiniteStateMachine.Result.NO_TRANSITION == ret;
    }

    /**d
     *
     * @param skillID 调用技能攻击
     */
    public function attackWithSkillID( skillID : int ) : void {

        if ( skillID > 0 ) {
            attack( skillID );
        }
        else
            Foundation.Log.logTraceMsg( "You attack with skill that no exist in player's skill list:  ID " + skillID )
    }

    /**
     * 向前方攻击，通过传入技能的索引值，从0开始，0表示普攻第一技能
     */
    public function attackWithSkillIndex( nSkillIndex : int = 0 ) : void {
        // FIXME: 现阶段还没有技能配对的数值表，所以简单模拟下
        var skillList : CSkillList = owner.getComponentByClass( CSkillList, true ) as CSkillList;
        var skillID : int = skillList.getSkillIDByIndex( nSkillIndex );
        if ( skillID == 0 ) {
            var fightTrigger : CCharacterFightTriggle = owner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
            fightTrigger.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.SKILL_NOT_EXIST, null, null ) );
            CSkillDebugLog.logTraceMsg( "! The skill you spell not exist, ID is : " + skillID );
            return;
        }
        this.attack( skillID );
    }

    /**
     * 向某一方向进行突击闪避
     */
    public function dodgeSudden( condition : Array = null, boNetSync : Boolean = false ) : Boolean {
        var fightTrigger : CCharacterFightTriggle = owner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
        var pCharacterProperty : CCharacterProperty = owner.getComponentByClass( CCharacterProperty , true ) as CCharacterProperty;
        fightTrigger.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.REQUEST_SYNC_FIGHT_STATE, null, CCharacterSyncBoard.SYNC_SKILL_PROPERTY ) );
        fightTrigger.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.REQUEST_SYNC_FIGHT_STATE, null, [ CCharacterSyncBoard.SKILL_CD_LIST ] ) );
        var ret : int = m_pGameStateRef.actionFSM.on( CCharacterActionStateConstants.EVENT_DODGE_BEGAN, condition, boNetSync );
        var boDodge : Boolean = ret == CFiniteStateMachine.Result.SUCCEEDED || ret == CFiniteStateMachine.Result.PENDING;
        var dodgeGravity : Number = pCharacterProperty.quickStandGravity;
        if ( boDodge ) {
            var pSyncBoard : CCharacterSyncBoard = owner.getComponentByClass( CCharacterSyncBoard, true ) as CCharacterSyncBoard;
            if ( pSyncBoard ) {
                var theSubStates : Object = {};
                pSyncBoard.setValue( CCharacterSyncBoard.SYNC_STATE, ESyncStateType.STATE_FIGHT );
                var pStateBoard : CCharacterStateBoard = owner.getComponentByClass( CCharacterStateBoard, false ) as CCharacterStateBoard;
                var boOnGround : Boolean = pStateBoard.getValue( CCharacterStateBoard.ON_GROUND );
                var subStateType : int;
                var subStateTime : Number;
                if ( boOnGround ) {
                    subStateType = ESyncStateType.SUB_FIGHT_WUDI;
                    subStateTime = 2.0;
                } else {
                    var height : Number = this.transform.z;
                    var fallingTime : Number = Math.sqrt( 2 * height / ( 200 * dodgeGravity ) );
                    subStateTime = 2.0 + fallingTime;
                    subStateType = ESyncStateType.SUB_FIGHT_WUDI
                }

                theSubStates[ subStateType ] = subStateTime;
                pSyncBoard.setValue( CCharacterSyncBoard.SYNC_SUB_STATES, theSubStates );
            }
            fightTrigger.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.REQUEST_SYNC_DODGE, null ) );
        }

        return boDodge;
    }

    public function exeHitWithTargets( hitID : int, targets : Array, collidedArea : Array = null ) : void {
        var pSkillCaster : CSkillCaster = owner.getComponentByClass( CSkillCaster, true ) as CSkillCaster;
        var pHitEffect : CSkillHit;
        if ( pSkillCaster ) {
            var effecInfo : CSkillEffectInfo = new CSkillEffectInfo();
            effecInfo.EffectType = EEffectType.E_HIT;
            effecInfo.EffectID = hitID;
            effecInfo.EffectDes = "hit directly";
            pHitEffect = pSkillCaster.appendSkillEffect( effecInfo ) as CSkillHit;
            if ( pHitEffect )
                pHitEffect.hitTargetDirectly( targets, collidedArea );
        }
    }

    public function forceCancelAttakState() : void {
        var stateMech : CCharacterStateMachine = owner.getComponentByClass( CCharacterStateMachine, true ) as CCharacterStateMachine;
        if ( stateMech ) {
            if ( stateMech.actionFSM.currentState is CCharacterAttackState )
                stateMech.actionFSM.on( CCharacterActionStateConstants.EVENT_ATTACK_END );
        }
    }

    /**复活*/
    public function revive( obj : CGameObject ) : Boolean {
        var ret : int = -1;
        var sStateAction : String = "";
        var pStateBoard : CCharacterStateBoard = obj.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
        if ( pStateBoard ) {
            pStateBoard.resetValue( CCharacterStateBoard.DEAD );
        }
        var m_pGameStateRef : CCharacterStateMachine = obj.getComponentByClass( CCharacterStateMachine, true ) as CCharacterStateMachine;
        var iAnimation : IAnimation = owner.getComponentByClass( IAnimation, true ) as IAnimation;
        ret = m_pGameStateRef.actionFSM.on( "startup" );
        iAnimation.playAnimation( "Idle_1".toUpperCase(), false, false );
        return ret;
    }

    //----------------------------------------------------------------------------
    //
    // Testing Usage. [Start]
    //
    //----------------------------------------------------------------------------

    public function _testTeleToTarget() : void {
        var pSkillCaster : CSkillCaster = getComponent( CSkillCaster, true ) as CSkillCaster;
        if ( pSkillCaster ) {
            var pTargetComp : CTarget = getComponent( CTarget, true ) as CTarget;
            if ( pTargetComp.targetObject ) {
                pSkillCaster.castTeleportToTarget( 10086, pTargetComp.targetObject );
            }
        }
    }

    public function _testBorn() : void {
        var ret : int = -1;
        var sStateAction : String = "";
        var pStateBoard : CCharacterStateBoard = getComponent( CCharacterStateBoard ) as CCharacterStateBoard;
        if ( pStateBoard ) {
            pStateBoard.resetValue( CCharacterStateBoard.DEAD );
        }
        ret = m_pGameStateRef.actionFSM.on( "startup" );
        this._testingStateReport( sStateAction + " BORN", ret );
    }

    public function _testDead() : void {
        var ret : int = -1;
        var sStateAction : String = "";
        var pStateBoard : CCharacterStateBoard = getComponent( CCharacterStateBoard ) as CCharacterStateBoard;
        if ( pStateBoard ) {
            pStateBoard.setValue( CCharacterStateBoard.DEAD, true );
        }
        ret = m_pGameStateRef.actionFSM.on( CCharacterActionStateConstants.EVENT_DEAD );
        this._testingStateReport( sStateAction + " DEAD", ret );
    }

    /**
     * 被击飞
     */
    public function _testKnockUp( iDirX : int = 0, frozonT : Number = 0, mdata : Motion = null, aliasPos : CVector3 = null ) : void {
        var ret : int = -1;
        var sStateAction : String = "";
        ret = m_pGameStateRef.actionFSM.on( CCharacterActionStateConstants.EVENT_KNOCK_UP_BEGAN, iDirX, frozonT, mdata, aliasPos );
        this._testingStateReport( sStateAction + " KNOCKUP", ret );
    }

    public function _testPopToIdle() : void {
        var ret : int = -1;
        var sStateAction : String = "";
        ret = m_pGameStateRef.actionFSM.on( CCharacterActionStateConstants.EVENT_POP );
        this._testingStateReport( sStateAction + " IDLE", ret );
    }

    /** @private internal test useOnly. */
    private var m_iTypeOfHurt : int;

    /**
     * 随机伤害，但是每次不同
     */
    public function _testRandomHurt( iDirX : int = 0, frozonT : Number = 0, mData : Motion = null, attackPos : CVector3 = null ) : void {
        var ret : int = -1;
        var sStateAction : String = "";

        // 0, 1, 2 cycle.

        var iTemp : int = Math.random() >= 0.5 ? 2 : 1;
        m_iTypeOfHurt += (iTemp);

        if ( m_iTypeOfHurt > 2 )
            m_iTypeOfHurt -= 3;

        ret = m_pGameStateRef.actionFSM.on( CCharacterActionStateConstants.EVENT_HURT_BEGAN, m_iTypeOfHurt, EHurtAnimationCategory.E_UPPER, iDirX, frozonT, mData, attackPos );
        this._testingStateReport( sStateAction + " HURT", ret );
    }

    /**
     * 伤害受击
     */
    public function _testDamageHurt() : void {
        var ret : int = -1;
        var sStateAction : String = "";
        ret = m_pGameStateRef.actionFSM.on( CCharacterActionStateConstants.EVENT_HURT_BEGAN );
        this._testingStateReport( sStateAction + " HURT", ret );
    }

    /**
     * 测试buff
     */

    public function _testAddBuffToSelf( buffList : Array ) : void {
        var pBuffSelf : CSelfBuffInitializer = owner.getComponentByClass( CSelfBuffInitializer, true ) as CSelfBuffInitializer;
        if ( pBuffSelf )
            pBuffSelf.addBuffsToSelf( buffList );
    }

    /**
     * 暴击伤害受击
     */
    public function _testCriticalDamageHurt() : void {
        var ret : int = -1;
        var sStateAction : String = "";
        ret = m_pGameStateRef.actionFSM.on( CCharacterActionStateConstants.EVENT_HURT_BEGAN, 1 );
        this._testingStateReport( sStateAction + " CRIT HURT", ret );
    }

    /**
     * 防御受击
     */
    public function _testGuardHurt() : void {
        var ret : int = -1;
        var sStateAction : String = "";
        ret = m_pGameStateRef.actionFSM.on( CCharacterActionStateConstants.EVENT_HURT_BEGAN, 2 );
        this._testingStateReport( sStateAction + " GUARD HURT", ret );
    }

    /** 报告状态切换结果 */
    private function _testingStateReport( sNameOfState : String, iTypeOfRet : int ) : void {
        sNameOfState = sNameOfState || "UNKNOWN";
        if ( iTypeOfRet == CFiniteStateMachine.Result.SUCCEEDED ) {
            Foundation.Log.logTraceMsg( "Request to \"" + sNameOfState + "\" state " + "[SUCCEEDED]" );
        } else if ( iTypeOfRet == CFiniteStateMachine.Result.NO_TRANSITION ) {
            Foundation.Log.logTraceMsg( "Request to \"" + sNameOfState + "\" state " + "[NO TRANSITION]" );
        } else if ( iTypeOfRet == CFiniteStateMachine.Result.PENDING ) {
            Foundation.Log.logTraceMsg( "Request to \"" + sNameOfState + "\" state " + "[PENDING]" );
        } else if ( iTypeOfRet == CFiniteStateMachine.Result.CANCELLED ) {
            Foundation.Log.logTraceMsg( "Request to \"" + sNameOfState + "\" state " + "[CANCELLED]" );
        } else if ( iTypeOfRet == CFiniteStateMachine.Error.INVALID_TRANSITION ) {
            Foundation.Log.logErrorMsg( "Request to \"" + sNameOfState + "\" state %%%ERROR%%% " + "[INVALID]" );
        } else if ( iTypeOfRet == CFiniteStateMachine.Error.PENDING_TRANSITION ) {
            Foundation.Log.logErrorMsg( "Request to \"" + sNameOfState + "\" state %%%ERROR%%% " + "[PENDING]" );
        }
    }

    public function _testSetStateBoard( key : int, value : *, tag : int = -1 ) : void {
        var pStateBoard : CCharacterStateBoard = owner.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
        if ( pStateBoard ) {
            pStateBoard.setValue( key, value, tag );
        }
    }

    public function _testLeaveDodge( bForceExit : Boolean = true ) : void{
        var pStateMachine : CCharacterStateMachine = owner.getComponentByClass( CCharacterStateMachine , false ) as CCharacterStateMachine;
        var pAnimation : IAnimation = owner.getComponentByClass( IAnimation , false ) as IAnimation;

        var bRet : Boolean = pStateMachine.actionFSM.on( CCharacterActionStateConstants.EVENT_POP , bForceExit );//EVENT_ATTACK_END
        if ( bRet && pAnimation ) {
            pAnimation.playAnimation( CCharacterActionStateConstants.IDLE, true );
        }
    }

    /**
     * 测试跳跃
     */
    public function _testJump() : void {
        var pCharacterDisplay : IDisplay = getComponent( IDisplay ) as IDisplay;
        if ( pCharacterDisplay ) {
            pCharacterDisplay.modelDisplay.jump( 200.0 );
        }
    }

    /**
     *
     * @param obj
     * @return
     */
    public function _ShotMissile( emitterID : int, missileSeq : Number = 0, position : CVector3 = null ) : void {
        var pSkillCaster : CSkillCaster = getComponent( CSkillCaster ) as CSkillCaster;
        var pMissileContainer : CMissileContainer = pSkillCaster.missileContainer;
        var missileData : Object;

        var emitterInfo : Emitter = CSkillCaster.skillDB.getEmmiterByID( emitterID );
        var missileID : int = emitterInfo.MissileID;
        var missileInfo : Aero = CSkillCaster.skillDB.getAeroByID( missileID );
        var axis2D : CVector3;
        var pTransform : CKOFTransform = owner.getComponentByClass( CKOFTransform, true ) as CKOFTransform;
        var playerPorperty : CCharacterProperty = owner.getComponentByClass( CCharacterProperty, true ) as CCharacterProperty;
        var missilePorperty : CMasterCompomnent = owner.getComponentByClass( CMasterCompomnent, true ) as CMasterCompomnent;

        var pDisplay : IDisplay = owner.getComponentByClass( IDisplay, true ) as IDisplay;

        if ( position )
            axis2D = position;
        else
            axis2D = new CVector3( pTransform.to2DAxis().x, pTransform.to2DAxis().y, pTransform.z );

        missileData = {};
        missileData[ "fightProperty" ] = CObjectUtils.cloneObject( playerPorperty.fightProperty );
        missileData[ "campID" ] = CCharacterDataDescriptor.getCampID( owner.data );
        missileData[ "skin" ] = missileInfo.MissleSpine;
        missileData[ "x" ] = axis2D.x;
        missileData[ "y" ] = axis2D.y;
        missileData[ "z" ] = axis2D.z;
        missileData[ "direction" ] = pDisplay.direction;
        missileData[ "missileId" ] = missileID;
        missileData[ "missileSeq" ] =  pMissileIDsRes.getNextIDByEmitter( emitterID );
        missileData[ "missileHP" ] = missileInfo.HMBeHit;
        missileData[ "type" ] = CCharacterDataDescriptor.TYPE_MISSILE;

        var ownerType : int = CCharacterDataDescriptor.getType( pSkillCaster.owner.data );
        if ( ownerType == CCharacterDataDescriptor.TYPE_MISSILE ) {
            missileData[ "ownerId" ] = missilePorperty.ownerId;
            missileData[ "ownerType" ] = missilePorperty.ownerType;
            missileData[ "ownerSkin" ] = missilePorperty.ownerSkin;
            missileData[ "aliasSkillID" ] = missilePorperty.aliasSkillID;

        } else if ( ownerType == CCharacterDataDescriptor.TYPE_PLAYER ||
                ownerType == CCharacterDataDescriptor.TYPE_MONSTER ) {
            missileData[ "ownerId" ] = CCharacterDataDescriptor.getID( pSkillCaster.owner.data );
            missileData[ "ownerType" ] = CCharacterDataDescriptor.getType( pSkillCaster.owner.data );
            missileData[ "ownerSkin" ] = CCharacterDataDescriptor.getSkinName( pSkillCaster.owner.data );
            missileData[ "aliasSkillID" ] = pSkillCaster.skillID;
        }

        missileData[ "moveSpeed" ] = 1;

        if ( pMissileContainer ) {
            pMissileContainer.shotMissile( missileData );
        }
    }

    final private function get pMissileIDsRes() : CMissileIdentifersRepository{
        return owner.getComponentByClass( CMissileIdentifersRepository , true ) as CMissileIdentifersRepository;
    }

    //----------------------------------------------------------------------------
    //
    // Testing Usage. [End]
    //
    //----------------------------------------------------------------------------

    //----------------------------------
    // Display
    //----------------------------------

    final public function directionTo( obj : CGameObject ) : Boolean {
        if ( !obj || !obj.transform )
            return false;

        var offsetX : Number = obj.transform.x - transform.x;
        var directionX : int = offsetX > 0 ? 1 : -1;
        // Turn my direction if needed.
        return this.setDisplayDirection( directionX );
    }

    final public function setDisplayDirection( direction : int ) : Boolean {
        var pStateBoard : CCharacterStateBoard = getComponent( CCharacterStateBoard ) as CCharacterStateBoard;
        if ( pStateBoard && pStateBoard.getValue( CCharacterStateBoard.DIRECTION_PERMIT ) ) {
            var dir : Point = pStateBoard.getValue( CCharacterStateBoard.DIRECTION );
            dir.setTo( direction, 0 );
            return true;
        }
        return false;
    }

    //----------------------------------
    // Animation
    //----------------------------------

    /** @private */
    final private function _onCharacterStopMoved( event : Event ) : void {

        var pInput : CCharacterInput = getComponent( CCharacterInput ) as CCharacterInput;
        if ( pInput ) {
            pInput.wheel = new Point( 0, 0 );
//            pInput.makeWheelDirty();
        }

        if ( m_listMovingStopCalls && m_listMovingStopCalls.length ) {

            if ( m_listMovingStopCalls.length > 1 )
                m_listMovingStopCalls = m_listMovingStopCalls.reverse();

            var fnCallback : Function;
            var len : int = m_listMovingStopCalls.length;
            for ( var i : int = 0; i < len; i++ ) {
                fnCallback = m_listMovingStopCalls.pop();
                if ( null != fnCallback ) {
                    fnCallback();
                }
            }
        }
    }

    public function switchQItem() : void
    {
        var targetID : int = 0;
        this.m_pSceneFacadeRef.swapHeroShowIndex( 1 );
        var pList : Vector.<CGameObject> = this.m_pSceneFacadeRef.findHeroAsList();
        if( pList && pList.length > 1){
                var target : CGameObject = pList[0];
                if( target == null ) return;
                var pFacade : CFacadeMediator = target.getComponentByClass( CFacadeMediator , true ) as CFacadeMediator;

                while( pFacade && pFacade.isDead ) {
                    this.m_pSceneFacadeRef.swapHeroShowIndex( 1 );
                    target = pList[0];
                    pFacade  = target.getComponentByClass( CFacadeMediator , true ) as CFacadeMediator;
                    if( pFacade && !pFacade.isDead)
                            break;
                }
                targetID = CCharacterDataDescriptor.getID( target.data );
                if( targetID > 0)
                    switchHeroByID( targetID );
        }

    }

    public function switchEItem() : void
    {
        var targetID : int = 0;
        this.m_pSceneFacadeRef.swapHeroShowIndex( -1 );
        var pList : Vector.<CGameObject> = this.m_pSceneFacadeRef.findHeroAsList();
        if( pList && pList.length > 1){
                var target : CGameObject = pList[0];
                if( target == null ) return;
                var pFacade : CFacadeMediator = target.getComponentByClass( CFacadeMediator , true ) as CFacadeMediator;

                while( pFacade && pFacade.isDead ) {
                    this.m_pSceneFacadeRef.swapHeroShowIndex( -1 );
                    target = pList[0];
                    pFacade  = target.getComponentByClass( CFacadeMediator , true ) as CFacadeMediator;
                    if( pFacade && !pFacade.isDead)
                            break;
                }
                targetID = CCharacterDataDescriptor.getID( target.data );
                if(targetID>0)
                    switchHeroByID( targetID );
        }

        /**
        var targetID : int = 0;

        var pList : Vector.<CGameObject> = this.m_pSceneFacadeRef.findHeroAsList();
        if( pList && pList.length > 0){
            if( pList.length > 2 ) {
                var target : CGameObject = pList[2];
                if( target == null ) return;
                var pFacade : CFacadeMediator = target.getComponentByClass( CFacadeMediator , true ) as CFacadeMediator;
                if( pFacade && pFacade.isDead ) return ;
                targetID = CCharacterDataDescriptor.getID( target.data );

                this.m_pSceneFacadeRef.swapHeroShowIndex( 0 , 2 );
            }
        }
        switchHeroByID( targetID );
         */
    }

    public function switchPrevHero() : void {
        switchQItem();
        return;
        // Foundation.Log.logWarningMsg( "Request to switch prev hero if absent." );
        // Find prev hero.
        var targetID : int = 0;

        var pList : Vector.<CGameObject> = this.m_pSceneFacadeRef.findHeroAsList();
        if ( pList && pList.length ) {
            pList = pList.filter( function ( obj : CGameObject, idx : int, arr : * ) : Boolean {
                var pFacade : CFacadeMediator = obj.getComponentByClass( CFacadeMediator, true ) as CFacadeMediator;
                if ( pFacade )
                    return !pFacade.isDead;
                return false;
            } );

            if ( pList.length <= 1 )
                return;

            for ( var i : int = 0; i < pList.length; ++i ) {
                var obj : CGameObject = pList[ i ];
                if ( CCharacterDataDescriptor.isHero( obj.data ) ) {
                    CAssertUtils.assertEquals( obj, owner );

                    if ( i == 0 ) {
                        // switch to the last one.
                        targetID = CCharacterDataDescriptor.getID( pList[ pList.length - 1 ].data );
                    } else {
                        targetID = CCharacterDataDescriptor.getID( pList[ i - 1 ].data );
                    }
                    break;
                }
            }
        }

        switchHeroByID( targetID );
    }

    public function switchNextHero() : void {
        switchEItem();
        return;
        // Foundation.Log.logWarningMsg( "Request to switch next hero if absent." );
        // Find next hero.

        var targetID : int = 0;

        var pList : Vector.<CGameObject> = this.m_pSceneFacadeRef.findHeroAsList();
        if ( pList && pList.length ) {
            pList = pList.filter( function ( obj : CGameObject, idx : int, arr : * ) : Boolean {
                var pFacade : CFacadeMediator = obj.getComponentByClass( CFacadeMediator, true ) as CFacadeMediator;
                if ( pFacade )
                    return !pFacade.isDead;
                return false;
            } );

            if ( pList.length <= 1 )
                return;

            for ( var i : int = 0; i < pList.length; ++i ) {
                var obj : CGameObject = pList[ i ];
                if ( CCharacterDataDescriptor.isHero( obj.data ) ) {
                    CAssertUtils.assertEquals( obj, owner );

                    if ( i == pList.length - 1 ) {
                        // switch to the first one.
                        targetID = CCharacterDataDescriptor.getID( pList[ 0 ].data );
                    } else {
                        targetID = CCharacterDataDescriptor.getID( pList[ i + 1 ].data );
                    }
                    break;
                }
            }
        }

        switchHeroByID( targetID );
    }

    private var m_iHeroIDtoSwitch : int;

    public function switchHeroByID( idHero : uint ) : void {
        // send request to the server for braodcasting.
        var pEventMediator : CEventMediator = getComponent( CEventMediator ) as CEventMediator;
        if ( pEventMediator && pEventMediator.enabled ) {
            pEventMediator.dispatchEvent( new CRequestEvent( CCharacterEvent.SWITCH_HERO, idHero ) );
        }

        // m_iHeroIDtoSwitch = idHero;
    }

    /**筛选正在操控的玩家*/
    public function filterPlayerObject() : CGameObject {
        var pList : Vector.<CGameObject> = this.m_pSceneFacadeRef.findHeroAsList();
        if ( pList && pList.length ) {
            pList = pList.filter( function ( obj : CGameObject, idx : int, arr : * ) : Boolean {
                var pFacade : CFacadeMediator = obj.getComponentByClass( CFacadeMediator, true ) as CFacadeMediator;
                if ( pFacade )
                    return !pFacade.isDead;
                return false;
            } );

            if ( pList.length < 1 )
                return null;

            for ( var i : int = 0; i < pList.length; ++i ) {
                var obj : CGameObject = pList[ i ];
                if ( CCharacterDataDescriptor.isHero( obj.data ) ) {
//                    CAssertUtils.assertEquals( obj, owner );
                    return obj
                    break;
                }
            }
        }
        return null;
    }

    override public virtual function update( delta : Number ) : void {
        super.update( delta );

        if ( m_iHeroIDtoSwitch > 0 ) {
            var id : int = m_iHeroIDtoSwitch;
            m_iHeroIDtoSwitch = 0;

            // dummy server response.
            m_pSceneFacadeRef.updateCharacter( {
                id : CCharacterDataDescriptor.getID( owner.data ),
                type : 1,
                aiID : 0,
                operateSide : 2
            } );

            m_pSceneFacadeRef.updateCharacter( {
                id : id,
                type : 1,
                aiID : 0,
                operateSide : 1
            } );
        }
    }
    /**清除移动完成后的回调函数*/
    final public function clearMoveFinishFunction():void{
        for each(var func:Function in m_listMovingStopCalls){
            func=null;
        }
        m_listMovingStopCalls.splice(0,m_listMovingStopCalls.length);
    }

}
}

// vim:ft=as3 tw=120
