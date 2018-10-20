//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.data {

import kof.table.TreasureCardPool;

/**
 * @author Jeremy (jeremy@qifun.com)
 */
public class KOFTableConstants {

    public static const PLAYER_GLOBAL : String = "PlayerGlobal";
    static public const PLAYER_BASIC : String = "PlayerBasic";
    static public const PLAYER_DISPLAY : String = "PlayerDisplay";
    static public const LEVEL : String = "Level";
    static public const LEVELINFORMATION : String = "Levelinformation";
    static public const SKILL : String = "Skill";
    static public const HIT : String = "Hit";
    static public const SKILL_CATCH : String = "SkillCatch";
    static public const SKILL_CATCH_END : String = "SkillEndCatch";
    static public const TELEPORT_EFFECT : String = "Teleport";
    static public const MONSTER : String = "Monster";
    static public const TOWN : String = "Town";
    static public const MOTION : String = "Motion";
    static public const PLAYER_SKILL : String = "PlayerSkill";
    static public const MONSTER_SKILL : String = "MonsterSkill";
    static public const MAP_OBJECT : String = "MapObject";
    static public const MAP_OBJECT_SKILL : String = "MapObjectSkill";
    static public const NPC : String = "NPC";
    static public const AI : String = "AI";
    static public const Chain : String = "Chain";
    static public const ChainCondition : String = "ChainCondition";
    static public const ChainPropertyStatus : String = "ChainPropertyStatus";
    static public const ChainKeyCondition : String = "ChainKeyCondition";
    static public const ButtonMapping : String = "ButtonMapping";
    static public const LEVEL_UI_TXT : String = "LevelUITxt";
    static public const AERO : String = "Aero";
    static public const EMITTER : String = "Emitter";
    static public const AERO_ABSORBER : String = "AeroAbsorber";
    static public const SUMMONER : String = "Summoner";
    static public const DIALOGUE : String = "Dialogue";
    static public const AUDIO : String = "Audio";
    static public const INSTANCE : String = "Instance";
    static public const DAMAGE : String = "Damage";
    static public const HITSHAKE : String = "HitShake";
    static public const PLAYER_NAME_1 : String = "PlayerName1";
    static public const PLAYER_NAME_2 : String = "PlayerName2";
    static public const PLAYER_NAME_3 : String = "PlayerName3";
    static public const TEAM_ICON : String = "TeamIcon";
    static public const TEAM_LEVEL : String = "TeamLevel";
    static public const MODIFY_NAME_COST : String = "ModifyNameCost";

    static public const PLAYER_LINES : String = "PlayerLines";
    static public const PLAYER_CONSTANT : String = "PlayerConstant";
    static public const ITEM : String = "Item";
    static public const ItemSequence : String = "ItemSequence";

    static public const VIP_LEVEL : String = "VipLevel";
    static public const VIPPRIVILEGE : String = "VipPrivilege";
    static public const CURRENCY : String = "Currency";
    static public const CURRENCY_GOLD_CONTYPE : String = "CurrencyGoldContype";
    static public const CURRENCY_VIT_CONTYPE : String = "CurrencyVitContype";
    static public const TEAM_COEFFICIENT : String = "TeamCoefficient";
    static public const ROLE_SELECT : String = "RoleSelect";
    static public const SYSTEM_IDS : String = "SystemIDs";
    static public const MAIN_VIEW : String = "MainView";


    static public const INSTANCE_DIALOG : String = "InstanceDialog";
    static public const INSTANCE_EXIT : String = "Exit";
    static public const INSTANCE_CHAPTER : String = "InstanceChapter";
    static public const INSTANCE_CONTENT : String = "InstanceContent";
    static public const INSTANCE_TXT : String = "InstanceTxt";
    static public const INSTANCE_CONSTANTS : String = "InstanceConstant";
    static public const INSTANCE_TYPE : String = "InstanceType";
    static public const EMBATTLE : String = "Embattle";
    static public const NUMERIC_TEMPLATE : String = "NumericTemplate";
    static public const MONSTER_PROPERTY : String = "MonsterProperty";

    static public const HERO_TRAIN_QUALITY_LEVEL : String = "PlayerQuality";
    static public const HERO_TRAIN_QUALITY : String = "PlayerQualityConsume";
    static public const HERO_TRAIN_LEVEL : String = "PlayerLevelConsume";
    static public const HERO_TRAIN_STAR : String = "PlayerStarConsume";

    static public const EQUIP_BASE : String = "EquipBase";
    static public const EquipUpgrade : String = "EquipUpgrade";
    static public const EquipUpQuality : String = "EquipUpQuality";
    static public const EquipAwakenTemplate : String = "EquipAwakenTemplate";
    static public const EquipAwaken : String = "EquipAwaken";
    static public const EQUIP_QUALITY_LEVEL : String = "EquipQuality";

    static public const DROP_PACKAGE : String = "DropPackage";

//    static public const ACTION_SEQ2 : String = "ActionSeq2";
//    static public const ACTION_SEQ : String = "ActionSeq";

    static public const CAMP_REFS : String = "CampRefs";
    static public const GAME_PROMPT : String = "GamePrompt";
    static public const TASK : String = "Task";
    static public const PLOT_TASK : String = "PlotTask";

    static public const BUFF : String = "Buff";
    static public const BUFF_EMITTER : String = "BuffEmitter";

    static public const SCREEN_EFFECT : String = "ScreenEffect";
    static public const MAIL_SYSTEM : String = "MailSystem";
    static public const TASK_ACTIVE : String = "TaskActive";

    static public const CHAT_EMOTICON_SYSTEM : String = "ChatEmoticonSystem";
    static public const CHAT_EMOTICON_SHOP : String = "ChatEmoticonShop";
    static public const CHAT_EMOTICON_SHOP_CHILD : String = "ChatEmoticonShopChild";
    static public const HIT_CRITERIA : String = "Criteria";

    static public const PEAK_GAME_LEVEL : String = "PeakScoreLevel";
    static public const PEAK_GAME_REWARD : String = "PeakReward";
    static public const PEAK_GAME_CONSTANT : String = "PeakConstant";

    static public const FAIR_PEAK_GAME_LEVEL : String = "FairPeakScoreLevel";
    static public const FAIR_PEAK_GAME_REWARD : String = "FairPeakReward";
    static public const FAIR_PEAK_GAME_CONSTANT : String = "FairPeakConstant";

    static public const ACTIVE_SKILL_UP : String = "ActiveSkillUp";
    static public const PASSIVE_SKILL_UP : String = "PassiveSkillUp";
    static public const SKILL_UP_CONSUME : String = "SkillUpConsume";
    static public const SKILL_POSITION_RATE : String = "SkillPositionRate";
    static public const SKILL_QUALITY_RATE : String = "SkillQualityRate";
    static public const HEALING : String = "Healing";
    static public const SKILL_EMITTER_CONSUME : String = "SkillEmitterConsume";
    static public const BREACH_LV_CONST : String = "BreachLvConst";

    static public const MARQUEE_MSG : String = "MarqueeInfo";
    static public const PASSIVE_SKILL_PRO : String = "PassiveSkillPro";
    static public const ARTIFACT : String = "ArtifactIntensify";
    static public const DESKTIPS : String = "DeskTips";
    static public const TEACHINGCONTENT : String = "TeachingContent";
    static public const TEACHINGGOAL : String = "TeachingGoal";
    static public const PRACTICE : String = "PracticeOpponent";
    static public const SUPERVIPCONFIG : String = "SuperVipConfig";
    static public const OPERATORCONFIG : String = "OperatorConfig";
    static public const ARTIFACTSOULINFO : String = "ArtifactSoulInfo";
    static public const ARTIFACTCOLOUR : String = "ArtifactColour";
    static public const ARTIFACTSOULQUALITY : String = "ArtifactSoulQuality";
    static public const ARTIFACTCONSTANT : String = "ArtifactConstant";
    static public const ARTIFACTBASICS : String = "ArtifactBasics";
    static public const ARTIFACTBREAKTHROUGH : String = "ArtifactBreakthrough";
    static public const ARTIFACTQUALITY : String = "ArtifactQuality";
    static public const ARTIFACTSUIT : String = "ArtifactSuit";
    static public const RESOURCEINSTANCE : String = "ResourceInstance";
    static public const RESOURCEINSTANCEDIFFICULTY : String = "ResourceInstanceDifficulty";
    static public const RESOURCEEXPCONSTANCE : String = "ResourceExpConstance";

    static public const TALENT_SOUL_POINT : String = "TalentSoulPoint";
    static public const TALENT_SOUL : String = "TalentSoul";
    static public const TALENT_CONSTANT : String = "TalentConstant";
    static public const FRIENDCONFIG : String = "FriendConfig";
    static public const SHOP_ITEM : String = "ShopItem";
    static public const SHOP : String = "Shop";
    static public const SHOP_REFRESH : String = "ShopRefresh";

    static public const SUGGESTCONFIG : String = "SuggestionConfig";
    static public const CULTIVATE_BASE : String = "ClimbTowerBase";
    static public const CULTIVATE_DESC : String = "ClimbTowerInfo";
    static public const CULITIVATE_BUFF : String = "TowerBuff";
    static public const CULITIVATE_CONSTANT : String = "TowerConstant";
    static public const CULITIVATE_RAND_BUFF_COST : String = "TowerRandBuffCost";

    static public const IMPRESSION : String = "Impression";
    static public const IMPRESSION_TITLE : String = "ImpressionTitle";
    static public const IMPRESSION_LEVEL : String = "ImpressionLevel";
    static public const IMPRESSION_PROPERTY : String = "ImpressionProperty";
    static public const BUBBLE_MSG : String = "BubbleMsg";
    static public const IMPRESSION_TASK : String = "ImpressionTask";
    static public const ImpressionTotalLevelAddProperty : String = "ImpressionTotalLevelAddProperty";

    static public const CLUBUPGRADEBASIC : String = "ClubUpgradeBasic";
    static public const CLUBCONSTANT : String = "ClubConstant";
    static public const CLUBPOSITION : String = "ClubPosition";
    static public const INVESTCONSUMEREWARD : String = "InvestConsumeReward";
    static public const LUCKYBAGCONFIG : String = "LuckyBagConfig";

    static public const NEW_SERVER_REWARD : String = "NewServerReward";
    static public const TUTOR_GROUP : String = "TutorGroup";
    static public const SIGNIN_REWARD : String = "SignInReward";
    static public const TUTOR_ACTION : String = "TutorAction";
    static public const TOTAL_SIGNIN_REWARD : String = "TotalSignInReward";
    static public const TUTOR_TXT : String = "TutorTxt";

    static public const ENHANCE_ABILITY : String = "Enhanceability";
    static public const BUNDLE_ENABLE : String = "BundleEnable";
    static public const TASKCALLUP : String = "TaskCallUp";
    static public const CARD_MONTH_CONFIG : String = "CardMonthConfig";
    static public const CALLUPCONSTANT : String = "CallUpConstant";
    static public const COUPLERELATIONSHIP : String = "CoupleRelationship";

    static public const CARDPLAYER_POOL : String = "CardPlayerPool";
    static public const CARDPLAYER_TIMES : String = "CardPlayerTimes";
    static public const SHOWITEM : String = "ShowItem";
    static public const CARDPLAYER_ACTIVITY : String = "CardPlayerActivity";
    static public const EUROPEAN_MONEY : String = "EuropeanMoney";
    static public const FREE_SET : String = "FreeSet";
    static public const TEAMADDITION : String = "TeamAddition";
    static public const CARDPlAYERCONSTANT : String = "CardPlayerConstant";
    static public const NEWSERVERSHOWITEM : String = "NewServerShowItem";
    static public const NEWSERVERTIMES : String = "NewServerTimes";
    static public const AllSHOWITEM : String = "AllShowItem";

    static public const HEROQUALITYADDITION : String = "HeroQualityAddition";
    static public const HEROSTARADDITION : String = "HeroStarAddition";
    static public const TEAMLEVELADDITION : String = "TeamLevelAddition";

    static public const TENCENT_FRESH_PRIVILEGE : String = "TencentFreshPrivilege";
    static public const TENCENT_DAILY_PRIVILEGE : String = "TencentDailyPrivilege";
    static public const TENCENT_LEVEL_PRIVILEGE : String = "TencentLevelPrivilege";

    static public const CHATCONSTANT : String = "ChatConstant";


    static public const HANGUP_BATTLE_ADDITION : String = "HangUpBattleAddition";
    static public const HANGUP_LEVEL_ADDITION : String = "HangUpLevelAddition";
    static public const HANGUP_CONSTANT : String = "HangUpConstant";
    static public const HANGUP_SKILL_VIDEO : String = "HangUpSkillVideo";

    static public const EQUIPCARD_POOL : String = "EquipCardPool";
    static public const EQUIPCARD_TIMES : String = "EquipCardTimes";
    static public const EQUIPSHOWITEM : String = "EquipShowItem";

    static public const SKILLBUY : String = "SkillBuy";
    static public const SYSTEMCONSTANT : String = "SystemConstant";
    static public const WORLD_BOSS_CONSTANT : String = "WorldBossConstant";
    static public const WORLD_BOSS_TREASURE_BUY_PRICE : String = "WorldBossTreasureBuyPrice";
    static public const WORLD_BOSS_TREASURE_RATIO : String = "WorldBossTreasureRatio";
    static public const WORLD_BOSS_REWARD_GOLD : String = "WorldBossRewardGold";
    static public const WORLD_BOSS_RANK_REWARD : String = "WorldBossRankReward";
    static public const WORLD_BOSS_PROPERTY : String = "WorldBossProperty";
    static public const WORLD_BOSS_REVIVE_PRICE : String = "WorldBossRevivePrice";
    static public const WORLD_BOSS_CHAT_CONTENT : String = "WorldBossChatContent";

    static public const TREASUREDISPLAYITEM : String = "TreasureDisplayItem";
    static public const TREASURECARDPOOL : String = "TreasureCardPool";
    static public const TREASUREACTIVITYINFO : String = "TreasureActivityInfo";

    static public const ArenaTimeDeplete : String = "ArenaTimeDeplete";
    static public const ArenaChangeBatch : String = "ArenaChangeBatch";
    static public const ArenaRankingReward : String = "ArenaRankingReward";
    static public const ArenaHighestRanking : String = "ArenaHighestRanking";
    static public const ArenaBubble : String = "ArenaBubble";
    static public const ArenaConstant : String = "ArenaConstant";

    static public const SEVEN_DAYS : String = "NewServerLoginActivityConfig";

    static public const FirstRecharge : String = "FirstRechargeActivityConst";
    static public const DailyRecharge : String = "EverydayRechargeConfig";
    static public const OneDiamondReward : String = "OneDiamondActivityConfig";
    static public const FirstRechargeTips : String = "FirstRechargeTipsConfig";

    static public const ACTIVITY : String = "Activity";
    static public const TOTALCONSUME_ACTIVITY : String = "ConsumeActivity";
    static public const TOTALCHARGE_ACTIVITY : String = "TotalRechargeConfig";
    static public const DISCOUNT_SHOP : String = "DiscounterActivityConfig";
    static public const ACTIVE_TASK : String = "TaskActivity";
    static public const ACTIVITY_PREVIEW : String = "ActivityPreviewData";

    static public const SKILLRUSH : String = "SkillRush";
    static public const NEW_SERVER_ACTIVITY : String = "ServerActivity";

    static public const PAY_PRODUCT : String = "PayProduct";

    static public const LIMITACTIVITY_RANKCONFIG : String = "LimitTimeConsumeActivityRankConfig";
    static public const LIMITACTIVITY_SCORECONFIG : String = "LimitTimeConsumeActivityScoreConfig";
    static public const LIMITACTIVITY_CONST : String = "LimitTimeConsumeActivityConst";
    static public const LIMITACTIVITY_CONSUME : String = "LimitTimeConsumeActivityConfig";
    static public const ITEM_GET_PATH : String = "ItemGetPath";

    static public const CARNIVALACTIVITY_CONFIG : String = "CarnivalActivityConfig";
    static public const CARNIVALACTIVITY_ENTRY_CONFIG : String = "CarnivalEntryConfig";
    static public const CARNIVALACTIVITY_TARGET_CONFIG : String = "CarnivalTargetConfig";
    static public const CARNIVALACTIVITY_REWARD_CONFIG : String = "CarnivalRewardConfig";

    static public const SKILLGETCONDITION : String = "SkillGetCondition";

    static public const UPDATENOTICECONFIG : String = "UpdateNoticeConfig";

    static public const EndlessTowerConst : String = "EndlessTowerConst";
    static public const EndlessTowerLayerConfig : String = "EndlessTowerLayerConfig";
    static public const EndlessTowerSegmentConfig : String = "EndlessTowerSegmentConfig";
    static public const EndlessTowerRobotConfig : String = "EndlessTowerRobotConfig";
    static public const RobotPlayer : String = "RobotPlayer";
    static public const RobotHero : String = "RobotHero";
    static public const CLUBBOSSCONSTANT : String = "ClubBossConstant";
    static public const CLUBBOSSREVIVEPRICE : String = "ClubBossRevivePrice";
    static public const CLUBBOSSRANKREWARD : String = "ClubBossRankReward";
    static public const CLUBBOSSRANKSINGLE : String = "ClubBossRankSingle";
    static public const CLUBBOSSPROPERTY : String = "ClubBossProperty";
    static public const CLUBBOSSBASE : String = "ClubBossBase";

    static public const Peak1v1Reward : String = "Peak1v1Reward";
    static public const Peak1v1Constant : String = "Peak1v1Constant";
    static public const Peak1v1AlwaysWinScore : String = "Peak1v1AlwaysWinScore";

    static public const WECHATCONFIG : String = "WeChatConfig";
    static public const BUYRESETTIMESCONFIG : String = "BuyResetTimesConfig";
    static public const SPECIALREWARD : String = "SpecialReward";
    static public const LATTICEREWARD : String = "LatticeReward";
    static public const BUBBLE : String = "Bubble";
    static public const SEQUENCEOFPOPUP : String = "SequenceOfPopup";

    static public const FLAGDES : String = "FlagDes";
    static public const INVESTCONST : String = "InvestConst";
    static public const INVESTREWARDCONFIG : String = "InvestRewardConfig";
    static public const RECHARGEREBATE : String = "RechargeRebate";

    static public const LEVELUPREWARD7k7k : String = "LevelUpReward7k7k";
    static public const SEVENKREWARDCONFIG : String = "SevenKRewardConfig";


    static public const DIAMOND_ROULETTE_CONFIG : String = "DiamondRouletteConfig";
    static public const DIAMOND_ROULETTE_CONST : String = "DiamondRouletteConst";
    static public const DRECHARGE_EXTRA_CONST : String = "RechargeExtraCounts";


    static public const YYREWAEDCONFIG : String = "YYRewardConfig";
    static public const YYLOGINREWARD : String = "YYLoginReward";
    static public const YYGAMELEVELREWARD : String = "YYGameLevelReward";
    static public const YYLEVELREWARD : String = "YYLevelReward";
    static public const YYVIPLEVELREWARD : String = "YYVipLevelReward";
    static public const YYVIPDAYWELFARE : String = "YYVipDayWelfare";
    static public const YYVIPWEEKWELFARE : String = "YYVipWeekWelfare";

    static public const ActivitySchedule : String = "ActivitySchedule";

    static public const ACTIVITYCONST : String = "ActivityConst";

    static public const GuildWarConstant : String = "GuildWarConstant";
    static public const GuildWarSpaceTable : String = "GuildWarSpaceTable";
    static public const GuildWarReward : String = "GuildWarReward";
    static public const GuildWarAlwaysWin : String = "GuildWarAlwaysWin";
    static public const GuildWarExtraSpaceReward : String = "GuildWarExtraSpaceReward";
    static public const GuildWarBuff : String = "GuildWarBuff";
    static public const GuildWarReport : String = "GuildWarReport";
    static public const FirstOccupyReward : String = "FirstOccupyReward";

    static public const RANKCONFIG : String = "RankConfig";

    static public const FOREVER_RECHARGE_REWARD : String = "ForeverRechargeReward";

    static public const RECRUIT_ACTIVITY_CONFIG : String = "RecruitRankActivityConfig";
    static public const RECRUIT_ACTIVITY_CONST : String = "RecruitRankActivityConst";
    static public const RECRUIT_ACTIVITY_RANK_CONFIG : String = "RecruitRankActivityRankConfig";
    static public const RECRUIT_ACTIVITY_TIMES_CONFIG : String = "RecruitRankActivityTimesConfig";

    static public const BOSS_CHALLENGE_CONST : String = "CooperationBossConstant";
    static public const BOSS_CHALLENGE_BASE : String = "CooperationBossBase";
    static public const BOSS_CHALLENGE_PROP : String = "CooperationBossProperty";

    static public const INSTANCE_LOAD : String = "InstanceLoad";

    static public const SKILLVIDEO : String = "SkillVideo";

    static public const EFFORT_CONST : String = "EffortConst";
    static public const EFFORT_STAGE_CONFIG : String = "EffortStageConfig";
    static public const EFFORT_TYPEREWARD_CONFIG : String = "EffortTypeRewardConfig";
    static public const EFFORT_CONFIG : String = "EffortConfig";
    static public const EFFORT_TARGET_CONFIG : String = "EffortTargetConfig";

    static public const STREET_FIGHTER_REWARD : String = "StreetFighterReward";

    static public const THANKSMESSAGE : String = "ThanksMessage";

    static public const PLATFORM_MOBILE_REGIST : String = "PlatformMobileRegister";
    static public const PlatFormBoxLoginReward : String = "PlatFormBoxLoginReward";
    static public const TalentSoulSuit : String = "TalentSoulSuit";
    static public const TalentOpenCondition : String = "TalentOpenCondition";
    static public const TalentSoulFurnace : String = "TalentSoulFurnace";

    static public const STORY_CONSTANT : String = "HeroStoryConstant";
    static public const STORY_HERO : String = "HeroStoryBase";
    static public const STORY_GATE : String = "HeroStoryGate";
    static public const STORY_CONSUME : String = "HeroStoryConsume";

    static public const TitleTypeConfig : String = "TitleTypeConfig";
    static public const TitleConfig : String = "TitleConfig";

    static public const RETRIEVESYSTEMCONFIG : String = "RetrieveSystemConfig";
    static public const RETRIEVEREWARD : String = "RetrieveReward";

    static public const STRENGTHEN_CONSTANTS : String = "StrengthConst";
    static public const STRENGTHEN_BATTLE_VALUE_TARGET : String = "StrengthTargetBattleValue"; // 各个item对应的战力要求
    static public const STRENGTHEN_ITEM : String = "StrengthItem";
    static public const STRENGTHEN_TYPE : String = "StrengthType";
    static public const STRENGTHEN_LEVEL_BATTLE_VALUE : String = "StrengthLevelBattleValue"; // 等级对应的战力.只有一份
    static public const STRENGTHEN_BATTLE_VALUE_CALC : String = "StrengthBattleValueCalc";

    static public const GemConstant : String = "GemConstant";
    static public const GemPoint : String = "GemPoint";
    static public const Gem : String = "Gem";
    static public const GemSuit : String = "GemSuit";

    static public const LOTTERYCONFIG : String = "LotteryConfig";
    static public const LOTTERYCONSUME : String = "LotteryConsume"; // 等级对应的战力.只有一份
    static public const LOTTERYSHOW : String = "LotteryShow";

    //挖宝大行动（影二的修行）
    static public const ACTIVITY_TREASURE_TASK : String = "ActivityTreasureTask";
    static public const ACTIVITY_TREASURE_BOX : String = "ActivityTreasureBox";
    static public const ACTIVITY_TREASURE_REPOSITORY : String = "ActivityTreasureRepository";

    static public const FunctionNotice : String = "FunctionNotice";
    static public const FuncOpenCondition : String = "FuncOpenCondition";

    static public const ChargeActivityNotice : String = "ChargeActivityNotice";


    static public var s_classRenameList : Object = {
        FairPeakScoreLevel : PEAK_GAME_LEVEL,
        FairPeakReward : PEAK_GAME_REWARD,
        FairPeakConstant : PEAK_GAME_CONSTANT
    };

    static public function getClassName( tableName : String ) : String {
        if ( s_classRenameList.hasOwnProperty( tableName ) ) {
            return s_classRenameList[ tableName ] as String;
        } else {
            return tableName;
        }
    }

    public function KOFTableConstants() {
    }

}
}
