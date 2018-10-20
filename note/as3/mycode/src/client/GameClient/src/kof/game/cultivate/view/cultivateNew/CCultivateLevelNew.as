//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/4/27.
 */
package kof.game.cultivate.view.cultivateNew {


import com.greensock.TweenLite;

import kof.game.common.CLang;
import kof.game.common.hero.CHeroEmbattleListView;
import kof.game.common.view.CViewBase;
import kof.game.common.view.event.CViewEvent;
import kof.game.common.view.reward.CShowRewardViewUtil;
import kof.game.cultivate.controller.CCultivateControl;
import kof.game.cultivate.data.CClimpData;
import kof.game.cultivate.data.cultivate.CCultivateData;
import kof.game.common.view.CChildView;
import kof.game.cultivate.data.cultivate.CCultivateLevelDefenderData;
import kof.game.cultivate.data.cultivate.CCultivateLevelListData;
import kof.game.cultivate.enum.ECultivateViewEventType;
import kof.game.cultivate.view.CCultivateLevelInfo;
import kof.game.instance.enum.EInstanceType;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CEmbattleData;
import kof.game.player.data.CEmbattleListData;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.ui.master.cultivate.CultivateNewIIUI;
import kof.ui.master.taskcallup.TaskCallUpHeroItemUI;

import morn.core.components.Component;

import morn.core.components.ProgressBar;
import morn.core.handlers.Handler;
import morn.core.utils.ObjectUtils;

public class CCultivateLevelNew extends CChildView {
    public function CCultivateLevelNew() {
        super ()
    }
    protected override function _onCreate() : void {
        // can not call super._onCreate in this class
        _isFirst = true;
        _ui.fight_info_box.cacheAsBitmap = true;
        _ui.fight_info_box_mask.cacheAsBitmap = true;
        _ui.fight_info_box.mask = _ui.fight_info_box_mask;
        _baseFightInfoMaskHeight = _ui.fight_info_box_mask.height;

        _ui.level_info_box.cacheAsBitmap = true;
        _ui.level_info_box_mask.cacheAsBitmap = true;
        _ui.level_info_box.mask = _ui.level_info_box_mask;
        _baseLevelInfoMaskHeight = _ui.level_info_box_mask.height;

    }
    protected override function _onDispose() : void {
        // can not call super._onDispose in this class
    }

    protected override function _onShowing():void {
    }

    protected override function _onShow():void {
        _ui.monster_list.renderHandler = new Handler(_onMonsterRender);
        _ui.level_info_box_mask.height = _baseLevelInfoMaskHeight;
        _ui.fight_info_box_mask.height = _baseFightInfoMaskHeight;
        _ui.level_info_box.alpha = 1.0;

    }
    protected override function _onHide() : void {
        _ui.monster_list.renderHandler = null;
        TweenLite.killTweensOf( _ui.fight_info_box_mask, true );
        TweenLite.killTweensOf( _ui.level_info_box_mask, true );
        TweenLite.killTweensOf( _ui.level_info_box, true );

        _ui.effect_reset_clip.visible = false;
        _ui.effect_reset_clip.stop();
        _ui.effect_first_start_clip.visible = false;
        _ui.effect_first_start_clip.stop();
        _ui.level_info_box_mask.height = _baseLevelInfoMaskHeight;
        _ui.fight_info_box_mask.height = _baseFightInfoMaskHeight;
        _ui.level_info_box.alpha = 1.0;

    }

    // ===========update and render
    public virtual override function updateWindow() : Boolean {
        if (false ==  super.updateWindow()) {
            return false;
        }

        if (isShowFadeInOut) {
            isShowFadeInOut = false;
            showFadeInOut();
            return true;
        }

        if (isAllPass) {
            _ui.all_level_pass_txt.visible = true;
            _ui.level_info_box.visible = false;
            return true;
        }
        _ui.level_info_box.visible = true;
        _ui.all_level_pass_txt.visible = false;

        var levelListData:CCultivateLevelListData = _climpData.cultivateData.levelList;
        var curOpenLevelIndex:int = levelListData.curOpenLevelIndex;
        _levelInfo = new CCultivateLevelInfo(levelListData, curOpenLevelIndex, curOpenLevelIndex);

        // 关卡内容
        var strLevelIndex:String = "common_number_china_" + curOpenLevelIndex;
        _ui.title.text = CLang.Get("cultivate_title_name", {v1:CLang.Get(strLevelIndex)});
        _ui.level_name.text = _levelInfo.levelData.descRecord.Name;
        _ui.level_desc.text = _levelInfo.levelData.descRecord.Desc;

        // 奖励
        CShowRewardViewUtil.show(this, _ui, _levelInfo.levelData.reward);

        // 怪物列表
        _ui.monster_list.dataSource = _levelInfo.levelData.defenderList.list;

        // 阵容数据
        var enemyPower:int = _levelInfo.levelData.enemyPower;
        _ui.enemyPowerTxt.text = enemyPower.toString();

        _renderEmbattleList();

        return true;
    }

    private function _renderEmbattleList() : void {
        sendEvent(new CViewEvent(CViewEvent.UPDATE_VIEW));

        var heroListData:Array = new Array(3);
        var emListData:CEmbattleListData = _playerData.embattleManager.getByType(EInstanceType.TYPE_CLIMP_CULTIVATE);
        if (emListData) {
            for (var i:int = 0; i < 3; i++) {
                var emData:CEmbattleData = emListData.getByPos(i+1);
                if (emData) {
                    heroListData[i] = _playerData.heroList.getHero(emData.prosession);
                } else {
                    heroListData[i] = null;
                }
            }
        }

        if (_heroEmbattleList == null) {
            _heroEmbattleList = new CHeroEmbattleListView(system, _ui.hero_em_list, EInstanceType.TYPE_CLIMP_CULTIVATE, null, null, false, false, false, false);
        }
        _heroEmbattleList.updateWindow();

        if (_isFirst) {
            _isFirst = false;
            if (!_hasEmbattleData) {
                sendEvent(new CViewEvent(CViewEvent.UI_EVENT, ECultivateViewEventType.MAIN_SEND_EMBATTLE_FIRST));
            }
        }

        var allBattleValue:Number = 0;
        for each (var heroData:CPlayerHeroData in heroListData) {
            if (heroData) {
                allBattleValue += ((rootView as CViewBase).controlList[0] as CCultivateControl).calcCultivateProperty(heroData ).getBattleValue();
            }
        }


        _ui.selfPowerTxt.text = ((int)(allBattleValue)).toString();
    }

    private function _onMonsterRender(comp:Component, idx:int) : void {
        var monsterItem:TaskCallUpHeroItemUI = comp as TaskCallUpHeroItemUI;
        monsterItem.clip_quality.visible = false;
        monsterItem.clip_state.visible = false;
        monsterItem.clip_type.visible = true;
        monsterItem.star_list.visible = false;



        var hp_bar:ProgressBar = monsterItem.hp_bar as ProgressBar;
        ObjectUtils.gray(monsterItem, false);
        var hp:Number = 1.0;
        var defenderData:CCultivateLevelDefenderData = monsterItem.dataSource as CCultivateLevelDefenderData;
        if (defenderData) {
            if (defenderData.maxHP == 0) {
                hp = 1.0;
            } else {
                hp = defenderData.HP / defenderData.maxHP;
                if (defenderData.HP == 0) {
                    ObjectUtils.gray(monsterItem, true);
                }
            }
        }
        hp_bar.value = hp;
        hp_bar.visible = true;

        monsterItem.icon_image.cacheAsBitmap = true;
        monsterItem.hero_icon_mask.cacheAsBitmap = true;
        monsterItem.icon_image.mask = monsterItem.hero_icon_mask;
        monsterItem.icon_image.url = CPlayerPath.getHeroBigconPath(defenderData.profession);

        var heroDataForMonster:CPlayerHeroData = _playerData.heroList.createHero(defenderData.profession);
        if (heroDataForMonster) {
            monsterItem.clip_type.index = heroDataForMonster.job;
        } else {
            monsterItem.clip_type.index = 0;
        }
    }


    public function get selectLevelInfo() : CCultivateLevelInfo {
        return _levelInfo;
    }

    // 中间显示动画
    public function playLevelInfoShowMovie() : void {
        if (!this.isShowState) {
            return ;
        }
        _ui.level_info_box_mask.height = 1;
        TweenLite.to(_ui.level_info_box_mask, 1, {height:_baseLevelInfoMaskHeight});
    }

    // 右边战斗信息表现
    public function playFightInfoShowMovie() : void {
        if (!this.isShowState) {
            return ;
        }
        _ui.fight_info_box_mask.height = 1;
        TweenLite.to(_ui.fight_info_box_mask, 1, {height:_baseFightInfoMaskHeight});
    }

    // ===============渐入渐出
    public function showFadeInOut() : void {
        _ui.level_info_box.alpha = 1.0;
        _ui.fight_info_box.alpha = 1.0;
        TweenLite.to(_ui.level_info_box, 3, {alpha:0, onComplete:function () : void {
            updateWindow();
            TweenLite.to(_ui.level_info_box, 2, {alpha:1});
        }});
        TweenLite.to(_ui.fight_info_box, 3, {alpha:0, onComplete:function () : void {
            TweenLite.to(_ui.fight_info_box, 2, {alpha:1});
        }});

    }

    // ===============重置动画
    public function playResetMovie() : void {
        _ui.level_info_box_mask.height = 1;
        _ui.effect_reset_clip.visible = true;
        _ui.effect_reset_clip.playFromTo(null, null, new Handler(_onResetEffectPlayCompleted));
    }
    private function _onResetEffectPlayCompleted() : void {
        _ui.effect_reset_clip.visible = false;

        if (!this.isShowState) {
            return ;
        }
        playLevelInfoShowMovie();
    }
    // =============================首次动画
    public function playFirstOpenMovie() : void {
        _ui.win_box.visible = false;
        _ui.effect_first_start_clip.visible = true;
        _ui.effect_first_start_clip.playFromTo(null, null, new Handler(_onPlayFirstOpenMovieCompleted));
    }
    private function _onPlayFirstOpenMovieCompleted() : void {
        _ui.effect_first_start_clip.visible = false;
        _ui.win_box.visible = true;

        if (!this.isShowState) {
            return ;
        }

        _ui.fight_info_box_mask.height = 1;
        _ui.level_info_box_mask.height = 1;

        playLevelInfoShowMovie();
        playFightInfoShowMovie();
    }

    [Inline]
    public function get _ui() : CultivateNewIIUI {
        return (rootUI as CultivateNewIIUI);
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

    private var _levelInfo:CCultivateLevelInfo;
    private var _heroEmbattleList:CHeroEmbattleListView;

    private function get _hasEmbattleData() : Boolean {
        return super._data[2] as Boolean;
    }
    private var _isFirst:Boolean = true;

    private var _baseLevelInfoMaskHeight:int;
    private var _baseFightInfoMaskHeight:int;
    public var isShowFadeInOut:Boolean;
    public var isAllPass:Boolean

}
}