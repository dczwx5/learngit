//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/8/5.
 * Time: 16:24
 */
package kof.game.globalBoss.view {

    import flash.utils.clearInterval;
    import flash.utils.setInterval;

    import kof.data.CDataTable;
    import kof.data.CDatabaseSystem;
    import kof.data.KOFTableConstants;
    import kof.framework.CAppSystem;
    import kof.game.bag.data.CBagData;
    import kof.game.common.CLang;
    import kof.game.common.CRewardUtil;
    import kof.game.globalBoss.CWorldBossSystem;
    import kof.game.globalBoss.datas.CWBDataManager;
    import kof.game.instance.CInstanceSystem;
    import kof.game.item.CItemData;
    import kof.game.item.CItemSystem;
    import kof.game.item.data.CRewardData;
    import kof.game.item.data.CRewardListData;
    import kof.table.Item;
    import kof.ui.IUICanvas;
    import kof.ui.imp_common.RewardItemUI;
    import kof.ui.master.WorldBoss.WBResultUI;
    import kof.ui.master.messageprompt.GoodsItemUI;

    import morn.core.components.Component;

    import morn.core.handlers.Handler;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/8/5
     */
    public class CWBResultView {
        private var _wbResultUI : WBResultUI = null;
        private var _uiContainer : IUICanvas = null;
        private var _system : CAppSystem = null;
        private var _wbDatamanager : CWBDataManager = null;
        private var _wbTips : CWBTips = null;

        private var _intervelID : int = 0;

        public function CWBResultView( uiContainer : IUICanvas, appSys : CAppSystem ) {
            _wbResultUI = new WBResultUI();
            this._uiContainer = uiContainer;
            _wbResultUI.leaveBtn.clickHandler = new Handler( _leaveInstance );
            this._system = appSys;
            _wbResultUI.rewardItemList.renderHandler = new Handler( _renderItem );
            _wbDatamanager = _system.stage.getSystem( CWorldBossSystem ).getBean( CWBDataManager ) as CWBDataManager;
            CWorldBossSystem(_system.stage.getSystem( CWorldBossSystem )).excuteNotEndLeveInstance = _notEndLeve;
        }

        private function _initView() : void {
            if (_wbDatamanager.wbData.rank > 0) {
                _wbResultUI.rankLabel.text = _wbDatamanager.wbData.rank + "";
            } else {
                _wbResultUI.rankLabel.text = CLang.Get("common_none");
            }

            _wbResultUI.damageLabel.text = _wbDatamanager.wbData.damage + "";
            _wbResultUI.goldLabel.text = _wbDatamanager.getGoldReward( _wbDatamanager.wbData.damage ) + "";

            if (_wbDatamanager.wbData.rank > 0) {
                var rewardListData : CRewardListData = CRewardUtil.createByDropPackageID( _system.stage, _wbDatamanager.getWorldBossRankRewardRewardID() );
                var itemListArr : Array = rewardListData.list;
                _wbResultUI.rewardItemList.dataSource = itemListArr;
                _wbResultUI.rewardItemList.visible = true;
                _wbResultUI.none_reward_txt.visible = false;
            } else {
                _wbResultUI.rewardItemList.visible = false;
                _wbResultUI.none_reward_txt.visible = true;
            }

            _wbTips = new CWBTips();

            var reviveTime : int = 45;
            var shi : int = reviveTime / 10;
            var ge : int = reviveTime % 10;
            _intervelID = setInterval
            ( function () : void {
                reviveTime--;
                if ( reviveTime < 0 ) {
                    clearInterval( _intervelID );
                    _leaveInstance();
                }
                shi = reviveTime / 10;
                ge = reviveTime % 10;
                _wbResultUI.leaveTimeLabel.text = "(00:" + shi + ge + CLang.Get("autoLeavout")+")";
            }, 1000 );
        }

        private function _renderItem( item : Component, idx : int ) : void {
            var itemUI : RewardItemUI = item as RewardItemUI;
            var data : CRewardData = item.dataSource as CRewardData;
            if ( !data )return;
            itemUI.bg_clip.index = data.quality;
            itemUI.icon_image.url = data.iconSmall;
            itemUI.num_lable.text = data.num + "";

            var goods : GoodsItemUI = new GoodsItemUI();
            goods.img.url = data.iconBig;
            var bagData : CBagData = _wbDatamanager.getItemNuForBag( data.ID );
            if ( bagData ) {
                goods.txt.text = bagData.num + "";
            } else {
                goods.txt.text = "0";
            }
            itemUI.toolTip = new Handler( _showItemTips, [ goods, data.ID, data.num ] );
        }

        private function _showItemTips( goods : GoodsItemUI, id : int, itemNum : int) : void {
            _wbTips.appSystem = _system.stage.getSystem( CWorldBossSystem );
            _wbTips.showItemTips( goods, _getItemTableData( id ), _getItemData( id ),itemNum );
        }

        private function _getItemTableData( itemID : int ) : Item {
            var itemTable : CDataTable;
            var pDatabaseSystem : CDatabaseSystem = _system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            itemTable = pDatabaseSystem.getTable( KOFTableConstants.ITEM ) as CDataTable;
            return itemTable.findByPrimaryKey( itemID );
        }

        private function _getItemData( itemID : int ) : CItemData {
            var itemData : CItemData = (_system.stage.getSystem( CItemSystem ) as CItemSystem).getItem( itemID );
            return itemData;
        }

        public function _leaveInstance() : void {
            clearInterval( _intervelID );
            (_system.stage.getSystem( CInstanceSystem ) as CInstanceSystem).exitInstance();
            _wbResultUI.close();
        }

        private function _notEndLeve():void{
            clearInterval( _intervelID );
            _wbResultUI.close();
        }

        public function show() : void {
            _uiContainer.addPopupDialog( _wbResultUI );
            _initView();
        }
    }
}
