//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2016/5/26.
 * 技能信息
 */
package kof.game.fightui.compoment {

import QFLib.Foundation.CMap;

import com.greensock.TimelineLite;
import com.greensock.TweenLite;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.utils.Dictionary;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.character.CFacadeMediator;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.fight.skill.CSkillDataBase;
import kof.game.character.fight.skill.CSkillUtil;
import kof.game.character.fight.skillcalc.CFightCalc;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.character.property.interfaces.ICharacterProperty;
import kof.game.character.state.CCharacterInput;
import kof.game.common.view.CChildView;
import kof.game.core.CGameObject;
import kof.game.gameSetting.CGameSettingSystem;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.enum.EInstanceType;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CSkillData;
import kof.table.ActiveSkillUp;
import kof.table.PlayerSkill;
import kof.table.Skill;
import kof.ui.demo.FightUI;
import kof.ui.demo.SkillItemIIUI;
import kof.ui.demo.SkillItemUI;

import morn.core.components.Component;
import morn.core.components.FrameClip;
import morn.core.components.Image;
import morn.core.components.View;
import morn.core.events.UIEvent;
import morn.core.handlers.Handler;

public class CSkillViewHandler extends CChildView {

    private var m_fightUI:FightUI;
//    private static const KEY_ARY:Array = ["J","K","U","I","O","L"];
    private static const KEY_ARY:Array = ["J","U","I","O","L","SPACE"];
    private static const PERFECTNUM:uint = 360;
    private var _itemDic:Dictionary;
    private var _hero:CGameObject;
    private var _pCharacterMediator : CCharacterFightTriggle;

    private static const ITEM_L : int = 999;

    private var SKILL_ITEM_J : SkillItemUI;
    private var SKILL_ITEM_U : SkillItemUI;
    private var SKILL_ITEM_I : SkillItemUI;
    private var SKILL_ITEM_O : SkillItemUI;
    private var SKILL_ITEM_L : SkillItemUI;
    private var SKILL_ITEM_SPACE : SkillItemIIUI;

    private var _config:Object ;


    private var SKILL_DIC : Dictionary;

    private var _useSkillEnable : Boolean = true ;//不能点击使用技能

    private var _enerey : Number;

    public function CSkillViewHandler( $fightUI:FightUI = null ) {
        super();
        if($fightUI)
            m_fightUI = $fightUI;
        _itemDic = new Dictionary();
        m_fightUI.spcicalSkill.mc_fire_1.visible =
                m_fightUI.spcicalSkill.mc_fire_2.visible = false;
        //todo 美术素材
        m_fightUI.img_att_red.alpha =
                m_fightUI.info_left.img_def_red.alpha = 0;
//                        m_fightUI.img_energy_red.alpha = 0;

        SKILL_DIC = new Dictionary();
        _config = {J:true,U:true,I:true,O:true,L:true,SPACE:true};
    }
    public function updateSkillData(hero:CGameObject):void {
        if(!m_fightUI ||  !hero)
            return;
        hideView();
        _hero = hero;
        var pDB : IDatabase = system.stage.getSystem( IDatabase ) as IDatabase;
        var pTablePlayerSkil : IDataTable = pDB.getTable( KOFTableConstants.PLAYER_SKILL );
        var pPlayerSkill : PlayerSkill = pTablePlayerSkil.findByPrimaryKey( hero.data.prototypeID );

        normalSkill(pPlayerSkill);
        spcicalSkill(pPlayerSkill.SkillID[5]);
//        passiveSkill(pPlayerSkill.SkillID[7],pPlayerSkill.SkillID[8],pPlayerSkill.SkillID[9]);

        if( _pCharacterMediator && _pCharacterMediator.owner && _pCharacterMediator.owner.isRunning ){
//            _pCharacterMediator.removeEventListener(CFightTriggleEvent.SKILL_CHAIN_PASS_EVALUATION ,_onSkillChain);
//            _pCharacterMediator.removeEventListener(CFightTriggleEvent.SKILL_CHAIN_OUTDATE,_onSkillChain );
            _pCharacterMediator.removeEventListener(CFightTriggleEvent.SPELL_SKILL_BEGIN ,_onSkillBegin);
            _pCharacterMediator.removeEventListener(CFightTriggleEvent.SPELL_SKILL_END ,_onSkillEnd);
            _pCharacterMediator.removeEventListener(CFightTriggleEvent.EVT_PLAYER_DRIVECANCEL,_onResetToMainSkill );
            _pCharacterMediator.removeEventListener(CFightTriggleEvent.SKILL_BE_INTERRUPTED,_onResetToMainSkill );
            _pCharacterMediator.removeEventListener(CFightTriggleEvent.EVT_PLAYER_PUCANCEL,_onResetToMainSkill );
            _pCharacterMediator.removeEventListener(CFightTriggleEvent.EVT_PLAYER_SUPERCANCEL,_onResetToMainSkill );
            _pCharacterMediator.removeEventListener(CFightTriggleEvent.RESPONSE_ROLL_BACK,_onResetToMainSkill );

            _pCharacterMediator.removeEventListener(CFightTriggleEvent.EVT_NOT_ENOUGHT_AP,_onNotEnought );
            _pCharacterMediator.removeEventListener(CFightTriggleEvent.EVT_NOT_ENOUGHT_DP,_onNotEnought );
            _pCharacterMediator.removeEventListener(CFightTriggleEvent.EVT_NOT_ENOUGHT_RP,_onNotEnought );
            _pCharacterMediator.removeEventListener(CFightTriggleEvent.EVT_NOT_ENOUGHT_CD,_onNotEnought );

        }
        _pCharacterMediator = hero.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
//        _pCharacterMediator.addEventListener(CFightTriggleEvent.SKILL_CHAIN_PASS_EVALUATION,_onSkillChain, false, 0, true );
//        _pCharacterMediator.addEventListener(CFightTriggleEvent.SKILL_CHAIN_OUTDATE,_onSkillChain, false, 0, true );
        _pCharacterMediator.addEventListener(CFightTriggleEvent.SPELL_SKILL_BEGIN,_onSkillBegin, false, 0, true );
        _pCharacterMediator.addEventListener(CFightTriggleEvent.SPELL_SKILL_END,_onSkillEnd, false, 0, true );
        _pCharacterMediator.addEventListener(CFightTriggleEvent.EVT_PLAYER_DRIVECANCEL,_onResetToMainSkill, false, 0, true );//技能取消
        _pCharacterMediator.addEventListener(CFightTriggleEvent.SKILL_BE_INTERRUPTED,_onResetToMainSkill, false, 0, true );//技能被打断
        _pCharacterMediator.addEventListener(CFightTriggleEvent.EVT_PLAYER_PUCANCEL,_onResetToMainSkill, false, 0, true );//普攻被取消
        _pCharacterMediator.addEventListener(CFightTriggleEvent.EVT_PLAYER_SUPERCANCEL,_onResetToMainSkill, false, 0, true );
        _pCharacterMediator.addEventListener(CFightTriggleEvent.RESPONSE_ROLL_BACK,_onResetToMainSkill, false, 0, true );

        _pCharacterMediator.addEventListener(CFightTriggleEvent.EVT_NOT_ENOUGHT_AP,_onNotEnought, false, 0, true );//攻击值不够
        _pCharacterMediator.addEventListener(CFightTriggleEvent.EVT_NOT_ENOUGHT_DP,_onNotEnought, false, 0, true );//防御值不够
        _pCharacterMediator.addEventListener(CFightTriggleEvent.EVT_NOT_ENOUGHT_RP,_onNotEnought, false, 0, true );//怒气值不够
        _pCharacterMediator.addEventListener(CFightTriggleEvent.EVT_NOT_ENOUGHT_CD,_onNotEnought, false, 0, true );//冷却中


    }

    public function setPlayerEnerey( enerey : Number ):void{
        _enerey = enerey;
    }
    //////////////////////////////////////////////    maskimg  技能的CD  要有透明度
    //////////////////////////////////////////////    maskimgH  闪避CD   要有透明度
    //////////////////////////////////////////////    maskimgII 技能图标  不要有透明度

    public function update(delta:Number):void {
        if( !m_fightUI || !m_fightUI.parent || !_hero)
            return;

        var pfightCal : CFightCalc = _hero.getComponentByClass( CFightCalc , true ) as CFightCalc;
        if(!pfightCal)return;
        var pSkillCDMap : CMap = pfightCal.fightCDCalc.skillCDPool;
        var pSkillItemUI : SkillItemUI;
        var skillData : CSkillData;
        for each(  pSkillItemUI in _itemDic ){
            if( pSkillItemUI.mask_en.visible )
                pSkillItemUI.mask_en.visible = false;
            skillData = pSkillItemUI.mask_en.dataSource as CSkillData;
            if( skillData && ( skillData.skillPosition == 2 || skillData.skillPosition == 3 || skillData.skillPosition == 4 ) ){
                if( skillData.activeSkillUp.consumeAP1 + skillData.activeSkillUp.consumeAP2 + skillData.activeSkillUp.consumeAP3 > _enerey ){
                    pSkillItemUI.mask_en.visible = true;
                }
            }
            if( pSkillItemUI.maskimg.visible )
                pSkillItemUI.maskimg.visible = false;
            if( pSkillItemUI.maskimgII.visible )
                pSkillItemUI.maskimgII.visible = false;
            if( pSkillItemUI.maskimgH.visible )
                pSkillItemUI.maskimgH.visible = false;
        }
        for( var key :int in  pSkillCDMap){
            _onCDHandler( key, pSkillCDMap[key]);
        }

    }
    private function _onCDHandler( id :int ,remainCD : Number ):void{

        var pSkillItemUI:SkillItemUI ;
        if( id == CSkillDataBase.SKILL_ID_DODGE_SIM || id == CSkillDataBase.SKILL_ID_QUICKSTAND_SIM ){
            pSkillItemUI = _itemDic[ITEM_L] as SkillItemUI;
        }else{
            pSkillItemUI = _itemDic[id] as SkillItemUI;
        }
        if(!pSkillItemUI || !pSkillItemUI.visible )return;
        if( id == CSkillDataBase.SKILL_ID_DODGE_SIM ){
            cdEffect( pSkillItemUI , ( _hero.data.property.rollCD + 1500.0 )  / 1000 , remainCD );
        }else if(id == CSkillDataBase.SKILL_ID_QUICKSTAND_SIM ){
            cdEffectII( pSkillItemUI , ( _hero.data.property.quickStandCD+ 1500.0)  / 1000, remainCD );
        }else{
            var skill : Skill = _pTable.findByPrimaryKey(id);
            cdEffect( pSkillItemUI,skill.CD , remainCD );
        }

    }
    //同一栏位技能跳转换图标
    private function _onSkillChain(evt:CFightTriggleEvent):void{
        var pSkillItemUI:SkillItemUI = _itemDic[evt.parmList[0]] as SkillItemUI;
        if(!pSkillItemUI)
            return;
        pSkillItemUI.dataSource = evt.parmList[1];
        var pDB : IDatabase = system.stage.getSystem( IDatabase ) as IDatabase;
        var pTableSkil : IDataTable = pDB.getTable( KOFTableConstants.SKILL );
        var pSkill : Skill = pTableSkil.findByPrimaryKey( pSkillItemUI.dataSource);
        if(pSkill){
            pSkillItemUI.img.url = CPlayerPath.getSkillBigIcon( pSkill.IconName );
        }
        if(pSkillItemUI.dataSource > 0)
            _itemDic[pSkillItemUI.dataSource] = pSkillItemUI;

    }
    //技能开始
    private function _onSkillBegin(evt:CFightTriggleEvent):void{

        var skillID : int = evt.parmList[0];
        var rootSkillID : int = CSkillUtil.getMainSkill( skillID );
        var pSkillItemUI:SkillItemUI = _itemDic[rootSkillID] as SkillItemUI;
        if(!pSkillItemUI)
            return;

        var pDB : IDatabase = system.stage.getSystem( IDatabase ) as IDatabase;
        var pTableSkil : IDataTable = pDB.getTable( KOFTableConstants.SKILL );
        var pSkill : Skill = pTableSkil.findByPrimaryKey( skillID );
        if(pSkill && pSkill.SuperScript > 0 ) {
            pSkillItemUI.imgTag.url = CPlayerPath.getSkillTagBigIcon( pSkill.SuperScript );
        }else{
            pSkillItemUI.imgTag.url = '';
        }
    }
    //技能结束
    private function _onSkillEnd(evt:CFightTriggleEvent):void {
        var skillID : int = evt.parmList[ 0 ];
        var rootSkillID : int = CSkillUtil.getMainSkill( skillID );
        var pSkillItemUI : SkillItemUI = _itemDic[ rootSkillID ] as SkillItemUI;
        if ( !pSkillItemUI )
            return;

        pSkillItemUI.imgTag.url = '';
    }

    //技能取消 ,技能打断，普攻取消  等，技能图标还原
    private function _onResetToMainSkill(evt:CFightTriggleEvent):void {
        var skillID : int = evt.parmList[ 0 ];
        var rootSkillID : int = CSkillUtil.getMainSkill( skillID );
        var pSkillItemUI : SkillItemUI = _itemDic[ rootSkillID ] as SkillItemUI;
        if ( !pSkillItemUI )
            return;

        pSkillItemUI.imgTag.url = '';
    }
    private function _onNotEnought( evt : CFightTriggleEvent ):void{
        var pSkillItemUI:SkillItemUI = _itemDic[evt.parmList[0]] as SkillItemUI;
        _onNotEnoughtEff( evt.type , pSkillItemUI);
        if( !pSkillItemUI || !pSkillItemUI.visible )
            return;
        if(pSkillItemUI.mc_prohibit.visible)
            return;
        pSkillItemUI.mc_prohibit.addEventListener(UIEvent.FRAME_CHANGED,onChanged);
        pSkillItemUI.mc_prohibit.gotoAndPlay(0);
        pSkillItemUI.mc_prohibit.visible = true;
        function onChanged():void{
            if(pSkillItemUI.mc_prohibit.frame >= pSkillItemUI.mc_prohibit.totalFrame -1) {
                pSkillItemUI.mc_prohibit.removeEventListener( UIEvent.FRAME_CHANGED, onChanged );
                pSkillItemUI.mc_prohibit.stop();
                pSkillItemUI.mc_prohibit.visible = false;
            }
        }
    }
    private function _onNotEnoughtEff( type : String ,pSkillItemUI:SkillItemUI ) : void {
        //todo 待美术补充UI
        if( type == CFightTriggleEvent.EVT_NOT_ENOUGHT_AP ){
            showNotenghtEff( m_fightUI.img_att_red ) ;
            showNotEnghtTips( 1 );
        } else if ( type == CFightTriggleEvent.EVT_NOT_ENOUGHT_DP ){
            showNotenghtEff( m_fightUI.info_left.img_def_red ) ;
        }else if( type == CFightTriggleEvent.EVT_NOT_ENOUGHT_RP  ){
//            showNotenghtEff( m_fightUI.img_energy_red );
            showNotEnghtTips( 2 );
        }else if( type == CFightTriggleEvent.EVT_NOT_ENOUGHT_CD ){
            if( pSkillItemUI ){
                var pSkillCaster : CSkillCaster = _hero.getComponentByClass( CSkillCaster ,true ) as CSkillCaster;
                if( pSkillCaster.isInSameMainSkill( int( pSkillItemUI.dataSource )) == false ){
                    showNotEnghtTips( 0 );
                }
            }

        }
    }
    private function cdEffect(pSkillItemUI:SkillItemUI, total : Number ,remainCD : Number):void{
//        trace( remainCD, "=============remainCD---",total,"----total")
        pSkillItemUI.maskimg.visible = true;
        var sector:Sector = pSkillItemUI.getChildByName('sector') as Sector;
        var completePercent:Number = remainCD / total;
        sector.init(0, 0, 49, -90,  completePercent * PERFECTNUM  ,0.5);
//        sector.init(0, 0, 49, -90, (1 - completePercent) * PERFECTNUM  ,0.5);
        pSkillItemUI.maskimg.mask = sector;
        if( completePercent < 1 )
            pSkillItemUI.imgTag.url = '';
    }
    //闪避和受身在同一个item，分别有不同的CD
    private function cdEffectII(pSkillItemUI:SkillItemUI, total : Number ,remainCD : Number):void{

        pSkillItemUI.maskimgH.visible = true;
        var sector:Sector = pSkillItemUI.getChildByName('sectorII') as Sector;
        var completePercent:Number = remainCD / total;
        sector.init(0, 0, 49, -90,  completePercent * PERFECTNUM  ,0.5);
//        sector.init(0, 0, 49, -90, (1 - completePercent) * PERFECTNUM  ,0.5);
        pSkillItemUI.maskimgH.mask = sector;
        if( completePercent< 1 )
            pSkillItemUI.imgTag.url = '';
    }

    private function normalSkill(pPlayerSkill : PlayerSkill):void{

        m_fightUI.list_skill.renderHandler = new Handler( renderSkill );
        var skillAry : Array = pPlayerSkill.SkillID.concat();
        skillAry.splice(1,1);
        m_fightUI.list_skill.dataSource = skillAry;
        m_fightUI.spcicalSkill.img.addEventListener(MouseEvent.CLICK, _onSpcicalSkill);
        m_fightUI.list_skill.mouseHandler = new Handler( listSkillSelectHandler );
    }
    private function listSkillSelectHandler( evt:Event,idx : int ) : void {
        if(evt.type == MouseEvent.CLICK){
            if( idx < 4 ){
                if( idx > 0)
                    useSkill(idx + 1);//因为中间去掉了一L
                else
                    useSkill(idx);
            }else if( idx == 4 ){//闪避
                var pFacadeMediator : CFacadeMediator = _hero.getComponentByClass(CFacadeMediator, true) as CFacadeMediator;
                pFacadeMediator.dodgeSudden();
            }
        }
    }
    private function _onSpcicalSkill(evt:Event):void{
        if( !_hero )
                return;
        var property : ICharacterProperty = _hero.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty;
        if( !property )
                return;
        var maxValue:int = property.MaxRagePower/property.maxRageCount;
        var enNum:int = Math.floor(property.RagePower/maxValue);
        if(enNum <= 0 ){
//            showNotenghtEff( m_fightUI.img_energy_red );
            showNotEnghtTips( 2 );
            return;
        }
        useSkill(5);
    }

    private function useSkill(skillIdx : int ):void{
        if(!_hero)
            return;
        if( !_useSkillEnable )
                return;
        var input:CCharacterInput = _hero.getComponentByClass(CCharacterInput, true) as CCharacterInput;
        input.addSkillRequest(skillIdx);
    }

    private function renderSkill(item:Component, idx:int):void {
        if (!(item is SkillItemUI)) {
            return;
        }
        var sector:Sector;
        var pSkillItemUI:SkillItemUI = item as SkillItemUI;
//        pSkillItemUI.txt_key.text = KEY_ARY[idx];
        pSkillItemUI.txt_key.text = (system.stage.getSystem(CGameSettingSystem) as CGameSettingSystem).getSkillKeyNameByIndex(idx);
        pSkillItemUI.imgTag.url = '';

        if( idx == 0 )
            SKILL_DIC["J"] = SKILL_ITEM_J = pSkillItemUI;
        else if( idx == 1 )
            SKILL_DIC["U"] = SKILL_ITEM_U = pSkillItemUI;
        else if( idx == 2 )
            SKILL_DIC["I"] = SKILL_ITEM_I = pSkillItemUI;
        else if( idx == 3 )
            SKILL_DIC["O"] = SKILL_ITEM_O = pSkillItemUI;
        else if( idx == 4 )
            SKILL_DIC["L"] = SKILL_ITEM_L = pSkillItemUI;

            pSkillItemUI.visible = true && _config[KEY_ARY[idx]];

        if( idx == 4 ){//闪避
//            pSkillItemUI.img.url = CPlayerPath.getSkillBigIcon( 'skill_icon_roll' );
            pSkillItemUI.dataSource = ITEM_L;
            pSkillItemUI.maskimgII.visible = false;
            sector = new Sector();
            sector.name = 'sectorII';
            sector.visible = false;
            sector.alpha = 0.7;
            sector.scaleX = -1;
            sector.x = sector.y = 38;
            pSkillItemUI.addChild(sector);
//            pSkillItemUI.clip_SuperScript.visible = false;
            pSkillItemUI.box_dou.visible = true;

            pSkillItemUI.clip_zhi.index = 1;
            pSkillItemUI.clip_zhi.visible = true;


//            // XXX(Jeremy): 巅峰赛临时去除L键
//            var pInstanceSystem:CInstanceSystem = system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
//            if ( pInstanceSystem ) {
//                var isPeak:Boolean = EInstanceType.isPeakGame( pInstanceSystem.instanceType );
//                pSkillItemUI.visible = !isPeak;
//            }

        }else{
            var pDB : IDatabase = system.stage.getSystem( IDatabase ) as IDatabase;
            var pTableSkil : IDataTable = pDB.getTable( KOFTableConstants.SKILL );
            var pSkill : Skill = pTableSkil.findByPrimaryKey( pSkillItemUI.dataSource );
            if(pSkill){
                pSkillItemUI.img.url = CPlayerPath.getSkillBigIcon( pSkill.IconName );
//                pSkillItemUI.clip_SuperScript.visible = pSkill.SuperScript > 0 ;
//                if( pSkillItemUI.clip_SuperScript.visible )
//                    pSkillItemUI.clip_SuperScript.index = pSkill.SuperScript - 1;

                pSkillItemUI.clip_zhi.visible = idx == 0;
                pSkillItemUI.img.visible = idx != 0;
                if( pSkillItemUI.clip_zhi.visible )
                    pSkillItemUI.clip_zhi.index = 0;


            }
            pSkillItemUI.box_dou.visible = false;

            //tips
            if( idx == 0 ){//普攻
//                _playerData.
            }else{
                var skillData : CSkillData;
                var skillAry:Array;
                var pInstanceSystem:CInstanceSystem = system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
                if( pInstanceSystem && pInstanceSystem.instanceContent && pInstanceSystem.instanceContent.embattleHeroID[0] > 0 ){//专属副本，特殊处理
//                    skillAry = _playerData.heroList.createHero( _hero.data.prototypeID ).skillList.list;
                    skillData = new CSkillData;
                    var pTableI : IDataTable  ;
                    pTableI = _databaseSystem.getTable( KOFTableConstants.ACTIVE_SKILL_UP );
                    var activeSkillUpI : ActiveSkillUp = pTableI.findByPrimaryKey( pSkillItemUI.dataSource );
                    skillData.activeSkillUp = activeSkillUpI;
                    pTableI  = _databaseSystem.getTable( KOFTableConstants.SKILL );
                    var pSkillI : Skill = pTableI.findByPrimaryKey( pSkillItemUI.dataSource );
                    skillData.pSkill = pSkillI;
                    skillData.skillLevel = 1;
                    pSkillItemUI.toolTip = new Handler( showTips, [skillData]);
                }else{
                    skillAry = _playerData.heroList.getHero( _hero.data.prototypeID ).skillList.list;
                }



                for each( skillData in skillAry ){
                    if( skillData.skillID == pSkillItemUI.dataSource ){
                        pSkillItemUI.toolTip = new Handler( showTips, [skillData]);
                        pSkillItemUI.mask_en.dataSource = skillData;//为了做能量不做的蒙板
                        break;
                    }
                }
            }
        }




        if( pSkillItemUI.dataSource > 0){
            _itemDic[pSkillItemUI.dataSource] = pSkillItemUI;

        }

        pSkillItemUI.maskimg.visible = false;
        sector = new Sector();
        sector.name = 'sector';
        sector.visible = false;
        sector.alpha = 0.7;
        sector.scaleX = -1;
        sector.x = sector.y = 38;
        pSkillItemUI.addChild(sector);

        //todo UI改版后删掉
        pSkillItemUI.maskimgII.visible = false;
        var pMaskDisplayObject : DisplayObject;
        pMaskDisplayObject =  pSkillItemUI.maskimgII;
        if ( pMaskDisplayObject ) {
            pSkillItemUI.img.cacheAsBitmap = true;
            pMaskDisplayObject.cacheAsBitmap = true;
            pSkillItemUI.img.mask = pMaskDisplayObject;
        }

    }
    private function spcicalSkill(id:int):void{
        var pDB : IDatabase = system.stage.getSystem( IDatabase ) as IDatabase;
        var pTableSkil : IDataTable = pDB.getTable( KOFTableConstants.SKILL );
        var pSkill : Skill = pTableSkil.findByPrimaryKey( id );
        if (pSkill)
            m_fightUI.spcicalSkill.img.url = CPlayerPath.getSkillBigIcon( pSkill.IconName );
        SKILL_DIC["SPACE"] = SKILL_ITEM_SPACE = m_fightUI.spcicalSkill;

        m_fightUI.spcicalSkill.visible = true && _config['SPACE'];


        //tips
        var pInstanceSystem:CInstanceSystem = system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if( pInstanceSystem && pInstanceSystem.instanceContent && pInstanceSystem.instanceContent.embattleHeroID[0] > 0 ){//专属副本，特殊处理
//                    skillAry = _playerData.heroList.createHero( _hero.data.prototypeID ).skillList.list;
            skillData = new CSkillData;
            var pTableI : IDataTable  ;
            pTableI = _databaseSystem.getTable( KOFTableConstants.ACTIVE_SKILL_UP );
            var activeSkillUpI : ActiveSkillUp = pTableI.findByPrimaryKey( id );
            skillData.activeSkillUp = activeSkillUpI;
            pTableI  = _databaseSystem.getTable( KOFTableConstants.SKILL );
            var pSkillI : Skill = pTableI.findByPrimaryKey( id );
            skillData.pSkill = pSkillI;
            skillData.skillLevel = 1;
            m_fightUI.spcicalSkill.img.toolTip = new Handler( showTips, [skillData]);
        }else{
            var skillAry:Array = _playerData.heroList.getHero( _hero.data.prototypeID ).skillList.list;
            var skillData : CSkillData;
            for each( skillData in skillAry ){
                if( skillData.skillID == id ){
                    m_fightUI.spcicalSkill.img.toolTip = new Handler( showTips, [skillData]);
                    break;
                }
            }
        }


        //todo UI改版后删掉
        var pMaskDisplayObject : DisplayObject;
        pMaskDisplayObject =  m_fightUI.spcicalSkill.maskimgII;
        if ( pMaskDisplayObject ) {
            m_fightUI.spcicalSkill.img.cacheAsBitmap = true;
            pMaskDisplayObject.cacheAsBitmap = true;
            m_fightUI.spcicalSkill.img.mask = pMaskDisplayObject;
        }
    }
    private function passiveSkill(...args):void{
        var i:int;
        for( i = 0 ;i < args.length ; i++){
            if( m_fightUI["passiveskill_" + i ]){
                var pDB : IDatabase = system.stage.getSystem( IDatabase ) as IDatabase;
                var pTableSkil : IDataTable = pDB.getTable( KOFTableConstants.SKILL );
                var pSkill : Skill = pTableSkil.findByPrimaryKey( args[i] );
                if(pSkill)
                    m_fightUI["passiveskill_" + i ].img.url = CPlayerPath.getSkillBigIcon( pSkill.IconName );
            }
        }
    }
    private function showNotenghtEff( img :Image ):void{
        var timeline:TimelineLite = new TimelineLite();
        timeline.append(new TweenLite(img, .1,{alpha :.7}));
        timeline.append(new TweenLite(img, .5,{alpha :.7}));
        timeline.append(new TweenLite(img, .1,{alpha:0,onComplete:onComplete,onCompleteParams:[timeline]}));
        timeline.play();
        function onComplete( timeline:TimelineLite):void{
            if(timeline){
                timeline.stop();
                timeline = null;
            }
        }
    }
    //‘冷却中，能量不足，怒气不足’的文字提示
    private var _showNotEnghtTipsTimeline:TimelineLite;
    private function showNotEnghtTips( index : int ):void{
//        if( m_fightUI.clip_zdts.alpha > 0 && m_fightUI.clip_zdts.index == index )
//                return;
        _notEnghtTipsTimelineComplete();
        m_fightUI.clip_zdts.index = index;
        _showNotEnghtTipsTimeline = new TimelineLite();
        _showNotEnghtTipsTimeline.append(new TweenLite(m_fightUI.clip_zdts, .1,{alpha :1}));
        _showNotEnghtTipsTimeline.append(new TweenLite(m_fightUI.clip_zdts, 1.5,{alpha :0}));
        _showNotEnghtTipsTimeline.play();
    }
    private function _notEnghtTipsTimelineComplete( ):void{
        if(_showNotEnghtTipsTimeline){
            _showNotEnghtTipsTimeline.stop();
            _showNotEnghtTipsTimeline = null;
        }
    }


    ///////////
    public function updateEnerey( enNum : int ):void{
        if( SKILL_ITEM_L && SKILL_ITEM_L.visible ){
            SKILL_ITEM_L.img_dou.visible = enNum >= 1;
        }
        m_fightUI.spcicalSkill.img_dou_1.visible = enNum >= 1;
        m_fightUI.spcicalSkill.img_dou_2.visible = enNum >= 2;
        m_fightUI.spcicalSkill.img_dou_3.visible = enNum >= 3;
    }
    public function hideView(removed:Boolean = true):void {
        _notEnghtTipsTimelineComplete();
        m_fightUI.clip_zdts.alpha = 0;
    }

    private function showTips( skillData : CSkillData ):void {
        ( system.getHandler( CSkillTipsOnFightUIHandler ) as CSkillTipsOnFightUIHandler ).addTips( skillData );
    }


    //////////////////////隐藏 显示 技能图标//////////////////////

    private function onSkillItemVisible():void{
        for each( var key : String in KEY_ARY ){
            if( SKILL_DIC[key] )
                SKILL_DIC[key].visible = true && _config[key];
        }
    }
    public function getSkillItemByKey( key :String ):View{
        if( SKILL_DIC[key] )
            return SKILL_DIC[key];
        return null;
    }
    public function hideAllSkillItemssss( ):void {
        for ( var key : String in  _config ) {
            _config[key] = false;
        }
        onSkillItemVisible();
    }
    public function showAllSkillItems( ):void{
        for( var key: String in  _config ){
            _config[key] = true;
        }
        onSkillItemVisible();
    }
    public function hideSkillItemByKey( key :String ):void{
        _config[key] = false;
        onSkillItemVisible();
    }
    public function showSkillItemByKey( key :String ):void{
        _config[key] = true;
        onSkillItemVisible();
    }
   ///////////////////////////////////////




    private function get _databaseSystem():CDatabaseSystem {
        return  system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }


    private function get _playerSystem() : CPlayerSystem {
        return system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }
    private function get _playerData() : CPlayerData {
        return ( _playerSystem.getBean( CPlayerManager ) as CPlayerManager ).playerData;
    }
    private function get _pTable():IDataTable {
        return _databaseSystem.getTable( KOFTableConstants.SKILL );
    }

    // 先直接设置
    public function setFightUIVisible(v:Boolean) : void {
        m_fightUI.visible = v;
    }

    public function get m__useSkillEnable() : Boolean {
        return _useSkillEnable;
    }

    public function set m__useSkillEnable( value : Boolean ) : void {
        _useSkillEnable = value;
    }

    public function showAutoFightTips() : void {
        m_fightUI.auto_fight_tips_img.visible = true;
        m_fightUI.auto_fight_tips_img.play();
    }

    public function hideAutoFightTips() : void {
        m_fightUI.auto_fight_tips_img.visible = false;
        m_fightUI.auto_fight_tips_img.stop();
    }
    public function get autoFightBtn() : Component {
        return m_fightUI.auto_img;
    }
    public function get autoFightEffect() : FrameClip {
        return m_fightUI.auto_open_effect_clip;
    }
    public function get qeEffect() : FrameClip {
        return m_fightUI.qe_tutor_clip;
    }
}
}
