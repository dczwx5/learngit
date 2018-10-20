//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.scripts {

import QFLib.Foundation;
import QFLib.Foundation.CTimeDog;

import flash.events.Event;

import kof.framework.events.CEventPriority;
import kof.framework.fsm.CStateEvent;
import kof.game.character.CCharacterEvent;
import kof.game.character.CEventMediator;
import kof.game.character.animation.IAnimation;
import kof.game.character.fx.CFXMediator;
import kof.game.character.property.CMonsterProperty;
import kof.game.character.property.interfaces.ICharacterProperty;
import kof.game.character.scene.CSceneMediator;
import kof.game.character.state.CCharacterActionStateConstants;
import kof.game.character.state.CCharacterStateMachine;
import kof.table.Monster.EMonsterDieCameraWay;
import kof.table.Monster.EMonsterDispearType;
import kof.util.CAssertUtils;

/**
 * 怪物死亡移除
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CMonsterRemoval extends CCharacterDie {

    /** 序列计算移除时间（需等待死亡动作的最后一帧才开始计算移除时间） */
    static public const TYPE_REMOVE_SEQ : int = 0;
    /** 并行计算移除时间（不需要理会死亡动作的播放时间） */
    static public const TYPE_REMOVE_PAL : int = 1;

    static public const DEFAULT_TIMEOUT : Number = 5.0;
    static public const DEFAULT_REMOVE_TIME : Number = 3.0;
    static public const DEFAULT_REMOVE_TYPE : int = TYPE_REMOVE_SEQ;

    /** 超时，如果timeout < 死亡动作 + 移除时长，会以timeout为准 */
    private var m_fTimeout : Number = DEFAULT_TIMEOUT;
    private var m_fRemoveTime : Number = DEFAULT_REMOVE_TIME;
    private var m_fRemoveType : int = DEFAULT_REMOVE_TYPE;
    private var m_pRemoveDog : CTimeDog;
    private var m_pTimeoutDog : CTimeDog;
    private var m_bPlayFade : Boolean;

    /** 移除怪物的回调控制逻辑委托 */
    private var m_pFnRemoveHandler : Function;

    public function CMonsterRemoval( pfnRemoveHandler : Function ) {
        super();

        m_pFnRemoveHandler = pfnRemoveHandler;
    }

    override public function dispose() : void {
        super.dispose();

        if ( m_pRemoveDog )
            m_pRemoveDog.dispose();
        m_pRemoveDog = null;

        if ( m_pTimeoutDog )
            m_pTimeoutDog.dispose();
        m_pTimeoutDog = null;

        m_pFnRemoveHandler = null;
    }

    override protected virtual function onEnter() : void {
        super.onEnter();
    }

    override protected virtual function onDataUpdated() : void {
        super.onDataUpdated();
    }

    override protected virtual function onExit() : void {
        super.onExit();
    }

    final public function get removeTime() : Number {
        return m_fRemoveTime;
    }

    final public function set removeTime( value : Number ) : void {
        if ( m_fRemoveTime == value )
            return;
        m_fRemoveTime = value;
    }

    final public function get removeType() : Number {
        return m_fRemoveType;
    }

    final public function set removeType( value : Number ) : void {
        if ( m_fRemoveType == value )
            return;
        m_fRemoveType = value;
    }

    final public function get timeout() : Number {
        return m_fTimeout;
    }

    final public function set timeout( value : Number ) : void {
        if ( value == m_fTimeout )
            return;
        m_fTimeout = value;
    }

    final public function get pAnimation() : IAnimation{
        return owner.getComponentByClass( IAnimation , true ) as IAnimation;
    }

    override protected function onDie() : void {
        super.onDie();

        var disappear : Boolean = true;
        var bSlowDown : Boolean = false;
        var bBGFlash : Boolean = false;

        var pSceneMediator : CSceneMediator = getComponent( CSceneMediator ) as CSceneMediator;
        var pEventMediator : CEventMediator = getComponent( CEventMediator ) as CEventMediator;
        var pMonsterProperty : CMonsterProperty = getComponent( CMonsterProperty ) as CMonsterProperty;

        if ( pMonsterProperty ) {
            disappear = pMonsterProperty.disappearType != EMonsterDispearType.NONE;
            bSlowDown = ( -1 != pMonsterProperty.dieCameraEffect.indexOf( EMonsterDieCameraWay.SLOW_DOWN ) );
            bBGFlash = ( -1 != pMonsterProperty.dieCameraEffect.indexOf( EMonsterDieCameraWay.FLASH_BG_RW ) );
        }

        if ( disappear ) {
            // 按类型开始计时逻辑
            if ( TYPE_REMOVE_SEQ == removeType ) {
                m_bPlayFade  = false;
                // listen to the animation end.
                if ( pEventMediator ) {
                    pEventMediator.addEventListener( CCharacterEvent.ANIMATION_TIME_END, _onAnimationTimeEnd, false, CEventPriority.DEFAULT, true );
                } else {
                    Foundation.Log.logErrorMsg( "CEventMediator required by CMonsterRemoval, but it's missing." );
                }
                m_pTimeoutDog = new CTimeDog( _onTimeoutDogDone );
            } else if ( TYPE_REMOVE_PAL == removeType ) {
                m_pTimeoutDog = new CTimeDog( _onTimeoutDogDone );
                m_pRemoveDog = new CTimeDog( _onRemoveDogDone );

            } else {
                CAssertUtils.assertTrue( false, "Unknown remove type." );
            }

            if ( m_pTimeoutDog )
                m_pTimeoutDog.start( this.timeout );

            if ( m_pRemoveDog )
                m_pRemoveDog.start( this.removeTime );

        }

        if ( bSlowDown ) {
            if ( pSceneMediator ) {
                pSceneMediator.slowMotionWithDuration( 1.0, 0.38 );
            }
        }

        if ( bBGFlash ) {
            if ( pSceneMediator ) {
                // 红白闪
                pSceneMediator.backgroundFlashInTurns( 1.0, 0.1, 0xFF0000, 0xFFFFFF );
            }
        }

        var pFSM : CCharacterStateMachine = getComponent( CCharacterStateMachine ) as CCharacterStateMachine;
        if ( !pFSM || pFSM.actionFSM.current == CCharacterActionStateConstants.DEAD ) {
            playDieFx();
        } else if ( pFSM && pFSM.actionFSM.current != CCharacterActionStateConstants.DEAD ) {
            pFSM.actionFSM.addEventListener( CStateEvent.ENTER, _onStateEnter, false, CEventPriority.DEFAULT, true );
        }
    }

    private function _onStateEnter( event : CStateEvent ) : void {
        if ( event.to == CCharacterActionStateConstants.DEAD ) {
            event.currentTarget.removeEventListener( event.type, _onStateEnter );

            playDieFx();
        }
    }

    protected function playDieFx() : void {
        // 死亡嘿嘿的特效
        var pFXMediator : CFXMediator = this.getComponent( CFXMediator ) as CFXMediator;
        if ( pFXMediator ) {
            if( !m_bPlayFade )
                pFXMediator.playDieFx();
            else{
                pFXMediator.playDieFadeFX();
            }
        }
    }

    private function _onAnimationTimeEnd( event : Event ) : void {
        m_pRemoveDog = new CTimeDog( _onRemoveDogDone );
        m_pRemoveDog.start( this.removeTime );
    }

    private function _onRemoveDogDone() : void {
        // time-end callback.
        Foundation.Log.logTraceMsg( "On MonsterRemoval completed." );

        this._removeGameObject();
    }

    private function _onTimeoutDogDone() : void {
        // timeout callback
        Foundation.Log.logTraceMsg( "On MonsterRemoval timeout." );

        this._removeGameObject();
    }

    private function _removeGameObject() : void {
        if ( null != this.m_pFnRemoveHandler ) {
            var ID : Number = NaN;

            var prop : ICharacterProperty = this.getComponent( ICharacterProperty ) as ICharacterProperty;
            if ( prop ) {
                ID = prop.ID;
            }

            CAssertUtils.assertFalse( isNaN( ID ), "CMonsterRemoval removing a monster ID by NaN." );

            this.m_pFnRemoveHandler( ID );
        }
    }

    final override public function update( delta : Number ) : void {
        super.update( delta );

        var pFSM : CCharacterStateMachine = getComponent( CCharacterStateMachine ) as CCharacterStateMachine;
        if ( !pFSM || pFSM && pFSM.actionFSM.current == CCharacterActionStateConstants.DEAD ) {
            if ( m_pTimeoutDog ) {
//                if( m_pTimeoutDog.running)
//                        _updateOpaque( delta );
                m_pTimeoutDog.update( delta );
            }

            if ( m_pRemoveDog ) {
//                if( m_pRemoveDog.running )
//                    _updateOpaque( delta );
                m_pRemoveDog.update( delta );

            }

        }
    }

    private function _updateOpaque( delta : Number ) : void{
        var oldOpaque : Number = pAnimation.modelDisplay.opaque;
        oldOpaque -= 1/10 * delta;
        if( pAnimation && pAnimation.modelDisplay){
            pAnimation.modelDisplay.opaque = oldOpaque < 0 ? 0 : oldOpaque;
        }
    }

}
}
