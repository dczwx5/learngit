//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/6/26.
 */
package kof.game.gem.view {

import flash.events.MouseEvent;
import flash.geom.Point;

import kof.SYSTEM_ID;

import kof.framework.IDatabase;

import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.character.property.CBasePropertyData;
import kof.game.common.CItemUtil;
import kof.game.common.CLang;
import kof.game.common.CSystemRuleUtil;
import kof.game.common.data.CAttributeBaseData;
import kof.game.common.view.CTweenViewHandler;
import kof.game.gem.CGemHelpHandler;
import kof.game.gem.CGemManagerHandler;
import kof.game.gem.CGemNetHandler;
import kof.game.gem.CGemUIHandler;
import kof.game.gem.CGemUIHandler;
import kof.game.gem.Enum.EGemHoleState;
import kof.game.gem.Enum.EGemPageType;
import kof.game.gem.Enum.EGemUpgradeType;
import kof.game.gem.data.CGemBagData;
import kof.game.gem.data.CGemConst;
import kof.game.gem.data.CGemData;
import kof.game.gem.data.CGemHoleData;
import kof.game.gem.event.CGemEvent;
import kof.game.item.CItemData;
import kof.game.item.CItemData;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardData;
import kof.game.item.view.tips.CItemTipsView;
import kof.game.player.CPlayerSystem;
import kof.game.player.event.CPlayerEvent;
import kof.game.shop.enum.EShopType;
import kof.table.Gem;
import kof.ui.CUISystem;
import kof.ui.master.Gem.GemMainWinUI;
import kof.ui.master.Gem.GemOperateInfoViewUI;
import kof.ui.master.Gem.GemOperateInfoViewUI;

import morn.core.components.Button;
import morn.core.components.Component;

import morn.core.handlers.Handler;

/**
 * 宝石系统主界面
 */
public class CGemMainViewHandler extends CTweenViewHandler {

    private var m_bViewInitialized : Boolean;

    private var m_pViewUI : GemMainWinUI;
    private var m_pCloseHandler : Handler;
    private var m_pLastSelBtn:Button;

    private var m_iCurrSelPage:int;
    private var m_pPropertyData:CBasePropertyData;

    public function CGemMainViewHandler( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override protected function onSetup() : Boolean
    {
        var ret : Boolean = super.onSetup();

        return ret;
    }

    override public function get viewClass() : Array
    {
        return [GemMainWinUI];
    }

    override protected function get additionalAssets():Array
    {
        return ["Gem.swf", "frameclip_gem.swf", "frameclip_item.swf"];
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
                m_pViewUI = new GemMainWinUI();
                m_pViewUI.btn_close.clickHandler = new Handler( _onClose );

                m_pViewUI.btnGroup.selectedIndex = -1;
                m_pViewUI.btnGroup.selectHandler = new Handler(_onSelectHandler);
                m_pViewUI.list_gem.renderHandler = new Handler(CItemUtil.getItemRenderFunc(system));
                m_pViewUI.btn_oneKeyEmbed.clickHandler = new Handler(_onOneKeyEmbedHandler);
                m_pViewUI.btn_oneKeyLevelUp.clickHandler = new Handler(_onOneKeyUpgradeHandler);
                m_pViewUI.btn_levelUp.clickHandler = new Handler(_onClickGemMergeHandler);
                m_pViewUI.btn_buy.clickHandler = new Handler(_onClickGemBuyHandler);
                m_pViewUI.btn_suit.clickHandler = new Handler(_onClickSuitHandler);

                CSystemRuleUtil.setRuleTips(m_pViewUI.img_tip, CLang.Get("gem_rule"));

//                for(var i:int = 1; i <= CGemConst.MaxHoleNum; i++)
//                {
//                    (m_pViewUI["view_gemInfo" + i ] as GemOperateInfoViewUI).dataSource = i;
//                }

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
//            invalidate();
            callLater( _tweenShow );
        }
        else
        {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    private function _tweenShow():void
    {
        setTweenData(KOFSysTags.GEM);
        showDialog(m_pViewUI, false, _addToDisplay);
    }

    private function _addToDisplay() : void
    {
        uiCanvas.addDialog( m_pViewUI );

        _initView();
        _addListeners();
        _reqStationInfo();
    }

    private function _reqStationInfo():void
    {
    }

    private function _addListeners():void
    {
        system.addEventListener(CGemEvent.UpdateGemHoleInfo, _onGemHoleInfoUpdateHandler);
        system.addEventListener(CGemEvent.UpdateGemBagInfo, _onGemBagUpdateHandler);
        system.addEventListener(CGemEvent.UpdateGemCategoryList, _onGemMergeRedTipHandler);
        system.stage.getSystem(CPlayerSystem).addEventListener(CPlayerEvent.PLAYER_LEVEL_UP,_onUpdateTipInfoHandler);

        for(var i:int = 1; i <= CGemConst.MaxHoleNum; i++)
        {
            m_pViewUI["view_gemInfo" + i ].addEventListener(MouseEvent.CLICK, _onClickGemHandler);
        }
    }

    private function _removeListeners():void
    {
        system.removeEventListener(CGemEvent.UpdateGemHoleInfo, _onGemHoleInfoUpdateHandler);
        system.removeEventListener(CGemEvent.UpdateGemBagInfo, _onGemBagUpdateHandler);
        system.removeEventListener(CGemEvent.UpdateGemCategoryList, _onGemMergeRedTipHandler);
        system.stage.getSystem(CPlayerSystem).removeEventListener(CPlayerEvent.PLAYER_LEVEL_UP,_onUpdateTipInfoHandler);

        for(var i:int = 1; i <= CGemConst.MaxHoleNum; i++)
        {
            m_pViewUI["view_gemInfo" + i ].removeEventListener(MouseEvent.CLICK, _onClickGemHandler);
        }
    }

    private function _initView():void
    {
        _updateTotalCombatInfo();
        _updateBagListInfo();
        _onUpdateTipInfoHandler();
        _onGemMergeRedTipHandler();

        m_pViewUI.box_addPercent.visible = false;

        m_pViewUI.btnGroup.selectedIndex = 0;
    }

    /**
     * 宝石所加总战力
     */
    private function _updateTotalCombatInfo():void
    {
        var attrDatas:Array = _helper.getTotalAttrData();
        if(attrDatas && attrDatas.length)
        {
            // 战力
            if(m_pPropertyData == null)
            {
                m_pPropertyData = new CBasePropertyData();
                m_pPropertyData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;
            }

            m_pPropertyData.clearData();
            for each(var attrData:CAttributeBaseData in attrDatas)
            {
                var obj:Object = {};
                obj[attrData.attrNameEN] = attrData.attrBaseValue;
                m_pPropertyData.updateDataByData(obj);
            }

            m_pViewUI.txt_totalCombat.text = "+" + m_pPropertyData.getBattleValue();
        }
        else
        {
            m_pViewUI.txt_totalCombat.text = "+0";
        }
    }

    /**
     * 镶嵌信息
     */
    private function _updateEmbedInfo():void
    {
        var page:int = m_pViewUI.btnGroup.selectedIndex + 1;
        for(var i:int = 1; i <= CGemConst.MaxHoleNum; i++)
        {
            var holeData:CGemHoleData = _helper.getGemHoleDataByHoleIndex(page, i);
            _updateSingleGemInfo(i, holeData)
        }
    }

    private function _updateSingleGemInfo(holeIndex:int, data:CGemHoleData):void
    {
        var view:GemOperateInfoViewUI = m_pViewUI["view_gemInfo"+holeIndex] as GemOperateInfoViewUI;

        // 清除之前的
        view.btn_add.clickHandler = null;
        view.btn_levelUp.clickHandler = null;
        view.img_gem.toolTip = null;

        if(data)
        {
            view.txt_noGem.visible = false;
            view.txt_clickEmbed.visible = false;
            view.img_lock.visible = false;
            view.dataSource = data;
            if(data.state == EGemHoleState.Type_notEmbed)// 已开启未镶嵌
            {
                view.img_gem.url = "";
                view.btn_levelUp.visible = false;
                view.frameClip_levelUp.autoPlay = false;
                view.frameClip_levelUp.visible = false;

                var isCanEmbed:Boolean = _helper.isCanEmbed(data.gemPointConfigID);
                view.frameClip_embed.autoPlay = isCanEmbed;
                view.frameClip_embed.visible = isCanEmbed;
                view.btn_add.visible = isCanEmbed;
                view.txt_clickEmbed.visible = isCanEmbed;
                view.txt_noGem.visible = !isCanEmbed;
                view.txt_noGem.text = "无宝石可镶嵌";

                view.btn_add.clickHandler = new Handler(_onClickEmbedHandler, [data.gemPointConfigID, holeIndex]);
            }
            else if(data.state == EGemHoleState.Type_hasEmbed)// 已镶嵌
            {
                var gem:Gem = _helper.getGemConfigInfoById(data.gemConfigID);
                view.img_gem.url = gem == null ? "" : ("icon/gem/small/" + gem.icon + ".png");
                view.img_gem.y = 14;
                view.frameClip_embed.autoPlay = false;
                view.frameClip_embed.visible = false;
                view.btn_add.visible = false;

                var isCanUpgrade:Boolean = _helper.isCanUpgrade(data.gemPointConfigID, data.gemConfigID);

                view.txt_noGem.visible = gem != null && !isCanUpgrade;
                view.txt_noGem.text = gem.name;

                view.frameClip_levelUp.autoPlay = isCanUpgrade;
                view.frameClip_levelUp.visible = isCanUpgrade;
                view.btn_levelUp.visible = isCanUpgrade;

                if(view.btn_levelUp.clickHandler == null)
                {
                    view.btn_levelUp.clickHandler = new Handler(_onClickUpgradeHandler, [data.gemPointConfigID]);
                }

                if(view.img_gem.toolTip == null)
                {
                    var dateBase:IDatabase = system.stage.getSystem(IDatabase) as IDatabase;
                    var itemData:CItemData = CRewardData.CreateRewardData(data.gemConfigID, 1, dateBase);
                    view.img_gem.toolTip = new Handler( _showItemTips, [view.img_gem, itemData] );
                }
            }
        }
        else
        {
            _clear(view, holeIndex);
        }
    }

    private function _clear(view:GemOperateInfoViewUI, holeIndex:int = 0):void
    {
        view.img_gem.url = "";
        view.txt_noGem.visible = false;
        view.txt_clickEmbed.visible = false;
        view.img_lock.visible = true;
        view.btn_levelUp.visible = false;
        view.frameClip_levelUp.autoPlay = false;
        view.frameClip_levelUp.stop();
        view.frameClip_levelUp.visible = false;
        view.frameClip_embed.autoPlay = false;
        view.frameClip_embed.stop();
        view.frameClip_embed.visible = false;
        view.btn_add.visible = false;
        view.btn_add.clickHandler = null;
        view.btn_levelUp.clickHandler = null;
        view.dataSource = null;
        view.img_gem.toolTip = null;

        if(holeIndex)
        {
            var openLevel:int = _helper.getHoleIndexOpenLevel(m_iCurrSelPage, holeIndex);
            view.txt_noGem.visible = true;
            view.txt_noGem.text = openLevel + "级解锁";
        }
    }

    private function _showItemTips(item:Component, itemData:CItemData) : void
    {
        (system.stage.getSystem(CItemSystem) as CItemSystem).addTips(CItemTipsView, item, [itemData]);
    }

    /**
     * 点击打开小界面
     * @gemPointConfigID 宝石孔配置表ID
     * @holeIndex 宝石孔位置
     */
    private function _onClickEmbedHandler(gemPointConfigID:int, holeIndex:int):void
    {
        var canEmbedGems:Array = _helper.getCanEmbedGems(gemPointConfigID);
        if(canEmbedGems && canEmbedGems.length == 1)
        {
            var bagData:CGemBagData = canEmbedGems[0] as CGemBagData;
            if(bagData)
            {
                (system.getHandler(CGemNetHandler) as CGemNetHandler).gemEmbedReplaceRequest(gemPointConfigID, bagData.gemConfigID);
            }
        }
        else
        {
            var view:CGemEmbedBagViewHandler = system.getHandler(CGemEmbedBagViewHandler) as CGemEmbedBagViewHandler;
            var holeView:GemOperateInfoViewUI = m_pViewUI["view_gemInfo" + holeIndex] as GemOperateInfoViewUI;
            var point:Point = holeView.localToGlobal(new Point(holeView.width, 0));

            if(view.gemHoleConfigID != gemPointConfigID)
            {
                view.gemHoleConfigID = gemPointConfigID;
                view.addDisplay(point.x, point.y);
            }
        }
    }

    /**
     * 点击升级
     * @gemPointConfigID 宝石孔配置表ID
     */
    private function _onClickUpgradeHandler(gemPointConfigID:int):void
    {
        (system.getHandler(CGemNetHandler) as CGemNetHandler).gemUpgradeRequest(EGemUpgradeType.Type_Hole, gemPointConfigID);
    }

    private function _onClickGemHandler(e:MouseEvent):void
    {
        var view:GemOperateInfoViewUI = e.currentTarget as GemOperateInfoViewUI;
        if(view && (e.target == view || e.target == view.img_gem))
        {
            var holeData:CGemHoleData = view.dataSource as CGemHoleData;
            if(holeData)
            {
                var bagView:CGemEmbedBagViewHandler = system.getHandler(CGemEmbedBagViewHandler) as CGemEmbedBagViewHandler;
                var point:Point = view.localToGlobal(new Point(view.width, 0));

                if(bagView.gemHoleConfigID != holeData.gemPointConfigID)
                {
                    bagView.gemHoleConfigID = holeData.gemPointConfigID;
                    bagView.addDisplay(point.x, point.y);
                }
            }
        }
    }

    private function _updatePageLogo():void
    {
        m_pViewUI.clip_logo.index = m_iCurrSelPage - 1;
    }

    /**
     * 战力和属性信息
     */
    private function _updateCombatAndAttrInfo():void
    {
        m_pViewUI.txt_pageName.text = _helper.getPageNameByType(m_iCurrSelPage);

        // 属性
        var attrDatas:Array = _helper.getAttrDataByPage(m_iCurrSelPage);
        var attrData:CAttributeBaseData = attrDatas.length >= 1 ? attrDatas[0] : null;
        m_pViewUI.txt_attrName1.text = attrData == null ? "" : attrData.attrNameCN;
        m_pViewUI.txt_attrValue1.text = attrData == null ? "" : attrData.attrBaseValue + "";

        attrData = attrDatas.length >= 2 ? attrDatas[1] : null;
        m_pViewUI.txt_attrName2.text = attrData == null ? "" : attrData.attrNameCN;
        m_pViewUI.txt_attrValue2.text = attrData == null ? "" : attrData.attrBaseValue + "";

        attrData = attrDatas.length >= 3 ? attrDatas[2] : null;
        m_pViewUI.txt_attrName3.text = attrData == null ? "" : attrData.attrNameCN;
        m_pViewUI.txt_attrValue3.text = attrData == null ? "" : attrData.attrBaseValue + "";

        // 战力
        if(m_pPropertyData == null)
        {
            m_pPropertyData = new CBasePropertyData();
            m_pPropertyData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;
        }

        m_pPropertyData.clearData();
        for each(attrData in attrDatas)
        {
            var obj:Object = {};
            obj[attrData.attrNameEN] = attrData.attrBaseValue;
            m_pPropertyData.updateDataByData(obj);
        }

        m_pViewUI.num_combat.num = m_pPropertyData.getBattleValue();
        m_pViewUI.box_combat.centerX = 0;
    }

    /**
     * 宝石背包信息
     */
    private function _updateBagListInfo():void
    {
        var arr:Array = _helper.getBagRenderListData();
        if(arr.length < 12)
        {
            for(var i:int = arr.length; i < 12; i++)
            {
                arr.push({});
            }
        }

        m_pViewUI.list_gem.dataSource = arr;
    }

    private function _updateBtnState():void
    {
        // TODO
    }

    public function removeDisplay() : void
    {
        closeDialog(_remove);
    }

    private function _remove():void
    {
        if ( m_bViewInitialized )
        {
            _removeListeners();

            for(var i:int = 1; i <= CGemConst.MaxHoleNum; i++)
            {
                var view:GemOperateInfoViewUI = m_pViewUI["view_gemInfo" + i] as GemOperateInfoViewUI;
                _clear(view);
            }

            if(m_pLastSelBtn)
            {
                m_pLastSelBtn.selected = false;
                m_pLastSelBtn = null;
            }

            m_pViewUI.btnGroup.selectedIndex = -1;
            m_iCurrSelPage = -1;
        }
    }

    private function _onClose( type : String = null ) : void
    {
        switch ( type )
        {
            default:
                if ( this.closeHandler )
                {
                    this.closeHandler.execute();
                }
                break;
        }
    }

    private function _showSuitTips( pageType : int, item : Component = null) : void
    {
        (system.getHandler(CGemUIHandler) as CGemUIHandler).addTips( CGemSuitTipsView, item, [pageType] );
    }

//按钮点击处理===========================================================================================================
    /**
     * 一键镶嵌
     */
    private function _onOneKeyEmbedHandler():void
    {
        if(m_iCurrSelPage)
        {
            (system.getHandler(CGemNetHandler) as CGemNetHandler).gemOneKeyEmbedRequest(m_iCurrSelPage);
        }
    }

    /**
     * 一键升级
     */
    private function _onOneKeyUpgradeHandler():void
    {
        if(m_iCurrSelPage)
        {
            (system.getHandler(CGemNetHandler) as CGemNetHandler).gemUpgradeRequest(EGemUpgradeType.Type_Onekey, m_iCurrSelPage);
        }
    }

    /**
     * 宝石合成
     */
    private function _onClickGemMergeHandler():void
    {
        var view:CGemMergeViewHandler = (system.getHandler(CGemMergeViewHandler) as CGemMergeViewHandler);
        if(view && !view.isViewShow)
        {
            view.addDisplay();
        }
    }

    /**
     * 宝石购买
     */
    private function _onClickGemBuyHandler():void
    {
        var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
        var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.MALL));
        bundleCtx.setUserData(systemBundle, "shop_type", [EShopType.SHOP_TYPE_21]);
        bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);
    }

    private function _onClickSuitHandler():void
    {
        var view:CGemSuitAttrInfoViewHandler = system.getHandler(CGemSuitAttrInfoViewHandler) as CGemSuitAttrInfoViewHandler;
        view.pageType = m_iCurrSelPage;
        view.addDisplay();
    }

//监听==================================================================================================================
    private function _onSelectHandler(index:int):void
    {
        if(index == -1)
        {
            return;
        }

        if(m_pLastSelBtn)
        {
            m_pLastSelBtn.selected = false;
        }

        var btn:Button = m_pViewUI.btnGroup.items[index] as Button;
        m_pLastSelBtn = btn;
        btn.selected = true;

        m_iCurrSelPage = index + 1;

        _updateEmbedInfo();
        _updatePageLogo();
        _updateCombatAndAttrInfo();

        m_pViewUI.btn_suit.toolTip = new Handler(_showSuitTips, [m_iCurrSelPage, m_pViewUI.btn_suit]);

        var view:CGemEmbedBagViewHandler = system.getHandler(CGemEmbedBagViewHandler) as CGemEmbedBagViewHandler;
        if(view && view.isViewShow)
        {
            view.removeDisplay();
        }
    }

    /**
     * 宝石镶嵌、摘除、替换、升级后的更新操作
     * @param e
     */
    private function _onGemHoleInfoUpdateHandler(e:CGemEvent):void
    {
        _updateEmbedInfo();
        _updateTotalCombatInfo();
        _updateCombatAndAttrInfo();
    }

    /**
     * 宝石包信息更新
     */
    private function _onGemBagUpdateHandler(e:CGemEvent):void
    {
        _updateBagListInfo();

        delayCall(0.1, _updateOperateState);
        delayCall(0.1, _onUpdateTipInfoHandler);
    }

    /**
     * 更新可操作状态
     */
    private function _updateOperateState():void
    {
        for(var i:int = 1; i <= CGemConst.MaxHoleNum; i++)
        {
            var view:GemOperateInfoViewUI = m_pViewUI["view_gemInfo" + i ] as GemOperateInfoViewUI;
            var gemHoleData:CGemHoleData = view.dataSource as CGemHoleData;
            if(gemHoleData)// 已开启的孔才更新
            {
                if(gemHoleData.state == EGemHoleState.Type_notEmbed)
                {
                    var isCanEmbed:Boolean = _helper.isCanEmbed(gemHoleData.gemPointConfigID);
                    view.frameClip_embed.autoPlay = isCanEmbed;
                    view.frameClip_embed.visible = isCanEmbed;
                    view.btn_add.visible = isCanEmbed;

                    view.txt_clickEmbed.visible = isCanEmbed;
                    view.txt_noGem.visible = !isCanEmbed;
                    view.txt_noGem.text = "无宝石可镶嵌";
                }
                else if(gemHoleData.state == EGemHoleState.Type_hasEmbed)
                {
                    var isCanUpgrade:Boolean = _helper.isCanUpgrade(gemHoleData.gemPointConfigID, gemHoleData.gemConfigID);
                    view.frameClip_levelUp.autoPlay = isCanUpgrade;
                    view.frameClip_levelUp.visible = isCanUpgrade;
                    view.btn_levelUp.visible = isCanUpgrade;
                    view.txt_clickEmbed.visible = false;

                    var gem:Gem = _helper.getGemConfigInfoById(gemHoleData.gemConfigID);
                    view.txt_noGem.visible = gemHoleData.gemConfigID != 0 && !isCanUpgrade;
                    view.txt_noGem.text = gem == null ? "" : gem.name;
                }
            }
        }
    }

    private function _onUpdateTipInfoHandler(e:CPlayerEvent = null):void
    {
        m_pViewUI.img_dian1.visible = _helper.isCanOperateByPage(EGemPageType.Type_Heart);
        m_pViewUI.img_dian2.visible = _helper.isCanOperateByPage(EGemPageType.Type_Soul);
        m_pViewUI.img_dian3.visible = _helper.isCanOperateByPage(EGemPageType.Type_Power);
    }

    private function _onGemMergeRedTipHandler(e:CGemEvent = null):void
    {
        m_pViewUI.img_dian4.visible = _helper.isCanMerge();
    }

//property=============================================================================================================
    public function get closeHandler() : Handler
    {
        return m_pCloseHandler;
    }

    public function set closeHandler( value : Handler ) : void
    {
        m_pCloseHandler = value;
    }

    private function get _uiSystem():CUISystem
    {
        return system.stage.getSystem(CUISystem) as CUISystem;
    }

    private function get _helper():CGemHelpHandler
    {
        return system.getHandler(CGemHelpHandler) as CGemHelpHandler;
    }

    private function get _gemData():CGemData
    {
        return (system.getHandler(CGemManagerHandler) as CGemManagerHandler).gemData;
    }
}
}
