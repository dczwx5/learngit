//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/7/28.
//----------------------------------------------------------------------
package kof.game.character.fight.sync.synctimeline.base.strategy.base {

import flash.geom.Point;

import kof.game.character.CFacadeMediator;

import kof.game.character.display.IDisplay;
import kof.game.character.fight.catches.CSkillCatcher;
import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.fight.skill.CSkillDebugLog;
import kof.game.character.fight.skillcalc.CFightCalc;
import kof.game.character.fight.sync.CCharacterSyncBoard;
import kof.game.character.fight.sync.synctimeline.base.CCharacterFightData;
import kof.game.character.fight.sync.synctimeline.base.action.CBaseFighterKeyAction;
import kof.game.character.fight.sync.synctimeline.base.action.CFighterCatchAction;
import kof.game.character.fight.sync.synctimeline.base.action.CFighterHitAction;
import kof.game.character.fight.sync.synctimeline.base.action.EFighterActionType;
import kof.game.character.level.CLevelMediator;
import kof.game.character.scene.CSceneMediator;
import kof.game.character.state.CCharacterActionStateConstants;
import kof.game.character.state.CCharacterInput;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.character.state.CCharacterStateMachine;
import kof.game.core.CGameObject;
import kof.message.Fight.DodgeResponse;
import kof.table.ActionSeq.EActionSeqType;
import kof.table.Hit;

public class CDodgeStrategy extends CBaseStrategy {
    public function CDodgeStrategy() {
        super();
    }

    override public function doResponseAction() : void {
        super.doResponseAction();
        var bValid : Boolean;
        bValid = _checkDodgeValid();
        if ( bValid ) {
            _dodge();
        } else {
            CSkillDebugLog.logTraceMsg( "判定网络包闪避失败" )
        }
    }

    private function _checkDodgeValid() : Boolean {
        var bValid : Boolean = true;

        return true;
        //以下为服务端验证
        var lastInvalidAction : CBaseFighterKeyAction;
        if ( prevGlobalNode == null )
            return true;
        var fighterDataList : Vector.<CCharacterFightData> = prevGlobalNode.nodeFightData.getFighterDatas();
        for each( var fighterData : CCharacterFightData in fighterDataList ) {
            var keyAction : CBaseFighterKeyAction;
            for each ( keyAction in fighterData.fighterActions ) {
                if ( keyAction != null ) {
                    if ( keyAction.type == EFighterActionType.E_CATCH_ACTION ) {
                        lastInvalidAction = _checkBeingCatch( keyAction );
                    }
                }
            }
        }
        if ( lastInvalidAction ) {
            var pStateBoard : CCharacterStateBoard = owner.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
            var bInCatch : Boolean = pStateBoard.getValue( CCharacterStateBoard.IN_CATCH );
            bValid = false;
        }

        return bValid;
    }

    private function _checkBeingCatch( action : CBaseFighterKeyAction ) : CBaseFighterKeyAction {
        var catchAction : CFighterCatchAction;
        catchAction = action as CFighterCatchAction;
        if ( catchAction.findTargetInCatching( owner ) ) {
            return action;
        }
        return null;
    }

    private function _dodge() : void {
        var pInput : CCharacterInput = owner.getComponentByClass( CCharacterInput, true ) as CCharacterInput;
        var pSyncBoard : CCharacterSyncBoard = owner.getComponentByClass( CCharacterSyncBoard, true ) as CCharacterSyncBoard;
        var pDisplay : IDisplay = owner.getComponentByClass( IDisplay, true ) as IDisplay;
        var boRelocate : Boolean = true;

        var fHeight : Number = pSyncBoard.getValue( CCharacterSyncBoard.NHEIGHT_PLAYER );
        if ( boRelocate && pDisplay ) {
//            _setPosition( owner, dodgeResponse.posX, dodgeResponse.posY, false, fHeight );
        }
        if ( !pInput ) {
            CSkillDebugLog.logTraceMsg( "Character[" + dodgeResponse.ID + ":" + dodgeResponse.type + "] doesn't contains a CCharacterInput, but it's message supported." );
        } else {
            //数据回来默认不移动了
            pInput.wheel = new Point( dodgeResponse.dirX , dodgeResponse.dirY );
        }

        _setPropertyFromSyncData( owner, false, true, false, dodgeResponse.dynamicStates );
        _setStateBoardFromSyncData( owner, dodgeResponse.dynamicStates );

        var pFightCal : CFightCalc = owner.getComponentByClass( CFightCalc, true ) as CFightCalc;
        if ( pFightCal ) {
            pFightCal.syncCDFromData( dodgeResponse.dynamicStates[ CCharacterSyncBoard.SKILL_CD_LIST ] );
        }

        if( !_canEnterDodge() ) {
            _removeFromCatcher();
            _resetStateMachine();
        }
        var pFacadeMediator : CFacadeMediator = owner.getComponentByClass( CFacadeMediator, true ) as CFacadeMediator;
        if ( pFacadeMediator ) {
            pFacadeMediator.dodgeSudden( null, true );
        }

    }

    private function _removeFromCatcher() : void {
        var pStateBoard : CCharacterStateBoard = owner.getComponentByClass( CCharacterStateBoard , true ) as CCharacterStateBoard;
        if(pStateBoard && pStateBoard.getValue(CCharacterStateBoard.IN_CATCH)) {
            var sceneFacade : CSceneMediator = owner.getComponentByClass( CSceneMediator, true ) as CSceneMediator;
            var heros : Vector.<CGameObject> = sceneFacade.findHeroAsList();
            for each( var hero : CGameObject in heros ) {
                var pHeroCatcher : CSkillCatcher = hero.getComponentByClass( CSkillCatcher, true ) as CSkillCatcher;
                if ( pHeroCatcher ) {
                    pHeroCatcher.remove( owner );
                }
            }
        }
    }

    protected function _canEnterDodge() : Boolean{
        var characterFSM : CCharacterStateMachine = owner.getComponentByClass( CCharacterStateMachine, true ) as CCharacterStateMachine;
        if ( characterFSM && characterFSM.actionFSM ) {
            return characterFSM.actionFSM.can( CCharacterActionStateConstants.EVENT_DODGE_BEGAN );
        }
        return false;
    }

    protected function get dodgeResponse() : DodgeResponse {
        return action.actionData as DodgeResponse;
    }
}
}
