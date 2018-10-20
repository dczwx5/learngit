//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/11/22.
 * Time: 11:42
 */
package kof.game.player.view.playerTrain {

import kof.game.common.CLang;
import kof.game.common.view.CChildView;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.data.CPlayerHeroListData;
import kof.game.player.enum.EPlayerWndTabType;
import kof.game.player.event.CPlayerEvent;
import kof.game.player.view.playerTrain.tabPage.CPlayerTrainLevelUPView;
import kof.game.player.view.playerTrain.tabPage.CPlayerTrainQualityView;
import kof.game.player.view.playerTrain.tabPage.CPlayerTrainStarView;
import kof.table.Skill;
import kof.ui.CUISystem;

import morn.core.components.Component;
import morn.core.handlers.Handler;

public class CPlayerHeroTrainViewHandler extends CChildView { // change to childView
        //增加的属性
        private var _addPower : int = 0;
        private var _addAttack : int = 0;
        private var _addDefense : int = 0;
        private var _addHP : int = 0;
        private var _currentPower : int = 0;
        private var _currentAttack : int = 0;
        private var _currentDefense : int = 0;
        private var _currentHP : int = 0;

        private var _heroData : CPlayerHeroData = null;

        public function CPlayerHeroTrainViewHandler() {
            super( [ CPlayerTrainLevelUPView, CPlayerTrainQualityView, CPlayerTrainStarView ] );
        }

        protected override function _onShow() : void {
            super._onShow();
            var ui : Object = _ui;
            ui.tab.selectHandler = ui.viewStack.setIndexHandler;
            ui.skill_list.renderHandler = new Handler( _renderSkill );

            system.addEventListener( CPlayerEvent.HERO_DATA, _showPrompt );
        }

        private function _renderSkill( item : Component, idx : int ) : void {
            if ( !(item is Object) ) {
                return;
            }
            var pSkillItemUI : Object = item as Object;
            var pSkill : Skill = _data[ 0 ].skillTable.findByPrimaryKey( pSkillItemUI.dataSource );
            if ( pSkill ) {
                pSkillItemUI.icon_img.url = CPlayerPath.getSkillBigIcon( pSkill.IconName );
            }
        }

        protected override function _onHide() : void {
            super._onHide();
            var ui : Object = _ui;
            ui.skill_list.renderHandler = null;
            system.removeEventListener( CPlayerEvent.HERO_DATA, _showPrompt );
        }

        private function _showPrompt( e : CPlayerEvent ) : void {
            _showPropertyAddTips();
        }

        private function _showPropertyAddTips() : void {
            var rootTabIndex : int = Object( rootUI ).tab_list.selectedIndex;
            if ( rootTabIndex != 2 ) {
                return;
            }
            _addPower = this._currentBattleValue() - _currentPower;
            _addAttack = _heroData.propertyData.Attack - _currentAttack;
            _addDefense = _heroData.propertyData.Defense - _currentDefense;
            _addHP = _heroData.propertyData.HP - _currentHP;
            if ( _addPower != 0 || _addAttack != 0 || _addDefense != 0 || _addHP != 0 ) {
                var txt : String = "";
                if ( _addPower != 0 ) {
                    txt += CLang.Get( "battleValue" ) + "  +" + _addPower + "\n";
                }
                if ( _addAttack != 0 ) {
                    txt += CLang.Get( "player_attack" ) + "     +" + _addAttack + "\n";
                }
                if ( _addDefense != 0 ) {
                    txt += CLang.Get( "player_denfense" ) + "     +" + _addDefense + "\n";
                }
                if ( _addHP != 0 ) {
                    txt += CLang.Get( "player_hp" ) + "     +" + _addHP + "\n";
                }
                (system.stage.getSystem( CUISystem ) as CUISystem).showMsgProperChange( txt );
            }
        }

        public override function updateWindow() : Boolean {
            if ( super.updateWindow() == false ) return false;
            _currentPower = this._currentBattleValue();
            var ui : Object = _ui;
            ui.info_face_img.url = CPlayerPath.getUIHeroFacePath( _data[ 1 ] );
            var playerData : CPlayerData = _data[ 0 ] as CPlayerData;
            var heroListData : CPlayerHeroListData = playerData.heroList;
            var selectHeroData : CPlayerHeroData = (heroListData.list[ 0 ] as CPlayerHeroData);
            _heroData = selectHeroData;
            ui.skill_list.visible = false;
            _currentAttack = selectHeroData.propertyData.Attack;
            _currentDefense = selectHeroData.propertyData.Defense;
            _currentHP = selectHeroData.propertyData.HP;
            return true;
        }

        private function _currentBattleValue() : int {
            //战队数据
            var playerManager : CPlayerManager = system.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
            var playerData : CPlayerData = playerManager.playerData;
            return playerData.teamData.battleValue;
        }

        override public function setData( value : Object, forceInvalid : Boolean = true ) : void {
            super.setData( value, forceInvalid );
            this.setChildrenData( value, forceInvalid );
        }

        private function get levelUPView() : CPlayerTrainLevelUPView {
            return getChild( LEVEL_UP ) as CPlayerTrainLevelUPView
        }

        private function get _ui() : Object {
            return (rootUI as Object).viewStack.items[ EPlayerWndTabType.STACK_ID_HERO_WND_TRAIN ] as Object;
        }

        private const LEVEL_UP : int = 0;
    }
}
