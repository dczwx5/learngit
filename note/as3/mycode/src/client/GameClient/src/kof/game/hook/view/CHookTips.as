//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/7/21.
 * Time: 17:44
 */
package kof.game.hook.view {

    import kof.game.common.CLang;
    import kof.game.common.CRewardUtil;
    import kof.game.hook.CHookClientFacade;
    import kof.game.item.CItemData;
    import kof.game.item.data.CRewardData;
    import kof.game.item.data.CRewardListData;
    import kof.table.Item;
    import kof.ui.imp_common.ItemTipsUI;
    import kof.ui.master.Hook.HookTipsUI;
    import kof.ui.master.JueseAndEqu.RolePieceItemUI;
    import kof.ui.master.messageprompt.GoodsItemUI;

    import morn.core.components.Component;
    import morn.core.handlers.Handler;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/7/21
     */
    public class CHookTips {
        private var _pHookTips : HookTipsUI = null;
        private var _ItemTipsUI : ItemTipsUI = null;

        public function CHookTips() {
            _pHookTips = new HookTipsUI();
            _pHookTips.itemList.renderHandler = new Handler( _renderItem );
            _ItemTipsUI = new ItemTipsUI();
        }

        private function _renderItem( item : Component, idx : int ) : void {
            var itemUI : RolePieceItemUI = item as RolePieceItemUI;
            var rewardData : CRewardData = itemUI.dataSource as CRewardData;
            itemUI.icon_img.url = rewardData.iconSmall;

            var itemTable : Item = CHookClientFacade.instance.getItemForItemID( rewardData.ID );
            var itemNu : int = CHookClientFacade.instance.getItemNuForBag( rewardData.ID );
            var itemData : CItemData = CHookClientFacade.instance.getItemDataForItemID( rewardData.ID );
            itemUI.qualityClip.index = itemTable.quality;

        }

        public function showPreviewProp( dropPropId : int ) : void {
            var rewardListData : CRewardListData = CRewardUtil.createByDropPackageID( CHookClientFacade.instance.hookSystem.stage, dropPropId );
            var itemListArr : Array = rewardListData.list;
            _pHookTips.itemList.dataSource = itemListArr;
            App.tip.addChild( _pHookTips );
        }

        public function showItemTips( item : GoodsItemUI, itemTableData : Item, itemData : CItemData,itemNum :int = 0 ) : void {
            _ItemTipsUI.mc_item.img.url = item.img.url;
            _ItemTipsUI.mc_item.txt_num.text = "";
            _ItemTipsUI.mc_item.clip_bg.index = item.quality_clip.index;
            _ItemTipsUI.txt_name.text = itemData.nameWithColor;
            _ItemTipsUI.txt_type.text = getItemType( itemTableData.typeDisplay );
            _ItemTipsUI.txt_num.text = CLang.Get( "item_has_num", {v1 : item.txt.text} );
            _ItemTipsUI.txt_cont.text = itemTableData.usageDescription;
            _ItemTipsUI.mc_item.box_effect.visible = itemTableData.effect > 0 ? (itemTableData.extraEffect == 0 || itemNum >= itemTableData.extraEffect) : false;
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
    }
}
