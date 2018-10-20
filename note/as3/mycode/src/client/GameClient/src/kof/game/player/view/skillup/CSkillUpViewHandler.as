//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/3/17.
 */
package kof.game.player.view.skillup {

import flash.events.Event;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.framework.IDataTable;
import kof.game.common.hero.CHeroListItemRender;
import kof.game.common.view.CChildView;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.data.CSkillData;
import kof.game.player.enum.EPlayerWndTabType;
import kof.table.SkillPositionRate;
import kof.table.SkillQualityRate;
import kof.table.SkillUpConsume;

import morn.core.components.Box;
import morn.core.components.Clip;
import morn.core.components.Component;
import morn.core.components.Image;
import morn.core.components.List;
import morn.core.events.UIEvent;
import morn.core.handlers.Handler;

public class CSkillUpViewHandler extends CChildView {

    private var _playerHeroData : CPlayerHeroData;
    private var _activeSkillAry : Array = [];
    private var _passiveSkillAry : Array = [];

    private var _curList : List;
    private var _listIndex : int;

    public function CSkillUpViewHandler( ) {
        super([ CSkillLevelUpView ,CSkillBreachView ]);
    }

    protected override function _onCreate() : void {
        // can not call super._onCreate in this class
        this.setNoneData();
        _heroItemRender = new CHeroListItemRender();
    }
    protected override function _onDispose() : void {
        // can not call super._onDispose in this class
    }
    protected override function _onShow():void {
        // can not call super._onShow in this class

        _ui.list_active.renderHandler = new Handler( renderItem );
        _ui.list_active.selectHandler = new Handler( _selectItemHandler,[_ui.list_active] );
        _ui.list_passive.renderHandler = new Handler( renderItem );
        _ui.list_passive.selectHandler = new Handler( _selectItemHandler,[_ui.list_passive] );
        _ui.tab.selectHandler = new Handler( onTabHandler );
        _ui.tab.selectedIndex = 0;
        _ui.tab.callLater( onTabHandler , [0] );

    }

    protected override function _onHide() : void {
        // can not call super._onHide in this class
        if(_curList)
            _curList.removeEventListener( UIEvent.ITEM_RENDER ,_onListActiveRender );
    }
    public virtual override function updateWindow() : Boolean {
        super.updateWindow();

        if( !_playerHeroData || _playerHeroData != _initialArgs[0] ){
            _curList  = _ui.list_active;
            _listIndex = 0;
            _playerHeroData = _initialArgs[0];
        }
        onSkillInfoHandler();

        return true;
    }

    private function onSkillInfoHandler():void{
        _ui.roleItem.dataSource = playerHeroData;
        _heroItemRender.renderItem(_ui.roleItem,0);
        var url:String = CPlayerPath.getUIHeroNamePath(playerHeroData.prototypeID);
        var nameBox:Box = _ui.nameBox;
        nameBox.dataSource = {heroName:{url:url},quanlityClip:{index:playerHeroData.qualityLevelSubValue}};
        var heroNameImg:Image = nameBox.getChildByName("heroName") as Image;
        heroNameImg.parent.addEventListener(Event.RESIZE,_onResize);
        _onResize();

        _activeSkillAry.splice( 0, _activeSkillAry.length );
        _passiveSkillAry.splice( 0, _passiveSkillAry.length );
        var skillAry:Array = _playerData.heroList.getHero( playerHeroData.prototypeID ).skillList.list;
        var skillData : CSkillData;
        for each( skillData in skillAry ){
            if( skillData.pSkill ){
                _activeSkillAry.push( skillData );
            }else if( skillData.passiveSkillUp ){
                _passiveSkillAry.push( skillData );
            }
        }
        _curList.addEventListener( UIEvent.ITEM_RENDER ,_onListActiveRender, false, 0, true );
        _ui.list_active.dataSource = _activeSkillAry;
        _ui.list_passive.dataSource = _passiveSkillAry;

    }
    private function _onListActiveRender( evt : UIEvent ):void{
        if( evt.data[1] == _listIndex ){
            _curList.removeEventListener( UIEvent.ITEM_RENDER ,_onListActiveRender );
            _curList.selectedIndex = _listIndex;
            _curList.callLater( _selectItemHandler ,[ _curList ,_listIndex ] );
        }
    }
    private function renderItem( item : Component, idx : int ) : void {
//        if ( !(item is Object) ) {
//            return;
//        }
        var Object : * = new Object();
        var skillData : CSkillData = Object.dataSource as CSkillData;
        if ( skillData ) {
            if( skillData.pSkill ){
                if(skillData.pSkill){
                    Object.txt_name.text = skillData.pSkill.Name;
                    Object.img.url = CPlayerPath.getSkillSmallIcon( skillData.pSkill.IconName );
                }
            }else if( skillData.passiveSkillUp ){
                Object.txt_name.text = skillData.passiveSkillUp.skillname;
                Object.img.url = CPlayerPath.getPassiveSkillSmallIcon( skillData.passiveSkillUp.icon );
            }
            Object.txt_lv.text = "等级：" + skillData.skillLevel;
            skillData.skillPosition == 5 ? Object.clip_kuang.index = 1 : Object.clip_kuang.index = 0;


            var pTable : IDataTable;
            pTable  = _databaseSystem.getTable( KOFTableConstants.SKILL_UP_CONSUME );
            var skillUpConsume : SkillUpConsume = pTable.findByPrimaryKey( skillData.skillLevel );
            pTable  = _databaseSystem.getTable( KOFTableConstants.SKILL_POSITION_RATE );
            var skillPositionRate : SkillPositionRate = pTable.findByPrimaryKey( skillData.skillPosition );
            pTable  = _databaseSystem.getTable( KOFTableConstants.SKILL_QUALITY_RATE );
            var skillQualityRate : SkillQualityRate = pTable.findByPrimaryKey( _playerHeroData.qualityBase );

            var needSkillPoint : int = Math.ceil( skillUpConsume.skillConsumeNum * (skillPositionRate.skillConsumeRate / 10000 ) * (skillQualityRate.skillConsumeRate / 10000 ) );
            var needGold : int = Math.ceil( skillUpConsume.goldConsumeNum * (skillPositionRate.goldConsumeRate / 10000 ) * (skillQualityRate.goldConsumeRate / 10000 ) );


            Object.btn_up.visible = _playerData.currency.gold >= needGold && _playerData.skillData.skillPoint >= needSkillPoint && _playerHeroData.level > skillData.skillLevel;

            Object.toolTip = new Handler( addTips, [CSkillUpItemTips, Object, []]);
//            Object.toolTip = new Handler( addTips, [CSkillUpItemTips, Object, [tipsTitle, status]]);

        }
    }

    private function _selectItemHandler( ...args) : void {
//        var list : List = args[0] as List;
//        var Object : Object = new Object();
//        if ( !Object )
//            return;
//        var skillData : CSkillData = Object.dataSource as CSkillData;
//        if ( skillData ) {
//            if( list == _ui.list_active ){
//                _ui.list_passive.selectedIndex = -1;
//                _curList = _ui.list_active;
//            }else if( list == _ui.list_passive ){
//                _ui.list_active.selectedIndex = -1;
//                _curList = _ui.list_passive;
//            }
//            _listIndex = args[1];
//            skillLevelUpView.updateView( skillData );
//            skillBreachView.updateView( skillData );
//        }
    }
    public override function setData(data:Object, forceInvalid:Boolean = true) : void {
        super.setData(data, forceInvalid);
        skillLevelUpView.setData([data, _initialArgs[0]], forceInvalid);
        skillBreachView.setData([data, _initialArgs[0]], forceInvalid);
    }
    private function onTabHandler(index : int):void{
        index == 0 ? onSkillUpViewShow() : onSkillBreachViewShow();
    }
    private function onSkillUpViewShow():void{
        _ui.view_breach.visible = false;
        _ui.view_up.visible = true;
    }
    private function onSkillBreachViewShow():void{
        _ui.view_up.visible = false;
        _ui.view_breach.visible = true;
    }
    private function _onResize(e:Event = null):void {
        var nameBox:Box = _ui.nameBox;
        var heroNameImg:Image = nameBox.getChildByName("heroName") as Image;
        var addImg:Image = nameBox.getChildByName("add") as Image;
        var quanlityClipC:Clip = nameBox.getChildByName("quanlityClip") as Clip;
        heroNameImg.x = heroNameImg.width/2;
        addImg.x= heroNameImg.x+heroNameImg.width/2+1;
        quanlityClipC.x = addImg.x+addImg.width+1;
    }
    private function get _ui() : Object{
        return (rootUI as Object).viewStack.items[EPlayerWndTabType.STACK_ID_HERO_SKILL_UP] as Object;
    }

    private function get playerData() : CPlayerData {
        return _data as CPlayerData;
    }
    private function get playerHeroData() : CPlayerHeroData {
        return _initialArgs[0] as CPlayerHeroData;
    }
    public function get skillLevelUpView() : CSkillLevelUpView { return this.getChild(0) as CSkillLevelUpView; }
    public function get skillBreachView() : CSkillBreachView { return this.getChild(1) as CSkillBreachView; }

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

    private var _heroItemRender:CHeroListItemRender;

}
}
