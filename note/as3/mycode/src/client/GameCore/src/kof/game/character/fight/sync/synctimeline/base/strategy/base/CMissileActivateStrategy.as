//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/11/23.
//----------------------------------------------------------------------
package kof.game.character.fight.sync.synctimeline.base.strategy.base {

import QFLib.Math.CVector3;

import kof.game.character.CFacadeMediator;
import kof.game.character.CKOFTransform;
import kof.game.character.fight.emitter.CMissileIdentifersRepository;
import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.scene.CSceneMediator;
import kof.game.core.CGameObject;
import kof.message.Fight.FightMissileAbsorbResponse;
import kof.message.Fight.FightMissileActivateResponse;
import kof.table.Emitter;

public class CMissileActivateStrategy extends CBaseStrategy {
    public function CMissileActivateStrategy() {
    }

    override public function doResponseAction() : void {
        var pSceneMediator : CSceneMediator = owner.getComponentByClass( CSceneMediator, true ) as CSceneMediator;
        var existMissile : CGameObject;
        var missileSeq : Number;
        missileSeq = activateResponse.missileId;
        if ( pSceneMediator ) {
            existMissile = pSceneMediator.findMissile( missileSeq );
            if ( !existMissile ) {
                var posX : Number;
                var posY : Number;
                var posZ : Number;
                var pFacadeMediator : CFacadeMediator = owner.getComponentByClass( CFacadeMediator, true ) as CFacadeMediator;
                var pIdsRespo : CMissileIdentifersRepository = owner.getComponentByClass( CMissileIdentifersRepository, true ) as CMissileIdentifersRepository;
                var hasNotShotted : Boolean;
                var emitterId : int = activateResponse.dynamicStates[ "emitterID" ];
                if ( pIdsRespo ) {
                    hasNotShotted = pIdsRespo.hasSpecifyIDByEmitter( emitterId, missileSeq )
                }

                posX = activateResponse.dynamicStates[ "posX" ];
                posY = activateResponse.dynamicStates[ "posY" ];
                posZ = activateResponse.dynamicStates[ "posZ" ];

                var emitterInfo : Emitter = CSkillCaster.skillDB.getEmmiterByID( emitterId );
                if ( hasNotShotted &&  emitterInfo && pFacadeMediator )
                    pFacadeMediator._ShotMissile( emitterId , missileSeq, new CVector3( posX, posY, posZ ) );
            }
        }

    }

    final private function get activateResponse() : FightMissileActivateResponse {
        return action.actionData as FightMissileActivateResponse;
    }
}
}
