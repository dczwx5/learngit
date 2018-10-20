//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/6/12.
//----------------------------------------------------------------------
package kof.game.character.fight.sync.synctimeline.base.strategy.base {

import QFLib.Foundation;
import QFLib.Interface.IDisposable;

import flash.geom.Point;

import flash.utils.clearTimeout;

import kof.game.character.animation.IAnimation;

import kof.game.character.display.IDisplay;
import kof.game.character.fight.skill.CSkillCaster;

import kof.game.character.fight.skill.CSkillDebugLog;
import kof.game.character.fight.sync.CCharacterSyncBoard;

import kof.game.character.fight.sync.synctimeline.base.CBaseFightTimeLineNode;
import kof.game.character.fight.sync.synctimeline.base.action.CBaseFighterKeyAction;
import kof.game.character.fight.sync.synctimeline.base.strategy.CSyncContext;
import kof.game.character.property.CCharacterProperty;
import kof.game.character.state.CCharacterActionStateConstants;
import kof.game.character.state.CCharacterInput;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.character.state.CCharacterStateMachine;
import kof.game.core.CGameObject;
import kof.message.CAbstractPackMessage;
import kof.table.Skill;

public class CBaseStrategy implements ISyncStrategy,IDisposable {
    public function CBaseStrategy() {
    }

    public function dispose() : void {
        m_pAction = null;
        m_pNode = null;
        m_pSyncCtx = null;
    }

    public function recycle() : void{
        m_pAction = null;
        m_pNode = null;
    }
    public function takeAction() : void {
        if ( action.actionCategory == CAbstractPackMessage.REQUEST ) {
            doRequestAction();
        } else if ( action.actionCategory == CAbstractPackMessage.RESPONSE ) {
            doResponseAction();
        }
    }

    /**
     * 执行发包处理
     */
    virtual public function doRequestAction() : void {

    }

    /**
     * 执行回包处理
     */
    virtual public function doResponseAction() : void {

    }

    protected function _setInputDiretion( target : CGameObject, dirX : Number, dirY : Number, syncForce : Boolean = true ) : void {
        var pInput : CCharacterInput = target.getComponentByClass( CCharacterInput, true ) as CCharacterInput;
        if ( !pInput ) {
            CSkillDebugLog.logTraceMsg( "Character doesn't contains a CCharacterInput, but it's message supported." );
        } else {
            pInput.wheel = new Point( dirX, dirY );
        }
    }

    protected function _setPosition( target : CGameObject, posX : Number, poxY : Number, boForceNotSync : Boolean = false, fHeight : Number = 0.0 ) : void {
        var targetDisplay : IDisplay = target.getComponentByClass( IDisplay, true ) as IDisplay;

        if( isNaN( posX ) || isNaN(poxY) ||isNaN(fHeight)){
            Foundation.Log.logWarningMsg("The position value(x,y) should not be NaN ");
            return;
        }
        if ( targetDisplay && targetDisplay.modelDisplay ) {
            targetDisplay.modelDisplay.setPositionToFrom2D( posX, poxY, fHeight );
            target.transform.x = targetDisplay.modelDisplay.position.x;
            target.transform.y = targetDisplay.modelDisplay.position.z;
            target.transform.z = targetDisplay.modelDisplay.position.y;
        }
    }

    protected function _setPropertyFromSyncData( target : CGameObject, bIgnoreAtkPwd : Boolean = false,
                                                 bIngnoreDefPwd : Boolean = false, bIgnoreRagePwd : Boolean = false ,dynamicStates: Object = null ) : void {
        var pCharacterProperty : CCharacterProperty = target.getComponentByClass( CCharacterProperty, true ) as CCharacterProperty;
        var pStateBoard : CCharacterStateBoard = target.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
        if ( pCharacterProperty && dynamicStates){
            if ( !bIgnoreRagePwd )
                pCharacterProperty.RagePower = dynamicStates[ CCharacterSyncBoard.RAGE_POWER ];
            if ( !bIgnoreAtkPwd )
                pCharacterProperty.AttackPower =dynamicStates[ CCharacterSyncBoard.ATTACK_POWER ];
            if ( !bIngnoreDefPwd )
                pCharacterProperty.DefensePower =dynamicStates[  CCharacterSyncBoard.DEFENSE_POWER ];

            var dir : int = dynamicStates[ CCharacterSyncBoard.SKILL_DIR ];
            pStateBoard.setValue( CCharacterStateBoard.DIRECTION, new Point( dir, 0 ) );
        }
    }

    protected function _setStateBoardFromSyncData( target : CGameObject , dynamicStates : Object = null) : void {
        var pStateBoard : CCharacterStateBoard = target.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;

        if ( dynamicStates && dynamicStates[ CCharacterSyncBoard.BO_ON_GROUND ] ) {
            var bOnGround : Boolean =dynamicStates[ CCharacterSyncBoard.BO_ON_GROUND ];
            pStateBoard.setValue( CCharacterStateBoard.ON_GROUND, bOnGround );
        }
    }

    protected function _setSyncCharacterStatsWithDynamic( target : CGameObject,  data : Object ) : void {
        var pSyncBoard : CCharacterSyncBoard = target.getComponentByClass( CCharacterSyncBoard, true ) as CCharacterSyncBoard;
        for ( var key : String in data ) {
            pSyncBoard.setValue( key, data[ key ] );
        }
    }

    protected function _resetStateMachine() : Boolean {
        var characterFSM : CCharacterStateMachine = owner.getComponentByClass( CCharacterStateMachine, true ) as CCharacterStateMachine;
        var ret : Boolean;
        if ( characterFSM ) {
            ret = characterFSM.actionFSM.on( CCharacterStateMachine.STARTUP );
        }
        return ret;
    }

    protected function _canEnterAttack() : Boolean{
        var characterFSM : CCharacterStateMachine = owner.getComponentByClass( CCharacterStateMachine, true ) as CCharacterStateMachine;
        if ( characterFSM && characterFSM.actionFSM ) {
            return characterFSM.actionFSM.can( CCharacterActionStateConstants.EVENT_ATTACK_BEGAN);
        }
        return false;
    }

    protected function _resetAnimation( target : CGameObject , stateData : Object ) : void{
        var pAnimation : IAnimation = target.getComponentByClass( IAnimation , true ) as IAnimation;
        if( pAnimation )
                pAnimation.resetCharacterGravityAcc();
        if( stateData.hasOwnProperty(CCharacterSyncBoard.CURRENT_ANIMATION_SPEED )) {
            var speedInfo : Object = stateData[CCharacterSyncBoard.CURRENT_ANIMATION_SPEED];
            pAnimation.emitWithVelocityXYZ( speedInfo.vx, speedInfo.vy, speedInfo.vz );
        }
    }

    public function attachToContext( ctx : CSyncContext ) : void {
        m_pSyncCtx = ctx;
    }

    public function set action( data : CBaseFighterKeyAction ) : void {
        this.m_pAction = data;
    }

    public function get action() : CBaseFighterKeyAction {
        return m_pAction;
    }

    public function set timelineNode( node : CBaseFightTimeLineNode ) : void {
        this.m_pNode = node;
    }

    public function get timelineNode() : CBaseFightTimeLineNode {
        return m_pNode;
    }

    protected function get prevSelfNode() : CBaseFightTimeLineNode {
        var temSelfPrevNode : CBaseFightTimeLineNode;
        temSelfPrevNode = timelineNode.prev;

        while ( temSelfPrevNode !== null ) {
            if ( temSelfPrevNode.hasOwner( owner ) )
                return temSelfPrevNode;
            temSelfPrevNode = temSelfPrevNode.prev;
        }

        return null;
    }

    protected function get nextGlobalNode() : CBaseFightTimeLineNode {
        var temGlobalNode : CBaseFightTimeLineNode;
        temGlobalNode = timelineNode.next;

        while ( temGlobalNode != null ) {
            if ( temGlobalNode.hasOtherOwner( owner ) )
                return temGlobalNode;
            temGlobalNode = temGlobalNode.next;
        }

        return null;
    }

    protected function get nextSelfNode() : CBaseFightTimeLineNode {
        var temSelfNextNode : CBaseFightTimeLineNode;
        temSelfNextNode = timelineNode.next;

        while ( temSelfNextNode != null ) {
            if ( temSelfNextNode.hasOwner( owner ) ) {
                return temSelfNextNode;
            }

            temSelfNextNode = temSelfNextNode.next;
        }

        return null;
    }

    protected function get prevGlobalNode() : CBaseFightTimeLineNode {
        var temGlobalPrevNode : CBaseFightTimeLineNode;
        temGlobalPrevNode = timelineNode.prev;
        while ( temGlobalPrevNode != null ) {
            if ( temGlobalPrevNode.hasOtherOwner( owner ) ) {
                return temGlobalPrevNode;
            }
            temGlobalPrevNode = temGlobalPrevNode.prev;
        }

        return null;
    }

    public function get owner() : CGameObject {
        return m_pSyncCtx.owner;
    }

    protected function isJumpLandSkill( skillId : int ) : Boolean{
        var skillData : Skill = CSkillCaster.skillDB.getSkillDataByID( skillId );
        if( skillData )
        {
            var skillFlag : String = skillData.ActionFlag;
            if( skillFlag == "NL_1" || skillFlag == "NJL_1")
                    return true;
        }
        return false;
    }


    protected var m_pAction : CBaseFighterKeyAction;
    protected var m_pNode : CBaseFightTimeLineNode;
    protected var m_pSyncCtx : CSyncContext;
}
}
