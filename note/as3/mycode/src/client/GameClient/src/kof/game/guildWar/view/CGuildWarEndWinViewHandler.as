//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/4/18.
 */
package kof.game.guildWar.view {

import QFLib.Utils.HtmlUtil;

import kof.framework.CViewHandler;
import kof.game.guildWar.CGuildWarHelpHandler;
import kof.game.guildWar.CGuildWarNetHandler;
import kof.game.guildWar.CGuildWarSystem;
import kof.game.guildWar.data.CGuildWarData;
import kof.table.GuildWarSpaceTable;
import kof.ui.CUISystem;
import kof.ui.master.GuildWar.ClubLeagueEndUI;

import morn.core.components.Dialog;
import morn.core.handlers.Handler;

/**
 * 终结连胜界面
 */
public class CGuildWarEndWinViewHandler extends CViewHandler {

    private var m_bViewInitialized : Boolean;
    private var m_pViewUI:ClubLeagueEndUI;
    private var m_iStationId:int;

    public function CGuildWarEndWinViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array
    {
        return [ ClubLeagueEndUI];
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
                m_pViewUI = new ClubLeagueEndUI();

                m_pViewUI.btn_cancel.clickHandler = new Handler(_onClickCancelHandler);
                m_pViewUI.btn_confirm.clickHandler = new Handler(_onClickConfirmHandler);
                m_pViewUI.checkBox_refuse.clickHandler = new Handler(_onClickRefuseHandler);
                m_pViewUI.btn_close.clickHandler = new Handler(_onClickCloseHandler);

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
            m_pViewUI.checkBox_refuse.visible = false;

            _updateEndInfo();
        }
    }

    private function _updateEndInfo():void
    {
        var guildWar:CGuildWarData = (system as CGuildWarSystem).data;
        if(guildWar && guildWar.baseData)
        {
            m_pViewUI.txt_desc.isHtml = true;
            var table:GuildWarSpaceTable = _helper.getSpaceTableData(guildWar.baseData.currentSpaceId);
            var spaceName:String = table == null ? "" : table.spaceName;
            m_pViewUI.txt_desc.text = "您当前在" + spaceName + "达成" + HtmlUtil.color(guildWar.baseData.alwaysWin+"", "#00ffff")
                    + "连胜，更换空间站会自动终结连胜，确认更换？";
        }
        else
        {
            m_pViewUI.txt_desc.text = "";
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

    private function _onClickCancelHandler():void
    {
        removeDisplay();
    }

    private function _onClickConfirmHandler():void
    {
        var matchView:CGuildWarMatchViewHandler = system.getHandler(CGuildWarMatchViewHandler) as CGuildWarMatchViewHandler;
        if(matchView && !matchView.isViewShow)
        {
            (system.getHandler(CGuildWarNetHandler) as CGuildWarNetHandler).guildWarAppointSpaceMatchRequest(m_iStationId);
            matchView.addDisplay();

            var stationView:CGuildWarStationViewHandler = system.getHandler(CGuildWarStationViewHandler)
                    as CGuildWarStationViewHandler;
            if(stationView)
            {
                stationView.btnDisabled = true;
            }
        }

        removeDisplay();
    }

    private function _onClickRefuseHandler():void
    {
        // TODO
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

    public function set stationId(value:int):void
    {
        m_iStationId = value;
    }
}
}
