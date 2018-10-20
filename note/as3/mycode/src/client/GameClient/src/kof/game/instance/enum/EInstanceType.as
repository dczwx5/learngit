//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/1.
 */
package kof.game.instance.enum {

public class EInstanceType {
    public static const TYPE_ALL:int = -9999; // 所有副本
    public static const TYPE_MAIN_CITY:int = -1; // 主城
    public static const TYPE_MAIN:int = 0; // 主线
    public static const TYPE_ELITE:int = 1; // 精英
    public static const TYPE_PVP:int = 2; // pvp
    public static const TYPE_3V3:int = 3; // pvp
    public static const TYPE_3PV3P:int = 4; // pvp
    public static const TYPE_CLIMP_CULTIVATE:int = 8; // pvp
    public static const TYPE_ENDLESS_TOWER:int = 14; // 无尽塔
    public static const TYPE_WORLD_BOSS:int = 15;
    public static const TYPE_CLUB_BOSS:int=16;
    public static const TYPE_GOLD_INSTANCE:int = 17; // 金币副本
    public static const TYPE_TRAIN_INSTANCE:int = 18; // 经验副本
    public static const TYPE_PEAK_GAME:int = 21; // pvp
    public static const TYPE_PEAK_GAME_FAIR:int = 22; // pvp
    public static const TYPE_PEAK_1V1:int = 23; // 巅峰对应
    public static const TYPE_ARENA:int = 24; // 竞技场
    public static const TYPE_PRACTICE:int = 25; // 练习场
    public static const TYPE_HOOK:int = 101;
    public static const TYPE_PEAK_PK:int = 26; // 切磋
    public static const TYPE_TEACHING:int = 28; // 教学副本
    public static const TYPE_MAIN_EXTRA:int = 19; // 番外
    public static const TYPE_GUILD_WAR:int = 29; // 公会战
    public static const TYPE_STORY:int = 30; //列传副本
    public static const TYPE_STREET_FIGHTER:int = 31; // 街头争霸
    public static const TYPE_COOPERATION_PVE:int = 32; //合作PVE

    public static function isMainExtra(type:int) : Boolean {
        return TYPE_MAIN_EXTRA == type;
    }
    public static function isPeakPK(type:int) : Boolean {
        return TYPE_PEAK_PK == type;
    }
    public static function isPVP(type:int) : Boolean {
        return type == TYPE_PVP || type == TYPE_3PV3P ||
                type == TYPE_3V3|| type == TYPE_PEAK_GAME ||
                type == TYPE_PEAK_GAME_FAIR || type == TYPE_PEAK_1V1 || type == TYPE_PEAK_PK || type == TYPE_GUILD_WAR || type == TYPE_STREET_FIGHTER;
    }
    public static function isPVE(type:int) : Boolean {
        return !isPVP(type);//type == TYPE_MAIN || type == TYPE_ELITE || type == TYPE_CLIMP_CULTIVATE;
    }
    public static function isPrelude(instanceID:int) : Boolean {
        return instanceID == 10000;
    }
    public static function isMainCity(type:int) : Boolean {
        return type == TYPE_MAIN_CITY;
    }

//    public static function isPractice( type : int ) : Boolean{
//        return type == TYPE_PRACTICE;
//    }

    public static function isPeakGame(type:int) : Boolean {
        return type == TYPE_PEAK_GAME || type == TYPE_PEAK_GAME_FAIR;
    }
    public static function isPractice(type:int) : Boolean {
        return type == TYPE_PRACTICE;
    }
    public static function isPeak1v1(type:int) : Boolean {
        return type == TYPE_PEAK_1V1;
    }
    public static function isClimp(type:int) : Boolean {
        return type == TYPE_CLIMP_CULTIVATE;
    }
    public static function isArena(type:int) : Boolean {
        return type == TYPE_ARENA;
    }
    public static function isScenario(type:int) : Boolean {
        return type == TYPE_MAIN || type == TYPE_MAIN_EXTRA || type == TYPE_TEACHING || type == TYPE_STORY;
    }
    public static function isElite(type:int) : Boolean {
        return type == TYPE_ELITE;
    }
    public static function isWorldBoss(type:int):Boolean{
        return type == TYPE_WORLD_BOSS;
    }
    public static function isEndLessTower(type:int):Boolean{
        return type == TYPE_ENDLESS_TOWER;
    }
    public static function isClubBoss(type:int):Boolean{
        return type==TYPE_CLUB_BOSS;
    }

    public static function isTeaching( type : int ) : Boolean{
        return type == TYPE_TEACHING;
    }

    public static function isGuildWar( type : int ) : Boolean{
        return type == TYPE_GUILD_WAR;
    }

    public static function isStreetFighter(type:int) : Boolean {
        return TYPE_STREET_FIGHTER == type;
    }
    public static function isStory(type:int) : Boolean {
        return TYPE_STORY == type;
    }

    // 经典对战模式, 3v3车轮
    public static function isClassicalMode(type:int) : Boolean {
        return isPeakGame(type) || isEndLessTower(type) || isPeakPK(type);
    }

    public static function isCooperation( type : int ) : Boolean{
        return type == TYPE_COOPERATION_PVE;
    }

    public static function canQE(type:int) : Boolean {
        switch (type) {
            case TYPE_MAIN :
            case TYPE_GOLD_INSTANCE :
            case TYPE_TRAIN_INSTANCE :
            case TYPE_CLIMP_CULTIVATE :
                return true;
        }
        return false;
    }
}
}
