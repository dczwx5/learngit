//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/4/18.
 */
package kof.game.guildWar.view {

import kof.framework.CViewHandler;
import kof.game.club.CClubManager;
import kof.game.club.CClubSystem;
import kof.game.guildWar.CGuildWarHelpHandler;
import kof.game.guildWar.CGuildWarSystem;
import kof.game.guildWar.data.CGuildWarData;
import kof.ui.CUISystem;
import kof.ui.master.GuildWar.LeagueSettleUI;

import morn.core.components.Box;
import morn.core.components.Clip;

import morn.core.components.Component;

import morn.core.components.Dialog;
import morn.core.components.Label;
import morn.core.handlers.Handler;

/**
 * 俱乐部联赛结算界面
 */
public class CGuildWarResultViewHandler extends CViewHandler {

    private var m_bViewInitialized : Boolean;
    private var m_pViewUI:LeagueSettleUI;

    public function CGuildWarResultViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array
    {
        return [ LeagueSettleUI];
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
                m_pViewUI = new LeagueSettleUI();

                m_pViewUI.btn_alloc.clickHandler = new Handler(_onClickAllockHandler);
                m_pViewUI.list_station.renderHandler = new Handler(_renderStationHandler);

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
        uiCanvas.addDialog( m_pViewUI );

        _initView();
        _addListeners();
    }

    private function _addListeners():void
    {
    }

    private function _removeListeners():void
    {
    }

    private function _initView():void
    {
        if ( m_pViewUI )
        {
            _updateStationList();
        }
    }

    // 空间站列表
    private function _updateStationList():void
    {
        var guildWarData:CGuildWarData = (system as CGuildWarSystem).data;
        if(guildWarData && guildWarData.obtainSpaceIds)
        {
            m_pViewUI.list_station.dataSource = guildWarData.obtainSpaceIds;
            var listWidth:int = 146 * guildWarData.obtainSpaceIds.length
                    + m_pViewUI.list_station.spaceX*(guildWarData.obtainSpaceIds.length-1);
            m_pViewUI.list_station.x = m_pViewUI.width - listWidth >> 1;
        }
        else
        {
            m_pViewUI.list_station.dataSource = [];
        }
    }

    public function removeDisplay() : void
    {
        if ( m_bViewInitialized )
        {
            _removeListeners();

            if ( m_pViewUI && m_pViewUI.parent )
            {
                m_pViewUI.close( Dialog.CLOSE );
            }
        }
    }

    private function _onClickAllockHandler():void
    {
        removeDisplay();
    }

    private function _renderStationHandler(item:Component, index:int):void
    {
        var render : Box = item as Box;
        var data : int = render == null ? 0 : (render.dataSource as int);

        var txt_guildName:Label = render.getChildByName("txt_guildName") as Label;
        var clip_station:Clip = render.getChildByName("clip_station") as Clip;
        var txt_stationName:Label = render.getChildByName("txt_stationName") as Label;

        if(render && data)
        {
            var clubName:String = ((system.stage.getSystem(CClubSystem) as CClubSystem).getHandler(CClubManager) as CClubManager).clubName;
            txt_guildName.text = clubName;
            clip_station.index = _helper.getStationTypeById(data) - 1;
            clip_station.visible = true;
            txt_stationName.text = _helper.getStationNameById(data);
        }
        else
        {
            txt_guildName.text = "";
            clip_station.visible = false;
            txt_stationName.text = "";
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
}
}
