//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.animation {

import QFLib.Collision.CCollisionBound;
import QFLib.Collision.common.ICollision;
import QFLib.Foundation;
import QFLib.Framework.CAnimationController;
import QFLib.Framework.CAnimationState;
import QFLib.Framework.CCharacter;
import QFLib.Framework.CCollisionObject;
import QFLib.Framework.CharacterExtData.CCharacterCollisionKey;
import QFLib.Math.CAABBox3;
import QFLib.Math.CVector2;
import QFLib.Math.CVector3;

import flash.events.Event;
import flash.geom.Point;
import flash.trace.Trace;
import flash.utils.Dictionary;

import kof.game.character.CCharacterEvent;
import kof.game.character.CEventMediator;
import kof.game.character.collision.ICollisable;
import kof.game.character.display.CBaseDisplay;
import kof.game.character.movement.CMovement;
import kof.game.character.property.CMonsterProperty;
import kof.game.character.state.CCharacterStateBoard;

/**
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CBaseAnimationDisplay extends CBaseDisplay implements IAnimation, ICollisable {

    static public const DEFAULT_ANIMATION_SPEED : Number = 1.0;

    private var m_pEventMediator : CEventMediator;
    private var m_pStateBoard : CCharacterStateBoard;

    private var m_iStateValue : int;

    private var m_fResumeAnimationTimeLeft : Number;
    private var m_listAnimationFrozenNotifies : Dictionary;

    private var m_fResumeFrameTimeLeft : Number;
    private var m_listFrameFrozenNotifies : Dictionary;

    private var m_bLastFrameMode : Boolean;
    private var m_boSkillPlaying : Boolean;
    private var m_inTurnning :Boolean;

    private var m_bNoPhysicsAndAnimationOffset : Boolean;

    private var m_bAnimationOffsetEnabled : Boolean;
    private var m_bAnimationOffsetEnabledDirty : Boolean;
    private var m_fResumeAnimationSpeed : Number;

    private var m_listAnimationCallbacks : Vector.<Function>;

    private var m_boInView : Boolean;
    private var m_bAnimationBanFrozen : Boolean;
    private var m_fDefaultGravityAcc : Number;

    private var m_lastFrameModeTimeLeft : Number = NaN;

    public function CBaseAnimationDisplay( pDisplay : CCharacter = null ) {
        super( pDisplay );
    }

    override public function dispose() : void {
        super.dispose();

        m_pEventMediator = null;
        m_pStateBoard = null;
    }

    override protected function onEnter() : void {
        super.onEnter();

        m_pEventMediator = getComponent( CEventMediator ) as CEventMediator;
        m_pStateBoard = getComponent( CCharacterStateBoard ) as CCharacterStateBoard;
        m_boFirstInView = true;
        setEnableCollision( false );
    }

    override protected function onDataUpdated() : void {
        super.onDataUpdated();

        if ( 'stateValue' in owner.data || owner.data.hasOwnProperty( 'stateValue' ) ) {
            this.m_iStateValue = int( owner.data.stateValue );
        }

        if ( 'direction' in owner.data || owner.data.hasOwnProperty( 'direction' ) ) {
            var pDir : Point = this.m_pStateBoard.getValue( CCharacterStateBoard.DIRECTION );
            pDir.x = int( owner.data.direction ) || 1;
        }

        var pModel : CCharacter = this.modelDisplay;
        if ( pModel ) {
            pModel.setPosition( transform.x, transform.z, transform.y );

            pModel.enablePhysics = true;
            pModel.animationSpeed = DEFAULT_ANIMATION_SPEED;
        }

        var fDefaultStepHeight : Number = 150.0;
        if ( 'stepHeight' in owner.data || owner.data.hasOwnProperty( 'stepHeight' ) ) {
            this.stepHeight = Number( owner.data.stepHeight );
            if ( !isNaN( this.stepHeight ) )
                this.stepHeight = fDefaultStepHeight;
        } else {
            this.stepHeight = fDefaultStepHeight;
        }

        setFrozenBan();
    }

    override protected function onExit() : void {
        super.onExit();

        m_pEventMediator = null;
        m_pStateBoard = null;
        m_listAnimationFrozenNotifies = null;
        m_listFrameFrozenNotifies = null;

        m_fResumeAnimationTimeLeft = m_fResumeFrameTimeLeft = NaN;

        if ( m_listAnimationCallbacks )
            m_listAnimationCallbacks.splice( 0, m_listAnimationCallbacks.length );
        m_listAnimationCallbacks = null;
    }

    final public function get animationController() : CAnimationController {
        return modelDisplay.animationController;
    }

    final public function set animationController( value : CAnimationController ) : void {
        modelDisplay.animationController = value;
    }

    override protected function setDisplay( pDisplay : CCharacter ) : void {
        super.setDisplay( pDisplay );

        if ( pDisplay ) {
            pDisplay.animationController.addStateChangedCallback( onAnimationStageChanged );
        }
    }

    protected function onAnimationStageChanged( from : String, to : String ) : void {
        if ( from && from != to ) {
            if ( m_pEventMediator ) {
                m_pEventMediator.dispatchEvent( new CCharacterEvent( CCharacterEvent.ANIMATION_TIME_END, owner ) );
            }
        }
    }

    /**
     * @param delta 其它组件如碰撞框同步需要跟动作时间同步
     */
    private function syncWithAnimationUpdate( delta : Number ) : void {
        if ( m_listAnimationCallbacks ) {
            for each ( var pfnCallback : Function in m_listAnimationCallbacks ) {
                if ( null != pfnCallback ) {
                    // pfnCallback( delta * modelDisplay.animationSpeed );
                    pfnCallback( delta );
                }
            }
        }
    }

    //--------------------------------------------------------------------------
    // IAnimation implementations.
    //--------------------------------------------------------------------------

    [Inline]
    final public function pushState( stateValue : int ) : int {
        m_iStateValue |= stateValue;
        return m_iStateValue;
    }

    [Inline]
    final public function popState( stateValue : int ) : int {
        m_iStateValue &= ~stateValue;
        return m_iStateValue;
    }

    [Inline]
    final public function get stateValue() : int {
        return m_iStateValue;
    }

    [Inline]
    final public function isStateActive( stateValue : int ) : Boolean {
        return (this.stateValue & stateValue) != 0;
    }

    private function setFrozenBan() : void {
        var pMonsterProprety : CMonsterProperty = owner.getComponentByClass( CMonsterProperty, true ) as CMonsterProperty;
        if ( pMonsterProprety ) {
            var bBanFrozen : int = pMonsterProprety.bStopHitFrozen;
            this.bAnimationBanFrozen = bBanFrozen == 1;
        }
    }

    /**
     public function createCharacterCollision( type : int , box : CAABBox3 , ownerData : Object ) : CCollisionBound
     {
         return this.modelDisplay.createCollisionBox( type , box, ownerData ) as CCollisionBound;
     }

     public  function destroyCharacterCollision( bound : ICollision ) : void
     {
         this.modelDisplay.destroyCollisionBox( bound );
     }
     */

    public function addSkillAnimationState( sStateName : String, sAnimationName : String ) : void {
        if ( !this.modelDisplay.animationController.findState( sStateName ) ) {
            this.modelDisplay.animationController.addState( new CAnimationState( sStateName, sAnimationName, false, true, true ) );
            this.modelDisplay.animationController.addStateRelationship( sStateName, CAnimationStateConstants.IDLE, timeLeft2Idle );
        }
    }

    public function removeSkillAnimationState( sStateName : String ) : void {
        if ( this.modelDisplay.animationController.findState( sStateName ) ) {
            // TODO: remove the target animation state.
        }
    }

    [Inline]
    final public function get currentAnimationLoop() : Boolean {
        return this.animationController.currentState.animationLoop;
    }

    [Inline]
    final public function set currentAnimationLoop( value : Boolean ) : void {
        this.animationController.currentState.animationLoop = value;
    }

    [Inline]
    public function continuePlayAnimation( animationState : String ) : void {
        if ( this.modelDisplay ) {
            this.modelDisplay.addNextPlayAnimation( animationState, false, false, false, 0, false, 0.0, null, false );
        }
    }

    [Inline]
    final public function get currentAnimationState() : String {
        return this.animationController.currentState.stateName;
    }

    [Inline]
    final public function playAnimation( animationState : String, bForceReplay : Boolean = false, bForceLoop : Boolean = false, iTrackIdx : int = 0 ) : void {
        if ( animationState == CAnimationStateConstants.RUN ) {
            pushState( CAnimationStateValue.RUN );
        } else {
            popState( CAnimationStateValue.RUN );
        }

        this.modelDisplay.playState( animationState, bForceLoop, bForceReplay, iTrackIdx );
        m_lastFrameModeTimeLeft = NaN;
    }

    [Inline]
    final public function getAnimationTime( stateName : String ) : Number {
        return this.modelDisplay.getStateDuration( stateName );
    }

    final public function get isFrameFrozen() : Boolean {
        return !isNaN( m_fResumeFrameTimeLeft );
    }

    final public function frozenAnimation( fTimeDuration : Number, pfnCallback : Function = null, ... args ) : void {
        this.m_fResumeAnimationTimeLeft = fTimeDuration;
        if ( !isNaN( m_fResumeAnimationTimeLeft ) ) {
            this.pauseAnimation();
            if ( null != pfnCallback ) {
                if ( !m_listAnimationFrozenNotifies ) {
                    m_listAnimationFrozenNotifies = new Dictionary();
                }

                m_listAnimationFrozenNotifies[ pfnCallback ] = args || [];
            }
        }
    }

    final public function popFrozenAnimationCallback( pfnCallback : Function ) : void {
        if ( null != pfnCallback ) {
            if ( m_listAnimationFrozenNotifies )
                delete m_listAnimationFrozenNotifies[ pfnCallback ];
        }
    }

    final public function clearFrozenAnimationCallbacks() : void {
        if ( m_listAnimationFrozenNotifies ) {
            m_listAnimationFrozenNotifies = null;
        }
    }

    final public function pauseFrame() : void {
        this.pauseAnimation();
//        this.physicsEnabled = false;
        this.modelDisplay.updateSpeed = 0.0;

        var pMov : CMovement = getComponent( CMovement ) as CMovement;
        if ( pMov ) {
            pMov.enabled = false;
        }
    }

    final public function resumeFrame() : void {
        this.resumeAnimation();
//        this.physicsEnabled = true;
        this.modelDisplay.updateSpeed = 1.0;

        var pMov : CMovement = getComponent( CMovement ) as CMovement;
        if ( pMov ) {
            pMov.enabled = true;
        }

        if ( m_pEventMediator )
            m_pEventMediator.dispatchEvent( new Event( CCharacterEvent.ANIMATION_RESUME ) );
        Foundation.Log.logTraceMsg( "Resume Frame ..." );
    }

    final public function frozenFrame( fTimeDuration : Number, pfnCallback : Function = null, ... args ) : void {
        if ( bAnimationBanFrozen ) fTimeDuration = 0.0;
        this.m_fResumeFrameTimeLeft = fTimeDuration;
        if ( !isNaN( m_fResumeFrameTimeLeft ) ) {
            this.pauseFrame();
            if ( null != pfnCallback ) {
                if ( !m_listFrameFrozenNotifies ) {
                    m_listFrameFrozenNotifies = new Dictionary();
                }

                m_listFrameFrozenNotifies[ pfnCallback ] = args || [];
            }
        }
    }

    //为了标识定帧在Fighthandler帧尾执行 frozenFrame
    final public function setFrozenDirty( fTimeDuration : Number , pfnCallback : Function = null , ... args ) : void {
        m_bCacheFrozenDirty = true;
        m_cacheFrozenTime = fTimeDuration;
    }

    final public function popFrozenFrameCallback( pfnCallback : Function ) : void {
        if ( null != pfnCallback ) {
            if ( m_listFrameFrozenNotifies )
                delete m_listFrameFrozenNotifies[ pfnCallback ];
        }
    }

    final public function clearFrozenFrameCallbacks() : void {
        if ( m_listFrameFrozenNotifies ) {
            m_listFrameFrozenNotifies = null;
        }
    }

    final public function get animationOffset() : CVector2 {
        if ( modelDisplay )
            return modelDisplay.getAnimationOffset();
        return null;
    }

    final public function getAnimationOffset( bClear : Boolean = false ) : CVector2 {
        if ( modelDisplay )
            return modelDisplay.getAnimationOffset( -1, bClear );
        return null;
    }

    final public function get lastFrameMode() : Boolean {
        return m_bLastFrameMode;
    }

    final public function set lastFrameMode( value : Boolean ) : void {
        m_bLastFrameMode = value;
    }

    final public function get boSkillPlaying() : Boolean {
        return m_boSkillPlaying;
    }

    final public function set boSkillPlaying( value : Boolean ) : void {
        m_boSkillPlaying = value;
    }

    final public function get inTurnning() : Boolean{
       return m_inTurnning;
    }
    final public function set inTurnning( value : Boolean ) : void{
        m_inTurnning = value;
    }

    final public function get animationSpeed() : Number {
        return modelDisplay.animationSpeed;
    }

    final public function get noPhysicsAndAnimationOffset() : Boolean {
        return m_bNoPhysicsAndAnimationOffset;
    }

    final public function set noPhysicsAndAnimationOffset( value : Boolean ) : void {
        m_bNoPhysicsAndAnimationOffset = value;
    }

    final public function get animationOffsetEnabled() : Boolean {
        return m_bAnimationOffsetEnabled;
    }

    final public function set animationOffsetEnabled( value : Boolean ) : void {
        if ( m_bAnimationOffsetEnabled == value )
            return;
        Foundation.Log.logTraceMsg( "Animation Offset Enabled = " + value );
        m_bAnimationOffsetEnabled = value;
        m_bAnimationOffsetEnabledDirty = true;
    }

    public function get physicsEnabled() : Boolean {
        if ( modelDisplay )
            return modelDisplay.enablePhysics;
        return false;
    }

    public function set physicsEnabled( physicsEnabled : Boolean ) : void {
        if ( modelDisplay ) {
            if ( modelDisplay.enablePhysics == physicsEnabled )
                return;
            modelDisplay.enablePhysics = physicsEnabled;
            this.animationOffsetEnabled = !physicsEnabled;
        }
    }

    [Inline]
    final public function pauseAnimation() : void {
        if ( isNaN( this.m_fResumeAnimationSpeed ) )
            this.m_fResumeAnimationSpeed = this.modelDisplay.animationSpeed;
        this.modelDisplay.animationSpeed = 0.0;
    }

    [Inline]
    final public function resumeAnimation() : void {
        this.modelDisplay.animationSpeed = m_fResumeAnimationSpeed || DEFAULT_ANIMATION_SPEED;
        m_fResumeAnimationSpeed = NaN;
    }

    [Inline]
    final public function speedUpAnimation( speed : Number ) : void {
        if ( isNaN( this.m_fResumeAnimationSpeed ) )
            this.m_fResumeAnimationSpeed = this.modelDisplay.animationSpeed;
        this.modelDisplay.animationSpeed = speed;
    }

    [Inline]
    final public function emit( fHeight : Number ) : void {
        this.modelDisplay.jump( fHeight );
    }

    [Inline]
    public function emitWithExtraVelocity( fHeight : Number, velocity : CVector3 = null ) : void {
        // this.modelDisplay.jumpWithExtraVelocity( fHeight, velocity );
    }

    [Inline]
    public function emitWithExtraVelocityXYZ( fHeight : Number, x : Number, y : Number, z : Number, clear : Boolean = false ) : void {
        if ( clear ) {
            this.modelDisplay.velocity.y = 0;
        }
        this.modelDisplay.jumpWithExtraVelocityXYZ( fHeight, x, y, z );
    }

    public function emitWithVelocityXYZ( veloX : Number, veloY : Number, veloZ : Number ) : void {
        this.modelDisplay.velocity.zero();
        this.modelDisplay.jumpWithExtraVelocityXYZ( 0, veloX, veloY, veloZ );
    }

    public function addAnimationTickCallback( pfnCallback : Function ) : void {
        if ( null == pfnCallback )
            return;
        if ( null == m_listAnimationCallbacks ) {
            m_listAnimationCallbacks = new <Function>[];
        }

        var idx : int = m_listAnimationCallbacks.indexOf( pfnCallback );
        if ( idx == -1 ) {
            m_listAnimationCallbacks.push( pfnCallback );
        }
    }

    public function removeAnimationTickCallback( pfnCallback : Function ) : void {
        if ( null == pfnCallback || !m_listAnimationCallbacks )
            return;

        var idx : int = m_listAnimationCallbacks.indexOf( pfnCallback );
        if ( idx > -1 )
            m_listAnimationCallbacks.splice( idx, 1 );
    }

    public function clearAnimationTickCallbacks() : void {
        if ( !m_listAnimationCallbacks )
            return;

        m_listAnimationCallbacks.splice( 0, m_listAnimationCallbacks.length );
    }


    public function stateWithAnimation( statName : String, AnimationName : String ) : void {
        this.animationController.findState( statName ).animationName = AnimationName;
    }

    override public function update( delta : Number ) : void {
        super.update( delta );

        if ( !isReady )
            return;

        var model : CCharacter = this.modelDisplay;

//        if ( !this.noPhysicsAndAnimationOffset ) {
//            this.physicsEnabled = !m_bAnimationOffsetEnabled;
//        }

        model.animationController.theCurrentState.applyAnimationOffsetToPosition = m_bAnimationOffsetEnabled;

        m_bAnimationOffsetEnabledDirty = false;

       /* var bFrozen : Boolean = false;
        var pfnCallback : Function;
        var func : Function;
        var args : Array;

        if ( !isNaN( m_fResumeAnimationTimeLeft ) ) {
            m_fResumeAnimationTimeLeft -= delta;
            if ( m_fResumeAnimationTimeLeft <= .0 ) {
                m_fResumeAnimationTimeLeft = NaN;
                this.resumeAnimation();

                if ( m_listAnimationFrozenNotifies ) {
                    for ( pfnCallback in m_listAnimationFrozenNotifies ) {
                        if ( null == pfnCallback )
                            continue;
                        func = pfnCallback;
                        args = m_listAnimationFrozenNotifies[ pfnCallback ];
                        delete m_listAnimationFrozenNotifies[ pfnCallback ];
                        func.apply( null, args );
                    }
                }
            }
            bFrozen = true;
        }

        if ( !isNaN( m_fResumeFrameTimeLeft ) ) {
            m_fResumeFrameTimeLeft -= delta;
            if ( m_fResumeFrameTimeLeft <= .0 ) {
                m_fResumeFrameTimeLeft = NaN;
                this.resumeFrame();

                if ( m_listFrameFrozenNotifies ) {
                    for ( pfnCallback in m_listFrameFrozenNotifies ) {
                        if ( null == pfnCallback )
                            continue;
                        func = pfnCallback;
                        args = m_listFrameFrozenNotifies[ pfnCallback ];
                        delete m_listFrameFrozenNotifies[ pfnCallback ];
                        func.apply( null, args );
                    }
                }
            }
            bFrozen = true;
        }

        if ( !bFrozen ) {
            syncWithAnimationUpdate( delta );
        }*/

        m_pStateBoard.setValue( CCharacterStateBoard.ON_GROUND, !model.inAir );
        CONFIG::debug{
            if ( tempAir != model.inAir ) {
                tempAir = model.inAir;
                Foundation.Log.logTraceMsg( " Animation last air " + model.inAir );
            }
        }

    }

    public function tickFrozenTime( delta : Number ) : void{

        if ( !this.noPhysicsAndAnimationOffset ) {
            this.physicsEnabled = !m_bAnimationOffsetEnabled;
        }

        var bFrozen : Boolean = false;
        var pfnCallback : Function;
        var func : Function;
        var args : Array;

        if ( !isNaN( m_fResumeAnimationTimeLeft ) ) {
            m_fResumeAnimationTimeLeft -= delta;
            if ( m_fResumeAnimationTimeLeft <= .0 ) {
                m_fResumeAnimationTimeLeft = NaN;
                this.resumeAnimation();

                if ( m_listAnimationFrozenNotifies ) {
                    for ( pfnCallback in m_listAnimationFrozenNotifies ) {
                        if ( null == pfnCallback )
                            continue;
                        func = pfnCallback;
                        args = m_listAnimationFrozenNotifies[ pfnCallback ];
                        delete m_listAnimationFrozenNotifies[ pfnCallback ];
                        func.apply( null, args );
                    }
                }
            }
            bFrozen = true;
        }

        if ( !isNaN( m_fResumeFrameTimeLeft ) ) {
            m_fResumeFrameTimeLeft -= delta;
            if ( m_fResumeFrameTimeLeft <= .0 ) {
                m_fResumeFrameTimeLeft = NaN;
                this.resumeFrame();

                if ( m_listFrameFrozenNotifies ) {
                    for ( pfnCallback in m_listFrameFrozenNotifies ) {
                        if ( null == pfnCallback )
                            continue;
                        func = pfnCallback;
                        args = m_listFrameFrozenNotifies[ pfnCallback ];
                        delete m_listFrameFrozenNotifies[ pfnCallback ];
                        func.apply( null, args );
                    }
                }
            }
            bFrozen = true;
        }

        if ( !bFrozen ) {
            syncWithAnimationUpdate( delta );
        }

        if( m_bCacheFrozenDirty && !isNaN(m_cacheFrozenTime)){
            frozenFrame( m_cacheFrozenTime );
            m_bCacheFrozenDirty = false;
            m_cacheFrozenTime = NaN;
        }

        if( !isNaN( m_lastFrameModeTimeLeft ) && ! isFrameFrozen )
                m_lastFrameModeTimeLeft -= delta;
    }

    private var tempAir : Boolean;

    protected function timeLeft2Idle() : Boolean {
        if ( ( (modelDisplay.currentAnimationClipTimeLeft <= 0.0 || (!isNaN(m_lastFrameModeTimeLeft) &&  m_lastFrameModeTimeLeft <= 0.0))
                && !m_bLastFrameMode
                && ( !modelDisplay.currentAnimationClip || !modelDisplay.currentAnimationClip.m_bLoop))
                && !m_boSkillPlaying && !m_inTurnning
        ) {
            pushState( CAnimationStateValue.IDLE );
            m_lastFrameModeTimeLeft = NaN;
            return true;
        }

        return false;
    }

    protected function timeLeft2Dead() : Boolean {
        if ( modelDisplay.currentAnimationClipTimeLeft <= 0.0 ) {
            if ( isStateActive( CAnimationStateValue.DEAD_SIGN ) ) {
                pushState( CAnimationStateValue.DEAD );
            }

            if ( isStateActive( CAnimationStateValue.DEAD_SIGN ) )
                return true;
        }

        return false;
    }

    protected function run2Idle() : Boolean {
        if ( !isStateActive( CAnimationStateValue.RUN ) ) {
            pushState( CAnimationStateValue.IDLE );
            return true;
        }
        return false;
    }

    protected function born2Idle() : Boolean {
        return true;
    }

    protected function idle2Turn() : Boolean {
        if ( isStateActive( CAnimationStateValue.TURN ) ) {
            popState( CAnimationStateValue.IDLE );
            return true;
        }
        return false;
    }

    protected function turn2Run() : Boolean {
        return modelDisplay.currentAnimationClipTimeLeft <= 0.0;
    }

    protected function turn2Idle() : Boolean {
        if ( isStateActive( CAnimationStateValue.TURN ) ) {
            if ( modelDisplay.currentAnimationClipTimeLeft <= 0.0 ) {
                popState( CAnimationStateValue.TURN );
                pushState( CAnimationStateValue.IDLE );
                if ( m_pEventMediator )
                    m_pEventMediator.dispatchEvent( new Event( CCharacterEvent.ANIMATION_TIME_END ) );
                return true;
            }
        }
        return false;
    }

    protected function idle2Run() : Boolean {
        if ( isStateActive( CAnimationStateValue.RUN ) && !isDirectionDirty ) {
            popState( CAnimationStateValue.IDLE );
            popState( CAnimationStateValue.TURN );
            return true;
        }
        return false;
    }

    public function setCharacterGravityAcc( acc : Number ) : void {
        if( modelDisplay )
            modelDisplay.setGravityAcceleration( acc );
    }

    public function setDefaultCharacterGravityAcc( acc : Number ) : void {
        m_fDefaultGravityAcc = acc;
        setCharacterGravityAcc( acc );
    }

    public function resetCharacterGravityAcc() : void {
        if ( isNaN( m_fDefaultGravityAcc ) ) {
            if( modelDisplay )
                modelDisplay.resumeGravityAcceleration();
        }
        else
            setCharacterGravityAcc( m_fDefaultGravityAcc );
    }

    public function setEnableCollision( value : Boolean ) : void {
        modelDisplay.setEnableCollision( value );
    }

    final public function getConvertedBaseGravity( value : Number ) : Number {
        return -value * 100.0 * 2.0;
    }

    //--------------------------------------------------------------------------
    // ICollisable implementations.
    //--------------------------------------------------------------------------

    /**
     public function get currentCollisionData() : Vector.<CCharacterCollisionKey> {
        return modelDisplay.currentCollisionData;
    }

     public function get currentCollisionName() : String {
        if ( modelDisplay.currentAnimationClip )
            return modelDisplay.currentAnimationClip.m_sName;
        return null;
    }

     public function get currentCollisionTime() : Number {
        if ( modelDisplay.currentAnimationClip )
            return modelDisplay.currentAnimationClip.m_fTime;

        return 0.0;
    }*/

    public function get currentCollisionLoopDuration() : Number {
        return modelDisplay.currentCollisionDurationTime;
    }

    public function get collision() : CCollisionObject {
        return modelDisplay.collision;
    }

    public function set collisionOwnerData( value : Object ) : void {
        if ( collision )
            collision.ownerData = owner;
    }

    public function setCurrentAnimationTag( tabName : String, subSequenceTab : String ) : void {
        this.modelDisplay.setCurrentAnimationTag( tabName, subSequenceTab );
    }

    public function get currentAnimationTag() : String {
        return modelDisplay.currentAnimationTag;
    }

    public function get currentAnimationTagParam() : String {
        return modelDisplay.currentAnimationTagParam;
    }

    public function get stepHeight() : Number {
        return modelDisplay.stepHeight;
    }

    public function set stepHeight( value : Number ) : void {
        modelDisplay.stepHeight = value;
    }

    public function get bAnimationBanFrozen() : Boolean {
        return m_bAnimationBanFrozen;
    }

    public function set bAnimationBanFrozen( value : Boolean ) : void {
        this.m_bAnimationBanFrozen = value;
    }

    public function set lastFrameModeTimeLeft( value : Number ) : void{
        this.m_lastFrameModeTimeLeft = value;
    }

    override public function get boInView() : Boolean {
        return m_boInView;
    }

    override public function set boInView( isInView : Boolean ) : void {
        if ( m_boInView == isInView && !m_boFirstInView )
            return;
        m_boInView = isInView;

        if ( m_pEventMediator ) {
            if ( m_boInView ) {
                m_pEventMediator.dispatchEvent( new Event( CCharacterEvent.BE_IN_VIEW ) );
            } else
                m_pEventMediator.dispatchEvent( new Event( CCharacterEvent.OUT_OF_VIEW ) );
        }
        m_boFirstInView = false;
    }

    private var m_boFirstInView : Boolean;
    private var m_bCacheFrozenDirty : Boolean;
    private var m_cacheFrozenTime : Number;

}
}
