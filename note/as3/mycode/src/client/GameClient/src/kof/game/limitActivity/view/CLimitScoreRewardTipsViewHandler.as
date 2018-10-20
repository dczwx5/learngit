//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Maniac on 2017/8/16.
 */
package kof.game.limitActivity.view {

import kof.game.limitActivity.*;

import QFLib.Utils.HtmlUtil;

import kof.framework.CViewHandler;
import kof.game.common.CRewardUtil;
import kof.game.item.data.CRewardData;
import kof.game.item.data.CRewardListData;
import kof.table.LimitTimeConsumeActivityScoreConfig;
import kof.ui.imp_common.RewardItemUI;
import kof.ui.master.limitActivity.LimitScoreRewardTipsUI;

import morn.core.handlers.Handler;

/**
 * 商店物品Tips
 */
public class CLimitScoreRewardTipsViewHandler extends CViewHandler {

    private var m_bViewInitialized : Boolean;
    private var _rewardTipsUI:LimitScoreRewardTipsUI;
    private var _data:Object;


    public function CLimitScoreRewardTipsViewHandler() {
        super( false );
    }

    override public function get viewClass() : Array {
        return [ LimitScoreRewardTipsUI ];
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
        if ( _rewardTipsUI == null ) {
            _rewardTipsUI = new LimitScoreRewardTipsUI();

            _rewardTipsUI.img_ylq.visible = false;
            _rewardTipsUI.img_wdc.visible = false;

            _rewardTipsUI.list_item.renderHandler = new Handler( _onRenderRewardList );

            m_bViewInitialized = true;
        }
    }

    public function showTips(obj:Object):void {
        _data = obj;
        this.loadAssetsByView( viewClass, _addToDisplay )
    }

    private function _addToDisplay():void {

        if ( onInitializeView() ) {
            invalidate();
        }

        if(_data){
            _rewardTipsUI.img_ylq.visible = false;
            _rewardTipsUI.img_wdc.visible = false;

            var scoreTable:LimitTimeConsumeActivityScoreConfig = _data as LimitTimeConsumeActivityScoreConfig;//send consume_blue_diamond
            var rewardData:CRewardListData = CRewardUtil.createByDropPackageID(limitSystem.stage, scoreTable.reward);
            if(rewardData) {
                _rewardTipsUI.list_item.dataSource = rewardData.list;
            }
            var isGet:Boolean = limitManager.isGetReward(scoreTable.ID);
            if(isGet){
                _rewardTipsUI.img_ylq.visible = true;
                _rewardTipsUI.img_wdc.visible = false;
            }else{
                if(limitManager.mySroce < scoreTable.score){
                    _rewardTipsUI.img_wdc.visible = true;
                    _rewardTipsUI.img_ylq.visible = false;
                }
            }
        }

        App.tip.addChild(_rewardTipsUI);
    }

    private function _onRenderRewardList(item:RewardItemUI,index:int):void{
        if(item == null || item.dataSource == null)return;

        var itemData:CRewardData = item.dataSource as CRewardData;
        if (!itemData) return ;
        item.box_eff.visible = itemData.effect;
        item.clip_eff.autoPlay = itemData.effect;
        item.num_lable.text = itemData.num.toString();
        item.icon_image.url = itemData.iconSmall;
        item.bg_clip.index = itemData.quality;
        item.hasTakeImg.visible = false;
    }

    private function get limitSystem() : CLimitActivitySystem {
        return system as CLimitActivitySystem;
    }

    private function get limitManager() : CLimitActivityManager {
        return system.getBean( CLimitActivityManager ) as CLimitActivityManager;
    }

}
}
