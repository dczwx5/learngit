//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by dendi on 2017/11/29.
 */
package kof.game.practice {

import QFLib.Utils.HtmlUtil;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerBaseData;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.enum.EHeroIntelligence;
import kof.game.scene.CSceneSystem;
import kof.table.PracticeOpponent;
import kof.ui.master.practice.PracticeListRenderUI;
import kof.ui.master.practice.PracticeUI;
import kof.util.CQualityColor;

import morn.core.components.Box;
import morn.core.components.Component;
import morn.core.components.Dialog;
import morn.core.handlers.Handler;

public class CPracticeViewHandler extends CViewHandler {
    private var m_bViewInitialized : Boolean;
    private var m_pViewUI:PracticeUI;
    private var m_pCloseHandler : Handler;
    private var m_viewType:int;
    public function CPracticeViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array {
        return [ PracticeUI, PracticeListRenderUI ];
    }

    override protected function get additionalAssets() : Array
    {
        return ["practice.swf"];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !m_bViewInitialized )
        {
            if ( !m_pViewUI )
            {
                m_pViewUI = new PracticeUI();
                m_pViewUI.closeHandler = new Handler(_onCloseHandler);

                m_pViewUI.list_hasGet.renderHandler = new Handler(_renderItem);
                m_pViewUI.list_hasGet.mouseHandler = new Handler(_onClickListHandler);

                m_pViewUI.list_notGet.renderHandler = new Handler(_renderItem);

                m_pViewUI.box_hasGet.addEventListener(Event.RESIZE, _onResize);
                m_pViewUI.panel.vScrollBar.changeHandler = new Handler(_onScrollChange);

                _updateScrollState();

                m_bViewInitialized = true;
            }
        }

        return m_bViewInitialized;
    }

    private function _onClickListHandler(evt:Event, idx:int) : void {
        if(evt.type == MouseEvent.CLICK){
            var heroItem:PracticeListRenderUI = evt.currentTarget as PracticeListRenderUI;
            var isRobot:Boolean = true;
            if(heroItem.dataSource is CPlayerHeroData){
                isRobot = false;
            }

            if (heroItem == null) return ;
            var heroData:Object = heroItem.dataSource;

            switch (evt.target.name)
            {
                case "btn_change":
                    var id:int = isRobot ? heroData.ID : heroData.prototypeID;

                    if(isRobot){
                        (system.getHandler(CPracticeHandler) as CPracticeHandler).changePracticeRobotHeroRequest(id);
                    }else{
                        (system.getHandler(CPracticeHandler) as CPracticeHandler).changePracticeSelfHeroRequest(id);

                        (system.stage.getSystem(CSceneSystem) as CSceneSystem).initialHeroShowList();
                    }
                    (system as CPracticeSystem).closeView();
                    break;
            }
        }
    }

    override protected function updateDisplay():void
    {
        if(m_viewType){
            _updateOpponentWindow();
            m_pViewUI.img_unHave.visible = false;
        }else{
            _updateWindow();
            m_pViewUI.img_unHave.visible = true;
        }

    }

    private function _updateOpponentWindow():void{
        var list:Array = (system as CPracticeSystem).heroList;//getRobotList();
        // list 排序
        var unlockRepeatY:int = m_pViewUI.list_hasGet.repeatY;
        var curUnlockRepeatY:int = (list.length-1) / m_pViewUI.list_hasGet.repeatX + 1;
        m_pViewUI.list_hasGet.dataSource = list;
        if (unlockRepeatY != curUnlockRepeatY)
        {
            m_pViewUI.list_hasGet.repeatY = curUnlockRepeatY;
        }

        m_pViewUI.list_notGet.dataSource = [];
        m_pViewUI.list_notGet.visible = false;

        _onResize(null);

        _lastScrollValue = m_pViewUI.panel.vScrollBar.value+1;
        m_pViewUI.panel.refresh();
    }

    private function _updateWindow():void
    {
        // 看能不能优化一下, 不要每次都排序
        var list:Array = _playerData.displayList;

        var existFilter:Function = function (item:CPlayerHeroData, idx:int, arr:Array) : Boolean {
            return item.hasData;
        };
        var unHireFilter:Function = function (item:CPlayerHeroData, idx:int, arr:Array) : Boolean {
            return item.hasData == false;
        };
        var hireList:Array = list.filter(existFilter);
        var unHireList:Array = list.filter(unHireFilter);
        hireList.sort(_playerData.heroList.compare);
        unHireList.sort(_playerData.heroList.compare);
        // list 排序
        var unlockRepeatY:int = m_pViewUI.list_hasGet.repeatY;
        var curUnlockRepeatY:int = (hireList.length-1) / m_pViewUI.list_hasGet.repeatX + 1;
        m_pViewUI.list_hasGet.dataSource = hireList;
        if (unlockRepeatY != curUnlockRepeatY)
        {
            m_pViewUI.list_hasGet.repeatY = curUnlockRepeatY;
        }

        var lockRepeatY:int = m_pViewUI.list_notGet.repeatY;
        var curLockRepeatY:int = (unHireList.length-1) / m_pViewUI.list_notGet.repeatX + 1;
        m_pViewUI.list_notGet.dataSource = unHireList;
        if (lockRepeatY != curLockRepeatY)
        {
            m_pViewUI.list_notGet.repeatY = curLockRepeatY;
        }
        m_pViewUI.list_notGet.visible = unHireList.length != 0;

        _onResize(null);

        _lastScrollValue = m_pViewUI.panel.vScrollBar.value+1;
        m_pViewUI.panel.refresh();
    }

    private function _updateScrollState():void
    {
        m_pViewUI.panel.vScrollBar.mouseEnabled = true;
        m_pViewUI.panel.vScrollBar.mouseChildren = true;
        m_pViewUI.panel.vScrollBar.target = m_pViewUI.panel;
    }

    private function _onResize(e:Event) : void {

        m_pViewUI.box_notGet.y = m_pViewUI.box_hasGet.y + m_pViewUI.box_hasGet.displayHeight + 20-14;
    }

    private var _lastScrollValue:int;
    private function _onScrollChange(value:int) : void {
        if (_lastScrollValue == value) {
            return ;
        }
        _lastScrollValue = value;
        var lockCells:Vector.<Box> = m_pViewUI.list_notGet.cells;
        var unLockCells:Vector.<Box> = m_pViewUI.list_hasGet.cells;
        var allList:Vector.<Box> = lockCells.concat(unLockCells);
        var cell:PracticeListRenderUI;
        var isInRect:Boolean;
        for each (cell in allList) {
            if (cell && cell.dataSource) {
                isInRect = _isItemInScrollRect(cell);
                if (isInRect) {
                    if (cell.dataSource != null) {
                        _renderItem(cell);
                    }
                }
            }
        }
    }

    private var _tempItemPos:Point = new Point();
    private var _tempItemRect:Rectangle = new Rectangle();
    private function _isItemInScrollRect(cell:PracticeListRenderUI) : Boolean {
        var heroBox:Box = m_pViewUI.hero_box;
        if (heroBox == null) {
            return false;
        }
        _tempItemPos.x = cell.x;
        _tempItemPos.y = cell.y;
        var pos:Point = _tempItemPos;
        pos = cell.parent.localToGlobal(pos);
        pos = heroBox.globalToLocal(pos);
        var rect:Rectangle = _tempItemRect;
        rect.x = pos.x;
        rect.y = pos.y;
        rect.width = cell.width;
        rect.height = cell.height;

        if (m_pViewUI.panel.content.scrollRect && m_pViewUI.panel.content.scrollRect.intersects(rect)) {
            return true;
        }
        return false;
    }


    private function _renderItem(item:Component, idx:int = 0) : void {
        if (!(item is PracticeListRenderUI)) {
            return ;
        }
        var heroItem:PracticeListRenderUI = item as PracticeListRenderUI;
        var isInRect:Boolean = _isItemInScrollRect(heroItem);
        if (isInRect) {
            if(heroItem.dataSource is CPlayerBaseData || heroItem.dataSource is CPlayerHeroData){
                renderItem(heroItem);
                return;
            }
            renderItemRobot(heroItem);
        }
    }

    public function addDisplay(type:int) : void {
        m_viewType = type;
        this.loadAssetsByView( viewClass, _showDisplay );
    }

    protected function _showDisplay() : void {
        if ( onInitializeView() ) {
            invalidate();
            callLater( addToDisplay );
        } else {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    protected function addToDisplay() : void {
        if ( m_pViewUI ){
            uiCanvas.addPopupDialog( m_pViewUI );
            m_pViewUI.clip_title.index = m_viewType;
            _addEventListeners();
        }
    }

    public function removeDisplay() : void {
        if ( m_pViewUI ) {
            m_pViewUI.close( Dialog.CLOSE );
            _removeEventListeners();
            m_pViewUI.remove();
        }
    }

    private function _addEventListeners():void {

    }

    private function _removeEventListeners():void {

    }

    private function _onCloseHandler(type:String = null):void
    {
        if(closeHandler)
        {
            closeHandler.execute();
        }
    }

    public function get closeHandler() : Handler {
        return m_pCloseHandler;
    }

    public function set closeHandler( value : Handler ) : void {
        m_pCloseHandler = value;
    }

    private function get _playerData() : CPlayerData
    {
        return (system.stage.getSystem(CPlayerSystem ) as CPlayerSystem).playerData;
    }

    public function getRobotList():Array{
        var practiceTable : IDataTable = (system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem).getTable( KOFTableConstants.PRACTICE );
        var practiceArray : Array = practiceTable.toArray();
        var len:int = practiceArray.length;
        var item:PracticeOpponent;
        var heroList:Array = new Array();
        var list:Array = (system as CPracticeSystem).heroList;
        for( var i:int = 0; i<len; i++){
            item = practiceArray[i];
            if(item.Open || _playerData.heroList.hasHero(item.PlayerBasicID)){
                heroList.push( item );
            }
        }

        return heroList;
    }


    //设置 Item
    private function renderItem(heroItem:PracticeListRenderUI) : void {
        if (heroItem.dataSource == null) {
            return ;
        }
        var heroData:CPlayerHeroData = heroItem.dataSource as CPlayerHeroData;


        var isHeroExist:Boolean = heroData != null && heroData.hasData;
        var playerName:String = heroData.heroNameWithColor;

        heroItem.img_hero_mask.cacheAsBitmap = true;
        heroItem.img_hero.mask = heroItem.img_hero_mask;
        heroItem.clip_intelligence.index = heroData.qualityBaseType;
        heroItem.clip_career.index = heroData.job;
        heroItem.box_name.mouseChildren = true;
        (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).showCareerTips(heroItem.clip_career);
        heroItem.txt_heroName.isHtml = true;
//        heroItem.clip_effect.visible = isHeroExist && heroData.qualityBase == EHeroIntelligence.SS;
//        heroItem.clip_effect.autoPlay = isHeroExist && heroData.qualityBase == EHeroIntelligence.SS;
        heroItem.img_have.visible = false;
        heroItem.btn_change.visible = false;

//        if(heroItem.clip_effect)
//        {
//            heroItem.clip_effect.gotoAndPlay(1);
//        }

        if(isHeroExist)
        {
            heroItem.img_hero.url = CPlayerPath.getPeakUIHeroFacePath(heroData.prototypeID);
            heroItem.list_star.visible = true;
            heroItem.list_star_null.visible = true;
            heroItem.list_star.centerX = 0;
            heroItem.list_star_null.centerX = 0;

//            heroItem.clip_bg.index = (4-heroData.qualityBaseType);
            heroItem.clip_bg.index = heroData.qualityBaseType;

            var qualityLevelTxt:String = HtmlUtil.color("+"+heroData.qualityLevelSubValue,CQualityColor.QUALITY_COLOR_ARY[heroData.qualityLevelValue]);
            heroItem.txt_heroName.text = playerName + qualityLevelTxt;
            heroItem.txt_heroName.stroke = heroData.strokeColor;
            heroItem.box_name.centerX = 0;

            heroItem.list_star.dataSource = new Array(heroData.star);

            heroItem.addEventListener(MouseEvent.ROLL_OVER, _onRollOverHandler);
            heroItem.addEventListener(MouseEvent.ROLL_OUT, _onRollOutHandler);
        }
        else
        {
            heroItem.img_hero.url = CPlayerPath.getPeakUIHeroFacePath2(heroData.prototypeID);
            heroItem.list_star.visible = false;
            heroItem.list_star_null.visible = false;

            heroItem.clip_bg.index = 5;
            heroItem.txt_heroName.text = playerName;
            heroItem.box_name.centerX = 0;

        }

//        var playerSystem:CPlayerSystem = m_system.stage.getSystem(CPlayerSystem ) as CPlayerSystem;
//        heroItem.img_hero.toolTip = new Handler( playerSystem.showHeroTips, [heroData]);
    }

    private function renderItemRobot(heroItem:PracticeListRenderUI) : void {
        if (heroItem.dataSource == null) {
            return ;
        }
        var heroData:CPlayerHeroData = getPlayerHeroData(heroItem.dataSource);

        var isHeroExist:Boolean = heroData != null && heroData.hasData;
        var playerName:String = heroData.heroNameWithColor;

        heroItem.img_hero_mask.cacheAsBitmap = true;
        heroItem.img_hero.mask = heroItem.img_hero_mask;
        heroItem.clip_intelligence.index = heroData.qualityBaseType;
        heroItem.clip_career.index = heroData.job;
        heroItem.box_name.mouseChildren = true;
        (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).showCareerTips(heroItem.clip_career);
        heroItem.txt_heroName.isHtml = true;
//        heroItem.clip_effect.visible = isHeroExist && heroData.qualityBase == EHeroIntelligence.SS;
//        heroItem.clip_effect.autoPlay = isHeroExist && heroData.qualityBase == EHeroIntelligence.SS;
        heroItem.img_have.visible = _playerData.heroList.hasHero(heroData.prototypeID);
        heroItem.btn_change.visible = false;


//        if(heroItem.clip_effect)
//        {
//            heroItem.clip_effect.gotoAndPlay(1);
//        }

        heroItem.img_hero.url = CPlayerPath.getPeakUIHeroFacePath(heroData.prototypeID);
        heroItem.list_star.visible = true;
        heroItem.list_star_null.visible = true;
        heroItem.list_star.centerX = 0;
        heroItem.list_star_null.centerX = 0;

//        heroItem.clip_bg.index = (4-heroData.qualityBaseType);
        heroItem.clip_bg.index = heroData.qualityBaseType;

        heroItem.txt_heroName.text = playerName;
        heroItem.txt_heroName.stroke = heroData.strokeColor;
        heroItem.box_name.centerX = 0;

        heroItem.list_star.dataSource = new Array(heroData.star);

        heroItem.addEventListener(MouseEvent.ROLL_OVER, _onRollOverHandler);
        heroItem.addEventListener(MouseEvent.ROLL_OUT, _onRollOutHandler);
    }

    private function _onRollOverHandler(e:MouseEvent):void
    {
        var heroItem:PracticeListRenderUI = e.target as PracticeListRenderUI;
        if(heroItem)
        {
            heroItem.btn_change.visible = true;
        }
    }

    private function _onRollOutHandler(e:MouseEvent):void
    {
        var heroItem:PracticeListRenderUI = e.target as PracticeListRenderUI;
        if(heroItem)
        {
            heroItem.btn_change.visible = false;
        }
    }

    private function getPlayerHeroData(data:Object):CPlayerHeroData{
        var heroData:CPlayerHeroData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData.heroList.createHero(data.prototypeID);
        heroData.star = data.star;
        heroData.updateDataByData({ID:data.ID});
        return heroData;
    }
}
}
