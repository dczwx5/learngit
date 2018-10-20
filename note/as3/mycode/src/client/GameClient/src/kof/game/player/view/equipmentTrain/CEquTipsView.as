//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/5/13.
 * Time: 16:13
 */
package kof.game.player.view.equipmentTrain {

    import kof.data.CDataTable;
    import kof.data.CDatabaseSystem;
    import kof.data.KOFTableConstants;
    import kof.game.bag.data.CBagData;
    import kof.game.common.CLang;
    import kof.game.common.view.CRootView;
    import kof.game.item.CItemData;
    import kof.game.player.data.CHeroEquipData;
    import kof.table.Item;
    import kof.ui.IUICanvas;
    import kof.ui.imp_common.ItemTipsUI;
    import kof.ui.imp_common.ItemUIUI;
    import kof.ui.master.Equipment.EquTips2UI;
    import kof.ui.master.Equipment.EquTipsUI;
    import kof.ui.master.JueseAndEqu.EquItemUI;
    import kof.ui.master.messageprompt.GoodsItemUI;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/5/13
     */
    public class CEquTipsView {
        private var _tipsUI : EquTips2UI = null;
        private var _materialTipsUI : ItemTipsUI = null;

        public function CEquTipsView() {
            _tipsUI = new EquTips2UI();
            _materialTipsUI = new ItemTipsUI();
        }

        public function showEquiTips( item : EquItemUI, equiData : CHeroEquipData, arr : Array = null ) : void {
            _tipsUI.nameTxt.text = item.name_label.text;
            _tipsUI.lvTxt.text = CLang.Get( "player_level" ) + ":" + equiData.level + "/" + equiData.levelLimit;

            _tipsUI.descriptionTxt.text = equiData.eqpdis + "";
//            if ( equiData.isExclusive ) {
//                _tipsUI.exclusiveTxt.visible = true;
//            } else {
//                _tipsUI.exclusiveTxt.visible = false;
//            }
            var itemUI : ItemUIUI = _tipsUI.mc_item;
            itemUI.txt_num.text = "";
            var imgUrl : String = item.icon_img.url.replace( "small", "big" );
            itemUI.img.url = imgUrl;
            itemUI.clip_bg.index = item.quality_clip.index;
            itemUI.box_effect.visible = false;//装备没有配置扫光字段
            _tipsUI.list_star.repeatX = item.star_list.repeatX;
            _tipsUI.list_star.centerX = item.star_list.centerX;
            _tipsUI.list_star.dataSource = item.star_list.dataSource;
            if ( arr ) {
                for ( var i : int = 0; i < arr.length; i++ ) {
                    _tipsUI[ "pro" + (i + 1) ].text = arr[ i ].name + "：+" + arr[ i ].value;
                }
                if ( arr.length == 1 ) {
                    _tipsUI.pro2.visible = false;
                } else {
                    _tipsUI.pro2.visible = true;
                }
            }
            App.tip.addChild( _tipsUI );
        }

        public function showEquiMaterialTips( item : GoodsItemUI, itemTableData : Item, itemData : CItemData ) : void {
            _materialTipsUI.mc_item.img.url = itemData.iconBig;
            _materialTipsUI.mc_item.txt_num.text = "";
            _materialTipsUI.mc_item.clip_bg.index = item.quality_clip.index;
            _materialTipsUI.txt_name.text = itemData.nameWithColor;
            _materialTipsUI.txt_type.text = getItemType( itemTableData.typeDisplay );
            _materialTipsUI.txt_num.text = CLang.Get( "item_has_num", {v1 : item.txt.text} );
            _materialTipsUI.txt_cont.text = itemTableData.usageDescription;
            _materialTipsUI.mc_item.box_effect.visible = itemTableData.effect > 0 ? (itemTableData.extraEffect == 0 || int(item.txt.text) >= itemTableData.extraEffect) : false;
            if ( itemTableData.canSell ) {
                _materialTipsUI.txt_price.text = CLang.Get( "item_sell_price", {v1 : itemTableData.sellPrice} );
            }
            else {
                _materialTipsUI.txt_price.text = CLang.Get( "item_can_not_sell" );
            }
            _materialTipsUI.box_priceT.visible = itemTableData.canSell;
            _materialTipsUI.box_priceT.x = _materialTipsUI.txt_price.x + (_materialTipsUI.txt_price.width - _materialTipsUI.txt_price.textField.textWidth)
                    - _materialTipsUI.box_priceT.width - 10;
            App.tip.addChild( _materialTipsUI );
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
