//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/8/25.
 */
package kof.game.player.view.playerNew {

import QFLib.Utils.PathUtil;

import flash.display.DisplayObject;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.game.character.property.CBasePropertyData;
import kof.game.common.tips.ITips;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CSkillData;
import kof.game.player.view.skillup.CSkillUpConst;
import kof.game.talent.talentFacade.CTalentFacade;
import kof.table.BreachLvConst;
import kof.table.FlagDes;
import kof.table.PassiveSkillPro;
import kof.table.PassiveSkillUp;
import kof.ui.master.jueseNew.panel.SkillTipsTagUI;
import kof.ui.master.jueseNew.panel.SkillTipsUI;

import morn.core.components.Component;
import morn.core.handlers.Handler;

public class CHeroSkillTipsView extends CViewHandler implements ITips {

    private var m_pViewUI:SkillTipsUI;
    private var m_pTipsObj:Component;
    private var m_pTipsData:CSkillData;
    private var m_skillID:int;
    private var m_skillPosition:int;
    private static const TYPE_ARY : Array = ['普','跳','U','I','O','space','','被','被','被','被'];

    public function CHeroSkillTipsView( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }
    override public function get viewClass() : Array
    {
        return [ SkillTipsUI ];
    }
    public function addTips(component:Component, args:Array = null):void
    {
        if (m_pViewUI == null)
        {
            m_pViewUI = new SkillTipsUI();
//            m_pViewUI.list_skill.renderHandler = new Handler(_renderSkillInfo);
            m_pViewUI.listTag.renderHandler = new Handler(_renderSkillTag);
        }

            m_pTipsObj = component;

            var skillData:CSkillData;
            if(args != null)
            {
                skillData = args[0] as CSkillData;
                m_skillID = int( args[1] );
                m_skillPosition = int( args[2] );
            }
            else
            {
                skillData = component.dataSource as CSkillData;
            }


        m_pViewUI.maskimgII.visible = false;
        m_pViewUI.maskimg.visible = false;

        m_pTipsData = skillData;
        var pTable : IDataTable;
        if(m_pTipsData)
        {
            ////////////////
            var pMaskDisplayObject : DisplayObject;

            pMaskDisplayObject =  m_pViewUI.maskimgII;
            if ( pMaskDisplayObject ) {
                m_pViewUI.img_spcicalSkill.cacheAsBitmap = true;
                pMaskDisplayObject.cacheAsBitmap = true;
                m_pViewUI.img_spcicalSkill.mask = pMaskDisplayObject;
            }
            pMaskDisplayObject =  m_pViewUI.maskimg;
            if ( pMaskDisplayObject ) {
                m_pViewUI.img_normalSkill.cacheAsBitmap = true;
                pMaskDisplayObject.cacheAsBitmap = true;
                m_pViewUI.img_normalSkill.mask = pMaskDisplayObject;
            }

            var str1 : String;
            var str2 : String;
            var index : int;
            var obj : Object;
            ///////////////////////

            m_pViewUI.txt_vValueA.text = '';

            var lvMax : Boolean = m_pTipsData.skillLevel >= CSkillUpConst.SKILL_LEVEL_MAX ;
//            m_pViewUI.txt_nextLvT.visible = m_pViewUI.box_effUp1.visible = m_pViewUI.box_effUp2.visible = !lvMax;

            var propertyData : CBasePropertyData  = new CBasePropertyData();
            propertyData.databaseSystem = _databaseSystem;
            var passiveSkillPro : PassiveSkillPro;

            var fakeBreakPowerAdd : int;
            for( index = 1 ; index <= 3 ; index++ ) {
                obj = getPositionInfo( index );
                if ( obj ) {
                    if ( obj.isBreak ) {
                        if ( m_pTipsData.activeSkillUp ) {
                            fakeBreakPowerAdd += m_pTipsData.activeSkillUp['fakeBreakPower' + index];
                        } else if ( m_pTipsData.passiveSkillUp ) {
                            fakeBreakPowerAdd = m_pTipsData.passiveSkillUp[ 'fakeBreakPower' + index ];
                        }
                    }
                }
            }

            if( m_pTipsData.pSkill ){
                m_pViewUI.txt_name.text = m_pTipsData.pSkill.Name;
                if( m_pTipsData.skillPosition == 5 ){//大招
                    m_pViewUI.img_spcicalSkill.url = CPlayerPath.getSkillBigIcon( skillData.pSkill.IconName );
                    m_pViewUI.txt_consume.text = '3点';
                    m_pViewUI.txt_consumeT.text = '怒气消耗：';
                    m_pViewUI.box_spcicalSkill.visible = true;
                    m_pViewUI.box_normalSkill.visible = false;
                }else{
                    m_pViewUI.img_normalSkill.url = CPlayerPath.getSkillBigIcon( skillData.pSkill.IconName );
                    m_pViewUI.txt_consume.text = String( m_pTipsData.activeSkillUp.consumeAP1 + m_pTipsData.activeSkillUp.consumeAP2 + m_pTipsData.activeSkillUp.consumeAP3 );
                    m_pViewUI.txt_consumeT.text = '能量消耗：';
                    m_pViewUI.box_spcicalSkill.visible = false;
                    m_pViewUI.box_normalSkill.visible = true;
                }

                if( m_pTipsData.activeSkillUp ){
                    m_pViewUI.txt_cd.text =  m_pTipsData.activeSkillUp.CD  + "s";
                    if( String( m_pTipsData.activeSkillUp.CD ).indexOf('.') != -1 &&
                            String( m_pTipsData.activeSkillUp.CD ).slice( String( m_pTipsData.activeSkillUp.CD ).indexOf('.'),String( m_pTipsData.activeSkillUp.CD ).length ).length > 2 ){
                        m_pViewUI.txt_cd.text =  m_pTipsData.activeSkillUp.CD.toFixed( 2 )  + "s";
                    }
                }

                m_pViewUI.txt_desc.text = m_pTipsData.pSkill.LongDescription;


//                m_pViewUI.txt_vValueB.text = String( m_pTipsData.activeSkillUp.damageCount + m_pTipsData.activeSkillUp.hitTimes * m_pTipsData.skillLevel * m_pTipsData.activeSkillUp.effectPar1 );
//                if( !lvMax ){
//                    m_pViewUI.txt_vValueA.text = String( m_pTipsData.activeSkillUp.damageCount + m_pTipsData.activeSkillUp.hitTimes * ( m_pTipsData.skillLevel + 1 ) * m_pTipsData.activeSkillUp.effectPar1);
//                }
//
//                m_pViewUI.txt_pValueB.text = Math.ceil( ( m_pTipsData.activeSkillUp.perDamageCount +  m_pTipsData.skillLevel * ( m_pTipsData.activeSkillUp.effectPar2 / 10000 ) ) * 100 ) + '%';
//                if( !lvMax ){
//                    m_pViewUI.txt_pValueA.text = Math.ceil( (m_pTipsData.activeSkillUp.perDamageCount +  (m_pTipsData.skillLevel + 1) * ( m_pTipsData.activeSkillUp.effectPar2 / 10000 ) ) * 100 ) + '%';
//                }
//
//                if( m_pTipsData.activeSkillUp.effectType == CSkillUpConst.ACTIVE_SKILL_DAMAGE ){
//                    m_pViewUI.txt_vName1.text = CSkillUpConst.ACTIVE_SKILL_DAMAGE_TYPE_ARY[0];
//                    m_pViewUI.txt_pName1.text = CSkillUpConst.ACTIVE_SKILL_DAMAGE_TYPE_ARY[1];
//                }else if(m_pTipsData.activeSkillUp.effectType == CSkillUpConst.ACTIVE_SKILL_HEALING ){
//                    m_pViewUI.txt_vName1.text = CSkillUpConst.ACTIVE_SKILL_HEALING_TYPE_ARY[0];
//                    m_pViewUI.txt_pName1.text = CSkillUpConst.ACTIVE_SKILL_HEALING_TYPE_ARY[1];
//                }
//
//                m_pViewUI.box_eff2.visible =
                        m_pViewUI.box_cd.visible =
                                m_pViewUI.box_consume.visible = true;

                 str1  = Math.ceil( ( skillData.activeSkillUp.perDamageCount +  skillData.skillLevel * ( skillData.activeSkillUp.effectPar2 / 10000 ) ) * 100 ) + '%';
                 str2  = String( skillData.activeSkillUp.damageCount + skillData.activeSkillUp.hitTimes * skillData.skillLevel * skillData.activeSkillUp.effectPar1 );

//                m_pViewUI.txt_vValueA.text = '对目标造成' + str1 + '+' + str2 + '点伤害';

                //技能标签
                var strII : String = m_pTipsData.pSkill.SkillFlag.toString(2) ;
                var aryII : Array = strII.split('' ).reverse();
                var tagIndex : int;
                var aryTag : Array = [];
                for( tagIndex = 0 ; tagIndex < aryII.length ; tagIndex++ ){
                    if( int( aryII[tagIndex] == 1 )){
                        aryTag.push( tagIndex + 1 );
                    }
                }
                m_pViewUI.listTag.dataSource = aryTag;


//                m_pViewUI.txt_powerAdd.text = String( m_pTipsData.activeSkillUp.fakeBasePower + m_pTipsData.activeSkillUp.fakeUpPower * ( m_pTipsData.skillLevel - 1) );
                if( m_pTipsData.activeSkillUp.emittereffectType1 == 1 ){
                    passiveSkillPro  = CTalentFacade.getInstance().getPassiveSkillProData( m_pTipsData.activeSkillUp.emittereffect1 );
                    propertyData[passiveSkillPro.word] = m_pTipsData.activeSkillUp.emittereffect1Par1 ;
//                    m_pViewUI.txt_powerAdd.text = String( m_pTipsData.activeSkillUp.fakeBasePower + m_pTipsData.activeSkillUp.fakeUpPower * ( m_pTipsData.skillLevel - 1) + propertyData.getBattleValue()
//                            + fakeBreakPowerAdd );
                }else{
//                    m_pViewUI.txt_powerAdd.text = String( m_pTipsData.activeSkillUp.fakeBasePower + m_pTipsData.activeSkillUp.fakeUpPower * ( m_pTipsData.skillLevel - 1)
//                            + fakeBreakPowerAdd );
                }


            }else if( m_pTipsData.passiveSkillUp ){
                m_pViewUI.txt_name.text = m_pTipsData.passiveSkillUp.skillname;
                m_pViewUI.img_normalSkill.url = CPlayerPath.getPassiveSkillBigIcon( skillData.passiveSkillUp.icon );
                m_pViewUI.box_spcicalSkill.visible = false;
                m_pViewUI.box_normalSkill.visible = true;

//                pTable  = _databaseSystem.getTable( KOFTableConstants.PASSIVE_SKILL_PRO );
//                var passiveSkillPro : PassiveSkillPro = pTable.findByPrimaryKey( m_pTipsData.passiveSkillUp.effectType );
//                m_pViewUI.txt_vName1.text = m_pViewUI.txt_vName1.text = passiveSkillPro.name;
//                m_pViewUI.txt_vValueB.text = String( m_pTipsData.passiveSkillUp.effectPar1 + (m_pTipsData.skillLevel - 1) * m_pTipsData.passiveSkillUp.skillUpEffectPar1 );
//                if( !lvMax ){
//                    m_pViewUI.txt_vValueA.text = String( m_pTipsData.passiveSkillUp.effectPar1 + m_pTipsData.skillLevel * m_pTipsData.passiveSkillUp.skillUpEffectPar1 );
//                }
//
//                if( m_pTipsData.passiveSkillUp.effectPar2 > 0 ){
//                    m_pViewUI.txt_pName1.text = m_pViewUI.txt_pName1.text = passiveSkillPro.name + CSkillUpConst.PASSIVE_SKILL_EFF_TYPE2;
//                    m_pViewUI.txt_pValueB.text = int((( m_pTipsData.passiveSkillUp.effectPar1 + (m_pTipsData.skillLevel - 1) * m_pTipsData.passiveSkillUp.skillUpEffectPar1 )/ 10000 ) * 100 ) + '%';
//                    if( !lvMax ){
//                        m_pViewUI.txt_pValueA.text = int((( m_pTipsData.passiveSkillUp.effectPar1 + m_pTipsData.skillLevel * m_pTipsData.passiveSkillUp.skillUpEffectPar1 )/ 10000 ) * 100 ) + '%';
//                    }
//                }
//                m_pViewUI.box_eff2.visible = m_pTipsData.passiveSkillUp.effectPar2 > 0;
//
                m_pViewUI.box_cd.visible =
                        m_pViewUI.box_consume.visible = false;

                 str1  = int((( m_pTipsData.passiveSkillUp.effectPar1 + (m_pTipsData.skillLevel - 1) * m_pTipsData.passiveSkillUp.skillUpEffectPar1 )/ 10000 ) * 100 ) + '%';
                 str2  = String( m_pTipsData.passiveSkillUp.effectPar1 + (m_pTipsData.skillLevel - 1) * m_pTipsData.passiveSkillUp.skillUpEffectPar1 );

//                m_pViewUI.txt_vValueA.text = '对目标造成' + str1 + '+' + str2 + '点伤害';

                m_pViewUI.txt_desc.text = m_pTipsData.passiveSkillUp.skillDesc;

                m_pViewUI.listTag.dataSource = [];//

//                m_pViewUI.txt_powerAdd.text = String( m_pTipsData.passiveSkillUp.fakeBasePower + m_pTipsData.passiveSkillUp.fakeUpPower * ( m_pTipsData.skillLevel - 1) );

                passiveSkillPro  = CTalentFacade.getInstance().getPassiveSkillProData( m_pTipsData.passiveSkillUp.effectType );
                propertyData[passiveSkillPro.word] = m_pTipsData.passiveSkillUp.effectPar1 + m_pTipsData.passiveSkillUp.skillUpEffectPar1 * m_pTipsData.skillLevel ;
//                m_pViewUI.txt_powerAdd.text = String( m_pTipsData.passiveSkillUp.fakeBasePower + m_pTipsData.passiveSkillUp.fakeUpPower * ( m_pTipsData.skillLevel - 1) + propertyData.getBattleValue()
//                        + fakeBreakPowerAdd );

            }
            m_pViewUI.txt_lv.text = "等级：" + m_pTipsData.skillLevel;
            if(  m_pViewUI.box_normalSkill.visible ){
                m_pViewUI.txt_key.text = TYPE_ARY[m_pTipsData.skillPosition];
//                m_pViewUI.clip_SuperScript.visible = skillData.pSkill && skillData.pSkill.SuperScript > 0 ;
//                if( m_pViewUI.clip_SuperScript.visible )
//                    m_pViewUI.clip_SuperScript.index = skillData.pSkill.SuperScript - 1;
            }


//
//            var str : String = '';
//            for( index = 1 ; index <= 3 ; index++ ){
//                obj  = getPositionInfo( index );
//                if( obj ){
//                    if( obj.isBreak ){
//                        if( m_pTipsData.activeSkillUp ){
//                            str = m_pTipsData.activeSkillUp['emittereffectdesc' + index];
//                        }else if( m_pTipsData.passiveSkillUp ){
//                            str = m_pTipsData.passiveSkillUp['emittereffectdesc' + index];
//                        }
//                        m_pViewUI['txt_' + index ].text = "<font color='#ffeaa9'>" +  str +  "</font>";
//                    }else if( obj.isActive ){
//                        m_pViewUI['txt_' + index ].text = "<font color='#ff0000'>尚未突破</font>";
//                    }
//                }else{
//                    pTable   = _databaseSystem.getTable( KOFTableConstants.BREACH_LV_CONST );
//                    var breachLvConst : BreachLvConst = pTable.findByPrimaryKey( 1 );
//                    m_pViewUI['txt_' + index ].text = "招式等级到达<font color='#ff0000'>" + breachLvConst['needSkillLv' + index] + "级</font>自动开启";
//                }
//            }


        } else{ //未开启的被动技能

            pTable  = _databaseSystem.getTable( KOFTableConstants.PASSIVE_SKILL_UP );
            var passiveSkillUp : PassiveSkillUp = pTable.findByPrimaryKey( m_skillID );

            m_pViewUI.txt_name.text = passiveSkillUp.skillname;
            m_pViewUI.img_normalSkill.url = CPlayerPath.getPassiveSkillBigIcon( passiveSkillUp.icon );
            m_pViewUI.box_spcicalSkill.visible = false;
            m_pViewUI.box_normalSkill.visible = true;

            m_pViewUI.box_cd.visible =
                    m_pViewUI.box_consume.visible = false;


            m_pViewUI.txt_vValueA.text = '';

            m_pViewUI.txt_desc.text = passiveSkillUp.skillDesc;

            m_pViewUI.listTag.dataSource = [];//

//            m_pViewUI.txt_powerAdd.text = "0";

            m_pViewUI.txt_lv.text = "等级：" + 0;
            if(  m_pViewUI.box_normalSkill.visible ){
                m_pViewUI.txt_key.text = TYPE_ARY[m_skillPosition];
            }

            //var str : String = '';
//            for( index = 1 ; index <= 3 ; index++ ){
//                pTable   = _databaseSystem.getTable( KOFTableConstants.BREACH_LV_CONST );
//                var breachLvConstI : BreachLvConst = pTable.findByPrimaryKey( 1 );
//                m_pViewUI['txt_' + index ].text = "招式等级到达<font color='#ff0000'>" + breachLvConstI['needSkillLv' + index] + "级</font>自动开启";
//            }

        }



        App.tip.addChild(m_pViewUI);
    }

    private function _renderSkillTag(item:Component, idx:int):void {
        if ( !(item is SkillTipsTagUI) ) {
            return;
        }
        var pSkillTipsTagUI : SkillTipsTagUI = item as SkillTipsTagUI;
        var pTable : IDataTable;
        var flagDes : FlagDes;
        if ( pSkillTipsTagUI.dataSource ) {
            pTable   = _databaseSystem.getTable( KOFTableConstants.FLAGDES );
            flagDes  = pTable.findByPrimaryKey( int( pSkillTipsTagUI.dataSource ) );
            if( flagDes ){
                pSkillTipsTagUI.img.url = PathUtil.getVUrl(flagDes.IconName);
            }
        }
    }

    private function getPositionInfo( i : int ):Object{
        for each( var obj : Object in m_pTipsData.slotListData.list ){
            if( obj.position == i ){
                return obj;
                break;
            }
        }
        return null;
    }
    private function get _databaseSystem():CDatabaseSystem {
        return  system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }

}
}
