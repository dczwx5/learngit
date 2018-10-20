//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/7/1.
 * Time: 12:10
 */
package kof.game.currency.tipview {

    import kof.game.common.CLang;
    import kof.game.item.CItemData;
    import kof.table.Item;
    import kof.ui.imp_common.ItemTipsUI;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/7/1
     */
    public class CQQTipsView {
        private var _itemTipsUI : ItemTipsUI = null;
        public function CQQTipsView() {
            _itemTipsUI = new ItemTipsUI();
        }

        public function showQQItemTips( itemNu : int, itemTableData : Item, itemData : CItemData ) : void {
            _itemTipsUI.mc_item.img.url = itemTableData.bigiconURL + ".png";
            _itemTipsUI.mc_item.txt_num.text = "";
            _itemTipsUI.mc_item.clip_bg.index = itemTableData.quality;
            _itemTipsUI.txt_name.text = itemData.nameWithColor;
            _itemTipsUI.txt_type.text = getItemType( itemTableData.typeDisplay );
            _itemTipsUI.txt_num.text = CLang.Get( "item_has_num", {v1 : itemNu} );
            _itemTipsUI.txt_cont.text = itemTableData.usageDescription;
            if ( itemTableData.canSell ) {
                _itemTipsUI.txt_price.text = CLang.Get( "item_sell_price", {v1 : itemTableData.sellPrice} );
            } else {
                _itemTipsUI.txt_price.text = CLang.Get( "item_can_not_sell" );
            }
            _itemTipsUI.box_priceT.visible = itemTableData.canSell;
            _itemTipsUI.box_priceT.x = _itemTipsUI.txt_price.x + (_itemTipsUI.txt_price.width - _itemTipsUI.txt_price.textField.textWidth)
            - _itemTipsUI.box_priceT.width - 10;
            App.tip.addChild( _itemTipsUI );
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
