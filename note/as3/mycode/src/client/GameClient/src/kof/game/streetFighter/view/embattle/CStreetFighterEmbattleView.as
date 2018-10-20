//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/25.
 */
package kof.game.streetFighter.view.embattle {

import flash.events.Event;
import flash.events.MouseEvent;

import kof.game.common.CLang;

import kof.game.common.view.CRootView;
import kof.game.common.view.event.CViewEvent;
import kof.game.instance.enum.EInstanceType;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CEmbattleData;
import kof.game.player.data.CEmbattleListData;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.streetFighter.control.CStreetFighterControler;
import kof.game.streetFighter.control.CStreetFighterEmbattleControler;
import kof.game.streetFighter.data.CStreetFighterData;
import kof.game.streetFighter.enum.EStreetFighterViewEventType;
import kof.game.streetFighter.view.CStreetFighterViewUtil;
import kof.ui.master.StreetFighter.StreetFighterDuelUI;
import kof.ui.master.StreetFighter.StreetFighterarrayUI;
import kof.ui.master.taskcallup.TaskCallUpHeroItemUI;

import morn.core.components.Component;
import morn.core.handlers.Handler;


public class CStreetFighterEmbattleView extends CRootView {
    public function CStreetFighterEmbattleView() {
        super(StreetFighterarrayUI, null, null, false);
    }

    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);
    }
    protected override function _onCreate() : void {
        _isFrist = true;

    }
    protected override function _onDispose() : void {
        // can not call super._onDispose in this class
    }
    protected override function _onShow():void {
        _ui.tab.selectedIndex = -1;
        // can not call super._onShow in this class
        _ui.tab.selectHandler = new Handler(_onTabChange);

        _ui.hero_list.renderHandler = new Handler(_renderItem);
        _ui.hero_list.mouseHandler = new Handler(_onSelectHeroList);

        _ui.embattle_hero_list.renderHandler = new Handler(_onRenderEmbattleHeroItem);
        _ui.embattle_hero_list.mouseHandler = new Handler(_onClickEmbattleHeroItem);

        _ui.one_key_btn.clickHandler = new Handler(_onOneKey);
    }

    protected override function _onHide() : void {
        _ui.hero_list.renderHandler = null;
        _ui.hero_list.mouseHandler = null;
        _ui.one_key_btn.clickHandler = null;
        _ui.hero_list.renderHandler = null;
        _ui.hero_list.mouseHandler = null;

        _ui.tab.selectHandler = null;

    }
    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        var tabIndex:int = _ui.tab.selectedIndex;
        if (tabIndex == -1) {
            _ui.tab.selectedIndex = 0;
        } else {
            _onTabChange(tabIndex);
        }

        // 已出阵格斗家
        var emListData:CEmbattleListData = _playerData.embattleManager.getByType(EInstanceType.TYPE_STREET_FIGHTER);
        _ui.embattle_hero_list.dataSource = emListData.list;

        this.addToPopupDialog();

        return true;
    }

    private function _onTabChange(tabIdx:int) : void {
        var heroList:Array = _playerData.heroList.getSortList(EInstanceType.TYPE_STREET_FIGHTER) as Array;
        // 0 : all , 1 : 攻, 2 : 防, 3 : 技
        if (tabIdx == 0) {
            _ui.hero_list.dataSource = heroList;
        } else {
            var job:int = tabIdx - 1;
            var newHeroList:Array = new Array();
            for (var i:int = 0; i < heroList.length; i++) {
                var heroData:CPlayerHeroData = heroList[i] as CPlayerHeroData;
                if (heroData.job == job) {
                    newHeroList[newHeroList.length] = heroData;
                }
            }
            _ui.hero_list.dataSource = newHeroList;
        }
    }

    // ==============================================================左边的已上阵列表// ==============================================================
    private function _onRenderEmbattleHeroItem(comp:Component, idx:int) : void {
        CStreetFighterViewUtil._onRenderHeroItem(_playerData, comp, idx, null, _streetData, false);
        (comp as StreetFighterDuelUI).hp_bar.visible = false;
    }
    private function _onClickEmbattleHeroItem(e:Event, index:int) : void {
        if ( e.type != MouseEvent.CLICK) return ;

        var heroItem:StreetFighterDuelUI = e.currentTarget as StreetFighterDuelUI;
        if (!heroItem) return ;

        var dataSource:CEmbattleData = heroItem.dataSource as CEmbattleData;
        if (!dataSource) return ;

        var pControll:CStreetFighterControler = controlList[0];
        var minCount:int = pControll.embattleMinCount;
        var count:int = _playerData.embattleManager.getHeroCountByType(EInstanceType.TYPE_STREET_FIGHTER);
        if (count <= minCount) {
            uiCanvas.showMsgAlert(CLang.Get("common_embattle_less", {v1:minCount}));
            return ;
        }
        if (_streetData.alreadyStartFight) {
            uiCanvas.showMsgAlert(CLang.Get("street_can_not_change_embattle"));
            return ;
        }

        // 下阵
        ((controlList[0] as CStreetFighterEmbattleControler).removeHeroFromEmbattle(dataSource.prosession));
    }

    // ==============================================================右边的herolist// ==============================================================
    private function _renderItem(comp:Component, idx:int) : void {
        if (comp == null) return ;

        var dataSource:CPlayerHeroData = comp.dataSource as CPlayerHeroData;
        if (!dataSource) {
            comp.visible = false;
            return ;
        }
        comp.visible = true;

        var heroItem:TaskCallUpHeroItemUI = comp as TaskCallUpHeroItemUI;
        var playerHeroData : CPlayerHeroData = heroItem.dataSource as CPlayerHeroData;
        heroItem.clip_quality.index = playerHeroData.qualityBaseType;
        heroItem.clip_state.visible = false;
        heroItem.clip_type.visible = false;
        heroItem.star_list.visible = false;

        heroItem.icon_image.cacheAsBitmap = true;
        heroItem.hero_icon_mask.cacheAsBitmap = true;
        heroItem.icon_image.mask = heroItem.hero_icon_mask;
        heroItem.icon_image.url = CPlayerPath.getHeroBigconPath(playerHeroData.ID);

        var isInEmbattle:Boolean = false;
        var emListData:CEmbattleListData = _playerData.embattleManager.getByType(EInstanceType.TYPE_STREET_FIGHTER);
        for each (var emData:CEmbattleData in emListData.list) {
            if (emData.prosession == playerHeroData.prototypeID) {
                isInEmbattle = true;
                break ;
            }
        }

        if( isInEmbattle ){
            heroItem.clip_state.index = 2;
            heroItem.clip_state.visible = true;
        } else {
            heroItem.clip_state.visible = false;
        }

        heroItem.clip_type.index = playerHeroData.job;
    }

    private function _onSelectHeroList(e:Event, index:int) : void {
        if ( e.type != MouseEvent.CLICK) return ;

        var pController:CStreetFighterEmbattleControler = (controlList[0] as CStreetFighterEmbattleControler);
        var embattleMaxCount:int = pController.embattleMaxCount;


        if (_streetData.alreadyStartFight) {
            uiCanvas.showMsgAlert(CLang.Get("street_can_not_change_embattle"));
            return ;
        }

        var selectHeroItem:Component = _ui.hero_list.getCell(index);
        var heroData:CPlayerHeroData = selectHeroItem.dataSource as CPlayerHeroData;
        if (pController.isHeroInEmbattle(heroData.ID)) {
            // 已在阵，下阵
            var minCount:int = pController.embattleMinCount;
            var count:int = _playerData.embattleManager.getHeroCountByType(EInstanceType.TYPE_STREET_FIGHTER);
            if (count <= minCount) {
                uiCanvas.showMsgAlert(CLang.Get("common_embattle_less", {v1:minCount}));
                return ;
            }
            pController.removeHeroFromEmbattle(heroData.ID);
            return ;
        }

        var emListData:CEmbattleListData = _playerData.embattleManager.getByType(EInstanceType.TYPE_STREET_FIGHTER);
        if (emListData.list.length >= embattleMaxCount) {
            uiCanvas.showMsgAlert(CLang.Get("common_embattle_full"));
            return ;
        }

        pController.setHeroInEmbattle(heroData.ID, heroData.prototypeID);
    }

    private function _onOneKey() : void {
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EStreetFighterViewEventType.EMBATTLE_ONE_KEY_CLICK));
    }

    [Inline]
    public function get _ui() : StreetFighterarrayUI {
        return (rootUI as StreetFighterarrayUI);
    }
    [Inline]
    private function get _streetData() : CStreetFighterData {
        return super._data[0] as CStreetFighterData;
    }
    [Inline]
    private function get _playerData() : CPlayerData {
        return super._data[1] as CPlayerData;
    }

    private var _isFrist:Boolean = true;
}
}
