//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/4/19.
 */
package kof.game.artifact.view {

import QFLib.Graphics.RenderCore.starling.utils.DisplayUtil;
import QFLib.Utils.FileType;
import QFLib.Utils.HtmlUtil;

import flash.events.MouseEvent;
import flash.events.TextEvent;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.framework.IDataTable;
import kof.game.KOFSysTags;
import kof.game.artifact.*;
import kof.game.artifact.data.CArtifactData;
import kof.game.artifact.data.CArtifactSoulData;
import kof.game.artifact.view.soul.CArtifactSoulStrengthenView;
import kof.game.artifact.view.suit.CArtifactSuitTipsView;
import kof.game.artifact.view.suit.CArtifactSuitViewHandler;
import kof.game.bag.CBagEvent;
import kof.game.bag.CBagSystem;
import kof.game.common.CLang;
import kof.game.common.CSystemRuleUtil;
import kof.game.common.view.CTweenViewHandler;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.player.event.CPlayerEvent;
import kof.table.ArtifactBasics;
import kof.table.ArtifactBreakthrough;
import kof.table.ArtifactColour;
import kof.table.ArtifactIntensify;
import kof.table.Item;
import kof.ui.CUISystem;
import kof.ui.master.Artifact.ArtifactItemUI;
import kof.ui.master.Artifact.ArtifactUI;
import kof.util.CQualityColor;
import kof.util.TweenUtil;

import morn.core.components.Box;
import morn.core.components.Button;
import morn.core.components.Component;
import morn.core.components.FrameClip;
import morn.core.components.Label;
import morn.core.components.List;
import morn.core.handlers.Handler;

public class CArtifactViewHandler extends CTweenViewHandler {
    private var _m_uiView:ArtifactUI;

    private var m_pCloseHandler : Handler;

    private var m_Manager:CArtifactManager;

    private var m_handler:CArtifactHandler;

    private var m_curSelectData:CArtifactData;

    private var m_selectIndex:int;

    private var m_bViewInitialized : Boolean;

    private var m_soulArr:Array;

    public function CArtifactViewHandler() {
        super();
    }

    override public function get viewClass() : Array {
        return [ ArtifactUI ];
    }

    override protected function get additionalAssets() : Array
    {
        return ["frameclip_role.swf", "frameclip_artifact.swf"];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !m_bViewInitialized ) {

            if (!_m_uiView) {
                _m_uiView = new ArtifactUI();
                _m_uiView.closeHandler = new Handler( _onClose );
                m_Manager = system.getBean(CArtifactManager);
                m_handler = system.getBean(CArtifactHandler);
                initFun();
                m_bViewInitialized = true;
            }
        }

        return m_bViewInitialized;
    }

    public function initFun():void{
        _addEventListeners();

        _m_uiView.uiFrameClipBg.autoPlay = false;
        _m_uiView.uiFrameClipBg.visible = false;
        _m_uiView.list_active.dataSource = m_Manager.m_data;
        _m_uiView.list_active.selectedIndex = 0;
        CSystemRuleUtil.setRuleTips(_m_uiView.img_tips, CLang.Get("club_artifact_rule"));
        _showOrHideNextLevelAttr(false)
    }

    public function addDisplay() : void {
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
        setTweenData(KOFSysTags.ARTIFACT);
        showDialog(_m_uiView, false, _addToDisplayB);
    }
    protected function _addToDisplayB() : void {
        if ( _m_uiView ){
            _addEventListeners();
            _updateView(m_curSelectData);
        }
    }
    public function removeDisplay() : void {
        closeDialog(_removeDisplayB);
    }
    private function _removeDisplayB() : void {
        if ( _m_uiView ) {
            _removeEventListeners();
            _m_uiView.remove();
            _removeEffect();
        }
    }

    public function update(param:Object = null):void{
        if(_m_uiView && m_Manager.m_data){
            _m_uiView.list_active.dataSource = m_Manager.m_data;
            _updateView(m_Manager.m_data[m_selectIndex]);
        }
    }

    //显示洗练界面
    public function showPurifyView(data:CArtifactSoulData):void{
        (system.getBean(CArtifactSoulStrengthenView) as CArtifactSoulStrengthenView).update(data);
        (system.getBean(CArtifactSoulStrengthenView) as CArtifactSoulStrengthenView).addDisplay();
    }

    private function _onBagItemsChangeHandler(e:CBagEvent):void{
        if ( e.type == CBagEvent.BAG_UPDATE ) {
            update();
        }
    }

    private function renderNameItem( item : Component, idx : int ) : void {
        if ( !(item is Box) || item.dataSource == null) {
            return;
        }
        var pTable:IDataTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.PASSIVE_SKILL_PRO);
        ((item as Box).getChildAt(0) as Label).text = pTable.findByPrimaryKey( item.dataSource ).name;
    }

    private function renderTextItem( item : Component, idx : int ) : void {
        if ( !(item is Box) || item.dataSource == null) {
            return;
        }
        ((item as Box).getChildAt(0) as Label).text = item.dataSource.toString();
    }

    private function renderItem( item : Component, idx : int ) : void {
        if ( !(item is ArtifactItemUI) || item.dataSource == null) {
            return;
        }
        item.mouseChildren = false;
        var dataSource:CArtifactData = item.dataSource as CArtifactData;

        var artifactBasicsTable:IDataTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.ARTIFACTBASICS);
        (item as ArtifactItemUI).icon_lock.visible = dataSource.isLock;
        (item as ArtifactItemUI).img_mask.visible = (item as ArtifactItemUI).icon_lock.visible = dataSource.isLock;
        (item as ArtifactItemUI).img.url = _getURL((artifactBasicsTable.findByPrimaryKey( dataSource.artifactID ) as ArtifactBasics).iconSource);
        (item as ArtifactItemUI).clip_bg.index = (int(dataSource.qualityCfg.qualityColour));

        var artifactQuality:ArtifactColour = dataSource.colorCfg;
        (item as ArtifactItemUI).txt_name.stroke = artifactQuality.traceside;
        (item as ArtifactItemUI).txt_name.text = dataSource.htmlNameWithNum;

        var bool:Boolean = m_Manager.canUpgrade(dataSource, false) || m_Manager.canBreak(dataSource) || dataSource.isAnySoulCanBreak();
        (item as ArtifactItemUI).img_dian.visible = bool;
        var level:int = (dataSource["artifactLevel"]);
        (item as ArtifactItemUI).lv_txt.text = "LV" + level;
        (item as ArtifactItemUI).lv_txt.visible = !dataSource.isLock;
    }

    private function _getURL( sName : String ) : String
    {
        if ( !sName || !sName.length )
            return null;

        return "icon/artifact/icon/" + sName + "." + FileType.PNG;
    }

    private function _getNameURL( sName : String ) : String
    {
        if ( !sName || !sName.length )
            return null;

        return "icon/artifact/art_word/" + sName + "." + FileType.PNG;
    }

    private function _selectItemHandler( ...args) : void {
        var list : List = args[ 0 ] as List;
        if ( list.selectedItem == null )
            return;
        m_curSelectData = list.selectedItem as CArtifactData;
        m_selectIndex = args[ 1 ];

        _updateView( m_curSelectData );
        _playApearEffect();

        _removeEffect();

        if ( !App.loader.getResLoaded( "frameclip_artifact_" + m_curSelectData.artifactID + ".swf" ) ) {
            App.loader.loadAssets( [ "frameclip_artifact_" + m_curSelectData.artifactID + ".swf" ],
                    new Handler( _onAssetsFrameClipCompleted ), null, null, true );
        } else {
            _onAssetsFrameClipCompleted(null);
        }

        _m_uiView.img_artifact_tips.toolTip = new Handler(_onShowTipsFun);
        _m_uiView.btn_soulAllValue.toolTip = new Handler(_onShowTSuitipsFun);
     }

    private function _onAssetsFrameClipCompleted( ... args ):void{
        _m_uiView.frameClip_artifact.skin = "frameclip_artifact_"+m_curSelectData.artifactID;
        _m_uiView.frameClip_artifact.play();
    }

    private function _updateView(data:CArtifactData):void {
        m_curSelectData = data;

        //先隐藏4个状态的面板
        _m_uiView.box_break.visible = false;
        _m_uiView.box_upgrade.visible = false;
        _m_uiView.box_unlock.visible = false;
        _m_uiView.img_max.visible = false;
        _m_uiView.list_newValue.dataSource = [];

        //属性显示
        _m_uiView.list_value.dataSource = m_curSelectData.intensifyCfg.propertyValue;
        _m_uiView.list_valueName.dataSource = m_curSelectData.baseCfg.propertyID;

        //名字、等级、经验条
        var currMaxLevel:int =  m_curSelectData.getBreakThroughCfg().qualityMaxLevel;
        _m_uiView.txt_name.stroke = m_curSelectData.colorCfg.traceside;
        _m_uiView.txt_name.text = m_curSelectData.htmlNameWithNum;
        _m_uiView.txt_lv.text = CLang.Get("common_level_en",{v1:data.artifactLevel}) + "/" + currMaxLevel;
        _m_uiView.bar_exp.value = data.artifactExp / m_curSelectData.intensifyCfg.upgradeLevelExp;
        if (data.artifactExp >= m_curSelectData.intensifyCfg.upgradeLevelExp) {
            _m_uiView.bar_exp.label = "Max";
        }else{
            _m_uiView.bar_exp.label = data.artifactExp + "/" + m_curSelectData.intensifyCfg.upgradeLevelExp;
        }

        //战力显示
        _m_uiView.num_fight.num = m_curSelectData.fighting;
        callLater( function():void{
            (_m_uiView.num_fight.parent as Box).centerX = 0;
        });
        _m_uiView.num_total_fight.num = _manager.totalFighing;
        callLater( function():void{
            _m_uiView.num_total_fight.centerX = -4;
        });

        //更新神灵
        updateSoul(data);
        //神灵品质底
        _m_uiView.uiClipQualityBg.index = m_curSelectData.suitCfg == null ? 0 : m_curSelectData.suitCfg.qualityID;

        if (m_curSelectData.isLock) {//未解锁
            _showUnLockPanel();
        } else if (m_curSelectData.artifactExp < m_curSelectData.intensifyCfg.upgradeLevelExp) {//可培养
            _showTrainPanel();
        } else if (m_curSelectData.isCanBreak) {//可突破
            _showBreachPanel();
        } else if (data.isMaxQualityAndLevel) {//等级、品质达到上限
            _showMaxLevelAndQulityPanel();
        }
    }

    //显示解锁面板
    private function _showUnLockPanel():void {
        _m_uiView.box_unlock.visible = true;
        var artifactBasicsTable:IDataTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.ARTIFACTBASICS);
        var artifactBasics:ArtifactBasics = artifactBasicsTable.findByPrimaryKey( m_curSelectData.artifactID ) as ArtifactBasics;
        for(var i:int = 0; i < 1; i++){
            if(artifactBasics["conditionDesc"+(i+1)] != ""){
                _m_uiView["txt_unlock_condition_"+i].visible = true;
                _m_uiView["clip_unlock_condition_"+i].visible = true;
                _m_uiView["txt_unlock_condition_value_"+i ].visible = true;

                _m_uiView["txt_unlock_condition_"+i].text = artifactBasics["conditionDesc"+(i+1)] + " : ";
                var quality:int = artifactBasics["unlockValue"+(i+1)];
                if(artifactBasics["conditionType"+(i+1)] == 2){
                    var artifactQualityTable:IDataTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.ARTIFACTCOLOUR);
                    var artifactQuality:ArtifactColour = (artifactQualityTable.findByPrimaryKey(quality) as ArtifactColour);
                    _m_uiView["txt_unlock_condition_value_"+i].text = CLang.Get("artifact_soul_Level",{v1:artifactQuality.colour.split("0x")[1],v2:quality});
                }else{
                    var pPlayerSystem : CPlayerSystem = system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
                    var colour:String = pPlayerSystem.playerData.teamData.level>=quality ? "00ff00" : "ff0000";
                    _m_uiView["txt_unlock_condition_value_"+i].text = CLang.Get("artifact_soul_Level",{v1:colour,v2:quality});
                }

                _m_uiView["clip_unlock_condition_"+i].index = m_curSelectData.isopenConditionList[i] + 1;
            }else{
                _m_uiView["txt_unlock_condition_"+i].visible = false;
                _m_uiView["clip_unlock_condition_"+i].visible = false;
                _m_uiView["txt_unlock_condition_value_"+i ].visible = false;
            }
        }
        _m_uiView.btn_unlock.disabled = !m_curSelectData.isCanUnLock;
    }

    //显示培养面板
    private function _showTrainPanel() : void {
        _m_uiView.box_upgrade.visible = true;
        _initNextLevelView();

        //消耗
        var itemTable:IDataTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.ITEM);
        var itemCfg:Item = itemTable.findByPrimaryKey(_manager.constantCfg.artifactEnergyID);
        var obj:Object = {};
        obj.itemName = HtmlUtil.hrefAndU(itemCfg.name, null,  CQualityColor.getColorByQuality(itemCfg.quality - 1));
        obj.cost = _manager.constantCfg.onceConsume;
        obj.own = _playerData.currency.artifactEnergy;

        callLater(function():void {//需要延迟设置，否则报错
            _m_uiView.uiLabelTrainCost.textField.styleSheet = HtmlUtil.hrefSheet;
            _m_uiView.uiLabelTrainCost.textField.text = CLang.Get("artifact_train_cost", obj);
        });
        _m_uiView.uiBoxTrainCost.centerX = 5;
    }

    //显示突破面板
    private function _showBreachPanel() : void {
        _initNextLevelView();
        _m_uiView.box_break.visible = true;
        var artifactBreakthroughCfg:ArtifactBreakthrough = m_curSelectData.getBreakThroughCfg();
        _m_uiView.img_stoneIcon.skin = _getBreakthroughIconURL( artifactBreakthroughCfg.breakthroughItem.toString() );
        _m_uiView.txt_count.text = "x"+artifactBreakthroughCfg.nums;
        _m_uiView.linkButton_name.label = getItemTableByID( artifactBreakthroughCfg.breakthroughItem).name;
        _m_uiView.linkButton_name.clickHandler = new Handler(_manager.openShop);
        _m_uiView.txt_count.x = _m_uiView.linkButton_name.x + _m_uiView.linkButton_name.width + 1;
        _m_uiView.txt_myCount.x = _m_uiView.txt_count.x + _m_uiView.txt_count.width + 1;
        _m_uiView.box_break_cost.x = _m_uiView.btn_break.x + _m_uiView.btn_break.width * 0.5 - _m_uiView.box_break_cost.width * 0.5;

        //突破消耗
        _m_uiView.txt_myCount.text = CLang.Get("artifact_myStone",{v1:_manager.getOwnItemNum(m_curSelectData.getBreakThroughCfg().breakthroughItem)});
        //突破要求战队等级
        _m_uiView.uiLabelBreakNeedLevel.text = m_curSelectData.getBreakThroughCfg().Level.toString();

    }

    //显示满级面板
    private function _showMaxLevelAndQulityPanel() : void {
        _m_uiView.img_max.visible = m_curSelectData.artifactExp >= m_curSelectData.intensifyCfg.upgradeLevelExp;//显示max图片
    }

    //下一级属性
    private function _initNextLevelView():void {
        var nextArtifactIntensify: ArtifactIntensify =  m_curSelectData.nextIntensifyCfg;
        var len:int = nextArtifactIntensify == null ? 0 : nextArtifactIntensify.propertyValue.length;
        var arr:Array = [];
        for(var i:int = 0; i<len; i++)
        {
            arr.push(nextArtifactIntensify.propertyValue[i] + "(+" + (nextArtifactIntensify.propertyValue[i] - m_curSelectData.intensifyCfg.propertyValue[i]) + ")");
        }
        _m_uiView.list_newValue.dataSource = arr;
    }

    private function _showOrHideNextLevelAttr(isShow:Boolean):void {
        _m_uiView.list_newValue.visible = isShow;
    }

    private function getItemTableByID(id:int) : Item{
        var itemTable:IDataTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.ITEM);
        return itemTable.findByPrimaryKey(id);
    }

    //更新神灵
    private function updateSoul(data:CArtifactData):void{
        if(m_soulArr == null){
            m_soulArr = new Array();
        }

        var item:CSoulItem;
        var soulData:CArtifactSoulData;
        for (var i:int = 0; i<3; i++){
            soulData = data.soulListData.list[i];
            if(m_soulArr[i] == null){
                item = new CSoulItem(system as CArtifactSystem,_m_uiView["soul_item_"+i ],soulData,showPurifyView);
                m_soulArr.push(item);
            }else{
                item = m_soulArr[i];
                item.update(soulData);
            }
        }
    }

    private function listClickFun(e:MouseEvent):void {

        var btn : Button = e.target as Button;
        switch ( btn ) {
            case _m_uiView.btn_unlock:
                m_handler.artifactOpenRequest( m_curSelectData.artifactID );
                break;
            case _m_uiView.btn_once:
                if(_playerData.currency.artifactEnergy < _manager.constantCfg.onceConsume) {
                    _manager.showQuickBuyShop(_manager.constantCfg.artifactEnergyID, 1);
                    (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert(CLang.Get("artifact_msg"));
                    return;
                }
                m_handler.artifactUpgradeRequest(m_curSelectData.artifactID,1);
                break;
            case _m_uiView.btn_uplevel:
                if(_playerData.currency.artifactEnergy < m_curSelectData.levelUpCostItemCount ){
                    (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert(CLang.Get("artifact_msg"));
                    return;
                }
                m_handler.artifactUpgradeRequest(m_curSelectData.artifactID,0);
                break;
            case _m_uiView.btn_break:
                if(_manager.getOwnItemNum(m_curSelectData.getBreakThroughCfg().breakthroughItem) < m_curSelectData.getBreakThroughCfg().nums){
                    (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert(CLang.Get("playerCard_prop_notEnough"));
                    return;
                }
                m_handler.artifactBreakthroughRequest(m_curSelectData.artifactID);
                break;
            case _m_uiView.btn_soulAllValue:
                (system.getBean(CArtifactSuitViewHandler) as CArtifactSuitViewHandler).update(m_curSelectData);
                (system.getBean(CArtifactSuitViewHandler) as CArtifactSuitViewHandler).addDisplay();
                break;
        }
    }



    private function _addEventListeners():void {
        _m_uiView.list_active.renderHandler = new Handler( renderItem );
        _m_uiView.list_active.selectHandler = new Handler( _selectItemHandler,[_m_uiView.list_active] );
        _m_uiView.addEventListener(MouseEvent.CLICK, listClickFun, false, 0, true);
        (system.stage.getSystem(CBagSystem) as CBagSystem).listenEvent(_onBagItemsChangeHandler);
        _m_uiView.list_value.renderHandler = new Handler(renderTextItem);
        _m_uiView.list_newValue.renderHandler = new Handler(renderTextItem);
        _m_uiView.list_valueName.renderHandler = new Handler(renderNameItem);
        _m_uiView.btn_uplevel.addEventListener(MouseEvent.ROLL_OVER, _onBtnOverOrOut);
        _m_uiView.btn_uplevel.addEventListener(MouseEvent.ROLL_OUT, _onBtnOverOrOut);
        _m_uiView.btn_break.addEventListener(MouseEvent.ROLL_OVER, _onBtnOverOrOut);
        _m_uiView.btn_break.addEventListener(MouseEvent.ROLL_OUT, _onBtnOverOrOut);
        _m_uiView.uiLabelTrainCost.addEventListener(TextEvent.LINK, _onTextLink);
        system.addEventListener(CArtifactEvent.ARTIFACTUPDATE, update);
        (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).addEventListener(CPlayerEvent.PLAYER_ARTIFACT,_onPlayerDataHandler);
    }

    private function _removeEventListeners():void {
        if (_m_uiView) {
            _m_uiView.removeEventListener(MouseEvent.CLICK, listClickFun);
            _m_uiView.btn_uplevel.removeEventListener(MouseEvent.ROLL_OVER, _onBtnOverOrOut);
            _m_uiView.btn_uplevel.removeEventListener(MouseEvent.ROLL_OUT, _onBtnOverOrOut);
            _m_uiView.btn_break.removeEventListener(MouseEvent.ROLL_OVER, _onBtnOverOrOut);
            _m_uiView.btn_break.removeEventListener(MouseEvent.ROLL_OUT, _onBtnOverOrOut);
            _m_uiView.uiLabelTrainCost.removeEventListener(TextEvent.LINK, _onTextLink);
            system.removeEventListener(CArtifactEvent.ARTIFACTUPDATE, update);
            (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).removeEventListener(CPlayerEvent.PLAYER_ARTIFACT,_onPlayerDataHandler);
//            _m_uiView.img_artifact_tips.toolTip = null;
//            _m_uiView.btn_soulAllValue.toolTip = null;
             }

        (system.stage.getSystem(CBagSystem) as CBagSystem).unListenEvent(_onBagItemsChangeHandler);
    }

    private function _onPlayerDataHandler(e:CPlayerEvent):void{
        if ( e.type == CPlayerEvent.PLAYER_ARTIFACT ) {
            update();
        }
    }

    private function _onTextLink( event : TextEvent ) : void {
        _manager.openShop();
    }

    private function _onBtnOverOrOut( event : MouseEvent ) : void {
        _showOrHideNextLevelAttr(event.type == MouseEvent.ROLL_OVER);
    }

    public function get closeHandler() : Handler {
        return m_pCloseHandler;
    }

    public function set closeHandler( value : Handler ) : void {
        m_pCloseHandler = value;
    }

    private function _onClose( type : String ) : void {
        switch ( type ) {
            default:
                if ( this.closeHandler ) {
                    this.closeHandler.execute();
                }
                break;
        }
    }

    private function get _playerData() : CPlayerData {
        var _playerSystem:CPlayerSystem = ( system as CAppSystem ).stage.getSystem( CPlayerSystem ) as CPlayerSystem;
        return ( _playerSystem.getBean( CPlayerManager ) as CPlayerManager ).playerData;
    }

    private function get _manager():CArtifactManager{
        var manager:CArtifactManager = system.getHandler(CArtifactManager) as CArtifactManager;
        return manager;
    }

    private function _getBreakthroughIconURL( sName : String ) : String
    {
        if ( !sName || !sName.length )
            return null;

        return "icon/artifact/breakthroughIcon/" + sName + "." + FileType.PNG;
    }

    private var m_tipsView:CArtifactTipsView;
    private function _onShowTipsFun():void{
        if (m_tipsView == null) {
            m_tipsView = new CArtifactTipsView();
        }

        m_tipsView.showTips(m_curSelectData,system as CArtifactSystem);
    }

    private var _m_pSuitTipsView:CArtifactSuitTipsView;
    private function _onShowTSuitipsFun():void{
        if (_m_pSuitTipsView == null) {
            _m_pSuitTipsView = new CArtifactSuitTipsView(system);
        }

        _m_pSuitTipsView.showTips(m_curSelectData);
    }

    //播放神器解锁成功动画
    private var _m_pUnLockEff:FrameClip;
    public function playUnlockEffect():void {
        var effectName:String = "frameclip_artifact_unlock.swf";
        if (!App.loader.getResLoaded(effectName) ) {
            App.loader.loadAssets( [effectName], new Handler( _onUnlockSwfLoaded, [m_curSelectData.artifactID]), null, null, true );
        } else {
            _onUnlockSwfLoaded(m_curSelectData.artifactID);
        }
    }

    private function _onUnlockSwfLoaded( ... args ):void {
        if (_m_uiView == null || _m_uiView.stage == null ||  args[0] != m_curSelectData.artifactID) {
            return;
        }
        if (_m_pUnLockEff == null) {
            _m_pUnLockEff = new FrameClip("frameclip_jiesuochenggong");
            _m_pUnLockEff.interval = 42;
            _m_pUnLockEff.x = 414;
            _m_pUnLockEff.y = 280;
            _m_pUnLockEff.mouseChildren = _m_pUnLockEff.mouseEnabled = false;
        }

        _m_uiView.addChild(_m_pUnLockEff);
        _m_pUnLockEff.playFromTo(0, null, new Handler(function():void {
            _m_pUnLockEff.stop();
            DisplayUtil.removeFromParent(_m_pUnLockEff);
        }));
    }

    //播放神器突破成功动画
    private var _m_pBreakEff:FrameClip;
    public function playBreakEffect():void {
        var effectName:String = "frameclip_artifact_break.swf";
        if (!App.loader.getResLoaded(effectName) ) {
            App.loader.loadAssets( [effectName], new Handler( _onBreakSwfLoaded, [m_curSelectData.artifactID]), null, null, true );
        } else {
            _onBreakSwfLoaded(m_curSelectData.artifactID);
        }
    }

    private function _onBreakSwfLoaded( ... args ):void {
        if (_m_uiView == null || _m_uiView.stage == null || args[0] != m_curSelectData.artifactID) {
            return;
        }
        if (_m_pBreakEff == null) {
            _m_pBreakEff = new FrameClip("frameclip_tupochenggong");
            _m_pBreakEff.interval = 42;
            _m_pBreakEff.x = 414;
            _m_pBreakEff.y = 280;
            _m_pBreakEff.mouseChildren = _m_pBreakEff.mouseEnabled = false;
        }

        _m_uiView.addChild(_m_pBreakEff);
        _m_pBreakEff.playFromTo(0, null, new Handler(function():void {
            _m_pBreakEff.stop();
            DisplayUtil.removeFromParent(_m_pBreakEff);
        }));
    }

    private var _m_iTimeId:uint;
    //播放神器切换显示的动画
    private function _playApearEffect():void {

        //圆圈开始动
        TweenUtil.kill(_m_uiView.uiImgCircleBg);
        _m_uiView.uiImgCircleBg.alpha = 0;
        _m_uiView.uiImgCircleBg.scaleX = _m_uiView.uiImgCircleBg.scaleY = 0.3;
        TweenUtil.tween(_m_uiView.uiImgCircleBg, 0.5, {alpha:1, scaleX: 1, scaleY: 1});

        //3个神器动
        var item:CSoulItem;
        var targetX:int;
        var targetY:int;
        for (var i:int = 0; i < m_soulArr.length; i++) {
            item = m_soulArr[i];
            item.ui.x = 379;
            item.ui.y = 242;
            item.ui.alpha = 0;
            targetX = item.ui.comXml.@x[0];
            targetY = item.ui.comXml.@y[0];
            TweenUtil.kill(item.ui);
            TweenUtil.tween(item.ui, 0.5, {delay: 0.5, alpha: 1, x: targetX, y: targetY});
        }


        //中间套装动画播放
        var delay:Number;
        clearTimeout(_m_iTimeId);
        _m_uiView.uiFrameClipBg.visible = false;
        _m_uiView.uiFrameClipBg.alpha = 1;
        TweenUtil.kill(_m_uiView.uiFrameClipBg);
        if (m_curSelectData.suitID > 0) {
            _m_iTimeId = setTimeout(function():void{
                _m_uiView.uiFrameClipBg.visible = true;
                _m_uiView.uiFrameClipBg.playFromTo(0, null, new Handler(function():void{
                    _m_uiView.uiFrameClipBg.stop();
                    TweenUtil.tween(_m_uiView.uiFrameClipBg, 0.5, {alpha: 0, onComplete: function():void{
                        _m_uiView.uiFrameClipBg.visible = false;
                    }})
                }));
            }, 1000);
            delay = 1.5;
        } else {
            delay = 0.9;
        }

        //动画播放完，套装品质Clip、神器动画显示出来：
        TweenUtil.kill(_m_uiView.uiClipQualityBg);
        _m_uiView.uiClipQualityBg.alpha = 0;
        TweenUtil.tween(_m_uiView.uiClipQualityBg, 0.5, {delay: delay, alpha: 1});

        TweenUtil.kill(_m_uiView.frameClip_artifact);
        _m_uiView.frameClip_artifact.alpha = 0;
        TweenUtil.tween(_m_uiView.frameClip_artifact, 0.5, {delay:delay, alpha: 1});
    }

    private function _removeEffect():void {
        //隐藏掉解锁成功、升阶成功动画：
        if (_m_pBreakEff != null) {
            _m_pBreakEff.stop();
            DisplayUtil.removeFromParent(_m_pBreakEff);
        }
        if (_m_pUnLockEff != null) {
            _m_pUnLockEff.stop();
            DisplayUtil.removeFromParent(_m_pUnLockEff);
        }
    }
}
}
