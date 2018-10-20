//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2018/5/12.
//----------------------------------------------------------------------
package kof.game.character.fight.skill {

import QFLib.Foundation.CMap;

import kof.game.character.CCharacterDataDescriptor;

import kof.game.character.fight.event.CFightTriggleEvent;

import kof.game.character.fight.skillchain.CCharacterFightTriggle;

import kof.game.character.state.CCharacterStateBoard;

import kof.game.core.CGameComponent;
import kof.game.core.CGameObject;
import kof.game.core.CGameObject;
import kof.game.scene.CSceneEvent;
import kof.game.scene.ISceneFacade;

public class CSuperControlComponent extends CGameComponent {
    private var m_theSuperControlList : Vector.<CGameObject>;
    private var m_theSuperMissileControlList : CMap;
    private var m_pSceneFacade : ISceneFacade;

    public function CSuperControlComponent( sceneFacade : ISceneFacade ) {
        super();
        m_pSceneFacade = sceneFacade;
    }

    override protected function onExit() : void {
        releaseSuperControl();
        m_theSuperControlList = null;
        if ( m_theSuperMissileControlList ) {
            for ( var key : int in m_theSuperMissileControlList ) {
                _releaseMissileControl( key );
            }
            m_theSuperMissileControlList.clear();
        }
        m_theSuperControlList = null;

        if ( m_pSceneFacade )
            m_pSceneFacade.removeEventListener( CSceneEvent.MISSILE_REMOVE, _onSceneMissileRemove )
    }

    override protected function onEnter() : void {
        m_theSuperControlList = new <CGameObject>[];
        m_theSuperMissileControlList = new CMap();
        m_pSceneFacade.addEventListener( CSceneEvent.MISSILE_REMOVE, _onSceneMissileRemove )
    }

    public function addObjToSuperControl( obj : CGameObject ) : void {
        if ( obj == null || !obj.isRunning || m_theSuperControlList.indexOf( obj ) >= 0 )
            return;

        _executeSuperControl( obj );
        m_theSuperControlList.push( obj );
    }

    public function missileHitToSuperControl( obj : CGameObject, missileSeq : int ) : void {

        if( m_theSuperMissileControlList.find( missileSeq ) )
                return;

        m_theSuperMissileControlList.add( missileSeq, obj );
        var theStateBoard : CCharacterStateBoard = pStateBoard;
        if ( theStateBoard ) {
            theStateBoard.setValue( CCharacterStateBoard.BAN_DODGE, true, missileSeq );
        }
    }

    private function _onSceneMissileRemove( e : CSceneEvent ) : void {
        var seq : int = e.value as int;
        _releaseMissileControl( seq );
    }

    private function _onReleaseMissileControl( e : CFightTriggleEvent ) : void {
        var seq : int = e.parmList[ 0 ];
        _releaseMissileControl( seq );
    }

    private function _releaseMissileControl( seq : int ) : void {
        var theStateBoard : CCharacterStateBoard = pStateBoard;
        if ( theStateBoard ) {
            theStateBoard.resetValue( CCharacterStateBoard.BAN_DODGE, seq );
        }

        delete m_theSuperMissileControlList[ seq ];
    }

    private function releaseSuperControl() : void {
        if ( m_theSuperControlList ) {
            for each( var obj : CGameObject in m_theSuperControlList )
                resetSuperControl( obj );
        }
        m_theSuperControlList.splice( 0, m_theSuperControlList.length );
    }

    private function _onReleaseSuperControl( e : CFightTriggleEvent ) : void {
        var skillId : int = e.parmList[ 0 ];

//        if( CSkillUtil.boSuperSkill( skillId )) {
        releaseSuperControl();
//        }
    }

    private function _listenTargetSkillEnd( obj : CGameObject ) : void {
        var skillFightTrigger : CCharacterFightTriggle = obj.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
        if ( skillFightTrigger ) {
            skillFightTrigger.addEventListener( CFightTriggleEvent.SPELL_SKILL_END, _onReleaseSuperControl );
            skillFightTrigger.addEventListener( CFightTriggleEvent.SKILL_BE_INTERRUPTED, _onReleaseSuperControl );
        }
    }

    private function _removeListenTargetSkillEnd( obj : CGameObject ) : void {
        var skillFightTrigger : CCharacterFightTriggle = obj.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
        if ( skillFightTrigger ) {
            skillFightTrigger.removeEventListener( CFightTriggleEvent.SPELL_SKILL_END, _onReleaseSuperControl );
            skillFightTrigger.removeEventListener( CFightTriggleEvent.SKILL_BE_INTERRUPTED, _onReleaseSuperControl );
        }
    }

    private function _executeSuperControl( obj : CGameObject ) : void {
        _setControlState( obj, CCharacterStateBoard.BAN_DODGE, true );
        _listenTargetSkillEnd( obj );
    }

    private function resetSuperControl( obj : CGameObject ) : void {
        resetControlState( obj, CCharacterStateBoard.BAN_DODGE )
        _removeListenTargetSkillEnd( obj );
    }

    private function _setControlState( obj : CGameObject, stateKey : int, stateValue : Boolean ) : void {
        var theStateBoard : CCharacterStateBoard = pStateBoard;
        if ( theStateBoard ) {
            theStateBoard.setValue( stateKey, stateValue, CCharacterDataDescriptor.getID( obj.data ) );
        }
    }

    private function resetControlState( obj : CGameObject, stateKey : int ) : void {
        var theStateBoard : CCharacterStateBoard = pStateBoard;
        if ( theStateBoard ) {
            theStateBoard.resetValue( stateKey, CCharacterDataDescriptor.getID( obj.data ) );
        }
    }

    private final function get pFightTrigger() : CCharacterFightTriggle {
        return owner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
    }

    private final function get pStateBoard() : CCharacterStateBoard {
        return owner.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
    }
}
}
