//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/8/3.
 */
package kof.game.common.view.resultWin {

import QFLib.Foundation.CKeyboard;

import flash.events.TimerEvent;

import flash.ui.Keyboard;
import flash.utils.Timer;

import kof.framework.CViewHandler;
import kof.framework.IDatabase;
import kof.game.instance.CInstanceSystem;
import kof.game.item.CItemData;
import kof.game.item.CItemSystem;
import kof.game.item.view.tips.CItemTipsView;
import kof.game.player.config.CPlayerPath;
import kof.ui.imp_common.RewardItemUI;
import kof.ui.master.JueseAndEqu.RoleItem02UI;

import morn.core.components.Button;

import morn.core.components.Component;

import morn.core.components.Dialog;
import morn.core.handlers.Handler;

/**
 * PVP结算界面
 */
public class CPVPResultViewHandler extends CViewHandler {

    protected var m_bViewInitialized : Boolean;
//    protected var m_pViewUI:ArenaResultWinUI;
    protected var m_pData:CPVPResultData;
    protected var m_pKeyBoard:CKeyboard;
    protected var m_pTimer:Timer;

    public function CPVPResultViewHandler( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array
    {
//        return [ ArenaResultWinUI ];
        return [];
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
//            if ( !m_pViewUI )
//            {
//                m_pViewUI = new ArenaResultWinUI();
//                m_pViewUI.closeHandler = new Handler(_closeHandler);
//                m_pViewUI.list_hero_self.renderHandler = new Handler(_renderHero);
//                m_pViewUI.list_hero_enemy.renderHandler = new Handler(_renderHero);
//                m_pViewUI.list_item.renderHandler = new Handler(_renderItem);
//
//                m_pKeyBoard = new CKeyboard(system.stage.flashStage);
//
//                m_pTimer = new Timer(1000, 30);
//
//                m_bViewInitialized = true;
//            }
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
            invalidate();
            callLater( _addToDisplay );
        }
        else
        {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    protected function _addToDisplay() : void
    {
//        uiCanvas.addPopupDialog( m_pViewUI );

        _initView();
        _addListeners();

        m_pTimer.reset();
        m_pTimer.start();
    }

    protected function _initView():void
    {
    }

    protected function _addListeners():void
    {
        m_pKeyBoard.registerKeyCode(false, Keyboard.J, _onKeyDown);

        m_pTimer.addEventListener(TimerEvent.TIMER,_onTimerHandler);
    }

    protected function _removeListeners():void
    {
        m_pKeyBoard.unregisterKeyCode(false, Keyboard.J, _onKeyDown);

        m_pTimer.removeEventListener(TimerEvent.TIMER,_onTimerHandler);
    }

    public function set data(value:CPVPResultData):void
    {
        m_pData = value;
    }

    override protected function updateDisplay():void
    {
        super.updateDisplay();

//        animation();

        if(m_pData)
        {
            _updateResult();
            _updateSelfAndEnemyInfo();
            _updateRewardInfo();
        }
        else
        {
            clear();
        }
    }

    private function _updateResult():void
    {
        switch (m_pData.result)
        {
            case EPVPResultType.FAIL:
//                m_pViewUI.clip_result.index = 0;
                break;
            case EPVPResultType.WIN:
//                m_pViewUI.clip_result.index = 2;
                break;
            case EPVPResultType.TIE:
//                m_pViewUI.clip_result.index = 1;
                break;
            case EPVPResultType.FULL_WIN:
//                m_pViewUI.clip_result.index = 3;
                break;
        }
    }

    private function _updateSelfAndEnemyInfo():void
    {
//        m_pViewUI.txt_roleName_self.text = m_pData.selfRoleName;
//        m_pViewUI.txt_roleName_enemy.text = m_pData.enemyRoleName;
//        m_pViewUI.list_hero_self.dataSource = m_pData.selfHeroList;
//        m_pViewUI.list_hero_enemy.dataSource = m_pData.enemyHeroList;
//        m_pViewUI.txt_value_self.text = m_pData.selfValue.toString();
//        m_pViewUI.txt_value_enemy.text = m_pData.enemyValue.toString();
//        m_pViewUI.txt_changeValue_self.text = Math.abs(m_pData.selfChangeValue ).toString();
//        m_pViewUI.txt_changeValue_enemy.text = Math.abs(m_pData.enemyChangeValue ).toString();
//        m_pViewUI.img_arrow_self.visible = true;
//        m_pViewUI.img_arrow_enemy.visible = true;
//
//        if(m_pData.selfChangeValue >= 0)
//        {
//            m_pViewUI.img_arrow_self.skin = "png.arena.img_arrow_shangsheng";
//            m_pViewUI.txt_changeValue_self.color = 0x70e324;
//        }
//        else
//        {
//            m_pViewUI.img_arrow_self.skin = "png.arena.img_arrow_xiajiang";
//            m_pViewUI.txt_changeValue_self.color = 0xe8210d;
//        }
//
//        if(m_pData.enemyChangeValue >= 0)
//        {
//            m_pViewUI.img_arrow_enemy.skin = "png.arena.img_arrow_shangsheng";
//            m_pViewUI.txt_changeValue_enemy.color = 0x70e324;
//        }
//        else
//        {
//            m_pViewUI.img_arrow_enemy.skin = "png.arena.img_arrow_xiajiang";
//            m_pViewUI.txt_changeValue_enemy.color = 0xe8210d;
//        }
    }

    private function _updateRewardInfo():void
    {
//        m_pViewUI.list_item.dataSource = m_pData.rewards;
    }

    private function animation():void
    {
//        var timelineLite:TimelineLite = new TimelineLite();
//        TweenLite.fromTo(m_pViewUI.img_role1,0.8,{x:-290},{x:0});
//        TweenLite.fromTo(m_pViewUI.img_role2,0.8,{x:-290},{x:524});
//        TweenLite.fromTo(m_pViewUI.img_role3,0.3,{x:914},{x:183});
//
//        timelineLite.play();
    }

    protected function _onKeyDown(keyCode:uint):void
    {
        switch (keyCode)
        {
            case Keyboard.J:
                _closeHandler();
                break;
        }
    }

    protected function _closeHandler(type:String = null):void
    {
        _removeListeners();

//        if(m_pViewUI && m_pViewUI.parent)
//        {
//            m_pViewUI.close( Dialog.CLOSE );
//        }

        (system.stage.getSystem(CInstanceSystem) as CInstanceSystem).exitInstance();

        m_pTimer.stop();
    }

    private function _onTimerHandler(e:TimerEvent):void
    {
//        var closeBtn:Button = m_pViewUI.getChildByName("close") as Button;
//        if(closeBtn)
//        {
//            var leftSec:int = 30 - m_pTimer.currentCount;
//            closeBtn.label = "确 定(" + leftSec + "s)";
//
//            if(leftSec <= 0)
//            {
//                _closeHandler();
//            }
//        }
    }

    private function _renderHero(item:Component, index:int):void
    {
        if(!(item is RoleItem02UI))
        {
            return;
        }

        var render:RoleItem02UI = item as RoleItem02UI;
        render.mouseChildren = false;
        render.mouseEnabled = true;
        var heroData:CResultHeroInfo = render.dataSource as CResultHeroInfo;
        if(heroData != null)
        {
            render.icon_image.url = CPlayerPath.getUIHeroIconBigPath(heroData.heroId);
        }
        else
        {
            render.icon_image.url = "";
        }

        render.icon_image.mask = render.hero_icon_mask;
        render.star_list.visible = false;
        render.lv_txt.visible = false;
        render.level_frame_img.visible = false;
    }

    private function _renderItem(item:Component, index:int):void
    {
        if(!(item is RewardItemUI))
        {
            return;
        }

        var render:RewardItemUI = item as RewardItemUI;
        render.mouseChildren = false;
        render.mouseEnabled = true;
        var rewardData:CResultRewardInfo = render.dataSource as CResultRewardInfo;

        if(null != rewardData)
        {
            var itemData:CItemData = new CItemData();
            itemData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;
            itemData.updateDataByData(CItemData.createObjectData(rewardData.itemId));
            if(rewardData.itemNum > 1)
            {
                render.num_lable.text = rewardData.itemNum.toString();
            }
            else
            {
                render.num_lable.text = "";
            }

            render.icon_image.url = itemData.iconSmall;
            render.bg_clip.index = itemData.quality;

            render.toolTip = new Handler( _showTips, [render, rewardData.itemId] );
        }
        else
        {
            render.num_lable.text = "";
            render.icon_image.url = "";
            render.toolTip = null;
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

    private function clear():void
    {
//        m_pViewUI.clip_result.index = 0;
//        m_pViewUI.txt_roleName_self.text = "";
//        m_pViewUI.txt_roleName_enemy.text = "";
//        m_pViewUI.txt_changeValue_enemy.text = "";
//        m_pViewUI.txt_changeValue_self.text = "";
//        m_pViewUI.txt_value_enemy.text = "";
//        m_pViewUI.txt_value_self.text = "";
//        m_pViewUI.img_arrow_enemy.visible = true;
//        m_pViewUI.img_arrow_self.visible = true;
//
//        var arr:Array = [];
//        for(var i:int = 0; i < 3; i++)
//        {
//            arr.push({});
//        }
//
//        m_pViewUI.list_hero_enemy.dataSource = arr;
//        m_pViewUI.list_hero_self.dataSource = arr;
//
//        var arr2:Array = [];
//        for(i = 0; i < 4; i++)
//        {
//            arr2.push({});
//        }
//
//        m_pViewUI.list_item.dataSource = arr2;
    }

    override public function dispose():void
    {
        super.dispose();

        m_pData = null;
//        m_pViewUI = null;
        m_pKeyBoard = null;

        m_pTimer.stop();
        m_pTimer = null;
    }
}
}
