//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/8/18.
 */
package kof.game.player.view.playerNew.view.heroDevelop {

import QFLib.Utils.HtmlUtil;

import flash.display.DisplayObjectContainer;
import flash.events.MouseEvent;

import kof.framework.CViewHandler;
import kof.game.bag.CBagEvent;
import kof.game.bag.CBagManager;
import kof.game.bag.CBagSystem;
import kof.game.bag.data.CBagData;
import kof.game.common.CLang;
import kof.game.fightui.compoment.Sector;
import kof.game.item.CItemData;
import kof.game.itemGetPath.CItemGetSystem;
import kof.game.player.CHeroNetHandler;
import kof.game.player.CPlayerHandler;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.event.CPlayerEvent;
import kof.game.player.view.equipmentTrain.CEquTipsView;
import kof.game.player.view.playerNew.util.CPlayerHelpHandler;
import kof.table.PlayerLevelConsume;
import kof.ui.master.jueseNew.render.HeroDevelopItemUI;
import kof.ui.master.jueseNew.view.HeroLevelUpStuffViewUI;
import kof.ui.master.messageprompt.GoodsItemUI;

import morn.core.components.Component;

import morn.core.components.View;
import morn.core.handlers.Handler;

/**
 * 格斗家升级消耗材料部分
 */
public class CHeroLevelUpStuffView extends CViewHandler {

    private var m_pViewUI:HeroLevelUpStuffViewUI;
    private var m_bViewInitialized:Boolean;
    private var m_pData:CPlayerHeroData;
    private var m_pTipsView:CEquTipsView;

    public function CHeroLevelUpStuffView( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    public function initializeView():void
    {
        m_pViewUI.list_item.renderHandler = new Handler(_renderItem);
        m_bViewInitialized = true;
    }

    public function set data(value:*):void
    {
        m_pData = value as CPlayerHeroData;
    }

    public function addDisplay(parent:DisplayObjectContainer, x:int = 0, y:int = 0):void
    {
        if(parent && m_pViewUI)
        {
            parent.addChild(m_pViewUI);
            m_pViewUI.x = x;
            m_pViewUI.y = y;
        }

        _initView();
        _addListeners();
    }

    private function _addListeners():void
    {
//        m_pViewUI.addEventListener(MouseEvent.ROLL_OVER, _onRollOverHandler);
        m_pViewUI.addEventListener(MouseEvent.ROLL_OUT, _onRollOutHandler);
        system.stage.getSystem(CBagSystem).addEventListener(CBagEvent.BAG_UPDATE, _onBagItemsChangeHandler);
        (system as CPlayerSystem).addEventListener(CPlayerEvent.PLAYER_LEVEL_UP,_onPlayerLevelUpHandler);
    }

    private function _removeListeners():void
    {
//        m_pViewUI.removeEventListener(MouseEvent.ROLL_OVER, _onRollOverHandler);
        m_pViewUI.removeEventListener(MouseEvent.ROLL_OUT, _onRollOutHandler);
        system.stage.getSystem(CBagSystem).removeEventListener(CBagEvent.BAG_UPDATE, _onBagItemsChangeHandler);
        (system as CPlayerSystem).removeEventListener(CPlayerEvent.PLAYER_LEVEL_UP,_onPlayerLevelUpHandler);
    }

    private function _initView():void
    {
        if(m_pData && m_pData.hasData)
        {
            // 升下一级消耗
            var itemIdArr:Array = [];
            var nextLevelCostTable:PlayerLevelConsume;
            if ( m_pData.level >= CPlayerHeroData.MAX_LEVEL )//已经到顶级
            {

                nextLevelCostTable = m_pData.getLevelConsume( CPlayerHeroData.MAX_LEVEL );
            }
            else
            {
                nextLevelCostTable = m_pData.nextLevelConsume;
            }

            if(nextLevelCostTable)
            {
                for(var i:int = 1; i <= 6; i++)
                {
                    var itemId : int = nextLevelCostTable["consumItemID" + i];
                    itemIdArr.push(itemId);
                }
            }

            m_pViewUI.list_item.dataSource = itemIdArr;
        }
    }

    public function removeDisplay():void
    {
        if(m_bViewInitialized)
        {
            _removeListeners();
//            clear();

            if(isViewShow)
            {
                m_pViewUI.parent.removeChild(m_pViewUI);
            }
        }
    }

    private function _onRollOverHandler(e:MouseEvent):void
    {
        addDisplay(_heroDevelopPart.view,0,354-10);
    }

    private function _onRollOutHandler(e:MouseEvent):void
    {
        removeDisplay();
    }

    private function _onItemRollOverHandler(e:MouseEvent):void
    {
        var render:HeroDevelopItemUI = e.currentTarget as HeroDevelopItemUI;
        if(render)
        {
            var itemNum:int = int(render.txt_num.text);
            var itemId:int = render.dataSource as int;
            if(itemId && itemNum)
            {
                var itemData:Object = {};
                itemData["itemNum"] = itemNum;
                itemData["itemId"] = itemId;
                system.getHandler(CHeroDevelopPart ).dispatchEvent(new CPlayerEvent(CPlayerEvent.SHOW_ADD_PROGRESS, itemData));
            }
        }
    }

    private function _onItemRollOutHandler(e:MouseEvent):void
    {
        var render:HeroDevelopItemUI = e.currentTarget as HeroDevelopItemUI;
        if(render)
        {
            system.getHandler(CHeroDevelopPart ).dispatchEvent(new CPlayerEvent(CPlayerEvent.SHOW_ADD_PROGRESS, null));
        }
    }

    private function _renderItem(item:Component, index:int):void
    {
        if(!(item is HeroDevelopItemUI))
        {
            return;
        }

        var render:HeroDevelopItemUI = item as HeroDevelopItemUI;
        render.mouseEnabled = true;
        var itemId:int = render.dataSource as int;
        if(itemId)
        {
            var itemData : CItemData = _playerHelper.getItemData( itemId ); // 消耗物品
            var bagData : CBagData = _bagManager.getBagItemByUid( itemId ); // item1, 当前拥有
            var itemNum : int = bagData == null ? 0 : bagData.num;

            render.clip_bg.index = itemData.quality;
            render.img_item.url = itemData.iconSmall;
            render.txt_num.isHtml = true;

            var playerLevel:int = (system as CPlayerSystem).playerData.teamData.level;
            if (itemData.teamLevel > playerLevel)// 战队等级不足
            {
                render.txt_num.text = "<font color = '#ff0000'>" + itemData.teamLevel + CLang.Get( "player_exp_open" ) + "</font>";
                render.img_black.visible = true;
                render.link_get.visible = false;
            }
            else
            {
                if(itemNum > 0)
                {
                    render.txt_num.text = itemNum.toString();
                    render.img_black.visible = false;
                    render.link_get.visible = false;

                    render.addEventListener(MouseEvent.ROLL_OVER, _onItemRollOverHandler);
                    render.addEventListener(MouseEvent.ROLL_OUT, _onItemRollOutHandler);
                }
                else
                {
                    render.txt_num.text = "";
                    render.img_black.visible = true;
                    render.link_get.visible = true;
                    render.link_get.clickHandler = new Handler(_onOpenItemGetWay, [itemId]);
                }
            }

            if(!render.img_black.visible)
            {
                render.addEventListener(MouseEvent.MOUSE_DOWN,_onMouseDownHandler);
            }

            render.clip_eff.visible = itemData.effect;

            // CD
            var sector:Sector = new Sector();
            sector.name = 'sector';
            sector.visible = false;
            sector.alpha = 0.7;
            sector.scaleX = -1;
            sector.x = 31;
            sector.y = 4;
            render.addChild(sector);

            render.img_cd.visible = true;
            var completePercent:Number = 0 / 100;
            sector.init(0, 0, 49, -90,  completePercent * 360  ,0.5);
//        sector.init(0, 0, 49, -90, (1 - completePercent) * PERFECTNUM  ,0.5);
            render.img_cd.mask = sector;

            var goodsItem : GoodsItemUI = new GoodsItemUI();
            goodsItem.img.url = itemData.iconBig;
            goodsItem.quality_clip.index = render.clip_bg.index;
            goodsItem.txt.text = render.txt_num.text;
            render.toolTip = new Handler( _showQualityTips, [ goodsItem, itemId ] );
        }
        else
        {
            render.img_black.visible = false;
            render.img_item.url = "";
            render.txt_num.text = "";
            render.link_get.visible = false;
            render.img_cd.visible = false;
            render.clip_eff.visible = false;
        }
    }

    private function _onMouseDownHandler(e:MouseEvent):void
    {
        var render:HeroDevelopItemUI = e.target as HeroDevelopItemUI;
        if(render)
        {
            render.removeEventListener(MouseEvent.MOUSE_DOWN,_onMouseDownHandler);

            var itemList:Array = [];
            var obj:Object = {};
            obj.itemID = render.dataSource as int;
            obj.num = 1;
            itemList.push(obj);
            _heroNetHandler.sendHeroLevelUp(m_pData.prototypeID, itemList);
        }
    }

    /**
     * 背包物品更新
     * @param e
     */
    private function _onBagItemsChangeHandler(e:CBagEvent):void
    {
        m_pViewUI.list_item.refresh();
    }

    /**
     * 战队升级
     * @param e
     */
    private function _onPlayerLevelUpHandler(e:CPlayerEvent):void
    {
        m_pViewUI.list_item.refresh();
    }

    /**
     * 物品获得途径
     */
    private function _onOpenItemGetWay(itemId:int):void
    {
        (system.stage.getSystem(CItemGetSystem) as CItemGetSystem).showItemGetPath(itemId);
    }

    private function _showQualityTips(item : GoodsItemUI, itemID : int) : void
    {
        _tipsView.showEquiMaterialTips(item, _playerHelper.getItemTableData(itemID), _playerHelper.getItemData(itemID));
    }

    public function set view(value:View):void
    {
        m_pViewUI = value as HeroLevelUpStuffViewUI;
    }

    public function get isViewShow():Boolean
    {
        return m_pViewUI && m_pViewUI.parent;
    }

    protected function get _playerHelper():CPlayerHelpHandler
    {
        return system.getHandler(CPlayerHelpHandler) as CPlayerHelpHandler;
    }

    private function get _bagManager():CBagManager
    {
        return system.stage.getSystem(CBagSystem).getHandler(CBagManager) as CBagManager;
    }

    private function get _tipsView():CEquTipsView
    {
        if(m_pTipsView == null)
        {
            m_pTipsView = new CEquTipsView();
        }

        return m_pTipsView;
    }

    private function get _heroDevelopPart():CHeroDevelopPart
    {
        return system.getHandler(CHeroDevelopPart) as CHeroDevelopPart;
    }

    private function get _heroNetHandler():CHeroNetHandler
    {
        return system.getHandler(CHeroNetHandler) as CHeroNetHandler;
    }
}
}
