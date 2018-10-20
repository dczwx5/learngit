//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/7.
 */
package kof.game.peakGame.view.main {

import QFLib.Foundation.CTime;
import QFLib.Utils.CDateUtil;

import flash.events.MouseEvent;

import kof.game.common.CLang;
import kof.game.common.view.CChildView;
import kof.game.common.view.event.CViewEvent;
import kof.game.peakGame.data.CPeakGameData;
import kof.game.peakGame.data.CPeakGameRewardTaskData;
import kof.game.peakGame.enum.EPeakGameViewEventType;
import kof.game.player.data.CPlayerData;
import kof.ui.master.PeakGame.PeakGameUI;

public class CPeakGameMainLinks extends CChildView {
    public function CPeakGameMainLinks() {
    }
    protected override function _onCreate() : void {
        // can not call super._onCreate in this class
    }
    protected override function _onDispose() : void {
        // can not call super._onDispose in this class
    }
    protected override function _onShow():void {
        // can not call super._onShow in this class
        _ui.go_btn.addEventListener(MouseEvent.CLICK, _onClickFight);
        _ui.daily_reward_btn.addEventListener(MouseEvent.CLICK, _onClickReward);

        _ui.rank_btn.addEventListener(MouseEvent.CLICK, _onClickRank);
        _ui.practice_btn.addEventListener(MouseEvent.CLICK, _onClickPractice);
        _ui.report_btn.addEventListener(MouseEvent.CLICK, _onClickReport);
        _ui.shop_btn.addEventListener(MouseEvent.CLICK, _onClickShop);
//        _ui.embattle_btn.addEventListener(MouseEvent.CLICK, _onClickEmbattle);
//        _ui.level_btn.addEventListener(MouseEvent.CLICK, _onClickLevelInfo);
        _ui.pk_btn.addEventListener(MouseEvent.CLICK, _onClickPK);

        _ui.tips_daily_box.visible = false;
        _isFirst = true;



//        _ui.tips_btn.toolTip = "test tips, need fix";
    }
    private function showTipsEnd() : void {
        _ui.tips_daily_box.visible = false;
    }

    protected override function _onHide() : void {
        // can not call super._onHide in this class

        _ui.go_btn.removeEventListener(MouseEvent.CLICK, _onClickFight);
        _ui.daily_reward_btn.removeEventListener(MouseEvent.CLICK, _onClickReward);
        _ui.rank_btn.removeEventListener(MouseEvent.CLICK, _onClickRank);
        _ui.practice_btn.removeEventListener(MouseEvent.CLICK, _onClickPractice);
        _ui.report_btn.removeEventListener(MouseEvent.CLICK, _onClickReport);
        _ui.shop_btn.removeEventListener(MouseEvent.CLICK, _onClickShop);
//        _ui.level_btn.removeEventListener(MouseEvent.CLICK, _onClickLevelInfo);
        _ui.pk_btn.removeEventListener(MouseEvent.CLICK, _onClickPK);

        _ui.tips_btn.toolTip = null;
    }
    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;
//        _updateNormalTips();
        if (_isFirst) {
            _isFirst = false;
            _updateMovieTips();
        }

        return true;
    }
//    private function _updateNormalTips() : void {
//        var subCount:int;
//
//        _ui.daily_reward_btn.toolTip = null;
////        _ui.week_reward_btn.toolTip = null;
////        _ui.season_reward_btn.toolTip = null;
//        var dailyTask:CPeakGameRewardTaskData = _peakGameData.rewardData.getFirstDailyUnFinishTaskData();
//        if (dailyTask) {
//            if (dailyTask.isCanReward) {
//                // 可领取
//                _ui.daily_reward_btn.toolTip = CLang.Get("peak_has_can_reward");
//            } else if (dailyTask.isUnReady) {
//                subCount = dailyTask.target - _peakGameData.rewardData.dayBeatHeroCount;
//                _ui.daily_reward_btn.toolTip = CLang.Get("peak_daily_reward_tips", {v1:subCount});
//            }
//        }
//
//        var weekWinTask:CPeakGameRewardTaskData = _peakGameData.rewardData.getFirstWeekWinUnFinishTaskData();
//        if (weekWinTask) {
//            if (weekWinTask.isCanReward) {
//                // 可领取
////                _ui.week_reward_btn.toolTip = CLang.Get("peak_has_can_reward");
//            } else if (weekWinTask.isUnReady) {
//                subCount = weekWinTask.target - _peakGameData.rewardData.weekWinCount;
////                _ui.week_reward_btn.toolTip = CLang.Get("peak_week_win_reward_tips", {v1:subCount});
//            }
//        }
////
////        if (_ui.count_down_txt.visible && _ui.count_down_txt.text.length > 0) {
////            _ui.season_reward_btn.toolTip = _ui.count_down_txt.text;
////        } else {
////            _ui.season_reward_btn.toolTip = _ui.count_down2_txt.text;
////        }
//    }
    private function _updateMovieTips() : void {
        var subCount:int;

        _ui.tips_daily_box.visible = true;
        var dailyTask:CPeakGameRewardTaskData = _peakGameData.rewardData.getFirstDailyUnFinishTaskData();
        if (dailyTask) {
            if (dailyTask.isCanReward) {
                // 可领取
                _ui.tips_daily_txt.text = CLang.Get("peak_has_can_reward");
            } else if (dailyTask.isUnReady) {
                subCount = dailyTask.target - _peakGameData.rewardData.dayBeatHeroCount;
                _ui.tips_daily_txt.text = CLang.Get("peak_daily_reward_tips", {v1:subCount});

            } else {
                _ui.tips_daily_txt.text = CLang.Get("common_none");
            }
        } else {
            _ui.tips_daily_txt.text = CLang.Get("peak_week_no_task");
        }


        var weekWinTask:CPeakGameRewardTaskData = _peakGameData.rewardData.getFirstWeekWinUnFinishTaskData();
        if (weekWinTask) {
            if (weekWinTask.isCanReward) {
                // 可领取
                _ui.tips_week_txt.text = CLang.Get("peak_has_can_reward");
            } else if (weekWinTask.isUnReady) {
                subCount = weekWinTask.target - _peakGameData.rewardData.weekWinCount;
                _ui.tips_week_txt.text = CLang.Get("peak_week_win_reward_tips", {v1:subCount});
            } else {
                _ui.tips_week_txt.text = CLang.Get("common_none");
            }
        } else {
            _ui.tips_week_txt.text = CLang.Get("peak_week_no_task");
        }

        var startSeasonTime:Number = _peakGameData.seasonStartTime;
        var endSeasonTime:Number = _peakGameData.seasonOverTime;
        var iClientTime:Number = CTime.getCurrServerTimestamp();
        if (iClientTime < startSeasonTime) {
            var dataSub:int = Math.abs(CTime.dateSub(iClientTime, startSeasonTime));
            if (dataSub > 0) {
                _ui.tips_season_txt.text = CLang.Get("peak_open_left_day_2", {v1:dataSub});
            } else {
                var timeSub:Number = startSeasonTime - iClientTime;
                _ui.tips_season_txt.text = CTime.toDurTimeString(timeSub);
            }
        } else {
            if (startSeasonTime > 0 && endSeasonTime > 0) {
                var startTime:String = CTime.formatYMDStr(startSeasonTime);
                var endTime:String = CTime.formatYMDStr(endSeasonTime);
                _ui.tips_season_txt.text = startTime + " - " + endTime;
            } else {
                _ui.tips_season_txt.text = CLang.Get("common_none");
            }
        }

        delayCall(3, showTipsEnd);
    }

    private function _onClickFight(e:MouseEvent) : void {
        var date:Date = new Date(CTime.getCurrServerTimestamp());
        var view:CPeakGameTipViewHandler = system.getHandler(CPeakGameTipViewHandler) as CPeakGameTipViewHandler;
        if(date.hours >= 0 && date.hours <= 7 && !view.isNotTip)
        {
            (system.getHandler(CPeakGameTipViewHandler) as CPeakGameTipViewHandler).callBackFunc = _fightHandler;
            (system.getHandler(CPeakGameTipViewHandler) as CPeakGameTipViewHandler).addDisplay();
        }
        else
        {
            _fightHandler();
        }
//        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EPeakGameViewEventType.MAIN_CLICK_FIGHT));
        e.stopImmediatePropagation();
    }

    private function _fightHandler():void
    {
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EPeakGameViewEventType.MAIN_CLICK_FIGHT));
    }

    private function _onClickReward(e:MouseEvent) : void {
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EPeakGameViewEventType.MAIN_CLICK_REWARD));
        e.stopImmediatePropagation();
    }
    private function _onClickRank(e:MouseEvent) : void {
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EPeakGameViewEventType.MAIN_CLICK_RANK));
        e.stopImmediatePropagation();
    }
    private function _onClickPractice(e:MouseEvent) : void {
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EPeakGameViewEventType.MAIN_CLICK_PRACTICE));
        e.stopImmediatePropagation();
    }
    private function _onClickReport(e:MouseEvent) : void {
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EPeakGameViewEventType.MAIN_CLICK_REPORT));
        e.stopImmediatePropagation();
    }
    private function _onClickShop(e:MouseEvent) : void {
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EPeakGameViewEventType.MAIN_CLICK_SHOP));
//        _uiSystem.showMsgAlert(CLang.Get("common_not_open"));
        e.stopImmediatePropagation();
    }
    private function _onClickEmbattle(e:MouseEvent) : void {
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EPeakGameViewEventType.MAIN_CLICK_EMBATTLE));
        e.stopImmediatePropagation();
    }
    private function _onClickLevelInfo(e:MouseEvent) : void {
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EPeakGameViewEventType.MAIN_CLICK_LEVEL_INFO));
        e.stopImmediatePropagation();
    }
    private function _onClickPK(e:MouseEvent) : void {
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EPeakGameViewEventType.MAIN_CLICK_PK));
        e.stopImmediatePropagation();
    }


    [Inline]
    private function get _ui() : PeakGameUI {
        return rootUI as PeakGameUI;
    }
    [Inline]
    private function get _peakGameData() : CPeakGameData {
        return super._data[0] as CPeakGameData;
    }
    [Inline]
    private function get _playerData() : CPlayerData {
        return super._data[1] as CPlayerData;
    }

    private var _isFirst:Boolean = false;
}
}
