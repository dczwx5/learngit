//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2017/4/24.
 * Time: 19:45
 */
package kof.game.player.view.playerNew.view.equipDevelop {

    import flash.events.Event;

    import kof.data.CDataTable;
    import kof.data.CDatabaseSystem;
    import kof.data.KOFTableConstants;
    import kof.game.bag.data.CBagData;
    import kof.game.common.CLang;
    import kof.game.item.CItemData;
    import kof.game.item.CItemSystem;
    import kof.game.itemGetPath.CItemGetSystem;
    import kof.game.player.data.CHeroEquipData;
    import kof.game.player.view.equipmentTrain.*;
    import kof.game.player.view.playerNew.panel.CEquipDevelopPanel;
    import kof.table.Item;
    import kof.ui.CUISystem;
    import kof.ui.demo.Bag.QualityBoxUI;
    import kof.ui.master.Equipment.EqusuccesstoneUI;
    import kof.ui.master.messageprompt.GoodsItemUI;

    import morn.core.components.Button;
    import morn.core.components.Dialog;
    import morn.core.components.Image;
    import morn.core.components.Label;
    import morn.core.handlers.Handler;

    public class CEqustoneView {
        private var _stoneNuArr : Vector.<CBagData> = new Vector.<CBagData>();

        private var _tipsView : CEquTipsView = null;
        private var ui : EqusuccesstoneUI = null;
        private var _pPanel : CEquipDevelopPanel = null;

        public function CEqustoneView( panel : CEquipDevelopPanel ) {
            this._pPanel = panel;
            _tipsView = new CEquTipsView();
            ui = new EqusuccesstoneUI();
            ui.okbtn.clickHandler = new Handler( _okBtn );
            ui.close_btn.clickHandler = new Handler( _onClose );
        }

        public function show() : void {
            _pPanel.uiCanvas.addPopupDialog( ui );
            updateWindow();
        }

        private function _okBtn() : void {
            var index : int = 0;
            if ( (ui.box1.getChildByName( "item1" ) as QualityBoxUI).img_selected.visible ) {
                index = 1;
            }
            if ( (ui.box2.getChildByName( "item2" ) as QualityBoxUI).img_selected.visible ) {
                index = 2;
            }
            if ( (ui.box3.getChildByName( "item3" ) as QualityBoxUI).img_selected.visible ) {
                index = 3;
            }
            if ( index == 0 ) {
                (_pPanel.system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( CLang.Get( "wishStoneSelectTips" ) );
            } else {
                _onClose();
            }
        }

        public function updateWindow() : void {
            for ( var i : int = 1; i < 4; i++ ) {
                (ui[ "box" + i ].getChildByName( "item" + i ) as QualityBoxUI).img_selected.visible = false;
            }
            _showStone();
        }

        private function _showEquMaterialTips( item : GoodsItemUI, itemID : int ) : void {
            _tipsView.showEquiMaterialTips( item, _getItemTableData( itemID ), _getItemData( itemID ) );
        }

        private function _getItemData( itemID : int ) : CItemData {
            var itemData : CItemData = _pPanel.getItemData( itemID );
            return itemData;
        }

        private function _getItemTableData( itemID : int ) : Item {
            var itemTable : CDataTable;
            var pDatabaseSystem : CDatabaseSystem = _pPanel.system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            itemTable = pDatabaseSystem.getTable( KOFTableConstants.ITEM ) as CDataTable;
            return itemTable.findByPrimaryKey( itemID );
        }

        private function _showStone() : void {
            var itemSystem : CItemSystem = (_pPanel.system.stage.getSystem( CItemSystem ) as CItemSystem);
            var wishStoneData1 : CBagData = _pPanel.bagManager.getBagItemByUid( CHeroEquipData.LOW_WISH_STONE_ID ); //当前拥有低级祝福石
            var wishStoneData2 : CBagData = _pPanel.bagManager.getBagItemByUid( CHeroEquipData.MIDDLE_WISH_STONE_ID ); //当前拥有低级祝福石
            var wishStoneData3 : CBagData = _pPanel.bagManager.getBagItemByUid( CHeroEquipData.HIGH_WISH_STONE_ID ); //当前拥有低级祝福石
            var goodsItem : GoodsItemUI = null;
            var itemID : int = 0;
            var stoneNu : int = 0;
            if ( wishStoneData1 ) {
                if ( _selectStoneIndex == 1 ) {
                    stoneNu = wishStoneData1.num - 1;
                } else {
                    stoneNu = wishStoneData1.num;
                }
                (ui.box1.getChildByName( "item1" ) as QualityBoxUI).img.url = itemSystem.getItem( CHeroEquipData.LOW_WISH_STONE_ID ).iconBig;
                (ui.box1.getChildByName( "item1" ) as QualityBoxUI).clip_bg.index = _pPanel.getItemData( CHeroEquipData.LOW_WISH_STONE_ID ).quality;
                (ui.box1.getChildByName( "item1" ) as QualityBoxUI).txt_num.text = stoneNu + "";
                (ui.box1.getChildByName( "name1" ) as Label).text = itemSystem.getItem( CHeroEquipData.LOW_WISH_STONE_ID ).name;
                (ui.box1.getChildByName( "des1" ) as Label).text = itemSystem.getItem( CHeroEquipData.LOW_WISH_STONE_ID ).desc;
                if ( stoneNu != 0 ) {
                    (ui.box1.getChildByName( "btn1" ) as Button).clickHandler = new Handler( _selectStone, [ (ui.box1.getChildByName( "btn1" ) as Button).name ] );
                } else {
                    (ui.box1.getChildByName( "btn1" ) as Button).clickHandler = new Handler( _getStonePath, [ CHeroEquipData.LOW_WISH_STONE_ID ] );
                }
                itemID = wishStoneData1.itemID;
            }
            else {
                (ui.box1.getChildByName( "item1" ) as QualityBoxUI).img.url = itemSystem.getItem( CHeroEquipData.LOW_WISH_STONE_ID ).iconBig;
                (ui.box1.getChildByName( "item1" ) as QualityBoxUI).clip_bg.index = _pPanel.getItemData( CHeroEquipData.LOW_WISH_STONE_ID ).quality;
                (ui.box1.getChildByName( "item1" ) as QualityBoxUI).txt_num.text = 0 + "";
                (ui.box1.getChildByName( "name1" ) as Label).text = itemSystem.getItem( CHeroEquipData.LOW_WISH_STONE_ID ).name;
                (ui.box1.getChildByName( "des1" ) as Label).text = itemSystem.getItem( CHeroEquipData.LOW_WISH_STONE_ID ).desc;
                (ui.box1.getChildByName( "btn1" ) as Button).clickHandler = new Handler( _getStonePath, [ CHeroEquipData.LOW_WISH_STONE_ID ] );
                itemID = CHeroEquipData.LOW_WISH_STONE_ID;
//                (ui.box1.getChildByName( "btn1" ) as Button).clickHandler = new Handler( _selectStone, [ (ui.box1.getChildByName( "btn1" ) as Button).name ] );
                //石头来源
            }
            (ui.box1.getChildByName( "item1" ) as QualityBoxUI).box_eff.visible = itemSystem.getItem( CHeroEquipData.LOW_WISH_STONE_ID ).effect;
            goodsItem = new GoodsItemUI();
            goodsItem.quality_clip.index = (ui.box1.getChildByName( "item1" ) as QualityBoxUI).clip_bg.index;
            goodsItem.img.url = (ui.box1.getChildByName( "item1" ) as QualityBoxUI).img.url;
            goodsItem.txt.text = (ui.box1.getChildByName( "item1" ) as QualityBoxUI).txt_num.text;
            ui.box1.toolTip = new Handler( _showEquMaterialTips, [ goodsItem, itemID ] );
            if ( wishStoneData2 ) {
                if ( _selectStoneIndex == 2 ) {
                    stoneNu = wishStoneData2.num - 1;
                } else {
                    stoneNu = wishStoneData2.num;
                }
                (ui.box2.getChildByName( "item2" ) as QualityBoxUI).img.url = itemSystem.getItem( CHeroEquipData.MIDDLE_WISH_STONE_ID ).iconBig;
                (ui.box2.getChildByName( "item2" ) as QualityBoxUI).clip_bg.index = _pPanel.getItemData( CHeroEquipData.MIDDLE_WISH_STONE_ID ).quality;
                (ui.box2.getChildByName( "item2" ) as QualityBoxUI).txt_num.text = stoneNu + "";
                (ui.box2.getChildByName( "name2" ) as Label).text = itemSystem.getItem( CHeroEquipData.MIDDLE_WISH_STONE_ID ).name;
                (ui.box2.getChildByName( "des2" ) as Label).text = itemSystem.getItem( CHeroEquipData.MIDDLE_WISH_STONE_ID ).desc;
                if ( stoneNu != 0 ) {
                    (ui.box2.getChildByName( "btn2" ) as Button).clickHandler = new Handler( _selectStone, [ (ui.box2.getChildByName( "btn2" ) as Button).name ] );
                } else {
                    (ui.box2.getChildByName( "btn2" ) as Button).clickHandler = new Handler( _getStonePath, [ CHeroEquipData.MIDDLE_WISH_STONE_ID ] );
                }
                itemID = wishStoneData2.itemID;
            }
            else {
                (ui.box2.getChildByName( "item2" ) as QualityBoxUI).img.url = itemSystem.getItem( CHeroEquipData.MIDDLE_WISH_STONE_ID ).iconBig;
                (ui.box2.getChildByName( "item2" ) as QualityBoxUI).clip_bg.index = _pPanel.getItemData( CHeroEquipData.MIDDLE_WISH_STONE_ID ).quality;
                (ui.box2.getChildByName( "item2" ) as QualityBoxUI).txt_num.text = 0 + "";
                (ui.box2.getChildByName( "name2" ) as Label).text = itemSystem.getItem( CHeroEquipData.MIDDLE_WISH_STONE_ID ).name;
                (ui.box2.getChildByName( "des2" ) as Label).text = itemSystem.getItem( CHeroEquipData.MIDDLE_WISH_STONE_ID ).desc;
                (ui.box2.getChildByName( "btn2" ) as Button).clickHandler = new Handler( _getStonePath, [ CHeroEquipData.MIDDLE_WISH_STONE_ID ] );
                itemID = CHeroEquipData.MIDDLE_WISH_STONE_ID;
            }
            (ui.box2.getChildByName( "item2" ) as QualityBoxUI).box_eff.visible = itemSystem.getItem( CHeroEquipData.MIDDLE_WISH_STONE_ID ).effect;
            goodsItem = new GoodsItemUI();
            goodsItem.quality_clip.index = (ui.box2.getChildByName( "item2" ) as QualityBoxUI).clip_bg.index;
            goodsItem.img.url = (ui.box2.getChildByName( "item2" ) as QualityBoxUI).img.url;
            goodsItem.txt.text = (ui.box2.getChildByName( "item2" ) as QualityBoxUI).txt_num.text;
            ui.box2.toolTip = new Handler( _showEquMaterialTips, [ goodsItem, itemID ] );
            if ( wishStoneData3 ) {
                if ( _selectStoneIndex == 3 ) {
                    stoneNu = wishStoneData3.num - 1;
                } else {
                    stoneNu = wishStoneData3.num;
                }
                (ui.box3.getChildByName( "item3" ) as QualityBoxUI).img.url = itemSystem.getItem( CHeroEquipData.HIGH_WISH_STONE_ID ).iconBig;
                (ui.box3.getChildByName( "item3" ) as QualityBoxUI).clip_bg.index = _pPanel.getItemData( CHeroEquipData.HIGH_WISH_STONE_ID ).quality;
                (ui.box3.getChildByName( "item3" ) as QualityBoxUI).txt_num.text = stoneNu + "";
                (ui.box3.getChildByName( "name3" ) as Label).text = itemSystem.getItem( CHeroEquipData.HIGH_WISH_STONE_ID ).name;
                (ui.box3.getChildByName( "des3" ) as Label).text = itemSystem.getItem( CHeroEquipData.HIGH_WISH_STONE_ID ).desc;
                if ( stoneNu != 0 ) {
                    (ui.box3.getChildByName( "btn3" ) as Button).clickHandler = new Handler( _selectStone, [ (ui.box3.getChildByName( "btn3" ) as Button).name ] );
                } else {
                    (ui.box3.getChildByName( "btn3" ) as Button).clickHandler = new Handler( _getStonePath, [ CHeroEquipData.HIGH_WISH_STONE_ID ] );
                }
                itemID = wishStoneData3.itemID;
            }
            else {
                (ui.box3.getChildByName( "item3" ) as QualityBoxUI).img.url = itemSystem.getItem( CHeroEquipData.HIGH_WISH_STONE_ID ).iconBig;
                (ui.box3.getChildByName( "item3" ) as QualityBoxUI).clip_bg.index = _pPanel.getItemData( CHeroEquipData.HIGH_WISH_STONE_ID ).quality;
                (ui.box3.getChildByName( "item3" ) as QualityBoxUI).txt_num.text = 0 + "";
                (ui.box3.getChildByName( "name3" ) as Label).text = itemSystem.getItem( CHeroEquipData.HIGH_WISH_STONE_ID ).name;
                (ui.box3.getChildByName( "des3" ) as Label).text = itemSystem.getItem( CHeroEquipData.HIGH_WISH_STONE_ID ).desc;
                (ui.box3.getChildByName( "btn3" ) as Button).clickHandler = new Handler( _getStonePath, [ CHeroEquipData.HIGH_WISH_STONE_ID ] );
                itemID = CHeroEquipData.HIGH_WISH_STONE_ID;
            }
            (ui.box3.getChildByName( "item3" ) as QualityBoxUI).box_eff.visible = itemSystem.getItem( CHeroEquipData.HIGH_WISH_STONE_ID ).effect;
            goodsItem = new GoodsItemUI();
            goodsItem.quality_clip.index = (ui.box3.getChildByName( "item3" ) as QualityBoxUI).clip_bg.index;
            goodsItem.img.url = (ui.box3.getChildByName( "item3" ) as QualityBoxUI).img.url;
            goodsItem.txt.text = (ui.box3.getChildByName( "item3" ) as QualityBoxUI).txt_num.text;
            ui.box3.toolTip = new Handler( _showEquMaterialTips, [ goodsItem, itemID ] );
        }

        private function _selectStone( btnName : String ) : void {
            for ( var i : int = 1; i < 4; i++ ) {
                (ui[ "box" + i ].getChildByName( "item" + i ) as QualityBoxUI).img_selected.visible = false;
            }
            var index : String = btnName.substr( -1, 1 );
            var img : Image = (ui[ "box" + index ].getChildByName( "item" + index ) as QualityBoxUI).img_selected;
            img.visible = true;
            _onClose();
        }

        private function _getStonePath( id : Number ) : void {
            (_pPanel.system.stage.getSystem( CItemGetSystem ) as CItemGetSystem).showItemGetPath( id, _onClose );
        }

        private function _onClose() : void {
            var index : int = 0;
            if ( (ui.box1.getChildByName( "item1" ) as QualityBoxUI).img_selected.visible ) {
                index = 1;
            }
            if ( (ui.box2.getChildByName( "item2" ) as QualityBoxUI).img_selected.visible ) {
                index = 2;
            }
            if ( (ui.box3.getChildByName( "item3" ) as QualityBoxUI).img_selected.visible ) {
                index = 3;
            }

            _selectStoneIndex = index;
            _stoneNuArr.splice( 0, _stoneNuArr.length );
            ui.close( Dialog.CLOSE );
            _pPanel.dispatchEvent( new Event( CEquipDevelopPanel.UPDATE_STONE ) );
        }

        private var _selectStoneIndex : int = 0;

        public function get selectStoneIndex() : int {
            return _selectStoneIndex;
        }

        public function set selectStoneIndex( value : int ) : void {
            _selectStoneIndex = value;
        }
    }
}
