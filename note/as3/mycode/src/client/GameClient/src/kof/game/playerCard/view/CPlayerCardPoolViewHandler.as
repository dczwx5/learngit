//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/6/12.
 */
package kof.game.playerCard.view {

import flash.events.Event;

import kof.framework.CViewHandler;
import kof.game.common.CDisplayUtil;
import kof.game.common.CItemUtil;
import kof.game.item.CItemData;
import kof.game.item.CItemSystem;
import kof.game.item.view.tips.CItemTipsView;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.enum.EHeroIntelligence;
import kof.game.playerCard.CPlayerCardNetHandler;
import kof.game.playerCard.event.CPlayerCardEvent;
import kof.game.playerCard.util.CPlayerCardUtil;
import kof.game.playerCard.util.ECardPoolType;
import kof.ui.imp_common.ItemUIUI;
import kof.ui.master.playerCard.PlayerCardHeroRenderUI;
import kof.ui.master.playerCard.PlayerCardPoolViewUI;

import morn.core.components.Box;

import morn.core.components.Component;
import morn.core.components.Dialog;
import morn.core.components.List;

import morn.core.handlers.Handler;

/**
 * 卡池
 */
public class CPlayerCardPoolViewHandler extends CViewHandler {

    private var m_pViewUI : PlayerCardPoolViewUI;
    private var m_bViewInitialized : Boolean;

    /** 卡池类型 */
    private var m_iCardPoolType:int;
    /** 卡池子类型 */
    private var m_iCardSubPoolType:int;

//    private var m_pCurrList:List;
    private var m_pList:Array;
    private var m_pBox:Array;

    public function CPlayerCardPoolViewHandler( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array
    {
        return [PlayerCardPoolViewUI];
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
                m_pViewUI = new PlayerCardPoolViewUI();

                m_pViewUI.closeHandler = new Handler( _onClose );
//                m_pViewUI.list_item.renderHandler = new Handler( _renderCommonItem );
//                m_pViewUI.list_hero.renderHandler = new Handler( _renderHeroItem );

                if(m_pList == null)
                {
                    m_pList = [];
                }

                if(m_pBox == null)
                {
                    m_pBox = [];
                }

                m_pList[0] = m_pViewUI.list_ss;
                m_pList[1] = m_pViewUI.list_s;
                m_pList[2] = m_pViewUI.list_a;
                m_pList[3] = m_pViewUI.list_b;
                m_pList[4] = m_pViewUI.list_c;
                m_pList[5] = m_pViewUI.list_other;

                m_pBox[0] = m_pViewUI.box_ss;
                m_pBox[1] = m_pViewUI.box_s;
                m_pBox[2] = m_pViewUI.box_a;
                m_pBox[3] = m_pViewUI.box_b;
                m_pBox[4] = m_pViewUI.box_c;
                m_pBox[5] = m_pViewUI.box_other;

                m_pViewUI.list_ss.renderHandler = new Handler(_renderHeroItem);
                m_pViewUI.list_s.renderHandler = new Handler(_renderHeroItem);
                m_pViewUI.list_a.renderHandler = new Handler(_renderHeroItem);
                m_pViewUI.list_b.renderHandler = new Handler(_renderHeroItem);
                m_pViewUI.list_c.renderHandler = new Handler(_renderHeroItem);
                m_pViewUI.list_other.renderHandler = new Handler(_renderCommonItem);

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
                }
                break;
        }

        _removeListeners();

        m_iCardSubPoolType = 0;
    }

    private function _initView():void
    {
//        m_pViewUI.list_hero.visible = true;
//        m_pViewUI.list_item.visible = false;
        m_pViewUI.tab.selectedIndex = 0;
//        m_pCurrList = m_pViewUI.list_hero;

        m_pViewUI.panel.vScrollBar.value = 0;

        m_pViewUI.img_expect_s.visible = false;
        m_pViewUI.img_expect_ss.visible = false;

        if(m_iCardPoolType == ECardPoolType.Type_Better)
        {
            m_pViewUI.panel.visible = false;
            (system.getHandler(CPlayerCardNetHandler) as CPlayerCardNetHandler).cardPlayerSubPoolRequest();
        }
        else
        {
            updateDisplay();
        }
    }

    private function _addListeners():void
    {
        system.addEventListener(CPlayerCardEvent.SubPoolInfo, _onSubPoolInfoHandler);
    }

    private function _removeListeners():void
    {
        system.removeEventListener(CPlayerCardEvent.SubPoolInfo, _onSubPoolInfoHandler);
    }

    override protected function updateDisplay():void
    {
        _updateItemList();
    }

    private function _updateItemList():void
    {
        var itemArr:Array = CPlayerCardUtil.getCardPoolItems2(m_iCardPoolType, m_iCardSubPoolType);
        var count:int = 0;
        var posY:int = 19;

        for(var i:int = 0; i < itemArr.length; i++)
        {
            var dataArr:Array = itemArr[i];
            var repeatY:int = Math.ceil(dataArr.length / 6);
            (m_pList[i] as List).repeatY = repeatY;
            (m_pList[i] as List).dataSource = dataArr;
            var spaceY:int = (m_pList[i] as List).spaceY;

            if(i == 0)
            {
//                m_pViewUI.img_expect_ss.visible = dataArr.length == 0;
            }

            if(i == 1)
            {
//                m_pViewUI.img_expect_s.visible = dataArr.length == 0;
            }

            if(dataArr.length)
            {
                m_pBox[i].visible = true;
                m_pBox[i].x = 29;
                m_pBox[i].y = posY;
                count++;
                posY += (80 * repeatY + spaceY * (repeatY-1) + 15);
            }
            else
            {
                m_pBox[i].visible = false;
            }
        }

        m_pViewUI.panel.refresh();
    }

    /**
     * 切换页签处理
     * @param e
     */
    private function _onTabSelectedHandler(e:Event = null) : void
    {
//        if(m_pViewUI.tab.selectedIndex == ECardPoolTabType.Type_Item)
//        {
//            m_pViewUI.list_item.visible = true;
//            m_pViewUI.list_hero.visible = false;
//            m_pCurrList = m_pViewUI.list_item;
//        }
//
//        if(m_pViewUI.tab.selectedIndex == ECardPoolTabType.Type_Hero)
//        {
//            m_pViewUI.list_hero.visible = true;
//            m_pViewUI.list_item.visible = false;
//            m_pCurrList = m_pViewUI.list_hero;
//        }

        updateDisplay();
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

//            if(CPlayerCardUtil.isHeroCardItem(itemData.ID))
//            {
            if(CItemUtil.isHeroItem(itemData))
            {
                var cardInfo:Object = CPlayerCardUtil.getHeroCardInfo(itemData.ID);
                var heroData:CPlayerHeroData = CPlayerCardUtil.getHeroDataById(cardInfo.roleId);

                heroItem.aptitude_lock_cliip.index = heroData == null ? 0 : heroData.qualityBaseType;
                heroItem.aptitude_lock_cliip.visible = true;
                heroItem.list_star.dataSource = new Array(cardInfo.star);

                var heroData2 : CPlayerHeroData = (system.stage.getSystem( CPlayerSystem ) as CPlayerSystem).playerData.heroList.createHero(cardInfo.roleId);
                if(heroData2)
                {
                    heroData2.updateDataByData( {star : cardInfo.star} );
                }

                if(heroData.qualityBase <= EHeroIntelligence.BPlus)
                {
                    heroItem.item.clip_effect.autoPlay = false;
                    heroItem.item.clip_effect.visible = false;
                }
                else
                {
                    heroItem.item.clip_effect.visible = true;
                    heroItem.item.clip_effect.autoPlay = true;
                }

                heroItem.toolTip = new Handler( _showHeroTips, [ heroItem, heroData2 ] );
            }
            else
            {
                heroItem.aptitude_lock_cliip.visible = false;
                heroItem.list_star.dataSource = [];
                heroItem.toolTip = new Handler( _showItemTips, [ heroItem ] );
            }

            heroItem.item.box_effect.visible = itemData.effect;
        }
        else
        {
            heroItem.item.img.url = "";
            heroItem.item.txt_num.text = "";
            heroItem.item.clip_bg.index = 0;
            heroItem.aptitude_lock_cliip.visible = false;
            heroItem.list_star.dataSource = [];
            heroItem.item.box_effect.visible = false;
            heroItem.toolTip = null;
        }
    }

    private function _showHeroTips(item:PlayerCardHeroRenderUI, heroData:CPlayerHeroData) : void
    {
        (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).showHeroTips(heroData, item);
    }

    private function _showItemTips(item:PlayerCardHeroRenderUI) : void
    {
        (system.stage.getSystem(CItemSystem) as CItemSystem).addTips(CItemTipsView, item);
    }

    private function _onSubPoolInfoHandler(e:CPlayerCardEvent):void
    {
        var subPoolId:int = e.data as int;
        m_iCardSubPoolType = subPoolId;

        m_pViewUI.panel.visible = true;
        _updateItemList();
    }

    public function set cardPoolType(value:int):void
    {
        m_iCardPoolType = value;
    }

    override public function dispose():void
    {
    }
}
}
