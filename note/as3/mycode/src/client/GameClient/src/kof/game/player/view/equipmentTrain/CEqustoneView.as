//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2017/4/24.
 * Time: 19:45
 */
package kof.game.player.view.equipmentTrain {

import kof.data.CDataTable;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.game.bag.data.CBagData;
import kof.game.common.view.CRootView;
import kof.game.common.view.event.CViewEvent;
import kof.game.item.CItemData;
import kof.game.item.CItemSystem;
import kof.game.player.data.CHeroEquipData;
import kof.game.player.view.event.EPlayerViewEventType;
import kof.table.Item;
import kof.ui.CUISystem;
import kof.ui.demo.Bag.QualityBoxUI;
import kof.ui.master.Equipment.EqusuccesstoneUI;
import kof.ui.master.messageprompt.GoodsItemUI;

import morn.core.components.Button;
import morn.core.components.Image;
import morn.core.components.Label;
import morn.core.handlers.Handler;

public class CEqustoneView extends CRootView {
        private var _stoneCount : int = 0;
        private var _stoneNuArr : Vector.<CBagData> = new Vector.<CBagData>();

        private var _tipsView : CEquTipsView = null;

        public function CEqustoneView() {
            super( EqusuccesstoneUI, null, null, false );
            _tipsView = new CEquTipsView();
        }

        protected override function _onDispose() : void {
            _stoneNuArr = null;
            _tipsView = null;
        }

        protected override function _onHide() : void {
            super._onHide();
            var ui : EqusuccesstoneUI = rootUI as EqusuccesstoneUI;
            ui.okbtn.clickHandler = null;
        }

        protected override function _onShow() : void {
            super._onShow();
            var ui : EqusuccesstoneUI = rootUI as EqusuccesstoneUI;
            ui.okbtn.clickHandler = new Handler( _okBtn );
        }

        private function _okBtn() : void {
            var ui : EqusuccesstoneUI = rootUI as EqusuccesstoneUI;
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
                ((uiCanvas as CAppSystem).stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( "祝福石能够提升觉醒概率，还是先选一个吧!" );
            }
            else {
                close();
            }
        }

        public override function updateWindow() : Boolean {
            if ( super.updateWindow() == false ) return false;
            var ui : EqusuccesstoneUI = rootUI as EqusuccesstoneUI;
            for ( var i : int = 1; i < 4; i++ ) {
                (ui[ "box" + i ].getChildByName( "item" + i ) as QualityBoxUI).img_selected.visible = false;
            }
            if ( _data.type == EEquAssetsType.STONE ) {
                _showStone();
            }
            else if ( _data.type == EEquAssetsType.BADGE ) {
                _showBadge();
            }
            else if ( _data.type == EEquAssetsType.CHEATS ) {
                _showCheats();
            }

            this.addToPopupDialog();
            return true;
        }

        private function _showCheats() : void {

        }

        private function _showBadge() : void {
            var ui : EqusuccesstoneUI = rootUI as EqusuccesstoneUI;
            var itemSystem : CItemSystem = ((uiCanvas as CAppSystem).stage.getSystem( CItemSystem ) as CItemSystem);
            var itemVec : Vector.<int> = _data.equipData.nextLevelExtendsItemListCost;
            var arr : Array = [];
            var bagItemData : CBagData = null;
            for ( var i : int = 1; i < 4; i++ )   //后面记得改成itemVec.length
            {
                bagItemData = _data.bagManager.getBagItemByUid( itemVec[ i - 1 ] ); //当前拥有
                if ( bagItemData ) {
                    var itemID : int = itemVec[ i - 1 ];
//                    var itemData : CItemData = itemSystem.getItem( itemVec[ i ] );
//                    arr.push( {
//                        url : itemData.iconBig,
//                        num : bagItemData.num,
//                        itemID : itemVec[ i ],
//                        itemQunlity : itemData.quality
//                    } );

                    (ui[ "box" + i ].getChildByName( "item" + i ) as QualityBoxUI).img.url = itemSystem.getItem( itemID ).iconBig;
                    (ui[ "box" + i ].getChildByName( "item" + i ) as QualityBoxUI).txt_num.text = bagItemData.num + "";
                    (ui[ "box" + i ].getChildByName( "name" + i ) as Label).text = itemSystem.getItem( itemID ).name;
                    (ui[ "box" + i ].getChildByName( "des" + i ) as Label).text = itemSystem.getItem( itemID ).desc;
                    (ui[ "box" + i ].getChildByName( "btn" + i ) as Button).clickHandler = new Handler( _selectBadge, [ (ui[ "box" + i ].getChildByName( "btn" + i ) as Button).name ] );
                }
                else {
                    arr.push( {num : -1} );
                }

            }
        }

        private function _showEquMaterialTips( item : GoodsItemUI, itemID : int ) : void {
            _tipsView.showEquiMaterialTips( item, _getItemTableData( itemID ), _getItemData( itemID ) );
        }

        private function _getItemData( itemID : int ) : CItemData {
            var itemData : CItemData = ((uiCanvas as CAppSystem).stage.getSystem( CItemSystem ) as CItemSystem).getItem( itemID );
            return itemData;
        }

        private function _getItemTableData( itemID : int ) : Item {
            var itemTable : CDataTable;
            var pDatabaseSystem : CDatabaseSystem = (uiCanvas as CAppSystem).stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            itemTable = pDatabaseSystem.getTable( KOFTableConstants.ITEM ) as CDataTable;
            return itemTable.findByPrimaryKey( itemID );
        }

        private function _showStone() : void {
            var ui : EqusuccesstoneUI = rootUI as EqusuccesstoneUI;
            var itemSystem : CItemSystem = ((uiCanvas as CAppSystem).stage.getSystem( CItemSystem ) as CItemSystem);
            var wishStoneData1 : CBagData = _data.bagManager.getBagItemByUid( CHeroEquipData.LOW_WISH_STONE_ID ); //当前拥有低级祝福石
            var wishStoneData2 : CBagData = _data.bagManager.getBagItemByUid( CHeroEquipData.MIDDLE_WISH_STONE_ID ); //当前拥有低级祝福石
            var wishStoneData3 : CBagData = _data.bagManager.getBagItemByUid( CHeroEquipData.HIGH_WISH_STONE_ID ); //当前拥有低级祝福石
            var goodsItem : GoodsItemUI = null;
            var itemID : int = 0;
            if ( wishStoneData1 ) {
                (ui.box1.getChildByName( "item1" ) as QualityBoxUI).img.url = itemSystem.getItem( CHeroEquipData.LOW_WISH_STONE_ID ).iconBig;
                (ui.box1.getChildByName( "item1" ) as QualityBoxUI).txt_num.text = wishStoneData1.num + "";
                (ui.box1.getChildByName( "name1" ) as Label).text = itemSystem.getItem( CHeroEquipData.LOW_WISH_STONE_ID ).name;
                (ui.box1.getChildByName( "des1" ) as Label).text = itemSystem.getItem( CHeroEquipData.LOW_WISH_STONE_ID ).desc;
                (ui.box1.getChildByName( "btn1" ) as Button).clickHandler = new Handler( _selectStone, [ (ui.box1.getChildByName( "btn1" ) as Button).name ] );
                itemID = wishStoneData1.itemID;

            }
            else {
                (ui.box1.getChildByName( "item1" ) as QualityBoxUI).img.url = itemSystem.getItem( CHeroEquipData.LOW_WISH_STONE_ID ).iconBig;
                (ui.box1.getChildByName( "item1" ) as QualityBoxUI).txt_num.text = 0 + "";
                (ui.box1.getChildByName( "name1" ) as Label).text = itemSystem.getItem( CHeroEquipData.LOW_WISH_STONE_ID ).name;
                (ui.box1.getChildByName( "des1" ) as Label).text = itemSystem.getItem( CHeroEquipData.LOW_WISH_STONE_ID ).desc;
                itemID = CHeroEquipData.LOW_WISH_STONE_ID;
//                (ui.box1.getChildByName( "btn1" ) as Button).clickHandler = new Handler( _selectStone, [ (ui.box1.getChildByName( "btn1" ) as Button).name ] );
                //石头来源
            }
            goodsItem = new GoodsItemUI();
            goodsItem.quality_clip.index = (ui.box1.getChildByName( "item1" ) as QualityBoxUI).clip_bg.index;
            goodsItem.img.url = (ui.box1.getChildByName( "item1" ) as QualityBoxUI).img.url;
            goodsItem.txt.text = (ui.box1.getChildByName( "item1" ) as QualityBoxUI).txt_num.text;
            ui.box1.toolTip = new Handler( _showEquMaterialTips, [ goodsItem, itemID ] );
            if ( wishStoneData2 ) {
                (ui.box2.getChildByName( "item2" ) as QualityBoxUI).img.url = itemSystem.getItem( CHeroEquipData.MIDDLE_WISH_STONE_ID ).iconBig;
                (ui.box2.getChildByName( "item2" ) as QualityBoxUI).txt_num.text = wishStoneData2.num + "";
                (ui.box2.getChildByName( "name2" ) as Label).text = itemSystem.getItem( CHeroEquipData.MIDDLE_WISH_STONE_ID ).name;
                (ui.box2.getChildByName( "des2" ) as Label).text = itemSystem.getItem( CHeroEquipData.MIDDLE_WISH_STONE_ID ).desc;
                (ui.box2.getChildByName( "btn2" ) as Button).clickHandler = new Handler( _selectStone, [ (ui.box2.getChildByName( "btn2" ) as Button).name ] );
                itemID = wishStoneData2.itemID;
            }
            else {
                (ui.box2.getChildByName( "item2" ) as QualityBoxUI).img.url = itemSystem.getItem( CHeroEquipData.MIDDLE_WISH_STONE_ID ).iconBig;
                (ui.box2.getChildByName( "item2" ) as QualityBoxUI).txt_num.text = 0 + "";
                (ui.box2.getChildByName( "name2" ) as Label).text = itemSystem.getItem( CHeroEquipData.MIDDLE_WISH_STONE_ID ).name;
                (ui.box2.getChildByName( "des2" ) as Label).text = itemSystem.getItem( CHeroEquipData.MIDDLE_WISH_STONE_ID ).desc;
                itemID = CHeroEquipData.MIDDLE_WISH_STONE_ID;
            }
            goodsItem = new GoodsItemUI();
            goodsItem.quality_clip.index = (ui.box2.getChildByName( "item2" ) as QualityBoxUI).clip_bg.index;
            goodsItem.img.url = (ui.box2.getChildByName( "item2" ) as QualityBoxUI).img.url;
            goodsItem.txt.text = (ui.box2.getChildByName( "item2" ) as QualityBoxUI).txt_num.text;
            ui.box2.toolTip = new Handler( _showEquMaterialTips, [ goodsItem, itemID ] );
            if ( wishStoneData3 ) {
                (ui.box3.getChildByName( "item3" ) as QualityBoxUI).img.url = itemSystem.getItem( CHeroEquipData.HIGH_WISH_STONE_ID ).iconBig;
                (ui.box3.getChildByName( "item3" ) as QualityBoxUI).txt_num.text = wishStoneData3.num + "";
                (ui.box3.getChildByName( "name3" ) as Label).text = itemSystem.getItem( CHeroEquipData.HIGH_WISH_STONE_ID ).name;
                (ui.box3.getChildByName( "des3" ) as Label).text = itemSystem.getItem( CHeroEquipData.HIGH_WISH_STONE_ID ).desc;
                (ui.box3.getChildByName( "btn3" ) as Button).clickHandler = new Handler( _selectStone, [ (ui.box3.getChildByName( "btn3" ) as Button).name ] );
                itemID = wishStoneData3.itemID;
            }
            else {
                (ui.box3.getChildByName( "item3" ) as QualityBoxUI).img.url = itemSystem.getItem( CHeroEquipData.HIGH_WISH_STONE_ID ).iconBig;
                (ui.box3.getChildByName( "item3" ) as QualityBoxUI).txt_num.text = 0 + "";
                (ui.box3.getChildByName( "name3" ) as Label).text = itemSystem.getItem( CHeroEquipData.HIGH_WISH_STONE_ID ).name;
                (ui.box3.getChildByName( "des3" ) as Label).text = itemSystem.getItem( CHeroEquipData.HIGH_WISH_STONE_ID ).desc;
                itemID = CHeroEquipData.HIGH_WISH_STONE_ID;
            }
            goodsItem = new GoodsItemUI();
            goodsItem.quality_clip.index = (ui.box3.getChildByName( "item3" ) as QualityBoxUI).clip_bg.index;
            goodsItem.img.url = (ui.box3.getChildByName( "item3" ) as QualityBoxUI).img.url;
            goodsItem.txt.text = (ui.box3.getChildByName( "item3" ) as QualityBoxUI).txt_num.text;
            ui.box3.toolTip = new Handler( _showEquMaterialTips, [ goodsItem, itemID ] );

//            var stoneID : int = 0;
//            for ( var i : int = 1; i < _stoneCount + 1; i++ ) {
//                if ( i == 1 ) {
//                    stoneID = CHeroEquipData.LOW_WISH_STONE_ID;
//                }
//                else if ( i == 2 ) {
//                    stoneID = CHeroEquipData.MIDDLE_WISH_STONE_ID;
//                }
//                else if ( i == 3 ) {
//                    stoneID = CHeroEquipData.HIGH_WISH_STONE_ID;
//                }
//                (ui[ "box" + i ].getChildByName( "item" + i ) as QualityBoxUI).img.url = itemSystem.getItem( stoneID ).iconBig;
//                (ui[ "box" + i ].getChildByName( "item" + i ) as QualityBoxUI).txt_num.text = _stoneNuArr[ i - 1 ].num + "";
//                (ui[ "box" + i ].getChildByName( "name" + i ) as Label).text = itemSystem.getItem( stoneID ).name;
//                (ui[ "box" + i ].getChildByName( "des" + i ) as Label).text = itemSystem.getItem( stoneID ).desc;
//                (ui[ "box" + i ].getChildByName( "btn" + i ) as Button).clickHandler = new Handler( _selectStone, [ (ui[ "box" + i ].getChildByName( "btn" + i ) as Button).name ] );
//
//            }
//            if ( _stoneCount == 0 ) {
//                ui.box1.visible = false;
//                ui.box2.visible = false;
//                ui.box3.visible = false;
//            }
//            else if ( _stoneCount == 1 ) {
//                ui.box2.visible = false;
//                ui.box3.visible = false;
//            }
//            else if ( _stoneCount == 2 ) {
//                ui.box3.visible = false;
//            }
        }

        private function _selectBadge( btnName : String ) : void {
            var ui : EqusuccesstoneUI = rootUI as EqusuccesstoneUI;
            for ( var i : int = 1; i < 4; i++ ) {
                (ui[ "box" + i ].getChildByName( "item" + i ) as QualityBoxUI).img_selected.visible = false;
            }
            var index : String = btnName.substr( -1, 1 );
            var img : Image = (ui[ "box" + index ].getChildByName( "item" + index ) as QualityBoxUI).img_selected;
            img.visible = true;
        }

        private function _selectStone( btnName : String ) : void {
            var ui : EqusuccesstoneUI = rootUI as EqusuccesstoneUI;
            for ( var i : int = 1; i < 4; i++ ) {
                (ui[ "box" + i ].getChildByName( "item" + i ) as QualityBoxUI).img_selected.visible = false;
            }
            var index : String = btnName.substr( -1, 1 );
            var img : Image = (ui[ "box" + index ].getChildByName( "item" + index ) as QualityBoxUI).img_selected;
            img.visible = true;
            close();
        }

        override public function setData( value : Object, forceInvalid : Boolean = true ) : void {
            super.setData( value, forceInvalid );
        }

        override protected function _onClose() : void {
            var ui : EqusuccesstoneUI = rootUI as EqusuccesstoneUI;
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
            if ( _data.type == EEquAssetsType.STONE ) {
                this.rootView.dispatchEvent( new CViewEvent( CViewEvent.UI_EVENT, EPlayerViewEventType.EVENT_EQUIP_STONE, {id : index} ) );
            }
//            else if(_data.type==EEquAssetsType.BADGE)
//            {
//                this.rootView.dispatchEvent( new CViewEvent( CViewEvent.UI_EVENT, EPlayerViewEventType.EVENT_EQUIP_BADGE, {id : index} ) );
//            }
//            else if(_data.type==EEquAssetsType.CHEATS)
//            {
//                this.rootView.dispatchEvent( new CViewEvent( CViewEvent.UI_EVENT, EPlayerViewEventType.EVENT_EQUIP_CHEATS, {id : index} ) );
//            }
            _stoneCount = 0;
            _stoneNuArr.splice( 0, _stoneNuArr.length );
            super._onClose();
        }

    }
}
