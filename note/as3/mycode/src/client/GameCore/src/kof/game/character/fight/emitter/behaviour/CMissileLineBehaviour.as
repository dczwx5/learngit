//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/8/19.
//----------------------------------------------------------------------
package kof.game.character.fight.emitter.behaviour {

import flash.geom.Point;
import flash.geom.Point;

import kof.game.character.fight.emitter.*;


import kof.game.character.display.IDisplay;

import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.fx.CFXMediator;
import kof.game.character.movement.CMovement;
import kof.game.character.property.CMissileProperty;
import kof.game.character.state.CCharacterStateBoard;

import kof.game.core.CGameObject;
import kof.table.Aero;
import kof.table.Aero.EAeroType;

/**
 * the implement of missile just moving straight;
 */
public class CMissileLineBehaviour extends CMissileBasicBehaviour {

    public function CMissileLineBehaviour( owner : CGameObject ) {

        super( owner );
        this.m_type = EAeroType.E_STRAIGHT;
    }

    override public function dispose() : void {
        missileObject = null;
        m_pEmitterInfo = null;
    }

    override public function initiaBehaviour( ... arg ) : void {
        if ( null == arg || arg[ 0 ] == null )
            return;
        missileObject = owner;

        var missileProp : CMissileProperty = owner.getComponentByClass( CMissileProperty, true ) as CMissileProperty;
        m_pEmitterInfo = CSkillCaster.skillDB.getAeroByID( missileProp.missileId );

        var myMovement : CMovement = pMissileOwner.getComponentByClass( CMovement, true ) as CMovement;

        var pDisplayer : IDisplay = owner.getComponentByClass( IDisplay, true ) as IDisplay;
        var dirX : int = pDisplayer.direction;
        if ( emitterComp && emitterComp.comUtility ) {
            var dir : Point = new Point( dirX, 0 );
            emitterComp.comUtility.stateBoard.setValue( CCharacterStateBoard.DIRECTION, dir ); //new Point( dir.x, dir.y ) );
        }

        if ( pAnimation )
            pAnimation.modelDisplay.enablePhysics = false;

        myMovement.direction.x = dirX;
        myMovement.moveSpeed = emitterInfo.Speed == 0 ? 1 : emitterInfo.Speed;
        myMovement.movable = true;
    }

    override public function updateBehaviour( delta : Number ) : void {

    }

    final private function get emitterInfo() : Aero {
        return m_pEmitterInfo;
    }

    private function get pMissileOwner() : CGameObject {
        return emitterComp.owner;
    }

    final private function get emitterComp() : CEmitterComponent {
        return missileObject.getComponentByClass( CEmitterComponent, true ) as CEmitterComponent;
    }

    private var missileObject : CGameObject;
    private var m_pEmitterInfo : Aero;

}
}
