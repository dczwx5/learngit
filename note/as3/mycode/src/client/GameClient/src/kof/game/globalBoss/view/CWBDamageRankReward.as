//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/8/7.
 * Time: 20:24
 */
package kof.game.globalBoss.view {

    import kof.data.CDataTable;
    import kof.data.CDatabaseSystem;
    import kof.data.KOFTableConstants;
    import kof.framework.CAppSystem;
    import kof.game.bag.data.CBagData;
import kof.game.common.CItemUtil;
import kof.game.common.CRewardUtil;
    import kof.game.globalBoss.datas.CWBDataManager;
    import kof.game.globalBoss.net.CWBNet;
    import kof.game.item.CItemData;
    import kof.game.item.CItemSystem;
    import kof.game.item.data.CRewardData;
    import kof.game.item.data.CRewardListData;
    import kof.table.Item;
    import kof.table.WorldBossRankReward;
    import kof.ui.IUICanvas;
    import kof.ui.imp_common.RewardItemUI;
    import kof.ui.master.WorldBoss.WBRewardItemUI;
    import kof.ui.master.WorldBoss.WBRewardUI;
    import kof.ui.master.messageprompt.GoodsItemUI;

    import morn.core.components.Clip;
    import morn.core.components.Component;
    import morn.core.handlers.Handler;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/8/7
     */
    public class CWBDamageRankReward {
        private var _wbDamageRankRewardUI : WBRewardUI = null;
        private var _uiContainer : IUICanvas = null;
        private var _network : CWBNet = null;
        private var _wbDataManager : CWBDataManager = null;
        private var _appSystem : CAppSystem = null;
        private var _wbTips : CWBTips = null;

        public function CWBDamageRankReward( uiContainer : IUICanvas, sys : CAppSystem ) {
            _wbDamageRankRewardUI = new WBRewardUI();
            this._uiContainer = uiContainer;
            _appSystem = sys;
            _wbDataManager = _appSystem.getBean( CWBDataManager ) as CWBDataManager;
            _initView();
        }

        private function _initView() : void {
            _wbDamageRankRewardUI.rankList.renderHandler = new Handler( _renderItem );
            _wbDamageRankRewardUI.rankList.dataSource = getWorldBossRankRewardRewardArray();
            _wbTips = new CWBTips();
            _wbTips.appSystem = _appSystem;
            _wbDamageRankRewardUI.lastKill.killItemList.renderHandler = new Handler( _renderLastKillItem );
            var rewardListData : CRewardListData = CRewardUtil.createByDropPackageID( _appSystem.stage, _wbDataManager.worldBossConstant.lastDamageReward );
            _wbDamageRankRewardUI.lastKill.killItemList.dataSource = rewardListData.list;
            _wbDamageRankRewardUI.lastKill.rankBox.visible = false;
        }

        private function _renderLastKillItem( item : Component, idx : int ) : void {
            var itemUI : RewardItemUI = item as RewardItemUI;
            var data : CRewardData = item.dataSource as CRewardData;
            if ( !data )return;
            itemUI.bg_clip.index = data.quality;
            itemUI.icon_image.url = data.iconBig;
            itemUI.num_lable.text = data.num + "";
            itemUI.box_eff.visible = data.effect;

            var goods : GoodsItemUI = new GoodsItemUI();
            goods.img.url = itemUI.icon_image.url;
            var bagData : CBagData = _wbDataManager.getItemNuForBag( data.ID );
            if ( bagData ) {
                goods.txt.text = bagData.num + "";
            } else {
                goods.txt.text = "0";
            }
            itemUI.toolTip = new Handler( _showItemTips, [ goods, data.ID,data.num ] );
        }

        public function getWorldBossRankRewardRewardArray() : Array {
            var pDatabaseSystem : CDatabaseSystem = this._appSystem.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            var wbRankRewardTable : CDataTable = pDatabaseSystem.getTable( KOFTableConstants.WORLD_BOSS_RANK_REWARD ) as CDataTable;
            var rankRewardArr : Array = wbRankRewardTable.toArray();
            return rankRewardArr;
        }

        private function _renderItem( item : Component, idx : int ) : void {
            var itemUI : WBRewardItemUI = item as WBRewardItemUI;
            var data : WorldBossRankReward = item.dataSource as WorldBossRankReward;
            if ( !data )return;
            var rewardListData : CRewardListData = CRewardUtil.createByDropPackageID( _appSystem.stage, data.rewardID );
            var itemListArr : Array = rewardListData.list;
            itemUI.itemList.renderHandler = new Handler( CItemUtil.getItemRenderFunc(_appSystem) );
            itemUI.itemList.dataSource = itemListArr;
            showRank( itemUI, data.rankMax, "f" );
            showRank( itemUI, data.rankMin, "b" );
        }

        private function showRank( itemUI : WBRewardItemUI, rank : int, name : String ) : void {
            var ge : int = 0;
            var shi : int = 0;
            var bai : int = 0;
            var qian : int = 0;
            if ( rank < 4 ) {
                showf( itemUI, name );
                itemUI.clip_rank.visible = true;
                itemUI.alink.visible = false;
                itemUI.clip_rank.num = rank;
            } else if ( rank < 10 ) {
                showf( itemUI, name );
                itemUI[ name + 1 ].visible = true;
                if ( name == "b" ) {
                    (itemUI[ name + 1 ] as Clip).index = rank;
                } else {
                    (itemUI[ name + 1 ].getChildByName( "big" ) as Clip).index = rank;
                    (itemUI[ name + 1 ].getChildByName( "small" ) as Clip).index = rank;
                }
            } else if ( rank < 100 ) {
                showf( itemUI, name );
                itemUI[ name + 2 ].visible = true;
                ge = rank % 10;
                shi = rank / 10;
                (itemUI[ name + 2 ].getChildByName( "ge" ) as Clip).index = ge;
                (itemUI[ name + 2 ].getChildByName( "shi" ) as Clip).index = shi;
            } else if ( rank < 1000 ) {
                showf( itemUI, name );
                itemUI[ name + 3 ].visible = true;
                ge = rank % 100 % 10;
                shi = rank % 100 / 10;
                bai = rank / 100;
                (itemUI[ name + 3 ].getChildByName( "ge" ) as Clip).index = ge;
                (itemUI[ name + 3 ].getChildByName( "shi" ) as Clip).index = shi;
                (itemUI[ name + 3 ].getChildByName( "bai" ) as Clip).index = bai;
            } else if ( rank < 2001 ) {
                showf( itemUI, name );
                itemUI[ name + 4 ].visible = true;
                ge = rank % 1000 % 100 % 10;
                shi = rank % 1000 % 100 / 10;
                bai = rank % 1000 / 100;
                qian = rank / 1000;
                (itemUI[ name + 4 ].getChildByName( "ge" ) as Clip).index = ge;
                (itemUI[ name + 4 ].getChildByName( "shi" ) as Clip).index = shi;
                (itemUI[ name + 4 ].getChildByName( "bai" ) as Clip).index = bai;
                (itemUI[ name + 4 ].getChildByName( "qian" ) as Clip).index = qian;
            } else {
                showf( itemUI, name );
                itemUI.b7.visible = true;
                itemUI.alink.visible = false;
            }
        }

        private function showf( itemUI : WBRewardItemUI, name : String ) : void {
            for ( var i : int = 1; i <= 4; i++ ) {
                itemUI[ name + i ].visible = false;
            }
            itemUI.b7.visible = false;
            itemUI.clip_rank.visible = false;
            itemUI.alink.visible = true;
        }

        private function showb() : void {

        }

        private function _renderSmallItem( item : Component, idx : int ) : void {
            var itemUI : RewardItemUI = item as RewardItemUI;
            var data : CRewardData = item.dataSource as CRewardData;
            if ( !data )return;
            itemUI.bg_clip.index = data.quality;
            itemUI.icon_image.url = data.iconSmall;
            itemUI.num_lable.text = data.num + "";
            itemUI.box_eff.visible = data.effect;

            var goods : GoodsItemUI = new GoodsItemUI();
            goods.img.url = data.iconBig;
            var bagData : CBagData = _wbDataManager.getItemNuForBag( data.ID );
            if ( bagData ) {
                goods.txt.text = bagData.num + "";
            } else {
                goods.txt.text = "0";
            }
            itemUI.toolTip = new Handler( _showItemTips, [ goods, data.ID, data.num ] );
        }

        private function _showItemTips( goods : GoodsItemUI, id : int, itemNum : int ) : void {
            _wbTips.showItemTips( goods, _getItemTableData( id ), _getItemData( id ),itemNum );
        }

        private function _getItemTableData( itemID : int ) : Item {
            var itemTable : CDataTable;
            var pDatabaseSystem : CDatabaseSystem = _appSystem.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            itemTable = pDatabaseSystem.getTable( KOFTableConstants.ITEM ) as CDataTable;
            return itemTable.findByPrimaryKey( itemID );
        }

        private function _getItemData( itemID : int ) : CItemData {
            var itemData : CItemData = (_appSystem.stage.getSystem( CItemSystem ) as CItemSystem).getItem( itemID );
            return itemData;
        }

        public function show() : void {
            _uiContainer.addPopupDialog( _wbDamageRankRewardUI );
        }
    }
}
