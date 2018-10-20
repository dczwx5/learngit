//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/9/26.
//----------------------------------------------------------------------
package kof.game.character.fight.skill {

import QFLib.Foundation;

import kof.data.KOFTableConstants;

import kof.framework.IDataTable;

import kof.framework.IDatabase;
import kof.table.ActionSeq.EActionSeqType;

import kof.table.Skill;
import kof.table.Skill.ECastType;
import kof.table.Skill.ESkillType;
import kof.util.CAssertUtils;

/**
 * supply some utils function use,for skill type etc.
 */
public class CSkillUtil {

    public static function isActiveSkill( skillID : int, logMsg : String = '' ) : Boolean {
        var skillData : Skill = CSkillCaster.skillDB.getSkillDataByID( skillID, logMsg );

        if ( skillData != null ) {
            return skillData.CastType == ECastType.NORMAL;
        }

        return false;
    }

    public static function isChainSkill( skillID : int ) : Boolean {
        var skillData : Skill = CSkillCaster.skillDB.getSkillDataByID( skillID );

        if ( skillData != null ) {
            return skillData.CastType == ECastType.CHAIN;
        }

        return false;
    }

    public static function getMainSkill( skillID : int ) : int {
        var skillData : Skill = CSkillCaster.skillDB.getSkillDataByID( skillID );

        if ( skillData != null ) {
            if ( isActiveSkill( skillID ) )
                return skillID;
            if ( isChainSkill( skillID ) ) {
                var retID : int = skillData.RootSkill;
                CAssertUtils.assertNotEquals( retID, 0, "check the skill table !!! Chain Skill " + skillID + " Should config RootSkill ID" );
                return skillData.RootSkill;
            }
        }
        return 0;
    }

    public static function boSuperSkill( skillID : int ) : Boolean {
        var skillData : Skill = CSkillCaster.skillDB.getSkillDataByID( skillID );
        if ( !skillData )
            return false;
        return skillData.SkillType == ESkillType.SKILL_SPOWER;
    }

    public static function isHitSkill( skillID : int ) : Boolean{
        var skillData : Skill = CSkillCaster.skillDB.getSkillDataByID( skillID );
        if ( !skillData )
                return false;
        return skillData.SkillType == ESkillType.SKILL_HIT;
    }

    public static function getSkillFlag( nSkillID : int ) : String {
        var sActionFlag : String;
        var pSkillData : Skill = CSkillCaster.skillDB.getSkillDataByID( nSkillID );
        if ( pSkillData )
            sActionFlag = pSkillData.ActionFlag;
        return sActionFlag;
    }
}
}
