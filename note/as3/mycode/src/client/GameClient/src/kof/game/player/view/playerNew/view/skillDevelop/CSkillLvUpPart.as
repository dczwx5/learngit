//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/8/22.
 * 技能升级
 */
package kof.game.player.view.playerNew.view.skillDevelop {

import QFLib.Foundation.CTime;
import QFLib.Utils.PathUtil;

import kof.SYSTEM_ID;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.character.property.CBasePropertyData;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.data.CSkillData;
import kof.game.player.event.CPlayerEvent;
import kof.game.player.view.playerNew.CSkillTagViewHandler;
import kof.game.player.view.skillup.CSkillUpConst;
import kof.game.player.view.skillup.CSkillUpHandler;
import kof.game.reciprocation.CReciprocalSystem;
import kof.game.talent.talentFacade.CTalentFacade;
import kof.table.BreachLvConst;
import kof.table.FlagDes;
import kof.table.PassiveSkillPro;
import kof.table.PassiveSkillUp;
import kof.table.SkillBuy;
import kof.table.SkillPositionRate;
import kof.table.SkillQualityRate;
import kof.table.SkillUpConsume;
import kof.table.VipPrivilege;
import kof.ui.CUISystem;
import kof.ui.master.jueseNew.panel.SkillTipsTagUI;
import kof.ui.master.jueseNew.view.SkillLvUpViewUI;

import morn.core.components.Component;

import morn.core.handlers.Handler;

public class CSkillLvUpPart extends CViewHandler {

    private var m_pViewUI:SkillLvUpViewUI;
    private var m_pData:CPlayerHeroData;
    private var m_pSkillData : CSkillData;

    private var _skillID : int;
    private var _needGold : int;
    private var _needSkillPoint : int;

    public function CSkillLvUpPart( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }

    public function initializeView():void
    {
        m_pViewUI.btn_add.clickHandler = new Handler( onBuySkillHandler );
        m_pViewUI.btn_up.clickHandler = new Handler( onSkillUpHandler );
        m_pViewUI.btn_topUp.clickHandler = new Handler( onTopUpHandler );
        m_pViewUI.listTag.renderHandler = new Handler( _renderSkillTag );
        m_pViewUI.btn_skillTag.clickHandler = new Handler( onSkillTagHandler );

    }

    public function updateView( skillData : CSkillData ,skillID : int ):void{

        m_pSkillData = skillData;

        m_pViewUI.box_txtLock.visible =  m_pSkillData == null ;
        m_pViewUI.box_unlock.visible =  m_pSkillData != null ;

        var pTable : IDataTable;
        var lvMax : Boolean = m_pSkillData &&  m_pSkillData.skillLevel >= CSkillUpConst.SKILL_LEVEL_MAX ;

        var propertyData : CBasePropertyData  = new CBasePropertyData();
        propertyData.databaseSystem = _databaseSystem;

        if( m_pSkillData && m_pSkillData.pSkill && m_pSkillData.activeSkillUp ){
            _skillID = m_pSkillData.pSkill.ID;
            m_pViewUI.txt_name.text = m_pSkillData.pSkill.Name;
            m_pViewUI.txt_type.text = CSkillUpConst.ACTIVE_SKILL_TYPE_ARY[ m_pSkillData.pSkill.SkillType ];
            m_pViewUI.txt_cd.text =  m_pSkillData.activeSkillUp.CD  + "s";
            if( String( m_pSkillData.activeSkillUp.CD ).indexOf('.') != -1 &&
                    String( m_pSkillData.activeSkillUp.CD ).slice( String( m_pSkillData.activeSkillUp.CD ).indexOf('.'),String( m_pSkillData.activeSkillUp.CD ).length ).length > 2 ){
                m_pViewUI.txt_cd.text =  m_pSkillData.activeSkillUp.CD.toFixed( 2 )  + "s";
            }

            if( m_pSkillData.skillPosition == 5  ){
                m_pViewUI.txt_consume.text = '3点';
                m_pViewUI.txt_consumeT.text = '怒气消耗';
            }else{
                m_pViewUI.txt_consume.text = String( m_pSkillData.activeSkillUp.consumeAP1 + m_pSkillData.activeSkillUp.consumeAP2 + m_pSkillData.activeSkillUp.consumeAP3 );
                m_pViewUI.txt_consumeT.text = '能量消耗';
            }

//            m_pViewUI.txt_desc.text = '招式描述：'+ m_pSkillData.pSkill.Description;
            m_pViewUI.txt_desc.text = '体能描述：'+ m_pSkillData.pSkill.LongDescription;

            m_pViewUI.txt_vValueB.text = String( m_pSkillData.activeSkillUp.damageCount + m_pSkillData.activeSkillUp.hitTimes * m_pSkillData.skillLevel * m_pSkillData.activeSkillUp.effectPar1 );
            if( !lvMax ){
                m_pViewUI.txt_vValueA.text = String( m_pSkillData.activeSkillUp.damageCount + m_pSkillData.activeSkillUp.hitTimes * ( m_pSkillData.skillLevel + 1 ) * m_pSkillData.activeSkillUp.effectPar1);
                m_pViewUI.txt_vAdd.text = String( m_pSkillData.activeSkillUp.hitTimes *  m_pSkillData.activeSkillUp.effectPar1 );
            }

            m_pViewUI.txt_pValueB.text = Math.ceil( ( m_pSkillData.activeSkillUp.perDamageCount +  m_pSkillData.skillLevel * ( m_pSkillData.activeSkillUp.effectPar2 / 10000 ) ) * 100 ) + '%';
            if( !lvMax ){
                m_pViewUI.txt_pValueA.text = Math.ceil( (m_pSkillData.activeSkillUp.perDamageCount +  (m_pSkillData.skillLevel + 1) * ( m_pSkillData.activeSkillUp.effectPar2 / 10000 ) ) * 100 ) + '%';
                m_pViewUI.txt_pAdd.text = Math.ceil( (  m_pSkillData.activeSkillUp.effectPar2 / 10000 ) * 100 ) + '%'
            }
            /////
//            m_pViewUI.txt_nValueB.text = String( m_pSkillData.activeSkillUp.fakeBasePower + m_pSkillData.activeSkillUp.fakeUpPower * ( m_pSkillData.skillLevel - 1) );

            if( m_pSkillData.activeSkillUp.emittereffectType1 == 1 ){
                passiveSkillPro  = CTalentFacade.getInstance().getPassiveSkillProData( m_pSkillData.activeSkillUp.emittereffect1 );
                propertyData[passiveSkillPro.word] = m_pSkillData.activeSkillUp.emittereffect1Par1 ;
                m_pViewUI.txt_nValueB.text = String( m_pSkillData.activeSkillUp.fakeBasePower + m_pSkillData.activeSkillUp.fakeUpPower * ( m_pSkillData.skillLevel - 1) + propertyData.getBattleValue() );
            }else{
                m_pViewUI.txt_nValueB.text = String( m_pSkillData.activeSkillUp.fakeBasePower + m_pSkillData.activeSkillUp.fakeUpPower * ( m_pSkillData.skillLevel - 1) );
            }

            if( !lvMax ){
//                m_pViewUI.txt_nValueA.text = String( m_pSkillData.activeSkillUp.fakeBasePower + m_pSkillData.activeSkillUp.fakeUpPower *  m_pSkillData.skillLevel );
                if( m_pSkillData.activeSkillUp.emittereffectType1 == 1 ){
                    passiveSkillPro  = CTalentFacade.getInstance().getPassiveSkillProData( m_pSkillData.activeSkillUp.emittereffect1 );
                    propertyData[passiveSkillPro.word] = m_pSkillData.activeSkillUp.emittereffect1Par1 ;
                    m_pViewUI.txt_nValueA.text = String( m_pSkillData.activeSkillUp.fakeBasePower + m_pSkillData.activeSkillUp.fakeUpPower *  m_pSkillData.skillLevel  + propertyData.getBattleValue() );
                }else{
                    m_pViewUI.txt_nValueA.text = String( m_pSkillData.activeSkillUp.fakeBasePower + m_pSkillData.activeSkillUp.fakeUpPower *  m_pSkillData.skillLevel  );
                }
                m_pViewUI.txt_nAdd.text = String( m_pSkillData.activeSkillUp.fakeUpPower );
            }


            if( m_pSkillData.activeSkillUp.effectType == CSkillUpConst.ACTIVE_SKILL_DAMAGE ){
                m_pViewUI.txt_vName1.text = m_pViewUI.txt_vName2.text = CSkillUpConst.ACTIVE_SKILL_DAMAGE_TYPE_ARY[0];
                m_pViewUI.txt_pName1.text = m_pViewUI.txt_pName2.text = CSkillUpConst.ACTIVE_SKILL_DAMAGE_TYPE_ARY[1];
            }else if(m_pSkillData.activeSkillUp.effectType == CSkillUpConst.ACTIVE_SKILL_HEALING ){
                m_pViewUI.txt_vName1.text = m_pViewUI.txt_vName2.text = CSkillUpConst.ACTIVE_SKILL_HEALING_TYPE_ARY[0];
                m_pViewUI.txt_pName1.text = m_pViewUI.txt_pName2.text = CSkillUpConst.ACTIVE_SKILL_HEALING_TYPE_ARY[1];
            }

            m_pViewUI.txt_nName1.text = m_pViewUI.txt_nName2.text = CSkillUpConst.ACTIVE_SKILL_DAMAGE_TYPE_ARY[2];

            m_pViewUI.box_eff2.visible = m_pViewUI.box_eff3.visible = m_pViewUI.box_cd.visible = m_pViewUI.box_consume.visible = true;

            //技能标签
            var strII : String = m_pSkillData.pSkill.SkillFlag.toString(2) ;
            var aryII : Array = strII.split('' ).reverse();
            var tagIndex : int;
            var aryTag : Array = [];
            for( tagIndex = 0 ; tagIndex < aryII.length ; tagIndex++ ){
                if( int( aryII[tagIndex] == 1 )){
                    aryTag.push( tagIndex + 1 );
                }
            }
            m_pViewUI.listTag.dataSource = aryTag;
            m_pViewUI.box_skillTag.visible = aryTag.length > 0;

        }else if( m_pSkillData && m_pSkillData.passiveSkillUp ){
            _skillID = m_pSkillData.passiveSkillUp.ID;
            m_pViewUI.txt_name.text = m_pSkillData.passiveSkillUp.skillname;
//            m_pViewUI.txt_type.text = CSkillUpConst.PASSIVE_SKILL_TYPE_ARY[ m_pSkillData.passiveSkillUp.effectType - 1];
            m_pViewUI.txt_type.text = '被动';
            m_pViewUI.txt_desc.text = '体能描述：'+ m_pSkillData.passiveSkillUp.skillDesc;

            pTable  = _databaseSystem.getTable( KOFTableConstants.PASSIVE_SKILL_PRO );
            var passiveSkillPro : PassiveSkillPro = pTable.findByPrimaryKey( m_pSkillData.passiveSkillUp.effectType );

            m_pViewUI.txt_vName1.text = m_pViewUI.txt_vName2.text = passiveSkillPro.name;
            m_pViewUI.txt_vValueB.text = String( m_pSkillData.passiveSkillUp.effectPar1 + m_pSkillData.skillLevel * m_pSkillData.passiveSkillUp.skillUpEffectPar1 );
            if( !lvMax ){
                m_pViewUI.txt_vValueA.text = String( m_pSkillData.passiveSkillUp.effectPar1 + ( m_pSkillData.skillLevel + 1 ) * m_pSkillData.passiveSkillUp.skillUpEffectPar1 );
                m_pViewUI.txt_vAdd.text = String( m_pSkillData.passiveSkillUp.skillUpEffectPar1 );
            }


            if( m_pSkillData.passiveSkillUp.effectPar2 > 0 ){
                m_pViewUI.txt_pName1.text = m_pViewUI.txt_pName2.text = passiveSkillPro.name + CSkillUpConst.PASSIVE_SKILL_EFF_TYPE2;
                m_pViewUI.txt_pValueB.text = int((( m_pSkillData.passiveSkillUp.effectPar1 + m_pSkillData.skillLevel * m_pSkillData.passiveSkillUp.skillUpEffectPar1 )/ 10000 ) * 100 ) + '%';
                if( !lvMax ){
                    m_pViewUI.txt_pValueA.text = int((( m_pSkillData.passiveSkillUp.effectPar1 + ( m_pSkillData.skillLevel + 1 )* m_pSkillData.passiveSkillUp.skillUpEffectPar1 )/ 10000 ) * 100 ) + '%';
                    m_pViewUI.txt_pAdd.text = int((  m_pSkillData.passiveSkillUp.skillUpEffectPar1 / 10000 ) * 100 ) + '%';
                }

            }

            m_pViewUI.box_eff2.visible = m_pSkillData.passiveSkillUp.effectPar2 > 0;

            if( m_pViewUI.box_eff2.visible ){
                m_pViewUI.box_eff3.visible = true;
                m_pViewUI.txt_nName1.text = m_pViewUI.txt_nName2.text = CSkillUpConst.ACTIVE_SKILL_DAMAGE_TYPE_ARY[2];
                m_pViewUI.txt_nValueB.text = String( m_pSkillData.passiveSkillUp.fakeBasePower + m_pSkillData.passiveSkillUp.fakeUpPower * ( m_pSkillData.skillLevel - 1) );
                if( !lvMax ){
                    m_pViewUI.txt_nValueA.text = String( m_pSkillData.passiveSkillUp.fakeBasePower + m_pSkillData.passiveSkillUp.fakeUpPower *  m_pSkillData.skillLevel );
                    m_pViewUI.txt_nAdd.text = String( m_pSkillData.passiveSkillUp.fakeUpPower );
                }
            }else{
                m_pViewUI.box_eff2.visible = true;
                m_pViewUI.box_eff3.visible = false;

                m_pViewUI.txt_pName1.text = m_pViewUI.txt_pName2.text = CSkillUpConst.ACTIVE_SKILL_DAMAGE_TYPE_ARY[2];
                ///
//                m_pViewUI.txt_pValueB.text = String( m_pSkillData.passiveSkillUp.fakeBasePower + m_pSkillData.passiveSkillUp.fakeUpPower * ( m_pSkillData.skillLevel - 1) );

                passiveSkillPro  = CTalentFacade.getInstance().getPassiveSkillProData( m_pSkillData.passiveSkillUp.effectType );
                propertyData[passiveSkillPro.word] = m_pSkillData.passiveSkillUp.effectPar1 + m_pSkillData.skillLevel * m_pSkillData.passiveSkillUp.skillUpEffectPar1 ;
                m_pViewUI.txt_pValueB.text = String( m_pSkillData.passiveSkillUp.fakeBasePower + m_pSkillData.passiveSkillUp.fakeUpPower * ( m_pSkillData.skillLevel - 1) + propertyData.getBattleValue() );

                if( !lvMax ){
//                    m_pViewUI.txt_pValueA.text = String( m_pSkillData.passiveSkillUp.fakeBasePower + m_pSkillData.passiveSkillUp.fakeUpPower *  m_pSkillData.skillLevel );
                    propertyData[passiveSkillPro.word] = m_pSkillData.passiveSkillUp.effectPar1 + ( m_pSkillData.skillLevel + 1 ) * m_pSkillData.passiveSkillUp.skillUpEffectPar1 ;
                    m_pViewUI.txt_pValueA.text = String( m_pSkillData.passiveSkillUp.fakeBasePower + m_pSkillData.passiveSkillUp.fakeUpPower * m_pSkillData.skillLevel + propertyData.getBattleValue() );
                    m_pViewUI.txt_pAdd.text = String( int( m_pViewUI.txt_pValueA.text ) - int( m_pViewUI.txt_pValueB.text ) );
                }
            }


            m_pViewUI.box_cd.visible =
                    m_pViewUI.box_consume.visible = false;
            m_pViewUI.box_skillTag.visible = false;
        }else if( null == m_pSkillData ){
            m_pViewUI.box_cd.visible =
                    m_pViewUI.box_consume.visible =
                            m_pViewUI.box_skillTag.visible = false;

            pTable  = _databaseSystem.getTable( KOFTableConstants.PASSIVE_SKILL_UP );
            var passiveSkillUp : PassiveSkillUp = pTable.findByPrimaryKey( skillID );
            m_pViewUI.txt_type.text = '被动';
            m_pViewUI.txt_desc.text = '体能描述：'+ passiveSkillUp.skillDesc;
            m_pViewUI.txt_name.text = passiveSkillUp.skillname;

        }

        if( m_pSkillData ){
            m_pViewUI.txt_lv.text = String( m_pSkillData.skillLevel );
            m_pViewUI.txt_LvB.text =  String( m_pSkillData.skillLevel );
            m_pViewUI.txt_LvA.text =  String( m_pSkillData.skillLevel + 1);
            m_pViewUI.txt_gold.text = "";
            _onskillPointUpdateHandler();
            _onGoldConsumeHandler();
            _onLvMaxHandler();
        }else{
            m_pViewUI.txt_lv.text = String( 0 );
        }
        _onskillPointUpdateHandler();

    }

    private function _onskillPointUpdateHandler():void{
        if(m_pViewUI)
            m_pViewUI.txt_skillPoint.text = String( _playerData.skillData.skillPoint );
    }

    private function _onGoldConsumeHandler():void{
        if( null == m_pSkillData )
                return;
        var pTable : IDataTable;
        pTable  = _databaseSystem.getTable( KOFTableConstants.SKILL_UP_CONSUME );
        var skillUpConsume : SkillUpConsume = pTable.findByPrimaryKey( m_pSkillData.skillLevel );
        pTable  = _databaseSystem.getTable( KOFTableConstants.SKILL_POSITION_RATE );
        var skillPositionRate : SkillPositionRate = pTable.findByPrimaryKey( m_pSkillData.skillPosition );
        pTable  = _databaseSystem.getTable( KOFTableConstants.SKILL_QUALITY_RATE );
        var skillQualityRate : SkillQualityRate = pTable.findByPrimaryKey( m_pData.qualityBase );

        _needGold = Math.floor( skillUpConsume.goldConsumeNum * (skillPositionRate.goldConsumeRate / 10000 ) * (skillQualityRate.goldConsumeRate / 10000 ) );
//        _needGold = Math.ceil( skillUpConsume.goldConsumeNum * (skillPositionRate.goldConsumeRate / 10000 ) * (skillQualityRate.goldConsumeRate / 10000 ) );
        _needSkillPoint = Math.ceil( skillUpConsume.skillConsumeNum * (skillPositionRate.skillConsumeRate / 10000 ) * (skillQualityRate.skillConsumeRate / 10000 ) );

        var color : String ;
        _playerData.currency.gold < _needGold ? color = '#ff0000' : color = '#ff00';
        m_pViewUI.txt_gold.text =  "<font color='" + color + "'>" + _needGold + "</font>";

        _playerData.skillData.skillPoint < _needSkillPoint ? color = '#ff0000' : color = '#ff00';
        m_pViewUI.txt_needSkillPoint.text =  "<font color='" + color + "'>" + _needSkillPoint + "</font>";

    }


    private function _onLvMaxHandler():void{
        var lvMax : Boolean = m_pSkillData.skillLevel >= CSkillUpConst.SKILL_LEVEL_MAX ;
        m_pViewUI.box_gold.visible = !lvMax;
        m_pViewUI.box_needSkillPoint.visible = !lvMax;
        m_pViewUI.txt_max.visible = lvMax;
        m_pViewUI.box_effUp1.visible = !lvMax;
        m_pViewUI.box_effUp2.visible = !lvMax;
        m_pViewUI.box_effUp3.visible = !lvMax;
        m_pViewUI.box_lvB.visible = !lvMax;
        m_pViewUI.box_skillPoint.visible = !lvMax;
        m_pViewUI.btn_up.visible = !lvMax;
        m_pViewUI.btn_topUp.visible = !lvMax;
    }

    private function _onPlayerDataHandler(e:CPlayerEvent):void{
        _onskillPointUpdateHandler();
        _onGoldConsumeHandler();
    }

    private function _onEnterFrame( delta : Number ) : void {
        if( !m_pViewUI )
            return;
        if ( CTime.getCurrServerTimestamp()  < _playerData.skillData.remainTimeGetNexSkillPoint ) {
            var timeSub:int = _playerData.skillData.remainTimeGetNexSkillPoint - CTime.getCurrServerTimestamp();
            if( _playerData.skillData.skillPoint <= 0 ){
                m_pViewUI.txt_skillPoint.text =  CTime.toDurTimeString(timeSub) + '后获得1点体能点';
            }else{
                m_pViewUI.txt_skillPoint.text = _playerData.skillData.skillPoint + ' (' + CTime.toDurTimeString(timeSub) + ')';
            }

        } else {
            m_pViewUI.txt_skillPoint.text = _playerData.skillData.skillPoint + ' ( 点数已满 )';
        }
        m_pViewUI.btn_add.x = m_pViewUI.box_skillPoint.x + m_pViewUI.txt_skillPointT.textField.textWidth +
                m_pViewUI.txt_skillPoint.textField.textWidth + 35;
    }
    private function onBuySkillHandler():void{
        var pTable : IDataTable;

        var skillTimes : int;
        pTable  = _databaseSystem.getTable( KOFTableConstants.BREACH_LV_CONST );
        var breachLvConst : BreachLvConst = pTable.findByPrimaryKey(1);
        skillTimes += breachLvConst.skillTimes;

        pTable  = _databaseSystem.getTable( KOFTableConstants.VIPPRIVILEGE );
        var vipPrivilege : VipPrivilege = pTable.findByPrimaryKey( _playerData.vipData.vipLv );
        skillTimes += vipPrivilege.buySkillPointLimit;

        if( _playerData.skillData.buySkillPointCount >= skillTimes ){
            _pUISystem.showMsgBox( "您今天的购买次数已用完，升级vip可增加购买次数" ,openPAY);
            function openPAY():void{
                var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
                var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.PAY));
                bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);
            }
            return;
        }

        pTable  = _databaseSystem.getTable( KOFTableConstants.SKILLBUY );
        var skillBuy : SkillBuy = pTable.findByPrimaryKey( _playerData.skillData.buySkillPointCount + 1 );
            if( !skillBuy )
                return;

        _pUISystem.showMsgBox( '需要消耗' + skillBuy.costPurpleDiamondNum + '绑钻，确定继续吗？',okFun,null,true,null,null,true,"COST_BIND_D" );
        function okFun():void{
            (system.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem).showCostBdDiamondMsgBox( skillBuy.costPurpleDiamondNum, buySkill );
        }
        function buySkill():void{
            var skillUpHandler : CSkillUpHandler = _playerSystem.getBean( CSkillUpHandler ) as CSkillUpHandler;
            skillUpHandler.onBuySkillPointRequest();
        }

    }
    private function onSkillUpHandler():void{
        if( null == m_pSkillData ){
            _pUISystem.showMsgAlert('很抱歉，该技能未解锁');
            return;
        }
        if(  _playerData.currency.gold < _needGold ){
            _pUISystem.showMsgAlert('很抱歉，您的金币不足');

            var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as
                    ISystemBundleContext;
            if ( pSystemBundleCtx ) {
                var pSystemBundle : ISystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.BUY_MONEY ) );
                if ( pSystemBundle ) {
                    pSystemBundleCtx.setUserData( pSystemBundle, "activated", true );
                }
            }

            return;
        }

        if( _playerData.skillData.skillPoint < _needSkillPoint ){
            _pUISystem.showMsgAlert('很抱歉，您的体能点不足');
            return;
        }
        if( m_pData.level <= m_pSkillData.skillLevel ){
            _pUISystem.showMsgAlert('很抱歉，招式等级不能大于格斗家等级');
            return;
        }
        var skillUpHandler : CSkillUpHandler = _playerSystem.getBean( CSkillUpHandler ) as CSkillUpHandler;
        skillUpHandler.onSkillUpgrateRequest(m_pData.ID , _skillID );
    }
    private function onTopUpHandler():void{
        if( null == m_pSkillData ){
            _pUISystem.showMsgAlert('很抱歉，该技能未解锁');
            return;
        }
        if( _playerData.skillData.skillPoint <= 0 ){
            _pUISystem.showMsgAlert('很抱歉，您的体能点不足');
            return;
        }
        var skillUpHandler : CSkillUpHandler = _playerSystem.getBean( CSkillUpHandler ) as CSkillUpHandler;
        skillUpHandler.onOneKeyUpgrateSkillRequest( m_pData.ID , _skillID );
    }
    public function set view(value:SkillLvUpViewUI):void
    {
        m_pViewUI = value;
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
    private function onSkillTagHandler():void{
        (_playerSystem.getBean( CSkillTagViewHandler ) as CSkillTagViewHandler ).addDisplay();
    }
    public function addListeners():void
    {
        _playerSystem.addEventListener( CPlayerEvent.PLAYER_ORIGIN_CURRENCY ,_onPlayerDataHandler );
        _playerSystem.addEventListener( CPlayerEvent.SKILL_DATA ,_onPlayerDataHandler );
        _playerSystem.addEventListener( CPlayerEvent.SKILL_LVUP ,_onPlayerDataHandler );
        _playerSystem.addEventListener( CPlayerEvent.SKILL_POINT ,_onPlayerDataHandler );
        _playerSystem.addEventListener( CPlayerEvent.SKILL_ADD ,_onPlayerDataHandler );
        _playerSystem.addEventListener( CPlayerEvent.PLAYER_SKILL ,_onPlayerDataHandler );

        schedule( 0.3, _onEnterFrame );
    }

    public function removeListeners():void
    {
        _playerSystem.removeEventListener( CPlayerEvent.PLAYER_ORIGIN_CURRENCY ,_onPlayerDataHandler );
        _playerSystem.removeEventListener( CPlayerEvent.SKILL_DATA ,_onPlayerDataHandler );
        _playerSystem.removeEventListener( CPlayerEvent.SKILL_LVUP ,_onPlayerDataHandler );
        _playerSystem.removeEventListener( CPlayerEvent.SKILL_POINT ,_onPlayerDataHandler );
        _playerSystem.removeEventListener( CPlayerEvent.SKILL_ADD ,_onPlayerDataHandler );
        _playerSystem.removeEventListener( CPlayerEvent.PLAYER_SKILL ,_onPlayerDataHandler );

        unschedule( _onEnterFrame );
    }

    public function initView():void
    {
    }
    public function set data(value:*):void
    {
        m_pData = value as CPlayerHeroData;
    }

    private function get _databaseSystem():CDatabaseSystem {
        return  ( uiCanvas as CAppSystem ).stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }
    private function get _pUISystem() : CUISystem {
        return ( uiCanvas as CAppSystem ).stage.getSystem( CUISystem ) as CUISystem;
    }
    private function get _playerSystem() : CPlayerSystem {
        return ( uiCanvas as CAppSystem ).stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }
    private function get _playerData() : CPlayerData {
        return ( _playerSystem.getBean( CPlayerManager ) as CPlayerManager ).playerData;
    }

}
}
