//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/4/26.
 */
package kof.game.cultivate.view.embattle {

import flash.events.Event;
import flash.events.Event;
import flash.events.MouseEvent;

import kof.game.common.CLang;
import kof.game.common.view.CViewBase;
import kof.game.common.view.event.CViewEvent;
import kof.game.cultivate.controller.CCultivateEmbattleControl;
import kof.game.cultivate.data.CClimpData;
import kof.game.cultivate.data.cultivate.CCultivateData;
import kof.game.common.view.CChildView;
import kof.game.cultivate.data.cultivate.CCultivateLevelData;
import kof.game.cultivate.enum.ECultivateViewEventType;
import kof.game.instance.enum.EInstanceType;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CEmbattleData;
import kof.game.player.data.CEmbattleListData;
import kof.game.player.data.CHeroExtendsData;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.data.CPlayerHeroData;
import kof.ui.master.cultivate.CultivateEmbattleHeroUI;
import kof.ui.master.cultivate.CultivateEmbattleUI;
import kof.ui.master.taskcallup.TaskCallUpHeroItemUI;

import morn.core.components.Component;
import morn.core.components.ProgressBar;

import morn.core.handlers.Handler;
import morn.core.utils.ObjectUtils;

public class CCultivateEmbattleHeroList extends CChildView {
    public function CCultivateEmbattleHeroList() {
        super ()
    }
    protected override function _onCreate() : void {
        _isFrist = true;
        // can not call super._onCreate in this class
        _ui.hero_1_view.icon_img.cacheAsBitmap = true;
        _ui.hero_1_view.icon_img_mask.cacheAsBitmap = true;
        _ui.hero_1_view.icon_img.mask = _ui.hero_1_view.icon_img_mask;

        _ui.hero_2_view.icon_img.cacheAsBitmap = true;
        _ui.hero_2_view.icon_img_mask.cacheAsBitmap = true;
        _ui.hero_2_view.icon_img.mask = _ui.hero_2_view.icon_img_mask;
    }
    protected override function _onDispose() : void {
        // can not call super._onDispose in this class
    }

    protected override function _onShowing():void {
    }

    protected override function _onShow():void {
        _ui.hero_list.renderHandler = new Handler(_renderItem);
        _ui.hero_list.mouseHandler = new Handler(_onSelectHeroList);
        _ui.tips_img.toolTip = CLang.Get("cultivate_embattle_tips");

        _ui.hero_1_view.addEventListener(MouseEvent.CLICK, _onClickInEmbattleHero);
        _ui.hero_2_view.addEventListener(MouseEvent.CLICK, _onClickInEmbattleHero);

        _ui.fight_btn.clickHandler = new Handler(_onFight);

    }
    protected override function _onHide() : void {
        _ui.hero_list.renderHandler = null;
        _ui.hero_list.mouseHandler = null;
        _ui.tips_img.toolTip = null;

        _ui.hero_1_view.removeEventListener(MouseEvent.CLICK, _onClickInEmbattleHero);
        _ui.hero_2_view.removeEventListener(MouseEvent.CLICK, _onClickInEmbattleHero);

        _ui.fight_btn.clickHandler = null;
    }

    // ===========update and render
    public virtual override function updateWindow() : Boolean {
        if (false ==  super.updateWindow()) {
            return false;
        }

        var heroList:Array = _playerData.heroList.getSortList(EInstanceType.TYPE_CLIMP_CULTIVATE) as Array;
        _ui.hero_list.dataSource = heroList;

        // 已出阵格斗家
        var emListData:CEmbattleListData = _playerData.embattleManager.getByType(EInstanceType.TYPE_CLIMP_CULTIVATE);
        var heroData:CPlayerHeroData;
        var emData:CEmbattleData = emListData.getByPos(1);
        if (emData) {
            heroData = _playerData.heroList.getHero(emData.prosession);
            _renderSelectItem(_ui.hero_1_view, heroData);
        } else {
            _renderSelectItem(_ui.hero_1_view, null);
        }
        emData = emListData.getByPos(2);
        if (emData) {
            heroData = _playerData.heroList.getHero(emData.prosession);
            _renderSelectItem(_ui.hero_2_view, heroData);
        } else {
            _renderSelectItem(_ui.hero_2_view, null);
        }

        return true;
    }

    private function _renderSelectItem(heroItem:CultivateEmbattleHeroUI, heroData:CPlayerHeroData) : void {
        heroItem.dataSource = heroData;
        if (heroData) {
            heroItem.icon_img.url = CPlayerPath.getPeakUIHeroFacePath( heroData.prototypeID );
            heroItem.name_txt.text = heroData.heroName;
            heroItem.bg_no_hero_img.visible = false;
            heroItem.bg_has_hero_img.visible = true;
            heroItem.job_clip.visible = true;
            heroItem.job_clip.index = heroData.job;
        } else {
            heroItem.icon_img.url = null;
            heroItem.name_txt.text = "";
            heroItem.bg_no_hero_img.visible = true;
            heroItem.bg_has_hero_img.visible = false;
            heroItem.job_clip.visible = false;

        }
    }

    private function _onClickInEmbattleHero(e:Event) : void {
        var heroItem:CultivateEmbattleHeroUI = e.currentTarget as CultivateEmbattleHeroUI;
        if (!heroItem) return ;

        var dataSource:CPlayerHeroData = heroItem.dataSource as CPlayerHeroData;
        if (!dataSource) return ;

        // 下阵
        ((rootView as CViewBase).controlList[0] as CCultivateEmbattleControl).removeHeroFromEmbattle(dataSource.ID);
    }

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
        var emListData:CEmbattleListData = _playerData.embattleManager.getByType(EInstanceType.TYPE_CLIMP_CULTIVATE);
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
        ObjectUtils.gray(heroItem.icon_image, false);


        var heroExtendsData:CHeroExtendsData = playerHeroData.extendsData as CHeroExtendsData;
        if (heroExtendsData) {
            // 添加血条处理 auto
            var hpBar:ProgressBar = heroItem.hp_bar;
            var hpMax:int = heroExtendsData.maxHP;
            var hpCur:int = heroExtendsData.hp;
            if (hpMax > 0) {
                hpBar.value = hpCur / hpMax;
            } else {
                hpBar.value = 1;
            }
            hpBar.visible = true;

            if (hpCur == 0) {
                ObjectUtils.gray(heroItem.icon_image, true);
            }
        }
    }

    private function _onSelectHeroList(e:Event, index:int) : void {
        if ( e.type != MouseEvent.CLICK) return ;

        var emListData:CEmbattleListData = _playerData.embattleManager.getByType(EInstanceType.TYPE_CLIMP_CULTIVATE);
        if (emListData.list.length >= 2) {
            uiCanvas.showMsgAlert(CLang.Get("common_embattle_full"));
            return ;
        }

        var selectHeroItem:Component = _ui.hero_list.getCell(index);
        var heroData:CPlayerHeroData = selectHeroItem.dataSource as CPlayerHeroData;
        if ((heroData.extendsData as CHeroExtendsData).hp <= 0) {
            return ;
        }

        ((rootView as CViewBase).controlList[0] as CCultivateEmbattleControl).setHeroInEmbattle(heroData.ID, heroData.prototypeID);
    }

    private function _onFight() : void {

       sendEvent(new CViewEvent(CViewEvent.UI_EVENT, ECultivateViewEventType.EMBATTLE_FIGHT, _initialArgs[0] as CCultivateLevelData));
    }

    [Inline]
    public function get _ui() : CultivateEmbattleUI {
        return (rootUI as CultivateEmbattleUI);
    }
    [Inline]
    public function get _climpData() : CClimpData {
        return super._data[0] as CClimpData;
    }
    [Inline]
    private function get _cultivateData() : CCultivateData {
        return _climpData.cultivateData;
    }
    [Inline]
    private function get _playerData() : CPlayerData {
        return super._data[1] as CPlayerData;
    }

    private var _isFrist:Boolean = true;

}
}