//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/7/14.
//----------------------------------------------------------------------
package kof.game.character.fight.skilleffect {

import flash.events.Event;

import kof.game.character.CCharacterDataDescriptor;

import kof.game.character.CCharacterEvent;
import kof.game.character.CEventMediator;
import kof.game.character.fight.skill.CComponentUtility;
import kof.game.character.fight.skill.CSkillDebugLog;
import kof.game.character.fight.skillchain.*;

import QFLib.Foundation;
import QFLib.Interface.IUpdatable;

import kof.game.character.CFacadeMediator;
import kof.game.character.CSkillList;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.fight.skill.CSkillCasterContext;
import kof.game.character.movement.CMovement;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.core.CGameObject;

import kof.table.Chain;
import kof.table.Chain.ECastType;
import kof.table.Chain.ETriggleEventType;

public class CSkillChainEffect extends CAbstractSkillEffect implements IUpdatable {

    public function CSkillChainEffect( id : int, startFrame : Number, hitEvent : String, et : int, des : String = "" ) {
        super( id, startFrame, hitEvent, et, des );
    }

    override public function initData( ... args ) : void {
        CONFIG::debug {
            Foundation.Log.logTraceMsg( "**@CSkillChainEffect： 初始化技能链 其中ID= " + effectID );
        }
        if ( null == args || args.length <= 0 ) return;

        super.initData( null );
        var skillContext : CComponentUtility = args[ 0 ] as CComponentUtility;

        m_skillCtx = skillContext;
        m_pFightTriggle = m_skillCtx.fightTriggle;

        var chainData : Chain = CSkillCaster.skillDB.getSkillChainByID( effectID, CCharacterDataDescriptor.getSimpleDes( owner.data ) );
        if ( chainData == null ) {
            CONFIG::debug {
                Foundation.Log.logErrorMsg( "**@CSkillChainEffect： 在Chain表找不到对应ID的技能链效果 其中ID= " + effectID );
            }
            return;
        }

        m_skillChain = chainData;
        m_effectDuarationFrame = m_skillChain.Duration;
        m_eventName = extractEventByType( chainData.TriggleEventType );
        m_effectendTime = this.effectDuarationTime + this.effectStartTime;

    }

    override public function dispose() : void {
        super.dispose();
        if ( m_triggleMechanism != null ) {
            m_triggleMechanism.dispose();
        }

        if ( null != eventName && eventName.length != 0 ) {
            fightTriggle.removeEventListener( eventName, onTriggle );
        }

        _removeStatusEventListener();

        m_triggleMechanism = null;
    }

    private function _removeStatusEventListener() : void {
        var eventMedia : CEventMediator = owner.getComponentByClass( CEventMediator, true ) as CEventMediator;
        if ( eventMedia ) {
            eventMedia.removeEventListener( CCharacterEvent.STATE_VALUE_UPDATE, statEventChange );
        }
    }

    override public function update( delta : Number ) : void {
        super.update( delta );
        //这里主要是手动模式的需要update判断是否在时间内触发
        m_elapsTime += delta;

        if ( eventName == CFightTriggleEvent.T_BLOCK_SCENE && m_boInChain ) {
            if ( pMovement.boBlockInScene ) {
                onTriggle( null );
                m_eventName = "";
            }
        }

        if ( effectStartTime <= m_elapsTime && !m_boInChain ) {
            onEnterChain();
        }
    }

    override public function doStart() : void {
        super.doStart();
    }

    override public function lastUpdate( delta : Number ) : void {
        super.lastUpdate( delta );
    }

    override public function doEnd() : void {
        super.doEnd();
        onExitChain();
    }

    protected function _boRunInTime() : Boolean {
        return effectStartTime <= m_elapsTime;
    }

    protected function _boRunOutOfTime() : Boolean {
        return m_effectendTime <= m_elapsTime;
    }

    //fixme useless 一般技能开始要重置
    override public function resetEffect() : void {
        m_elapsTime = 0;
        m_boInChain = false;
        //重置进入模式的参数
        if ( triggleMechanism )
            triggleMechanism.reset();
    }

    private function onEnterChain() : Boolean {
        CONFIG::debug{
            Foundation.Log.logTraceMsg( "@CSkillChainEffect ,效果生效时间点到，进入技能链逻辑检测 time = " + m_elapsTime + "effectID : " + m_skillChain.ID )
        }
        ;
        m_boInChain = true;
        fightTriggle.removeEventListener( eventName, onTriggle );

        if ( null != eventName && eventName.length != 0 ) {

            if ( eventName == CFightTriggleEvent.T_LAND_EVENT ) {
                var eventMedia : CEventMediator = owner.getComponentByClass( CEventMediator, true ) as CEventMediator;
                eventMedia.addEventListener( CCharacterEvent.STATE_VALUE_UPDATE, statEventChange, false );
            }

            fightTriggle.addEventListener( eventName, onTriggle );
        }
        else
            onTriggle( null );

        return m_boInChain;
    }

    private function onExitChain() : void {
        m_boInChain = false;
        fightTriggle.removeEventListener( eventName, onTriggle );
        if ( triggleMechanism )
            triggleMechanism.exitMechanism();

        this.m_pContainer.removeSkillEffect( this );
        CONFIG::debug{
            Foundation.Log.logTraceMsg( "@CSkillChainEffect ,效果生效时间结束，退出技能链等待逻辑: time = " + m_elapsTime + chainData.ID + "TO" + chainData.SkillID )
        }
        ;
    }

    private function extractEventByType( type : int ) : String {
        CONFIG::debug{
            Foundation.Log.logTraceMsg( "@CSkillChainEffect ,当前技能链事件触发类型为  TriggleEventType = " + type )
        }
        ;
        switch ( type ) {
            case ETriggleEventType.T_BEING_HITTED:
                return CFightTriggleEvent.BEING_HITTED;
            case ETriggleEventType.T_BEING_INHURT:
                return CFightTriggleEvent.BEING_HURT;
            case ETriggleEventType.T_BEING_KNOCKUP:
                return CFightTriggleEvent.BEING_KNOCKUP;
            case ETriggleEventType.T_GET_BULLET:
                return CFightTriggleEvent.GET_BULLET;
            case ETriggleEventType.T_HIT_TARGET:
                return CFightTriggleEvent.HIT_TARGET;
            case ETriggleEventType.T_HURT_TARGET:
                return CFightTriggleEvent.HURT_TARGET;
            case ETriggleEventType.T_LAND:
                return CFightTriggleEvent.T_LAND_EVENT;
            case ETriggleEventType.T_SCENEBLOCK:
                return CFightTriggleEvent.T_BLOCK_SCENE;
            case ETriggleEventType.T_CATCHWORK:
                return CFightTriggleEvent.CATCH_EFFECT_SUCCEED;
            default :
            {
                CSkillDebugLog.logTraceMsg( "@CSkillChainEffect , ！警告！没有配置对应的事件触发类型，该技能将自动触发技能链了 :其中 TriggleEventType =" + type );
                if ( effectStartTime <= m_elapsTime && !m_boInChain ) {
                    onTriggle( null );
                }
            }
                return "";
        }
    }

    /**
     * generate the trigger event when the character's state changes
     * @param e
     */
    private function statEventChange( e : Event) : void {

        if( !owner || !owner.isRunning) return;
        var pStateBoard : CCharacterStateBoard = owner.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;

        if ( eventName == CFightTriggleEvent.T_LAND_EVENT ) {
            if ( pStateBoard.isDirty( CCharacterStateBoard.ON_GROUND ) &&
                    pStateBoard.getValue( CCharacterStateBoard.ON_GROUND ) ) {
                fightTriggle.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.T_LAND_EVENT, null, null ) );

                if( owner ) {
                    var eventMedia : CEventMediator = owner.getComponentByClass( CEventMediator, true ) as CEventMediator;
                    eventMedia.removeEventListener( CCharacterEvent.STATE_VALUE_UPDATE, statEventChange );
                }
            }
        }
    }

    //事件触发接下来走
    private function onTriggle( e : CFightTriggleEvent ) : void {
        var triggleMode : int = chainData.CastType;
        if ( null == m_triggleMechanism )
            m_triggleMechanism = getTriggleMechanism( triggleMode );

        var boTrigger : Boolean = true;
        if ( e )
            boTrigger = _processEvaluateEventParam( e.parmList );
        if ( boTrigger ) {
            processEvaluate();
            CONFIG::debug{
                Foundation.Log.logTraceMsg( "@CSkillChainEffect ,达成技能链触发事件条件  TriggleEventType =" + eventName )
            }
            ;
            if ( eventName )
                fightTriggle.removeEventListener( eventName, onTriggle );
        }
        else {
            CONFIG::debug{
                Foundation.Log.logTraceMsg( "@CSkillChainEffect ,达成击打事件条件,但是不能跳转，不同属同个技能击打不能跳转 " )
            }
            ;
        }
    }

    private function _processEvaluateEventParam( eventParam : Array ) : Boolean {
        if ( eventParam == null || eventParam.length == 0 ) return true;

        switch ( eventName ) {
            case CFightTriggleEvent.HIT_TARGET:
                if ( CCharacterDataDescriptor.isMissile( owner.data ) )
                    return true;

                var skillID : int = eventParam[ 0 ];
                return pSkillCaster.isInSameMainSkill( skillID );
            default:
                return true;
        }
    }

    /**
     *
     * @param modeType triggle mode type auto or manul
     * @return
     */
    private function getTriggleMechanism( modeType : int ) : ITriggleSkillMechanism {
        var tm : ITriggleSkillMechanism;
        if ( modeType == ECastType.BY_AUTO ) {
            tm = new CAutoTriggleMechanism( this, owner );
        }
        else if ( modeType == ECastType.BY_PRIMARY_KEY ) {
            tm = new CManualTriggleMechanism( this, owner );
        } else if ( modeType == ECastType.BY_STOP ) {
            tm = new CMotionTriggerMechanism( this, owner );
        } else if ( modeType == ECastType.BY_AERO ) {
            tm = new CAeroTriggerMechanism( this, owner );
        } else if( modeType == ECastType.BY_PRIMARY_KEY_UP ){
            tm = new CManualKeyUpTriggleMechanism( this , owner );
        }
        else {
            CONFIG::debug{
                Foundation.Log.logWarningMsg( "@CSkillChainEffect ,技能触发模式不正确或者未定义  modeType =" + modeType )
            }
            ;
        }

        return tm;
    }

    //处理自动或者手动模式下的通过条件
    private function processEvaluate() : void {
        if ( null != triggleMechanism ) {
            triggleMechanism.onTransfer();
        }
    }

    final public function get TransType() : int {
        return chainData.TransType;
    }

    //当前技能链是否处于手动状态下 ，如果没有技能触发模式的话，默认就是自动的
    final public function get isManulType() : Boolean {
        if ( triggleMechanism ) {
            if ( triggleMechanism.modeType == ECastType.BY_PRIMARY_KEY )
                return true;
        }

        return false
    }

    final private function get triggleMechanism() : ITriggleSkillMechanism {
        return m_triggleMechanism;
    }

    final public function get fightTriggle() : CCharacterFightTriggle {
        return m_pFightTriggle;
    }

    final public function get chainData() : Chain {
        return m_skillChain;
    }

    final private function get eventName() : String {
        return m_eventName;
    }

    final private function get skillCtx() : CComponentUtility {
        return m_skillCtx;
    }

    final public function get skillList() : CSkillList {
        return skillCtx.skillList;
    }

    final public function get skillCaster() : CSkillCaster {
        return skillCtx.skillCaster;
    }

    /*final public function get owner() : CGameObject
     {
     return skillCtx.owner;
     }*/

    final public function get facadeMediator() : CFacadeMediator {
        return skillCtx.facadeMediator;
    }

    final private function get pMovement() : CMovement {
        return owner.getComponentByClass( CMovement, true ) as CMovement;
    }

    private var m_skillChain : Chain;
    private var m_skillCtx : CComponentUtility;//CSkillCasterContext;
    private var m_eventName : String;
    private var m_pFightTriggle : CCharacterFightTriggle;
    private var m_triggleMechanism : ITriggleSkillMechanism;

    private var m_elapsTime : Number = 0.0;
    private var m_effectendTime : Number;

    private var m_boInChain : Boolean;


}
}
