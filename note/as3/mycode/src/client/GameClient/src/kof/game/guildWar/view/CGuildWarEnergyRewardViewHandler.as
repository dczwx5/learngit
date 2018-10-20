//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/4/18.
 */
package kof.game.guildWar.view {

import flash.events.Event;
import flash.geom.Point;

import kof.framework.CViewHandler;
import kof.game.common.CFlyItemUtil;
import kof.game.common.CItemUtil;
import kof.game.common.CRewardUtil;
import kof.game.common.view.CViewExternalUtil;
import kof.game.endlessTower.enmu.ERewardTakeState;
import kof.game.guildWar.CGuildWarHelpHandler;
import kof.game.guildWar.CGuildWarNetHandler;
import kof.game.guildWar.CGuildWarSystem;
import kof.game.guildWar.data.CGuildWarData;
import kof.game.guildWar.enum.EEnergyRewardType;
import kof.game.guildWar.enum.EStationType;
import kof.game.guildWar.event.CGuildWarEvent;
import kof.game.item.data.CRewardListData;
import kof.game.item.view.part.CRewardItemListView;
import kof.table.GuildWarReward;
import kof.table.GuildWarSpaceTable;
import kof.ui.CMsgAlertHandler;
import kof.ui.CUISystem;
import kof.ui.master.GuildWar.LeagueEnergyRewardItemUI;
import kof.ui.master.GuildWar.LeagueEnergyRewardStrongholdItemUI;
import kof.ui.master.GuildWar.LeagueEnergyRewardUI;

import morn.core.components.Component;

import morn.core.components.Dialog;
import morn.core.components.List;
import morn.core.handlers.Handler;

/**
 * 能源奖励界面
 */
public class CGuildWarEnergyRewardViewHandler extends CViewHandler {

    private var m_bViewInitialized : Boolean;
    private var m_pViewUI:LeagueEnergyRewardUI;
    private var m_iSelectedIndex:int;

    public function CGuildWarEnergyRewardViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array
    {
        return [ LeagueEnergyRewardUI];
    }

    override  protected function get additionalAssets() : Array
    {
        return ["frameclip_item.swf"];
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
                m_pViewUI = new LeagueEnergyRewardUI();

                m_pViewUI.btn_close.clickHandler = new Handler(_onClickCloseHandler);
                m_pViewUI.view_stationReward.list_stationReward.renderHandler = new Handler(_stationRewardRenderHandler);
                m_pViewUI.view_clubEnergy.list_clubReward.renderHandler = new Handler(_clubRewardRenderHandler);
                m_pViewUI.view_personEnergy.list_personReward.renderHandler = new Handler(_roleRewardRenderHandler);

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

        uiCanvas.addPopupDialog(m_pViewUI);
    }

    private function _addListeners():void
    {
        m_pViewUI.tab.addEventListener( Event.CHANGE, _onTabSelectedHandler);
        system.addEventListener(CGuildWarEvent.UpdateBaseInfo, _onUpdateBaseInfoHandler);
    }

    private function _removeListeners():void
    {
        m_pViewUI.tab.removeEventListener( Event.CHANGE, _onTabSelectedHandler);
        system.removeEventListener(CGuildWarEvent.UpdateBaseInfo, _onUpdateBaseInfoHandler);
    }

    private function _initView():void
    {
        if ( m_pViewUI )
        {
            m_pViewUI.tab.selectedIndex = m_iSelectedIndex;
            _updateRedPoint();
        }
    }

    private function _updateStationReward():void
    {
        m_pViewUI.view_stationReward.list_stationReward.dataSource = _helper.getStationRewards();
    }

    private function _updateClubEnergy():void
    {
        if(_guildWarData && _guildWarData.baseData)
        {
            m_pViewUI.view_clubEnergy.txt_clubEnergy.text = _guildWarData.baseData.clubTotalScore.toString();
            m_pViewUI.view_clubEnergy.list_clubReward.dataSource = _helper.getEnergyRewardsByType(EEnergyRewardType.Type_Club);
        }
    }

    private function _updatePersonEnergy():void
    {
        if(_guildWarData && _guildWarData.baseData)
        {
            m_pViewUI.view_personEnergy.list_personReward.dataSource = _helper.getEnergyRewardsByType(EEnergyRewardType.Type_Role);
        }
    }

    private function _updateRedPoint():void
    {
        m_pViewUI.img_dian_club.visible = _hasRewardTake(EEnergyRewardType.Type_Club);
        m_pViewUI.img_dian_role.visible = _hasRewardTake(EEnergyRewardType.Type_Role);
    }

    public function removeDisplay() : void
    {
        if ( m_bViewInitialized )
        {
            _removeListeners();

            m_iSelectedIndex = 0;

            if ( m_pViewUI && m_pViewUI.parent )
            {
                m_pViewUI.close( Dialog.CLOSE );
            }
        }
    }

    private function _onClickCloseHandler():void
    {
        removeDisplay();
    }

    private function _onTabSelectedHandler(e:Event = null):void
    {
        m_iSelectedIndex = m_pViewUI.tab.selectedIndex;

        if(m_pViewUI.tab.selectedIndex == 0)
        {
            if(m_pViewUI.view_clubEnergy.parent)
            {
                m_pViewUI.view_clubEnergy.remove();
            }

            if(m_pViewUI.view_personEnergy.parent)
            {
                m_pViewUI.view_personEnergy.remove();
            }
            m_pViewUI.addChild(m_pViewUI.view_stationReward);
            _updateStationReward();
        }
        else if(m_pViewUI.tab.selectedIndex == 1)
        {
            if(m_pViewUI.view_stationReward.parent)
            {
                m_pViewUI.view_stationReward.remove();
            }

            if(m_pViewUI.view_personEnergy.parent)
            {
                m_pViewUI.view_personEnergy.remove();
            }
            m_pViewUI.addChild(m_pViewUI.view_clubEnergy);
            _updateClubEnergy();
        }
        else if(m_pViewUI.tab.selectedIndex == 2)
        {
            if(m_pViewUI.view_stationReward.parent)
            {
                m_pViewUI.view_stationReward.remove();
            }

            if(m_pViewUI.view_clubEnergy.parent)
            {
                m_pViewUI.view_clubEnergy.remove();
            }
            m_pViewUI.addChild(m_pViewUI.view_personEnergy);
            _updatePersonEnergy();
        }
    }

//render处理===========================================================================================================
    private function _stationRewardRenderHandler(item:Component, index:int):void
    {
        var render:LeagueEnergyRewardStrongholdItemUI = item as LeagueEnergyRewardStrongholdItemUI;
        var data:GuildWarSpaceTable = render == null ? null : (item.dataSource as GuildWarSpaceTable);

        if(render && data)
        {
            render.clip_station.index = data.spaceType - 1;
            render.view_dailyReward.list_item.renderHandler = new Handler(CItemUtil.getItemRenderFunc(system));
            render.view_boxReward.list_item.renderHandler = new Handler(CItemUtil.getItemRenderFunc(system));

            var rewardListData:CRewardListData = CRewardUtil.createByDropPackageID(system.stage, data.dayReward);

            if(rewardListData)
            {
                render.view_dailyReward.list_item.dataSource = rewardListData.list;
            }
            else
            {
                render.view_dailyReward.list_item.dataSource = [];
            }

            rewardListData = CRewardUtil.createByDropPackageID(system.stage, data.spaceBox);

            if(rewardListData)
            {
                render.view_boxReward.list_item.dataSource = rewardListData.list;
            }
            else
            {
                render.view_boxReward.list_item.dataSource = [];
            }
        }
    }

    private function _clubRewardRenderHandler(item:Component, index:int):void
    {
        var render:LeagueEnergyRewardItemUI = item as LeagueEnergyRewardItemUI;
        var data:GuildWarReward = render == null ? null : (item.dataSource as GuildWarReward);

        if(render && data)
        {
            render.txt_energyNum.text = data.score.toString();
            render.view_itemList.list_item.renderHandler = new Handler(CItemUtil.getItemRenderFunc(system));

            var rewardListData:CRewardListData = CRewardUtil.createByDropPackageID(system.stage, data.rewardID);

            if(rewardListData)
            {
                render.view_itemList.list_item.dataSource = rewardListData.list;
            }
            else
            {
                render.view_itemList.list_item.dataSource = [];
            }

            var state:int = _helper.getClubRewardTakeState(data);
            render.btn_take.visible = state != ERewardTakeState.HasTake;
            render.img_hasTake.visible = state == ERewardTakeState.HasTake;
            render.btn_take.disabled = state == ERewardTakeState.CannotTake;

            render.btn_take.clickHandler = new Handler(_onTakeRewardHandler, [data.ID, render.view_itemList.list_item]);
        }
    }

    private function _roleRewardRenderHandler(item:Component, index:int):void
    {
        var render:LeagueEnergyRewardItemUI = item as LeagueEnergyRewardItemUI;
        var data:GuildWarReward = render == null ? null : (item.dataSource as GuildWarReward);

        if(render && data)
        {
            render.txt_energyNum.text = data.score.toString();
            render.view_itemList.list_item.renderHandler = new Handler(CItemUtil.getItemRenderFunc(system));

            var rewardListData:CRewardListData = CRewardUtil.createByDropPackageID(system.stage, data.rewardID);

            if(rewardListData)
            {
                render.view_itemList.list_item.dataSource = rewardListData.list;
            }
            else
            {
                render.view_itemList.list_item.dataSource = [];
            }

            var state:int = _helper.getRoleRewardTakeState(data);
            render.btn_take.visible = state != ERewardTakeState.HasTake;
            render.img_hasTake.visible = state == ERewardTakeState.HasTake;
            render.btn_take.disabled = state == ERewardTakeState.CannotTake;

            render.btn_take.clickHandler = new Handler(_onTakeRewardHandler, [data.ID, render.view_itemList.list_item]);
        }
    }

    private function _onTakeRewardHandler(id:int, list:List):void
    {
//        if(_guildWarData && _guildWarData.baseData && _guildWarData.baseData.totalScore == 0)
//        {
//            _uiSystem.showMsgAlert("个人积分为0！", CMsgAlertHandler.WARNING);
//            return;
//        }

        (system.getHandler(CGuildWarNetHandler) as CGuildWarNetHandler).guildWarGetRewardRequest(id);

        var len:int = list.dataSource.length;
        for(var i:int = 0; i < len; i++)
        {
            var item:Component = list.getCell(i) as Component;
            CFlyItemUtil.flyItemToBag(item, item.localToGlobal(new Point()), system);
        }
    }

//监听处理==============================================================================================================
    private function _onUpdateBaseInfoHandler(e:CGuildWarEvent):void
    {
        m_pViewUI.view_clubEnergy.list_clubReward.refresh();
        m_pViewUI.view_personEnergy.list_personReward.refresh();

        _updateRedPoint();
    }

    private function _hasRewardTake(type:int):Boolean
    {
        var rewardsArr:Array = _helper.getEnergyRewardsByType(type);

        if(rewardsArr && rewardsArr.length)
        {
            for each(var data:GuildWarReward in rewardsArr)
            {
                var state:int;
                if(data)
                {
                    if(type == EEnergyRewardType.Type_Club)
                    {
                        state = _helper.getClubRewardTakeState(data);
                    }
                    else
                    {
                        state = _helper.getRoleRewardTakeState(data);
                    }
                }

                if(state == ERewardTakeState.CanTake)
                {
                    return true;
                }
            }
        }

        return false;
    }

//property=============================================================================================================
    public function get isViewShow():Boolean
    {
        return m_pViewUI && m_pViewUI.parent;
    }

    private function get _helper():CGuildWarHelpHandler
    {
        return system.getHandler(CGuildWarHelpHandler) as CGuildWarHelpHandler;
    }

    private function get _uiSystem():CUISystem
    {
        return system.stage.getSystem(CUISystem) as CUISystem;
    }

    private function get _guildWarData():CGuildWarData
    {
        return (system as CGuildWarSystem).data;
    }
}
}
