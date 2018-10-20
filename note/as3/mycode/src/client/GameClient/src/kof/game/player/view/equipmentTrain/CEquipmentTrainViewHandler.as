//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/12/15.
 * Time: 12:22
 */
package kof.game.player.view.equipmentTrain {

import flash.events.Event;

import kof.framework.CAppSystem;
import kof.framework.IDataTable;
import kof.game.bag.CBagManager;
import kof.game.bag.data.CBagData;
import kof.game.common.CLang;
import kof.game.common.view.CChildView;
import kof.game.item.CItemSystem;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CHeroEquipData;
import kof.game.player.data.CPlayerData;
import kof.game.player.enum.EPlayerWndTabType;
import kof.game.player.event.CPlayerEvent;
import kof.game.player.view.equipmentTrain.childView.CEquTrainLevelUpAndQualityView;
import kof.game.player.view.equipmentTrain.childView.CEquTrainStarView;
import kof.ui.CUISystem;
import kof.ui.master.Equipment.EquTrainUI;
import kof.ui.master.JueseAndEqu.EquItemUI;

import morn.core.components.Box;
import morn.core.components.Clip;
import morn.core.components.Component;
import morn.core.components.FrameClip;
import morn.core.components.List;
import morn.core.handlers.Handler;

public class CEquipmentTrainViewHandler extends CChildView {

        private var _dataTable : IDataTable = null;
        private var _bagManager : CBagManager = null;
        private var _currentIndex : int = 0;
        private var _tipsView : CEquTipsView = null;

        private var _lastStar1Nu : int = -1;
        private var _isFirstInto : Boolean = true;

        private var _currentEquipData : CHeroEquipData = null;
        //增加的属性
        private var _addPower : int = 0;
        private var _addAttack : int = 0;
        private var _addDefense : int = 0;
        private var _addHP : int = 0;
        private var _currentPower : int = 0;
        private var _currentAttack : int = 0;
        private var _currentDefense : int = 0;
        private var _currentHP : int = 0;

        public static var tabPage : int = 0;

        public function CEquipmentTrainViewHandler() {
            super( [ CEquTrainStarView, CEquTrainLevelUpAndQualityView ] );
            _tipsView = new CEquTipsView();
        }

        protected override function _onShow() : void {
            super._onShow();
            var ui : EquTrainUI = _ui;
            ui.tab.selectHandler = ui.viewStack.setIndexHandler;
            ui.tab.addEventListener( Event.CHANGE, _onChangeViewStack );
            ui.equip_list.renderHandler = new Handler( _onRender );
            ui.equip_list.selectHandler = new Handler( _selectItemHandler );

            system.addEventListener( CPlayerEvent.EQUIP_DATA, _showPrompt );
        }

        protected override function _onHide() : void {
            super._onHide();
            var ui : EquTrainUI = _ui;
            ui.tab.selectHandler = null;
            ui.tab.removeEventListener( Event.CHANGE, _onChangeViewStack );
            ui.equip_list.renderHandler = null;
            ui.equip_list.selectHandler = null;

            system.removeEventListener( CPlayerEvent.EQUIP_DATA, _showPrompt );
        }

        private function _showPrompt( e : CPlayerEvent ) : void {
        _showPropertyAddTips();
    }

        private function _showPropertyAddTips() : void {
//            var rootTabIndex : int = RoleMainUI( rootUI ).tab_list.selectedIndex;
//            if ( rootTabIndex != 3 ) {
//                return;
//            }
            if ( !_currentEquipData )return;
            _addPower = this._currentBattleValue() - _currentPower;
            _currentPower = this._currentBattleValue();
            if ( _currentEquipData.part > 4 ) {
                _addAttack = _currentEquipData.propertyData.PercentEquipATK - _currentAttack;
                _addDefense = _currentEquipData.propertyData.PercentEquipDEF - _currentDefense;
                _addHP = _currentEquipData.propertyData.PercentEquipHP - _currentHP;
            } else {
                _addAttack = _currentEquipData.propertyData.Attack - _currentAttack;
                _addDefense = _currentEquipData.propertyData.Defense - _currentDefense;
                _addHP = _currentEquipData.propertyData.HP - _currentHP;
            }
            var txt : String = "";
            if ( !_addPower == 0 ) {
                txt += CLang.Get( "battleValue" ) + "  +" + _addPower + "\n";
            }
            if ( !_addAttack == 0 ) {
                if ( _currentEquipData.part > 4 ) {
                    txt += CLang.Get( "player_attack" ) + "     +" + (_addAttack / 100).toFixed( 2 ) + "%" + "\n";
                } else {
                    txt += CLang.Get( "player_attack" ) + "     +" + _addAttack + "\n";
                }
            }
            if ( !_addDefense == 0 ) {
                if ( _currentEquipData.part > 4 ) {
                    txt += CLang.Get( "player_denfense" ) + "     +" + (_addDefense / 100).toFixed( 2 ) + "%" + "\n";
                } else {
                    txt += CLang.Get( "player_denfense" ) + "     +" + _addDefense + "\n";
                }
            }
            if ( !_addHP == 0 ) {
                if ( _currentEquipData.part > 4 ) {
                    txt += CLang.Get( "player_hp" ) + "     +" + (_addHP / 100).toFixed( 2 ) + "%" + "\n";
                } else {
                    txt += CLang.Get( "player_hp" ) + "     +" + _addHP + "\n";
                }
            }
            (system.stage.getSystem( CUISystem ) as CUISystem).showMsgProperChange( txt );
        }

        private function _currentBattleValue() : int {
            //战队数据
            var playerManager : CPlayerManager = system.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
            var playerData : CPlayerData = playerManager.playerData;
            return playerData.teamData.battleValue;
        }

        public override function updateWindow() : Boolean {
            if ( super.updateWindow() == false ) return false;
            _currentPower = this._currentBattleValue();
            _showData( _currentIndex );
            return true;
        }

        private function _showData( index : int = 0 ) : void {
            var equipList : Array = _data[ 2 ];
            var equipData : CHeroEquipData = equipList[ index ]; // 第一个装备
            _currentEquipData = equipData;
            if ( equipData.part > 4 ) {
                _currentAttack = equipData.propertyData.PercentEquipATK;
                _currentDefense = equipData.propertyData.PercentEquipDEF;
                _currentHP = equipData.propertyData.PercentEquipHP;
            } else {
                _currentAttack = equipData.propertyData.Attack;
                _currentDefense = equipData.propertyData.Defense;
                _currentHP = equipData.propertyData.HP;
            }
            _currentIndex = index;
            var ui : EquTrainUI = _ui;
            ui.equip_list.dataSource = equipList;
            _dataTable = _data[ 3 ][ 0 ];
            _bagManager = _data[ 3 ][ 1 ];

            var url : String = equipData.bigIcon;
            if ( equipData.part > 4 ) {
                var atk : String = "0";
                var def : String = "0";
                var hp : String = "0";
                if ( equipData.propertyData.PercentEquipATK > 0 ) {
                    atk = (equipData.propertyData.PercentEquipATK / 100).toFixed( 2 ) + "%";
                }
                if ( equipData.propertyData.PercentEquipDEF > 0 ) {
                    def = (equipData.propertyData.PercentEquipDEF / 100).toFixed( 2 ) + "%";
                }
                if ( equipData.propertyData.PercentEquipHP > 0 ) {
                    hp = (equipData.propertyData.PercentEquipHP / 100).toFixed( 2 ) + "%";
                }
                ui.equip_1.dataSource = {
                    name : {text : equipData.nameQualityWithColor},
                    ico : {url : url},
                    txt1 : {txt : {text : equipData.level + "/" + equipData.levelLimit}},
                    txt2 : {txt : {text : atk}},
                    txt3 : {txt : {text : def}},
                    txt4 : {txt : {text : hp}},
                    guangClip : {index : equipData.qualityLevelValue + 1}
                };
            } else {
                ui.equip_1.dataSource = {
                    name : {text : equipData.nameQualityWithColor},
                    ico : {url : url},
                    txt1 : {txt : {text : equipData.level + "/" + equipData.levelLimit}},
                    txt2 : {txt : {text : equipData.propertyData.Attack}},
                    txt3 : {txt : {text : equipData.propertyData.Defense}},
                    txt4 : {txt : {text : equipData.propertyData.HP}},
                    guangClip : {index : equipData.qualityLevelValue + 1}
                };
            }

            var starlist1 : List = (ui.equip_1.getChildByName( "list" ) as Box).getChildByName( "list" ) as List;
            var len : int = equipData.star;
            var arr1 : Array = [];
            var i : int = 0;
            for ( i = 0; i < len; i++ ) {
                arr1.push( i );
            }
            if ( _isFirstInto ) {
                _isFirstInto = false;
                var lenNu : int = arr1.length - 1;
                _lastStar1Nu = lenNu > -1 ? lenNu : -1;
            }

            starlist1.repeatX = arr1.length;
            starlist1.dataSource = arr1;
            starlist1.right = starlist1.right;

            starlist1.renderHandler = new Handler( _starList1Render );

            var nextStar : int = equipData.star + 1;
            if ( nextStar >= 5 ) {
                nextStar = 5;
            }
            ui.equip_2.dataSource = {
                ico : {url : url}
            };

            var starlist2 : List = (ui.equip_2.getChildByName( "list" ) as Box).getChildByName( "list" ) as List;
            len = equipData.star;
            var arr2 : Array = [];
            for ( i = 0; i < len; i++ ) {
                arr2.push( i );
            }
            starlist2.repeatX = arr2.length;
            starlist2.dataSource = arr2;
            starlist2.right = starlist2.right;


            var arr : Array = [];
            arr = [];
            for ( i = 0; i < nextStar; i++ ) {
                arr.push( 1 );
            }
            if ( ui.tab.selectedIndex == 1 ) {
                starlist2.repeatX = arr.length;
                starlist2.dataSource = arr;
                starlist2.right = starlist2.right;
            }
        }

        private function _starList1Render( item : Component, idx : int ) : void {
            if ( _lastStar1Nu < idx && _currentEquipData.star != 0 ) {
                var box : Box = item as Box;
                var clip : FrameClip = box.getChildByName( "fxstar" ) as FrameClip;
                clip.play();
                clip.addEventListener( Event.ENTER_FRAME, _hideFxstar );
                _lastStar1Nu = idx;
                _ui.fxUpstar.playFromTo();
            }
        }

        private function _hideFxstar( e : Event ) : void {
            var clip : FrameClip = (e.target as FrameClip);
            if ( clip.mc.currentFrame > 20 ) {
                clip.stop();
                clip.removeEventListener( Event.ENTER_FRAME, _hideFxstar );
                clip.index = 0;
            }
        }

        private function _onRender( item : Component, idx : int ) : void {
            var itemUI : EquItemUI = item as EquItemUI;
            var equiData : CHeroEquipData = itemUI.dataSource as CHeroEquipData;
            var itemData : CBagData = null;
            itemUI.name_label.text = equiData.name;
            itemUI.quality_clip.index = (item.dataSource as CHeroEquipData).qualityLevelValue + 1;
            itemUI.level_label.text = CLang.Get( "equip_level" ) + equiData.level;
//        itemData = _bagManager.getBagItemByUid(equiData.equipID); //当前拥有
            itemUI.icon_img.url = equiData.smallIcon;
            var arr : Array = [];
            for ( var i : int = 0; i < equiData.star; i++ ) {
                arr.push( 1 );
            }
            itemUI.star_list.repeatX = equiData.star;
            itemUI.star_list.dataSource = arr;
//        itemUI.star_list.x = itemUI.star_list.parent.width - itemUI.star_list.width - itemUI.star_list.right;
//        itemUI.star_list.right = itemUI.star_list.right;
            // itemUI.star_list.width = itemUI.star_list.width;
            itemUI.star_list.right = itemUI.star_list.right;
            arr = [];
            for ( var j : int = 0; j < equiData.qualityLevelSubValue; j++ ) {
                arr.push( equiData );
            }
            itemUI.quality_list.repeatX = arr.length;
            itemUI.quality_list.dataSource = arr;
            itemUI.quality_list.centerX = itemUI.quality_list.centerX;
            itemUI.quality_list.renderHandler = new Handler( _onItemRender );

            itemUI.toolTip = new Handler( _showTips, [ itemUI, equiData ] );
        }

        private function _showTips( item : EquItemUI, equiData : CHeroEquipData ) : void {
//            _itemSystem.addTips(CItemTipsView,item);
            _tipsView.showEquiTips( item, equiData );
        }

        private function get _itemSystem() : CItemSystem {
            return (uiCanvas as CAppSystem).stage.getSystem( CItemSystem ) as CItemSystem;
        }

        private function _onItemRender( item : Component, idx : int ) : void {
            var itemClip : Box = item as Box;
            if ( !item.dataSource )return;
            var qualityColor : int = (item.dataSource as CHeroEquipData).qualityLevelValue - 1;
            (itemClip.getChildByName( "quality" ) as Clip).index = qualityColor;
        }

        private function _selectItemHandler( index : int ) : void {
            if ( _currentIndex == index ) return;
            var ui : EquTrainUI = _ui;
            if ( ui.tab.selectedIndex == 0 ) {
                _isFirstInto = true;
                _lastStar1Nu = -1;
                lvAndQualityView.showData( index );
            }
            else {
                _isFirstInto = true;
                _lastStar1Nu = -1;
                starView.showData( index );
            }
            _showData( index );
        }

        private function _onChangeViewStack( e : Event ) : void {
            var ui : EquTrainUI = _ui;
            tabPage = ui.tab.selectedIndex;
            if ( ui.tab.selectedIndex == 0 ) {
                _isFirstInto = true;
                _lastStar1Nu = -1;
                lvAndQualityView.showData( _currentIndex );
            }
            else {
                _isFirstInto = true;
                _lastStar1Nu = -1;
                starView.showData( _currentIndex );
            }
            _showData( _currentIndex );
        }

        private function updateShow( obj : Object ) : void {
            lvAndQualityView.updateShow( obj );
        }

        override public function setData( value : Object, forceInvalid : Boolean = true ) : void {
            super.setData( value, forceInvalid );
            this.setChildrenData( value, forceInvalid );

            // _heroListView.setArgs([value[1]]);

//            var heroList : CPlayerHeroListData = (value[ 0 ].heroList as CPlayerHeroListData);
//            heroList.sort();
            // _heroListView.setData(heroList.list);

            _onChangeViewStack( null );

        }

        public function get currentEquipData() : CHeroEquipData {
            return _currentEquipData;
        }

        public function updateStone( stoneIndex : int ) : void {
            starView.updateStone( stoneIndex );
        }

        private function get lvAndQualityView() : CEquTrainLevelUpAndQualityView {
            return getChild( 1 ) as CEquTrainLevelUpAndQualityView;
        }

        private function get starView() : CEquTrainStarView {
            return getChild( 0 ) as CEquTrainStarView;
        }

        private function get _ui() : EquTrainUI {
            return /*(rootUI as RoleMainUI).viewStack.items[ EPlayerWndTabType.STACK_ID_HERO_WND_EQUIP_TRAIN ] as EquTrainUI;*/null;
        }
    }
}
