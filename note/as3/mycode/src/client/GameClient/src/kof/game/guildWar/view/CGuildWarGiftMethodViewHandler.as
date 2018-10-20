//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/4/18.
 */
package kof.game.guildWar.view {

import kof.framework.CViewHandler;
import kof.game.guildWar.CGuildWarHelpHandler;
import kof.game.guildWar.CGuildWarNetHandler;
import kof.game.guildWar.data.giftBag.CGiftBagRankData;
import kof.table.GuildWarSpaceTable;
import kof.ui.CMsgAlertHandler;
import kof.ui.CUISystem;
import kof.ui.master.GuildWar.LeagueDistributionBagConItemUI;
import kof.ui.master.GuildWar.LeagueDistributionBagConUI;

import morn.core.components.Component;

import morn.core.components.Dialog;
import morn.core.handlers.Handler;

/**
 * 礼包分配方案界面
 */
public class CGuildWarGiftMethodViewHandler extends CViewHandler {

    private var m_bViewInitialized : Boolean;
    private var m_pViewUI:LeagueDistributionBagConUI;
    private var m_arrData:Array;

    public function CGuildWarGiftMethodViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array
    {
        return [ LeagueDistributionBagConUI];
    }

    override  protected function get additionalAssets() : Array
    {
        return ["GuildWar.swf"];
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
                m_pViewUI = new LeagueDistributionBagConUI();

                m_pViewUI.btn_close.clickHandler = new Handler(_onClickCloseHandler);
                m_pViewUI.btn_cancel.clickHandler = new Handler(_onClickCancelHandler);
                m_pViewUI.btn_confirm.clickHandler = new Handler(_onClickConfirmHandler);

                m_pViewUI.list_gift.renderHandler = new Handler(_renderGiftListHandler);

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
            _updateGiftList();
        }
    }

    private function _updateGiftList():void
    {
        if(m_arrData)
        {
            m_pViewUI.list_gift.dataSource = m_arrData;
        }
        else
        {
            m_pViewUI.list_gift.dataSource = [];
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

    private function _onClickConfirmHandler():void
    {
        var resultArr:Array = [];
        if(m_arrData)
        {
            for each(var giftData:CGiftBagRankData in m_arrData)
            {
                if(giftData)
                {
                    var obj:Object = {};
                    obj.roleID = giftData.roleID;
                    var idStr:String = "";
                    for each(var spaceId:int in giftData.alreadyReceiveRewardBags)
                    {
                        idStr += (spaceId + ",");
                    }

                    obj.rewardBagData = idStr.substring(0, idStr.length-1);

                    resultArr.push(obj);
                }
            }
        }

        if(resultArr.length == 0)
        {
            _uiSystem.showMsgAlert("暂无可分配礼包", CMsgAlertHandler.WARNING);
            return;
        }

        (system.getHandler(CGuildWarNetHandler) as CGuildWarNetHandler).guildWarAllocateRewardBagRequest(resultArr);
    }

    private function _onClickCancelHandler():void
    {
        removeDisplay();
    }

    private function _renderGiftListHandler(item:Component, index:int):void
    {
        var render : LeagueDistributionBagConItemUI = item as LeagueDistributionBagConItemUI;
        var data : CGiftBagRankData = render.dataSource as CGiftBagRankData;
        if ( data )
        {
            render.img_vip.visible = false;
            render.txt_name.text = data.name;
            render.txt_score.text = data.score.toString();
            render.box_gift1.visible = data.alreadyReceiveRewardBags.length >= 1;
            render.box_gift2.visible = data.alreadyReceiveRewardBags.length >= 2;
            render.box_gift3.visible = data.alreadyReceiveRewardBags.length >= 3;

            if(render.box_gift1.visible)
            {
                var table:GuildWarSpaceTable = _helper.getSpaceTableData(data.alreadyReceiveRewardBags[0] as int);
                render.clip_gift1.index = table == null ? 0 : (table.spaceType - 1);
                render.txt_num1.text = "1";
            }

            if(render.box_gift2.visible)
            {
                table = _helper.getSpaceTableData(data.alreadyReceiveRewardBags[1] as int);
                render.clip_gift2.index = table == null ? 0 : (table.spaceType - 1);
                render.txt_num2.text = "1";
            }

            if(render.box_gift3.visible)
            {
                table = _helper.getSpaceTableData(data.alreadyReceiveRewardBags[2] as int);
                render.clip_gift3.index = table == null ? 0 : (table.spaceType - 1);
                render.txt_num3.text = "1";
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

    public function set data(value:Array):void
    {
        m_arrData = value;
    }
}
}
