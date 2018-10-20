//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/6.
 */
package kof.game.peakGame.view.result {

import QFLib.Foundation.CKeyboard;

import com.greensock.TweenLite;

import flash.geom.Point;
import flash.ui.Keyboard;

import kof.game.common.CLang;
import kof.game.common.view.CRootView;
import kof.game.common.view.CViewExternalUtil;
import kof.game.common.view.component.CCountDownCompoent;
import kof.game.instance.mainInstance.enum.EInstanceWndResType;
import kof.game.item.view.part.CRewardItemListView;
import kof.game.peakGame.CPeakGameSystem;
import kof.game.peakGame.data.CPeakGameData;
import kof.game.peakGame.data.CPeakGameSettlementData;
import kof.game.peakGame.view.CPeakGameLevelItemUtil;
import kof.game.player.data.CEmbattleData;
import kof.game.player.data.CEmbattleListData;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.table.PeakScoreLevel;
import kof.ui.master.PeakGame.PeakGameResultUI;

import morn.core.components.Component;

import morn.core.handlers.Handler;

public class CPeakGameResultView extends CRootView {

    public function CPeakGameResultView() {
        super(PeakGameResultUI, null, EInstanceWndResType.INSTANCE_PVP_RESULT, false);
    }

    protected override function _onCreate() : void {
        _basePos = new Point(_ui.no_damage_img.x, _ui.no_damage_img.y);
        _keyBoard = new CKeyboard(system.stage.flashStage);
    }
    protected override function _onDispose() : void {

    }
    protected override function _onShow():void {
        this.listEnterFrameEvent = true;
        _ui.ok_btn.visible = false;
        _ui.special_score_box.visible = false;
        _countDownComponent = new CCountDownCompoent(this, _ui.ok_btn, 30000, _onCountDownEnd,
                CLang.Get("peak_count_down_prefix"), CLang.Get("peak_count_down_buffix"));

        _isTimeToShowCountDown = false;
        _ui.ok_btn.clickHandler = new Handler(_onCountDownEnd);

        _keyBoard.registerKeyCode(false, Keyboard.SPACE, _onKeyDown);
    }
    private function _onKeyDown(keyCode:uint):void {
        switch (keyCode) {
            case Keyboard.SPACE:
                if (_ui.ok_btn.visible) {
                    close();
                }
                break;
        }
    }
    private function _onCountDownEnd() : void {
        this.close();
    }

    protected override function _onHide() : void {
        _countDownComponent.dispose();
        _countDownComponent = null;

        _keyBoard.unregisterKeyCode(false, Keyboard.SPACE, _onKeyDown);
    }
    protected override function _onEnterFrame(delta:Number) : void {
        if (_isTimeToShowCountDown) {
            _countDownComponent.tick();
        }
    }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        _titleProcessB();

        // 玩家, 格斗家信息
        _playerProcessB();

        // special score
        _specialScoreProcessB();

        this.addToDialog();

        return true;
    }

    private function _titleProcessB() : void {
        var settlementData:CPeakGameSettlementData = _peakGameData.settlementData;

        // 结果 : 0 : 失败, 1 : 成功, 2 : 战平, 3 : 完胜
        if (settlementData.result == 0) {
            // 失败
            _ui.result_clip.index = 0;
            _ui.bg_clip.index = 0;
            _ui.full_win_img.index = 0;
            _ui.combo_img.index = 0;
            _ui.no_damage_img.index = 0;
        } else if (settlementData.result == 1) {
            // 成功
            _ui.result_clip.index = 1;
            _ui.bg_clip.index = 1;
            _ui.full_win_img.index = 1;
            _ui.combo_img.index = 1;
            _ui.no_damage_img.index = 1;
        } else if (settlementData.result == 2) {
            // 战平
            _ui.result_clip.index = 3;
            _ui.bg_clip.index = 2;
            _ui.full_win_img.index = 2;
            _ui.combo_img.index = 2;
            _ui.no_damage_img.index = 2;

        } else if (settlementData.result == 3) {
            // 完胜
            _ui.result_clip.index = 2;
            _ui.bg_clip.index = 1;
            _ui.full_win_img.index = 1;
            _ui.combo_img.index = 1;
            _ui.no_damage_img.index = 1;

        }
    }

    private function _playerProcessB() : void {
        var settlementData:CPeakGameSettlementData = _peakGameData.settlementData;
        // 自己在前面
        _ui.name_1_txt.text = _playerData.teamData.name;
        if (settlementData.updateScore > 0) {
            _ui.score_1_txt.text = CLang.Get("peak_score_add", {v1:settlementData.updateScore});
        } else if (settlementData.updateScore < 0) {
            _ui.score_1_txt.text = CLang.Get("peak_score_sub", {v1:Math.abs(settlementData.updateScore)});
        } else {
            // == 0
            if (0 == settlementData.result) {
                _ui.score_1_txt.text = CLang.Get("peak_score_sub", {v1:Math.abs(settlementData.updateScore)});
            } else {
                _ui.score_1_txt.text = CLang.Get("peak_score_add", {v1:settlementData.updateScore});
            }
        }

        var levelRecord:PeakScoreLevel = _peakGameData.getLevelRecordByID(settlementData.scoreLevelID);
        CPeakGameLevelItemUtil.setValue(_ui.level_item1, levelRecord.levelId, levelRecord.subLevelId, levelRecord.levelName);


        var externalUtil:CViewExternalUtil = new CViewExternalUtil(CRewardItemListView, this, _ui);
        (externalUtil.view as CRewardItemListView).ui = _ui.reward_1_list;
        externalUtil.show();
        externalUtil.setData(settlementData.rewards);
        externalUtil.updateWindow();

        // enemy
        _ui.name_2_txt.text = settlementData.enemyName;
        if (settlementData.enemyUpdateScore > 0) {
            _ui.score_2_txt.text = CLang.Get("peak_score_add", {v1:settlementData.enemyUpdateScore});
        } else if (settlementData.enemyUpdateScore < 0) {
            _ui.score_2_txt.text = CLang.Get("peak_score_sub", {v1:Math.abs(settlementData.enemyUpdateScore)});
        } else {
            // == 0
            if (0 == settlementData.result || 2 == settlementData.result) {
                // settlementData.result是自己的结果
                _ui.score_2_txt.text = CLang.Get("peak_score_add", {v1:settlementData.enemyUpdateScore});
            } else {
                _ui.score_2_txt.text = CLang.Get("peak_score_sub", {v1:Math.abs(settlementData.enemyUpdateScore)});
            }
        }
        levelRecord = _peakGameData.getLevelRecordByID(settlementData.enemyScoreLevelID);
        CPeakGameLevelItemUtil.setValue(_ui.level_item2, levelRecord.levelId, levelRecord.subLevelId, levelRecord.levelName);
        var externalUtil2:CViewExternalUtil = new CViewExternalUtil(CRewardItemListView, this, _ui);
        (externalUtil2.view as CRewardItemListView).ui = _ui.reward_2_list;
        externalUtil2.show();
        externalUtil2.setData(settlementData.enemyRewards);
        externalUtil2.updateWindow();
    }
    private function _getSelfHeroLlistDataC() : Array {
        // selfData
        var heroList:Array = new Array();
        var embattleData:CEmbattleData;
        var selfEmbattle:CEmbattleListData = (system as CPeakGameSystem).embattleListData;
        for (var i:int = 0; i < selfEmbattle.list.length; i++) {
            embattleData = selfEmbattle.getByPos(i+1);
            if (embattleData) {
                var heroID:int = embattleData.prosession;
                var heroData:CPlayerHeroData = _playerData.heroList.getHero(heroID);
                heroList[i] = heroData;
            }
        }
        return heroList;
    }

    private function _specialScoreProcessB() : void {
        var settlementData:CPeakGameSettlementData = _peakGameData.settlementData;
        if (settlementData.fullWin == false && settlementData.comboHitMan == false && settlementData.noDamageToWin == false) {
            _ui.ok_btn.visible = true;
            _isTimeToShowCountDown = true;
        } else {
            delayCall(1, _specialScoreProcessC);
        }

    }
    private function _specialScoreProcessC() : void {
        var settlementData:CPeakGameSettlementData = _peakGameData.settlementData;
        _ui.special_score_box.visible = true;
        _ui.full_win_img.visible = _ui.no_damage_img.visible = _ui.combo_img.visible = false;
        var visibleList:Array = new Array();

        if (settlementData.noDamageToWin) {
            visibleList.push(_ui.no_damage_img);
        }
        if (settlementData.fullWin) {
            visibleList.push(_ui.full_win_img);
        }
        if (settlementData.comboHitMan) {
            visibleList.push(_ui.combo_img);
        }
        for (var i:int = 0; i < visibleList.length; i++) {
            var img:Component = visibleList[i] as Component;
            img.visible = true;
            if (i > 0) {
                var preImage:Component = visibleList[i-1] as Component;
                img.setPosition(preImage.x + preImage.displayWidth + 50, _basePos.y);
            } else {
                img.setPosition(_basePos.x, _basePos.y);
            }
        }
        _ui.ok_btn.alpha = 0;
        TweenLite.to(_ui.ok_btn, 0.2, {alpha:1, onComplete:function() : void {
            _isTimeToShowCountDown = true;
        }});
        _ui.special_score_box.alpha = 0;
        TweenLite.to(_ui.special_score_box, 0.2, {alpha:1});
    }

        // ====================================event=============================


    //===================================get/set======================================

    [Inline]
    private function get _ui() : PeakGameResultUI {
        return rootUI as PeakGameResultUI;
    }
    [Inline]
    private function get _peakGameData() : CPeakGameData {
        return super._data[0] as CPeakGameData;
    }
    [Inline]
    private function get _playerData() : CPlayerData {
        return super._data[1] as CPlayerData;
    }

    private var _countDownComponent:CCountDownCompoent;
    private var _basePos:Point;
    private var _isTimeToShowCountDown:Boolean;

    private var _keyBoard:CKeyboard;


}
}
