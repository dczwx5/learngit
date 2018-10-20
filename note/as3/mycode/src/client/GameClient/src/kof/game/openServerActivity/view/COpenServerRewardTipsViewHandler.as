//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Maniac on 2017/8/16.
 */
package kof.game.openServerActivity.view {

import kof.framework.CViewHandler;
import kof.game.common.CRewardUtil;
import kof.game.item.data.CRewardData;
import kof.game.item.data.CRewardListData;
import kof.game.openServerActivity.COpenServerActivityManager;
import kof.game.openServerActivity.COpenServerActivitySystem;
import kof.table.CarnivalRewardConfig;
import kof.ui.imp_common.RewardItemUI;
import kof.ui.master.OpenServerActivity.OpenServerActivityRewardTipsUI;

import morn.core.handlers.Handler;

/**
 * 物品Tips
 */
public class COpenServerRewardTipsViewHandler extends CViewHandler {

    private var m_bViewInitialized : Boolean;
    private var _rewardTipsUI:OpenServerActivityRewardTipsUI;
    private var _data:Object;


    public function COpenServerRewardTipsViewHandler() {
        super( false );
    }

    override public function get viewClass() : Array {
        return [ OpenServerActivityRewardTipsUI ];
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
            _rewardTipsUI = new OpenServerActivityRewardTipsUI();

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

            var rewardTable:CarnivalRewardConfig = _data as CarnivalRewardConfig;//send consume_blue_diamond
            var rewardData:CRewardListData = CRewardUtil.createByDropPackageID(openServerSystem.stage, rewardTable.reward);
            if(rewardData) {
                _rewardTipsUI.list_item.dataSource = rewardData.list;
            }
            var isGet:Boolean = openServerManager.isGetReward(rewardTable.ID);
            if(isGet){
                _rewardTipsUI.img_ylq.visible = true;
                _rewardTipsUI.img_wdc.visible = false;
            }else{
                if(openServerManager.getTargetComlpeteNum() < rewardTable.completeNum){
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

    private function get openServerManager() : COpenServerActivityManager {
        return system.getBean( COpenServerActivityManager ) as COpenServerActivityManager;
    }

    private function get openServerSystem() : COpenServerActivitySystem {
        return system as COpenServerActivitySystem;
    }

}
}
