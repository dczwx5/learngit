//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/4/18.
 */
package kof.game.guildWar.view {

import QFLib.Foundation.CTime;
import QFLib.Utils.HtmlUtil;

import flash.events.Event;

import kof.framework.CViewHandler;
import kof.game.club.CClubManager;
import kof.game.club.CClubSystem;
import kof.game.club.data.CClubConst;
import kof.game.guildWar.CGuildWarHelpHandler;
import kof.game.guildWar.CGuildWarNetHandler;
import kof.game.guildWar.CGuildWarSystem;
import kof.game.guildWar.data.CGuildWarData;
import kof.game.guildWar.data.giftBag.CAllocateGiftBagData;
import kof.game.guildWar.data.giftBag.CAllocateGiftBagData;
import kof.game.guildWar.data.giftBag.CAllocateGiftBagData;
import kof.game.guildWar.data.giftBag.CGiftBagRankData;
import kof.game.guildWar.data.giftBag.CGiftBagRankData;
import kof.game.guildWar.data.giftBag.CGiftBagRecordData;
import kof.game.guildWar.data.giftBag.CGuildWarGiftBagData;
import kof.game.guildWar.enum.EStationType;
import kof.game.guildWar.event.CGuildWarEvent;
import kof.game.guildWar.view.CGuildWarGiftMethodViewHandler;
import kof.table.GuildWarSpaceTable;
import kof.ui.CMsgAlertHandler;
import kof.ui.CUISystem;
import kof.ui.master.GuildWar.ClubGiftAllocateViewUI;
import kof.ui.master.GuildWar.ClubSpaceGiftBagViewUI;
import kof.ui.master.GuildWar.LeagueDistributionBagItemUI;
import kof.ui.master.GuildWar.LeagueDistributionBagUI;

import morn.core.components.Box;
import morn.core.components.Component;

import morn.core.components.Dialog;
import morn.core.components.Label;
import morn.core.handlers.Handler;

/**
 * 礼包分配界面
 */
public class CGuildWarGiftAllotViewHandler extends CViewHandler {

    private var m_bViewInitialized : Boolean;
    private var m_pViewUI:LeagueDistributionBagUI;
    private var m_iSelectedIndex:int;
    private var m_arrTemp:Array = [];

    public function CGuildWarGiftAllotViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array
    {
        return [ LeagueDistributionBagUI];
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
                m_pViewUI = new LeagueDistributionBagUI();
                m_pViewUI.btn_close.clickHandler = new Handler(_onClickCloseHandler);

                m_pViewUI.btn_allot.clickHandler = new Handler(_onClickAllotHandler);
                m_pViewUI.btn_smartAllot.clickHandler = new Handler(_onClickSmartAllotHandler);
                m_pViewUI.list_giftAllot.renderHandler = new Handler(_renderGiftListHandler);

                _clear();

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
        system.addEventListener(CGuildWarEvent.UpdateGiftBagAllocateInfo, _onUpdateGiftBagAllocateInfoHandler);
        system.addEventListener(CGuildWarEvent.UpdateGiftBagRecordInfo, _onUpdateRecordInfoHandler);
    }

    private function _removeListeners():void
    {
        m_pViewUI.tab.removeEventListener( Event.CHANGE, _onTabSelectedHandler);
        system.removeEventListener(CGuildWarEvent.UpdateGiftBagAllocateInfo, _onUpdateGiftBagAllocateInfoHandler);
        system.removeEventListener(CGuildWarEvent.UpdateGiftBagRecordInfo, _onUpdateRecordInfoHandler);
    }

    private function _initView():void
    {
        if ( m_pViewUI )
        {
            m_pViewUI.tab.selectedIndex = m_iSelectedIndex;
            m_pViewUI.btn_smartAllot.visible = false;
            m_pViewUI.btn_allot.disabled = !_helper.isChairman();
        }
    }

    private function _onClickAllotHandler():void
    {
        var giftMethodView:CGuildWarGiftMethodViewHandler = system.getHandler(CGuildWarGiftMethodViewHandler) as CGuildWarGiftMethodViewHandler;
        if(giftMethodView && !giftMethodView.isViewShow)
        {
            for(var i:int = 0; i < m_arrTemp.length; i++)
            {
                var data:CGiftBagRankData = m_arrTemp[i] as CGiftBagRankData;
                if(data.alreadyReceiveRewardBags.length == 0)
                {
                    m_arrTemp.splice(i, 1);
                    i--;
                }
            }

            giftMethodView.data = m_arrTemp;
            giftMethodView.addDisplay();
        }
    }

    private function _onClickSmartAllotHandler():void
    {
        // TODO
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

            _clear();

            m_arrTemp.length = 0;
        }
    }

    private function _onClickCloseHandler():void
    {
        removeDisplay();
    }

//监听处理=============================================================================================================
    /**
     * 切换页签处理
     * @param e
     */
    private function _onTabSelectedHandler(e:Event = null):void
    {
        m_iSelectedIndex = m_pViewUI.tab.selectedIndex;

        if(m_pViewUI.tab.selectedIndex == 0)
        {
            if(m_pViewUI.panel_record.parent)
            {
                m_pViewUI.panel_record.remove();
            }
            m_pViewUI.addChild(m_pViewUI.panel_allot);
            m_arrTemp.length = 0;
            _clearRecordInfo();

            if(!_helper.isChairman())
            {
                _onUpdateGiftBagAllocateInfoHandler();
                _uiSystem.showMsgAlert("会长才能分配礼包", CMsgAlertHandler.WARNING);
            }

            (system.getHandler(CGuildWarNetHandler) as CGuildWarNetHandler).guildWarRewardBagInfoRequest();
        }
        else if(m_pViewUI.tab.selectedIndex == 1)
        {
            if(m_pViewUI.panel_allot.parent)
            {
                m_pViewUI.panel_allot.remove();
            }
            m_pViewUI.addChild(m_pViewUI.panel_record);
            _clearGiftInfo();

            (system.getHandler(CGuildWarNetHandler) as CGuildWarNetHandler).guildWarAllocateRewardBagRecordRequest();
        }
    }

    /**
     * 礼包分配信息更新
     * @param e
     */
    private function _onUpdateGiftBagAllocateInfoHandler(e:CGuildWarEvent = null):void
    {
        if(_helper.isChairman() && _guildWarData && _guildWarData.giftBagData)
        {
            m_arrTemp.length = 0;

            var dataArr:Array = _guildWarData.giftBagData.allocateGiftBagListData.list;
            m_pViewUI.view_gift1.dataSource = dataArr.length >= 1 ? dataArr[0] : null;
            m_pViewUI.view_gift2.dataSource = dataArr.length >= 2 ? dataArr[1] : null;
            m_pViewUI.view_gift3.dataSource = dataArr.length >= 3 ? dataArr[2] : null;

            setGiftBagInfo(m_pViewUI.view_gift1);
            setGiftBagInfo(m_pViewUI.view_gift2);
            setGiftBagInfo(m_pViewUI.view_gift3);

            m_pViewUI.list_giftAllot.dataSource = _guildWarData.giftBagData.giftBagRankListData.list;
        }
        else if(!_helper.isChairman())
        {
//            var data1:CAllocateGiftBagData = new CAllocateGiftBagData();
//            data1.spaceId = 1;
//            m_pViewUI.view_gift1.dataSource = data1;
//
//            var data2:CAllocateGiftBagData = new CAllocateGiftBagData();
//            data2.spaceId = 2;
//            m_pViewUI.view_gift2.dataSource = data2;
//
//            var data3:CAllocateGiftBagData = new CAllocateGiftBagData();
//            data3.spaceId = 4;
//            m_pViewUI.view_gift3.dataSource = data3;

            dataArr = _guildWarData.giftBagData.allocateGiftBagListData.list;
            m_pViewUI.view_gift1.dataSource = dataArr.length >= 1 ? dataArr[0] : null;
            m_pViewUI.view_gift2.dataSource = dataArr.length >= 2 ? dataArr[1] : null;
            m_pViewUI.view_gift3.dataSource = dataArr.length >= 3 ? dataArr[2] : null;

            setGiftBagInfo(m_pViewUI.view_gift1);
            setGiftBagInfo(m_pViewUI.view_gift2);
            setGiftBagInfo(m_pViewUI.view_gift3);

            m_pViewUI.list_giftAllot.dataSource = null;
        }
    }

    private function setGiftBagInfo(view:ClubSpaceGiftBagViewUI):void
    {
        var data:CAllocateGiftBagData = view.dataSource as CAllocateGiftBagData;
        if(data)
        {
            view.visible = true;
            var table:GuildWarSpaceTable = _helper.getSpaceTableData(data.spaceId);
            if(table)
            {
                view.txt_stationName.text = table.spaceName;
                view.clip_giftIcon.index = table.spaceType - 1;
                view.clip_giftBg.index = table.spaceType - 1;
                view.txt_giftNum.text = (table.spaceBoxCount - data.alreadyAllocateRewardBagCount) + "";
            }
        }
        else
        {
            view.visible = false;
        }
    }

    private function _onUpdateRecordInfoHandler(e:CGuildWarEvent):void
    {
        if(_guildWarData && _guildWarData.giftBagRecordData)
        {
            m_pViewUI.txt_record.isHtml = true;
            var dataArr:Array = _guildWarData.giftBagRecordData.list;
            for each(var recordData:CGiftBagRecordData in dataArr)
            {
                var dateStr:String = CTime.formatHMSStr(recordData.time);
                m_pViewUI.txt_record.text += HtmlUtil.color("["+dateStr+"] ", "#00ff00");
                m_pViewUI.txt_record.text += HtmlUtil.color("会长把", "#bfdeed");
                var table:GuildWarSpaceTable = _helper.getSpaceTableData(recordData.spaceId);
                var spaceName:String = table == null ? "" : table.spaceName;
                m_pViewUI.txt_record.text += HtmlUtil.color(spaceName, "#00ffff");
                m_pViewUI.txt_record.text += HtmlUtil.color("荣耀礼包分配给", "#bfdeed");
                var positionName:String = _helper.getGuildPositionName(recordData.position);
                m_pViewUI.txt_record.text += HtmlUtil.color(positionName, "#bfdeed");
                m_pViewUI.txt_record.text += HtmlUtil.color(recordData.name, "#ffff00");
                m_pViewUI.txt_record.text += HtmlUtil.color("。", "#bfdeed");
                m_pViewUI.txt_record.text += "<br>";
            }

            m_pViewUI.txt_record.height = m_pViewUI.txt_record.textField.textHeight + 10;
            m_pViewUI.panel_record.scrollTo( 0,0 );
            m_pViewUI.panel_record.refresh();
        }
    }

//render==============================================================================================================
    private function _renderGiftListHandler(item:Component, index:int):void
    {
        var render:LeagueDistributionBagItemUI = item as LeagueDistributionBagItemUI;
        var data:CGiftBagRankData = render.dataSource as CGiftBagRankData;
        if(data)
        {
            render.img_vip.visible = false;
            render.txt_name.text = data.name;
            render.txt_energy.text = data.score.toString();

            if(_guildWarData && _guildWarData.giftBagData)
            {
                var spaceId:int;
                var dataArr:Array = _guildWarData.giftBagData.allocateGiftBagListData.list;
                render.view_gift1.dataSource = dataArr.length >= 1 ? data : null;
                spaceId = dataArr.length >= 1 ? (dataArr[0] as CAllocateGiftBagData).spaceId : 0;
                _setGiftAllocateView(render.view_gift1, spaceId);

                render.view_gift2.dataSource = dataArr.length >= 2 ? data : null;
                spaceId = dataArr.length >= 2 ? (dataArr[1] as CAllocateGiftBagData).spaceId : 0;
                _setGiftAllocateView(render.view_gift2, spaceId);

                render.view_gift3.dataSource = dataArr.length >= 3 ? data : null;
                spaceId = dataArr.length >= 3 ? (dataArr[2] as CAllocateGiftBagData).spaceId : 0;
                _setGiftAllocateView(render.view_gift3, spaceId);
            }
        }
        else
        {
            render.img_vip.visible = false;
            render.txt_name.text = "";
            render.txt_energy.text = "";
            render.view_gift1.dataSource = null;
            _setGiftAllocateView(render.view_gift1);

            render.view_gift2.dataSource = null;
            _setGiftAllocateView(render.view_gift2);

            render.view_gift3.dataSource = null;
            _setGiftAllocateView(render.view_gift3);
        }
    }

    private function _setGiftAllocateView(view:ClubGiftAllocateViewUI, spaceId:int = 0):void
    {
        var data:CGiftBagRankData = view.dataSource as CGiftBagRankData;
        if(data)
        {
            var table:GuildWarSpaceTable = _helper.getSpaceTableData(spaceId);
            if(table)
            {
                view.clip_bg.index = table.spaceType - 1;
                view.clip_gift.index = table.spaceType - 1;
            }

            var isAllocated:Boolean = data.alreadyReceiveRewardBags.indexOf(spaceId) != -1;// 已经分配了的
            if(isAllocated)
            {
                view.txt_num.text = "1";
            }
            else
            {
                view.txt_num.text = "0";
                var tempData:CGiftBagRankData = _getDataFromTempArr(data.roleID);
                if(tempData)
                {
                    if(tempData.alreadyReceiveRewardBags.indexOf(spaceId) != -1)
                    {
                        view.txt_num.text = "1";
                    }
                }
            }

            view.visible = true;
            if(isAllocated)
            {
                view.btn_add.disabled = true;
                view.btn_reduce.disabled = true;
                view.btn_add.clickHandler = null;
                view.btn_reduce.clickHandler = null;
            }
            else
            {
                view.btn_add.disabled = false;
                view.btn_reduce.disabled = false;
                view.btn_add.clickHandler = new Handler(_onClickAddHandler, [view, spaceId]);
                view.btn_reduce.clickHandler = new Handler(_onClickReduceHandler, [view, spaceId]);
            }
        }
        else
        {
            view.txt_num.text = "";
            view.clip_bg.index = 0;
            view.clip_gift.index = 0;
            view.visible = false;
        }
    }

    private function _onClickAddHandler(view:ClubGiftAllocateViewUI, spaceId:int):void
    {
        if(view.txt_num.text == "0")
        {
            var totalGiftData:CAllocateGiftBagData = _guildWarData.giftBagData.allocateGiftBagListData.getDataBySpaceId(spaceId);
            var table:GuildWarSpaceTable = _helper.getSpaceTableData(spaceId);
            if(table)
            {
                if(totalGiftData.alreadyAllocateRewardBagCount >= table.spaceBoxCount)
                {
                    _uiSystem.showMsgAlert("礼包已分配完", CMsgAlertHandler.WARNING);
                    return;
                }
            }

            view.txt_num.text = "1";

            var rankData:CGiftBagRankData = view.dataSource as CGiftBagRankData;
            if(rankData)
            {

                // 添加到临时数组
                var tempData:CGiftBagRankData = _getDataFromTempArr(rankData.roleID);
                if(tempData == null)
                {
                    tempData = new CGiftBagRankData();
                    tempData.alreadyReceiveRewardBags = [];
                    m_arrTemp.push(tempData);
                }

                tempData.roleID = rankData.roleID;
                tempData.name = rankData.name;
                tempData.score = rankData.score;
                if(tempData.alreadyReceiveRewardBags.indexOf(spaceId) == -1)
                {
                    tempData.alreadyReceiveRewardBags.push(spaceId);
                }

                _updateTotalGiftView(spaceId, 1);
            }
        }
    }

    private function _getDataFromTempArr(roleId:Number):CGiftBagRankData
    {
        for each(var rankData:CGiftBagRankData in m_arrTemp)
        {
            if(rankData && rankData.roleID == roleId)
            {
                return rankData;
            }
        }

        return null;
    }

    private function _onClickReduceHandler(view:ClubGiftAllocateViewUI, spaceId:int):void
    {
        if(view.txt_num.text == "1")
        {
            view.txt_num.text = "0";

            var rankData:CGiftBagRankData = view.dataSource as CGiftBagRankData;
            if(rankData)
            {
                // 从临时数组中删除
                var tempData:CGiftBagRankData = _getDataFromTempArr(rankData.roleID);
                if(tempData)
                {
                    if(tempData.alreadyReceiveRewardBags.indexOf(spaceId) != -1)
                    {
                        var index:int = tempData.alreadyReceiveRewardBags.indexOf(spaceId);
                        tempData.alreadyReceiveRewardBags.splice(index, 1);
                    }
                }

                _updateTotalGiftView(spaceId, -1);
            }
        }
    }

    /**
     * 更新左边的总礼包数
     * @param spaceId
     * @param changeNum
     */
    private function _updateTotalGiftView(spaceId:int, changeNum:int):void
    {
        for(var i:int = 1; i <= 3; i++)
        {
            var view:ClubSpaceGiftBagViewUI = m_pViewUI["view_gift"+i] as ClubSpaceGiftBagViewUI;
            if(view)
            {
                var data:CAllocateGiftBagData = view.dataSource as CAllocateGiftBagData;
                if(data && data.spaceId == spaceId)
                {
                    data.alreadyAllocateRewardBagCount += changeNum;
                    var totalGiftData:CAllocateGiftBagData = _guildWarData.giftBagData.allocateGiftBagListData.getDataBySpaceId(spaceId);
                    totalGiftData.alreadyAllocateRewardBagCount = data.alreadyAllocateRewardBagCount;

                    var table:GuildWarSpaceTable = _helper.getSpaceTableData(data.spaceId);
                    if(table)
                    {
                        view.txt_giftNum.text = (table.spaceBoxCount - data.alreadyAllocateRewardBagCount) + "";
                    }
                }
            }
        }
    }

    private function _clear():void
    {
        _clearGiftInfo();
        _clearRecordInfo();
    }

    private function _clearGiftInfo():void
    {
        for(var i:int = 1; i <= 3; i++)
        {
            var view:ClubSpaceGiftBagViewUI = m_pViewUI["view_gift"+i] as ClubSpaceGiftBagViewUI;
            view.clip_giftBg.index = 0;
            view.clip_giftIcon.index = 0;
            view.txt_giftNum.text = "";
            view.txt_stationName.text = "";
        }

        m_pViewUI.list_giftAllot.dataSource = [];
    }

    private function _clearRecordInfo():void
    {
        m_pViewUI.txt_record.text = "";
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
