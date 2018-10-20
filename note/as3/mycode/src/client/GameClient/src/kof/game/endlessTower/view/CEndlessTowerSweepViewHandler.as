//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/12/19.
 */
package kof.game.endlessTower.view {

import com.greensock.TweenMax;
import com.greensock.easing.Back;

import kof.framework.CViewHandler;
import kof.game.common.CItemUtil;
import kof.game.common.CUIFactory;
import kof.game.endlessTower.CEndlessTowerNetHandler;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardData;
import kof.game.item.view.tips.CItemTipsView;
import kof.game.playerCard.util.CTransformSpr;
import kof.ui.imp_common.EffectItem2UI;
import kof.ui.master.endlessTower.EndlessTowerSweepUI;

import morn.core.components.Component;

import morn.core.components.Dialog;

import morn.core.handlers.Handler;

public class CEndlessTowerSweepViewHandler extends CViewHandler
{
    private var m_bViewInitialized : Boolean;

    private var m_pViewUI : EndlessTowerSweepUI;
    private var m_pTransromSpr:CTransformSpr;
    private var m_pData:*;
    private var m_iCurrLayer:int;

    public function CEndlessTowerSweepViewHandler( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array
    {
        return [EndlessTowerSweepUI];
    }

    override protected function get additionalAssets() : Array
    {
        return ["frameclip_starAdvance.swf"];
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
                m_pViewUI = new EndlessTowerSweepUI();
                m_pViewUI.list_item.renderHandler = new Handler(_renderItem);
                m_pViewUI.btn_again.clickHandler = new Handler(_onClickAgainHandler);
                m_pViewUI.btn_confirm.clickHandler = new Handler(_onClickConfirmHandler);

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
        if(!m_pViewUI.parent)
        {
            uiCanvas.addPopupDialog( m_pViewUI );
        }

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
//        _clear();

        var dataArr:Array = m_pData as Array;

        if(dataArr)
        {
            m_pViewUI.list_item.dataSource = dataArr;

            var repeatX:int = m_pViewUI.list_item.repeatX;
            var listWidth:int = (52 + repeatX) * dataArr.length - repeatX;
            m_pViewUI.list_item.x = m_pViewUI.width - listWidth >> 1;

//            _playItemEffect();
        }

        if(m_pTransromSpr && TweenMax.isTweening(m_pTransromSpr))
        {
            TweenMax.killTweensOf(m_pTransromSpr);
        }

        if(m_pTransromSpr == null)
        {
            m_pTransromSpr = CUIFactory.getDisplayObj(CTransformSpr) as CTransformSpr;
        }

        m_pViewUI.img_sweepSucc.x = 125;
        m_pViewUI.img_sweepSucc.y = 187;

        m_pTransromSpr.objWidth = 141;
        m_pTransromSpr.objHeight = 35;
        m_pTransromSpr.transformObj = m_pViewUI.img_sweepSucc;
        m_pViewUI.addChild(m_pTransromSpr);

        TweenMax.fromTo(m_pTransromSpr, 0.2, {scale:4}, {scale:1, ease:Back.easeOut});
    }

    private function _playItemEffect():void
    {
        var dataArr:Array = m_pData as Array;
        var len:int = dataArr == null ? 0 : dataArr.length;
        for(var i:int = 0; i < len; i++)
        {
            var item:EffectItem2UI = m_pViewUI.list_item.getCell(i) as EffectItem2UI;
            if(item)
            {
                item.visible = false;
                _showRewardItem(item, 0.2 * i);
            }
        }
    }

    private function _showRewardItem(item:EffectItem2UI,delay:Number):void
    {
        if(item)
        {
            delayCall(delay,_onDelay);
            function _onDelay():void
            {
                item.visible = true;
                item.effct_item.visible = true;
                item.effct_item.mouseEnabled = false;
                item.effct_item.interval = 10;
                item.effct_item.playFromTo(null,null,new Handler(_onPlayEnd));
            }

            function _onPlayEnd():void
            {
                item.effct_item.visible = false;
                item.effct_item.mouseEnabled = false;
            }
        }
    }

    private function _onClickAgainHandler():void
    {
        if(m_iCurrLayer)
        {
            (system.getHandler(CEndlessTowerNetHandler) as CEndlessTowerNetHandler).endlessTowerSweepRequest(m_iCurrLayer, 1);
        }
    }

    private function _onClickConfirmHandler():void
    {
        removeDisplay();
    }

    public function removeDisplay() : void
    {
        if(m_bViewInitialized)
        {
            _removeListeners();

            if (m_pViewUI && m_pViewUI.parent)
            {
                m_pViewUI.close(Dialog.CLOSE);
            }

            if(m_pTransromSpr && TweenMax.isTweening(m_pTransromSpr))
            {
                TweenMax.killTweensOf(m_pTransromSpr);
            }

            m_pTransromSpr.dispose();
            m_pTransromSpr = null;

            m_pData = null;
        }
    }

    private function _renderItem(item:Component, index:int):void
    {
        if(!(item is EffectItem2UI))
        {
            return;
        }

        var render:EffectItem2UI = item as EffectItem2UI;
        render.mouseChildren = false;
        render.mouseEnabled = true;
        var rewardData:CRewardData = render.dataSource as CRewardData;

        if(null != rewardData)
        {
            if(rewardData.num > 1)
            {
                render.txt_num.text = rewardData.num.toString();
            }
            else
            {
                render.txt_num.text = "";
            }

            render.img_icon.url = rewardData.iconSmall;
            render.clip_bg.index = rewardData.quality;
            render.effct_item.visible = false;

            render.toolTip = new Handler( _showTips, [render, rewardData.ID] );
        }
        else
        {
            render.txt_num.text = "";
            render.img_icon.url = "";
            render.toolTip = null;
            render.effct_item.visible = false;
        }
    }

    /**
     * 物品tips
     * @param item
     */
    private function _showTips(item:Component,itemId:int):void
    {
        (system.stage.getSystem(CItemSystem) as CItemSystem).addTips(CItemTipsView,item,[itemId]);
    }

    private function _clear():void
    {
        m_pViewUI.list_item.dataSource = [];
        m_pViewUI.list_item.visible = false;
    }

    public function set data(value:*):void
    {
        m_pData = value;
    }

    public function set currLayer(value:int):void
    {
        m_iCurrLayer = value;
    }

    public function get isViewShow():Boolean
    {
        return m_pViewUI && m_pViewUI.parent;
    }
}
}
