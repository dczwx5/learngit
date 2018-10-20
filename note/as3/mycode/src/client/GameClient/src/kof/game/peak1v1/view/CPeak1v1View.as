//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/23.
 */
package kof.game.peak1v1.view {

import QFLib.Foundation.CTime;

import flash.events.Event;

import flash.events.MouseEvent;

import kof.game.KOFSysTags;

import kof.game.common.CLang;
import kof.game.common.CSystemRuleUtil;
import kof.game.common.hero.CHeroEmbattleListView;
import kof.game.common.view.CRootView;
import kof.game.common.view.event.CViewEvent;
import kof.game.instance.enum.EInstanceType;
import kof.game.peak1v1.data.CPeak1v1Data;
import kof.game.peak1v1.data.CPeak1v1RankingData;
import kof.game.peak1v1.enum.EPeak1v1ViewEventType;
import kof.game.peak1v1.enum.EPeak1v1WndResType;
import kof.game.player.data.CEmbattleData;
import kof.game.player.data.CEmbattleListData;
import kof.game.player.data.CPlayerData;
import kof.ui.master.peak1v1.Peak1v1UI;

import morn.core.components.Clip;

import morn.core.components.Component;
import morn.core.components.Label;

import morn.core.handlers.Handler;


public class CPeak1v1View extends CRootView {

    public function CPeak1v1View() {
        super(Peak1v1UI, null, EPeak1v1WndResType.PEAK_1V1_MAIN, false);
    }

    protected override function _onCreate() : void {
        _isFrist = true;
        _ui.last_top3_txt.text = CLang.Get("peak1v1_top3_title");
        _ui.top3_ranking_title_txt.text = CLang.Get("common_ranking");
        _ui.top3_name_title_txt.text = CLang.Get("common_team_name");
        _ui.my_score_title_txt.text = CLang.Get("peak1v1_my_score_title");
        _ui.round_title_txt.text = CLang.Get("peak1v1_round_title");
        _ui.next_round_count_down_title_txt.text = CLang.Get("peak1v1_next_round_cound_down_title");

        setTweenData(KOFSysTags.PEAK_1V1);
    }
    protected override function _onDispose() : void {

    }
    protected override function _onShow():void {
//        _hasRequireEmbattle = false;
        listEnterFrameEvent = true;
        _ui.rank_btn.clickHandler = new Handler(_onRank);
        _ui.report_btn.clickHandler = new Handler(_onReport);
        _ui.reward_btn.clickHandler = new Handler(_onReward);
        _ui.reward_desc_btn.clickHandler = new Handler(_onRewardDesc);
        _ui.embattle_btn.clickHandler = new Handler(_onEmbattle);
        _ui.rank3_switch_btn.addEventListener(MouseEvent.CLICK, _onSwitchRank3);
        _ui.reg_btn.clickHandler = new Handler(_onRegClick);
        _ui.un_reg_btn.clickHandler = new Handler(_onUnRegClick);

        _ui.rank3_list.renderHandler = new Handler(_onRenderRank3Item);
        CSystemRuleUtil.setRuleTips(_ui.tips_btn, CLang.Get("peak1v1_rule_tips"));

    }

    protected override function _onHide() : void {
        _ui.rank_btn.clickHandler = null;
        _ui.report_btn.clickHandler = null;
        _ui.reward_btn.clickHandler = null;
        _ui.reward_desc_btn.clickHandler = null;
        _ui.embattle_btn.clickHandler = null;
        _ui.rank3_switch_btn.removeEventListener(MouseEvent.CLICK, _onSwitchRank3);
        _ui.rank3_list.renderHandler = null;
        _ui.reg_btn.clickHandler = null;
        _ui.un_reg_btn.clickHandler = null;
        CSystemRuleUtil.setRuleTips(_ui.tips_btn, null);


    }
    protected override function _onClose() : void {
        var fCurTime:Number = CTime.getCurrServerTimestamp();
        var fStartTime:Number = _Data.warnStartTime;
        var fEndTime:Number = _Data.endTime;
        if (fCurTime > fStartTime && fCurTime < fEndTime) {
            uiCanvas.showMsgBox(CLang.Get("peak1v1_close_tips"), super._onClose, null, true);
        } else {
            super._onClose();
        }
    }
    protected override function _onEnterFrame(delta:Number) : void {
        var fCurTime:Number = CTime.getCurrServerTimestamp();
        var fStartCountDownTime:Number = _Data.nextRoundCountDownStartTime;
        var fCountDownStillTime:Number = _Data.nextRoundCountDownStillTime;
        var fCountDownEndTime:Number = fStartCountDownTime + fCountDownStillTime;
        if (fCurTime > fStartCountDownTime && fCurTime <= fCountDownEndTime) {
            var leftTime:int = (fCountDownEndTime - fCurTime)/1000;
            _ui.register_count_down_title_txt.visible = true;
            _ui.register_count_down_txt.visible = true;
            _ui.register_count_down_txt.text = leftTime.toString();
            _ui.register_count_down_line_box.visible = true;

            _ui.next_round_count_down_title_txt.visible = false;
            _ui.next_round_count_down_txt.visible = false;
        } else {
            _ui.register_count_down_title_txt.visible = false;
            _ui.register_count_down_txt.visible = false;
            _ui.register_count_down_line_box.visible = false;

            var nextRoundDelta:Number = (fCountDownEndTime - fCurTime);
            if (nextRoundDelta > 0) {
                var timeStr:String = CTime.toDurTimeString(nextRoundDelta);
                _ui.next_round_count_down_title_txt.visible = true;
                _ui.next_round_count_down_txt.visible = true;
                _ui.next_round_count_down_txt.text = timeStr;
            } else {
                _ui.next_round_count_down_title_txt.visible = false;
                _ui.next_round_count_down_txt.visible = false;
            }

        }

    }
    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        this.dispatchEvent(new CViewEvent(CViewEvent.UPDATE_VIEW));

        if (_isFrist) {
            _isFrist = false;
        }

        // 自动布阵
//        if (!_hasRequireEmbattle) {
//            var heroCount:int = _playerData.embattleManager.getHeroCountByType(EInstanceType.TYPE_PEAK_1V1);
//            if (heroCount == 0) {
//                _hasRequireEmbattle = true; // 避免已经没人可以上了，还一直在发布阵消息
//                sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EPeak1v1ViewEventType.MAIN_AUTO_SET_BEST_EMBATTLE));
//            }
//        }


        // 布阵信息
        var heroListData:Array = new Array(3);
        var emListData:CEmbattleListData = _playerData.embattleManager.getByType(EInstanceType.TYPE_PEAK_1V1);
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
            _heroEmbattleList = new CHeroEmbattleListView(system, _ui.hero_em_list, EInstanceType.TYPE_PEAK_1V1, new Handler(_onClickAddHero));
        }
        _heroEmbattleList.updateWindow();

        // 信息
        _ui.score_txt.text = _Data.score.toString();
        _ui.fight_round_txt.text = _Data.fightCount.toString() + "/" + _Data.fightCountMax.toString();
        _ui.cur_round_title_txt.num = _Data.round;
        _timeDate.setTime(_Data.showStartTime);
        var timeStr:String = CTime.fillZeros(_timeDate.hours.toString(),2) + ":" + CTime.fillZeros(_timeDate.minutes.toString(),2);
        _ui.start_tips_txt.text = CLang.Get("peak1v1_start_tips", {v1:timeStr});

        // 前三甲
        var rank3List:Array = _Data.rank3ListData.list;
        _ui.rank3_list.dataSource = rank3List;

        // 报名
        if (_Data.regState == 0) {
            _ui.reg_btn.visible = true;
            _ui.un_reg_btn.visible = false;
        } else {
            _ui.reg_btn.visible = false;
            _ui.un_reg_btn.visible = true;
        }


        this.addToDialog(KOFSysTags.PEAK_1V1);

        return true;
    }

    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);
        this.setChildrenData(v, forceInvalid);
    }

    // ====================================event=============================
    private function _onRank() : void {
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EPeak1v1ViewEventType.MAIN_RANK_CLICK));
    }
    private function _onReport() : void {
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EPeak1v1ViewEventType.MAIN_REPORT_CLICK));
    }
    private function _onEmbattle() : void {
        this.sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EPeak1v1ViewEventType.MAIN_EMBATTLE_CLICK));
    }
    private function _onClickAddHero() : void {
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EPeak1v1ViewEventType.MAIN_EMBATTLE_CLICK));
    }
    private function _onReward() : void {
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EPeak1v1ViewEventType.MAIN_REWARD_CLICK));
    }
    private function _onRewardDesc() : void {
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EPeak1v1ViewEventType.MAIN_REWARD_DESC_CLICK));
    }
    private function _onSwitchRank3(e:Event) : void {
        _ui.rank3_switch_btn.index == 0 ? _ui.rank3_switch_btn.index = 1 : _ui.rank3_switch_btn.index = 0;

        _ui.rank3_box.visible = _ui.rank3_switch_btn.index == 0;
    }
    private function _onRenderRank3Item(com:Component, idx:int) : void {
        if (com == null) return ;
        var dataSource:CPeak1v1RankingData = com.dataSource as CPeak1v1RankingData;
        if (!dataSource) {
            com.visible = false;
            return ;
        }
        com.visible = true;

        var rankClip:Clip = com.getChildByName("top3_rank_clip") as Clip;
        var name:Label = com.getChildByName("top3_name_txt") as Label;
        rankClip.index = dataSource.ranking - 1;
        name.text = dataSource.name;

    }
    private function _onRegClick() : void {
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EPeak1v1ViewEventType.MAIN_REG_CLICK));
    }
    private function _onUnRegClick() : void {
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EPeak1v1ViewEventType.MAIN_UN_REG_CLICK));
    }
    //===================================get/set======================================

    [Inline]
    private function get _ui() : Peak1v1UI {
        return rootUI as Peak1v1UI;
    }
    [Inline]
    private function get _Data() : CPeak1v1Data {
        if (_data && _data.length > 0) {
            return super._data[0] as CPeak1v1Data;
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
    private var _heroEmbattleList:CHeroEmbattleListView;
//    private var _hasRequireEmbattle:Boolean;
    private var _timeDate:Date = new Date();


}
}
