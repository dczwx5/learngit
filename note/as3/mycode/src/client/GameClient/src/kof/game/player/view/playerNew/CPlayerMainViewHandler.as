//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/8/16.
 */
package kof.game.player.view.playerNew {

import flash.events.Event;

import kof.game.KOFSysTags;

import kof.game.bag.CBagEvent;
import kof.game.bag.CBagSystem;
import kof.game.bundle.CChildSystemBundleEvent;
import kof.game.common.view.CTweenViewHandler;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.event.CPlayerEvent;
import kof.game.player.view.playerNew.data.CTabInfoData;
import kof.game.player.view.playerNew.panel.CEquipDevelopPanel;
import kof.game.player.view.playerNew.panel.CHeroDevelopPanel;
import kof.game.player.view.playerNew.panel.CPlayerPanelBase;
import kof.game.player.view.playerNew.panel.CSkillDevelopPanel;
import kof.game.player.view.playerNew.panel.CSkillVideoPanel;
import kof.game.player.view.playerNew.util.CPlayerHelpHandler;
import kof.game.player.view.playerNew.util.CPlayerTipHandler;
import kof.game.player.view.playerNew.view.heroDevelop.CHeroQualitySuccViewHandler;
import kof.game.player.view.playerNew.view.heroDevelop.CHeroStarSuccViewHandler;
import kof.ui.imp_common.ItemUIUI;
import kof.ui.master.jueseNew.HeroInfoWinUI;
import kof.ui.master.jueseNew.panel.EquipUI;
import kof.ui.master.jueseNew.panel.HeroDevelopPanelUI;
import kof.ui.master.jueseNew.panel.SkillTrainViewUI;

import morn.core.components.Component;

import morn.core.components.ISelect;
import morn.core.handlers.Handler;

public class CPlayerMainViewHandler extends CTweenViewHandler {

    private var m_bViewInitialized : Boolean;
    private var m_pViewUI:HeroInfoWinUI;
    private var m_pCurrSelPanel:CPlayerPanelBase;
    private var m_iSelectedIndex:int;
    private var m_pCurrSelHeroData:CPlayerHeroData;// 当前选择格斗家数据

    private var m_pHeroDevelopPanel:CPlayerPanelBase;// 格斗家养成
    private var m_pEquipDevelopPanel:CPlayerPanelBase;// 装备养成
    private var m_pSkillDevelopPanel:CPlayerPanelBase;// 招式提升
    private var m_pSkillVideoPanel:CPlayerPanelBase;// 招式录像

    public function CPlayerMainViewHandler( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override protected function onSetup() : Boolean
    {
        var ret : Boolean = super.onSetup();
        ret = ret && onInitialize();
        if ( loadViewByDefault )
        {
            ret = ret && loadAssetsByView( viewClass );
            ret = ret && onInitializeView();
        }

        this.addBean(m_pHeroDevelopPanel = new CHeroDevelopPanel());
        this.addBean(m_pEquipDevelopPanel = new CEquipDevelopPanel());
        this.addBean(m_pSkillDevelopPanel = new CSkillDevelopPanel());
        this.addBean(m_pSkillVideoPanel = new CSkillVideoPanel());

        this.addBean(new CHeroQualitySuccViewHandler());
        this.addBean(new CHeroStarSuccViewHandler());

        return ret;
    }

    override public function get viewClass() : Array
    {
        return [ HeroInfoWinUI, HeroDevelopPanelUI,SkillTrainViewUI,EquipUI,ItemUIUI];
    }

    override  protected function get additionalAssets() : Array
    {
        return ["jueseNew.swf","frameclip_upgrade.swf","frameclip_item.swf"];
    }

    override protected function onAssetsLoadCompleted() : void
    {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean
    {
        if ( !super.onInitializeView() )
        {
            return false;
        }

        if ( !m_bViewInitialized )
        {
            if ( !m_pViewUI )
            {
                m_pViewUI = new HeroInfoWinUI();
                m_pViewUI.closeHandler = new Handler( _onClose );

                m_pHeroDevelopPanel.initializeView();
                m_pEquipDevelopPanel.initializeView();
                m_pSkillDevelopPanel.initializeView();
                m_pSkillVideoPanel.initializeView();

                m_bViewInitialized = true;
            }
        }

        return m_bViewInitialized;
    }

    public function addDisplay() : void
    {
        this.loadAssetsByView( viewClass, _showDisplay );
    }

    protected function _showDisplay() : void
    {
        if ( onInitializeView() )
        {
            invalidate();
            callLater( _addToDisplay );
        }
        else
        {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    private function _addToDisplay() : void
    {
        if(m_pViewUI.parent == null)
        {
            _initView();
            _onTabSelectedHandler();
            _addListeners();
        }

        showDialog(m_pViewUI);
    }

    private function _initView():void
    {
        _initTabBarData();
        _updateTabTipState();
        m_pViewUI.tab.selectedIndex = m_iSelectedIndex;
        _updateTabDisplayState();
    }

    private function _initTabBarData():void
    {
        var tabDataVec:Vector.<CTabInfoData> = _playerHelper.getTabInfoData();
        m_pViewUI.tab.dataSource = tabDataVec;

        var labels:String = "";
        for each(var info:CTabInfoData in tabDataVec)
        {
            labels += info.tabNameCN + ",";
        }

        m_pViewUI.tab.labels = labels.slice(0,labels.length-1);
    }

    // 小红点提示
    private function _updateTabTipState():void
    {
        m_pViewUI.img_dian_hero.visible = m_pCurrSelHeroData.hasData && _playerHelper.isHeroCanDevelop(m_pCurrSelHeroData);

        m_pViewUI.img_dian_equip.visible = _playerHelper.isChildSystemOpen(KOFSysTags.EQP_STRONG)
                && m_pCurrSelHeroData.hasData && (m_pEquipDevelopPanel as CEquipDevelopPanel).judgeRedPt();

        m_pViewUI.img_dian_skill.visible = _playerHelper.isChildSystemOpen(KOFSysTags.SKIL_LEVELUP)
                && m_pCurrSelHeroData.hasData && _playerTipHandler.isSkillCanDevelop(m_pCurrSelHeroData);
    }

    private function _addListeners():void
    {
        m_pViewUI.tab.addEventListener( Event.CHANGE, _onTabSelectedHandler);
        system.stage.getSystem(CBagSystem).addEventListener(CBagEvent.BAG_UPDATE, _onBagItemsChangeHandler);
        system.addEventListener(CPlayerEvent.EQUIP_DATA,_onEquipDataHandler);
        system.addEventListener(CPlayerEvent.PLAYER_LEVEL_UP,_onPlayerLevelUpHandler);
        system.addEventListener(CPlayerEvent.SKILL_BREAK,_onSkillUpdateHandler);
        system.addEventListener(CPlayerEvent.SKILL_LVUP,_onSkillUpdateHandler);
        system.addEventListener(CPlayerEvent.SKILL_DATA,_onSkillUpdateHandler);
        system.addEventListener(CPlayerEvent.PLAYER_SKILL,_onSkillUpdateHandler);
        system.addEventListener(CPlayerEvent.HERO_DATA,_onSkillUpdateHandler);
        system.addEventListener(CPlayerEvent.SWITCH_HERO, _onSwitchHeroHandler);
        system.addEventListener(CPlayerEvent.PLAYER_ORIGIN_CURRENCY, _onCurrencyUpdateHandler);
        system.addEventListener(CChildSystemBundleEvent.CHILD_BUNDLE_START, _onChildSystemOpenHandler);
    }

    private function _removeListeners():void
    {
        m_pViewUI.tab.removeEventListener( Event.CHANGE, _onTabSelectedHandler);
        system.stage.getSystem(CBagSystem).removeEventListener(CBagEvent.BAG_UPDATE, _onBagItemsChangeHandler);
        system.removeEventListener(CPlayerEvent.EQUIP_DATA,_onEquipDataHandler);
        system.removeEventListener(CPlayerEvent.PLAYER_LEVEL_UP,_onPlayerLevelUpHandler);
        system.removeEventListener(CPlayerEvent.SKILL_BREAK,_onSkillUpdateHandler);
        system.removeEventListener(CPlayerEvent.SKILL_LVUP,_onSkillUpdateHandler);
        system.removeEventListener(CPlayerEvent.SKILL_DATA,_onSkillUpdateHandler);
        system.removeEventListener(CPlayerEvent.PLAYER_SKILL,_onSkillUpdateHandler);
        system.removeEventListener(CPlayerEvent.HERO_DATA,_onSkillUpdateHandler);
        system.removeEventListener(CPlayerEvent.SWITCH_HERO, _onSwitchHeroHandler);
        system.removeEventListener(CPlayerEvent.PLAYER_ORIGIN_CURRENCY, _onCurrencyUpdateHandler);
        system.removeEventListener(CChildSystemBundleEvent.CHILD_BUNDLE_START, _onChildSystemOpenHandler);
    }

    override protected function updateDisplay():void
    {
    }

    /**
     * 切换页签处理
     * @param e
     */
    private function _onTabSelectedHandler(e:Event = null):void
    {
        if(m_pCurrSelPanel)
        {
            m_pCurrSelPanel.removeDisplay();
            m_pCurrSelPanel = null;
        }
        if( m_pSkillVideoPanel ){
            m_pSkillVideoPanel.removeDisplay();
        }


        if(m_pViewUI.tab.selectedIndex >= 0)
        {
            var tabData:CTabInfoData = m_pViewUI.tab.dataSource[m_pViewUI.tab.selectedIndex] as CTabInfoData;

            if(tabData)
            {
                _playerHelper.currSelPanelIndex = tabData.tabIndex;

                var panelClass:Class = tabData.panelClass;
                m_pCurrSelPanel = this.getBean(panelClass);
                m_pCurrSelPanel.data = currSelHeroData;
                m_pCurrSelPanel.addDisplay(m_pViewUI.box_panel);
            }
        }
    }
    /*展示技能video页面
    * */
    public function showSkillVideoView( videoIndex : int ):void{
        m_pCurrSelPanel.removeDisplay();
        ( m_pSkillVideoPanel as CSkillVideoPanel ).m__videoIndex = videoIndex;
        m_pSkillVideoPanel.data = currSelHeroData;
        m_pSkillVideoPanel.addDisplay(m_pViewUI.box_panel );
    }
    public function hideSkillVideoView():void{
        _onTabSelectedHandler();
    }
    public function get isEquipTrainPage() : Boolean {
        return m_pCurrSelPanel is CEquipDevelopPanel;
    }
    public function get equipTrainPage() : CEquipDevelopPanel {
        return m_pCurrSelPanel as CEquipDevelopPanel;
    }

    private function _onClose( type : String ) : void
    {
        removeDisplay();
    }

    public function showByPanelName(panelName:String, panelData:* = null):void
    {
        var arr:Vector.<CTabInfoData> = _playerHelper.getTabInfoData();
        var panel:CPlayerPanelBase;
        for(var i:int = 0; i < arr.length; i++)
        {
            var tabData:CTabInfoData = arr[i] as CTabInfoData;
            if(tabData.tabNameEN == panelName)
            {
                m_iSelectedIndex = i;
                panel = getBean(tabData.panelClass) as CPlayerPanelBase;
                break;
            }
        }

        if(panel)
        {
            panel.data = panelData;
            if(panelData is CPlayerHeroData)
            {
                currSelHeroData = panelData as CPlayerHeroData;
            }
        }

        if(isViewShow)
        {
            if(m_pViewUI.tab && m_pViewUI.tab.selectedIndex != m_iSelectedIndex)
            {
                m_pViewUI.tab.selectedIndex = m_iSelectedIndex;
            }
        }
        else
        {
            addDisplay();
        }
    }

    /**
     * 标签显示状态(已招募的格斗家显示所有标签，未招募则只显示第一个标签)
     */
    private function _updateTabDisplayState():void
    {
        var vec:Vector.<ISelect> = m_pViewUI.tab.items;
        var len:int = vec.length;
        if(currSelHeroData && currSelHeroData.hasData)
        {
            for(var i:int = 0; i < len; i++)
            {
                (vec[i ] as Component).visible = true;
            }
        }
        else
        {
            for(i = 0; i < len; i++)
            {
                (vec[i ] as Component).visible = i == 0;
            }
        }
    }


//====================================================监听==============================================================
    /**
     * 背包物品更新
     * @param e
     */
    private function _onBagItemsChangeHandler(e:CBagEvent):void
    {
        _updateTabTipState();
    }

    /**
     * 装备信息更新
     * @param e
     */
    private function _onEquipDataHandler(e:CPlayerEvent):void
    {
        m_pViewUI.img_dian_equip.visible = (m_pEquipDevelopPanel as CEquipDevelopPanel).judgeRedPt();
    }

    /**
     * 战队升级
     * @param e
     */
    private function _onPlayerLevelUpHandler(e:CPlayerEvent):void
    {
        m_pViewUI.img_dian_hero.visible = _playerHelper.isHeroCanDevelop(m_pCurrSelHeroData);
        m_pViewUI.img_dian_equip.visible = (m_pEquipDevelopPanel as CEquipDevelopPanel).judgeRedPt();
    }

    /**
     * 技能更新
     */
    private function _onSkillUpdateHandler(e:CPlayerEvent):void
    {
        m_pViewUI.img_dian_skill.visible = _playerTipHandler.isSkillCanDevelop(m_pCurrSelHeroData);
    }

    /**
     * 切换格斗家
     */
    private function _onSwitchHeroHandler(e:CPlayerEvent):void
    {
        var heroData:CPlayerHeroData = e.data as CPlayerHeroData;
        if(heroData)
        {
            currSelHeroData = heroData;
            _updateTabDisplayState();
        }
    }

    /**
     * 货币更新
     * @param e
     */
    private function _onCurrencyUpdateHandler(e:CPlayerEvent):void
    {
        _updateTabTipState();
    }

    public function removeDisplay() : void {
        closeDialog(_removeDisplayB)
    }
    private function _removeDisplayB() : void
    {
        if ( m_bViewInitialized )
        {
            _removeListeners();

            m_iSelectedIndex = 0;

            if(m_pCurrSelPanel)
            {
                m_pCurrSelPanel.removeDisplay();
                m_pCurrSelPanel = null;
            }

            (system.getHandler(CHeroQualitySuccViewHandler) as CHeroQualitySuccViewHandler).removeDisplay();
            (system.getHandler(CHeroStarSuccViewHandler) as CHeroStarSuccViewHandler).removeDisplay();
        }
    }

    private function _onChildSystemOpenHandler(e:CChildSystemBundleEvent):void
    {
        if( e.data == KOFSysTags.EQP_STRONG || e.data == KOFSysTags.SKIL_LEVELUP)
        {
            _initTabBarData();
            _updateTabTipState();
            _updateTabDisplayState();
        }
    }

//====================================================property==========================================================
    private function get _playerHelper():CPlayerHelpHandler
    {
        return system.getHandler(CPlayerHelpHandler) as CPlayerHelpHandler;
    }

    private function get _playerTipHandler():CPlayerTipHandler
    {
        return system.getHandler(CPlayerTipHandler) as CPlayerTipHandler;
    }

    public function get currSelHeroData():CPlayerHeroData
    {
        return m_pCurrSelHeroData;
    }

    public function set currSelHeroData(value:CPlayerHeroData):void
    {
        m_pCurrSelHeroData = value;

        if(m_bViewInitialized)
        {
            _updateTabTipState();
        }
    }

    public function get isViewShow():Boolean
    {
        return m_pViewUI && m_pViewUI.parent;
    }

    public function get viewUI():Component
    {
        return m_pViewUI;
    }

    override public function dispose():void
    {
        m_pViewUI = null;
        m_pCurrSelPanel = null;
        m_iSelectedIndex = 0;
        m_pHeroDevelopPanel = null;
        m_pEquipDevelopPanel = null;
        m_pSkillDevelopPanel = null;
        m_pSkillVideoPanel = null;
    }
}
}
