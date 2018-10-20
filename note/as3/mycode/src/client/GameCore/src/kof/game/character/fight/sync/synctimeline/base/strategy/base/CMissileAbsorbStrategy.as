//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/11/21.
//----------------------------------------------------------------------
package kof.game.character.fight.sync.synctimeline.base.strategy.base {

import kof.game.character.CKOFTransform;
import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.scene.CSceneMediator;
import kof.game.core.CGameObject;
import kof.message.Fight.FightMissileAbsorbRequest;
import kof.message.Fight.FightMissileAbsorbResponse;

public class CMissileAbsorbStrategy extends CBaseStrategy {
    public function CMissileAbsorbStrategy() {

    }

    override public function doResponseAction() : void {
        var missile : CGameObject;
        var missilesList : Array = [];
        var missileInfos : Array;
        var absorbID : int;
        var pSkillCaster : CSkillCaster;
        absorbID = absorbResponse.dynamicStates[ "absorbID" ];
        missileInfos = absorbResponse.dynamicStates[ "target" ] as Array;
        var sceneMediator : CSceneMediator = owner.getComponentByClass( CSceneMediator, true ) as CSceneMediator;
        pSkillCaster = owner.getComponentByClass( CSkillCaster, true ) as CSkillCaster;
        if ( sceneMediator ) {
            for each( var missileInfo : Object in missileInfos ) {
                missile = sceneMediator.findMissile( missileInfo["missileSeq"] );
                var targetX : Number = missileInfo[ "posX" ];
                var targetY : Number = missileInfo[ "posY" ];
                if ( missile ) {
                    var missileTransform : CKOFTransform = missile.getComponentByClass( CKOFTransform, true ) as CKOFTransform;
                    if ( missileTransform ) {
                        missileTransform.moveTo( targetX, targetY, 0 );
                    }
                    missilesList.push( missile );
                }
            }

            pSkillCaster.castAbsorbMissiles( absorbID , missilesList );
        }
    }

    private function get absorbResponse() : FightMissileAbsorbResponse {
        return action.actionData as FightMissileAbsorbResponse;
    }
}
}
