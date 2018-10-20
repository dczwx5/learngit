//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/5/29.
//----------------------------------------------------------------------
package kof.game.character.fight.sync.synctimeline.base.action {

public class EFighterActionType {
    public static const E_STATUS_ACTION : int = 4;
    public static const E_POSITION_ACTION : int = 5;

    public static const E_SKILL_ACTION: int = 1;
    public static const E_SKILL_END_ACTION : int = 2;
    public static const E_HIT_ACTION : int = 3;
    public static const E_DODGE_ACTION: int = 6;
    public static const E_JUMP_ACTION : int = 7;
    public static const E_CATCH_ACTION : int = 8;
    public static const E_HEAL_ACTION : int = 9;
    public static const E_ABSORB_MISSILE : int = 10;
    public static const E_ACTIVATE_MISSILE : int  = 11;
    public static const E_IGNORE_LIST : Array = null ;

    public static function CreateActionByTye( type : int ) : CBaseFighterKeyAction{
        var action : CBaseFighterKeyAction;
        switch( type ){
            case EFighterActionType.E_POSITION_ACTION:
                action = new CFighterPositionAction();
                break;
            case EFighterActionType.E_SKILL_ACTION:
                action = new CFighterSkillAction();
                break;
            case EFighterActionType.E_STATUS_ACTION:
                action = new CFighterStatusAction();
                break;
            case EFighterActionType.E_DODGE_ACTION:
                action= new CFighterDodgeAction();
                break;
            case EFighterActionType.E_SKILL_END_ACTION:
                action = new CFighterSkillEndAction();
                break;
            case EFighterActionType.E_HIT_ACTION:
                action = new CFighterHitAction();
                break;
            case EFighterActionType.E_CATCH_ACTION:
                action = new CFighterCatchAction();
                break;
            case EFighterActionType.E_JUMP_ACTION:
                action = new CFighterJumpAction();
                break;
            case EFighterActionType.E_HEAL_ACTION:
                action = new CFighterHealAction();
                break;
            default:
                action = new CBaseFighterKeyAction(type);
        }
       return action;
    }
}
}
