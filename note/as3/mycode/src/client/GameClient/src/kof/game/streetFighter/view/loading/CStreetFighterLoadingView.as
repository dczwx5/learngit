//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/29.
 */
package kof.game.streetFighter.view.loading {

import kof.game.common.CLang;
import kof.game.common.loading.CLoadingEvent;
import kof.game.common.view.CRootView;
import kof.game.common.view.event.CViewEvent;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.streetFighter.data.CStreetFighterData;
import kof.game.streetFighter.data.match.CStreetFighterLoadingData;
import kof.ui.master.peak1v1.Peak1v1LoadingUI;

import morn.core.components.Clip;

import morn.core.components.Image;

import morn.core.components.Label;
import morn.core.components.ProgressBar;

public class CStreetFighterLoadingView extends CRootView {

    public function CStreetFighterLoadingView() {
        super(Peak1v1LoadingUI, null, null, false);
    }

    protected override function _onCreate() : void {
        _isFrist = true;
        _ui.p1_score_title_txt.visible = false;
        _ui.p2_score_title_txt.visible = false;
        _ui.p1_score_txt.visible = false;
        _ui.p2_score_txt.visible = false;
        _ui.score_1_bg_img.visible = false;
        _ui.score_2_bg_img.visible = false;
    }
    protected override function _onDispose() : void {

    }
    protected override function _onShow():void {
        listEnterFrameEvent = true;
        _isFirstUpdate = true;
        _isLoadFinish = false;
        _myVirtualRate = 0;
        _enemyVirtualRate = 0;
        _isMyLoadFinish = false;
        _isEnemyLoadFinish = false;
    }
    protected override function _onEnterFrame(delta:Number) : void {
        if (_isLoadFinish) return ;

        _updatePlayerProgress(_Data.myProgress, _Data.progressData.enemyProgress);
        var myRateTxt:Label;
        var myRateBar:ProgressBar;
        var enemyRateBTxt:Label;
        var enemyRateBar:ProgressBar;

        if (_Data.loadingData.isSelfP1) {
            myRateTxt = _ui.p1_load_rate_txt;
            myRateBar = _ui.p1_load_rate_bar;
            enemyRateBTxt = _ui.p2_load_rate_txt;
            enemyRateBar = _ui.p2_load_rate_bar;
        } else {
            myRateTxt = _ui.p2_load_rate_txt;
            myRateBar = _ui.p2_load_rate_bar;
            enemyRateBTxt = _ui.p1_load_rate_txt;
            enemyRateBar = _ui.p1_load_rate_bar;
        }

        myRateTxt.text = CLang.Get("peak1v1_loading_process_tips", {v1:(int)(_myVirtualRate*100)});
        myRateBar.value = _myVirtualRate;
        enemyRateBTxt.text = CLang.Get("peak1v1_loading_process_tips", {v1:(int)(_enemyVirtualRate*100)});
        enemyRateBar.value = _enemyVirtualRate;

        if (_isLoadVirtualFinish()) {
            rootView.dispatchEvent(new CLoadingEvent(CLoadingEvent.VIRTUAL_LOAD_FINISHED));
            _isLoadFinish = true;
        }
    }

    private function _updatePlayerProgress(myProgress:int, enemyProgress:int) : void {
        var reallyProgressRateP1:Number = myProgress/10000;
        var reallyProgressRateP2:Number = enemyProgress/10000;
        if (_isMyLoadFinish) {
            _myVirtualRate += _randomAddRate() * 10; // 即15%
        } else {
            if (_myVirtualRate < reallyProgressRateP1) {
                _myVirtualRate += _randomAddRate();
            }
        }

        if (_isEnemyLoadFinish) {
            _enemyVirtualRate += _randomAddRate() * 10; // 即15%
        } else {
            if (_enemyVirtualRate < reallyProgressRateP2) {
                _enemyVirtualRate += _randomAddRate();
            }
        }

        if (myProgress >= 10000) {
            _isMyLoadFinish = true;
        }
        if (enemyProgress >= 10000) {
            _isEnemyLoadFinish = true;
        }

        if (_myVirtualRate > 1) {
            _myVirtualRate = 1;
        }
        if (_enemyVirtualRate > 1) {
            _enemyVirtualRate = 1;
        }
    }
    private function _isLoadVirtualFinish() : Boolean {
        return _myVirtualRate > 0.999999 && _enemyVirtualRate > 0.999999;
    }
    private function _randomAddRate() : Number {
        return Math.random() * 100 / 10000 + 0.005;
    }

    protected override function _onHide() : void {

    }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        if (_isFrist) {
            _isFrist = false;
        }

        if (_isFirstUpdate) {
            _isFirstUpdate = false;
            sendEvent(new CViewEvent(CViewEvent.FIRST_UPDATE_VIEW));
        }
        var loadingData:CStreetFighterLoadingData = _Data.loadingData;

        var myRateTxt:Label;
        var myRateBar:ProgressBar;
        var myIconImg:Image;
        var myQualityClip:Clip;
        var myTeamNameTxt:Label;
        var myHeroNameTxt:Label;

        var enemyRateBTxt:Label;
        var enemyRateBar:ProgressBar;
        var enemyIconImg:Image;
        var enemyQualityClip:Clip;
        var enemyTeamNameTxt:Label;
        var enemyHeroNameTxt:Label;

        if (_Data.loadingData.isSelfP1) {
            myRateTxt = _ui.p1_load_rate_txt;
            myRateBar = _ui.p1_load_rate_bar;
            myIconImg = _ui.p1_icon_img;
            myQualityClip = _ui.p1_quality_clip;
            myTeamNameTxt = _ui.p1_team_name;
            myHeroNameTxt = _ui.p1_hero_name_txt;

            enemyRateBTxt = _ui.p2_load_rate_txt;
            enemyRateBar = _ui.p2_load_rate_bar;
            enemyIconImg = _ui.p2_icon_img;
            enemyQualityClip = _ui.p2_quality_clip;
            enemyTeamNameTxt = _ui.p2_team_name;
            enemyHeroNameTxt = _ui.p2_hero_name_txt;
        } else {
            myRateTxt = _ui.p2_load_rate_txt;
            myRateBar = _ui.p2_load_rate_bar;
            myIconImg = _ui.p2_icon_img;
            myQualityClip = _ui.p2_quality_clip;
            myTeamNameTxt = _ui.p2_team_name;
            myHeroNameTxt = _ui.p2_hero_name_txt;

            enemyRateBTxt = _ui.p1_load_rate_txt;
            enemyRateBar = _ui.p1_load_rate_bar;
            enemyIconImg = _ui.p1_icon_img;
            enemyQualityClip = _ui.p1_quality_clip;
            enemyTeamNameTxt = _ui.p1_team_name;
            enemyHeroNameTxt = _ui.p1_hero_name_txt;
        }

        var pPlayerData:CPlayerData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
        var myHeroData:CPlayerHeroData = pPlayerData.heroList.getHero(loadingData.fightHeroID);

        myIconImg.url = CPlayerPath.getPeakUIHeroFacePath(myHeroData.prototypeID);
        myQualityClip.index = myHeroData.qualityBaseType;
        myTeamNameTxt.text = pPlayerData.teamData.name;
        myRateTxt.text = CLang.Get("peak1v1_loading_process_tips", {v1:(int)(_Data.myProgress/10000*100)});
        myRateBar.value = _Data.myProgress/10000;
        myHeroNameTxt.text = myHeroData.heroNameWithColor;

        var enemyHeroData:CPlayerHeroData = pPlayerData.heroList.createHero(loadingData.enemyHeroData.prototypeID);
        enemyHeroData.quality = loadingData.enemyHeroData.quality;
        enemyHeroData.level = loadingData.enemyHeroData.level;
        enemyIconImg.url = CPlayerPath.getPeakUIHeroFacePath(enemyHeroData.prototypeID);
        enemyQualityClip.index = enemyHeroData.qualityBaseType;
        enemyTeamNameTxt.text = loadingData.enemyName;
        enemyRateBTxt.text = CLang.Get("peak1v1_loading_process_tips", {v1:(int)(_Data.progressData.enemyProgress/10000*100)});
        enemyRateBar.value = _Data.progressData.enemyProgress/10000;
        enemyHeroNameTxt.text = enemyHeroData.heroNameWithColor;

        var isJingFu:Boolean = loadingData.instanceID == 310001;
        _ui.scene_jingfu_img.visible = _ui.scene_name_jingfu_img.visible = isJingFu;
        _ui.scene_jiazi_img.visible = _ui.scene_name_jiazi_img.visible = !isJingFu;

        this.addToLoading();

        return true;
    }

    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);
        this.setChildrenData(v, forceInvalid);
    }

    // ====================================event=============================

    //===================================get/set======================================

    public function isLoadFinish() : Boolean {
        return _isLoadFinish;
    }
    [Inline]
    private function get _ui() : Peak1v1LoadingUI {
        return rootUI as Peak1v1LoadingUI;
    }
    [Inline]
    private function get _Data() : CStreetFighterData {
        if (_data && _data.length > 0) {
            return super._data[0] as CStreetFighterData;
        }
        return null;
    }
    [Inline]
    private function get _playerData() : CPlayerData {
        if (_data && _data.length > 1) {
            return super._data[1] as CPlayerData;
        }
        return null;
    }

    private var _isFrist:Boolean = true;
    private var _isFirstUpdate:Boolean;
    private var _isMyLoadFinish:Boolean;
    private var _isEnemyLoadFinish:Boolean;
    private var _myVirtualRate:Number;
    private var _enemyVirtualRate:Number;
    private var _isLoadFinish:Boolean;

}
}
