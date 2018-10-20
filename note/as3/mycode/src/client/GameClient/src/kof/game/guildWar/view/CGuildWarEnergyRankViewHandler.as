//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/4/18.
 */
package kof.game.guildWar.view {

import flash.events.Event;

import kof.framework.CViewHandler;
import kof.game.guildWar.CGuildWarHelpHandler;
import kof.game.guildWar.CGuildWarNetHandler;
import kof.game.guildWar.CGuildWarSystem;
import kof.game.guildWar.data.CGuildWarData;
import kof.game.guildWar.data.CStationDetailRankData;
import kof.game.guildWar.data.CStationScoreRankData;
import kof.game.guildWar.data.CTotalScoreRankData;
import kof.game.guildWar.event.CGuildWarEvent;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.subData.CTeamData;
import kof.table.GuildWarSpaceTable;
import kof.ui.CUISystem;
import kof.ui.master.GuildWar.ClubLeagueRankStationItemUI;
import kof.ui.master.GuildWar.ClubLeagueRankTotalItemUI;
import kof.ui.master.GuildWar.ClubLeagueRankUI;

import morn.core.components.Component;

import morn.core.components.Dialog;
import morn.core.handlers.Handler;

/**
 * 能源排行界面
 */
public class CGuildWarEnergyRankViewHandler extends CViewHandler {

    private var m_bViewInitialized : Boolean;
    private var m_pViewUI:ClubLeagueRankUI;
    private var m_iSelectedIndex:int;

    public function CGuildWarEnergyRankViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array
    {
        return [ ClubLeagueRankUI];
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
                m_pViewUI = new ClubLeagueRankUI();

                m_pViewUI.btn_close.clickHandler = new Handler(_onClickCloseHandler);
                m_pViewUI.view_totalRank.list_total.renderHandler = new Handler(_renderTotalScoreHandler);
                m_pViewUI.view_stationRank.list_station.renderHandler = new Handler(_renderStationTotalScoreHandler);

                m_pViewUI.view_totalRank.left_max_btn.clickHandler = new Handler(_onClubPageChange,[m_pViewUI.view_totalRank.left_max_btn]);
                m_pViewUI.view_totalRank.left_btn.clickHandler = new Handler(_onClubPageChange,[m_pViewUI.view_totalRank.left_btn]);
                m_pViewUI.view_totalRank.right_btn.clickHandler = new Handler(_onClubPageChange,[m_pViewUI.view_totalRank.right_btn]);
                m_pViewUI.view_totalRank.right_max_btn.clickHandler = new Handler(_onClubPageChange,[m_pViewUI.view_totalRank.right_max_btn]);

                m_pViewUI.view_totalRank.list_total.dataSource = [];
                m_pViewUI.view_stationRank.list_station.dataSource = [];
                m_pViewUI.view_totalRank.view_selfRank.dataSource = null;
                _renderTotalScoreHandler(m_pViewUI.view_totalRank.view_selfRank, -1);

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
        system.addEventListener(CGuildWarEvent.UpdateTotalScoreRankInfo, _onUpdateTotalScoreHandler);
        system.addEventListener(CGuildWarEvent.UpdateStationTotalScoreRankInfo, _onUpdateStationTotalScoreHandler);
    }

    private function _removeListeners():void
    {
        m_pViewUI.tab.removeEventListener( Event.CHANGE, _onTabSelectedHandler);
    }

    private function _initView():void
    {
        if ( m_pViewUI )
        {
            m_pViewUI.tab.selectedIndex = m_iSelectedIndex;
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
            if(m_pViewUI.view_stationRank.parent)
            {
                m_pViewUI.view_stationRank.remove();
            }

            m_pViewUI.addChild(m_pViewUI.view_totalRank);

            _netHandler.guildWarTotalScoreRankRequest();
        }
        else if(m_pViewUI.tab.selectedIndex == 1)
        {
            if(m_pViewUI.view_totalRank.parent)
            {
                m_pViewUI.view_totalRank.remove();
            }

            m_pViewUI.addChild(m_pViewUI.view_stationRank);

            _netHandler.guildWarSpaceClubTotalScoreRankRequest();
        }
    }

// 点击处理=============================================================================================================
    private function _onClubPageChange(btn:Component):void
    {
        var currPage:int = m_pViewUI.view_totalRank.list_total.page;
        var maxPage:int = m_pViewUI.view_totalRank.list_total.totalPage-1;
        if(btn == m_pViewUI.view_totalRank.left_btn)
        {
            if(currPage > 0)
            {
                m_pViewUI.view_totalRank.list_total.page -= 1;
            }
        }

        if(btn == m_pViewUI.view_totalRank.left_max_btn)
        {
            if(currPage > 0)
            {
                m_pViewUI.view_totalRank.list_total.page = 0;
            }
        }

        if(btn == m_pViewUI.view_totalRank.right_btn)
        {
            if(currPage < maxPage)
            {
                m_pViewUI.view_totalRank.list_total.page += 1;
            }
        }

        if(btn == m_pViewUI.view_totalRank.right_max_btn)
        {
            if(currPage < maxPage)
            {
                m_pViewUI.view_totalRank.list_total.page = maxPage;
            }
        }

        m_pViewUI.view_totalRank.page.text = (m_pViewUI.view_totalRank.list_total.page+1) + "/" + (maxPage+1);
    }

//render处理============================================================================================================
    // 总能源排行
    private function _renderTotalScoreHandler(item:Component, index:int):void
    {
        var render:ClubLeagueRankTotalItemUI = item as ClubLeagueRankTotalItemUI;
        var data:CTotalScoreRankData = render == null ? null : (render.dataSource as CTotalScoreRankData);

        if(render)
        {
            if(data) {
                render.clip_rank.visible = data.ranking <= 3 && data.ranking > 0;
                render.clip_rank.index = data.ranking - 1;
                render.txt_rank.text = data.ranking.toString();
                render.txt_rank.visible = data.ranking > 3;
                render.txt_notOnList.visible = data.ranking == 0;
                render.img_heroIcon.mask = render.img_mask;
                render.img_mask.cacheAsBitmap = true;
                render.img_heroIcon.url = CPlayerPath.getHeroBigconPath( data.headIcon );
                render.img_heroIcon.cacheAsBitmap = true;
                render.txt_roleName.text = data.name;
                render.txt_energyNum.text = data.score.toString();

                if (data.ranking <= 3 && data.ranking > 0)
                {
                    render.clip_bg.index = data.ranking - 1;
                }
                else
                {
                    render.clip_bg.index = 3;
                }
            }
            else
            {
                if(index == -1)
                {
                    render.clip_rank.visible = false;
                    render.txt_rank.visible = false;
                    render.txt_notOnList.visible = true;
                    var teamData:CTeamData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData.teamData;
                    render.img_heroIcon.mask = render.img_mask;
                    render.img_mask.cacheAsBitmap = true;
                    render.img_heroIcon.url = CPlayerPath.getHeroBigconPath( teamData.prototypeID );
                    render.img_heroIcon.cacheAsBitmap = true;
                    render.txt_roleName.text = teamData.name;
                    render.txt_energyNum.text = _guildWarData.baseData.totalScore.toString();
                }
            }
        }
    }

    // 空间站能源排行
    private function _renderStationTotalScoreHandler(item:Component, index:int):void
    {
        var render:ClubLeagueRankStationItemUI = item as ClubLeagueRankStationItemUI;
        var data:CStationScoreRankData = render == null ? null : (render.dataSource as CStationScoreRankData);

        if(render && data)
        {
            render.clip_station.index = _helper.getStationTypeById(data.spaceId) - 1;
            var spaceTableData:GuildWarSpaceTable = _helper.getSpaceTableData(data.spaceId);
            render.txt_stationName.text = spaceTableData == null ? "" : spaceTableData.spaceName;
            var rankData:CStationDetailRankData = _getNo1(data);
            render.txt_roleName.text = rankData == null ? "" : rankData.name;
            render.txt_energyNum.text = rankData == null ? "" : rankData.score.toString();

            render.link_lookDetail.clickHandler = new Handler(_onClickLookDetailHandler, [data.detailRankListData.list]);
        }
    }

    private function _getNo1(data:CStationScoreRankData):CStationDetailRankData
    {
        if(data && data.detailRankListData)
        {
            return data.detailRankListData.getDetailData(1);
        }

        return null;
    }

    // 查看详情
    private function _onClickLookDetailHandler(dataArr:Array):void
    {
        if(dataArr && dataArr.length)
        {
            var detailView:CGuildWarEnergyDetailViewHandler = system.getHandler(CGuildWarEnergyDetailViewHandler)
                    as CGuildWarEnergyDetailViewHandler;
            if(detailView && !detailView.isViewShow)
            {
                detailView.data = dataArr;
                detailView.addDisplay();
            }
        }
    }


//监听处理==============================================================================================================
    /**
     * 总能源排行
     * @param e
     */
    private function _onUpdateTotalScoreHandler(e:CGuildWarEvent):void
    {
        if(_guildWarData && _guildWarData.totalScoreRankListData)
        {
            m_pViewUI.view_totalRank.list_total.dataSource = _guildWarData.totalScoreRankListData.list;
            var roleId:Number = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData.ID;
            m_pViewUI.view_totalRank.view_selfRank.dataSource = _guildWarData.totalScoreRankListData.getRankData(roleId);
        }
        else
        {
            m_pViewUI.view_totalRank.view_selfRank.dataSource = null;
            m_pViewUI.view_totalRank.list_total.dataSource = [];
        }

        _renderTotalScoreHandler(m_pViewUI.view_totalRank.view_selfRank, -1);

        _updatePageInfo();
    }

    private function _updatePageInfo():void
    {
        if(_guildWarData && _guildWarData.totalScoreRankListData)
        {
            m_pViewUI.view_totalRank.box_page.visible = true;
            m_pViewUI.view_totalRank.list_total.page = 0;

            var currPage:int = m_pViewUI.view_totalRank.list_total.page + 1;
            var maxPage:int = m_pViewUI.view_totalRank.list_total.totalPage;
            m_pViewUI.view_totalRank.page.text = currPage + "/" + maxPage;
        }
        else
        {
            m_pViewUI.view_totalRank.box_page.visible = false;
        }
    }

    /**
     * 空间站能源排行
     * @param e
     */
    private function _onUpdateStationTotalScoreHandler(e:CGuildWarEvent):void
    {
        if(_guildWarData && _guildWarData.stationTotalScoreRankListData)
        {
            m_pViewUI.view_stationRank.list_station.dataSource = _guildWarData.stationTotalScoreRankListData.list;
        }
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

    private function get _netHandler():CGuildWarNetHandler
    {
        return system.getHandler(CGuildWarNetHandler) as CGuildWarNetHandler;
    }
}
}
