//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/11/24.
 * Time: 17:10
 */
package kof.game.player.view.playerTrain.tabPage {

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
import kof.game.item.CItemData;
import kof.game.item.CItemSystem;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.data.CPlayerHeroListData;
import kof.game.player.data.property.CPlayerHeroProperty;
import kof.game.player.enum.EPlayerWndTabType;
import kof.game.player.view.equipmentTrain.CEquTipsView;
import kof.game.player.view.event.EPlayerViewEventType;
import kof.table.Item;
import kof.table.PlayerLevelConsume;
import kof.ui.CUISystem;
import kof.ui.master.messageprompt.GoodsItemUI;

import morn.core.components.Box;
import morn.core.components.Button;
import morn.core.components.CheckBox;
import morn.core.components.Clip;
import morn.core.components.Component;
import morn.core.components.Image;
import morn.core.components.List;
import morn.core.components.ProgressBar;
import morn.core.components.TextInput;
import morn.core.handlers.Handler;

public class CPlayerTrainLevelUPView extends CChildView {

        private var _power : Number = 0;
        private var _attack : Number = 0;
        private var _defense : Number = 0;
        private var _hp : Number = 0;

        private var _dataTable : IDataTable = null;
        private var _bagManager : CBagManager = null;
        private var _heroID : int = 0;

        private var _nextLevelCostTable : PlayerLevelConsume = null;
        private var _curLevel : int = 0;

        private var _nextExpCost : int = 0;
        private var _curExpAddValue : int = 0;
        private var _curExp : int = 0;
        private var _lvOneNeedExp : int = 0;//升一级需要的经验
        private var _nextAttack : int = 0;
        private var _nextDefense : int = 0;
        private var _nextHp : int = 0;

        private var _playerData : CPlayerData = null;
        private var _heroData : CPlayerHeroData = null;
        //<key,value> itemId,num
        private var _selectExpWaterDic : Dictionary = new Dictionary();//勾选的经验药水
        private var _expWaterDic : Dictionary = new Dictionary();//经验药水填写的数量
        private var _cbItemIDDic : Dictionary = new Dictionary();//checkbox对应的药水id
        private var _tiItemIDDic : Dictionary = new Dictionary();//textInput对应的药水id
        private var _itemIDNumDic : Dictionary = new Dictionary();//药水id对应的拥有数量
        private var _itemIDExpValueDic : Dictionary = new Dictionary();//药水id对应药水增加的经验值

        private var _tipsView : CEquTipsView = null;

        private var _isSelected : Boolean = false;//当升级经验超过了下一级，就只需选择一个药水

        //是否手动勾选
        private var _manualSelectItemIDVector : Vector.<Number> = new <Number>[];
        private var _canLevelUp : int = 0;

        public function CPlayerTrainLevelUPView() {
            super();
            _tipsView = new CEquTipsView();
        }

        protected override function _onDispose() : void {
            _tipsView = null;
        }

        protected override function _onShow() : void {
            super._onShow();
            var ui : Object = _ui;
            var trainLevelUI : Object = ui.viewStack.getChildByName( "item0" ) as Object;
            var itemList : List = trainLevelUI.getChildByName( "item_list" ) as List;
            itemList.renderHandler = new Handler( _onRender );
            var nameBox : Box = (ui.viewStack.getChildByName( "item0" ) as Object).nameBox;
            var heroNameImg : Image = nameBox.getChildByName( "heroName" ) as Image;
            heroNameImg.parent.addEventListener( Event.RESIZE, _onResize );

            var useBtn : Button = trainLevelUI.getChildByName( "useBtn" ) as Button;
            useBtn.clickHandler = new Handler( _useExpWaterFunc );
            useBtn.addEventListener( MouseEvent.MOUSE_OVER, _expBarOnOver );
            useBtn.addEventListener( MouseEvent.MOUSE_OUT, _expBarOnOut );
        }

        private function _useExpWaterFunc() : void {
            if ( _heroData.level == CPlayerHeroData.MAX_LEVEL ) {
                ((uiCanvas as CAppSystem).stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( CLang.Get( "alreadyHignLv" ) );
                return;
            }
            var itemArr : Array = [];
            for ( var key : int in _selectExpWaterDic ) {
                itemArr.push( {itemID : key, num : _selectExpWaterDic[ key ]} );
            }
            if ( itemArr.length == 0 ) {
                ((uiCanvas as CAppSystem).stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( CLang.Get( "hasnotWater" ) );
                return;
            }
            this.rootView.dispatchEvent( new CViewEvent( CViewEvent.UI_EVENT, EPlayerViewEventType.EVENT_HERO_TRAIN_LEVELUP, {
                id : _heroID,
                itemArr : itemArr
            } ) );
        }

        private function _expBarOnOut( e : MouseEvent ) : void {
            var ui : Object = _ui;
            ui.property_battle_value_num.num = _power;
            ui.viewStack.dataSource = {
                item0 : {
                    property1 : {
                        txt1 : {text : CLang.Get( "player_attack" )},
                        txt2 : {text : _attack},
                        txt3 : {visible : false, text : "(" + _nextAttack + ")"}
                    },
                    property2 : {
                        txt1 : {text : CLang.Get( "player_denfense" )},
                        txt2 : {text : _defense},
                        txt3 : {visible : false, text : "(" + _nextDefense + ")"}
                    },
                    property3 : {
                        txt1 : {text : CLang.Get( "player_hp" )},
                        txt2 : {text : _hp},
                        txt3 : {visible : false, text : "(" + _nextHp + ")"}
                    },
                    property4 : {visible : false}
                }
            };
        }

        private function _expBarOnOver( e : MouseEvent ) : void {
            var ui : Object = _ui;
            ui.property_battle_value_num.num = _power;
            ui.viewStack.dataSource = {
                item0 : {
                    property1 : {
                        txt1 : {text : CLang.Get( "player_attack" )},
                        txt2 : {text : _attack},
                        txt3 : {visible : true, text : "(" + _nextAttack + ")"}
                    },
                    property2 : {
                        txt1 : {text : CLang.Get( "player_denfense" )},
                        txt2 : {text : _defense},
                        txt3 : {visible : true, text : "(" + _nextDefense + ")"}
                    },
                    property3 : {
                        txt1 : {text : CLang.Get( "player_hp" )},
                        txt2 : {text : _hp},
                        txt3 : {visible : true, text : "(" + _nextHp + ")"}
                    },
                    property4 : {visible : false}
                }
            };
        }

        private function _onResize( e : Event ) : void {
            var ui : Object = _ui;
            var nameBox : Box = (ui.viewStack.getChildByName( "item0" ) as Object).nameBox;
            var proIco : Clip = nameBox.getChildByName( "proIco" ) as Clip;
            var heroNameImg : Image = nameBox.getChildByName( "heroName" ) as Image;
            var addImg : Image = nameBox.getChildByName( "add" ) as Image;
            var quanlityClipC : Clip = nameBox.getChildByName( "quanlityClip" ) as Clip;
            heroNameImg.x = proIco.x + proIco.width + 1 + heroNameImg.width / 2;
            addImg.x = heroNameImg.x + heroNameImg.width / 2 + 1;
            quanlityClipC.x = addImg.x + addImg.width + 1;
        }

        protected override function _onHide() : void {
            super._onHide();
            var ui : Object = _ui;
            var trainLevelUI : Object = ui.viewStack.getChildByName( "item0" ) as Object;
            var itemList : List = trainLevelUI.getChildByName( "item_list" ) as List;
            itemList.renderHandler = null;
            var nameBox : Box = (ui.viewStack.getChildByName( "item0" ) as Object).nameBox;
            var heroNameImg : Image = nameBox.getChildByName( "heroName" ) as Image;
            heroNameImg.parent.removeEventListener( Event.RESIZE, _onResize );

            var expBar : ProgressBar = trainLevelUI.getChildByName( "exp_bar" ) as ProgressBar;
            expBar.removeEventListener( MouseEvent.MOUSE_OVER, _expBarOnOver );
            expBar.removeEventListener( MouseEvent.MOUSE_OUT, _expBarOnOut );
            ui.viewStack.dataSource = null;
        }

        public override function updateWindow() : Boolean {
            if ( super.updateWindow() == false )return false;
            _isSelected = false;
            showData();
            var playerData : CPlayerData = _data[ 0 ] as CPlayerData;
            var heroListData : CPlayerHeroListData = playerData.heroList;
            var heroData : CPlayerHeroData = heroListData.getHero( _data[ 1 ] );
            if ( heroData ) {
                _curExp = heroData.exp;
                var curPro : CPlayerHeroProperty = heroData.currentProperty;
                if ( heroData.level < 150 ) {
                    var nextLevelConsume : PlayerLevelConsume = heroData.nextLevelConsume;
                    var nextLvPro : CPlayerHeroProperty = heroData.nextLevelProperty;
                    if ( nextLevelConsume ) {
                        _nextExpCost = nextLevelConsume.consumEXP;
                    }
                    else {
                        _nextExpCost = 0;
                    }
                    _lvOneNeedExp = _nextExpCost - _curExp;
                    _nextAttack = nextLvPro.Attack - curPro.Attack;
                    _nextDefense = nextLvPro.Defense - curPro.Defense;
                    _nextHp = nextLvPro.HP - curPro.HP;
                } else {
                    _nextExpCost = 0;
                    _lvOneNeedExp = 0;
                    _nextAttack = 0;
                    _nextDefense = 0;
                    _nextHp = 0;
                }
            }
            var progressValue : Number = 1;
            if ( _nextExpCost > 0 ) {
                progressValue = _curExp / _nextExpCost;
            }
            var ui : Object = _ui;
            ui.property_battle_value_num.num = _power;
            ui.viewStack.dataSource = {
                item0 : {
                    lblLevel : {text : /*CLang.Get("player_level")+*/_curLevel},
                    property1 : {
                        txt1 : {text : CLang.Get( "player_attack" )},
                        txt2 : {text : _attack},
                        txt3 : {visible : false}
                    },
                    property2 : {
                        txt1 : {text : CLang.Get( "player_denfense" )},
                        txt2 : {text : _defense},
                        txt3 : {visible : false}
                    },
                    property3 : {
                        txt1 : {text : CLang.Get( "player_hp" )},
                        txt2 : {text : _hp},
                        txt3 : {visible : false}
                    },
                    property4 : {visible : false},
                    exp_bar : {value : progressValue, label : _curExp + "/" + _nextExpCost},
                    exp_newBar : progressValue
                }
            };
            if ( heroData.level == CPlayerHeroData.MAX_LEVEL ) {
                ui.viewStack.dataSource = {
                    item0 : {
                        exp_bar : {label : CLang.Get( "highLv" )}
                    }
                };
            }
            var url : String = CPlayerPath.getUIHeroNamePath( _data[ 1 ] );
            (ui.viewStack.getChildByName( "item0" ) as Object).nameBox.dataSource = {
                heroName : {url : url},
                quanlityClip : {index : heroData.qualityLevelSubValue},
                proIco : {index : heroData.playerBasic.Profession}
            };
            (ui.viewStack.getChildByName( "item0" ) as Object).getChildByName( "property4" ).visible = false;

            var trainLevelUI : Object = ui.viewStack.getChildByName( "item0" ) as Object;
            var itemList : List = trainLevelUI.getChildByName( "item_list" ) as List;
            _curExpAddValue = 0;
            itemList.dataSource = [ 1, 1, 1, 1, 1, 1 ];

            var curStar : int = heroData.star;
            var arr : Array = [];
            for ( var i : int = 0; i < curStar; i++ ) {
                arr.push( 1 );
            }
            var starlist : List = trainLevelUI.star_list.getChildByName( "info_star_list" ) as List;
            starlist.repeatX = arr.length;
            starlist.x = starlist.y = 0;
            starlist.dataSource = arr;
            starlist.right = starlist.right;
            return true;
        }

        private function _onRender( item : Component, idx : int ) : void {
            if ( this._nextLevelCostTable ) {
                var goodsItem : GoodsItemUI = new GoodsItemUI();
                var itemNu : int = 0;
                var itemID : int = _nextLevelCostTable[ "consumItemID" + int( idx + 1 ) ];

                var itemUI : Object = item as Object;
                var itemData : CItemData = itemSystem.getItem( itemID ); // 消耗物品
                var bagData : CBagData = _bagManager.getBagItemByUid( itemID ); // item0, 当前拥有
                var itemExpValue : int = 0;
                var heroID : int = _data[ 1 ];
                itemExpValue = _bagManager.getItemUseEffValueByID( itemID );
                if ( !itemData ) {
                    return;
                }

                itemUI.img.url = itemData.iconSmall;
                if ( itemData.teamLevel > _playerData.teamData.level ) {
                    itemUI.name_label.visible = true;
                    itemUI.name_label.isHtml = true;
                    itemUI.name_label.text = "<font color = '#ff0000'>" + itemData.teamLevel + CLang.Get( "player_exp_open" ) + "</font>";
                    itemUI.cb_btn.visible = false;
                    itemUI.cb_txt.visible = false;
                    itemUI.ti_txt.visible = false;
                    itemUI.black.visible = false;
                    itemUI.add.visible = false;
                    if ( bagData == null ) {
                        itemUI.num.text = "0";
                        itemNu = 0;
                    }
                    else {
                        itemUI.num.text = _getNumFormat( bagData.num );
                        itemUI.btn.clickHandler = null;
                        itemNu = bagData.num;
                    }
                }
                else {
                    if ( bagData == null ) {
                        itemUI.num.text = "0";
                        itemUI.name_label.visible = true;
                        itemUI.name_label.text = CLang.Get( "player_exp_get" );
                        itemUI.add.visible = true;
                        itemUI.cb_btn.visible = false;
                        itemUI.cb_txt.visible = false;
                        itemUI.ti_txt.visible = false;
                        for ( var key : int in _selectExpWaterDic ) {
                            if ( itemData.ID == key ) {
                                delete _selectExpWaterDic[ key ];
                            }
                        }
                        itemNu = 0;
                        //弹出获取途径
//                itemUI.btn.clickHandler = new Handler(_itemClickFunc,[itemUI.img.url,0,heroID,bagData.itemID,itemExpValue]);
                    }
                    else {
                        itemUI.name_label.visible = false;
                        itemUI.cb_btn.visible = true;
                        itemUI.cb_txt.visible = true;
                        itemUI.ti_txt.visible = true;
                        itemUI.black.visible = false;
                        itemUI.add.visible = false;
                        itemUI.num.text = _getNumFormat( bagData.num );
                        _itemIDNumDic[ bagData.itemID ] = bagData.num;
                        _itemIDExpValueDic[ bagData.itemID ] = itemExpValue;
//                    for ( var key : int in _selectExpWaterDic ) {
//                        var expValue:int = _itemIDExpValueDic[key];
//                        var expNum:int = _selectExpWaterDic[key];
//                        _curExpAddValue+=expNum*expValue;
//                    }
                        if ( _manualSelectItemIDVector.length == 0 ) {
                            if ( _lvOneNeedExp <= 0 && !_isSelected ) {
                                _isSelected = true;
                                _selectExpWaterDic[ bagData.itemID ] = 1;
                                itemUI.cb_btn.selected = true;
                                itemUI.ti_txt.text = 1 + "";
                                _expWaterDic[ bagData.itemID ] = 1;
                            } else {
                                if ( _curExpAddValue < _lvOneNeedExp ) {
                                    for ( var i : int = 1; i < bagData.num + 1; i++ ) {
                                        _curExpAddValue += itemExpValue;
                                        if ( _curExpAddValue >= _lvOneNeedExp ) {
                                            break;
                                        }
                                    }
                                    if ( i == bagData.num + 1 ) {
                                        i = bagData.num;
                                    }
                                    _selectExpWaterDic[ bagData.itemID ] = i;
                                    itemUI.cb_btn.selected = true;
                                    itemUI.ti_txt.text = i + "";
                                    _expWaterDic[ bagData.itemID ] = i;
                                }
                                else {
                                    itemUI.cb_btn.selected = false;
                                    itemUI.ti_txt.text = "1";
                                    _expWaterDic[ bagData.itemID ] = 1;
                                    var itemIndex : int = _manualSelectItemIDVector.indexOf( bagData.itemID );
                                    if ( itemIndex != -1 ) {
                                        _manualSelectItemIDVector.splice( itemIndex, 1 );
                                    }
                                }
                            }
                        } else {
                            if ( _manualSelectItemIDVector.length > 0 && _manualSelectItemIDVector.indexOf( bagData.itemID ) != -1 ) {
                                _selectExpWaterDic[ bagData.itemID ] = int( itemUI.ti_txt.text );
                                itemUI.cb_btn.selected = true;
                                itemUI.ti_txt.text = itemUI.ti_txt.text + "";
                                _expWaterDic[ bagData.itemID ] = int( itemUI.ti_txt.text );
                            } else {
                                itemUI.cb_btn.selected = false;
                                itemUI.ti_txt.text = "1";
                            }
                        }

                        _cbItemIDDic[ itemUI.cb_btn ] = bagData.itemID;
                        _tiItemIDDic[ itemUI.ti_txt ] = bagData.itemID;
                        itemUI.ti_txt.restrict = "0-9";
                        itemUI.btn.clickHandler = null;
                        itemUI.cb_btn.addEventListener( Event.CHANGE, _checkBoxChange );
                        itemUI.ti_txt.addEventListener( Event.CHANGE, _textInputChange );
                        itemUI.cb_btn.clickHandler = new Handler( _cbLick, [ bagData.itemID, itemUI.cb_btn ] );

                        itemNu = bagData.num;
                    }
                }
                itemUI.qualityClip.index = itemData.quality;
                if ( idx == 5 ) {
                    _updatePreViewBar();
                }
            }

            goodsItem.img.url = itemUI.img.url;
            goodsItem.txt.text = itemNu + "";
            goodsItem.quality_clip.index = itemUI.qualityClip.index;
            itemUI.toolTip = new Handler( _showLvItemTips, [ goodsItem, itemID ] );
        }

        private function _cbLick( itemID : int, cb_btn : CheckBox ) : void {
            var index : int = _manualSelectItemIDVector.indexOf( itemID );
            if ( index != -1 ) {
                _manualSelectItemIDVector.splice( index, 1 );
            }
            else {
                if ( cb_btn.selected ) {
                    _manualSelectItemIDVector.push( itemID );
                }
            }
        }

        private function _showLvItemTips( item : GoodsItemUI, itemID : int ) : void {
            _tipsView.showEquiMaterialTips( item, _getItemTableData( itemID ), _getItemData( itemID ) );
        }

        private function _getItemTableData( itemID : int ) : Item {
            var itemTable : CDataTable;
            var pDatabaseSystem : CDatabaseSystem = (uiCanvas as CAppSystem).stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            itemTable = pDatabaseSystem.getTable( KOFTableConstants.ITEM ) as CDataTable;
            return itemTable.findByPrimaryKey( itemID );
        }

        private function _getItemData( itemID : int ) : CItemData {
            var itemData : CItemData = ((uiCanvas as CAppSystem).stage.getSystem( CItemSystem ) as CItemSystem).getItem( itemID );
            return itemData;
        }

        private function _textInputChange( e : Event ) : void {
            var ti : TextInput = e.target as TextInput;
            if ( ti ) {
                var itemID : int = _tiItemIDDic[ ti ];
                _expWaterDic[ itemID ] = int( ti.text );
                for ( var key : CheckBox in _cbItemIDDic ) {
                    if ( itemID == _cbItemIDDic[ key ] ) {
                        if ( key.selected == false ) {
                            if ( _manualSelectItemIDVector.length == 0 ) {
                                key.selected = true;
                            } else {
                                if ( _manualSelectItemIDVector.indexOf( itemID ) != -1 ) {
                                    key.selected = true;
                                } else {
                                    key.selected = false;
                                }
                            }
                        }
                        _selectExpWaterDic[ itemID ] = int( ti.text );
                        _updatePreViewBar();
                    }
                }
            }
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

        //物品获得路径
        private function _itemClickFunc( url : String, nu : int, heroID : int, itemID : int, itemExpValue : int, curNu : int ) : void {
            _curExpAddValue = itemExpValue;
            //this.rootView.dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT,EPlayerViewEventType.EVENT_BATCH_USE_ITEM,{url:url,nu:nu,heroID:heroID,itemID:itemID}));
            if ( curNu != 0 ) {
                _updatePreViewBar();
            }
        }

        private function showData() : void {
            //通用数据：
            //格斗家id、当前战斗力、攻击力、防御、生命、当前金币数量、账号拥有的格斗家list
            _playerData = _data[ 0 ] as CPlayerData;
            var heroListData : CPlayerHeroListData = _playerData.heroList; // 格斗家列表数据
            var heroList : Array = heroListData.list;
            _heroID = _data[ 1 ];
            _heroData = heroListData.getHero( _heroID );
            if ( _heroData ) {
                this._power = _heroData.battleValue; // 战力
                this._attack = _heroData.propertyData.Attack; // 攻击
                this._defense = _heroData.propertyData.Defense; // 防
                this._hp = _heroData.propertyData.HP; // 生命
                this._curLevel = _heroData.level;
                if ( _heroData.level >= CPlayerHeroData.MAX_LEVEL ) {
                    //已经到顶级
                    this._nextLevelCostTable = _heroData.getLevelConsume( CPlayerHeroData.MAX_LEVEL );
                }
                else {
                    this._nextLevelCostTable = _heroData.nextLevelConsume;
                }
            }
            _dataTable = _data[ 3 ][ 0 ];
            _bagManager = _data[ 3 ][ 1 ];
            _curExpAddValue = 0;
        }

        private function _updatePreViewBar() : void {
            _curExpAddValue = 0;
            for ( var key : int in _selectExpWaterDic ) {
                var expValue : int = _itemIDExpValueDic[ key ];
                var expNum : int = _selectExpWaterDic[ key ];
                _curExpAddValue += expNum * expValue;
            }
            var totalExpValue : Number = _curExp + _curExpAddValue;
            var ui : Object = _ui;
            var nu : Number = totalExpValue / _nextExpCost;
            if ( nu >= 1 ) {
                nu = 1;
                if ( _heroData.level < CPlayerHeroData.MAX_LEVEL ) {
                    var canLevelUp : int = _heroData.getCanLevelUpValue( totalExpValue );
                    //计算可升至多少级
                    (ui.viewStack.getChildByName( "item0" ) as Object).canLvTxt.text = CLang.Get( "canLv", {v1 : canLevelUp} );
                    _canLevelUp = canLevelUp;
                }
                else {
                    (ui.viewStack.getChildByName( "item0" ) as Object).canLvTxt.text = CLang.Get( "highLv" );
                    _canLevelUp = 150;
                }

            } else {
                if ( _heroData.level < CPlayerHeroData.MAX_LEVEL ) {
                    (ui.viewStack.getChildByName( "item0" ) as Object).canLvTxt.text = CLang.Get( "canLv", {v1 : _heroData.level} );
                    _canLevelUp = _heroData.level;
                }
                else {
                    (ui.viewStack.getChildByName( "item0" ) as Object).canLvTxt.text = CLang.Get( "highLv" );
                    _canLevelUp = 150;
                }
            }
            var curPro : CPlayerHeroProperty = _heroData.currentProperty;
            var specialLvPro : CPlayerHeroProperty = _heroData.specialLevelProperty( _canLevelUp );
            _lvOneNeedExp = _nextExpCost - _curExp;
            _nextAttack = specialLvPro.Attack - curPro.Attack;
            _nextDefense = specialLvPro.Defense - curPro.Defense;
            _nextHp = specialLvPro.HP - curPro.HP;
            ui.property_battle_value_num.num = _power;
            ui.viewStack.dataSource = {
                item0 : {
                    exp_newBar : nu
                }
            };

        }

        private function get itemSystem() : CItemSystem {
            return ((uiCanvas as CAppSystem).stage.getSystem( CItemSystem ) as CItemSystem);
        }

        private function get _ui() : Object {
            return (rootUI as Object).viewStack.items[ EPlayerWndTabType.STACK_ID_HERO_WND_TRAIN ] as Object;
        }

        private function _currentBattleValue() : int {
            //战队数据
            var playerManager : CPlayerManager = system.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
            var playerData : CPlayerData = playerManager.playerData;
            return playerData.teamData.battleValue;
        }

        private function get _playerLevel() : int {
            //战队数据
            var playerManager : CPlayerManager = system.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
            var playerData : CPlayerData = playerManager.playerData;
            return playerData.teamData.level;
        }
    }
}
