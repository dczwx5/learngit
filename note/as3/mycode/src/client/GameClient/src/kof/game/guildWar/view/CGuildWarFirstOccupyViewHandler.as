//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/5/30.
 */
package kof.game.guildWar.view {

import flash.events.Event;

import kof.framework.CViewHandler;
import kof.game.club.data.CClubConst;
import kof.game.common.CItemUtil;
import kof.game.common.CRewardUtil;
import kof.game.guildWar.CGuildWarHelpHandler;
import kof.game.guildWar.enum.EStationType;
import kof.game.item.data.CRewardListData;
import kof.table.FirstOccupyReward;
import kof.ui.CUISystem;
import kof.ui.master.GuildWar.FirstOccupyRewardWinItemUI;
import kof.ui.master.GuildWar.FirstOccupyRewardWinUI;

import morn.core.components.Component;

import morn.core.components.Dialog;
import morn.core.handlers.Handler;

/**
 * 首占奖励
 */
public class CGuildWarFirstOccupyViewHandler extends CViewHandler {

    private var m_bViewInitialized : Boolean;
    private var m_pViewUI:FirstOccupyRewardWinUI;
    private var m_iSelectedIndex:int;

    public function CGuildWarFirstOccupyViewHandler( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array
    {
        return [ FirstOccupyRewardWinUI];
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
                m_pViewUI = new FirstOccupyRewardWinUI();

                m_pViewUI.list_info.renderHandler = new Handler(_renderInfoHandler);

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

    private function _onTabSelectedHandler(e:Event = null):void
    {
        m_iSelectedIndex = m_pViewUI.tab.selectedIndex;

        var spaceType:int;
        if(m_pViewUI.tab.selectedIndex == 0)
        {
            spaceType = EStationType.Type_High;
        }
        else if(m_pViewUI.tab.selectedIndex == 1)
        {
            spaceType = EStationType.Type_Mid;
        }
        else if(m_pViewUI.tab.selectedIndex == 2)
        {
            spaceType = EStationType.Type_Low;
        }

        m_pViewUI.list_info.dataSource = _helper.getFirstOccupyRewardInfo(spaceType);
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

    private function _onClickConfirmHandler():void
    {
        removeDisplay();
    }

    private function _onClickCloseHandler():void
    {
        removeDisplay();
    }


//render处理===========================================================================================================
    private function _renderInfoHandler(item:Component, index:int):void
    {
        var render:FirstOccupyRewardWinItemUI = item as FirstOccupyRewardWinItemUI;
        var data:FirstOccupyReward = render == null ? null : (item.dataSource as FirstOccupyReward);

        if(render && data)
        {
            switch (data.guildPosition)
            {
                case CClubConst.CLUB_POSITION_1:
                    render.txt_positionInfo.text = "成员可获得";
                    break;
                case CClubConst.CLUB_POSITION_2:
                    render.txt_positionInfo.text = "理事可获得";
                    break;
                case CClubConst.CLUB_POSITION_3:
                    render.txt_positionInfo.text = "副会长可获得";
                    break;
                case CClubConst.CLUB_POSITION_4:
                    render.txt_positionInfo.text = "会长可获得";
                    break;
            }

            render.view_rewardList.list_item.renderHandler = new Handler(CItemUtil.getItemRenderFunc(system));
            var rewardList:CRewardListData = CRewardUtil.createByDropPackageID(system.stage, data.rewardId);
            if(rewardList && rewardList.list)
            {
                render.view_rewardList.list_item.dataSource = rewardList.list;
            }
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
