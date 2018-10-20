//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/11/24.
 * Time: 17:06
 */
package kof.game.player.view.playerTrain.tabPage {

import flash.events.Event;
import flash.events.MouseEvent;

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
import kof.table.PlayerQualityConsume;
import kof.ui.master.JueseAndEqu.RoleQualityItemUI;
import kof.ui.master.messageprompt.GoodsItemUI;

import morn.core.components.Box;
import morn.core.components.Button;
import morn.core.components.Clip;
import morn.core.components.Component;
import morn.core.components.Image;
import morn.core.components.List;
import morn.core.handlers.Handler;

public class CPlayerTrainQualityView extends CChildView {

        private var _power : Number = 0;
        private var _attack : Number = 0;
        private var _defense : Number = 0;
        private var _hp : Number = 0;
        private var _goldNu : int = 0;

        private var _dataTable : IDataTable = null;
        private var _bagManager : CBagManager = null;

        private var _nextQualityCostTable : PlayerQualityConsume = null;
        private var _curQuanlity : int = 0;
        private var _curStar : int = 0;
        private var _nextAttack : int = 0;
        private var _nextDefense : int = 0;
        private var _nextHp : int = 0;
        private var _heroData : CPlayerHeroData = null;
        private var _nextGold : Number = 0;

        private var _tipsView : CEquTipsView = null;

        private var _isCanUpgrade : Boolean = true;

        public function CPlayerTrainQualityView() {
            super();
            _tipsView = new CEquTipsView();
        }

        protected override function _onDispose() : void {
            _tipsView = null;
        }

        protected override function _onShow() : void {
            super._onShow();
            var ui : Object = _ui;
            var trainQualityUI : Object = ui.viewStack.getChildByName( "item1" ) as Object;
            var itemList : List = trainQualityUI.getChildByName( "item_list" ) as List;
            itemList.renderHandler = new Handler( _onRender );
            var itemList1 : List = trainQualityUI.getChildByName( "item_list1" ) as List;
            itemList1.renderHandler = new Handler( _onRender1 );
            var itemList2 : List = trainQualityUI.getChildByName( "item_list2" ) as List;
            itemList2.renderHandler = new Handler( _onRender2 );
            var nameBox : Box = (ui.viewStack.getChildByName( "item1" ) as Object).nameBox;
            var heroNameImg : Image = nameBox.getChildByName( "heroName" ) as Image;
            heroNameImg.parent.addEventListener( Event.RESIZE, _onResize );

            var trainQualityBtn : Button = trainQualityUI.getChildByName( "trainQualityBtn" ) as Button;
            trainQualityBtn.addEventListener( MouseEvent.MOUSE_OVER, _trainQualityBtnOnOver );
            trainQualityBtn.addEventListener( MouseEvent.MOUSE_OUT, _trainQualityBtnOnOut );
        }

        private function _trainQualityBtnOnOut( e : MouseEvent ) : void {
            var ui : Object = _ui;
            ui.viewStack.dataSource =
            {
                item1 : {
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

        private function _trainQualityBtnOnOver( e : MouseEvent ) : void {
            var ui : Object = _ui;
            ui.viewStack.dataSource =
            {
                item1 : {
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
            var nameBox : Box = (ui.viewStack.getChildByName( "item1" ) as Object).nameBox;
            var proIco : Clip = nameBox.getChildByName( "proIco" ) as Clip;
            var heroNameImg : Image = nameBox.getChildByName( "heroName" ) as Image;
            var addImg : Image = nameBox.getChildByName( "add" ) as Image;
            var quanlityClipC : Clip = nameBox.getChildByName( "quanlityClip" ) as Clip;
            heroNameImg.x = proIco.x + proIco.width + 1 + heroNameImg.width / 2;
            addImg.x = heroNameImg.x + heroNameImg.width / 2 + 1;
            quanlityClipC.x = addImg.x + addImg.width + 1;
        }

        private function trainQualityBtnFunc() : void {
            var heroID : int = _data[ 1 ];
            this.rootView.dispatchEvent( new CViewEvent( CViewEvent.UI_EVENT, EPlayerViewEventType.EVENT_HERO_TARIN_QUALITY, heroID ) );
        }

        protected override function _onHide() : void {
            super._onHide();
            var ui : Object = _ui;
            var trainQualityUI : Object = ui.viewStack.getChildByName( "item1" ) as Object;
            var itemList : List = trainQualityUI.getChildByName( "item_list" ) as List;
            itemList.renderHandler = null;
            var nameBox : Box = (ui.viewStack.getChildByName( "item1" ) as Object).nameBox;
            var heroNameImg : Image = nameBox.getChildByName( "heroName" ) as Image;
            heroNameImg.parent.removeEventListener( Event.RESIZE, _onResize );

            var trainQualityBtn : Button = trainQualityUI.getChildByName( "trainQualityBtn" ) as Button;
            trainQualityBtn.removeEventListener( MouseEvent.MOUSE_OVER, _trainQualityBtnOnOver );
            trainQualityBtn.removeEventListener( MouseEvent.MOUSE_OUT, _trainQualityBtnOnOut );
            ui.viewStack.dataSource = null;
        }

        public override function updateWindow() : Boolean {
            if ( super.updateWindow() == false )return false;
            showData();
            var ui : Object = _ui;
            var trainHandler : Handler = new Handler( trainQualityBtnFunc );
            ui.viewStack.dataSource =
            {
                item1 : {
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
                    goldTxt : {txt : _nextGold},
                    trainQualityBtn : {clickHandler : trainHandler}
                }
            };

            var playerManager : CPlayerManager = (uiCanvas as CAppSystem).stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
            var playerData : CPlayerData = playerManager.playerData;
            if ( _nextGold > playerData.currency.gold ) {
                ui.viewStack.dataSource = {item1 : {goldTxt : {txt : {color : 0xff0000}}}};
            } else {
                ui.viewStack.dataSource = {item1 : {goldTxt : {txt : {color : 0xff9966}}}};
            }

            ui.property_battle_value_num.num = _power;
            var url : String = CPlayerPath.getUIHeroNamePath( _data[ 1 ] );
            (ui.viewStack.getChildByName( "item1" ) as Object).nameBox.dataSource = {
                heroName : {url : url},
                quanlityClip : {index : _curQuanlity},
                proIco : {index : _heroData.playerBasic.Profession}
            };
            var trainQualityUI : Object = ui.viewStack.getChildByName( "item1" ) as Object;
            var itemList : List = trainQualityUI.getChildByName( "item_list" ) as List;
            var arr : Array = [];
//        var itemCountCost : int = _nextStarCostTable.numItemID1;
            itemList.dataSource = [ 1, 1, 1, 1 ];
            var itemList1 : List = trainQualityUI.getChildByName( "item_list1" ) as List;
            var itemList2 : List = trainQualityUI.getChildByName( "item_list2" ) as List;
            itemList1.dataSource = [ 1 ];
            itemList2.dataSource = [ 2 ];
            var curStar : int = _curStar;
            arr = [];
            for ( var i : int = 0; i < curStar; i++ ) {
                arr.push( 1 );
            }
            var starlist : List = trainQualityUI.star_list.getChildByName( "info_star_list" ) as List;
            starlist.repeatX = arr.length;
            starlist.x = starlist.y = 0;
            starlist.dataSource = arr;
            starlist.right = starlist.right;
            return true;
        }

        private function _onRender( item : Component, idx : int ) : void {
            if ( this._nextQualityCostTable ) {
                var itemID : int = _nextQualityCostTable[ "consumItemID" + int( idx + 1 ) ];

                var itemUI : Object = item as Object;
                var itemTable : CItemData = itemSystem.getItem( itemID ); // 消耗物品
                var itemData : CBagData = _bagManager.getBagItemByUid( itemID ); // item1, 当前拥有
                var itemNu : int = 0;
                if ( !itemData ) {
                    itemNu = 0;
                    _isCanUpgrade = false;
                } else {
                    itemNu = itemData.num;
                }
                itemUI.img.url = itemTable.iconSmall;
                itemUI.name_label.text = itemTable.name;
                itemUI.num.isHtml = true;
                if ( itemNu >= this._nextQualityCostTable[ "numItemID" + int( idx + 1 ) ] ) {
                    itemUI.btn.visible = false;
                    itemUI.black.visible = false;
                    itemUI.num.text = itemNu + ""/*"/"+this._nextQualityCostTable["numItemID"+int(idx+1)]*/;

                    if ( _isCanUpgrade ) {
                        _isCanUpgrade = true;
                    }
                }
                else {
                    itemUI.btn.visible = true;
                    itemUI.black.visible = true;
                    itemUI.num.text = "<font color = '#ff0000'> " + itemNu + "/" + this._nextQualityCostTable[ "numItemID" + int( idx + 1 ) ] + "</font>";
                    _isCanUpgrade = false;
                }
                itemUI.clip.index = itemTable.quality;

                var goodsItem : GoodsItemUI = new GoodsItemUI();
                goodsItem.img.url = itemUI.img.url;
                goodsItem.quality_clip.index = itemUI.clip.index;
                goodsItem.txt.text = itemUI.num.text;
                itemUI.toolTip = new Handler( _showQualityTips, [ goodsItem, itemID ] );
            }
        }

        private function _showQualityTips( item : GoodsItemUI, itemID : int ) : void {
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

        //升品前品质头像
        private function _onRender1( item : Component, idx : int ) : void {
            var itemUI : RoleQualityItemUI = item as RoleQualityItemUI;
            itemUI.icon_image.url = CPlayerPath.getUIHeroIconBigPath( _heroData.prototypeID );
            itemUI.icon_image.mask = itemUI.hero_icon_mask;
            itemUI.quality_clip.index = _heroData.qualityLevelValue;
        }

        //升品后品质头像
        private function _onRender2( item : Component, idx : int ) : void {
            var itemUI : RoleQualityItemUI = item as RoleQualityItemUI;
            itemUI.icon_image.url = CPlayerPath.getUIHeroIconBigPath( _heroData.prototypeID );
            itemUI.icon_image.mask = itemUI.hero_icon_mask;
            if ( _heroData.quality < CPlayerHeroData.MAX_QUALITY_LEVEL ) {
                itemUI.quality_clip.index = int( _heroData.getQualityLevel( _heroData.quality + 1 ).qualityColour );
            }
            else {
                itemUI.quality_clip.index = _heroData.qualityLevelValue;
            }

        }

        private function showData() : void {
            //通用数据：
            //格斗家id、当前战斗力、攻击力、防御、生命、当前金币数量、账号拥有的格斗家list
            var playerData : CPlayerData = _data[ 0 ] as CPlayerData;
            var heroListData : CPlayerHeroListData = playerData.heroList; // 格斗家列表数据
            var heroList : Array = heroListData.list;
            var heroID : int = _data[ 1 ];
            var heroData : CPlayerHeroData = heroListData.getHero( heroID );
            _heroData = heroData;
            //升品数据
            _curQuanlity = heroData.qualityLevelSubValue; // 当前品质+x
            if ( heroData ) {
                this._power = heroData.battleValue; // 战力
                this._attack = heroData.propertyData.Attack; // 攻击
                this._defense = heroData.propertyData.Defense; // 防
                this._hp = heroData.propertyData.HP; // 生命
                if ( heroData.qualityLevel.ID < CPlayerHeroData.MAX_QUALITY_LEVEL ) {
                    var nextLvPro : CPlayerHeroProperty = heroData.nextQualityProperty;
                    var curPro : CPlayerHeroProperty = heroData.currentProperty;
                    this._nextAttack = nextLvPro.Attack - curPro.Attack;
                    this._nextDefense = nextLvPro.Defense - curPro.Defense;
                    this._nextHp = nextLvPro.HP - curPro.HP;
                } else {
                    this._nextAttack = 0;
                    this._nextDefense = 0;
                    this._nextHp = 0;
                }
            }
            this._goldNu = playerData.currency.gold; // 金币

            _curStar = heroData.star;
            if ( heroData.qualityLevel.ID >= CPlayerHeroData.MAX_QUALITY_LEVEL ) {
                //已经升到+30品质
                _nextGold = 0;
            }
            else {
                // 升下一品质消耗
                this._nextQualityCostTable = heroData.nextQualityConsume;
                _nextGold = _nextGold;
            }
//        var goldCost : int = _nextStarCostTable.consumGold; // 金币消耗
            // item 4个, 这里只举例第一个
            _dataTable = _data[ 3 ][ 0 ];
            _bagManager = _data[ 3 ][ 1 ];
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
    }
}
