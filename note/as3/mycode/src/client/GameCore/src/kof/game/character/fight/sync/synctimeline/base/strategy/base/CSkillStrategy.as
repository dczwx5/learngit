//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/6/9.
//----------------------------------------------------------------------
package kof.game.character.fight.sync.synctimeline.base.strategy.base {


import kof.game.character.display.IDisplay;
import kof.game.character.fight.CCharacterNetworkInput;
import kof.game.character.fight.skill.CSimulateSkillCaster;
import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.fight.skill.CSkillDebugLog;
import kof.game.character.fight.skillcalc.CFightCalc;
import kof.game.character.fight.sync.CCharacterResponseQueue;
import kof.game.character.fight.sync.CCharacterSyncBoard;
import kof.game.character.fight.sync.CSkillQueueSeq;
import kof.message.Fight.SkillCastResponse;

public class CSkillStrategy extends CBaseStrategy {
    public function CSkillStrategy() {
    }

    override public function dispose() : void {
        super.dispose();
    }

    override public function takeAction() : void {
        super.takeAction();
    }

    override public function doResponseAction() : void {
        super.doResponseAction();
        _spellSkillForResponse();
    }

    override public function doRequestAction() : void {
        super.doRequestAction();
    }

    protected function _spellSkillForResponse() : void {
        var skillRespose : SkillCastResponse = action.actionData as SkillCastResponse;
        if ( skillRespose == null ) {
            CSkillDebugLog.logTraceMsg( "responser has no data" );
            return;
        }


        var boJumpLand : Boolean = isJumpLandSkill( skillRespose.skillID );
        if ( boJumpLand ) {
            _setInputDiretion( owner, skillRespose.dirX, skillRespose.dirY );
            return;
        }

        if ( !getBoSyncToHostMsg( skillRespose ) )
            return;

        var pDisplay : IDisplay = owner.getComponentByClass( IDisplay, true ) as IDisplay;
        var pFightCal : CFightCalc = owner.getComponentByClass( CFightCalc, true ) as CFightCalc;


        _setInputDiretion( owner, skillRespose.dirX, skillRespose.dirY );
        _setPropertyFromSyncData( owner, false, true, false, skillRespose.dynamicStates );
        _setStateBoardFromSyncData( owner, skillRespose.dynamicStates );

        if ( skillRespose.dynamicStates ) {
            if ( pFightCal ) {
                pFightCal.syncCDFromData( skillRespose.dynamicStates[ CCharacterSyncBoard.SKILL_CD_LIST ] );
            }
            var fHeight : Number = skillRespose.dynamicStates[ CCharacterSyncBoard.NHEIGHT_PLAYER ];
            if ( pDisplay ) {
                _setPosition( owner, skillRespose.posX, skillRespose.posY, false, fHeight );
            }
        }

        _resetAnimation( owner ,  skillRespose.dynamicStates );

        if ( !_canEnterAttack() )
            _resetStateMachine();

        var pSimulationSkill : CSimulateSkillCaster = owner.getComponentByClass( CSimulateSkillCaster, true ) as CSimulateSkillCaster;
        if ( pSimulationSkill ) {
            pSimulationSkill.castSkillIngoreAll( skillRespose.skillID );
        }
    }

    private function verifyFightSkillQueue( msg : SkillCastResponse ) : Boolean {
        var incomeSkillID : int = msg.skillID;
        var incomeQueueID : int = msg.queueID;

        var pNetInput : CCharacterNetworkInput = owner.getComponentByClass( CCharacterNetworkInput, true ) as CCharacterNetworkInput;
        if ( !pNetInput )
            return false;

        if ( incomeQueueID > pNetInput.skillQueueID ) {
            pNetInput.syncSkillQueueID( incomeQueueID );
            return true;
        }
        CSkillDebugLog.logTraceMsg( "skill response abandoned skill ID = " + incomeSkillID + "  queueID : " + incomeQueueID );
        return false;
    }

    private function getBoSyncToHostMsg( msg : SkillCastResponse ) : Boolean {
        return true;
        var netInputSkillID : int = msg.skillID;
        var netInputQueueID : int = msg.queueID;
        var boRet : Boolean;

        var pInputComp : CCharacterNetworkInput = owner.getComponentByClass( CCharacterNetworkInput, true ) as CCharacterNetworkInput;
        var netInputComp : CCharacterResponseQueue = owner.getComponentByClass( CCharacterResponseQueue, true ) as CCharacterResponseQueue;

        if ( pInputComp == null ) {
            boRet = false;
        } else {
            var localSkillQueue : CSkillQueueSeq = pInputComp.localSkillQueue;
            var netSkillQueue : CSkillQueueSeq = netInputComp.currentSkillQueue;

            if ( netInputQueueID > localSkillQueue.queueID ) {
                localSkillQueue.from( netSkillQueue );
                pInputComp.resetSkillHitQueueID();
                pInputComp.resetSkillCatchQueueID();
                boRet = true;
            }
        }

        netSkillQueue.setSkillQueue( netInputQueueID, netInputSkillID, timelineNode.nodeDataTime );
        return boRet;
    }


    final private function get pSkillCater() : CSkillCaster {
        return owner.getComponentByClass( CSkillCaster, true ) as CSkillCaster;
    }
}
}
