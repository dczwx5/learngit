//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Maniac on 2017/8/16.
 */
package kof.game.limitActivity.view {

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.game.common.CRewardUtil;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardData;
import kof.game.item.data.CRewardListData;
import kof.game.item.view.tips.CItemTipsView;
import kof.game.limitActivity.*;
import kof.game.player.CPlayerSystem;
import kof.table.ActivityConst;
import kof.table.Item;
import kof.table.LimitTimeConsumeActivityRankConfig;
import kof.ui.CUISystem;
import kof.ui.imp_common.RewardItemUI;
import kof.ui.master.limitActivity.LimitRewardItemUI;
import kof.ui.master.limitActivity.LimitRewardUI;

import morn.core.components.Dialog;
import morn.core.handlers.Handler;

public class CLimitActivityRewardViewHandler extends CViewHandler {

    private var m_bViewInitialized:Boolean;
    private var m_rewardView:LimitRewardUI;

    private var _closeHandler:Handler;

    public function CLimitActivityRewardViewHandler() {
        super( false );
    }

    override public function get viewClass() : Array {
        return [ LimitRewardUI, LimitRewardItemUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !m_bViewInitialized ) {
            this.initialize();
        }

        return m_bViewInitialized;
    }

    protected function initialize() : void {
        if ( !m_rewardView ) {
            m_rewardView = new LimitRewardUI();
            m_rewardView.btn_close.clickHandler = new Handler( _close );


            m_rewardView.list_reward.renderHandler = new Handler( _onRenderRewardInfoItem );

            var activityConst:ActivityConst = _activityConstTable.findByPrimaryKey(1);
            m_rewardView.txt_tips.text = '1钻=' + activityConst.scoreZs + '积分，1绑钻=' + activityConst.scoreBz + '积分';

            m_bViewInitialized = true;
        }
    }

    public function addDisplay() : void {
        this.loadAssetsByView( viewClass, _addToDisplay );
    }

    private function _addToDisplay() : void {

        if ( onInitializeView() ) {
            invalidate();

            if ( m_rewardView )
            {
                uiCanvas.addDialog( m_rewardView );

                m_rewardView.list_reward.dataSource = limitManager.getScoreRankList();

                _addEventListener();
            }

        } else {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }


    }

    public function removeDisplay() : void {
        if ( m_rewardView ) {
            m_rewardView.close( Dialog.CLOSE );
            _removeEventListener();
        }
    }

    public function set closeHandler( value:Handler ):void {
        _closeHandler = value;
    }

    private function _onRenderRewardInfoItem(item:LimitRewardItemUI,index:int):void{
        if(item == null || item.dataSource == null)return;

        var rankTable:LimitTimeConsumeActivityRankConfig = item.dataSource as LimitTimeConsumeActivityRankConfig;

        if(rankTable == null)return;
        if(rankTable.configId <= 3){
            item.clip_rank1.visible = true;
            item.clip_rank1.num = rankTable.configId;

            item.clip_rank2.visible = false;
        }else{
            item.clip_rank1.visible = false;
            item.clip_rank2.visible = true;
            item.clip_rank2.num = rankTable.configId;
        }

        item.lb_score.text = "" + rankTable.needScore;
        item.lb_vipLv.text = "" + rankTable.needVIP;

        item.list_item.renderHandler = new Handler( _onRenderRewardItem );
        var rewardData:CRewardListData = CRewardUtil.createByDropPackageID(limitSystem.stage, rankTable.reward);
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
        var itemSystem:CItemSystem = limitSystem.stage.getSystem(CItemSystem) as CItemSystem;
        itemSystem.addTips(CItemTipsView, item);
    }


    override protected virtual function updateData():void {
        super.updateData();

        if ( m_rewardView ) {

        }

    }

    private function _addEventListener() : void {
//        system.addEventListener(CVIPEvent.VIP_BUYGIFT,_onUpdateBuyState);
    }

    private function _removeEventListener() : void {
//        system.removeEventListener(CVIPEvent.VIP_BUYGIFT,_onUpdateBuyState);
    }

    private function _close():void{
        if ( m_rewardView ) {
            m_rewardView.close( Dialog.CLOSE );
        }
    }

    private function get limitManager() : CLimitActivityManager {
        return system.getBean( CLimitActivityManager ) as CLimitActivityManager;
    }

    private function get limitSystem() : CLimitActivitySystem {
        return system as CLimitActivitySystem;
    }

    private function get playSystem() : CPlayerSystem {
        return system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
    }

    private function get uiSysTem() : CUISystem {
        return system.stage.getSystem(CUISystem) as CUISystem;
    }

    public function getItemTableByID(id:int) : Item{
        var itemTable:IDataTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.ITEM);
        return itemTable.findByPrimaryKey(id);
    }

    private function get _pCDatabaseSystem():CDatabaseSystem{
        return system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }
    private function get _activityConstTable():IDataTable{
        return  _pCDatabaseSystem.getTable(KOFTableConstants.ACTIVITYCONST);
    }


}
}
