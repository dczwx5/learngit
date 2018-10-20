//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/5/2.
//----------------------------------------------------------------------
package kof.game.character.fight.emitter.behaviour {

import flash.geom.Point;

import kof.game.character.display.IDisplay;
import kof.game.character.fight.emitter.CMasterCompomnent;
import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.movement.CMovement;
import kof.game.character.property.CMissileProperty;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.core.CGameObject;
import kof.table.Aero;
import kof.table.Aero.EAeroType;

public class CMissilePhysicBehaviour extends CMissileBasicBehaviour{
    public function CMissilePhysicBehaviour( owner : CGameObject ) {
        super( owner );
        this.m_type = EAeroType.E_PHYSICAL;
    }

    override public function dispose() : void{
        missileObject = null;
        m_pEmitterInfo = null;
    }

    override public function initiaBehaviour( ... arg ) : void
    {
        missileObject = owner;
        var missileProp : CMissileProperty = owner.getComponentByClass( CMissileProperty , true ) as CMissileProperty;
        m_pEmitterInfo = CSkillCaster.skillDB.getAeroByID( missileProp.missileId );

        var myMovement :  CMovement = owner.getComponentByClass( CMovement , true ) as CMovement;

        var pDisplayer : IDisplay = owner.getComponentByClass( IDisplay, true ) as IDisplay;
        var dirX : int = pDisplayer.direction;
        if (  pEmitterComp && pEmitterComp.comUtility ) {
            var dir : Point = new Point( dirX, 0 );
            pEmitterComp.comUtility.stateBoard.setValue( CCharacterStateBoard.DIRECTION, new Point( dir.x , dir.y) );
        }

        myMovement.direction.x = dirX ;
        myMovement.moveSpeed = m_pEmitterInfo.Speed == 0 ? 1 :m_pEmitterInfo.Speed;
        myMovement.movable = true;
        myMovement.collisionEnabled = true;
    }

    private var missileObject : CGameObject;
    private var m_pEmitterInfo : Aero;
}
}
