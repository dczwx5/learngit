//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/8/16.
 */
package kof.game.player.view.playerNew.util {

public class CPlayerConst {

    /** 角色面板对应的页签号 */
    public static const Panel_Index_HeroDevelop:int  = 0;// 格斗家养成
    public static const Panel_Index_EquipDevelop:int = 1;// 装备养成
    public static const Panel_Index_SkillDevelop:int = 2;// 招式提升

    /** 角色面板对应的页签名 */
    public static const Panel_Name_HeroDevelop:String  = "HeroDevelop";
    public static const Panel_Name_EquipDevelop:String  = "EquipDevelop";
    public static const Panel_Name_SkillDevelop:String  = "SkillDevelop";

    public static const HeroTags:Array = [
        [
            "格斗流派",
            "格斗家生日",
            "格斗家血型",
            "格斗家身高",
            "体重",
            "三围",
            "喜欢的食物",
            "兴趣",
            "重要的事物",
            "讨厌的事物"
        ],

        [
            "FightStyles",
            "RoleBirth",
            "RoleBlood",
            "RoleHeight",
            "RoleWeight",
            "Rolebwh",
            "RoleLikefood",
            "RoleHobbies",
            "Roleimportant",
            "Roledislike"
        ]
    ];

    public static const HeroBaseAttrs:Array = [
        "HP",
        "Attack",
        "Defense"
    ];

    public function CPlayerConst()
    {
    }
}
}
