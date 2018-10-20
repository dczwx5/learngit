//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/10/10.
 */
package kof.game.player.config {

import QFLib.Utils.PathUtil;

public class CPlayerPath {
    private static const _HERO_UI_ICON_PATH:String = "icon/role/ui/head_icon/";
    private static const _HERO_UI_BIG_ICON_PATH:String = _HERO_UI_ICON_PATH + "big_";
    private static const _HERO_UI_MIDDLE_ICON_PATH:String = _HERO_UI_ICON_PATH + "big_"; // ; // "middle_";
    private static const _HERO_UI_SMALL_ICON_PATH:String = _HERO_UI_ICON_PATH + "small_";

    public static function getUIHeroIconBigPath(heroID:int) : String {
        var url:String = _HERO_UI_BIG_ICON_PATH + heroID + ".png";
        return PathUtil.getVUrl(url);
    }
    public static function getUIHeroIconMiddlePath(heroID:int) : String {
        var url:String = _HERO_UI_MIDDLE_ICON_PATH + heroID + ".png";
        return PathUtil.getVUrl(url);
    }
    public static function getUIHeroIconSmallPath(heroID:int) : String {
        var url:String = _HERO_UI_SMALL_ICON_PATH + heroID + ".png";
        return PathUtil.getVUrl(url);
    }
    public static function getUIHeroFacePath(heroID:int) : String {
        var url:String = "icon/role/big/role_" + heroID + ".png";
        return PathUtil.getVUrl(url);
    }
    public static function getUIHeroNamePath(heroID:int) : String {
        var url:String = "icon/role/ui/name/name_" + heroID + ".png";
        return PathUtil.getVUrl(url);
    }
    public static function getPeakUIHeroFacePath(heroID:int) : String {
        var url:String = "icon/role/peakgame/role_" + heroID + ".png";
        return PathUtil.getVUrl(url);
    }
    public static function getPeakUIHeroFacePath2(heroID:int) : String {
        var url:String = "icon/role/peakgame2/role_" + heroID + ".png";
        return PathUtil.getVUrl(url);
    }
    public static function getHeroItemFacePath(heroID:int) : String {
        var url:String = "icon/item/small/" + heroID + ".png";
        return PathUtil.getVUrl(url);
    }
//    public static function getEquipIconMiddle(id:String) : String {
//        var url:String = "icon/equip/" + id + ".png";
//        return PathUtil.getVUrl(url);
//    }

//    public static function getItemIcoBig(id:int):String
//    {
//        var url:String = "icon/item/big/" + id + ".png";
//        return PathUtil.getVUrl(url);
//    }

//    public static function getItemIcoSmall(id:int):String
//    {
//        var url:String = "icon/item/small/" + id + ".png";
//        return PathUtil.getVUrl(url);
//    }
    public static function getMonsterIcon(id:int):String {
        var url:String = "icon/monster/fighthead/role_" + id + ".png";
        return PathUtil.getVUrl(url);
    }

    public static function getSkillBigIcon(IconName:String):String {
        var url:String = "icon/skill/big/" + IconName + ".png";
        return PathUtil.getVUrl(url);
    }
    public static function getSkillSmallIcon(IconName:String):String {
        var url:String = "icon/skill/small/" + IconName + ".png";
        return PathUtil.getVUrl(url);
    }
    public static function getPassiveSkillBigIcon(IconName:String):String {
        var url:String = "icon/skill/passivebig/" + IconName + ".png";
        return PathUtil.getVUrl(url);
    }
    public static function getPassiveSkillSmallIcon(IconName:String):String {
        var url:String = "icon/skill/passivesmall/" + IconName + ".png";
        return PathUtil.getVUrl(url);
    }

    public static function getSkillTagBigIcon(superScript:int):String {
        var url:String = "icon/skill/skilltag/" + superScript + ".png";
        return PathUtil.getVUrl(url);
    }

    public static function getHeroAudioPath(audio:String):String {
        var url:String = "assets/audio/" + audio;
        return PathUtil.getVUrl(url);
    }

    public static function getHeroSmallIconPath(heroId:int):String {
        var url:String = "icon/item/small/" + heroId + ".png";
        return PathUtil.getVUrl(url);
    }
    public static function getHeroBigconPath(heroId:int):String {
        var url:String = "icon/item/big/" + heroId + ".png";
        return PathUtil.getVUrl(url);
    }
}
}
