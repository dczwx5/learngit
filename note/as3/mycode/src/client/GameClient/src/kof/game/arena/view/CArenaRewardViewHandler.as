//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/7/18.
 */
package kof.game.arena.view {

import QFLib.Utils.HtmlUtil;

import flash.events.Event;
import flash.geom.Point;

import kof.framework.CViewHandler;
import kof.game.arena.CArenaHelpHandler;
import kof.game.arena.CArenaManager;
import kof.game.arena.CArenaNetHandler;
import kof.game.arena.enum.EArenaRewardTakeState;
import kof.game.arena.enum.EArenaRewardType;
import kof.game.arena.event.CArenaEvent;
import kof.game.arena.util.CArenaState;
import kof.game.common.CFlyItemUtil;
import kof.game.common.CItemUtil;
import kof.game.common.CLang;
import kof.game.common.CRewardUtil;
import kof.game.item.data.CRewardListData;
import kof.table.ArenaHighestRanking;
import kof.table.ArenaRankingReward;
import kof.ui.IUICanvas;
import kof.ui.master.arena.ArenaBestRewardRenderUI;
import kof.ui.master.arena.ArenaRewardRenderUI;
import kof.ui.master.arena.ArenaRewardWinUI;

import morn.core.components.Component;
import morn.core.components.Dialog;

import morn.core.components.List;
import morn.core.handlers.Handler;

/**
 * 竞技场奖励界面
 */
public class CArenaRewardViewHandler extends CViewHandler {

    private var m_bViewInitialized : Boolean;
    private var m_pViewUI:ArenaRewardWinUI;
    private var m_pCurrList:List;

    public function CArenaRewardViewHandler( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array
    {
        return [ArenaRewardWinUI];
    }

    override protected function get additionalAssets():Array
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
                m_pViewUI = new ArenaRewardWinUI();
                m_pViewUI.closeHandler = new Handler( _onClose );
                m_pViewUI.list_common.renderHandler = new Handler( _renderCommon );
                m_pViewUI.list_best.renderHandler = new Handler( _renderBest );

                m_bViewInitialized = true;
            }
        }

        return m_bViewInitialized;
    }

    public function addDisplay() : void
    {
        this.loadAssetsByView( viewClass, _showDisplay );
    }

    public function removeDisplay():void
    {
        if(m_bViewInitialized)
        {
            if(m_pViewUI && m_pViewUI.parent)
            {
                m_pViewUI.close(Dialog.CLOSE);
            }

            _removeListeners();
        }
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

        uiCanvas.addDialog( m_pViewUI );
    }

    private function _initView():void
    {
        m_pViewUI.list_common.visible = true;
        m_pViewUI.list_best.visible = false;
        m_pViewUI.tab.selectedIndex = 0;
        m_pCurrList = m_pViewUI.list_common;

        m_pViewUI.box_tip.visible = _arenaHelper.hasRewardToTake();

        updateDisplay();
    }

    private function _addListeners():void
    {
        m_pViewUI.tab.addEventListener( Event.CHANGE, _onTabSelectedHandler);
        system.addEventListener(CArenaEvent.TakeRewardSucc,_onTakeRewardSuccHandler);
        system.addEventListener(CArenaEvent.RewardInfo_Update,_onRewardInfoUpdateHandler);
    }

    private function _removeListeners():void
    {
        m_pViewUI.tab.removeEventListener( Event.CHANGE, _onTabSelectedHandler);
        system.removeEventListener(CArenaEvent.TakeRewardSucc,_onTakeRewardSuccHandler);
        system.removeEventListener(CArenaEvent.RewardInfo_Update,_onRewardInfoUpdateHandler);
    }

    override protected function updateDisplay():void
    {
        _updateItemList();
        _updateRankInfo();
    }

    private function _updateItemList():void
    {
        var rewardArr:Array;
        if(m_pViewUI.tab.selectedIndex == EArenaRewardType.Common_Reward)
        {
            rewardArr = _arenaHelper.getCommonRankRewardInfo();
        }
        else if(m_pViewUI.tab.selectedIndex == EArenaRewardType.His_Best_Reward)
        {
            rewardArr = _arenaHelper.getBestRankRewardInfo();

            delayCall(0.1,_scrollToFirstCanTake);
        }

        m_pCurrList.dataSource = rewardArr;
    }

    private function _updateRankInfo():void
    {
        var arenaManager:CArenaManager = system.getHandler(CArenaManager) as CArenaManager;
        m_pViewUI.txt_currRank.isHtml = true;
        m_pViewUI.txt_currRank.text = "当前排名：" + HtmlUtil.color(arenaManager.getMyRank().toString(),"#f37911");
        m_pViewUI.txt_hisBestRank.isHtml = true;
        var hisBestRank:int;
        if(arenaManager.getMyRank() == 0)
        {
            hisBestRank = 0;
        }
        else
        {
            hisBestRank = arenaManager.getHisBestRank();
        }
        m_pViewUI.txt_hisBestRank.text = "历史最高排名：" + HtmlUtil.color(hisBestRank.toString(),"#f37911");
    }

    /**
     * 切换页签处理
     * @param e
     */
    private function _onTabSelectedHandler(e:Event = null) : void
    {
        if(m_pViewUI.tab.selectedIndex == EArenaRewardType.Common_Reward)
        {
            m_pViewUI.list_common.visible = true;
            m_pViewUI.list_best.visible = false;
            m_pCurrList = m_pViewUI.list_common;
        }

        if(m_pViewUI.tab.selectedIndex == EArenaRewardType.His_Best_Reward)
        {
            m_pViewUI.list_best.visible = true;
            m_pViewUI.list_common.visible = false;
            m_pCurrList = m_pViewUI.list_best;
        }

        updateDisplay();
    }

    /**
     * 得第一个可领取的
     * @return
     */
    private function _scrollToFirstCanTake():void
    {
        var arr:Array = m_pViewUI.list_best.dataSource as Array;
        for(var i:int = 0; i < arr.length; i++)
        {
            var state:int = _arenaHelper.getRewardState(arr[i].ID);
            if(state == EArenaRewardTakeState.CanTake)
            {
                m_pViewUI.list_best.scrollTo(i);
                return;
            }
        }
    }

    private function _renderCommon( item:Component, index:int):void
    {
        if(!(item is ArenaRewardRenderUI))
        {
            return;
        }

        var render:ArenaRewardRenderUI = item as ArenaRewardRenderUI;
        render.mouseChildren = true;
        render.mouseEnabled = true;
        var data:ArenaRankingReward = render.dataSource as ArenaRankingReward;
        if(null != data)
        {
            render.txt_di.visible = true;
            render.txt_ming.visible = true;
            if(data.rankingFloor <= 3)
            {
//                render.clip_rank1.visible = false;
//                render.clip_rank2.visible = false;
//                render.img_gang.visible = false;
                render.txt_rank.visible = false;
                render.img_myh.visible = false;
                render.clip_rank.visible = true;
                render.clip_rank.num = data.rankingFloor;
            }
            else if(data.rankingFloor != data.rankingUpper)
            {
//                var len:int = String(render.clip_rank1.num ).split("" ).length;
//                render.clip_rank1.visible = true;
                render.clip_rank.visible = false;
//                render.clip_rank1.num = data.rankingFloor;

                render.txt_rank.visible = true;
                render.txt_rank.text = data.rankingFloor + "-" + data.rankingUpper;

//                var offset:int;
//                if(data.rankingFloor < 10)
//                {
//                    offset = 22;
//                }
//                else if(data.rankingFloor < 100)
//                {
//                    offset = 39;
//                }
//                else if(data.rankingFloor < 1000)
//                {
//                    offset = 56;
//                }
//                else
//                {
//                    offset = 73;
//                }
//
//                render.img_gang.visible = true;
//                render.img_gang.x = render.clip_rank1.x + offset;
//
//                render.clip_rank2.visible = true;
//                render.clip_rank2.num = data.rankingUpper;
//                render.clip_rank2.x = render.img_gang.x + render.img_gang.width + 5;


                if(!_arenaHelper.getNextRewardInfo(data.ID + 1))
                {
                    render.img_myh.visible = true;
//                    render.img_gang.visible = false;
//                    render.clip_rank2.visible = false;
//                    render.clip_rank1.num = render.clip_rank1.num - 1;
//                    render.img_myh.x = render.clip_rank1.x + offset;

                    render.txt_di.visible = false;
                    render.txt_ming.visible = false;
                    render.txt_rank.visible = true;
                    render.txt_rank.text = (data.rankingFloor - 1) + "";
//                    render.img_myh.x = render.txt_rank.x + render.txt_rank.width;
                }
                else
                {
                    render.img_myh.visible = false;
                }
            }

            render.list_item.renderHandler = new Handler(CItemUtil.getItemRenderFunc(system));
            var rewardListData:CRewardListData = CRewardUtil.createByDropPackageID(system.stage, data.dropId);
            var list:Array = rewardListData == null ? [] : rewardListData.list;
            render.list_item.dataSource = list;
        }
        else
        {
            render.clip_rank.visible = false;
//            render.clip_rank1.visible = false;
//            render.clip_rank2.visible = false;
//            render.img_gang.visible = false;
            render.img_myh.visible = false;
            render.list_item.dataSource = [];
        }
    }

    private function _renderBest( item:Component, index:int):void
    {
        if ( !(item is ArenaBestRewardRenderUI) )
        {
            return;
        }

        var render:ArenaBestRewardRenderUI = item as ArenaBestRewardRenderUI;
        render.mouseChildren = true;
        render.mouseEnabled = true;
        var data:ArenaHighestRanking = render.dataSource as ArenaHighestRanking;
        if(null != data)
        {
            render.clip_rank.num = data.ranking;
            render.list_item.renderHandler = new Handler(CItemUtil.getItemRenderFunc(system));
            var rewardListData:CRewardListData = CRewardUtil.createByDropPackageID(system.stage, data.dropId);
            var list:Array = rewardListData == null ? [] : rewardListData.list;
            render.list_item.dataSource = list;

            render.btn_take.visible = false;
            render.btn_take.clickHandler = new Handler(_onTakeRewardHandler,[data.ID]);
            render.img_hasTaken.visible = false;
            render.txt_notReach.visible = false;
            //render.box_btnEffect.visible = false;
            //render.clip_effect.autoPlay = false;
            var state:int = _arenaHelper.getRewardState(data.ID);
            switch (state)
            {
                case EArenaRewardTakeState.CanTake:
                    render.btn_take.visible = true;
                    //render.box_btnEffect.visible = true;
                    //render.clip_effect.autoPlay = true;
                    break;
                case EArenaRewardTakeState.HasTaken:
                    render.img_hasTaken.visible = true;
                    break;
                case EArenaRewardTakeState.NotReach:
                    render.txt_notReach.visible = true;
                    break;
            }
        }
        else
        {
            render.clip_rank.num = 0;
            render.list_item.dataSource = [];
            render.btn_take.visible = false;
            render.img_hasTaken.visible = false;
            render.txt_notReach.visible = false;
            //render.box_btnEffect.visible = false;
            //render.clip_effect.autoPlay = false;
        }
    }

    private function _onTakeRewardSuccHandler(e:CArenaEvent):void
    {
        if(m_pViewUI.tab.selectedIndex == EArenaRewardType.His_Best_Reward)
        {
            var rewardId:int = e.data as int;
            for each(var cell:ArenaBestRewardRenderUI in m_pCurrList.cells)
            {
                var data:ArenaHighestRanking = cell.dataSource as ArenaHighestRanking;
                if(data && data.ID == rewardId)
                {
                    _flyItem(cell.list_item);
                }
            }
        }
    }

    private function _flyItem(list:List):void
    {
        var len:int = list.dataSource.length;
        for(var i:int = 0; i < len; i++)
        {
            var item:Component = list.getCell(i) as Component;
            CFlyItemUtil.flyItemToBag(item, item.localToGlobal(new Point()), system);
        }
    }

    private function _onRewardInfoUpdateHandler(e:CArenaEvent):void
    {
        if(m_pViewUI.tab.selectedIndex == EArenaRewardType.His_Best_Reward)
        {
            m_pCurrList.dataSource = _arenaHelper.getBestRankRewardInfo();

            delayCall(0.1,_scrollToFirstCanTake);
        }

        m_pViewUI.box_tip.visible = _arenaHelper.hasRewardToTake();
    }

    /**
     * 领取奖励
     * @param rewardId
     */
    private function _onTakeRewardHandler(rewardId:int):void
    {
        if(CArenaState.isInTakeReward)
        {
            (system.stage.getSystem(IUICanvas) as IUICanvas).showMsgAlert(CLang.Get("clientLockTips"));
            return;
        }

//        system.dispatchEvent(new CArenaEvent(CArenaEvent.TakeRewardSucc,rewardId));
        (system.getHandler(CArenaNetHandler) as CArenaNetHandler).arenaHighestAwardGetRequest(rewardId);
    }

    private function _onClose(type:String):void
    {
        _removeListeners();
    }

    private function get _arenaHelper():CArenaHelpHandler
    {
        return system.getHandler(CArenaHelpHandler) as CArenaHelpHandler;
    }

    public function get isViewShow():Boolean
    {
        return m_pViewUI && m_pViewUI.parent;
    }

    override public function dispose():void
    {
        super.dispose();

        m_pCurrList = null;
    }
}
}
