//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/12/15.
 * Time: 14:32
 */
package kof.game.player.view.equipmentTrain.childView {

import flash.events.Event;
import flash.events.MouseEvent;
import flash.utils.Dictionary;

import kof.data.CDataTable;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.framework.IDataTable;
import kof.game.bag.CBagManager;
import kof.game.bag.data.CBagData;
import kof.game.common.CLang;
import kof.game.common.view.CChildView;
import kof.game.common.view.event.CViewEvent;
import kof.game.currency.enum.ECurrencyType;
import kof.game.item.CItemData;
import kof.game.item.CItemSystem;
import kof.game.itemGetPath.CItemGetSystem;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CHeroEquipData;
import kof.game.player.data.CPlayerData;
import kof.game.player.enum.EPlayerWndTabType;
import kof.game.player.view.equipmentTrain.CEquTipsView;
import kof.game.player.view.equipmentTrain.CEquipmentTrainViewHandler;
import kof.game.player.view.equipmentTrain.EEquipPageType;
import kof.game.player.view.event.EPlayerViewEventType;
import kof.table.EquipUpgrade;
import kof.table.Item;
import kof.ui.CUISystem;
import kof.ui.master.Equipment.EquTrainLevelUPUI;
import kof.ui.master.Equipment.EquTrainLvAndQualityUI;
import kof.ui.master.Equipment.EquTrainUI;
import kof.ui.master.Equipment.EquTrainqualityUI;
import kof.ui.master.messageprompt.GoodsItemUI;

import morn.core.components.Button;
import morn.core.components.CheckBox;
import morn.core.components.Component;
import morn.core.components.List;
import morn.core.components.TextInput;
import morn.core.handlers.Handler;

public class CEquTrainLevelUpAndQualityView extends CChildView {

        private var _dataTable : IDataTable = null;
        private var _bagManager : CBagManager = null;
        private var _currentEquipId : Number = 0;
        private var _itemList : Array = [];
        private var _currentIndex : int = 0;
        private var _currentEquipData : CHeroEquipData = null;

        private var _nextLevel : int = 0;
        private var _badgeAndCheatsLvAssetsArr : Array = [];

        //<key,value> itemId,num
        private var _selectExpWaterDic : Dictionary = new Dictionary();//勾选的经验药水
        private var _expWaterDic : Dictionary = new Dictionary();//经验药水填写的数量
        private var _cbItemIDDic : Dictionary = new Dictionary();//checkbox对应的药水id
        private var _tiItemIDDic : Dictionary = new Dictionary();//textInput对应的药水id
        private var _itemIDNumDic : Dictionary = new Dictionary();//药水id对应的拥有数量
        private var _itemIDExpValueDic : Dictionary = new Dictionary();//药水id对应药水增加的经验值
        private var _nextExpCost : int = 0;
        private var _curExpAddValue : int = 0;
        private var _curExp : int = 0;
        private var _lvOneNeedExp : int = 0;//升一级需要的经验
        private var _tipsView : CEquTipsView = null;

        private var _isCanUpQuality : Boolean = false;
        private var _isCanUpLv : Boolean = false;
        private var _currentItemId : Number = 0;

        public function CEquTrainLevelUpAndQualityView() {
            _tipsView = new CEquTipsView();
        }

        protected override function _onShow() : void {
            super._onShow();
            var ui : EquTrainUI = _ui;
            var trainEquLvAndQualityUI : EquTrainLvAndQualityUI = ui.viewStack.getChildByName( "item0" ) as EquTrainLvAndQualityUI;
            var lv : EquTrainLevelUPUI = trainEquLvAndQualityUI.getChildByName( "lv" ) as EquTrainLevelUPUI;
            var upBtn : Button = lv.getChildByName( "upgrade" ) as Button;
            upBtn.clickHandler = new Handler( _upgradeClick );
            var oneKeyBtn : Button = lv.getChildByName( "quickupgrade" ) as Button;
            oneKeyBtn.clickHandler = new Handler( _oneKeyUpgradeClick );
            var quality : EquTrainqualityUI = trainEquLvAndQualityUI.getChildByName( "quality" ) as EquTrainqualityUI;
            var qualityBtn : Button = quality.getChildByName( "upgrade" ) as Button;
            qualityBtn.clickHandler = new Handler( _qualityUpgradeClick );
            (lv.getChildByName( "lvItemList" ) as List).renderHandler = new Handler( _lvRenderHandler );
        }

        protected override function _onHide() : void {
            super._onHide();
        }

        public override function updateWindow() : Boolean {
            if ( super.updateWindow() == false )return false;
            showData( _currentIndex );
            return true;
        }

        public function showData( index : int = 0 ) : void {
            if ( CEquipmentTrainViewHandler.tabPage == EEquipPageType.STAR ) {
                return;
            }
            for ( var key : int in _selectExpWaterDic ) {
                delete _selectExpWaterDic[ key ];
            }
            _badgeAndCheatsLvAssetsArr = [];
            _itemList = [];
            var equipList : Array = _data[ 2 ];
            var equipData : CHeroEquipData = equipList[ index ]; // 第一个装备
            _currentEquipData = equipData;
            _currentIndex = index;
            _currentEquipId = equipData.equipID;

//        var equipInPart:CHeroEquipData = equipList.getByPart(CHeroEquipData.POS_WEAPON); // 按部位找装备
            var canLevelUp : Boolean = equipData.isCanLevelUp();
            var ui : EquTrainUI = _ui;
            var trainEquLvAndQualityUI : EquTrainLvAndQualityUI = ui.viewStack.getChildByName( "item0" ) as EquTrainLvAndQualityUI;
            var i : int = 0;
            _dataTable = _data[ 3 ][ 0 ];
            _bagManager = _data[ 3 ][ 1 ];
            var part : int = equipData.part;
            var goodsItem : GoodsItemUI = null;
            var itemTable : Item = null;
            var bagItemData : CBagData = null;
            _nextLevel = 0;
            var playerManager : CPlayerManager = (uiCanvas as CAppSystem).stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
            var playerData : CPlayerData = playerManager.playerData;
            var atk : String = "0";
            var def : String = "0";
            var hp : String = "0";
            if ( canLevelUp ) {
                trainEquLvAndQualityUI.getChildByName( "quality" ).visible = false;
                trainEquLvAndQualityUI.getChildByName( "lv" ).visible = true;
                if ( playerData.currency.gold >= equipData.nextLevelGoldCost ) {
                    _isCanUpLv = true;
                }
                else {
                    _isCanUpLv = false;
                }
                var lv : EquTrainLevelUPUI = trainEquLvAndQualityUI.getChildByName( "lv" ) as EquTrainLevelUPUI;

                lv.dataSource = {
                    goldTxt : {txt : {text : equipData.nextLevelGoldCost}}
                };

                if ( equipData.nextLevelGoldCost > playerData.currency.gold ) {
                    lv.dataSource = {goldTxt : {txt : {color : 0xff0000}}};
                } else {
                    lv.dataSource = {goldTxt : {txt : {color : 0xff9966}}};
                }
                _itemList = [];
                if ( part > 4 ) {
                    _curExp = _currentEquipData.exp;
                    var nextLevelConsume : EquipUpgrade = _currentEquipData.nextLevelUpPropertyData;
                    if ( nextLevelConsume ) {
                        _nextExpCost = nextLevelConsume.consumeCurrencyCount;
                    }
                    else {
                        _nextExpCost = 0;
                    }
                    _lvOneNeedExp = _nextExpCost - _curExp;

                    //额外消耗的货币类型和货币数

                    //额外道具
                    var itemVec : Vector.<int> = equipData.nextLevelExtendsItemListCost;
                    var arr : Array = [];
                    for ( i = 0; i < 3; i++ )                                       //后面记得改成itemVec.length
                    {
                        var itemData : CItemData = _itemSystem.getItem( itemVec[ i ] );
                        bagItemData = _bagManager.getBagItemByUid( itemVec[ i ] ); //当前拥有
                        if ( bagItemData ) {
                            arr.push( {
                                url : itemData.iconSmall,
                                itemNum : bagItemData.num,
                                itemID : itemVec[ i ],
                                itemQunlity : itemData.quality
                            } );
                        }
                        else {
                            arr.push( {
                                url : itemData.iconSmall,
                                itemNum : 0,
                                itemID : itemVec[ i ],
                                itemQunlity : itemData.quality
                            } );
                        }

                    }
//                    _badgeAndCheatsLvAssetsArr = [ 1, 1, 1 ];
                    (lv.getChildByName( "lvItemList" ) as List).dataSource = arr;
                    var progressValue : Number = 1;
                    if ( _nextExpCost > 0 ) {
                        progressValue = _curExp / _nextExpCost;
                    }
                    lv.dataSource = {
                        lvItemList : {visible : true},
                        tips : {visible : false},
                        exp_bar : {visible : true, value : progressValue, label : _curExp + "/" + _nextExpCost},
                        exp_newBar : {visible : true, value : progressValue},
                        quickupgrade : {visible : false}
                    };

                    if ( _currentEquipData.level == CHeroEquipData.EQUIP_MAX_LEVEL ) {
                        lv.dataSource = {
                            exp_bar : {label : CLang.Get( "highLv" )}
                        };
                    }
                }
                else {
                    lv.dataSource = {
                        lvItemList : {visible : false},
                        tips : {visible : true},
                        exp_bar : {visible : false},
                        exp_newBar : {visible : false},
                        quickupgrade : {visible : true}
                    };
                }
                _nextLevel = equipData.level + 1;
                if ( _nextLevel >= CHeroEquipData.EQUIP_MAX_LEVEL ) {
                    _nextLevel = CHeroEquipData.EQUIP_MAX_LEVEL;
                    if ( part > 4 ) {
                        if ( equipData.propertyData.PercentEquipATK > 0 ) {
                            atk = (equipData.propertyData.PercentEquipATK / 100).toFixed( 2 ) + "%";
                        }
                        if ( equipData.propertyData.PercentEquipDEF > 0 ) {
                            def = (equipData.propertyData.PercentEquipDEF / 100).toFixed( 2 ) + "%";
                        }
                        if ( equipData.propertyData.PercentEquipHP > 0 ) {
                            hp = (equipData.propertyData.PercentEquipHP / 100).toFixed( 2 ) + "%";
                        }
                        ui.equip_2.dataSource = {
                            name : {text : equipData.nameQualityWithColor},
                            txt1 : {txt : {text : _nextLevel + "/" + equipData.levelLimit, color : 0xcc66}},
                            txt2 : {txt : {text : atk, color : 0xcc66}},
                            txt3 : {txt : {text : def, color : 0xcc66}},
                            txt4 : {txt : {text : hp, color : 0xcc66}},
                            guangClip : {index : (equipData.qualityLevelValue + 1)}
                        }
                    } else {
                        ui.equip_2.dataSource = {
                            name : {text : equipData.nameQualityWithColor},
                            txt1 : {txt : {text : _nextLevel + "/" + equipData.levelLimit, color : 0xcc66}},
                            txt2 : {txt : {text : equipData.propertyData.Attack, color : 0xcc66}},
                            txt3 : {txt : {text : equipData.propertyData.Defense, color : 0xcc66}},
                            txt4 : {txt : {text : equipData.propertyData.HP, color : 0xcc66}},
                            guangClip : {index : (equipData.qualityLevelValue + 1)}
                        }
                    }
                }
                else {
                    if ( part > 4 ) {
                        if ( equipData.nextLevelProperty.PercentEquipATK > 0 ) {
                            atk = (equipData.nextLevelProperty.PercentEquipATK / 100).toFixed( 2 ) + "%";
                        }
                        if ( equipData.nextLevelProperty.PercentEquipDEF > 0 ) {
                            def = (equipData.nextLevelProperty.PercentEquipDEF / 100).toFixed( 2 ) + "%";
                        }
                        if ( equipData.nextLevelProperty.PercentEquipHP > 0 ) {
                            hp = (equipData.nextLevelProperty.PercentEquipHP / 100).toFixed( 2 ) + "%";
                        }
                        ui.equip_2.dataSource = {
                            name : {text : equipData.nameQualityWithColor},
                            txt1 : {txt : {text : _nextLevel + "/" + equipData.levelLimit, color : 0xcc66}},
                            txt2 : {txt : {text : atk, color : 0xcc66}},
                            txt3 : {txt : {text : def, color : 0xcc66}},
                            txt4 : {txt : {text : hp, color : 0xcc66}},
                            guangClip : {index : (equipData.qualityLevelValue + 1)}
                        };
                    } else {
                        ui.equip_2.dataSource = {
                            name : {text : equipData.nameQualityWithColor},
                            txt1 : {txt : {text : _nextLevel + "/" + equipData.levelLimit, color : 0xcc66}},
                            txt2 : {txt : {text : equipData.nextLevelProperty.Attack, color : 0xcc66}},
                            txt3 : {txt : {text : equipData.nextLevelProperty.Defense, color : 0xcc66}},
                            txt4 : {txt : {text : equipData.nextLevelProperty.HP, color : 0xcc66}},
                            guangClip : {index : (equipData.qualityLevelValue + 1)}
                        };
                    }
                }

            }
            else {
                trainEquLvAndQualityUI.getChildByName( "quality" ).visible = true;
                trainEquLvAndQualityUI.getChildByName( "lv" ).visible = false;
                var qualityUI : EquTrainqualityUI = trainEquLvAndQualityUI.getChildByName( "quality" ) as EquTrainqualityUI;
                //其他货币类型
//            var currencyTable:IDataTable = _data[3][2];
//            var currencyData:CCurrencyData = currencyTable.findByPrimaryKey(equipData.nextQualityOtherCurrencyType);
                if ( equipData.nextQualityOtherCurrencyType == 0/*ECurrencyType.GOLD*/ )//还没配相应数据，暂时写死成金币
                {
                    qualityUI.dataSource = {
                        goldTrain : {
                            visible : false
                        },
                        goldHonor : {
                            visible : false
                        },
                        goldTxt : {
                            visible : true,
                            txt : {text : equipData.nextQualityGoldCost}
                        }
                    };
                }
                else if ( equipData.nextQualityOtherCurrencyType == ECurrencyType.TRIAL ) {
                    qualityUI.dataSource = {
                        goldTrain : {
                            visible : true,
                            txt1 : {text : equipData.nextQualityGoldCost},
                            txt2 : {text : equipData.nextQualityOtherCurrencyCost}
                        },
                        goldHonor : {visible : false},
                        goldTxt : {visible : false}
                    };
                } else if ( equipData.nextQualityOtherCurrencyType == ECurrencyType.HONOR ) {
                    qualityUI.dataSource = {
                        goldTrain : {
                            visible : false
                        },
                        goldHonor : {
                            visible : true,
                            txt1 : {text : equipData.nextQualityGoldCost},
                            txt2 : {text : equipData.nextQualityOtherCurrencyCost}
                        },
                        goldTxt : {
                            visible : false
                        }
                    };
                }

                _itemList = [];
                var bagDataVec : Vector.<CBagData> = equipData.nextQualityItemCost;
                var equipQualityTable : IDataTable = _data[ 3 ][ 3 ];
                for ( i = 0; i < 4; i++ ) {
                    goodsItem = qualityUI.getChildByName( "item" + (i + 1) ) as GoodsItemUI;
                    if ( bagDataVec ) {
                        goodsItem.visible = true;
                        if ( bagDataVec[ i ] ) {
                            goodsItem.toolTip = new Handler( _showEquMaterialsTips, [ goodsItem, bagDataVec[ i ].itemID ] );
                            itemTable = _dataTable.findByPrimaryKey( bagDataVec[ i ].itemID ); // 消耗物品
                            goodsItem.img.url = itemTable.smalliconURL + ".png";
                            bagItemData = _bagManager.getBagItemByUid( bagDataVec[ i ].itemID ); // item1, 当前拥有
                            if ( bagItemData ) {
                                if ( bagItemData.num >= bagDataVec[ i ].num ) {
                                    goodsItem.blackbg.visible = false;
                                    goodsItem.btn.visible = false;
                                    goodsItem.txt.text = bagItemData.num + ""/*+ "/"+bagDataVec[i].num*/;
                                    _itemList.push( bagDataVec[ i ] );
                                    if ( _isCanUpQuality ) {
                                        _isCanUpQuality = true;
                                    }
                                }
                                else {
                                    goodsItem.blackbg.visible = false;
                                    goodsItem.btn.visible = true;
                                    goodsItem.txt.isHtml = true;
                                    goodsItem.txt.text = "<font color = '#ff0000'> " + bagItemData.num + "/" + bagDataVec[ i ].num + "</font>";
                                    _isCanUpQuality = false;
                                }
                            } else {
                                goodsItem.blackbg.visible = false;
                                goodsItem.btn.visible = true;
                                goodsItem.txt.isHtml = true;
                                goodsItem.txt.text = "<font color = '#ff0000'> " + 0 + "/" + bagDataVec[ i ].num + "</font>";
                                _isCanUpQuality = false;
                            }

                        }
                        else {
                            goodsItem.btn.visible = false;
                            goodsItem.blackbg.visible = true;
                            goodsItem.txt.visible = false;
                            goodsItem.quality_clip.index = 0;
                        }

                    }
                    else {
                        goodsItem.visible = false;
                    }
                    if ( _isCanUpQuality ) {
                        if ( playerData.currency.gold >= equipData.nextQualityGoldCost ) {
                            _isCanUpQuality = true;
                        }
                        else {
                            _isCanUpQuality = false;
                        }
                    }
                }
                ui.equip_2.dataSource = {
                    txt1 : {txt : {text : equipData.levelLimit + "/" + equipData.levelLimit}}
                };

                _nextLevel = equipData.level;
                if ( _nextLevel >= CHeroEquipData.EQUIP_MAX_LEVEL ) {
                    _nextLevel = CHeroEquipData.EQUIP_MAX_LEVEL;
                    ui.equip_2.dataSource = {
                        name : {text : equipData.nameQualityWithColor},
                        txt1 : {txt : {text : _nextLevel + "/" + equipData.levelLimit}},
                        txt2 : {txt : {text : equipData.propertyData.Attack}},
                        txt3 : {txt : {text : equipData.propertyData.Defense}},
                        txt4 : {txt : {text : equipData.propertyData.HP}},
                        guangClip : {index : (equipData.qualityLevelValue + 1)}
                    }
                }
                else {
                    //提示
                    //根据品质从装备品质表中获取的颜色，装备名称不用加1，而guangclip要+1，因为guangclip美术做的颜色帧动画正好比配置表中少1
                    //
                    if ( part > 4 ) {
                        if ( equipData.nextLevelProperty.PercentEquipATK > 0 ) {
                            atk = (equipData.nextLevelProperty.PercentEquipATK / 100).toFixed( 2 ) + "%";
                        }
                        if ( equipData.nextLevelProperty.PercentEquipDEF > 0 ) {
                            def = (equipData.nextLevelProperty.PercentEquipDEF / 100).toFixed( 2 ) + "%";
                        }
                        if ( equipData.nextLevelProperty.PercentEquipHP > 0 ) {
                            hp = (equipData.nextLevelProperty.PercentEquipHP / 100).toFixed( 2 ) + "%";
                        }
                        ui.equip_2.dataSource = {
                            name : {text : equipData.nameQualityWithColor},
                            txt1 : {txt : {text : _nextLevel + "/" + equipData.levelLimit, color : 0xcc66}},
                            txt2 : {txt : {text : atk, color : 0xcc66}},
                            txt3 : {txt : {text : def, color : 0xcc66}},
                            txt4 : {txt : {text : hp, color : 0xcc66}},
                            guangClip : {index : (equipData.qualityLevelValue + 1)}
                        };
                    } else {
                        ui.equip_2.dataSource = {
                            name : {text : equipData.nameNextQualityWithColor},
                            txt1 : {txt : {text : _nextLevel + "/" + equipData.levelLimit, color : 0xcc66}},
                            txt2 : {txt : {text : equipData.nextQualityProperty.Attack, color : 0xcc66}},
                            txt3 : {txt : {text : equipData.nextQualityProperty.Defense, color : 0xcc66}},
                            txt4 : {txt : {text : equipData.nextQualityProperty.HP, color : 0xcc66}},
                            guangClip : {index : (equipData.nextQualityLevelValue + 1)}

                        };
                    }
                }

                if ( equipData.nextQualityGoldCost > playerData.currency.gold ) {
                    qualityUI.dataSource = {goldTxt : {txt : {color : 0xff0000}}};
                } else {
                    qualityUI.dataSource = {goldTxt : {txt : {color : 0xff9966}}};
                }

            }
            _curExpAddValue = 0;
//        equipData.levelUpRecord
//        equipData.name; // 装备名
//        equipData.part; // 装备部分
//        equipData.isBook(); // 是否某种装备, book是秘籍
//        equipData.belongHero; // 所属格斗家ID
//        equipData.heroQuality; // 所属格斗家的资质
//        equipData.isCanAwaken; // 装备是否能觉醒
        }

        private function _showEquMaterialsTips( item : GoodsItemUI, itemID : Number ) : void {
            _tipsView.showEquiMaterialTips( item, _getItemTableData( itemID ), _getItemData( itemID ) );
        }

        private function _getItemData( itemID : int ) : CItemData {
            var itemData : CItemData = ((uiCanvas as CAppSystem).stage.getSystem( CItemSystem ) as CItemSystem).getItem( itemID );
            return itemData;
        }

        private function _toolTip() : void {
            var str : String = "材料来源";
            this.rootView.dispatchEvent( new CViewEvent( CViewEvent.UI_EVENT, EPlayerViewEventType.EVENT_HERO_TRAIN_SHOWTIP, str ) );
        }

        private function _lvRenderHandler( item : Component, index : int ) : void {
//            var itemUI : RoleTrainDrugUI = item as RoleTrainDrugUI;
//            var data : Object = itemUI.dataSource;
//            var itemData : CItemData = _itemSystem.getItem( data.itemID ); // 消耗物品
//            var bagData : CBagData = _bagManager.getBagItemByUid( data.itemID ); // item0, 当前拥有
//            var itemExpValue : int = 0;
//            var heroID : int = _data[ 1 ];
//            itemExpValue = _bagManager.getItemUseEffValueByID( data.itemID );
//            var itemNu : String = "";
//            if ( !itemData ) {
//                return;
//            }
//            itemUI.img.url = itemData.iconSmall;
//            if ( itemData.teamLevel > _currentEquipData.level ) {
//                itemUI.name_label.visible = true;
//                itemUI.name_label.text = itemData.teamLevel + CLang.Get( "player_exp_open" );
//                itemUI.cb_btn.visible = false;
//                itemUI.cb_txt.visible = false;
//                itemUI.ti_txt.visible = false;
//                itemUI.black.visible = false;
//                itemUI.add.visible = false;
//                if ( bagData == null ) {
//                    itemUI.num.text = "0";
//                    itemNu = "0";
//                }
//                else {
//                    itemUI.num.text = _getNumFormat( bagData.num );
//                    itemUI.btn.clickHandler = null;
//                    itemNu = _getNumFormat( bagData.num );
//                }
//            }
//            else {
//                if ( bagData == null ) {
//                    itemUI.num.text = "0";
//                    itemUI.name_label.visible = true;
//                    itemUI.name_label.text = CLang.Get( "player_exp_get" );
//                    itemUI.add.visible = true;
//                    _currentItemId = data.itemID;
//                    itemUI.add.addEventListener( MouseEvent.CLICK, _showGetPath );
//                    itemUI.cb_btn.visible = false;
//                    itemUI.cb_txt.visible = false;
//                    itemUI.ti_txt.visible = false;
//                    for ( var key : int in _selectExpWaterDic ) {
//                        if ( itemData.ID == key ) {
//                            delete _selectExpWaterDic[ key ];
//                        }
//                    }
//                    itemNu = "0";
//                    //弹出获取途径
////                itemUI.btn.clickHandler = new Handler(_itemClickFunc,[itemUI.img.url,0,heroID,bagData.itemID,itemExpValue]);
//                }
//                else {
//                    itemUI.name_label.visible = false;
//                    itemUI.cb_btn.visible = true;
//                    itemUI.cb_txt.visible = true;
//                    itemUI.ti_txt.visible = true;
//                    itemUI.black.visible = false;
//                    itemUI.add.visible = false;
//                    itemUI.num.text = _getNumFormat( bagData.num );
//                    itemNu = _getNumFormat( bagData.num );
//                    _itemIDNumDic[ bagData.itemID ] = bagData.num;
//                    _itemIDExpValueDic[ bagData.itemID ] = itemExpValue;
//                    if ( _curExpAddValue < _lvOneNeedExp ) {
//                        for ( var i : int = 1; i < bagData.num + 1; i++ ) {
//                            _curExpAddValue += itemExpValue;
//                            if ( _curExpAddValue >= _lvOneNeedExp ) {
//                                break;
//                            }
//                        }
//                        if ( i == bagData.num + 1 ) {
//                            i = bagData.num;
//                        }
//                        _selectExpWaterDic[ bagData.itemID ] = i;
//                        itemUI.cb_btn.selected = true;
//                        itemUI.ti_txt.text = i + "";
//                        _expWaterDic[ bagData.itemID ] = i;
//                    }
//                    else {
//                        itemUI.cb_btn.selected = false;
//                        itemUI.ti_txt.text = "1";
//                        _expWaterDic[ bagData.itemID ] = 1;
//                    }
//                    _cbItemIDDic[ itemUI.cb_btn ] = bagData.itemID;
//                    _tiItemIDDic[ itemUI.ti_txt ] = bagData.itemID;
//                    itemUI.ti_txt.restrict = "0-9";
//                    itemUI.btn.clickHandler = null;
//                    itemUI.cb_btn.addEventListener( Event.CHANGE, _checkBoxChange );
//                    itemUI.ti_txt.addEventListener( Event.CHANGE, _textInputChange );
//                }
//            }
//            itemUI.qualityClip.index = itemData.quality;
//            if ( index == 2 ) {
//                _updatePreViewBar();
//            }
//            var goodsItem : GoodsItemUI = new GoodsItemUI();
//            goodsItem.img.url = itemData.iconBig;
//            goodsItem.quality_clip.index = itemData.quality;
//            goodsItem.txt.text = itemNu;
//            itemUI.toolTip = new Handler( _showEquMaterialsTips, [ goodsItem, data.itemID ] );
        }

        private function _showGetPath( e : MouseEvent ) : void {
            (system.stage.getSystem( CItemGetSystem ) as CItemGetSystem).showItemGetPath( _currentItemId );
        }

        private function _textInputChange( e : Event ) : void {
            var ti : TextInput = e.target as TextInput;
            if ( ti ) {
                var itemID : int = _tiItemIDDic[ ti ];
                _expWaterDic[ itemID ] = int( ti.text );
                for ( var key : CheckBox in _cbItemIDDic ) {
                    if ( itemID == _cbItemIDDic[ key ] ) {
                        if ( key.selected == false ) {
                            key.selected = true;
                        }
                        _selectExpWaterDic[ itemID ] = int( ti.text );
                        _updatePreViewBar();
                    }
                }
            }
        }

        private function _updatePreViewBar() : void {
            _curExpAddValue = 0;
            for ( var key : int in _selectExpWaterDic ) {
                var expValue : int = _itemIDExpValueDic[ key ];
                var expNum : int = _selectExpWaterDic[ key ];
                _curExpAddValue += expNum * expValue;
            }
            var totalExpValue : Number = _curExp + _curExpAddValue;
            var nu : Number = totalExpValue / _nextExpCost;
            if ( nu >= 1 ) {
                nu = 1;
                if ( _currentEquipData.level < CHeroEquipData.EQUIP_MAX_LEVEL ) {
                    //可升级
                }
                else {
                    //满级
                }

            } else {
                if ( _currentEquipData.level < CHeroEquipData.EQUIP_MAX_LEVEL ) {
                    //可升级
                }
                else {
                    //满级
                }
            }
            var ui : EquTrainUI = _ui;
            var trainEquLvAndQualityUI : EquTrainLvAndQualityUI = ui.viewStack.getChildByName( "item0" ) as EquTrainLvAndQualityUI;
            var lv : EquTrainLevelUPUI = trainEquLvAndQualityUI.getChildByName( "lv" ) as EquTrainLevelUPUI;
            lv.dataSource = {
                exp_newBar : nu
            };
        }

        private function _checkBoxChange( e : Event ) : void {
            var cb : CheckBox = e.target as CheckBox;
            var itemID : int = _cbItemIDDic[ cb ];
            if ( cb && cb.selected ) {
                _selectExpWaterDic[ itemID ] = _expWaterDic[ itemID ];
            }
            else if ( cb && !cb.selected ) {
                for ( var key : int in _selectExpWaterDic ) {
                    if ( itemID == key ) {
                        delete _selectExpWaterDic[ key ];
                    }
                }
            }
            _updatePreViewBar();
        }

        private function _getNumFormat( nu : Number ) : String {
            var value : Number = 10000;
            if ( nu < value ) {
                return nu + "";
            }
            else {
                var result : String = nu / value + CLang.Get( "w" );
                return result;
            }
        }

        public function updateShow( obj : Object ) : void {
            var goodsItem : GoodsItemUI = null;
            var itemTable : Item = null;
            var bagItemData : CBagData = null;
            var itemID : int = obj.itemID;
            var value : int = obj.num;
            var ui : EquTrainUI = _ui;
            var trainEquLvAndQualityUI : EquTrainLvAndQualityUI = ui.viewStack.getChildByName( "item0" ) as EquTrainLvAndQualityUI;
            var lv : EquTrainLevelUPUI = trainEquLvAndQualityUI.getChildByName( "lv" ) as EquTrainLevelUPUI;

            var arr : Array = [];
            var i : int = 0;
            var itemVec : Vector.<int> = _currentEquipData.nextLevelExtendsItemListCost;
            for ( i = 0; i < 3; i++ )                                       //后面记得改成itemVec.length
            {
                bagItemData = _bagManager.getBagItemByUid( itemVec[ i ] ); //当前拥有
                if ( !bagItemData )continue;
                var itemData : CItemData = _itemSystem.getItem( itemVec[ i ] );
                var nu : int = bagItemData.num;
                if ( itemID == itemVec[ i ] ) {
                    nu = value;
                }
                arr.push( {url : itemData.iconSmall, num : nu, itemID : itemVec[ i ]} );
            }

            (lv.getChildByName( "lvItemList" ) as List).dataSource = arr;
        }

        private function _itemClickFunc( url : String, nu : int, heroID : int, itemID : int, itemExpValue : int ) : void {
//        _curExpAddValue = itemExpValue;
            rootView.dispatchEvent( new CViewEvent( CViewEvent.UI_EVENT, EPlayerViewEventType.EVENT_BATCH_USE_ITEM, {
                url : url,
                nu : nu,
                heroID : heroID,
                itemID : itemID
            } ) );
        }

        private function _upgradeClick() : void {
//        var playerManager:CPlayerManager = (_uiSystem as CAppSystem).stage.getSystem(CPlayerSystem ).getBean(CPlayerManager) as CPlayerManager;
//        var playerData:CPlayerData = playerManager.playerData;
//        if(_currentEquipData.level+1>playerData.level)
//        {
//            ((_uiSystem as CAppSystem).stage.getSystem(CUISystem) as CUISystem).showMsgAlert("装备等级不能超过战队等级!");
//            return;
//        }
            if ( _currentEquipData.level == CHeroEquipData.EQUIP_MAX_LEVEL ) {
                ((uiCanvas as CAppSystem).stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( CLang.Get( "alreadyHignLv" ) );
                return;
            }
            var itemArr : Array = [];
            for ( var key : int in _selectExpWaterDic ) {
                itemArr.push( {itemID : key, num : _selectExpWaterDic[ key ]} );
            }
            if ( itemArr.length == 0 && _currentEquipData.part > 4 && _currentEquipData.exp < _currentEquipData.nextLevelUpPropertyData.consumeCurrencyCount ) {
                ((uiCanvas as CAppSystem).stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( CLang.Get( "hasnotWater" ) );
                return;
            }

            var heroID : Number = _data[ 1 ];
            rootView.dispatchEvent( new CViewEvent( CViewEvent.UI_EVENT, EPlayerViewEventType.EVENT_EQUIP_TRAIN_LEVELUP, {
                heroId : heroID,
                equipId : _currentEquipId,
                type : 0,
                itemList : itemArr
            } ) );
        }

        private function _oneKeyUpgradeClick() : void {
            var heroID : int = _data[ 1 ];
            rootView.dispatchEvent( new CViewEvent( CViewEvent.UI_EVENT, EPlayerViewEventType.EVENT_EQUIP_TRAIN_ONEKEY_LEVELUP, {
                heroId : heroID,
                equipId : _currentEquipId,
                type : 1,
                itemList : _itemList
            } ) );
        }

        private function _qualityUpgradeClick() : void {
//        if(_nextLevel>=CHeroEquipData.EQUIP_MAX_LEVEL)
//        {
//            ((_uiSystem as CAppSystem).stage.getSystem(CUISystem) as CUISystem).showMsgAlert("已提升至极品!");
//            return;
//        }
            var heroID : int = _data[ 1 ];
            rootView.dispatchEvent( new CViewEvent( CViewEvent.UI_EVENT, EPlayerViewEventType.EVENT_EQUIP_TRAIN_QUALITY, {
                heroId : heroID,
                equipId : _currentEquipId
            } ) );
        }

        private function get _itemSystem() : CItemSystem {
            return (uiCanvas as CAppSystem).stage.getSystem( CItemSystem ) as CItemSystem;
        }

        private function get _ui() : EquTrainUI {
            return /*(rootUI as RoleMainUI).viewStack.items[ EPlayerWndTabType.STACK_ID_HERO_WND_EQUIP_TRAIN ] as EquTrainUI;*/null;
        }

        private function _getItemTableData( itemID : int ) : Item {
            var itemTable : CDataTable;
            var pDatabaseSystem : CDatabaseSystem = (uiCanvas as CAppSystem).stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            itemTable = pDatabaseSystem.getTable( KOFTableConstants.ITEM ) as CDataTable;
            return itemTable.findByPrimaryKey( itemID );
        }

        private function _currentBattleValue() : int {
            //战队数据
            var playerManager : CPlayerManager = system.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
            var playerData : CPlayerData = playerManager.playerData;
            return playerData.teamData.battleValue;
        }
    }
}
