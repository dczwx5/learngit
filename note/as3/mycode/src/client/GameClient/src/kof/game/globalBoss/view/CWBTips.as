//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/7/29.
 * Time: 10:51
 */
package kof.game.globalBoss.view {

    import kof.data.CDataTable;
    import kof.framework.CAppSystem;
    import kof.game.common.CLang;
    import kof.game.globalBoss.datas.CWBDataManager;
    import kof.game.item.CItemData;
    import kof.game.item.data.CRewardData;
    import kof.game.item.data.CRewardListData;
    import kof.game.player.data.CPlayerData;
    import kof.table.Item;
    import kof.table.VipLevel;
    import kof.table.VipPrivilege;
    import kof.ui.imp_common.ItemTipsUI;
    import kof.ui.imp_common.RewardItemUI;
import kof.ui.imp_common.RewardTipsItemUI;
import kof.ui.master.JueseAndEqu.RolePieceItemUI;
    import kof.ui.master.WorldBoss.WBTipsUI;
    import kof.ui.master.messageprompt.GoodsItemUI;

    import morn.core.components.Box;
    import morn.core.components.Clip;

    import morn.core.components.Component;
    import morn.core.components.Label;

    import morn.core.components.TextArea;
    import morn.core.handlers.Handler;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/7/29
     */
    public class CWBTips {
        private var _ItemTipsUI : ItemTipsUI = null;
        private var _tips : WBTipsUI = null;
        private var _appSystem : CAppSystem = null;

        public function CWBTips() {
            _ItemTipsUI = new ItemTipsUI();
            _tips = new WBTipsUI();
            _tips.itemList.renderHandler = new Handler( _renderItem );
        }

        public function set appSystem( value : CAppSystem ) : void {
            _appSystem = value;
        }

        public function showItemTips( item : GoodsItemUI, itemTableData : Item, itemData : CItemData, itemNum : int = 0 ) : void {
            _ItemTipsUI.mc_item.img.url = item.img.url;
            _ItemTipsUI.mc_item.txt_num.text = "";
            _ItemTipsUI.mc_item.clip_bg.index = item.quality_clip.index;
            _ItemTipsUI.txt_name.text = itemData.nameWithColor;
            _ItemTipsUI.txt_type.text = getItemType( itemTableData.typeDisplay );
            _ItemTipsUI.mc_item.clip_bg.index = itemTableData.quality;
            _ItemTipsUI.mc_item.box_effect.visible = itemTableData.effect > 0 ? (itemTableData.extraEffect == 0 || itemNum >= itemTableData.extraEffect) : false;
            var itemNu : int = int( item.txt.text );
            itemNu = _judgeCurrencyType( itemTableData.type, itemNu );
            _ItemTipsUI.txt_num.text = CLang.Get( "item_has_num", {v1 : itemNu} );
            _ItemTipsUI.txt_cont.text = itemTableData.usageDescription;
            if ( itemTableData.canSell ) {
                _ItemTipsUI.txt_price.text = CLang.Get( "item_sell_price", {v1 : itemTableData.sellPrice} );
            }
            else {
                _ItemTipsUI.txt_price.text = CLang.Get( "item_can_not_sell" );
            }
            _ItemTipsUI.box_priceT.visible = itemTableData.canSell;
            _ItemTipsUI.box_priceT.x = _ItemTipsUI.txt_price.x + (_ItemTipsUI.txt_price.width - _ItemTipsUI.txt_price.textField.textWidth)
                    - _ItemTipsUI.box_priceT.width - 10;
            App.tip.addChild( _ItemTipsUI );
        }

        private function getItemType( index : int ) : String {
            if ( index == 1 ) {
                return "[" + CLang.Get( "item_page_1" ) + "]";
            } else if ( index == 2 ) {
                return "[" + CLang.Get( "item_page_2" ) + "]";
            } else if ( index == 3 ) {
                return "[" + CLang.Get( "item_page_3" ) + "]";
            }
            else {
                return "[" + CLang.Get( "item_page_4" ) + "]";
            }
        }

        private function _judgeCurrencyType( type : Number, itemNu : Number ) : Number {
            var playerData : CPlayerData = (_appSystem.getBean( CWBDataManager ) as CWBDataManager).playerData;
            switch ( type ) {
                case 1://金币
                    return playerData.currency.gold;
                case 2://绑钻
                    return playerData.currency.purpleDiamond;
                case 13://神器能量
                    return playerData.currency.artifactEnergy;
                default:
                    return itemNu;
            }
        }

        /**
         * @param type 1金币鼓舞 2钻石鼓舞
         * */
        public function showInspire( type : int, price : int, addAttack : int, countNu : String ) : void {
            _tips.showRule.visible = false;
            _tips.vipShow.visible = false;
            _tips.treasureBox.visible = false;
            if ( type == 1 ) {
                _tips.goldCost.text = CLang.Get("costGoldInspire",{v1:price});
                _tips.diamondBox.visible = false;
                _tips.goldBox.visible = true;
                _tips.addLabel.text = addAttack + "%";
                _tips.nuLabel.text = countNu;
            } else if ( type == 2 ) {
                _tips.diamondCost.text = CLang.Get("costDiamondInspire",{v1:price});
                _tips.diamondBox.visible = true;
                _tips.goldBox.visible = false;
                _tips.bAddLabel.text = addAttack + "%";
                _tips.dNuLabel.text = countNu;
            }
            App.tip.addChild( _tips );
        }

        public function showRule() : void {
            _tips.showRule.visible = true;
            _tips.diamondBox.visible = false;
            _tips.goldBox.visible = false;
            _tips.vipShow.visible = false;
            _tips.treasureBox.visible = false;
            var txtArea : TextArea = _tips.txtArea;
            txtArea.text = CLang.Get( "worldbossRule" );
            txtArea.height = txtArea.textField.textHeight + 20;
            _tips.bg.height = txtArea.height;
            App.tip.addChild( _tips );
        }

        private var _viplevel : CDataTable = null;

        public function showVip( vipPrivilegeTable : CDataTable ) : void {
            this._viplevel = vipPrivilegeTable;
            _tips.showRule.visible = false;
            _tips.diamondBox.visible = false;
            _tips.goldBox.visible = false;
            _tips.vipShow.visible = true;
            _tips.treasureBox.visible = false;
            _tips.vipList.renderHandler = new Handler( _renderVipItem );
            _tips.vipList.dataSource = vipPrivilegeTable.toArray();
            App.tip.addChild( _tips );
        }

        private function _renderVipItem( item : Component, idx : int ) : void {
            var itemUI : Box = item as Box;
            (itemUI.getChildByName( "clip" ) as Clip).index = idx;
            var data : VipPrivilege = item.dataSource as VipPrivilege;
            (itemUI.getChildByName( "label" ) as Label).text = CLang.Get("countAdd") + data.treasureCount + "";
        }

        public function showTreasureTotalCountReward( rewardListData : CRewardListData, canget : Boolean, totalNu : int ) : void {
            _tips.treasureBox.visible = true;
            _tips.showRule.visible = false;
            _tips.diamondBox.visible = false;
            _tips.goldBox.visible = false;
            _tips.vipShow.visible = false;
            var itemListArr : Array = rewardListData.list;
            _tips.itemList.dataSource = itemListArr;
            _tips.itemList.repeatX = itemListArr.length;
            _tips.itemList.centerX = 0;
            _tips.tips_txt.text = CLang.Get("treasureGetReward",{v1:totalNu});
            App.tip.addChild( _tips );
            _tips.reward_status2_img.visible=false;
            _tips.reward_status0_img.visible=false;
            if ( canget ) {
                _tips.reward_status1_img.visible = true;
                _tips.reward_status3_img.visible = false;
            } else {
                _tips.reward_status1_img.visible = false;
                _tips.reward_status3_img.visible = true;
            }
        }

        private function _renderItem( item : Component, idx : int ) : void {
            var itemUI : RewardTipsItemUI = item as RewardTipsItemUI;
            var rewardData : CRewardData = itemUI.dataSource as CRewardData;
            if ( !rewardData )return;
            itemUI.icon_image.url = rewardData.iconSmall;
            itemUI.bg_clip.index = rewardData.quality;
            itemUI.num_lable.text = rewardData.num + "";
            itemUI.name_txt.text = rewardData.nameWithColor;
        }
    }
}
