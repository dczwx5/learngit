//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/4/25.
 */
package kof.game.guildWar.view {

import flash.utils.getTimer;

import kof.framework.CViewHandler;
import kof.game.common.CLang;
import kof.game.common.status.CGameStatus;
import kof.game.guildWar.CGuildWarNetHandler;
import kof.game.guildWar.event.CGuildWarEvent;
import kof.ui.master.PeakGame.PeakGameMatchUI;

import morn.core.components.Dialog;
import morn.core.handlers.Handler;

public class CGuildWarMatchViewHandler extends CViewHandler {

    private var m_bViewInitialized : Boolean;
    private var m_pViewUI:PeakGameMatchUI;
    private var m_fStartTime:Number;

    public function CGuildWarMatchViewHandler( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array
    {
        return [ PeakGameMatchUI];
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
                m_pViewUI = new PeakGameMatchUI();

                m_pViewUI.cancel_btn.clickHandler = new Handler(_onClickCancelHandler);

                m_bViewInitialized = true;
            }
        }

        return m_bViewInitialized;
    }

    public function addDisplay() : void
    {
        this.loadAssetsByView( viewClass, _showDisplay );

        CGameStatus.setStatus(CGameStatus.Status_GuildWarMatch);
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
            _addListeners();
        }

        uiCanvas.addPopupDialog(m_pViewUI);
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
            m_pViewUI.matching_txt.visible = false;
            m_pViewUI.count_down_txt.text = "0'0";
            m_fStartTime = getTimer();

            schedule(1, _onScheduleHandler);
        }
    }

    private function _onScheduleHandler(delta : Number):void
    {
        var passMin:int = 0;
        var passSecond:int = 0;
//        var predictTime:int = 0;
//        var sTime:String = CLang.Get("common_time_second");
//        if (_peakGameData) {
//            predictTime = _peakGameData.predictMatchTime;
//            if (predictTime >= 60) {
//                sTime = CLang.Get("common_time_min");
//                predictTime /= 60;
//            }
//        }

        var passTimeSecond:int = (getTimer() - m_fStartTime)/1000;
        passSecond = passTimeSecond % 60;
        passMin = passTimeSecond / 60;

//        var strMatching:String = CLang.Get("peak_matching_desc", {v3:predictTime, v4:sTime});
        var strCountDown:String = CLang.Get("peak_matching_count_down_desc", {v1:passMin, v2:passSecond});
        m_pViewUI.count_down_txt.text = strCountDown;
    }

    private function _onClickCancelHandler():void
    {
        (system.getHandler(CGuildWarNetHandler) as CGuildWarNetHandler).guildWarMatchCancelRequest();
        system.dispatchEvent(new CGuildWarEvent(CGuildWarEvent.CancelMatch, null));
        removeDisplay();
    }

    public function removeDisplay() : void
    {
        if ( m_bViewInitialized )
        {
            _removeListeners();

            unschedule(_onScheduleHandler);

            CGameStatus.unSetStatus(CGameStatus.Status_GuildWarMatch);

            if ( m_pViewUI && m_pViewUI.parent )
            {
                m_pViewUI.close( Dialog.CLOSE );
            }
        }
    }

    public function get isViewShow():Boolean
    {
        return m_pViewUI && m_pViewUI.parent;
    }
}
}
