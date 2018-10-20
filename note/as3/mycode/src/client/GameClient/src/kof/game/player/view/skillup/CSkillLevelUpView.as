//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/3/17.
 */
package kof.game.player.view.skillup {

import QFLib.Foundation.CTime;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.framework.IDataTable;
import kof.game.common.view.CChildView;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.data.CSkillData;
import kof.game.player.enum.EPlayerWndTabType;
import kof.game.player.event.CPlayerEvent;
import kof.table.PassiveSkillPro;
import kof.table.SkillBuy;
import kof.table.SkillPositionRate;
import kof.table.SkillQualityRate;
import kof.table.SkillUpConsume;
import kof.ui.CUISystem;

import morn.core.handlers.Handler;

public class CSkillLevelUpView extends CChildView {

    private var m_levelUp : Object;

    private var _playerHeroData : CPlayerHeroData;

    private var _skillData : CSkillData;

    private var _skillID : int;

    private var _needGold : int;

    private var _needSkillPoint : int;

    public function CSkillLevelUpView( ) {
        super( );
    }

    protected override function _onCreate() : void {
        // can not call super._onCreate in this class
        this.setNoneData();
    }
    protected override function _onDispose() : void {
        // can not call super._onDispose in this class
    }
    protected override function _onShow():void {
        // can not call super._onShow in this class
        this.listEnterFrameEvent = true;

        _playerSystem.addEventListener( CPlayerEvent.SKILL_POINT ,_onPlayerDataHandler );
    }
    protected override function _onHide() : void {
        // can not call super._onHide in this class

        _playerSystem.removeEventListener( CPlayerEvent.SKILL_POINT ,_onPlayerDataHandler );
    }

    public virtual override function updateWindow() : Boolean {
        super.updateWindow();

        //
        _data[0]
        _playerHeroData = _data[1] as CPlayerHeroData;
        m_levelUp = _ui.view_up;

        m_levelUp.btn_add.clickHandler = new Handler( onBuySkillHandler );
        m_levelUp.btn_up.clickHandler = new Handler( onSkillUpHandler );
        m_levelUp.btn_topUp.clickHandler = new Handler( onTopUpHandler );


        m_levelUp.box_effect_txt.visible = false;//todo 策划叫暂时隐藏

        return true;
    }
    public function updateView( skillData : CSkillData ):void{
        _skillData = skillData;
        var pTable : IDataTable;
        var lvMax : Boolean = _skillData.skillLevel >= CSkillUpConst.SKILL_LEVEL_MAX ;
        if( _skillData.pSkill && _skillData.activeSkillUp ){
            _skillID = _skillData.pSkill.ID;
            m_levelUp.txt_name.text = _skillData.pSkill.Name;
            m_levelUp.txt_type.text = CSkillUpConst.ACTIVE_SKILL_TYPE_ARY[ _skillData.pSkill.SkillType ];
            m_levelUp.txt_cd.text =  _skillData.activeSkillUp.CD  + "s";
            m_levelUp.txt_consume.text = String( _skillData.activeSkillUp.consumeAP1 + _skillData.activeSkillUp.consumeAP2 + _skillData.activeSkillUp.consumeAP3 );
            m_levelUp.txt_desc.text = _skillData.pSkill.Description;
            m_levelUp.txt_effect.text = _skillData.activeSkillUp.desc;

            m_levelUp.txt_vValueB.text = String( _skillData.activeSkillUp.damageCount + _skillData.activeSkillUp.hitTimes * _skillData.skillLevel * _skillData.activeSkillUp.effectPar1 );
            if( !lvMax )
                m_levelUp.txt_vValueA.text = String( _skillData.activeSkillUp.damageCount + _skillData.activeSkillUp.hitTimes * ( _skillData.skillLevel + 1 ) * _skillData.activeSkillUp.effectPar1)
                        + '(+ ' + _skillData.activeSkillUp.hitTimes *  _skillData.activeSkillUp.effectPar1 + ')';
            m_levelUp.txt_pValueB.text = Math.ceil( ( _skillData.activeSkillUp.perDamageCount +  _skillData.skillLevel * ( _skillData.activeSkillUp.effectPar2 / 10000 ) ) * 100 ) + '%';
            if( !lvMax )
                m_levelUp.txt_pValueA.text = Math.ceil( (_skillData.activeSkillUp.perDamageCount +  (_skillData.skillLevel + 1) * ( _skillData.activeSkillUp.effectPar2 / 10000 ) ) * 100 ) + '%'
                        + '(+ ' + Math.ceil( (  _skillData.activeSkillUp.effectPar2 / 10000 ) * 100 ) + '%' + ')';

            if( _skillData.activeSkillUp.effectType == CSkillUpConst.ACTIVE_SKILL_DAMAGE ){
                m_levelUp.txt_vName.text = CSkillUpConst.ACTIVE_SKILL_DAMAGE_TYPE_ARY[0];
                m_levelUp.txt_pName.text = CSkillUpConst.ACTIVE_SKILL_DAMAGE_TYPE_ARY[1];
            }else if(_skillData.activeSkillUp.effectType == CSkillUpConst.ACTIVE_SKILL_HEALING ){
                m_levelUp.txt_vName.text = CSkillUpConst.ACTIVE_SKILL_HEALING_TYPE_ARY[0];
                m_levelUp.txt_pName.text = CSkillUpConst.ACTIVE_SKILL_HEALING_TYPE_ARY[1];
            }

            m_levelUp.box_cd.visible =
                    m_levelUp.box_consume.visible = true;

        }else if( _skillData.passiveSkillUp ){
            _skillID = _skillData.passiveSkillUp.ID;
            m_levelUp.txt_name.text = _skillData.passiveSkillUp.skillname;
            m_levelUp.txt_type.text = CSkillUpConst.PASSIVE_SKILL_TYPE_ARY[ _skillData.passiveSkillUp.effectType - 1];
            m_levelUp.txt_effect.text = _skillData.passiveSkillUp.skillUpDesc;
            m_levelUp.txt_desc.text = _skillData.passiveSkillUp.skillDesc;
            pTable  = _databaseSystem.getTable( KOFTableConstants.PASSIVE_SKILL_PRO );
            var passiveSkillPro : PassiveSkillPro = pTable.findByPrimaryKey( _skillData.passiveSkillUp.effectType );

            m_levelUp.txt_vName.text = passiveSkillPro.name;
            m_levelUp.txt_vValueB.text = String( _skillData.passiveSkillUp.effectPar1 + (_skillData.skillLevel - 1) * _skillData.passiveSkillUp.skillUpEffectPar1 );
            if( !lvMax )
                m_levelUp.txt_vValueA.text = String( _skillData.passiveSkillUp.effectPar1 + _skillData.skillLevel * _skillData.passiveSkillUp.skillUpEffectPar1 )
                        + '(+ ' + _skillData.passiveSkillUp.skillUpEffectPar1 + ')';

            if( _skillData.passiveSkillUp.effectPar2 > 0 ){
                m_levelUp.txt_pName.text = passiveSkillPro.name + CSkillUpConst.PASSIVE_SKILL_EFF_TYPE2;
                m_levelUp.txt_pValueB.text = int((( _skillData.passiveSkillUp.effectPar1 + (_skillData.skillLevel - 1) * _skillData.passiveSkillUp.skillUpEffectPar1 )/ 10000 ) * 100 ) + '%';
                if( !lvMax )
                    m_levelUp.txt_pValueA.text = int((( _skillData.passiveSkillUp.effectPar1 + _skillData.skillLevel * _skillData.passiveSkillUp.skillUpEffectPar1 )/ 10000 ) * 100 ) + '%'
                            + '(+ ' + int((  _skillData.passiveSkillUp.skillUpEffectPar1 / 10000 ) * 100 ) + '%' + ')';;
            }

            m_levelUp.box_eff2.visible = _skillData.passiveSkillUp.effectPar2 > 0;

            m_levelUp.box_cd.visible =
                    m_levelUp.box_consume.visible = false;
        }

        m_levelUp.txt_lv.text = String( _skillData.skillLevel );
        m_levelUp.txt_gold.text = "";
        _onskillPointUpdateHandler();
        _onGoldConsumeHandler();
        _onLvMaxHandler();
    }

    private function _onPlayerDataHandler(e:CPlayerEvent):void{
        _onskillPointUpdateHandler();
    }
    protected override function _onEnterFrame(delta:Number) : void {
        if( !m_levelUp )
                return;
        if ( CTime.getCurrServerTimestamp()  < _playerData.skillData.remainTimeGetNexSkillPoint ) {
            var timeSub:int = _playerData.skillData.remainTimeGetNexSkillPoint - CTime.getCurrServerTimestamp();
            if( _playerData.skillData.skillPoint <= 0 ){
                m_levelUp.txt_skillPoint.text =  CTime.toDurTimeString(timeSub) + '后获得1点招式点';
                if( !m_levelUp.btn_add.visible )
                    m_levelUp.btn_add.visible = true;
                m_levelUp.btn_add.x = m_levelUp.box_skillPoint.x + m_levelUp.txt_skillPointT.textField.textWidth +
                        m_levelUp.txt_skillPoint.textField.textWidth + 10;

            }else{
                m_levelUp.txt_skillPoint.text = _playerData.skillData.skillPoint + ' (' + CTime.toDurTimeString(timeSub) + ')';
                if( m_levelUp.btn_add.visible )
                    m_levelUp.btn_add.visible = false;
            }

        } else {
            m_levelUp.txt_skillPoint.text = _playerData.skillData.skillPoint + ' ( 点数已满 )';
            if( m_levelUp.btn_add.visible )
                m_levelUp.btn_add.visible = false;
        }
    }
    private function _onskillPointUpdateHandler():void{
        if(m_levelUp)
            m_levelUp.txt_skillPoint.text = String( _playerData.skillData.skillPoint );
    }
    private function _onGoldConsumeHandler():void{
        var pTable : IDataTable;
        pTable  = _databaseSystem.getTable( KOFTableConstants.SKILL_UP_CONSUME );
        var skillUpConsume : SkillUpConsume = pTable.findByPrimaryKey( _skillData.skillLevel );
        pTable  = _databaseSystem.getTable( KOFTableConstants.SKILL_POSITION_RATE );
        var skillPositionRate : SkillPositionRate = pTable.findByPrimaryKey( _skillData.skillPosition );
        pTable  = _databaseSystem.getTable( KOFTableConstants.SKILL_QUALITY_RATE );
        var skillQualityRate : SkillQualityRate = pTable.findByPrimaryKey( _playerHeroData.qualityBase );

        _needGold = Math.ceil( skillUpConsume.goldConsumeNum * (skillPositionRate.goldConsumeRate / 10000 ) * (skillQualityRate.goldConsumeRate / 10000 ) );
        _needSkillPoint = Math.ceil( skillUpConsume.skillConsumeNum * (skillPositionRate.skillConsumeRate / 10000 ) * (skillQualityRate.skillConsumeRate / 10000 ) );

        var color : String ;
        _playerData.currency.gold < _needGold ? color = '#ff0000' : color = '#ff00';
        m_levelUp.txt_gold.text =  "<font color='" + color + "'>" + _needGold + "</font>";
        m_levelUp.txt_gold.text
    }

    private function _onLvMaxHandler():void{
        var lvMax : Boolean = _skillData.skillLevel >= CSkillUpConst.SKILL_LEVEL_MAX ;
        lvMax ? m_levelUp.txt_upTitle.text = "最终效果：" : m_levelUp.txt_upTitle.text = "升级效果：";
        m_levelUp.txt_max.visible = lvMax;
        m_levelUp.box_effUp1.visible = !lvMax;
        m_levelUp.box_effUp2.visible = !lvMax;
        m_levelUp.box_gold.visible = !lvMax;
        m_levelUp.box_skillPoint.visible = !lvMax;
//        m_levelUp.btn_add.visible = !lvMax;//这个不需要，否则会闪一下
        m_levelUp.btn_up.visible = !lvMax;
        m_levelUp.btn_topUp.visible = !lvMax;
        m_levelUp.img_line.visible = !lvMax;

    }

    private function onBuySkillHandler():void{
        var pTable : IDataTable;
        pTable  = _databaseSystem.getTable( KOFTableConstants.SKILLBUY );
        var skillBuy : SkillBuy = pTable.findByPrimaryKey( 2 );

        ((uiCanvas as CAppSystem).stage.getSystem( CUISystem ) as CUISystem).showMsgBox("确定要花费" + skillBuy.costPurpleDiamondNum + "紫钻购买招式点吗？",function buySkill():void{
            var skillUpHandler : CSkillUpHandler = _playerSystem.getBean( CSkillUpHandler ) as CSkillUpHandler;
            skillUpHandler.onBuySkillPointRequest();
        });
    }
    private function onSkillUpHandler():void{
        if(  _playerData.currency.gold < _needGold ){
            ((uiCanvas as CAppSystem).stage.getSystem( CUISystem ) as CUISystem).showMsgAlert('很抱歉，您的金币不足');
            return;
        }

        if( _playerData.skillData.skillPoint < _needSkillPoint ){
            ((uiCanvas as CAppSystem).stage.getSystem( CUISystem ) as CUISystem).showMsgAlert('很抱歉，您的招式点不足');
            return;
        }
        if( _playerHeroData.level <= _skillData.skillLevel ){
            ((uiCanvas as CAppSystem).stage.getSystem( CUISystem ) as CUISystem).showMsgAlert('很抱歉，技能等级不能大于格斗家等级');
            return;
        }
        var skillUpHandler : CSkillUpHandler = _playerSystem.getBean( CSkillUpHandler ) as CSkillUpHandler;
        skillUpHandler.onSkillUpgrateRequest(_playerHeroData.ID , _skillID );
    }
    private function onTopUpHandler():void{
        if( _playerData.skillData.skillPoint <= 0 ){
            ((uiCanvas as CAppSystem).stage.getSystem( CUISystem ) as CUISystem).showMsgAlert('很抱歉，您的招式点不足');
            return;
        }
        var skillUpHandler : CSkillUpHandler = _playerSystem.getBean( CSkillUpHandler ) as CSkillUpHandler;
        skillUpHandler.onOneKeyUpgrateSkillRequest( _playerHeroData.ID , _skillID );
    }
    private function get _ui() : Object{
        return (rootUI as Object).viewStack.items[EPlayerWndTabType.STACK_ID_HERO_SKILL_UP] as Object
    }

    private function get _playerSystem() : CPlayerSystem {
        return ( uiCanvas as CAppSystem ).stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }
    private function get _playerData() : CPlayerData {
        return ( _playerSystem.getBean( CPlayerManager ) as CPlayerManager ).playerData;
    }
    private function get _skillUpHandler() : CSkillUpHandler {
        return  _playerSystem.getBean(CSkillUpHandler) as CSkillUpHandler;
    }
    private function get _databaseSystem():CDatabaseSystem {
        return  ( uiCanvas as CAppSystem ).stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }
}
}
