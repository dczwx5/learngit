//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/11/24.
 * Time: 14:37
 */
package kof.game.player.view.playerTrain.tabPage {

import flash.events.Event;
import flash.events.MouseEvent;

import kof.data.CDataTable;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.game.bag.CBagManager;
import kof.game.bag.CBagSystem;
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
import kof.ui.master.JueseAndEqu.RolePieceItemUI;
import kof.ui.master.messageprompt.GoodsItemUI;

import morn.core.components.Box;
import morn.core.components.Button;
import morn.core.components.Clip;
import morn.core.components.Component;
import morn.core.components.Image;
import morn.core.components.List;
import morn.core.handlers.Handler;
import morn.core.utils.ObjectUtils;

public class CPlayerTrainStarView extends CChildView {
        private var _power : Number = 0;
        private var _attack : Number = 0;
        private var _defense : Number = 0;
        private var _hp : Number = 0;

        private var _piceID : int = 0;
        private var _piceNu : int = 0;

        private var _curStar : int = 0;
        private var _curQuality : int = 0;
        private var _curPiceNu : int = 0;
        private var _nextStarPiceCost : int = 0;
        private var _nextAttack : int = 0;
        private var _nextDefense : int = 0;
        private var _nextHp : int = 0;

        private var _heroData : CPlayerHeroData = null;

        private var _tipsView : CEquTipsView = null;

        private var _isCanUpgrade : Boolean = false;

        public function CPlayerTrainStarView() {
            super();
            _tipsView = new CEquTipsView();
        }

        protected override function _onDispose() : void {
            _tipsView = null;
        }

        protected override function _onShow() : void {
            super._onShow();
            var ui : Object = _ui;
//        var trainHandler:Handler = new Handler(trainStarBtnFunc);
//        ui.viewStack.dataSource = {item2:{power:_power,attack:_attack,defense:_defense,hp:_hp,trainStarBtn:{clickHandler:trainHandler}}};
            var starTrain : Object = ui.viewStack.getChildByName( "item2" ) as Object;
            var barBtn : Button = starTrain.getChildByName( "barBtn" ) as Button;
            barBtn.toolTip = new Handler( _toolTip, [] );
            barBtn.visible = false;
            var nameBox : Box = (ui.viewStack.getChildByName( "item2" ) as Object).nameBox;
            var heroNameImg : Image = nameBox.getChildByName( "heroName" ) as Image;
            heroNameImg.parent.addEventListener( Event.RESIZE, _onResize );

            var trainStarBtn : Button = starTrain.getChildByName( "trainStarBtn" ) as Button;
            trainStarBtn.addEventListener( MouseEvent.MOUSE_OVER, _trainStarBtnOnOver );
            trainStarBtn.addEventListener( MouseEvent.MOUSE_OUT, _trainStarBtnOnOut );

            var headIco : List = starTrain.getChildByName( "item_list" ) as List;
            headIco.renderHandler = new Handler( _onRenderHead );
        }

        private function _trainStarBtnOnOver( e : MouseEvent ) : void {
            var ui : Object = _ui;
            ui.viewStack.dataSource = {
                item2 : {
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

        private function _trainStarBtnOnOut( e : MouseEvent ) : void {
            var ui : Object = _ui;
            ui.viewStack.dataSource = {
                item2 : {
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
                    property4 : {visible : false}
                }
            };
        }

        private function _onResize( e : Event ) : void {
            var ui : Object = _ui;
            var nameBox : Box = (ui.viewStack.getChildByName( "item2" ) as Object).nameBox;
            var proIco : Clip = nameBox.getChildByName( "proIco" ) as Clip;
            var heroNameImg : Image = nameBox.getChildByName( "heroName" ) as Image;
            var addImg : Image = nameBox.getChildByName( "add" ) as Image;
            var quanlityClipC : Clip = nameBox.getChildByName( "quanlityClip" ) as Clip;
            heroNameImg.x = proIco.x + proIco.width + 1 + heroNameImg.width / 2;
            addImg.x = heroNameImg.x + heroNameImg.width / 2 + 1;
            quanlityClipC.x = addImg.x + addImg.width + 1;
        }

        private function _toolTip() : void {
            var str : String = "碎片来源";
            this.rootView.dispatchEvent( new CViewEvent( CViewEvent.UI_EVENT, EPlayerViewEventType.EVENT_HERO_TRAIN_SHOWTIP, str ) );
        }

        private function trainStarBtnFunc() : void {
            var heroID : int = _data[ 1 ];
            //升星
            this.rootView.dispatchEvent( new CViewEvent( CViewEvent.UI_EVENT, EPlayerViewEventType.EVENT_HERO_TRAIN_STAR, heroID ) );
        }

        protected override function _onHide() : void {
            super._onHide();
            var ui : Object = _ui;
            var starTrain : Object = ui.viewStack.getChildByName( "item2" ) as Object;
            var barBtn : Button = starTrain.getChildByName( "barBtn" ) as Button;
            barBtn.toolTip = null;
            var nameBox : Box = (ui.viewStack.getChildByName( "item2" ) as Object).nameBox;
            var heroNameImg : Image = nameBox.getChildByName( "heroName" ) as Image;
            heroNameImg.parent.removeEventListener( Event.RESIZE, _onResize );

            var trainStarBtn : Button = starTrain.getChildByName( "trainStarBtn" ) as Button;
            trainStarBtn.removeEventListener( MouseEvent.MOUSE_OVER, _trainStarBtnOnOver );
            trainStarBtn.removeEventListener( MouseEvent.MOUSE_OUT, _trainStarBtnOnOut );
            ui.viewStack.dataSource = null;
        }

        public override function updateWindow() : Boolean {
            if ( super.updateWindow() == false )return false;
            showData();
            var ui : Object = _ui;
            var trainHandler : Handler = new Handler( trainStarBtnFunc );
            var progressNu : Number = 0;
            if ( this._nextStarPiceCost > 0 ) {
                progressNu = _curPiceNu / this._nextStarPiceCost;
            }
            else {
                progressNu = 1;
            }
            ui.viewStack.dataSource = {
                item2 : {
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
                    bar : {value : progressNu},
                    pice_progress : {text : _curPiceNu + "/" + _nextStarPiceCost},
                    trainStarBtn : {clickHandler : trainHandler}
                }
            };
            if ( this._curStar >= CPlayerHeroData.MAX_STAR_LEVEL ) {
                ui.viewStack.dataSource = {
                    item2 : {
                        bar : {value : 1},
                        pice_progress : {text : CLang.Get( "highStarLv" )}
                    }
                };
            }
            ui.property_battle_value_num.num = _power;
            var url : String = CPlayerPath.getUIHeroNamePath( _data[ 1 ] );
            (ui.viewStack.getChildByName( "item2" ) as Object).nameBox.dataSource = {
                heroName : {url : url},
                quanlityClip : {index : _curQuality},
                proIco : {index : _heroData.playerBasic.Profession}
            };
            var curStar : int = _curStar;
            var arr : Array = [];
            for ( var i : int = 0; i < curStar; i++ ) {
                arr.push( 1 );
            }

            var trainLevelUI : Object = ui.viewStack.getChildByName( "item2" ) as Object;
            var starlist : List = trainLevelUI.star_list.getChildByName( "info_star_list" ) as List;
            starlist.repeatX = arr.length;
            starlist.x = starlist.y = 0;
            starlist.dataSource = arr;
            starlist.right = starlist.right;
            var trainStarUI : Object = ui.viewStack.getChildByName( "item2" ) as Object;
            for ( var j : int = 0; j < 7; j++ ) {
                var btn : Image = trainStarUI.getChildByName( "star" + (j + 1) ) as Image;
//                btn.toolTip = new Handler( _toolTip, [] );
                ObjectUtils.gray( btn, false );
                if ( _curStar < j + 1 ) {
                    ObjectUtils.gray( btn, true );
                }
            }

            var headIco : List = trainStarUI.getChildByName( "item_list" ) as List;
            headIco.dataSource = [ 1 ];
            return true;
        }

        private function _starNuRender( item : Component, idx : int ) : void {
            var len : int = int( item.dataSource );
        }

        private function _onRenderHead( item : Component, idx : int ) : void {
            var itemSys : CItemSystem = ((uiCanvas as CAppSystem).stage.getSystem( CItemSystem ) as CItemSystem);
            var itemUI : RolePieceItemUI = item as RolePieceItemUI;
            itemUI.icon_img.url = itemSys.getItem( _heroData.pieceID ).iconSmall;
            itemUI.qualityClip.index = _heroData.qualityLevelValue + 1;
            var gooodsItem : GoodsItemUI = new GoodsItemUI();
            gooodsItem.img.url = itemSys.getItem( _heroData.pieceID ).iconBig;
            var bagData : CBagData = (itemSys.stage.getSystem( CBagSystem ).getBean( CBagManager ) as CBagManager).getBagItemByUid( _heroData.pieceID );
            if ( bagData ) {
                gooodsItem.txt.text = bagData.num + "";
            } else {
                gooodsItem.txt.text = "0";
            }
            itemUI.toolTip = new Handler( _showHeadPieceTips, [ gooodsItem, _heroData.pieceID ] );
        }

        private function _showHeadPieceTips( item : GoodsItemUI, itemID : int ) : void {
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

        private function showData() : void {
            //通用数据：
            //格斗家id、当前战斗力、攻击力、防御、生命、当前金币数量、账号拥有的格斗家list
            var playerData : CPlayerData = _data[ 0 ] as CPlayerData;
            var heroListData : CPlayerHeroListData = playerData.heroList; // 格斗家列表数据
            var heroList : Array = heroListData.list;
            var heroID : int = _data[ 1 ];
            var heroData : CPlayerHeroData = heroListData.getHero( heroID );
            _heroData = heroData;
            if ( heroData ) {
                this._power = heroData.battleValue; // 战力
                this._attack = heroData.propertyData.Attack; // 攻击
                this._defense = heroData.propertyData.Defense; // 防
                this._hp = heroData.propertyData.HP; // 生命

                this._piceID = heroData.pieceID; // 碎片id
                this._curStar = heroData.star; // 当前星级
                this._curQuality = heroData.qualityLevelSubValue;
                if ( _curStar < CPlayerHeroData.MAX_STAR_LEVEL ) {
                    var nextLvPro : CPlayerHeroProperty = heroData.nextAwakenProperty;
                    var curPro : CPlayerHeroProperty = heroData.currentProperty;
                    this._nextAttack = nextLvPro.Attack - curPro.Attack;
                    this._nextDefense = nextLvPro.Defense - curPro.Defense;
                    this._nextHp = nextLvPro.HP - curPro.HP;
                } else {
                    this._nextAttack = 0;
                    this._nextDefense = 0;
                    this._nextHp = 0;
                }


                var piceData : CBagData = (((uiCanvas as CAppSystem).stage.getSystem( CBagSystem ) as CBagSystem).getBean( CBagManager ) as CBagManager).getBagItemByUid( _piceID );
                if ( piceData ) {
                    _curPiceNu = piceData.num;
                }
                else {
                    _curPiceNu = 0;
                }


                if ( this._curStar >= CPlayerHeroData.MAX_STAR_LEVEL ) {
                    //已经升到七星级
                }
                else {
                    this._nextStarPiceCost = heroData.nextStarPieceCost; // 升到下一星级需要消耗碎片数
                }
//            var starCost:int = heroData.getStarConsume(5).pieceNum; // 升到某一星级消耗碎片数
                // 当前碎片数量
//            var itemData:CBagData = (_bagSystem.getBean(CBagManager) as CBagManager).getBagItemByUid(pieceID);
//            var curPieceCount:int = itemData.num;
            }
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
