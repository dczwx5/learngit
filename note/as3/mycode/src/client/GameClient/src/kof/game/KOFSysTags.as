//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game {

import QFLib.Graphics.FX.effectsystem.track.StraightLineTrack;

/**
     * KOF系统Tag统一字符串常量，用于存取KOF系统ID
     *
     * @author Jeremy (jeremy@qifun.com)
     */
    public final class KOFSysTags {

        static public const LOBBY : String = "LOBBY";
        static public const PLAYER_TEAM : String = "PLAYER_TEAM";
        static public const ROLE : String = "ROLE";
        static public const BAG : String = "BAG";
        static public const PUB : String = "PUB";
        static public const ARTIFACT : String = "ARTIFACT";
        static public const TEACHING : String = "TEACHING";
        static public const TEACHING_ZHUJIEMIAN : String = "TEACHING_ZHUJIEMIAN";
        static public const PRACTICE : String = "PRACTICE";
        static public const COLLECTION : String = "COLLECTION";
        static public const WEI_CLIENT : String = "WEI_CLIENT";
        static public const SUPER_VIP : String = "SUPER_VIP";
        static public const GUILD : String = "GUILD";
        static public const MALL : String = "MALL";
        static public const TASK : String = "TASK";
        static public const RANKING : String = "RANKING";
        static public const FRIEND : String = "FRIEND";
        static public const SETTINGS : String = "SETTINGS";
        static public const PAPAPA : String = "PAPAPA";
        static public const INSTANCE : String = "INSTANCE";
        static public const PVP : String = "PVP";
        static public const SWITCHING : String = "SWITCHING";
        static public const VIP : String = "VIP";
        static public const CHAT : String = "CHAT";
        static public const BUY_POWER : String = "BUY_POWER";
        static public const BUY_MONEY : String = "BUY_MONEY";
        static public const ELITE : String = "ELITE";
        static public const MAIL : String = "MAIL";
        static public const PEAK_GAME : String = "PEAK_GAME";
        static public const PEAK_1V1 : String = "PEAK_1V1";
        static public const PEAK_PK : String = "PEAK_PK";
        static public const PEAK_GAME_FAIR : String = "PEAK_GAME_FAIR";
        static public const STREET_FIGHTER : String = "STREET_FIGHTER";
        static public const TALENT : String = "TALENT";
        static public const CULTIVATE : String = "CULTIVATE";
        static public const SIGN : String = "SIGN";
        static public const IMPRESSION : String = "IMPRESSION";
        static public const EMBATTLE : String = "EMBATTLE";
        static public const NPC : String = "NPC";
        static public const FRIEND_CHAT : String = "FRIEND_CHAT";
        static public const SYSTEM_NOTICE : String = "SYSTEM_NOTICE";
        static public const MAINNOTICE_SYSTEM : String = "MAINNOTICE_SYSTEM";
        static public const TASKCALLUP : String = "TASKCALLUP";
        static public const MAIN_TASK : String = "MAIN_TASK";
        static public const BUY_MONTH_CARD : String = "BUY_MONTH_CARD";
        static public const BUY_WEEK_CARD : String = "BUY_WEEK_CARD";
        static public const CARDPLAYER : String = "CARDPLAYER";
        static public const ACTIVITY : String = "ACTIVITY";
        static public const TUTOR : String = "TUTOR"; // -4
        static public const SCENARIO : String = "SCENARIO"; // -5
        static public const GM : String = "GM"; // -6
        static public const LEVEL : String = "LEVEL"; // -7
        static public const QQ_HALL : String = "QQ_HALL";
        static public const QQ_BLUE_DIAMOND : String = "QQ_BLUE_DIAMOND";
        static public const QQ_YELLOW_DIAMOND : String = "QQ_YELLOW_DIAMOND";
        static public const SUGGESTION : String = "SUGGESTION";
        static public const HOOK : String = "HOOK";
        static public const ARENA : String = "ARENA";
        static public const WORLD_BOSS : String = "WORLD_BOSS";
        static public const SEVEN_DAYS : String = "SEVEN_DAYS";
        static public const EQUIP_CARD : String = "EQUIP_CARD";
        static public const FIRST_RECHARGE : String = "FIRST_RECHARGE";
        static public const DAILY_RECHARGE : String = "DAILY_RECHARGE";
        static public const ACTIVITY_HALL : String = "ACTIVITY_HALL";
        static public const ONE_DIAMOND_REWARD : String = "ONE_DIAMOND_REWARD";
        static public const ITEM_GET_PATH : String = "ITEM_GET_PATH";
        static public const NEW_SERVER_ACTIVITY : String = "NEW_SERVER_ACTIVITY";
        static public const PAY : String = "PAY";
        static public const LIMIT_ACTIVITY : String = "LIMIT_ACTIVITY";
        static public const WELFARE_HALL : String = "WELFARE_HALL";
        static public const ENDLESS_TOWER : String = "ENDLESS_TOWER";
        static public const CLUB_BOSS:String="CLUB_BOSS";
        static public const CARNIVAL_ACTIVITY : String = "CARNIVAL_ACTIVITY";
        static public const GAMESETTING : String = "GAMESETTING";
        static public const HANGUP_RESULT:String = "HANGUP_RESULT";
        static public const GMREPORT:String = "GMREPORT";
        static public const INVEST:String = "INVEST";
        static public const RECHARGEREBATE:String = "RECHARGEREBATE";
        static public const YY_HALL:String = "YY_HALL";
        static public const YY_WECHAT:String = "YY_WECHAT";
        static public const YY_VIP:String = "YY_VIP";
        static public const SEVENK_HALL:String = "SEVENK_HALL";
        static public const DIAMOND_ROULETTE:String = "DIAMOND_ROULETTE";
        static public const SKIL_LEVELUP:String = "SKIL_LEVELUP";
        static public const SKIL_BREAK:String = "SKIL_BREAK";
        static public const EQP_STRONG:String = "EQP_STRONG";
        static public const EQP_SWORD:String = "EQP_STRONG";
        static public const EQP_CLOTHES:String = "EQP_CLOTHES";
        static public const EQP_TROUSERS:String = "EQP_TROUSERS";
        static public const EQP_SHOES:String = "EQP_SHOES";

        static public const EQP_BREAK:String = "EQP_BREAK";
        static public const EQP_ATTSTRONG:String = "EQP_ATTSTRONG";
        static public const EQP_HPSTRONG:String = "EQP_HPSTRONG";
        static public const TALENT_PEAK:String = "TALENT_PEAK";
        static public const ACTIVITY_NOTICE:String = "ACTIVITY_NOTICE";
        static public const PLAYER_CONSTANT:String = "PlayerConstant";
        static public const GUILDWAR:String = "GUILD_WAR";
        static public const EFFORT:String = "EFFORT";
        static public const RECRUIT_RANK:String = "RECRUIT_RANK";
        static public const BOSS_CHALLENGE:String = "BOSS_CHALLENGE";
        static public const HERO_TREASURE:String = "HERO_TREASURE";
        static public const RED_PACKET:String = "RED_PACKET";
        static public const PLATFORM_MOBILE_REGIST:String = "PLATFORM_MOBILE_REGIST";
        static public const PLATFORM_BOX:String = "PLATFORM_BOX";
        static public const STORY : String = "STORY";
        static public const TITLE : String = "TITLE";
        static public const STRENGTHEN : String = "STRENGTHEN";
        static public const GEM : String = "GEM";
        static public const ACTIVITY_LOTTERY : String = "ACTIVITY_LOTTERY";
        static public const ACTIVITY_TREASURE : String = "ACTIVITY_TREASURE";

        static public const HERO_LEVEL_UP : String = "HERO_LEVEL_UP";
        static public const CLUB_GAME : String = "CLUB_GAME";
        static public const TALENT_MELT : String = "TALENT_MELT";
        static public const GEMEN_RECHARGE : String = "GEMEN_RECHARGE";
        static public const BARGAINCARD : String = "BARGAINCARD";
        static public const DISCOUNT_STORE : String = "DISCOUNT_STORE";
        static public const TOTAL_RECHARGE : String = "TOTAL_RECHARGE";
        static public const TOTAL_CONSUME : String = "TOTAL_CONSUME";

        public function KOFSysTags() {
        }
    }
}
