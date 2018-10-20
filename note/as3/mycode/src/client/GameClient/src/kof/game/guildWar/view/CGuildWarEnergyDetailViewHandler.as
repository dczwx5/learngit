//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/4/18.
 */
package kof.game.guildWar.view {

import kof.framework.CViewHandler;
import kof.game.guildWar.CGuildWarHelpHandler;
import kof.game.guildWar.data.CStationDetailRankData;
import kof.ui.CUISystem;
import kof.ui.master.GuildWar.LeagueEnergyDatailsItemUI;
import kof.ui.master.GuildWar.LeagueEnergyDatailsUI;

import morn.core.components.Component;

import morn.core.components.Dialog;
import morn.core.handlers.Handler;

/**
 * 能源详情界面
 */
public class CGuildWarEnergyDetailViewHandler extends CViewHandler {

    private var m_bViewInitialized : Boolean;
    private var m_pViewUI:LeagueEnergyDatailsUI;
    private var m_arrRankList:Array;

    public function CGuildWarEnergyDetailViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array
    {
        return [ LeagueEnergyDatailsUI];
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
                m_pViewUI = new LeagueEnergyDatailsUI();

                m_pViewUI.btn_close.clickHandler = new Handler(_onClickCloseHandler);
                m_pViewUI.list_rank.renderHandler = new Handler(_renderRankListHandler);

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
        uiCanvas.addPopupDialog( m_pViewUI );

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
            _updateRankList();
        }
    }

    private function _updateRankList():void
    {
        if(m_arrRankList && m_arrRankList.length)
        {
            m_pViewUI.list_rank.dataSource = m_arrRankList;
        }
    }

    private function _renderRankListHandler(item:Component, index:int):void
    {
        var render : LeagueEnergyDatailsItemUI = item as LeagueEnergyDatailsItemUI;
        var data : CStationDetailRankData = render == null ? null : (render.dataSource as CStationDetailRankData);

        if( render && data)
        {
            render.txt_rank.text = data.ranking.toString();
            render.txt_rank.visible = data.ranking > 3;
            render.clip_rank.index = data.ranking - 1;
            render.clip_rank.visible = data.ranking <= 3;
            render.img_vip.visible = false;
            render.txt_name.text = data.name;
            render.txt_energy.text = data.score.toString();
        }
        else
        {
            render.txt_rank.text = "";
            render.clip_rank.visible = false;
            render.img_vip.visible = false;
            render.txt_name.text = "";
            render.txt_energy.text = "";
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

    private function _onClickCloseHandler():void
    {
        removeDisplay();
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

    public function set data(value:Array):void
    {
        m_arrRankList = value;
    }
}
}
