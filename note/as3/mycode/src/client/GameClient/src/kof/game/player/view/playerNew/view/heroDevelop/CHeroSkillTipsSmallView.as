//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/8/30.
 */
package kof.game.player.view.playerNew.view.heroDevelop {

import QFLib.Utils.HtmlUtil;

import kof.data.KOFTableConstants;

import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.framework.IDatabase;
import kof.game.common.tips.ITips;
import kof.game.player.data.CSkillData;
import kof.table.Skill;
import kof.table.Skill;
import kof.ui.master.jueseNew.view.HeroSkillTipsSmallUI;

import morn.core.components.Component;

public class CHeroSkillTipsSmallView extends CViewHandler implements ITips{

    private var m_pViewUI:HeroSkillTipsSmallUI;
    private var m_pTipsObj:Component;
    private var m_pTipsData:Object;

    public function CHeroSkillTipsSmallView( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array
    {
        return [ HeroSkillTipsSmallUI ];
    }

    public function addTips(component:Component, args:Array = null):void
    {
        if ( m_pViewUI == null )
        {
            m_pViewUI = new HeroSkillTipsSmallUI();
        }

        m_pTipsObj = component;

        var skillInfo:Object;
        if(args != null)
        {
            skillInfo = args[0] as Object;
        }
        else
        {
            skillInfo = component.dataSource;
        }

        m_pTipsData = skillInfo;
        if(m_pTipsData)
        {
            var skillData:CSkillData = skillInfo.skillData;
            var skillId:int = skillInfo.skillId;

            if(skillData && skillData.pSkill)
            {
                m_pViewUI.txt_name.text = skillData.pSkill.Name;
                m_pViewUI.txt_level.text = "等级：" + skillData.skillLevel;
                m_pViewUI.img_top.visible = true;
                m_pViewUI.img_down.y = 147;
                m_pViewUI.txt_desc.y = 148;
                m_pViewUI.img_bg.height = 266;

                if(skillData.activeSkillUp)
                {
                    m_pViewUI.txt_cd.isHtml = true;
                    m_pViewUI.txt_cd.text =  "冷却时间：" + HtmlUtil.color(skillData.activeSkillUp.CD  + "s" ,"#00ff00");
                    m_pViewUI.txt_energyCost.isHtml = true;
                    if( skillData.skillPosition == 5 ){//大招
                        m_pViewUI.txt_energyCost.text = "怒气消耗：" + HtmlUtil.color('3点',"#FF8C00");
                    }else{
                        m_pViewUI.txt_energyCost.text = "能量消耗：" +
                                HtmlUtil.color(String( skillData.activeSkillUp.consumeAP1 + skillData.activeSkillUp.consumeAP2 + skillData.activeSkillUp.consumeAP3 ),"#FF8C00");
                    }


                    m_pViewUI.txt_damage.isHtml = true;
                    m_pViewUI.txt_damage.text = "伤害值：" +
                            HtmlUtil.color(String( skillData.activeSkillUp.damageCount + skillData.activeSkillUp.hitTimes * skillData.skillLevel * skillData.activeSkillUp.effectPar1 ),"#fff9d8");

                    m_pViewUI.txt_damag_percent.isHtml = true;
                    m_pViewUI.txt_damag_percent.text = "伤害百分比：" +
                            HtmlUtil.color(Math.ceil( ( skillData.activeSkillUp.perDamageCount +  skillData.skillLevel * ( skillData.activeSkillUp.effectPar2 / 10000 ) ) * 100 ) + '%',"#fff9d8");
                }

                m_pViewUI.txt_desc.text = skillData.pSkill.LongDescription;
            }
            else
            {
                clear();

                var skill:Skill = getSKillInfoById(skillId);
                if(skill)
                {
                    m_pViewUI.txt_name.text = skill.Name;
                    m_pViewUI.txt_desc.text = skill.LongDescription;
                }

                m_pViewUI.img_top.visible = false;
                m_pViewUI.img_down.y = m_pViewUI.img_top.y;
                m_pViewUI.txt_desc.y = m_pViewUI.img_down.y + 1;
                m_pViewUI.img_bg.height = 266-108;
            }
        }

        App.tip.addChild(m_pViewUI);
    }

    private function clear():void
    {
        m_pViewUI.txt_name.text = "";
        m_pViewUI.txt_level.text = "";
        m_pViewUI.txt_cd.text = "";
        m_pViewUI.txt_energyCost.text = "";
        m_pViewUI.txt_damage.text = "";
        m_pViewUI.txt_damag_percent.text = "";
        m_pViewUI.txt_desc.text = "";
    }

    public function hideTips():void
    {
        if(m_pViewUI)
        {
            m_pViewUI.remove();
        }
    }

    private function getSKillInfoById(skillId:int):Skill
    {
        var dataBase:IDatabase = system.stage.getSystem(IDatabase) as IDatabase;
        if(dataBase)
        {
            var dataTable:IDataTable = dataBase.getTable(KOFTableConstants.SKILL);
            var skill:Skill = dataTable.findByPrimaryKey(skillId) as Skill;
            return skill;
        }

        return null;
    }
}
}
