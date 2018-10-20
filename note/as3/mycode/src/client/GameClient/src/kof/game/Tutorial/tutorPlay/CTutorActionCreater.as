//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/5.
 */
package kof.game.Tutorial.tutorPlay {

import kof.framework.CAppSystem;
import kof.game.Tutorial.tutorPlay.action.CTutorActionBase;
import kof.game.Tutorial.data.CTutorActionInfo;
import kof.game.Tutorial.enum.ETutorActionType;
import kof.game.Tutorial.tutorPlay.action.CTutorActionFinishWhenReturnMainCity;
import kof.game.Tutorial.tutorPlay.action.CTutorActionListArenaFightClick;
import kof.game.Tutorial.tutorPlay.action.CTutorActionListDailyTaskGetRewardClick;
import kof.game.Tutorial.tutorPlay.action.CTutorActionDoNoThing;
import kof.game.Tutorial.tutorPlay.action.CTutorActionListEmbattleRoleClick;
import kof.game.Tutorial.tutorPlay.action.CTutorActionListGetRoleClick;
import kof.game.Tutorial.tutorPlay.action.CTutorActionGuideClick;
import kof.game.Tutorial.tutorPlay.action.CTutorActionInstanceChangeChapter;
import kof.game.Tutorial.tutorPlay.action.CTutorActionInstanceFightClick;
import kof.game.Tutorial.tutorPlay.action.CTutorActionIsOpenSystemBundle;
import kof.game.Tutorial.tutorPlay.action.CTutorActionListNewServerGetRewardClick;
import kof.game.Tutorial.tutorPlay.action.CTutorActionListShopItemClick;
import kof.game.Tutorial.tutorPlay.action.CTutorActionListTalentItemClick;
import kof.game.Tutorial.tutorPlay.action.CTutorActionListTalentSelectStoneClick;
import kof.game.Tutorial.tutorPlay.action.CTutorActionNpcDialog;
import kof.game.Tutorial.tutorPlay.action.CTutorActionNpcDialogOrClick;
import kof.game.Tutorial.tutorPlay.action.CTutorActionNpcTrack;
import kof.game.Tutorial.tutorPlay.action.CTutorActionOpenSystemBundle;
import kof.game.Tutorial.tutorPlay.action.CTutorActionPlayScenario;
import kof.game.Tutorial.tutorPlay.action.CTutorActionListRoleClick;
import kof.game.Tutorial.tutorPlay.action.CTutorActionRoleTeamCreation;
import kof.game.Tutorial.tutorPlay.action.CTutorActionRoleTeamUpgrade;
import kof.game.Tutorial.tutorPlay.action.CTutorActionSetPlayHandler;
import kof.game.Tutorial.tutorPlay.action.CTutorActionShowFirstRechargeTips;
import kof.game.Tutorial.tutorPlay.action.CTutorActionSystemBundleGuideClick;
import kof.game.Tutorial.tutorPlay.action.CTutorActionTestPressP;
import kof.game.Tutorial.tutorPlay.action.carnival.CTutorActionCarnivalClickReward;
import kof.game.Tutorial.tutorPlay.action.carnival.CTutorActionCarnivalSelectDay;
import kof.game.Tutorial.tutorPlay.action.carnival.CTutorActionCarnivalSelectTab;
import kof.game.Tutorial.tutorPlay.action.teachingInstance.CTutorActionTeachingClickFight;
import kof.game.Tutorial.tutorPlay.action.teachingInstance.CTutorActionTeachingSelectTab;

public class CTutorActionCreater {
    public static function createAction(actionInfo:CTutorActionInfo, system:CAppSystem) : CTutorActionBase {
        var action:CTutorActionBase;
        var clazz:Class;
        switch  (actionInfo.actionID) {
            case ETutorActionType.GUIDE_CLICK :
                clazz = CTutorActionGuideClick;
                break;
            case ETutorActionType.SHOP_ITEM_CLICK :
                clazz = CTutorActionListShopItemClick;
                break;

            case ETutorActionType.HERO_GOT:
                clazz = CTutorActionListGetRoleClick;
                break;
            case ETutorActionType.HERO_CLICK:
                clazz = CTutorActionListRoleClick;
                break;

            case ETutorActionType.EMBATTLE_HERO :
                clazz = CTutorActionListEmbattleRoleClick;
                break;
            case ETutorActionType.ROLE_TEAM_CREATION:
                clazz = CTutorActionRoleTeamCreation;
                break;
            case ETutorActionType.ROLE_TEAM_UPGRADE:
                clazz = CTutorActionRoleTeamUpgrade;
                break;

            case ETutorActionType.SYSTEM_BUNDLE_SET_ACTIVED:
                clazz = CTutorActionOpenSystemBundle;
                break;
            case ETutorActionType.SYSTEM_BUNDLE_ACTIVITY_VALUE :
                clazz = CTutorActionIsOpenSystemBundle;
                break;
            case ETutorActionType.SYSTEM_BUNDLE_GUIDE_CLICK:
                clazz = CTutorActionSystemBundleGuideClick;
                break;

            case ETutorActionType.PLAY_SCENARIO :
                clazz = CTutorActionPlayScenario;
                break;

            case ETutorActionType.NPC_TRACK :
                clazz = CTutorActionNpcTrack;
                break;
            case ETutorActionType.NPC_DIALOG:
                clazz = CTutorActionNpcDialog;
                break;
            case ETutorActionType.NPC_DIALOG_OR_CLICK:
                clazz = CTutorActionNpcDialogOrClick;
                break;

            case ETutorActionType.INSTANCE_FIGHT_CLICK:
                clazz = CTutorActionInstanceFightClick;
                break;
            case ETutorActionType.INSTANCE_CHANGE_CHAPTER:
                clazz = CTutorActionInstanceChangeChapter;
                break;
            case ETutorActionType.FINISH_WHEN_RETURN_MAIN_CITY:
                clazz = CTutorActionFinishWhenReturnMainCity;
                break;

            case ETutorActionType.ACTIVITY_NEW_SERVER_GET_REWARD:
                clazz = CTutorActionListNewServerGetRewardClick;
                break;

            case ETutorActionType.DAILY_TASK_REWARD_LIST:
                clazz = CTutorActionListDailyTaskGetRewardClick;
                break;
            case ETutorActionType.ARENA_ENEMY_FIGHT:
                clazz = CTutorActionListArenaFightClick;
                break;
            case ETutorActionType.TALENT_ITEM_CLICK :
                clazz = CTutorActionListTalentItemClick;
                break;
            case ETutorActionType.TALENT_SELECT_LIST_CLICK :
                clazz = CTutorActionListTalentSelectStoneClick;
                break;

            case ETutorActionType.SHOW_FIRST_RECHARGE_TIPS :
                clazz = CTutorActionShowFirstRechargeTips;
                break;
            case ETutorActionType.SET_PLAY_HANDLE :
                clazz = CTutorActionSetPlayHandler;
                break;

            case ETutorActionType.DO_NOTHING :
                clazz = CTutorActionDoNoThing;
                break;

            case ETutorActionType.TEST_PRESS_P :
                clazz = CTutorActionTestPressP;
                break;

            case ETutorActionType.CARNIVAL_SELECT_DAY :
                clazz = CTutorActionCarnivalSelectDay;
                break;
            case ETutorActionType.CARNIVAL_SELECT_TAB :
                clazz = CTutorActionCarnivalSelectTab;
                break;
            case ETutorActionType.CARNIVAL_CLICK_REWARD :
                clazz = CTutorActionCarnivalClickReward;
                break;

            case ETutorActionType.TEACHING_SELECT_TAB :
                clazz = CTutorActionTeachingSelectTab;
                break;
            case ETutorActionType.TEACHING_CLICK_FIGHT :
                clazz = CTutorActionTeachingClickFight;
                break;

            default:
                break;
        }

        if (clazz) {
            action = new clazz(actionInfo, system);
        }
        return action;
    }
}
}
