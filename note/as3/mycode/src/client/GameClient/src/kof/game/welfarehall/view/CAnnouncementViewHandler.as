//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/9/25.
 */
package kof.game.welfarehall.view {

import flash.events.Event;
import flash.geom.Point;

import kof.framework.IDatabase;

import kof.game.common.CFlyItemUtil;
import kof.game.common.CLang;
import kof.game.item.CItemData;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardData;
import kof.game.item.view.tips.CItemTipsView;

import kof.game.welfarehall.CWelfareHallEvent;
import kof.game.welfarehall.CWelfareHallHandler;
import kof.game.welfarehall.CWelfareHallManager;
import kof.game.welfarehall.data.CAnnouncementData;
import kof.ui.CMsgAlertHandler;
import kof.ui.CUISystem;
import kof.ui.imp_common.RewardItemUI;
import kof.ui.master.welfareHall.UpdateNoticeUI;
import kof.ui.master.welfareHall.WelfareHallUI;

import morn.core.components.Component;

import morn.core.handlers.Handler;

/**
 * 更新公告
 */
public class CAnnouncementViewHandler extends CWelfarePanelBase {

    private var m_pViewUI : UpdateNoticeUI;
    private var m_bViewInitialized : Boolean;

    public function CAnnouncementViewHandler( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override protected function onSetup() : Boolean
    {
        var ret : Boolean = super.onSetup();
        _reqInfo();

        return ret;
    }

    override public function get viewClass() : Array
    {
        return [UpdateNoticeUI];
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
                m_pViewUI = new UpdateNoticeUI();

                m_pViewUI.list_reward.renderHandler = new Handler(_renderItem);

                m_pViewUI.btn_get.clickHandler = new Handler(_onTakeRewardHandler);

                m_bViewInitialized = true;
            }
        }

        return m_bViewInitialized;
    }

    override public function addDisplay() : void
    {
        this.loadAssetsByView(viewClass, _showDisplay);
    }

    protected function _showDisplay() : void
    {
        if ( onInitializeView() )
        {
            _addToDisplay();
        }
        else
        {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    private function _addToDisplay() : void
    {
        if(m_pViewUI)
        {
            _mainUI.ctn.addChild(m_pViewUI);
        }

        _initView();
        _addListeners();
        _reqInfo();
    }

    private function _initView():void
    {
        updateDisplay();
    }

    private function _addListeners():void
    {
        system.addEventListener(CWelfareHallEvent.TAKE_REWARD_SUCC, _onTakeRewardSuccHandler);
        system.addEventListener(CWelfareHallEvent.ANNOUNCEMENT_UPDATE, _onAnnouncementUpdateHandler);
    }

    private function _removeListeners():void
    {
        system.removeEventListener(CWelfareHallEvent.TAKE_REWARD_SUCC, _onTakeRewardSuccHandler);
        system.removeEventListener(CWelfareHallEvent.ANNOUNCEMENT_UPDATE, _onAnnouncementUpdateHandler);
    }

    private function _reqInfo():void
    {
        if(_announcementData == null)
        {
            _welfareHallHandler.announcementListRequest();
        }
    }

    override protected function updateDisplay():void
    {
        if(_announcementData)
        {
            _updateImg();
            _updateRewardList();
            _updateBtnState();
            _updateDescAndContent();
        }
        else
        {
            clear();
        }
    }

    private function _updateImg():void
    {

    }

    private function _updateRewardList():void
    {
        var rewardList:Array = _announcementData.rewards;
        m_pViewUI.list_reward.dataSource = rewardList;
    }

    private function _updateBtnState():void
    {
        var announcementData:CAnnouncementData = _announcementData;
        var arr:Array = m_pViewUI.list_reward.dataSource as Array;
        var len:int = arr == null ? 0 : arr.length;

        m_pViewUI.btn_get.disabled = announcementData.rewardState == 1 || len == 0;
        m_pViewUI.btn_get.visible = announcementData.rewardState == 0 && len != 0;
        m_pViewUI.btn_hasTake.visible = announcementData.rewardState == 1 && len != 0;
        m_pViewUI.btn_hasTake.mouseEnabled = false;
    }

    private function _updateDescAndContent():void
    {
        m_pViewUI.txt_desc.text = _announcementData.title;
        m_pViewUI.txt_content.text = _announcementData.content;
    }

    override public function removeDisplay():void
    {
        if(m_bViewInitialized)
        {
            _removeListeners();
            m_pViewUI.remove();
        }
    }

    private function _onAnnouncementUpdateHandler(e:CWelfareHallEvent):void
    {
        updateDisplay();
    }

    private function _onTakeRewardHandler():void
    {
        if(CAnnouncementState.isInTakeReward)
        {
            (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert(CLang.Get("clientLockTips"),CMsgAlertHandler.WARNING);
            return;
        }

        if(_announcementData)
        {
            _welfareHallHandler.getUpdateRewardRequest(_announcementData.id);
        }
    }

    private function _onTakeRewardSuccHandler(e:Event):void
    {
        _updateBtnState();
        _flyItem();
    }

    private function _flyItem():void
    {
        var len:int = m_pViewUI.list_reward.dataSource.length;
        for(var i:int = 0; i < len; i++)
        {
            var item:Component = m_pViewUI.list_reward.getCell(i) as Component;
            CFlyItemUtil.flyItemToBag(item, item.localToGlobal(new Point()), system);
        }
    }

    private function _renderItem( item:Component, index:int):void
    {
        if(!(item is RewardItemUI))
        {
            return;
        }

        var rewardItem:RewardItemUI = item as RewardItemUI;
        rewardItem.mouseChildren = true;
        rewardItem.mouseEnabled = true;
        var data:Object = rewardItem.dataSource;
        if(null != data)
        {
            if(data.num > 1)
            {
                rewardItem.num_lable.text = data.num.toString();
            }
            else
            {
                rewardItem.num_lable.text = "";
            }


            var itemData:CItemData = _getItemData(data.ID);
            if(itemData)
            {
                rewardItem.icon_image.url = itemData.iconSmall;
                rewardItem.bg_clip.index = itemData.quality;
            }

            rewardItem.toolTip = new Handler( _showTips, [rewardItem, data.ID] );
        }
        else
        {
            rewardItem.num_lable.text = "";
            rewardItem.icon_image.url = "";
        }
    }

    /**
     * 物品tips
     * @param item
     */
    private function _showTips(item:RewardItemUI, itemId:int):void
    {
        (system.stage.getSystem(CItemSystem) as CItemSystem).addTips(CItemTipsView,item,[itemId]);
    }

    private function _getItemData(itemId:int):CItemData
    {
        var itemData:CItemData = new CItemData();
        itemData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;
        itemData.updateDataByData(CItemData.createObjectData(itemId));
        return itemData;
    }

    private function clear():void
    {
        m_pViewUI.list_reward.dataSource = [];
        m_pViewUI.btn_get.disabled = true;
        m_pViewUI.txt_desc.text = "";
        m_pViewUI.txt_content.text = "";
        m_pViewUI.btn_get.visible = false;
        m_pViewUI.btn_hasTake.visible = false;
    }


    private function get _mainUI():WelfareHallUI
    {
        return (system.getBean( CWelfareHallViewHandler ) as CWelfareHallViewHandler).welfareHallUI;
    }

    private function get _welfareHallHandler():CWelfareHallHandler
    {
        return system.getBean( CWelfareHallHandler ) as CWelfareHallHandler;
    }

    private function get _welfareManager():CWelfareHallManager
    {
        return system.getHandler( CWelfareHallManager ) as CWelfareHallManager;
    }

    private function get _uiSystem():CUISystem
    {
        return system.stage.getSystem( CUISystem ) as CUISystem;
    }

    private function get _announcementData():CAnnouncementData
    {
        var listData:Vector.<CAnnouncementData> = _welfareManager.announcementListData;
        if(listData && listData.length)
        {
            return listData[0];
        }

        return null;
    }
}
}
