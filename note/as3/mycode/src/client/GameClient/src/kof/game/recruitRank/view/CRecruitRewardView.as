//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Lune on 2018/5/11.
 */
package kof.game.recruitRank.view {

import flash.utils.Dictionary;

import kof.framework.CViewHandler;
import kof.game.common.CItemUtil;
import kof.game.common.CRewardUtil;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardData;
import kof.game.item.data.CRewardListData;
import kof.game.item.view.tips.CItemTipsView;
import kof.game.recruitRank.CRecruitRankManager;
import kof.game.recruitRank.CRecruitRankSystem;
import kof.ui.imp_common.RewardItemUI;
import kof.ui.master.RecruitRank.RecruitRankRewardItemUI;
import kof.ui.master.RecruitRank.RecruitRankRewardUI;

import morn.core.components.Dialog;

import morn.core.handlers.Handler;

public class CRecruitRewardView extends CViewHandler{

    private var isViewInit : Boolean;
    private var m_rewardView : RecruitRankRewardUI;
    private var _closeHandler : Handler;
    public function CRecruitRewardView() {
        super();
    }

    override public function get viewClass() : Array
    {
        return [ RecruitRankRewardUI ];
    }
//    override protected function get additionalAssets() : Array{
//        return [
//            //"RecruitRank.swf",
//            "limitActivity.swf",
//        ];
//    }
    override protected function onAssetsLoadCompleted() : void
    {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean
    {
        if( !super.onInitializeView() )
            return false;

        if( !isViewInit)
            this.initialize();

        return isViewInit;
    }

    protected function initialize() : void
    {
        if( !m_rewardView )
        {
            m_rewardView = new RecruitRankRewardUI();
            m_rewardView.btn_close.clickHandler = new Handler( _close );
            //渲染列表数据
            m_rewardView.list_reward.renderHandler = new Handler( _onRenderRewardInfoItem );
            isViewInit = true;
        }
    }

    public function addDisplay() : void
    {
        this.loadAssetsByView( viewClass, _addToDisplay );
    }

    private function _addToDisplay() : void
    {
        if( onInitializeView() )
        {
            invalidate();

            if(m_rewardView)
            {
                uiCanvas.addDialog( m_rewardView );
                //填充奖励list
                m_rewardView.list_reward.dataSource = recruitManager.getTotalRewardList();

                _addEventListener();
            }
        }
        else {
            LOG.logErrorMsg( "Initialized\"" + viewClass + "\" failed by requesting display shown." );
        }
    }
    public function removeDisplay() : void
    {
        if( m_rewardView )
        {
            m_rewardView.close( Dialog.CLOSE );
        }
    }

    private function _onRenderRewardInfoItem(item:RecruitRankRewardItemUI,index:int):void{
        if(item == null || item.dataSource == null)return;
        var rankTable:Object = item.dataSource as Object;

        if(rankTable == null)return;
        var rankArr:Array = rankTable.rank;
        if(!rankArr || rankArr.length == 0)
        {
            trace("数据错误");
            return;
        }
        if(rankArr.length == 1)
        {
            item.box_num.visible = false;
            item.num_top.visible = true;
            item.num_top.num = rankArr[0];
            item.num_top.x = rankArr[0] == 10 ? 50:61;
        }
        else
        {
            item.box_num.visible = true;
            item.num_top.visible = false;
            item.num_preRank.num = rankArr[0];
            item.num_backRank.num = rankArr[rankArr.length-1];
        }
        item.lb_time.text = rankTable.needTimes + "";
        item.list_item.renderHandler = new Handler( CItemUtil.getItemRenderFunc(recruitRankSystem) );
        var rewardData:CRewardListData = CRewardUtil.createByDropPackageID(recruitRankSystem.stage, rankTable.reward);
        if(rewardData){
            item.list_item.dataSource = rewardData.list;
        }
        if( rewardData.list.length >= 5 )
            item.list_item.x = 150;
        else if( rewardData.list.length >= 4 )
            item.list_item.x = 185;
        else if( rewardData.list.length >= 3 )
            item.list_item.x = 215;
        else if( rewardData.list.length >= 2 )
            item.list_item.x = 240;
        else if( rewardData.list.length >= 1 )
            item.list_item.x = 270;
    }

    private function _onRenderRewardItem(item:RewardItemUI,index:int):void{
        if(item == null || item.dataSource == null)return;

        var itemData:CRewardData = item.dataSource as CRewardData;
        if (!itemData) return ;
        item.box_eff.visible = itemData.effect;
        item.clip_eff.autoPlay = itemData.effect;
        item.num_lable.text = itemData.num.toString();
        item.icon_image.url = itemData.iconSmall;
        item.bg_clip.index = itemData.quality;
        item.toolTip = new Handler(_addTips, [item]);
        item.hasTakeImg.visible = false;

    }

    private function _addTips(item:RewardItemUI) : void {
        var itemSystem:CItemSystem = recruitRankSystem.stage.getSystem(CItemSystem) as CItemSystem;
        itemSystem.addTips(CItemTipsView, item);
    }

    public function set closeHandler(value : Handler) :void
    {
        _closeHandler = value;
    }
    private function _addEventListener() : void
    {

    }
    private function _close() : void
    {
        if( m_rewardView )
        {
            m_rewardView.close( Dialog.CLOSE );
        }

    }

    override protected virtual function updateData() : void
    {
        super.updateData();
    }

    public function get recruitManager():CRecruitRankManager
    {
        return system.getBean(CRecruitRankManager) as CRecruitRankManager;
    }
    private function get recruitRankSystem() : CRecruitRankSystem
    {
        return system as CRecruitRankSystem;
    }

}
}
