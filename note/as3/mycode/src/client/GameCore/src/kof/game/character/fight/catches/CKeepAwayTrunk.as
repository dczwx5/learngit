//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2018/4/18.
//----------------------------------------------------------------------
package kof.game.character.fight.catches {

import QFLib.Foundation;
import QFLib.Math.CAABBox3;
import QFLib.Math.CVector2;
import QFLib.Math.CVector3;

import flash.events.Event;

import flash.geom.Point;

import kof.game.character.CCharacterEvent;

import kof.game.character.CEventMediator;

import kof.game.character.CKOFTransform;

import kof.game.character.display.IDisplay;
import kof.game.character.fight.skill.CSkillDebugLog;

import kof.game.character.level.CLevelMediator;
import kof.game.character.state.CCharacterStateBoard;

import kof.game.core.CGameComponent;

public class CKeepAwayTrunk extends CGameComponent {
    public function CKeepAwayTrunk() {
        super( "Keep away trunk" )
    }

    override protected function onEnter() : void {
        super.onEnter();
        m_pLevelMediator = owner.getComponentByClass( CLevelMediator , true ) as CLevelMediator;
        m_pStateBoard = owner.getComponentByClass( CCharacterStateBoard , true ) as CCharacterStateBoard;
    }

    override protected function onExit() : void {
        super.onExit();
        m_keepAwayBox = null;
    }

    public function set keepAwayBox( box : CAABBox3 ) : void {
        if( box == null ) return;

        m_keepAwayBox = box;
        var backDistance : Number;
        var nDir : Point = m_pStateBoard.getValue( CCharacterStateBoard.DIRECTION ) as Point;
        if( m_pLevelMediator && nDir ) {
            backDistance = m_pLevelMediator.getXOffsetOfTrunkPerBox( m_keepAwayBox , nDir.x );
            if( !isNaN( backDistance ) && backDistance < 0 ){
                 _moveBackward( Math.abs(backDistance ) , nDir.x );
            }
        }
    }

    private function _moveBackward( distance : Number , dir : int ) : void {
         var targetDisplay : IDisplay = owner .getComponentByClass( IDisplay, true ) as IDisplay;

        if( targetDisplay == null ){
            Foundation.Log.logWarningMsg("The position value(x,y) should not be NaN ");
            return;
        }

        if ( targetDisplay && targetDisplay.modelDisplay ) {
            var pTransform : CKOFTransform = this.transform as CKOFTransform;
            if( pTransform ) {
                var position : CVector3 = pTransform.position;
                pTransform.moveTo( position.x - dir * distance, position.z, position.y , true , true );
                CSkillDebugLog.logMsg( "版边向后退 " + dir * distance );
            }
        }
        var pEventMediator : CEventMediator = owner.getComponentByClass( CEventMediator, true ) as CEventMediator;
        if ( pEventMediator ) {
            pEventMediator.dispatchEvent( new Event( CCharacterEvent.STOP_MOVE, false, false ) );
        }
    }

    private var m_keepAwayBox : CAABBox3;
    private var m_pLevelMediator : CLevelMediator;
    private var m_pStateBoard : CCharacterStateBoard;
}
}
