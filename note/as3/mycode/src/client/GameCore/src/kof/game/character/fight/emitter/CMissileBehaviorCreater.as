//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/8/19.
//----------------------------------------------------------------------
package kof.game.character.fight.emitter {

import kof.game.character.fight.emitter.behaviour.CMissileBasicBehaviour;
import kof.game.character.fight.emitter.behaviour.CMissileLineBehaviour;
import kof.game.character.fight.emitter.behaviour.CMissilePhysicBehaviour;
import kof.game.character.fight.emitter.disabletrigger.CMissileCollisionHit;
import kof.game.character.fight.emitter.disabletrigger.CMissileHit;
import kof.game.character.fight.emitter.disabletrigger.CMissileSkillEndHit;
import kof.game.character.fight.emitter.disabletrigger.CMissileOutdateHit;
import kof.game.character.fight.emitter.effecttrigger.CMissileBaseEffect;
import kof.game.character.fight.emitter.effecttrigger.CMissileColliseEffect;
import kof.game.character.fight.emitter.effecttrigger.CMissileReachTargetEffect;
import kof.game.character.fight.emitter.effecttrigger.CMissileTimerEffect;
import kof.game.character.fight.skill.CSkillDebugLog;
import kof.game.core.CGameObject;
import kof.table.Aero.EAeroDisableType;
import kof.table.Aero.EAeroTriggrertype;
import kof.table.Aero.EAeroType;

/**
 * the galaxy interface to create the missile's property class relative
 */
public class CMissileBehaviorCreater {
    public function CMissileBehaviorCreater() {
    }

    public static function getMissileBehaviorByType( type : int , owner : CGameObject) : CMissileBasicBehaviour
    {
        var behavior : CMissileBasicBehaviour;
        switch ( type )
        {
            case EAeroType.E_STRAIGHT:
                behavior = new CMissileLineBehaviour(owner);
                break;
            case EAeroType.E_PHYSICAL:
                behavior = new CMissilePhysicBehaviour(owner);
                break;
            default:
                behavior = new CMissileBasicBehaviour(owner);
        }

        return behavior;
    }

    public static function getMissileHitByType( type : int , owner : CGameObject ) : CMissileHit
    {
        var missileHit : CMissileHit;
        switch ( type )
        {
            case EAeroDisableType.E_TIMEOUT:
                missileHit = new CMissileOutdateHit( owner );
                break;
            case EAeroDisableType.E_MISSTARGET:
                missileHit = new CMissileCollisionHit(owner);
                break;
            case EAeroDisableType.E_SKILLEND:
                missileHit = new CMissileSkillEndHit(owner);
                break;
            case EAeroDisableType.E_EFFECT:
            case EAeroDisableType.E_DISAPPEAR:
                missileHit = new CMissileHit( owner );
                break;
            default:
                CSkillDebugLog.logTraceMsg( " UNDEFINE Type of missile EAeroDisableType for Type : " + type );
        }

        return missileHit;
    }

    public static function getMissileEffetyType( type : int , owner : CGameObject ) : CMissileBaseEffect
    {
        var missileEffect : CMissileBaseEffect;
        switch ( type )
        {
            case EAeroTriggrertype.E_TIMEGAS:
                missileEffect = new CMissileTimerEffect(owner);
                break;
            case EAeroTriggrertype.E_COLLISE:
                missileEffect = new CMissileColliseEffect(owner);
                break;
            case EAeroTriggrertype.E_REACHTARGET:
                missileEffect = new CMissileReachTargetEffect(owner);
                break;
            case EAeroTriggrertype.E_FlY:
                missileEffect = new CMissileBaseEffect( owner );
                break;
            default:
                CSkillDebugLog.logTraceMsg( " UNDEFINE Type of missile EAeroTriggrertype for Type : " + type );
        }

        return missileEffect;
    }
}
}
