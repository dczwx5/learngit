//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/5/9.
//----------------------------------------------------------------------
package kof.game.character.fight.skillchain {

import QFLib.Foundation;

import kof.game.character.animation.IAnimation;
import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.fight.skilleffect.CSkillChainEffect;
import kof.game.character.fight.skilleffect.CSkillMotionEffect;
import kof.game.character.movement.CMovement;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.core.CGameObject;
import kof.table.Skill.EEffectType;

public class CMotionTriggerMechanism extends CAutoTriggleMechanism {
    public function CMotionTriggerMechanism( skillChain : CSkillChainEffect, owner : CGameObject ) {
        super( skillChain, owner );
    }

    override protected function doTrigger() : void {
        _stopRunningMotionEffect();
    }

    private function _stopRunningMotionEffect() : void {
        var pskillCaster : CSkillCaster = m_pOwner.getComponentByClass( CSkillCaster , false ) as CSkillCaster;
        if( pskillCaster ) {
           var motionEffects : Array = pskillCaster.getEffectsByType(EEffectType.E_MOTION );
            for each( var motionEffect : CSkillMotionEffect in motionEffects ) {
                if( motionEffect.effectStartTime >= m_skillChain.effectStartTime &&
                        motionEffect.endTime <= m_skillChain.endTime ) {
                    pskillCaster.removeSkillEffect( motionEffect );
                }
                continue;
            }
        }

        var pMovement : CMovement = m_pOwner.getComponentByClass( CMovement, true ) as CMovement;
        if ( pMovement ) {
            pMovement.clearAllMotionActions();
            pMovement.direction.setTo( 0, 0 );
        }

        var pStateBoard : CCharacterStateBoard = m_pOwner.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
        if ( pStateBoard ) {
            pStateBoard.setValue( CCharacterStateBoard.MOVABLE, false );
            pStateBoard.setValue( CCharacterStateBoard.DIRECTION_PERMIT, false );
        }
        var pAnimation : IAnimation = m_pOwner.getComponentByClass( IAnimation, true ) as IAnimation;
        if ( pAnimation ) {
            pAnimation.modelDisplay.velocity.x = 0;
            pAnimation.modelDisplay.velocity.z = 0;
        }

        m_skillChain.skillCaster.removeRunningTypeEffect( EEffectType.E_MOTION );
        Foundation.Log.logTraceMsg( " @CAutoTriggleMechanism target skillID == 0 , auto trigger the stop event" );
    }
}
}
