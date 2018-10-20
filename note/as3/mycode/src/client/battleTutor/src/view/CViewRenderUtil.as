//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/26.
 */
package view {

import action.EKeyCode;

import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.player.config.CPlayerPath;
import kof.table.Skill;
import kof.ui.master.BattleTutor.BTSkillItemUI;

import morn.core.components.Component;

public class CViewRenderUtil {
    public function CViewRenderUtil() {
    }

    public static function renderSkillItem(system:CAppSystem, key:String, skillID:int, item:Component):void {
        if (!(item is BTSkillItemUI)) {
            return;
        }

        var pBTSkillItemUI:BTSkillItemUI = item as BTSkillItemUI;
        pBTSkillItemUI.txt_key.text = key;
        pBTSkillItemUI.txt_key.visible = true;

        pBTSkillItemUI.bg_clip.index = 0;
        var pDB:IDatabase;
        var pTableSkil:IDataTable;
        var pSkill:Skill;
        pBTSkillItemUI.cacheAsBitmap = true;
        pBTSkillItemUI.img.cacheAsBitmap = true;
        pBTSkillItemUI.maskimg.cacheAsBitmap = true;
        pBTSkillItemUI.special_mask_img.cacheAsBitmap = true;

        if (key == EKeyCode.SPACE) {
            pBTSkillItemUI.bg_clip.index = 1;
            pBTSkillItemUI.txt_key.visible = false;
            pDB = system.stage.getSystem(IDatabase) as IDatabase;
            pTableSkil = pDB.getTable(KOFTableConstants.SKILL);
            pSkill = pTableSkil.findByPrimaryKey(skillID);
            if (pSkill) {
                pBTSkillItemUI.img.url = CPlayerPath.getSkillBigIcon(pSkill.IconName);
            }
            pBTSkillItemUI.maskimg.visible = false;
            pBTSkillItemUI.special_mask_img.visible = true;
            pBTSkillItemUI.img.mask = pBTSkillItemUI.special_mask_img;
        } else if (key == EKeyCode.L) {
            pBTSkillItemUI.img.url = CPlayerPath.getSkillBigIcon('skill_icon_roll');
            pBTSkillItemUI.maskimg.visible = true;
            pBTSkillItemUI.special_mask_img.visible = false;
            pBTSkillItemUI.img.mask = pBTSkillItemUI.maskimg;
        } else {
            pBTSkillItemUI.maskimg.visible = true;
            pBTSkillItemUI.special_mask_img.visible = false;
            pBTSkillItemUI.img.mask = pBTSkillItemUI.maskimg;

            pDB = system.stage.getSystem(IDatabase) as IDatabase;
            pTableSkil = pDB.getTable(KOFTableConstants.SKILL);
            pSkill = pTableSkil.findByPrimaryKey(skillID);
            if (pSkill) {
                pBTSkillItemUI.img.url = CPlayerPath.getSkillBigIcon(pSkill.IconName);
            }

        }
    }

}
}
