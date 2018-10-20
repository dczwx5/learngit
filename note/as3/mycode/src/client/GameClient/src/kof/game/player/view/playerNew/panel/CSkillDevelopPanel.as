//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/8/16.
 */
package kof.game.player.view.playerNew.panel {

import QFLib.Utils.HtmlUtil;

import flash.display.DisplayObject;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.KOFSysTags;
import kof.game.bag.CBagManager;
import kof.game.bag.CBagSystem;
import kof.game.bag.data.CBagData;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.data.CSkillData;
import kof.game.player.event.CPlayerEvent;
import kof.game.player.view.playerNew.view.skillDevelop.CSkillBreachPart;
import kof.game.player.view.playerNew.view.skillDevelop.CSkillLvUpPart;
import kof.table.PassiveSkillUp;
import kof.table.PlayerSkill;
import kof.table.SkillEmitterConsume;
import kof.table.SkillGetCondition;
import kof.table.SkillPositionRate;
import kof.table.SkillQualityRate;
import kof.table.SkillUpConsume;
import kof.ui.CUISystem;
import kof.ui.master.jueseNew.panel.SkillTrainViewUI;
import kof.ui.master.jueseNew.render.SkillTrainItemViewUI;
import kof.util.CQualityColor;

import morn.core.components.Box;
import morn.core.components.Component;
import morn.core.events.UIEvent;
import morn.core.handlers.Handler;

/**
 * 招式提升
 */
public class CSkillDevelopPanel extends CPlayerPanelBase {

    private var m_pHeroData : CPlayerHeroData;
    private var m_pSkillLvUpPart : CSkillLvUpPart;
    private var m_pSkillBreachPart : CSkillBreachPart;

    private static const TYPE_ARY : Array = ['普','跳','U','I','O','space','','被','被','被','被','被','被','被'];
    private static const SPACE_INDEX : int = 5;

    private var _redSkillPoint :Boolean;

    private var _skillPositon : Array;

    private var _activeSkillAry : Array;

    private var _passiveSkillAry : Array;

    private var m_iCurrSelSkillId:int;

    public function CSkillDevelopPanel()
    {
        super();
    }
    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        ret = ret && onInitialize();
        if ( loadViewByDefault ) {
            ret = ret && loadAssetsByView( viewClass );
            ret = ret && onInitializeView();
        }

        ret = this.addBean( m_pSkillLvUpPart = new CSkillLvUpPart() );
        ret = this.addBean( m_pSkillBreachPart = new CSkillBreachPart() );

        return ret;
    }
    override protected function _initView():void
    {
        m_pSkillLvUpPart.initView();
        m_pSkillBreachPart.initView();
    }
    override public function initializeView():void
    {
        super.initializeView();

        m_pViewUI = new SkillTrainViewUI();
        m_pSkillLvUpPart.view = _viewUI.skillLvUpView;
        m_pSkillBreachPart.view = _viewUI.skillBreachView;

//        _viewUI.btn_left.clickHandler = new Handler(_onPageChange,[_viewUI.btn_left]);
//        _viewUI.btn_right.clickHandler = new Handler(_onPageChange,[_viewUI.btn_right]);

        _viewUI.list.renderHandler = new Handler( renderItem );
        _viewUI.list.selectHandler = new Handler( selectHandler );
        _viewUI.tab.selectHandler = new Handler( tabSelectHandler );

        m_pSkillLvUpPart.initializeView();
        m_pSkillBreachPart.initializeView();

        _viewUI.tab.callLater( tabSelectHandler ,[0] );
    }

    private function renderItem( item : Component, idx : int ) : void {
        if ( !(item is SkillTrainItemViewUI) ) {
            return;
        }
        var skillItemUI : SkillTrainItemViewUI = item as SkillTrainItemViewUI;
        var skillGetCondition : SkillGetCondition;
        //
        var skillID : int ;
        var skillPosition : int;
        skillID = int( skillItemUI.dataSource );
        var skillData : CSkillData = getSkillDataByID( skillID );
        if ( skillData ) {
            var skillArr : Array = getHeroSkills( m_pHeroData.prototypeID );
            var pMaskDisplayObject : DisplayObject;
            for( var index : int = 0 ; index < skillArr.length ; index ++ ){
                skillID = skillArr[index];
                if( skillID == skillData.skillID ){
                    if( index == SPACE_INDEX ){
                        skillItemUI.img_spcicalSkill.url = CPlayerPath.getSkillBigIcon( skillData.pSkill.IconName );
                        skillItemUI.maskimgII.visible = false;
                        pMaskDisplayObject =  skillItemUI.maskimgII;
                        if ( pMaskDisplayObject ) {
                            skillItemUI.img_spcicalSkill.cacheAsBitmap = true;
                            pMaskDisplayObject.cacheAsBitmap = true;
                            skillItemUI.img_spcicalSkill.mask = pMaskDisplayObject;
                        }

                        skillItemUI.box_spcicalSkill.visible = true;
                        skillItemUI.box_normalSkill.visible = false;
                        skillItemUI.list_breach.visible = true;
                        skillItemUI.txt_openCondition.visible = false;
                    }else{
                        if( skillData.pSkill ){
                            skillItemUI.img_normalSkill.url = CPlayerPath.getSkillBigIcon( skillData.pSkill.IconName );
//                            skillItemUI.clip_SuperScript.visible = skillData.pSkill.SuperScript > 0 ;
//                            if( skillItemUI.clip_SuperScript.visible )
//                                skillItemUI.clip_SuperScript.index = skillData.pSkill.SuperScript - 1;
                            skillItemUI.list_breach.visible = true;
                            skillItemUI.txt_openCondition.visible = false;
                        }else if( skillData.passiveSkillUp ){
                            skillItemUI.img_normalSkill.url = CPlayerPath.getPassiveSkillBigIcon( skillData.passiveSkillUp.icon );
//                            skillItemUI.clip_SuperScript.visible = false;
                            skillGetCondition  = getSkillOpenCondition( skillData.skillPosition );
                            if( m_pHeroData.star >= skillGetCondition.star){//已经开启
                                skillItemUI.list_breach.visible = true;
                                skillItemUI.txt_openCondition.visible = false;
                            }else{
                                skillItemUI.list_breach.visible = false;
                                skillItemUI.txt_openCondition.visible = true;
                                skillItemUI.txt_openCondition.text = '格斗家' + skillGetCondition.star + '星开启';
                            }

                        }
                        skillItemUI.maskimg.visible = false;
                        pMaskDisplayObject =  skillItemUI.maskimg;
                        if ( pMaskDisplayObject ) {
                            skillItemUI.img_normalSkill.cacheAsBitmap = true;
                            pMaskDisplayObject.cacheAsBitmap = true;
                            skillItemUI.img_normalSkill.mask = pMaskDisplayObject;
                        }

                        skillItemUI.txt_key.text = TYPE_ARY[index];
                        skillItemUI.box_spcicalSkill.visible = false;
                        skillItemUI.box_normalSkill.visible = true;
                    }

                    if( skillData.pSkill ){
                        skillItemUI.txt_name.text = skillData.pSkill.Name;
                    }else if( skillData.passiveSkillUp ){
                        skillItemUI.txt_name.text = skillData.passiveSkillUp.skillname;
                    }
                    skillItemUI.txt_lv.text = "Lv." + skillData.skillLevel;
                    skillItemUI.txt_lv.visible = true;

                    skillItemUI.list_breach.renderHandler = new Handler( skillItemBreachRenderHandler ,[ skillData]);
                    skillItemUI.list_breach.dataSource = ['','',''];
                    break;
                }
            }

            skillItemUI.redpt.visible = canLvUpFlg( skillData ) || canBreachFlg( skillData);
            if( skillItemUI.redpt.visible )
                _redSkillPoint = true;

            skillItemUI.img_lock.visible = false;
//            skillItemUI.disabled = false;
//            skillItemUI.filters = null;
            skillItemUI.img_lockmask.visible = false;


        }else {
            if( skillID <= 0 )
                    return;
            var pTable : IDataTable = _databaseSystem.getTable( KOFTableConstants.PASSIVE_SKILL_UP );
            var passiveSkillUp : PassiveSkillUp = pTable.findByPrimaryKey( skillID );
            skillItemUI.txt_name.text = passiveSkillUp.skillname;
//            skillItemUI.clip_SuperScript.visible = false;
            skillItemUI.txt_key.text = '被';
            skillItemUI.list_breach.visible = false;
            skillItemUI.txt_openCondition.visible = true;
            skillPosition = _skillPositon.indexOf( skillID );
            skillGetCondition  = getSkillOpenCondition( skillPosition );
            skillItemUI.txt_openCondition.text = '格斗家' + skillGetCondition.star + '星开启';
            skillItemUI.redpt.visible = false;
            skillItemUI.img_lock.visible = true;
            skillItemUI.box_spcicalSkill.visible = false;
            skillItemUI.box_normalSkill.visible = true;
            skillItemUI.img_normalSkill.url = CPlayerPath.getPassiveSkillBigIcon( passiveSkillUp.icon );
            skillItemUI.txt_lv.visible = false;

            skillItemUI.maskimg.visible = false;
            pMaskDisplayObject =  skillItemUI.maskimg;
            if ( pMaskDisplayObject ) {
                skillItemUI.img_normalSkill.cacheAsBitmap = true;
                pMaskDisplayObject.cacheAsBitmap = true;
                skillItemUI.img_normalSkill.mask = pMaskDisplayObject;
            }

//            skillItemUI.disabled = true;
//            skillItemUI.filters = FilterUtil.bAndWfilter;

            skillItemUI.img_lockmask.visible = true;
        }

        if(skillID == m_iCurrSelSkillId)
        {
//            skillItemUI.selected.visible = true;
            skillItemUI.btn.selected = true;
        }
        else
        {
//            skillItemUI.selected.visible = false;
            skillItemUI.btn.selected = false;
        }

        skillItemUI.selected.visible = false;

        var playerSystem:CPlayerSystem = system.stage.getSystem(CPlayerSystem ) as CPlayerSystem;
        skillPosition = _skillPositon.indexOf( skillID );
        skillItemUI.toolTip = new Handler( playerSystem.showHeroSkillTips, [skillData,skillID,skillPosition]);


    }
    private function skillItemBreachRenderHandler( ...args ):void{

        var skillData : CSkillData = args[0] as CSkillData;
        var img : Box = args[1] as Box;
        var position : int = args[2] + 1;
        var obj : Object = getPositionInfo( position ,skillData);
        if( obj ){
            if( obj.isBreak ){
                img.disabled = false;
            }else if( obj.isActive ){
                img.disabled = true;
            }
        }else{
            img.disabled = true;
        }
    }
    private function selectHandler( index : int ) : void {
        var skillTrainItemViewUI : SkillTrainItemViewUI = _viewUI.list.getCell( index ) as SkillTrainItemViewUI;
        if ( !skillTrainItemViewUI )
            return;
        var skillID : int ;
        skillID = int( skillTrainItemViewUI.dataSource );
        var skillData : CSkillData = getSkillDataByID( skillID );
//        if ( skillData ) {
            m_pSkillLvUpPart.updateView( skillData ,skillID );
            var skillPosition : int = _skillPositon.indexOf( skillID );
            m_pSkillBreachPart.updateView( skillData ,skillID ,skillPosition);

            _onTabLvUpRedPoint( skillData );
            _onTabBreachRedPoint( skillData );
//        }

        m_iCurrSelSkillId = skillID;
        _resetState();
//        skillTrainItemViewUI.selected.visible = true;
        skillTrainItemViewUI.btn.selected = true;

    }
    private function tabSelectHandler( index : int ):void{
        _viewUI.skillLvUpView.visible = index == 0;
        _viewUI.skillBreachView.visible = index == 1;
    }

    private function _updateHeroImg():void
    {
        _viewUI.img_hero.url = CPlayerPath.getUIHeroFacePath(m_pHeroData.prototypeID);
    }
    private function _onListRender( evt : UIEvent ):void{
        _viewUI.list.removeEventListener( UIEvent.ITEM_RENDER ,_onListRender );
        _viewUI.list.selectedIndex = 0;
        _viewUI.list.callLater( selectHandler,[0]);
    }


    override public function set data( value : * ) : void
    {
        m_pHeroData = value as CPlayerHeroData;
        if(m_bViewInitialized)
        {
            m_pSkillLvUpPart.data = value as CPlayerHeroData;
            m_pSkillBreachPart.data = value as CPlayerHeroData;

            var qualLeveltxt:String = HtmlUtil.color("+"+m_pHeroData.qualityLevelSubValue,CQualityColor.QUALITY_COLOR_ARY[m_pHeroData.qualityLevelValue]);
            _viewUI.txt_heroName.stroke = (value as CPlayerHeroData).strokeColor;
            _viewUI.txt_heroName.text = _playerHelper.getHeroWholeName(m_pHeroData);

            _updateHeroImg();

            var allSkillArr : Array = getHeroSkills( m_pHeroData.prototypeID );
            var needShowArr : Array = [ allSkillArr[2],allSkillArr[3],allSkillArr[4],allSkillArr[5],
                allSkillArr[7],allSkillArr[8],allSkillArr[9],allSkillArr[10]];


            _skillPositon = ['','',allSkillArr[2],allSkillArr[3],allSkillArr[4],allSkillArr[5],'',
                    allSkillArr[7],allSkillArr[8],allSkillArr[9],allSkillArr[10],allSkillArr[11],
                    allSkillArr[12],allSkillArr[13]];

            _redSkillPoint = false;


            _activeSkillAry = [allSkillArr[2],allSkillArr[3],allSkillArr[4],allSkillArr[5]];
            _passiveSkillAry = [allSkillArr[7],allSkillArr[8],allSkillArr[9],allSkillArr[10],allSkillArr[11],
                allSkillArr[12],allSkillArr[13]];


            _viewUI.list.removeEventListener( UIEvent.ITEM_RENDER ,_onListRender );
            _viewUI.list.addEventListener( UIEvent.ITEM_RENDER ,_onListRender, false, 0, true );

            _viewUI.list.dataSource = _passiveSkillAry;

            _onTabShowHandler();

            _redPointOnTab();

        }

    }
    private function _onTabShowHandler():void{
        if( _playerHelper.isChildSystemOpen( KOFSysTags.SKIL_BREAK ) ){
            _viewUI.tab.labels = '体能升级,体能突破';
            _viewUI.tab.x = 670;
            _viewUI.img_red1.x = 758;
        }else{
            _viewUI.tab.labels = '体能升级';
            _viewUI.tab.x = 776;
            _viewUI.img_red1.x = 865;
        }
    }


    private function _resetState() : void {
//        for ( var i : int = 0; i < _viewUI.list.cells.length; i++ ) {
//            var itemUI : SkillTrainItemViewUI = _viewUI.list.getCell( i ) as SkillTrainItemViewUI;
//            itemUI.selected.visible = false;
//            itemUI.btn.selected = false;
//        }

        for each(var cell:SkillTrainItemViewUI in _viewUI.list.cells)
        {
            if(cell)
            {
                cell.selected.visible = false;
                cell.btn.selected = false;
            }
        }
    }


    private function getSkillDataByID( skillID : int ):CSkillData{
        var skillData : CSkillData;
        var skillAry:Array = _playerData.heroList.getHero( m_pHeroData.prototypeID ).skillList.list;
        if( skillAry ){
            for each ( skillData in skillAry ){
                if( skillData.skillID == skillID )
                        return skillData;
            }
        }
        return null;
    }

    private function _onPlayerDataHandler(e:CPlayerEvent):void{
        _redSkillPoint = false;
        _viewUI.list.refresh();
        _viewUI.list.callLater( selectHandler,[_viewUI.list.selectedIndex]);
        _playerData.skillData.skillPoint;
        callLater( _redPointOnTab );
    }
    override protected function _addListeners():void
    {
        super._addListeners();

        m_pSkillLvUpPart.addListeners();
        m_pSkillBreachPart.addListeners();

        _playerSystem.addEventListener( CPlayerEvent.PLAYER_ORIGIN_CURRENCY ,_onPlayerDataHandler );
        _playerSystem.addEventListener( CPlayerEvent.SKILL_DATA ,_onPlayerDataHandler );
        _playerSystem.addEventListener( CPlayerEvent.SKILL_POINT ,_onPlayerDataHandler );
        _playerSystem.addEventListener( CPlayerEvent.SKILL_ADD ,_onPlayerDataHandler );
        _playerSystem.addEventListener( CPlayerEvent.PLAYER_SKILL ,_onPlayerDataHandler );
        _playerSystem.addEventListener( CPlayerEvent.SKILL_LVUP ,_onPlayerDataHandler );
        _playerSystem.addEventListener( CPlayerEvent.SKILL_BREAK ,_onPlayerDataHandler );
    }

    override protected function _removeListeners():void
    {
        super._removeListeners();

        m_pSkillLvUpPart.removeListeners();
        m_pSkillBreachPart.removeListeners();

        _playerSystem.removeEventListener( CPlayerEvent.PLAYER_ORIGIN_CURRENCY ,_onPlayerDataHandler );
        _playerSystem.removeEventListener( CPlayerEvent.SKILL_DATA ,_onPlayerDataHandler );
        _playerSystem.removeEventListener( CPlayerEvent.SKILL_POINT ,_onPlayerDataHandler );
        _playerSystem.removeEventListener( CPlayerEvent.SKILL_ADD ,_onPlayerDataHandler );
        _playerSystem.removeEventListener( CPlayerEvent.PLAYER_SKILL ,_onPlayerDataHandler );
        _playerSystem.removeEventListener( CPlayerEvent.SKILL_LVUP ,_onPlayerDataHandler );
        _playerSystem.removeEventListener( CPlayerEvent.SKILL_BREAK ,_onPlayerDataHandler );
    }


    private function getPositionInfo( i : int ,skillData : CSkillData ):Object{
        for each( var obj : Object in skillData.slotListData.list ){
            if( obj.position == i ){
                return obj;
                break;
            }
        }
        return null;
    }

    private function getSkillOpenCondition( skillPosition : int ):SkillGetCondition{
        var tableAry : Array = _skillGetCondition.toArray();
        var skillGetCondition : SkillGetCondition ;
        for each ( skillGetCondition in tableAry ){
           if( skillGetCondition.skillPositionID == skillPosition ){
               return skillGetCondition;
               break;
           }
        }
        return null;
    }
    ////////////////////////////小红点////////////////////////////
    private function _redPointOnTab():void{
        var isActiveSkillRed : Boolean;
        var isPassiveRed : Boolean;
        var skillID : int;
        var skillData : CSkillData;
//        //主动
//        for each ( skillID in _activeSkillAry ){
//            skillData = getSkillDataByID( skillID );
//            if( skillData ){
//                isActiveSkillRed = canLvUpFlg( skillData ) || canBreachFlg( skillData );
//            }
//            if( isActiveSkillRed )
//                break;
//        }
        //被动
        for each ( skillID in _passiveSkillAry ){
            skillData = getSkillDataByID( skillID );
            if( skillData ){
                isPassiveRed = canLvUpFlg( skillData ) || canBreachFlg( skillData );
            }
            if( isPassiveRed )
                break;
        }
    }

    //总的小红点
    public function get m__redSkillPoint() : Boolean {
        return _redSkillPoint;
    }



    //招式提升小红点
    private function _onTabLvUpRedPoint( skillData : CSkillData ):void{
        _viewUI.img_red1.visible = canLvUpFlg( skillData );
    }
    //是否可以招式提升
    private function canLvUpFlg( skillData : CSkillData ):Boolean{
        if( null == skillData )
            return false;

        var pTable : IDataTable;
        pTable  = _databaseSystem.getTable( KOFTableConstants.SKILL_UP_CONSUME );
        var skillUpConsume : SkillUpConsume = pTable.findByPrimaryKey( skillData.skillLevel );
        pTable  = _databaseSystem.getTable( KOFTableConstants.SKILL_POSITION_RATE );
        var skillPositionRate : SkillPositionRate = pTable.findByPrimaryKey( skillData.skillPosition );
        pTable  = _databaseSystem.getTable( KOFTableConstants.SKILL_QUALITY_RATE );
        var skillQualityRate : SkillQualityRate = pTable.findByPrimaryKey( m_pHeroData.qualityBase );
        var needGold : int = Math.ceil( skillUpConsume.goldConsumeNum * (skillPositionRate.goldConsumeRate / 10000 ) * (skillQualityRate.goldConsumeRate / 10000 ) );
        var needSkillPoint : int = Math.ceil( skillUpConsume.skillConsumeNum * (skillPositionRate.skillConsumeRate / 10000 ) * (skillQualityRate.skillConsumeRate / 10000 ) );
        if(  _playerData.currency.gold < needGold ){
            return false;
        }
        if( _playerData.skillData.skillPoint < needSkillPoint ){
            return false;
        }
        if( m_pHeroData.level <= skillData.skillLevel ){
            return false;
        }
        //新加规则
        if( _playerData.teamData.level < 20 && _playerData.skillData.skillPoint < 10 )
                return false;

        if( _playerData.teamData.level >= 20 && _playerData.skillData.skillPoint < 20 )
                return false;

        return true;
    }
    //能量突破小红点
    private function _onTabBreachRedPoint( skillData : CSkillData ):void{
        _viewUI.img_red2.visible = canBreachFlg( skillData );
    }

    private function canBreachFlg( skillData : CSkillData ):Boolean{
        if( null == skillData )
            return false;
        if( _playerData.teamData.level < 30){// 战队等级30级才开放能量突破,todo :读表
            return false;
        }
        var activeObjAry : Array = [];
        var obj : Object;
        for each( obj in skillData.slotListData.list ){
            if( obj.isActive && !obj.isBreak ){
                activeObjAry.push( obj );
            }
        }
        if( activeObjAry.length <= 0 ){// 没有突破状态的点
            return false;
        }

        var curConsume : SkillEmitterConsume;
        var skillPointEnoughObjAry : Array = [];
        for each( obj in activeObjAry ){
            curConsume = getBreachConsume( skillData ,obj.position );
            if( _playerData.skillData.skillPoint >= curConsume.skillConsumeNum ){
                skillPointEnoughObjAry.push( obj );
            }
        }

        if( skillPointEnoughObjAry.length <= 0 ){// 没有满足足够招式点的点
            return false;
        }

        var itemEnoughObjAry : Array = [];
        var itemEnoughFlg : Boolean;
        for each( obj in skillPointEnoughObjAry ){
            curConsume = getBreachConsume( skillData ,obj.position );
            var bagData : CBagData;
            var itemObj : Object;
            itemEnoughFlg = true;
            for( var i : int  = 1 ; i <= 2 ; i++ ){
                itemObj = {};
                itemObj.ID = curConsume['item' + i];
                itemObj.num = curConsume['count' + i];
                if( itemObj.ID != 0 && itemObj.num != 0){
                    bagData = _bagManager.getBagItemByUid( itemObj.ID );
                    if( !bagData || bagData.num < itemObj.num ){
                        itemEnoughFlg = false;
                        break;
                    }
                }
            }
            if( itemEnoughFlg ){
                itemEnoughObjAry.push( obj );
            }
        }

        if( itemEnoughObjAry.length <= 0 ){// 没有满足足够道具的点
            return false;
        }


        var goldEnoughObjAry : Array = [];
        var goldEnoughFlg : Boolean;
        for each( obj in itemEnoughObjAry ){
            curConsume = getBreachConsume( skillData ,obj.position );
            if( curConsume.goldConsumeNum <= _playerData.currency.gold ){
                goldEnoughObjAry.push( obj );
            }
        }

        if( goldEnoughObjAry.length <= 0 ){// 没有满足足够金币的点
            return false;
        }


        return true;
    }

    private function getBreachConsume( skillData : CSkillData , position : int ):SkillEmitterConsume{
        var pTable : IDataTable  = _databaseSystem.getTable( KOFTableConstants.SKILL_EMITTER_CONSUME );
        var item : SkillEmitterConsume;
        var curConsume : SkillEmitterConsume;
        var tableAry : Array = pTable.toArray();
        for each ( item in tableAry ){
            if( position ==  item.skillEmitterLevel &&
                    skillData.skillPosition == item.skillPositionID &&
                    m_pHeroData.qualityBase == item.Quality
            ){
                curConsume = item;
                break;
            }
        }
        return curConsume;
    }

    override public function clear():void
    {
        m_iCurrSelSkillId = 0;
        _viewUI.list.scrollBar.value = 0;
    }


    ///////////////////////////////////////////////////////////////////
    /**
     * 得格斗家技能数据
     * @param heroId
     * @return
     */
    public function getHeroSkills( heroId:int ):Array {
        var playerSkill : PlayerSkill = _playerSkill.findByPrimaryKey(heroId);
        var skillArr : Array = playerSkill.SkillID.concat();
        return skillArr;
    }
    private function get _viewUI():SkillTrainViewUI
    {
        return view as SkillTrainViewUI;
    }
    private function get _playerData() : CPlayerData {
        return ( _playerSystem.getBean( CPlayerManager ) as CPlayerManager ).playerData;
    }
    private function get _playerSystem() : CPlayerSystem {
        return ( uiCanvas as CAppSystem ).stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }

    private function get _playerSkill():IDataTable {
        return _dataBase.getTable(KOFTableConstants.PLAYER_SKILL);
    }
    private function get _skillGetCondition():IDataTable {
        return _dataBase.getTable(KOFTableConstants.SKILLGETCONDITION);
    }
    private function get _dataBase():IDatabase {
        return system.stage.getSystem(IDatabase) as IDatabase;
    }
    private function get _databaseSystem():CDatabaseSystem {
        return  ( uiCanvas as CAppSystem ).stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }
    private function get _bagManager() : CBagManager {
        return _bagSystem.getBean( CBagManager ) as CBagManager;
    }
    private function get _bagSystem() : CBagSystem {
        return system.stage.getSystem(CBagSystem) as CBagSystem;
    }
    private function get _pUISystem() : CUISystem {
        return ( uiCanvas as CAppSystem ).stage.getSystem( CUISystem ) as CUISystem;
    }


}
}
