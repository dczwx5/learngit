//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/1/16.
 */
package kof.game.gm.event {

public class EGmEventType {
    // menu
    public static const EVENT_MENU_CMD:String = "menu_cmd";

    //
    public static const EVENT_SELECT_PANEL:String = "select_panel";

    // level
    public static const EVENT_LEVEL_ENTER_INSTANCE:String = "level_enter_instance";
    public static const EVENT_LEVEL_NEXT_LEVEL:String = "level_next_level";
    public static const EVENT_LEVEL_PASS_INSTANCE:String = "level_pass_instance";
    public static const ENVENT_LEVEL_OPEN_ALL_CHAPTER:String = "level_open_all_chapter";

    // base
    public static const EVENT_BASE_CALL_HERO:String = "base_call_hero";
    public static const EVENT_BASE_KILL_ALL:String = "base_kill_all";
    public static const EVENT_BASE_CLOSE_ALL_AI:String = "close_all_ai";
    public static const EVENT_BASE_OPEN_ALL_AI:String = "open_all_ai";

    // action
    public static const EVENT_SELECT_HERO:String = "action_select_hero";
    public static const EVENT_SELECT_COMB:String = "action_select_comb";
    public static const EVENT_NEXT_HERO:String = "action_next_hero";
    public static const EVENT_KILL_HERO:String = "action_kill_hero";
    public static const EVENT_MOVE_TO:String = "action_moveto";
    public static const EVENT_CHANGE_AI:String = "action_change_ai";
    public static const EVENT_OPEN_AI:String = "action_open_ai";
    public static const EVENT_CLOSE_AI:String = "action_close_ai";
    public static const EVENT_USE_SKILL:String = "action_use_skill";
    public static const EVENT_SKILL_SELECT_COMB:String = "action_skill_select_comb";
    public static const EVENT_SKILL_SELECT_H:String = "action_use_skill";

    // property
    public static const EVENT_PROPERTY_MODIFY:String = "property_modify";

    // skill
    public static const EVENT_SKILL_OPEN_AREA:String = "open_skill_area";
    public static const EVENT_SKILL_CLOSE_AREA:String = "close_skill_area";
    public static const EVENT_SKILL_OPEN_MAX_ATK_POWER:String = "open_skill_max_atk_power";
    public static const EVENT_SKILL_CLOSE_MAX_ATK_POWER:String = "close_skill_max_atk_power";
    public static const EVENT_SKILL_OPEN_POWER:String = "open_skill_power";
    public static const EVENT_SKILL_CLOSE_POWER:String = "close_skill_power";
    public static const EVENT_SKILL_OPEN_NO_CD:String = "open_skill_no_cd";
    public static const EVENT_SKILL_CLOSE_NO_CD:String = "close_skill_no_cd";



}
}
