//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Maniac on 2017/4/18.
 */
package kof.game.character.dynamicBlock {

import QFLib.Foundation;
import QFLib.Framework.CScene;
import QFLib.Math.CAABBox3;

import flash.events.Event;

import kof.framework.fsm.CStateEvent;

import kof.game.character.CCharacterEvent;
import kof.game.character.CEventMediator;
import kof.game.character.animation.CAnimationStateConstants;
import kof.game.character.animation.CCharacterDisplay;

import kof.game.character.animation.IAnimation;

import kof.game.character.collision.CCollisionComponent;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.character.fx.CFXMediator;
import kof.game.character.property.CMonsterProperty;
import kof.game.character.state.CCharacterActionStateConstants;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.character.state.CCharacterStateMachine;
import kof.game.core.CSubscribeBehaviour;
import kof.game.scene.ISceneFacade;

/***
 * 场景可破坏物件（状态切换，动态阻挡）
 */
public class CDynamicBlockComponent extends CSubscribeBehaviour  implements IDynamicBlock {
    public function CDynamicBlockComponent( sceneFacade : ISceneFacade ) {
        super("dynamicBlock");
        m_pSceneFacade = sceneFacade;
    }

    override public function dispose() : void {
        super.dispose();

        m_aabbBox3 = null;
        m_EventMerditor = null;
    }

    override protected virtual function onEnter() : void {
        super.onEnter();

        m_EventMerditor = getComponent( CEventMediator ) as CEventMediator;
        if( m_EventMerditor ){
            m_EventMerditor.addEventListener( CCharacterEvent.COLLISION_READY , _onCharacterReady);
        }

        m_StateMachine = getComponent( CCharacterStateMachine ) as CCharacterStateMachine;

    }

    override protected function onDataUpdated() : void {
        super.onDataUpdated();

        var mProperty:CMonsterProperty = getComponent( CMonsterProperty ) as CMonsterProperty;
        if(mProperty.style == 1){
            var pStateBoard : CCharacterStateBoard = getComponent( CCharacterStateBoard ) as CCharacterStateBoard;
            if( pStateBoard ) {
                CCharacterStateBoard.setDefaultValue( pStateBoard, CCharacterStateBoard.CAN_BE_CATCH, false );
                pStateBoard.setValue( CCharacterStateBoard.CAN_BE_CATCH, false );//不能被抓取
                pStateBoard.setValue( CCharacterStateBoard.DIRECTION_PERMIT , false );//不能转向
                pStateBoard.setValue( CCharacterStateBoard.DIRECTION_DISPLAY_PERMIT, false );
                pStateBoard.setValue( CCharacterStateBoard.CAN_BE_DO_MOTION, false );
            }
            var pFxMediator : CFXMediator = getComponent( CFXMediator ) as CFXMediator;
            if( pFxMediator ) {
                pFxMediator.setCombineEffectLock( true );
            }

        }
    }

    override protected virtual function onExit() : void {
        super.onExit();

        if( m_EventMerditor ){
            m_EventMerditor.removeEventListener( CCharacterEvent.COLLISION_READY , _onCharacterReady);
        }

        if(m_StateMachine){
            m_StateMachine.actionFSM.removeEventListener( CStateEvent.ENTER, _onActionStateEnter );
        }

        _onCharacterRemove(null);
    }

    public function stateChanged( animationState : String = "Idle_1", hurtState : String = "Hurt_1" ) : void {
        var iAnimation:IAnimation = getComponent( IAnimation ) as IAnimation;
        iAnimation.addSkillAnimationState( animationState.toUpperCase() , animationState );
        iAnimation.stateWithAnimation(CAnimationStateConstants.IDLE, animationState );
        iAnimation.stateWithAnimation(CAnimationStateConstants.RUN, animationState );
        iAnimation.stateWithAnimation(CAnimationStateConstants.TURN, animationState );

        iAnimation.stateWithAnimation(CAnimationStateConstants.HURT_MILD, hurtState );
        iAnimation.stateWithAnimation(CAnimationStateConstants.HURT_SEVERE, hurtState );
        iAnimation.stateWithAnimation(CAnimationStateConstants.HURT_LYING, hurtState );

        iAnimation.stateWithAnimation(CAnimationStateConstants.AERO_DEFAULT, hurtState );
        iAnimation.stateWithAnimation(CAnimationStateConstants.AERO_FALL, hurtState );
        iAnimation.stateWithAnimation(CAnimationStateConstants.AERO_LAND, hurtState );
        iAnimation.stateWithAnimation(CAnimationStateConstants.LYING, hurtState );
        iAnimation.stateWithAnimation(CAnimationStateConstants.FAINT, hurtState );
        iAnimation.stateWithAnimation(CAnimationStateConstants.GETUP, hurtState );
//        iAnimation.stateWithAnimation(CAnimationStateConstants.DEAD, hurtState );

        iAnimation.playAnimation( animationState, false, false );

//        trace("可破环物件切换状态============>:",animationState,hurtState);
    }

    private function _onCharacterReady( event:CCharacterEvent ):void {
        m_bDetectStarted = true;
    }

    private function _onCharacterRemove( event:Event ):void {
        this.removeDynamicBlock();
    }

    public function addDynamicBlock() : void {
        var collision:CCollisionComponent = getComponent( CCollisionComponent ) as CCollisionComponent;
        var mProperty:CMonsterProperty = getComponent( CMonsterProperty ) as CMonsterProperty;

        if( collision == null )return;
        //style=1 可破坏物件
        if(mProperty.style == 1){

            if(m_StateMachine){
                m_StateMachine.actionFSM.addEventListener( CStateEvent.ENTER, _onActionStateEnter, false, 0, true );
            }

            m_aabbBox3 = collision.getBlockAABB();
            if( m_aabbBox3 ){
                var scene:CScene =  m_pSceneFacade.scenegraph.scene;
                scene.terrainData.addDynamic3DBox(m_aabbBox3);//添加场景物件阻挡~
                m_bDetectStarted = false;
                stateChanged("Idle_1","Hurt_1");
            }else{
                Foundation.Log.logTraceMsg( "aabbBox3 is null" );
            }
        }
    }

    public function removeDynamicBlock() : void {
        if( m_aabbBox3 ){
            var scene:CScene =  m_pSceneFacade.scenegraph.scene;
            scene.terrainData.removeDynamic3DBox(m_aabbBox3);//移除场景物件阻挡
        }
    }

    override public function update( delta : Number ) : void {
        if ( !m_bDetectStarted )
                return;
        addDynamicBlock();
    }

    private function _onActionStateEnter( event : CStateEvent ):void{
        switch ( event.to ) {
            case CCharacterActionStateConstants.DEAD:
               this.removeDynamicBlock();
            default:
                break;
        }
    }

    private var m_pSceneFacade : ISceneFacade;
    private var m_aabbBox3 : CAABBox3;
    private var m_bDetectStarted : Boolean;
    private var m_EventMerditor:CEventMediator;
    private var m_StateMachine:CCharacterStateMachine;

}
}
