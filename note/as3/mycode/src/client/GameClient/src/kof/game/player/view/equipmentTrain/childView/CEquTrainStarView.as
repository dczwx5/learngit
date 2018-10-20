//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/12/15.
 * Time: 14:38
 */
package kof.game.player.view.equipmentTrain.childView {

import kof.data.CDataTable;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.framework.IDataTable;
import kof.game.bag.CBagManager;
import kof.game.bag.data.CBagData;
import kof.game.common.view.CChildView;
import kof.game.common.view.event.CViewEvent;
import kof.game.item.CItemData;
import kof.game.item.CItemSystem;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CHeroEquipData;
import kof.game.player.data.CPlayerData;
import kof.game.player.enum.EPlayerWndTabType;
import kof.game.player.view.equipmentTrain.CEquTipsView;
import kof.game.player.view.equipmentTrain.CEquipmentTrainViewHandler;
import kof.game.player.view.equipmentTrain.EEquAssetsType;
import kof.game.player.view.equipmentTrain.EEquipPageType;
import kof.game.player.view.event.EPlayerViewEventType;
import kof.table.Item;
import kof.ui.master.Equipment.EquTrainUI;
import kof.ui.master.Equipment.EquTrainstarUI;
import kof.ui.master.messageprompt.GoodsItemUI;

import morn.core.components.Button;
import morn.core.handlers.Handler;

public class CEquTrainStarView extends CChildView {
        private var _dataTable : IDataTable = null;
        private var _bagManager : CBagManager = null;
        private var _currentIndex : int = 0;
        private var _currentStar : int = 0;
        private var _tipsView : CEquTipsView = null;

        private var _currentEquipId : Number = 0;
        private var _sendWishStoneList : Array = [];
        private var _stoneSuccessRate : Number = 0;

        private var _currentEquipData : CHeroEquipData = null;

        private var _isCanUpgrade : Boolean = true;

        public function CEquTrainStarView() {
            super();
            _tipsView = new CEquTipsView();
        }

        protected override function _onShow() : void {
            super._onShow();
            var ui : EquTrainUI = _ui;
            var equStar : EquTrainstarUI = ui.viewStack.getChildByName( "item1" ) as EquTrainstarUI;
            var upgradeBtn : Button = equStar.getChildByName( "upgrade" ) as Button;
            upgradeBtn.clickHandler = new Handler( _upgradeHandler );
            var stoneItem3Btn : GoodsItemUI = equStar.getChildByName( "item3" ) as GoodsItemUI;
            stoneItem3Btn.btn.clickHandler = new Handler( _selectStone, [ "item3" ] );
            var stoneItem4Btn : GoodsItemUI = equStar.getChildByName( "item4" ) as GoodsItemUI;
            stoneItem4Btn.btn.clickHandler = new Handler( _selectStone, [ "item4" ] );
        }

        protected override function _onHide() : void {
            super._onHide();
            var ui : EquTrainUI = _ui;
            var equStar : EquTrainstarUI = ui.viewStack.getChildByName( "item1" ) as EquTrainstarUI;
            var upgradeBtn : Button = equStar.getChildByName( "upgrade" ) as Button;
            upgradeBtn.clickHandler = null;

        }

        public override function updateWindow() : Boolean {
            if ( super.updateWindow() == false )return false;
            showData( _currentIndex );
            return true;
        }

        public function showData( index : int = 0 ) : void {
            if ( CEquipmentTrainViewHandler.tabPage == EEquipPageType.QualityANDLV ) {
                return;
            }
            var itemSystem : CItemSystem = ((uiCanvas as CAppSystem).stage.getSystem( CItemSystem ) as CItemSystem);
            _sendWishStoneList = [];
            var equipList : Array = _data[ 2 ];
            var equipData : CHeroEquipData = equipList[ index ]; // 第一个装备
            _currentEquipData = equipData;
            _currentIndex = index;
            _currentEquipId = equipData.equipID;

            var ui : EquTrainUI = _ui;
            var goodsItem : GoodsItemUI = null;
            var itemTable : CItemData = null;
            var itemData : CBagData = null;
            _dataTable = _data[ 3 ][ 0 ];
            _bagManager = _data[ 3 ][ 1 ];
            var equStar : EquTrainstarUI = ui.viewStack.getChildByName( "item1" ) as EquTrainstarUI;//装备升星页面
            if ( equipData.star >= 5 ) {
                (equStar.getChildByName( "item1" ) as GoodsItemUI).visible = false;
                (equStar.getChildByName( "item2" ) as GoodsItemUI).visible = false;
                (equStar.getChildByName( "item3" ) as GoodsItemUI).visible = false;
                (equStar.getChildByName( "item4" ) as GoodsItemUI).visible = false;
            } else {
                (equStar.getChildByName( "item1" ) as GoodsItemUI).visible = true;
                (equStar.getChildByName( "item2" ) as GoodsItemUI).visible = true;
                (equStar.getChildByName( "item3" ) as GoodsItemUI).visible = true;
                (equStar.getChildByName( "item4" ) as GoodsItemUI).visible = true;
            }
            //是否专属武器
            goodsItem = equStar.getChildByName( "item1" ) as GoodsItemUI;
            goodsItem.visible = true;
            if ( equipData.isExclusive ) {
                itemTable = itemSystem.getItem( equipData.awakenSoulID ); // 消耗物品
                itemData = _bagManager.getBagItemByUid( equipData.awakenSoulID ); //当前拥有
                goodsItem.toolTip = new Handler( _showEquMaterialTips, [ goodsItem, equipData.awakenSoulID ] );
                goodsItem.img.url = itemTable.iconSmall;
                if ( itemData ) {
                    if ( itemData.num >= equipData.nextAwakenSoulCost ) {
                        goodsItem.blackbg.visible = false;
                        goodsItem.btn.visible = false;
//                    goodsItem.txt.autoSize = TextFieldAutoSize.RIGHT;
                        goodsItem.txt.text = /*itemData.num+"/"*/"" + equipData.nextAwakenSoulCost;
                        goodsItem.quality_clip.index = itemTable.quality;
                        _isCanUpgrade = true;
                    }
                    else {
                        goodsItem.blackbg.visible = false;
                        goodsItem.btn.visible = true;
                        goodsItem.txt.isHtml = true;
//                    goodsItem.txt.autoSize = TextFieldAutoSize.RIGHT;
                        goodsItem.txt.text = "<font color = '#ff0000'> " + itemData.num + "/" + equipData.nextAwakenSoulCost + "</font>";
                        goodsItem.quality_clip.index = itemTable.quality;
                        _isCanUpgrade = false;
                    }
                }
                else {
                    goodsItem.blackbg.visible = false;
                    goodsItem.btn.visible = true;
                    goodsItem.txt.isHtml = true;
//                goodsItem.txt.autoSize = TextFieldAutoSize.RIGHT;
                    goodsItem.txt.text = "<font color = '#ff0000'> " + 0 + "/" + equipData.nextAwakenSoulCost + "</font>";
                    goodsItem.quality_clip.index = itemTable.quality;
                    _isCanUpgrade = false;
                }
            }
            else {
                goodsItem.visible = false;
            }
            //觉醒石
            goodsItem = equStar.getChildByName( "item2" ) as GoodsItemUI;
            itemData = _bagManager.getBagItemByUid( equipData.nextAwakenStoneType ); //当前拥有
            itemTable = itemSystem.getItem( equipData.nextAwakenStoneType );
            goodsItem.toolTip = new Handler( _showEquMaterialTips, [ goodsItem, equipData.nextAwakenStoneType ] );
            if ( itemData ) {
                goodsItem.img.url = itemTable.iconSmall;
                if ( itemData.num >= equipData.nextAwakenStoneCost ) {
                    goodsItem.blackbg.visible = false;
                    goodsItem.btn.visible = false;
                    goodsItem.txt.text = /*itemData.num+"/"*/"" + equipData.nextAwakenStoneCost;
                }
                else {
                    goodsItem.blackbg.visible = false;
                    goodsItem.btn.visible = true;
                    goodsItem.txt.text = "<font color = '#ff0000'> " + itemData.num + "/" + equipData.nextAwakenStoneCost + "</font>";
                    _isCanUpgrade = false;
                }
            }
            else {
                if ( equipData.nextAwakenStoneType != 0 ) {
                    goodsItem.img.url = itemTable.iconSmall;
                    goodsItem.blackbg.visible = false;
                    goodsItem.btn.visible = true;
                    goodsItem.txt.text = "<font color = '#ff0000'> " + 0 + "/" + equipData.nextAwakenStoneCost + "</font>";
                    _isCanUpgrade = false;
                }
            }
            //觉醒消耗金币
            _stoneSuccessRate = equipData.nextAwakenSuccessRate * 100;
            equStar.dataSource = {
                txt : {txt : {text : equipData.nextAwakenGoldCost}},
                txt1 : {text : _stoneSuccessRate + "%"}
            };

            goodsItem = equStar.getChildByName( "item3" ) as GoodsItemUI;
            goodsItem.blackbg.visible = true;
            goodsItem.btn.visible = true;
//        goodsItem.txt.text = "<font color = '#ff0000'> " + itemData.num/*+"/"+equipData.nextAwakenSoulCost*/ + "</font>";
//        itemTable = itemSystem.getItem(equipData.nextAwakenStoneType); // 消耗物品
//        goodsItem.quality_clip.index = itemTable.quality;
            goodsItem = equStar.getChildByName( "item4" ) as GoodsItemUI;
            goodsItem.blackbg.visible = true;
            goodsItem.btn.visible = true;
//        goodsItem.txt.text = "<font color = '#ff0000'> " + itemData.num/*+"/"+equipData.nextAwakenSoulCost*/ + "</font>";
//        goodsItem.quality_clip.index = itemTable.quality;

            var nextLevel : int = equipData.level;
            if ( nextLevel >= CHeroEquipData.EQUIP_MAX_LEVEL ) {
                nextLevel = CHeroEquipData.EQUIP_MAX_LEVEL;
            }
            var nextStar : int = equipData.star + 1;
            if ( nextStar >= 5 ) {
                nextStar = 5;
            }
            if ( nextStar == 5 ) {
                if ( equipData.part <= 4 ) {
                    ui.equip_2.dataSource = {
                        name : {text : equipData.nameQualityWithColor},
                        txt1 : {txt : {text : equipData.level + "/" + equipData.levelLimit, color : 0xcc66}},
                        txt2 : {txt : {text : equipData.propertyData.Attack, color : 0xcc66}},
                        txt3 : {txt : {text : equipData.propertyData.Defense, color : 0xcc66}},
                        txt4 : {txt : {text : equipData.propertyData.HP, color : 0xcc66}},
                        guangClip : {index : (equipData.qualityLevelValue + 1)}
                    };
                    equStar.dataSource = {txt : {txt : equipData.nextAwakenGoldCost}};
                }
                else {
                    ui.equip_2.dataSource = {
                        name : {text : equipData.nameQualityWithColor},
                        txt1 : {txt : {text : equipData.level + "/" + equipData.levelLimit, color : 0xcc66}},
                        txt2 : {txt : {text : (equipData.propertyData.PercentEquipATK / 100).toFixed( 2 ) + "%", color : 0xcc66}},
                        txt3 : {txt : {text : (equipData.propertyData.PercentEquipDEF / 100).toFixed( 2 ) + "%", color : 0xcc66}},
                        txt4 : {txt : {text : (equipData.propertyData.PercentEquipHP / 100).toFixed( 2 ) + "%", color : 0xcc66}},
                        guangClip : {index : (equipData.qualityLevelValue + 1)}
                    };
                    equStar.dataSource = {txt : {txt : equipData.nextAwakenGoldCost}};
                }
            }
            else {
                if ( equipData.part <= 4 ) {
                    ui.equip_2.dataSource = {
                        name : {text : equipData.nameQualityWithColor},
                        txt1 : {txt : {text : equipData.level + "/" + equipData.levelLimit, color : 0xcc66}},
                        txt2 : {txt : {text : equipData.nextAwakenProperty.Attack, color : 0xcc66}},
                        txt3 : {txt : {text : equipData.nextAwakenProperty.Defense, color : 0xcc66}},
                        txt4 : {txt : {text : equipData.nextAwakenProperty.HP, color : 0xcc66}},
                        guangClip : {index : (equipData.qualityLevelValue + 1)}
                    };
                    equStar.dataSource = {txt : {txt : equipData.nextAwakenGoldCost}};
                } else {
                    ui.equip_2.dataSource = {
                        name : {text : equipData.nameQualityWithColor},
                        txt1 : {txt : {text : equipData.level + "/" + equipData.levelLimit, color : 0xcc66}},
                        txt2 : {txt : {text : (equipData.nextAwakenProperty.PercentEquipATK / 100).toFixed( 2 ) + "%", color : 0xcc66}},
                        txt3 : {txt : {text : (equipData.nextAwakenProperty.PercentEquipDEF / 100).toFixed( 2 ) + "%", color : 0xcc66}},
                        txt4 : {txt : {text : (equipData.nextAwakenProperty.PercentEquipHP / 100).toFixed( 2 ) + "%", color : 0xcc66}},
                        guangClip : {index : (equipData.qualityLevelValue + 1)}
                    };
                    equStar.dataSource = {txt : {txt : equipData.nextAwakenGoldCost}};
                }
            }
            if ( nextLevel >= CHeroEquipData.EQUIP_MAX_LEVEL ) {
                ui.equip_2.dataSource = {
                    guangClip : {index : (equipData.qualityLevelValue + 1)}
                };
            }
            else {
                ui.equip_2.dataSource = {
                    guangClip : {index : (equipData.qualityLevelValue + 1)}
                };
            }

            var playerManager : CPlayerManager = (uiCanvas as CAppSystem).stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
            var playerData : CPlayerData = playerManager.playerData;
            if ( equipData.nextAwakenGoldCost > playerData.currency.gold ) {
                equStar.dataSource = {txt : {txt : {color : 0xff0000}}};
            } else {
                equStar.dataSource = {txt : {txt : {color : 0xff9966}}};
            }

            _sendWishStoneList = [];
        }

        private function _showEquMaterialTips( item : GoodsItemUI, itemID : Number ) : void {
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

        private var _selectStoneName : String = "";

        private function _selectStone( type : String ) : void {
            if ( type == "item3" ) {
                rootView.dispatchEvent( new CViewEvent( CViewEvent.UI_EVENT, EPlayerViewEventType.EVENT_EQUIP_STONE, {
                    bagManager : _bagManager,
                    type : EEquAssetsType.STONE
                } ) );
                _selectStoneName = "item3";
            }
            else if ( type == "item4" ) {
                rootView.dispatchEvent( new CViewEvent( CViewEvent.UI_EVENT, EPlayerViewEventType.EVENT_EQUIP_STONE, {
                    bagManager : _bagManager,
                    type : EEquAssetsType.STONE
                } ) );
                _selectStoneName = "item4";
            }
        }

        public function updateStone( index : int ) : void {
            var goodsItem : GoodsItemUI = null;
            var ui : EquTrainUI = _ui;
            var equStar : EquTrainstarUI = ui.viewStack.getChildByName( "item1" ) as EquTrainstarUI;
            var itemSystem : CItemSystem = ((uiCanvas as CAppSystem).stage.getSystem( CItemSystem ) as CItemSystem);
            var bagData : CBagData = null;
            if ( _selectStoneName == "item3" ) {
                goodsItem = equStar.getChildByName( "item3" ) as GoodsItemUI;
            }
            else if ( _selectStoneName == "item4" ) {
                goodsItem = equStar.getChildByName( "item4" ) as GoodsItemUI;
            }
            if ( index == 1 ) {
                goodsItem.img.url = itemSystem.getItem( CHeroEquipData.LOW_WISH_STONE_ID ).iconSmall;
                goodsItem.quality_clip.index = itemSystem.getItem( CHeroEquipData.LOW_WISH_STONE_ID ).quality;
                bagData = _bagManager.getBagItemByUid( CHeroEquipData.LOW_WISH_STONE_ID );
                goodsItem.toolTip = new Handler( _showEquMaterialTips, [ goodsItem, bagData.itemID ] );
                _stoneSuccessRate += itemSystem.getItem( CHeroEquipData.LOW_WISH_STONE_ID ).stoneProbability;
                equStar.dataSource = {
                    txt1 : {text : _stoneSuccessRate + "%"}
                };
            }
            else if ( index == 2 ) {
                goodsItem.img.url = itemSystem.getItem( CHeroEquipData.MIDDLE_WISH_STONE_ID ).iconSmall;
                goodsItem.quality_clip.index = itemSystem.getItem( CHeroEquipData.MIDDLE_WISH_STONE_ID ).quality;
                bagData = _bagManager.getBagItemByUid( CHeroEquipData.MIDDLE_WISH_STONE_ID );
                goodsItem.toolTip = new Handler( _showEquMaterialTips, [ goodsItem, bagData.itemID ] );
                _stoneSuccessRate += itemSystem.getItem( CHeroEquipData.MIDDLE_WISH_STONE_ID ).stoneProbability;
                equStar.dataSource = {
                    txt1 : {text : _stoneSuccessRate + "%"}
                };
            }
            else if ( index == 3 ) {
                goodsItem.img.url = itemSystem.getItem( CHeroEquipData.HIGH_WISH_STONE_ID ).iconSmall;
                goodsItem.quality_clip.index = itemSystem.getItem( CHeroEquipData.HIGH_WISH_STONE_ID ).quality;
                bagData = _bagManager.getBagItemByUid( CHeroEquipData.HIGH_WISH_STONE_ID );
                goodsItem.toolTip = new Handler( _showEquMaterialTips, [ goodsItem, bagData.itemID ] );
                _stoneSuccessRate += itemSystem.getItem( CHeroEquipData.HIGH_WISH_STONE_ID ).stoneProbability;
                equStar.dataSource = {
                    txt1 : {text : _stoneSuccessRate + "%"}
                };
            }
            if ( index != 0 ) {
                goodsItem.blackbg.visible = false;
                goodsItem.btn.visible = false;
                goodsItem.txt.text = "1";
            }
            if ( bagData ) {
                _sendWishStoneList.push( bagData );
            }
//            if ( _selectStoneName == "item3" ) {
//                _sendWishStoneList[ 0 ] = bagData;
//            }
//            else if ( _selectStoneName == "item4" ) {
//                _sendWishStoneList[ 1 ] = bagData;
//            }
        }

        /**
         *
         * 祝福石升级的个数
         * 目前在数据发送那里都写死的1个
         *
         * */

        private function _upgradeHandler() : void {
            var heroID : int = _data[ 1 ];
            this.rootView.dispatchEvent( new CViewEvent( CViewEvent.UI_EVENT, EPlayerViewEventType.EVENT_EQUIP_TRAIN_STAR, {
                heroId : heroID,
                equipId : _currentEquipId,
                itemList : _sendWishStoneList
            } ) );
        }

        private function get _ui() : EquTrainUI {
            return /*(rootUI as RoleMainUI).viewStack.items[ EPlayerWndTabType.STACK_ID_HERO_WND_EQUIP_TRAIN ] as EquTrainUI;*/null;
        }

        private function _currentBattleValue() : int {
            //战队数据
            var playerManager : CPlayerManager = system.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
            var playerData : CPlayerData = playerManager.playerData;
            return playerData.teamData.battleValue;
        }
    }
}
