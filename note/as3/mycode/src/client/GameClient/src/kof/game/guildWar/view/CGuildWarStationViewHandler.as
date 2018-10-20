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
import kof.game.common.CItemUtil;
import kof.game.common.CRewardUtil;
import kof.game.guildWar.CGuildWarHelpHandler;
import kof.game.guildWar.CGuildWarNetHandler;
import kof.game.guildWar.CGuildWarSystem;
import kof.game.guildWar.data.CClubRankCellData;
import kof.game.guildWar.data.CGuildWarData;
import kof.game.guildWar.data.CRoleRankCellData;
import kof.game.guildWar.data.fightReport.CGuildWarFightReportContentData;
import kof.game.guildWar.event.CGuildWarEvent;
import kof.game.instance.enum.EInstanceType;
import kof.game.item.data.CRewardListData;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CEmbattleListData;
import kof.table.GuildWarSpaceTable;
import kof.table.GuildWarSpaceTable;
import kof.ui.CMsgAlertHandler;
import kof.ui.CUISystem;
import kof.ui.master.GuildWar.LeagueStrongholdClubRankItemUI;
import kof.ui.master.GuildWar.LeagueStrongholdRankItemUI;
import kof.ui.master.GuildWar.LeagueStrongholdStationUI;

import morn.core.components.Component;

import morn.core.components.Dialog;
import morn.core.handlers.Handler;

/**
 * 空间站信息界面(排行和战报)
 */
public class CGuildWarStationViewHandler extends CViewHandler {

    private var m_bViewInitialized : Boolean;
    private var m_pViewUI:LeagueStrongholdStationUI;
    private var m_iSelectedIndex:int;
    private var m_iStationId:int;

    public function CGuildWarStationViewHandler( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array
    {
        return [ LeagueStrongholdStationUI];
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
                m_pViewUI = new LeagueStrongholdStationUI();

                m_pViewUI.btn_close.clickHandler = new Handler(_onClickCloseHandler);
                m_pViewUI.btn_fight.clickHandler = new Handler(_onClickFightHandler);
                m_pViewUI.list_dailyReward.renderHandler = new Handler(CItemUtil.getItemRenderFunc(system));
                m_pViewUI.list_combatReward.renderHandler = new Handler(CItemUtil.getItemRenderFunc(system));
                m_pViewUI.list_clubRank.renderHandler = new Handler(_clubRankRenderHandler);
                m_pViewUI.list_personRank.renderHandler = new Handler(_roleRankRenderHandler);

                m_pViewUI.left_max_btn1.clickHandler = new Handler(_onClubPageChange,[m_pViewUI.left_max_btn1]);
                m_pViewUI.left_btn1.clickHandler = new Handler(_onClubPageChange,[m_pViewUI.left_btn1]);
                m_pViewUI.right_btn1.clickHandler = new Handler(_onClubPageChange,[m_pViewUI.right_btn1]);
                m_pViewUI.right_max_btn1.clickHandler = new Handler(_onClubPageChange,[m_pViewUI.right_max_btn1]);

                m_pViewUI.left_max_btn2.clickHandler = new Handler(_onRolePageChange,[m_pViewUI.left_max_btn2]);
                m_pViewUI.left_btn2.clickHandler = new Handler(_onRolePageChange,[m_pViewUI.left_btn2]);
                m_pViewUI.right_btn2.clickHandler = new Handler(_onRolePageChange,[m_pViewUI.right_btn2]);
                m_pViewUI.right_max_btn2.clickHandler = new Handler(_onRolePageChange,[m_pViewUI.right_max_btn2]);

                m_pViewUI.list_clubRank.dataSource = [];
                m_pViewUI.list_personRank.dataSource = [];

                m_pViewUI.box_roleName1.visible = false;
                m_pViewUI.box_roleName2.visible = false;
                m_pViewUI.box_win1.visible = false;
                m_pViewUI.box_win2.visible = false;

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
            _reqInfo();
        }

        uiCanvas.addPopupDialog(m_pViewUI);
    }

    private function _reqInfo():void
    {
        (system.getHandler(CGuildWarNetHandler) as CGuildWarNetHandler).guildWarSpaceClubInfoRequest();
    }

    private function _addListeners():void
    {
        m_pViewUI.tab.addEventListener( Event.CHANGE, _onTabSelectedHandler);
        system.addEventListener(CGuildWarEvent.CancelMatch, _onCancelMatchHandler);
        system.addEventListener(CGuildWarEvent.UpdateClubRankInfo, _updateClubRankInfo);
        system.addEventListener(CGuildWarEvent.UpdateRoleRankInfo, _updateRoleRankInfo);
        system.addEventListener(CGuildWarEvent.UpdateFightReportInfo, _updateFightReportInfo);
    }

    private function _removeListeners():void
    {
        m_pViewUI.tab.removeEventListener( Event.CHANGE, _onTabSelectedHandler);
        system.removeEventListener(CGuildWarEvent.CancelMatch, _onCancelMatchHandler);
        system.removeEventListener(CGuildWarEvent.UpdateClubRankInfo, _updateClubRankInfo);
        system.removeEventListener(CGuildWarEvent.UpdateRoleRankInfo, _updateRoleRankInfo);
        system.removeEventListener(CGuildWarEvent.UpdateFightReportInfo, _updateFightReportInfo);
    }

    private function _initView():void
    {
        if ( m_pViewUI )
        {
            m_pViewUI.tab.selectedIndex = m_iSelectedIndex;
            m_pViewUI.btn_fight.disabled = false;
            m_pViewUI.txt_notOpen.visible = false;

            _updateDailyRewardInfo();
            _updateCombatRewardInfo();
            _updateStationImgInfo();
            _updateBtnState();
        }
    }

    private function _updateDailyRewardInfo():void
    {
        var spaceTableData:GuildWarSpaceTable = _helper.getSpaceTableData(m_iStationId);
        if(spaceTableData)
        {
            var rewardListData:CRewardListData = CRewardUtil.createByDropPackageID(system.stage, spaceTableData.dayReward);

            if(rewardListData)
            {
                var rewardArr:Array = rewardListData.list;
                m_pViewUI.list_dailyReward.dataSource = rewardArr;
            }
            else
            {
                m_pViewUI.list_dailyReward.dataSource = [];
            }
        }
        else
        {
            m_pViewUI.list_dailyReward.dataSource = [];
        }
    }

    private function _updateStationImgInfo():void
    {
        var tableData:GuildWarSpaceTable = _helper.getSpaceTableData(m_iStationId);
        if(tableData)
        {
            m_pViewUI.clip_station.index = tableData.spaceType - 1;
            m_pViewUI.txt_stationName.text = tableData.spaceName;
//            m_pViewUI.txt_stationName.text = tableData.spaceName + m_iStationId;
        }
    }

    private function _updateCombatRewardInfo():void
    {
        var spaceTableData:GuildWarSpaceTable = _helper.getSpaceTableData(m_iStationId);
        if(spaceTableData)
        {
            var rewardListData:CRewardListData = CRewardUtil.createByDropPackageID(system.stage, spaceTableData.spaceBox);

            if(rewardListData)
            {
                var rewardArr:Array = rewardListData.list;
                m_pViewUI.list_combatReward.dataSource = rewardArr;

//                var listWidth:int = 52 * rewardArr.length + m_pViewUI.list_combatReward.spaceX * (rewardArr.length-1);
//                m_pViewUI.list_combatReward.x = (248 - listWidth >> 1) + 596;
            }
            else
            {
                m_pViewUI.list_combatReward.dataSource = [];
            }
        }
        else
        {
            m_pViewUI.list_combatReward.dataSource = [];
        }
    }

    private function _updateBtnState():void
    {
        if(_helper.isInActivityTime())
        {
            m_pViewUI.btn_fight.disabled = false;
            m_pViewUI.btn_fight.label = "开赛";
        }
        else
        {
            m_pViewUI.btn_fight.disabled = true;
            m_pViewUI.btn_fight.label = "休赛期";
        }
    }

    private function _onTabSelectedHandler(e:Event = null):void
    {
        m_iSelectedIndex = m_pViewUI.tab.selectedIndex;

        if(m_pViewUI.tab.selectedIndex == 0)
        {
            if(m_pViewUI.box_personRank.parent)
            {
                m_pViewUI.box_personRank.remove();
            }

            if(m_pViewUI.box_reportInfo.parent)
            {
                m_pViewUI.box_reportInfo.remove();
                m_pViewUI.txt_report.text = "";
            }
            m_pViewUI.addChild(m_pViewUI.box_clubRank);

            _netHandler.stationClubRankRequest(m_iStationId);
        }
        else if(m_pViewUI.tab.selectedIndex == 1)
        {
            if(m_pViewUI.box_clubRank.parent)
            {
                m_pViewUI.box_clubRank.remove();
            }

            if(m_pViewUI.box_reportInfo.parent)
            {
                m_pViewUI.box_reportInfo.remove();
                m_pViewUI.txt_report.text = "";
            }
            m_pViewUI.addChild(m_pViewUI.box_personRank);

            _netHandler.stationRoleRankRequest(m_iStationId);
        }
        else if(m_pViewUI.tab.selectedIndex == 2)
        {
            if(m_pViewUI.box_clubRank.parent)
            {
                m_pViewUI.box_clubRank.remove();
            }

            if(m_pViewUI.box_personRank.parent)
            {
                m_pViewUI.box_personRank.remove();
            }
            m_pViewUI.addChild(m_pViewUI.box_reportInfo);

            _netHandler.fightReportRequest(m_iStationId);
        }
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

            m_pViewUI.list_clubRank.dataSource = [];
            m_pViewUI.list_personRank.dataSource = [];

            _clearInfo();
        }
    }

//点击处理=============================================================================================================
    private function _onClickCloseHandler():void
    {
        removeDisplay();
    }

    private function _onClickFightHandler():void
    {
        if(!_helper.isInActivityTime())
        {
            _uiSystem.showMsgAlert("很抱歉，不在活动时间内。", CMsgAlertHandler.WARNING);
            return;
        }

        var playerSystem:CPlayerSystem = system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
        var emList:CEmbattleListData = playerSystem.playerData.embattleManager.getByType(EInstanceType.TYPE_GUILD_WAR);
        if (emList && emList.list.length == 0)
        {
            _uiSystem.showMsgAlert("很抱歉，请先进行出战编制。", CMsgAlertHandler.WARNING);
            return;
        }

        var _guildWarData:CGuildWarData = (system as CGuildWarSystem).data;
        if(_guildWarData && _guildWarData.baseData)
        {
            var winNum:int = _guildWarData.baseData.alwaysWin;
            if(winNum >= 1 && _guildWarData.baseData.currentSpaceId != 0 && _guildWarData.baseData.currentSpaceId != m_iStationId)
            {
                var tipView:CGuildWarEndWinViewHandler = system.getHandler(CGuildWarEndWinViewHandler) as CGuildWarEndWinViewHandler;
                tipView.stationId = m_iStationId;
                tipView.addDisplay();
                return;
            }
        }

        var matchView:CGuildWarMatchViewHandler = system.getHandler(CGuildWarMatchViewHandler) as CGuildWarMatchViewHandler;
        if(matchView && !matchView.isViewShow)
        {
            (system.getHandler(CGuildWarNetHandler) as CGuildWarNetHandler).guildWarAppointSpaceMatchRequest(m_iStationId);
            matchView.addDisplay();

            m_pViewUI.btn_fight.disabled = true;
        }
    }

    private function _onClubPageChange(btn:Component):void
    {
        var currPage:int = m_pViewUI.list_clubRank.page;
        var maxPage:int = m_pViewUI.list_clubRank.totalPage-1;
        if(btn == m_pViewUI.left_btn1)
        {
            if(currPage > 0)
            {
                m_pViewUI.list_clubRank.page -= 1;
            }
        }

        if(btn == m_pViewUI.left_max_btn1)
        {
            if(currPage > 0)
            {
                m_pViewUI.list_clubRank.page = 0;
            }
        }

        if(btn == m_pViewUI.right_btn1)
        {
            if(currPage < maxPage)
            {
                m_pViewUI.list_clubRank.page += 1;
            }
        }

        if(btn == m_pViewUI.right_max_btn1)
        {
            if(currPage < maxPage)
            {
                m_pViewUI.list_clubRank.page = maxPage;
            }
        }

        m_pViewUI.page1.text = (m_pViewUI.list_personRank.page+1) + "/" + (maxPage+1);
    }

    private function _onRolePageChange(btn:Component):void
    {
        var currPage:int = m_pViewUI.list_personRank.page;
        var maxPage:int = m_pViewUI.list_personRank.totalPage-1;
        if(btn == m_pViewUI.left_btn2)
        {
            if(currPage > 0)
            {
                m_pViewUI.list_personRank.page -= 1;
            }
        }

        if(btn == m_pViewUI.left_max_btn2)
        {
            if(currPage > 0)
            {
                m_pViewUI.list_personRank.page = 0;
            }
        }

        if(btn == m_pViewUI.right_btn2)
        {
            if(currPage < maxPage)
            {
                m_pViewUI.list_personRank.page += 1;
            }
        }

        if(btn == m_pViewUI.right_max_btn2)
        {
            if(currPage < maxPage)
            {
                m_pViewUI.list_personRank.page = maxPage;
            }
        }

        m_pViewUI.page2.text = (m_pViewUI.list_personRank.page+1) + "/" + (maxPage+1);
    }

//render处理=============================================================================================================
    private function _clubRankRenderHandler(item:Component, index:int):void
    {
        if(item == null)
        {
            return;
        }

        var render:LeagueStrongholdClubRankItemUI = item as LeagueStrongholdClubRankItemUI;
        var rankData:CClubRankCellData = render == null ? null : (render.dataSource as CClubRankCellData);
        if(render && rankData)
        {
            render.txt_rank.text = rankData.ranking.toString();
            render.txt_rank.visible = rankData.ranking > 3;
            render.clip_rank.visible = rankData.ranking <= 3 && rankData.ranking > 0;
            render.clip_rank.index = rankData.ranking - 1;
            render.txt_notOnList.visible = rankData.ranking == 0;
            render.txt_clubName.text = rankData.clubName;
            render.txt_clubName.y = 7;
            render.img_energy.visible = true;
            render.txt_score.text = rankData.clubScore.toString();
            render.img_clubIcon.visible = true;
        }
        else
        {
            render.txt_rank.text = "";
            render.clip_rank.visible = false;
            render.txt_clubName.text = "";
            render.txt_score.text = "";
            render.img_energy.visible = false;
            render.img_clubIcon.visible = false;
            render.txt_notOnList.visible = false;
        }
    }

    private function _roleRankRenderHandler(item:Component, index:int):void
    {
        if(item == null)
        {
            return;
        }

        var render:LeagueStrongholdRankItemUI = item as LeagueStrongholdRankItemUI;
        var rankData:CRoleRankCellData = render == null ? null : (render.dataSource as CRoleRankCellData);
        if(render && rankData)
        {
            render.txt_rank.text = rankData.ranking.toString();
            render.txt_rank.visible = rankData.ranking > 3;
            render.clip_rank.visible = rankData.ranking <= 3 && rankData.ranking > 0;
            render.clip_rank.index = rankData.ranking - 1;
            render.txt_notOnList.visible = rankData.ranking == 0;
            render.txt_clubName.text = rankData.clubName;
            render.txt_clubName.y = 7;
            render.txt_roleName.text = rankData.name;
            render.img_energy.visible = true;
            render.txt_score.text = rankData.score.toString();
            render.img_clubIcon.visible = true;
        }
        else
        {
            render.txt_rank.text = "";
            render.clip_rank.visible = false;
            render.txt_clubName.text = "";
            render.txt_score.text = "";
            render.img_energy.visible = false;
            render.img_clubIcon.visible = false;
            render.txt_roleName.text = "";
            render.txt_notOnList.visible = false;
        }
    }


//监听处理=============================================================================================================
    private function _updateClubRankInfo(e:CGuildWarEvent = null):void
    {
        var guildWarData:CGuildWarData = (system as CGuildWarSystem).data;
        if(guildWarData && guildWarData.stationClubRankData && guildWarData.stationClubRankData.spaceId == m_iStationId)
        {
            m_pViewUI.list_clubRank.dataSource = guildWarData.stationClubRankData.rankListData.list;
            m_pViewUI.view_selfClubRank.dataSource = guildWarData.stationClubRankData.myRankData;
            _clubRankRenderHandler(m_pViewUI.view_selfClubRank, -1);
        }
        else
        {
            m_pViewUI.view_selfClubRank.dataSource = null;
            _clubRankRenderHandler(m_pViewUI.view_selfClubRank, -1);
        }

        _updatePageInfo1();
    }

    private function _updatePageInfo1():void
    {
        var guildWarData:CGuildWarData = (system as CGuildWarSystem).data;
        if(guildWarData && guildWarData.stationClubRankData && guildWarData.stationClubRankData.spaceId == m_iStationId
                && guildWarData.stationClubRankData.rankListData.list.length)
        {
            m_pViewUI.box_page_club.visible = true;
            m_pViewUI.list_clubRank.page = 0;

            var currPage:int = m_pViewUI.list_clubRank.page + 1;
            var maxPage:int = m_pViewUI.list_clubRank.totalPage;
            m_pViewUI.page1.text = currPage + "/" + maxPage;
        }
        else
        {
            m_pViewUI.box_page_club.visible = false;
        }
    }

    private function _updateRoleRankInfo(e:CGuildWarEvent = null):void
    {
        var guildWarData:CGuildWarData = (system as CGuildWarSystem).data;
        if(guildWarData && guildWarData.stationRoleRankData && guildWarData.stationRoleRankData.spaceId == m_iStationId)
        {
            m_pViewUI.list_personRank.dataSource = guildWarData.stationRoleRankData.rankListData.list;
            m_pViewUI.view_selfRank.dataSource = guildWarData.stationRoleRankData.myRankData;
            _roleRankRenderHandler(m_pViewUI.view_selfRank, -1);
        }
        else
        {
            m_pViewUI.view_selfRank.dataSource = null;
            _roleRankRenderHandler(m_pViewUI.view_selfRank, -1);
        }

        _updatePageInfo2();
    }

    private function _updatePageInfo2():void
    {
        var guildWarData:CGuildWarData = (system as CGuildWarSystem).data;
        if(guildWarData && guildWarData.stationRoleRankData && guildWarData.stationRoleRankData.spaceId == m_iStationId
                && guildWarData.stationRoleRankData.rankListData.list.length)
        {
            m_pViewUI.box_page_role.visible = true;
            m_pViewUI.list_personRank.page = 0;

            var currPage:int = m_pViewUI.list_personRank.page + 1;
            var maxPage:int = m_pViewUI.list_personRank.totalPage;
            m_pViewUI.page2.text = currPage + "/" + maxPage;
        }
        else
        {
            m_pViewUI.box_page_role.visible = false;
        }
    }

    private function _updateFightReportInfo(e:CGuildWarEvent = null):void
    {
        var guildWarData:CGuildWarData = (system as CGuildWarSystem).data;
        if(guildWarData && guildWarData.fightReportData && guildWarData.fightReportData.alwaysWinData)
        {
            m_pViewUI.img_vip1.visible = false;
            m_pViewUI.txt_roleName1.text = guildWarData.fightReportData.alwaysWinData.historyHighWinName;
            m_pViewUI.txt_winNum1.text = guildWarData.fightReportData.alwaysWinData.historyHighWin.toString();
            m_pViewUI.box_roleName1.visible = guildWarData.fightReportData.alwaysWinData.historyHighWinName;
            m_pViewUI.box_win1.visible = guildWarData.fightReportData.alwaysWinData.historyHighWin;

            m_pViewUI.img_vip2.visible = false;
            m_pViewUI.txt_roleName2.text = guildWarData.fightReportData.alwaysWinData.alwaysWinName;
            m_pViewUI.txt_winNum2.text = guildWarData.fightReportData.alwaysWinData.alwaysWin.toString();
            m_pViewUI.box_roleName2.visible = guildWarData.fightReportData.alwaysWinData.alwaysWinName;
            m_pViewUI.box_win2.visible = guildWarData.fightReportData.alwaysWinData.alwaysWin;

            m_pViewUI.txt_report.isHtml = true;
            m_pViewUI.txt_report.text = "";

            var reportList:Array = guildWarData.fightReportData.fightReportContentListData.list;
            for each(var reportData:CGuildWarFightReportContentData in reportList)
            {
                if(reportData)
                {
                    var dateStr:String = CTime.formatHMSStr(reportData.time);
                    m_pViewUI.txt_report.text += HtmlUtil.color(dateStr, "#ffd940");
                    var contentStr:String = _helper.getFightReportContent(reportData.reportConfigID);
                    if(contentStr)
                    {
                        for (var i:int = 0; i < reportData.reportContents.length; i++) {
                            var findKey : String = "{" + i + "}";
                            if ( contentStr.indexOf( findKey ) != -1 ) {
                                contentStr = contentStr.replace(findKey, reportData.reportContents[i]);
                            }
                        }
//                        m_pViewUI.txt_report.text += HtmlUtil.color(" "+contentStr, "#bfdeed");
                        m_pViewUI.txt_report.text += " " + contentStr;
                        m_pViewUI.txt_report.text += "<br>";
                    }
                }
            }

            m_pViewUI.txt_report.height = m_pViewUI.txt_report.textField.textHeight + 10;

//            callLater( function refresh():void{
                m_pViewUI.panel_report.scrollTo( 0,0 );
                m_pViewUI.panel_report.refresh();
//            })
        }
        else
        {
            m_pViewUI.box_roleName1.visible = false;
            m_pViewUI.box_roleName2.visible = false;
            m_pViewUI.box_win1.visible = false;
            m_pViewUI.box_win2.visible = false;
            m_pViewUI.txt_report.text = "";
        }
    }

    private function _onCancelMatchHandler(e:CGuildWarEvent):void
    {
        m_pViewUI.btn_fight.disabled = false;
    }

    private function _clearInfo():void
    {
        m_pViewUI.box_roleName1.visible = false;
        m_pViewUI.box_roleName2.visible = false;
        m_pViewUI.box_win1.visible = false;
        m_pViewUI.box_win2.visible = false;
        m_pViewUI.txt_report.text = "";

        m_pViewUI.box_page_club.visible = false;
        m_pViewUI.box_page_role.visible = false;

        m_pViewUI.view_selfClubRank.dataSource = null;
        _clubRankRenderHandler(m_pViewUI.view_selfClubRank, -1);

        m_pViewUI.view_selfRank.dataSource = null;
        _roleRankRenderHandler(m_pViewUI.view_selfRank, -1);
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

    private function get _netHandler():CGuildWarNetHandler
    {
        return system.getHandler(CGuildWarNetHandler) as CGuildWarNetHandler;
    }

    public function set stationId(value:int):void
    {
        m_iStationId = value;
    }

    public function set btnDisabled(value:Boolean):void
    {
        m_pViewUI.btn_fight.disabled = value;
    }
}
}
