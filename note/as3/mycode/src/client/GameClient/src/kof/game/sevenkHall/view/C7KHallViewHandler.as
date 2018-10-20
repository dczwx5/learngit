//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/1/18.
 */
package kof.game.sevenkHall.view {

import QFLib.Foundation;

import flash.events.Event;
import flash.external.ExternalInterface;

import flash.geom.Point;
import flash.net.URLRequest;
import flash.net.navigateToURL;

import kof.game.KOFSysTags;
import kof.game.common.CFlyItemUtil;
import kof.game.common.CItemUtil;
import kof.game.common.CRewardUtil;
import kof.game.common.view.CTweenViewHandler;
import kof.game.endlessTower.enmu.ERewardTakeState;
import kof.game.platform.sevenK.C7KData;
import kof.game.platform.sevenK.E7kVipType;
import kof.game.player.CPlayerSystem;
import kof.game.player.event.CPlayerEvent;
import kof.game.sevenkHall.C7KHallHelpHandler;
import kof.game.sevenkHall.C7KHallManager;
import kof.game.sevenkHall.C7KHallNetHandler;
import kof.game.sevenkHall.data.C7KLevelRewardData;
import kof.game.sevenkHall.event.C7K7KEvent;
import kof.ui.CUISystem;
import kof.ui.platform.sevenK.SevenKLvItemUI;
import kof.ui.platform.sevenK.SevenKPrivilegeUI;

import morn.core.components.Component;

import morn.core.components.Dialog;

import morn.core.handlers.Handler;

public class C7KHallViewHandler extends CTweenViewHandler {

    private var m_bViewInitialized : Boolean;

    private var m_pViewUI : SevenKPrivilegeUI;
    private var m_pCloseHandler : Handler;
    private var m_iSelectedIndex:int;

    public function C7KHallViewHandler( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override protected function onSetup() : Boolean
    {
        var ret : Boolean = super.onSetup();
        _reqRewardsInfo();

        return ret;
    }

    private function _reqRewardsInfo():void
    {
        (system.getHandler(C7KHallNetHandler) as C7KHallNetHandler).get7K7KRewardsInfo();
    }

    override public function get viewClass() : Array
    {
        return [SevenKPrivilegeUI];
    }

    override protected function get additionalAssets():Array
    {
        return ["sevenK.swf", "frameclip_item.swf", "frameclip_item2.swf"];
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
                m_pViewUI = new SevenKPrivilegeUI();
                m_pViewUI.list_levelReward.renderHandler = new Handler(_renderLevelReward);
                m_pViewUI.list_newReward.renderHandler = new Handler(CItemUtil.getItemRenderFunc(system, 1));
                m_pViewUI.list_dailyReward1.renderHandler = new Handler(CItemUtil.getItemRenderFunc(system));
                m_pViewUI.list_dailyReward2.renderHandler = new Handler(CItemUtil.getItemRenderFunc(system));
                m_pViewUI.link_more.clickHandler = new Handler(_onClickDownloadHandler);
                m_pViewUI.btn_openCommon.clickHandler = new Handler(_onOpenCommonVipHandler);
                m_pViewUI.btn_openYear.clickHandler = new Handler(_onOpenYearVipHandler);
                m_pViewUI.btn_renewals.clickHandler = new Handler(_onRenewalsHandler);
                m_pViewUI.btn_takeNew.clickHandler = new Handler(_onTakeNewRewardHandler);
                m_pViewUI.btn_dailyTake1.clickHandler = new Handler(_onTakeDailyCommonRewardHandler);
                m_pViewUI.btn_dailyTake2.clickHandler = new Handler(_onTakeDailyYearRewardHandler);

//                m_pViewUI.list_reward.mask = m_pViewUI.img_mask;

                m_pViewUI.closeHandler = new Handler( _onClose );

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
        setTweenData(KOFSysTags.SEVENK_HALL);
        showDialog(m_pViewUI, false, _addToDisplay);
    }

    private function _addToDisplay() : void
    {
        uiCanvas.addDialog( m_pViewUI );

        _initView();
        _addListeners();
    }

    private function _addListeners():void
    {
        m_pViewUI.tab.addEventListener( Event.CHANGE, _onTabSelectedHandler);
        system.addEventListener(C7K7KEvent.UpdateAllRewardInfo, _onRewardsInfoUpdateHandler);
        system.addEventListener(C7K7KEvent.UpdateDailyRewardState, _onDailyRewardStateHandler);
        system.addEventListener(C7K7KEvent.UpdateNewRewardState, _onNewRewardStateHandler);
        system.addEventListener(C7K7KEvent.UpdateLevelRewardState, _onLevelRewardStateHandler);
        system.stage.getSystem(CPlayerSystem).addEventListener(CPlayerEvent.PLAYER_LEVEL_UP,_onTeamLevelUpHandler);
    }

    private function _removeListeners():void
    {
        m_pViewUI.tab.removeEventListener( Event.CHANGE, _onTabSelectedHandler);
        system.removeEventListener(C7K7KEvent.UpdateAllRewardInfo, _onRewardsInfoUpdateHandler);
        system.removeEventListener(C7K7KEvent.UpdateDailyRewardState, _onDailyRewardStateHandler);
        system.removeEventListener(C7K7KEvent.UpdateNewRewardState, _onNewRewardStateHandler);
        system.removeEventListener(C7K7KEvent.UpdateLevelRewardState, _onLevelRewardStateHandler);
        system.stage.getSystem(CPlayerSystem).removeEventListener(CPlayerEvent.PLAYER_LEVEL_UP,_onTeamLevelUpHandler);
    }

    private function _initView():void
    {
        if ( m_pViewUI )
        {
            _initTabBarData();
            _updateTabTipState();
//            m_pViewUI.tab.selectedIndex = m_iSelectedIndex;
            _onTabSelectedHandler();

            m_pViewUI.btn_openCommon.visible = !_helper.isVip();
            m_pViewUI.btn_openYear.visible = !_helper.isVip();
            m_pViewUI.btn_renewals.visible = _helper.isVip();
        }
    }

    private function _initTabBarData():void
    {
        m_pViewUI.tab.labels = "特权介绍,新手礼包,每日礼包,等级礼包";
        m_pViewUI.tab.space = m_pViewUI.tab.space;
    }

    // 小红点提示
    private function _updateTabTipState():void
    {
        m_pViewUI.img_dian_1.visible = _helper.isVip() && _helper.hasNewRewards();
        m_pViewUI.img_dian_2.visible = _helper.isVip() && _helper.hasEveryDayRewards();
        m_pViewUI.img_dian_3.visible = _helper.isVip() && _helper.hasLevelRewards();
    }

    /**
     * 切换页签处理
     * @param e
     */
    private function _onTabSelectedHandler(e:Event = null):void
    {
        m_pViewUI.box_privilege.visible = m_pViewUI.tab.selectedIndex == 0;
        m_pViewUI.box_newReward.visible = m_pViewUI.tab.selectedIndex == 1;
        m_pViewUI.box_dailyReward.visible = m_pViewUI.tab.selectedIndex == 2;
        m_pViewUI.list_levelReward.visible = m_pViewUI.tab.selectedIndex == 3;

        switch(m_pViewUI.tab.selectedIndex)
        {
            case 1:
                _updateNewRewards();
                break;
            case 2:
                _updateEveryDayRewards();
                break;
            case 3:
                _updateLevelRewards();
                break;
        }
    }

    /**
     * 新手奖励
     */
    private function _updateNewRewards():void
    {
        var arr:Array = _helper.getNewRewards();
        m_pViewUI.list_newReward.dataSource = arr;

        m_pViewUI.btn_takeNew.disabled = !_helper.isVip() || !_helper.hasNewRewards();

        var listWidth:int = 80 * arr.length + m_pViewUI.list_newReward.spaceX * (arr.length - 1);
        m_pViewUI.list_newReward.x = 670 - listWidth >> 1;
        m_pViewUI.btn_takeNew.x = 670 - m_pViewUI.btn_takeNew.width >> 1;
    }

    /**
     * 每日奖励
     */
    private function _updateEveryDayRewards():void
    {
        var arr1:Array = _helper.getEveryDayRewards(E7kVipType.COMMON);
        var arr2:Array = _helper.getEveryDayRewards(E7kVipType.YEAR);
        m_pViewUI.list_dailyReward1.dataSource = arr1;
        m_pViewUI.list_dailyReward2.dataSource = arr2;

        var listWidth1:int = 52 * arr1.length + m_pViewUI.list_dailyReward1.spaceX * (arr1.length - 1);
        var listWidth2:int = 52 * arr2.length + m_pViewUI.list_dailyReward2.spaceX * (arr2.length - 1);
        m_pViewUI.list_dailyReward1.x = 239 - listWidth1 >> 1;
        m_pViewUI.list_dailyReward2.x = 288 + (239 - listWidth2 >> 1);

        _updateDailyRewardState();
    }

    private function _updateDailyRewardState():void
    {
        var pPlayerSystem:CPlayerSystem = system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
        var sevenKData:C7KData = pPlayerSystem.platform.sevenKData;
        if(sevenKData)
        {
            m_pViewUI.img_hasTake1.visible = false;
            m_pViewUI.img_hasTake2.visible = false;

            if(sevenKData.vipType == E7kVipType.NONE)
            {
                m_pViewUI.btn_dailyTake1.visible = true;
                m_pViewUI.btn_dailyTake1.disabled = true;
                m_pViewUI.btn_dailyTake2.visible = true;
                m_pViewUI.btn_dailyTake2.disabled = true;
                m_pViewUI.btn_dailyTake1.label = "不可领取";
                m_pViewUI.btn_dailyTake2.label = "不可领取";
                m_pViewUI.img_tip_daily.visible = true;
                m_pViewUI.img_tip_daily.toolTip = "一次性开通12个月，就能成为年费贵族，领取礼包。";
            }
            else if (sevenKData.vipType == E7kVipType.COMMON)
            {
                m_pViewUI.btn_dailyTake2.disabled = true;
                m_pViewUI.btn_dailyTake2.label = "不可领取";
                m_pViewUI.img_tip_daily.visible = true;
                m_pViewUI.img_tip_daily.toolTip = "一次性开通12个月，就能成为年费贵族，领取礼包。";

                _updateDailyCommonState();
            }
            else if(sevenKData.vipType == E7kVipType.YEAR)
            {
                _updateDailyCommonState();
                _updateDailyYearState();

                m_pViewUI.img_tip_daily.visible = false;
                m_pViewUI.img_tip_daily.toolTip = null;
            }
        }
    }

    /**
     * 普通贵族
     */
    private function _updateDailyCommonState():void
    {
        switch(_manager.rewardInfoData.everydayRewardState)
        {
            case ERewardTakeState.CannotTake:
                m_pViewUI.btn_dailyTake1.visible = true;
                m_pViewUI.btn_dailyTake1.disabled = true;
                m_pViewUI.img_hasTake1.visible = false;
                break;
            case ERewardTakeState.CanTake:
                m_pViewUI.btn_dailyTake1.visible = true;
                m_pViewUI.btn_dailyTake1.disabled = false;
                m_pViewUI.img_hasTake1.visible = false;
                break;
            case ERewardTakeState.HasTake:
                m_pViewUI.btn_dailyTake1.visible = false;
                m_pViewUI.img_hasTake1.visible = true;
                break;
        }
    }

    /**
     * 年费贵族
     */
    private function _updateDailyYearState():void
    {
        switch(_manager.rewardInfoData.yearVipEverydayRewardState)
        {
            case ERewardTakeState.CannotTake:
                m_pViewUI.btn_dailyTake2.visible = true;
                m_pViewUI.btn_dailyTake2.disabled = true;
                m_pViewUI.img_hasTake2.visible = false;
                break;
            case ERewardTakeState.CanTake:
                m_pViewUI.btn_dailyTake2.visible = true;
                m_pViewUI.btn_dailyTake2.disabled = false;
                m_pViewUI.img_hasTake2.visible = false;
                break;
            case ERewardTakeState.HasTake:
                m_pViewUI.btn_dailyTake2.visible = false;
                m_pViewUI.img_hasTake2.visible = true;
                break;
        }
    }

    /**
     * 等级奖励
     */
    private function _updateLevelRewards():void
    {
        m_pViewUI.list_levelReward.dataSource = _helper.getLevelRewards();
    }

    private function _renderLevelReward(item:Component, index:int):void
    {
        if ( !(item is SevenKLvItemUI) )
        {
            return;
        }

        var render : SevenKLvItemUI = item as SevenKLvItemUI;
        render.mouseChildren = true;
        render.mouseEnabled = true;
        var levelData : C7KLevelRewardData = render.dataSource as C7KLevelRewardData;
        if ( levelData )
        {
            render.num_level.num = levelData.level;
            render.num_level.x = levelData.level >= 100 ? 45 : 55;
            if(render.list_item.renderHandler == null)
            {
                render.list_item.renderHandler = new Handler(CItemUtil.getItemRenderFunc(system));
            }

            render.list_item.dataSource = CRewardUtil.createByDropPackageID(system.stage, levelData.dropId ).list;

            var state:int = _helper.getLevelRewardState(levelData.level);
            switch (state)
            {
                case ERewardTakeState.CannotTake:
                    render.btn_take.visible = true;
                    render.btn_take.disabled = true;
                    render.img_hasTake.visible = false;
                    break;
                case ERewardTakeState.CanTake:
                    render.btn_take.visible = true;
                    render.btn_take.disabled = false;
                    render.img_hasTake.visible = false;
                    render.btn_take.clickHandler = new Handler(takeLevelReward);
                    break;
                case ERewardTakeState.HasTake:
                    render.btn_take.visible = false;
                    render.img_hasTake.visible = true;
                    break;
            }

            function takeLevelReward():void
            {
                (system.getHandler(C7KHallNetHandler) as C7KHallNetHandler).takeLevelReward(levelData.level);
            }
        }
        else
        {
            render.num_level.num = 0;
            render.list_item.dataSource = [];
        }

//        TweenMax.fromTo(render, 0.3, {x:666}, {x:0, delay:0.1*index});
    }

    private function _onClickDownloadHandler():void
    {
        if ( ExternalInterface.available ) {
            try {
                ExternalInterface.call( "goToVipSite" );
            } catch ( e : Error ) {
                Foundation.Log.logErrorMsg( "goTo 7k7k VipSite error caught: " + e.message );
            }
        }
    }

    private function _onOpenCommonVipHandler():void
    {
        if ( ExternalInterface.available ) {
            try {
                ExternalInterface.call( "buyVip" );
            } catch ( e : Error ) {
                Foundation.Log.logErrorMsg( "buy7k7kVip error caught: " + e.message );
            }
        }
    }

    private function _onOpenYearVipHandler():void
    {
        if ( ExternalInterface.available ) {
            try {
                ExternalInterface.call( "buyYearVip" );
            } catch ( e : Error ) {
                Foundation.Log.logErrorMsg( "buy7k7YearkVip error caught: " + e.message );
            }
        }
    }

    /**
     * 续费
     */
    private function _onRenewalsHandler():void
    {
        var pPlayerSystem:CPlayerSystem = system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
        var sevenKData:C7KData = pPlayerSystem.platform.sevenKData;
        var func:String;
        if(sevenKData)
        {
            func = sevenKData.vipType == E7kVipType.COMMON ? "buyVip" : "buyYearVip";
        }
        else
        {
            func = "buyVip";
        }

        if ( ExternalInterface.available ) {
            try {
                ExternalInterface.call( func );
            } catch ( e : Error ) {
                Foundation.Log.logErrorMsg( "buy7k7YearkVip error caught: " + e.message );
            }
        }
    }

    private function _onTakeNewRewardHandler():void
    {
        (system.getHandler(C7KHallNetHandler) as C7KHallNetHandler).takeNewReward();

        var len:int = m_pViewUI.list_newReward.cells.length;
        for(var i:int = 0; i < len; i++)
        {
            var cell:Component = m_pViewUI.list_newReward.getCell(i);
            if(cell.visible)
            {
                CFlyItemUtil.flyItemToBag(cell, cell.localToGlobal(new Point()), system);
            }
        }
    }

    private function _onTakeDailyCommonRewardHandler():void
    {
        (system.getHandler(C7KHallNetHandler) as C7KHallNetHandler).takeEveryDayReward(E7kVipType.COMMON);

        var len:int = m_pViewUI.list_dailyReward1.cells.length;
        for(var i:int = 0; i < len; i++)
        {
            var cell:Component = m_pViewUI.list_dailyReward1.getCell(i);
            if(cell.visible)
            {
                CFlyItemUtil.flyItemToBag(cell, cell.localToGlobal(new Point()), system);
            }
        }
    }

    private function _onTakeDailyYearRewardHandler():void
    {
        (system.getHandler(C7KHallNetHandler) as C7KHallNetHandler).takeEveryDayReward(E7kVipType.YEAR);

        var len:int = m_pViewUI.list_dailyReward2.cells.length;
        for(var i:int = 0; i < len; i++)
        {
            var cell:Component = m_pViewUI.list_dailyReward2.getCell(i);
            if(cell.visible)
            {
                CFlyItemUtil.flyItemToBag(cell, cell.localToGlobal(new Point()), system);
            }
        }
    }

// 监听=================================================================================================================
    private function _onRewardsInfoUpdateHandler(e:C7K7KEvent):void
    {
        // TODO

        _updateTabTipState();
    }

    /**
     * 领取每日奖励后更新按钮状态
     * @param e
     */
    private function _onDailyRewardStateHandler(e:C7K7KEvent):void
    {
        _updateDailyRewardState();
        m_pViewUI.img_dian_2.visible = _helper.hasEveryDayRewards();
    }

    /**
     * 领取新手奖励后更新按钮状态
     * @param e
     */
    private function _onNewRewardStateHandler(e:C7K7KEvent):void
    {
        m_pViewUI.btn_takeNew.disabled = !_helper.hasNewRewards();

        m_pViewUI.img_dian_1.visible = _helper.hasNewRewards();
    }

    /**
     * 领取等级奖励后更新按钮状态
     * @param e
     */
    private function _onLevelRewardStateHandler(e:C7K7KEvent):void
    {
        var level:int = e.data as int;
        var len:int = m_pViewUI.list_levelReward.cells.length;
        for(var i:int = 0; i < len; i++)
        {
            var index:int = i + m_pViewUI.list_levelReward.startIndex;
            var cell:SevenKLvItemUI = m_pViewUI.list_levelReward.getCell(index) as SevenKLvItemUI;
            if(cell)
            {
                var cellData:C7KLevelRewardData = cell.dataSource as C7KLevelRewardData;
                if(cellData && cellData.level == level)
                {
                    var state:int = _helper.getLevelRewardState(cellData.level);
                    switch (state)
                    {
                        case ERewardTakeState.CannotTake:
                            cell.btn_take.visible = true;
                            cell.btn_take.disabled = true;
                            cell.img_hasTake.visible = false;
                            break;
                        case ERewardTakeState.CanTake:
                            cell.btn_take.visible = true;
                            cell.btn_take.disabled = false;
                            cell.img_hasTake.visible = false;
                            break;
                        case ERewardTakeState.HasTake:
                            cell.btn_take.visible = false;
                            cell.img_hasTake.visible = true;
                            break;
                    }

                    var len2:int = cell.list_item.cells.length;
                    for(i = 0; i < len2; i++)
                    {
                        var cell2:Component = cell.list_item.getCell(i);
                        if(cell2.visible)
                        {
                            CFlyItemUtil.flyItemToBag(cell2, cell2.localToGlobal(new Point()), system);
                        }
                    }
                }
            }
        }

        m_pViewUI.img_dian_3.visible = _helper.hasLevelRewards();
    }

    private function _onTeamLevelUpHandler(e:CPlayerEvent):void
    {
        m_pViewUI.img_dian_3.visible = _helper.hasLevelRewards();

        m_pViewUI.list_levelReward.refresh();
    }

    public function removeDisplay() : void
    {
        closeDialog(_remove);
    }

    private function _remove():void
    {
        if ( m_bViewInitialized )
        {
            m_iSelectedIndex = 0;
            m_pViewUI.tab.selectedIndex = 0;

            _removeListeners();

            if ( m_pViewUI && m_pViewUI.parent )
            {
                m_pViewUI.close( Dialog.CLOSE );
            }
        }
    }

    private function _onClose( type : String ) : void
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

    private function get _helper():C7KHallHelpHandler
    {
        return system.getHandler(C7KHallHelpHandler) as C7KHallHelpHandler;
    }

    private function get _manager():C7KHallManager
    {
        return system.getHandler(C7KHallManager) as C7KHallManager;
    }

    public function get isViewShow():Boolean
    {
        return m_pViewUI && m_pViewUI.parent;
    }

    override public function dispose():void
    {
        super.dispose();

        m_pViewUI = null;
        m_pCloseHandler  = null;
        m_iSelectedIndex = 0;
    }
}
}
