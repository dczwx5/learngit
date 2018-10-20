//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/7/13.
 */
package kof.game.equipCard.view {

import flash.events.Event;

import kof.framework.CViewHandler;
import kof.game.bag.CBagEvent;
import kof.game.bag.CBagSystem;
import kof.game.equipCard.util.CEquipCardUtil;
import kof.game.item.CItemData;
import kof.game.item.CItemSystem;
import kof.game.item.view.tips.CItemTipsView;
import kof.game.playerCard.util.ECardPoolTabType;
import kof.ui.imp_common.ItemUIUI;
import kof.ui.master.equipCard.EquipCardPoolViewUI;

import morn.core.components.Component;

import morn.core.components.Dialog;

import morn.core.components.List;
import morn.core.handlers.Handler;

public class CEquipCardPoolViewHandler extends CViewHandler {

    private var m_pViewUI : EquipCardPoolViewUI;
    private var m_bViewInitialized : Boolean;

    /** 卡池类型 */
    private var m_iCardPoolType:int;

    private var m_pCurrList:List;

    public function CEquipCardPoolViewHandler( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array
    {
        return [EquipCardPoolViewUI];
    }

    override protected function get additionalAssets():Array
    {
        return ["frameclip_item2.swf"];
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
                m_pViewUI = new EquipCardPoolViewUI();

                m_pViewUI.closeHandler = new Handler( _onClose );
                m_pViewUI.list_item.renderHandler = new Handler( _renderCommonItem );

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

    private function _onClose( type : String ) : void
    {
        switch ( type )
        {
            default:
                if (m_pViewUI && m_pViewUI.parent)
                {
                    m_pViewUI.close(Dialog.CLOSE);

                    _removeListeners();
                }
                break;
        }
    }

    private function _initView():void
    {
//        m_pViewUI.list_hero.visible = true;
        m_pViewUI.list_item.visible = true;
        m_pViewUI.tab.selectedIndex = 0;
        m_pCurrList = m_pViewUI.list_item;

        updateDisplay();
    }

    private function _addListeners():void
    {
        m_pViewUI.tab.addEventListener( Event.CHANGE, _onTabSelectedHandler);

        if(system.stage.getSystem(CBagSystem))
        {
            (system.stage.getSystem(CBagSystem) as CBagSystem).addEventListener(CBagEvent.BAG_UPDATE,_onBagItemsChangeHandler);
        }
    }

    private function _removeListeners():void
    {
        m_pViewUI.tab.removeEventListener( Event.CHANGE, _onTabSelectedHandler);

        if(system.stage.getSystem(CBagSystem))
        {
            (system.stage.getSystem(CBagSystem) as CBagSystem).removeEventListener(CBagEvent.BAG_UPDATE,_onBagItemsChangeHandler);
        }
    }

    override protected function updateDisplay():void
    {
        _updateItemList();
    }

    private function _updateItemList():void
    {
        var itemArr:Array = CEquipCardUtil.getCardPoolItems(m_iCardPoolType,m_pViewUI.tab.selectedIndex);
        m_pCurrList.dataSource = itemArr;
    }

    /**
     * 切换页签处理
     * @param e
     */
    private function _onTabSelectedHandler(e:Event = null) : void
    {
        if(m_pViewUI.tab.selectedIndex == 0)
        {
            m_pViewUI.list_item.visible = true;
//            m_pViewUI.list_hero.visible = false;
            m_pCurrList = m_pViewUI.list_item;
        }

//        if(m_pViewUI.tab.selectedIndex == ECardPoolTabType.Type_Hero)
//        {
//            m_pViewUI.list_hero.visible = true;
//            m_pViewUI.list_item.visible = false;
//            m_pCurrList = m_pViewUI.list_hero;
//        }

        updateDisplay()
    }

    /**
     * 背包物品更新
     * @param e
     */
    protected function _onBagItemsChangeHandler(e:CBagEvent):void
    {
        if( e.type == CBagEvent.BAG_UPDATE)
        {
            _updateItemList();
            if(m_pCurrList)
            {
                m_pCurrList.refresh();
            }
        }
    }

    private function _renderCommonItem( item:Component, index:int):void
    {
        if(!(item is ItemUIUI))
        {
            return;
        }

        var commonItem:ItemUIUI = item as ItemUIUI;
        commonItem.mouseChildren = false;
        commonItem.mouseEnabled = true;
        var itemData:CItemData = commonItem.dataSource as CItemData;
        if(null != itemData)
        {
//            if(itemData.num > 1)
//            {
//                commonItem.num_lable.text = itemData.num.toString();
//            }

            commonItem.img.url = itemData.iconBig;
            commonItem.clip_bg.index = itemData.quality;
            commonItem.txt_num.text = "";
            commonItem.box_effect.visible = itemData.effect;
        }
        else
        {
            commonItem.txt_num.text = "";
            commonItem.img.url = "";
            commonItem.box_effect.visible = false;
        }

        commonItem.toolTip = new Handler( _showTips, [commonItem] );
    }

    /**
     * 物品tips
     * @param item
     */
    private function _showTips(item:ItemUIUI):void
    {
        (system.stage.getSystem(CItemSystem) as CItemSystem).addTips(CItemTipsView,item);
    }

    /*
    private function _renderHeroItem(item:Component, index:int):void
    {
        if(!(item is PlayerCardHeroRenderUI))
        {
            return;
        }

        var heroItem:PlayerCardHeroRenderUI = item as PlayerCardHeroRenderUI;
        heroItem.mouseChildren = false;
        heroItem.mouseEnabled = true;
        var itemData:CItemData = heroItem.dataSource as CItemData;
        if(null != itemData)
        {
            heroItem.item.img.url = itemData.iconBig;
            heroItem.item.clip_bg.index = itemData.quality;
            heroItem.item.txt_num.text = "";

            if(CPlayerCardUtil.isHeroCardItem(itemData.ID))
            {
                var cardInfo:Object = CPlayerCardUtil.getHeroCardInfo(itemData.ID);
                var heroData:CPlayerHeroData = CPlayerCardUtil.getHeroDataById(cardInfo.roleId);

                heroItem.aptitude_lock_cliip.index = heroData == null ? 0 : heroData.qualityBaseType;
                heroItem.aptitude_lock_cliip.visible = true;
                heroItem.list_star.dataSource = new Array(cardInfo.star);
            }
            else
            {
                heroItem.aptitude_lock_cliip.visible = false;
                heroItem.list_star.dataSource = [];
            }
        }
        else
        {
            heroItem.item.img.url = "";
            heroItem.item.txt_num.text = "";
            heroItem.item.clip_bg.index = 0;
            heroItem.aptitude_lock_cliip.visible = false;
            heroItem.list_star.dataSource = [];
        }
    }
    */

    public function set cardPoolType(value:int):void
    {
        m_iCardPoolType = value;
    }

    override public function dispose():void
    {
    }
}
}
