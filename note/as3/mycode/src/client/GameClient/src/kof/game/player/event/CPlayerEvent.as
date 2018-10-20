//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/9/30.
 */
package kof.game.player.event {

import flash.events.Event;

public class CPlayerEvent extends Event {

    public static const ERROR:String = "error";
    public static const PLAYER_DATA_INITIAL:String = "playerDataInitial";
    public static const PLAYER_DATA:String = "playerData";
    public static const BEFORE_UPDATE_DATA:String = "beforeUpdateData";


    // ====playerData 子事件
    public static const PLAYER_VIP_LEVEL:String = "subPlayVipLevel";
    public static const PLAYER_VIP:String = "subPlayVip.";
    public static const PLAYER_ORIGIN_CURRENCY:String = "subPlayOriginCurrency";
    public static const PLAYER_VIT:String = "subPlayVit"; // 体力
    public static const PLAYER_TEAM:String = "subPlayTeam";
    public static const PLAYER_LEVEL_UP:String = "subLevelUp";
    public static const PLAYER_TALENT:String = "subTalentChange";
    public static const PLAYER_PEAK:String = "subPeakChange";
    public static const PLAYER_PEAK_FAIR:String = "subPeakFairChange";
    public static const PLAYER_CULTIVATE:String = "subCultivateChange";
    public static const PLAYER_GUILD:String = "subGuildChange";
    public static const PLAYER_HERO_CARD:String = "subHeroCardChange"; // 招募
    public static const PLAYER_EQUIP_CARD:String = "subEquipCardChange"; // 装备抽奖
    public static const PLAYER_ARENA:String = "subArenaChange";
    public static const PLAYER_ARTIFACT:String = "subArtifactChange"; // 神器
    public static const PLAYER_MONTH_AND_WEEK_CARD:String = "subMonthNWeekChange"; // 月卡周卡
    public static const PLAYER_SYSTEM:String = "subSystemChange"; // 系统
    public static const PLAYER_TUTOR:String = "subTutorChange";
    public static const PLAYER_SKILL:String = "subSkillChange";
    public static const PLAYER_TASK:String = "subTaskChange";
    public static const PLAYER_HERO_DATA:String = "subHeroData";
    public static const PLAYER_GUILD_DATA:String = "subGuideData";
    public static const PLAYER_PLATFORM:String = "subPlatformChange"; // 平台

    // hero
    public static const HERO_ADD:String = "addHero";
    public static const HERO_DATA:String = "heroData";
    public static const HERO_LEVEL_UP:String = "heroLevel_up";
    public static const HERO_QUALITY_UP:String = "heroQuality_up";
    public static const HERO_STAR_UP:String = "heroStar_up";

    public static const HERO_RESET:String = "heroReset";
    public static const HERO_RESET_INFO:String = "heroResetInfo";

    // equip
    public static const EQUIP_DATA:String = "equipData";

    // skill
    public static const SKILL_DATA:String = "skillData";
    public static const SKILL_BREAK:String = "skillBreak";
    public static const SKILL_LVUP:String = "skillLvUp";
    public static const SKILL_ADD:String = "skillAdd";
    public static const SKILL_POINT:String = "skillPoint";

    // 战队
    public static const CREATE_TEAM:String = "createTeam";
    public static const RANDOM_NAME:String = "randomName";
    public static const VISIT_DATA:String = "visitData";

    //
    public static const SWITCH_HERO:String = "switchHero";// 切换选择格斗家
    public static const SHOW_ADD_PROGRESS:String = "showAddProgress";// 显示增加进度值

    public static const SHOWHIDE_COMBAT_EFFECT:String = "showHideCombatEffect";// 显示/隐藏战力增加特效
    public static const SHOW_GET_HERO_FINISHED:String = "show_get_hero_finished";// 格斗家获得界面完成

    public static const OPEN_AND_SELHERO:String = "openAndSelHero";// 打卡界面并选中某个格斗家

    public function CPlayerEvent(type:String, data:Object, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this.data = data;
    }

    public var data:Object;
}
}
