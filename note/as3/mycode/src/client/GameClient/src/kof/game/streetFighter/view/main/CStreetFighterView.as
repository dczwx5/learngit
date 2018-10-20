//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/23.
 */
package kof.game.streetFighter.view.main {


import QFLib.Foundation.CTime;

import kof.game.KOFSysTags;
import kof.game.common.CLang;
import kof.game.common.CSystemRuleUtil;

import kof.game.common.view.CRootView;
import kof.game.common.view.event.CViewEvent;
import kof.game.player.data.CPlayerData;
import kof.game.streetFighter.CStreetFighterRedPoint;
import kof.game.streetFighter.CStreetFighterRedPoint;
import kof.game.streetFighter.control.CStreetFighterControler;
import kof.game.streetFighter.control.CStreetFighterMainControler;
import kof.game.streetFighter.data.CStreetFighterData;
import kof.game.streetFighter.data.CStreetFighterRewardData;
import kof.game.streetFighter.enum.EStreetFighterViewEventType;
import kof.game.streetFighter.enum.EStreetFighterWndResType;
import kof.table.StreetFighterReward;
import kof.ui.master.StreetFighter.StreetFighterUI;

import morn.core.handlers.Handler;
import morn.core.utils.ObjectUtils;


public class CStreetFighterView extends CRootView {

    public function CStreetFighterView() {
        super(StreetFighterUI, [CStreetFighterMainRankView, CStreetFighterMainRoomView, CStreetFighterMainHeroListView], EStreetFighterWndResType.MAIN, false);
    }

    protected override function _onCreate() : void {
        _isFrist = true;
        setTweenData(KOFSysTags.STREET_FIGHTER);

        CSystemRuleUtil.setRuleTips(_ui.img_tips, CLang.Get("street_fighter_rule"));
    }
    protected override function _onDispose() : void {

    }
    protected override function _onShow():void {
        _ui.report_btn.clickHandler = new Handler(_onClickReport);
        _ui.shop_btn.clickHandler = new Handler(_onClickShop);
        _ui.reward_btn.clickHandler = new Handler(_onClickReward);
        _ui.rank_btn.clickHandler = new Handler(_onClickRank);
        _ui.match_btn.clickHandler = new Handler(_onClickMatch);
        _ui.refight_btn.clickHandler = new Handler(_onClickRefight);
        _ui.task_get_btn.clickHandler = new Handler(_onClickGetReward);

        listEnterFrameEvent = true;
    }
    protected override function _onHide() : void {
        _ui.report_btn.clickHandler = null;
        _ui.shop_btn.clickHandler = null;
        _ui.reward_btn.clickHandler = null;
        _ui.rank_btn.clickHandler = null;
        _ui.match_btn.clickHandler = null;
        _ui.refight_btn.clickHandler = null;
        _ui.task_get_btn.clickHandler = null;

        listEnterFrameEvent = false;
    }

    protected override function _onEnterFrame(delta:Number) : void {
        super._onEnterFrame(delta);

        var startTime:Number = _streetData.getStartTime();
        var endTime:Number = _streetData.getEndTime();
        var iClientTime:Number = CTime.getCurrServerTimestamp();
        var timeValue:Number;
        if (_streetData.isActivityTime) {
            // 开启
            _ui.count_down_title.text = CLang.Get("street_count_down_end");
            timeValue = endTime - iClientTime;
            _ui.count_down_num2.timeNum = CTime.toDurTimeString(timeValue);
            _ui.count_down_num2.visible = true;
            _ui.count_down_num.visible = false;

            var pControl:CStreetFighterMainControler = controlList[0] as CStreetFighterMainControler;
            if (startTime < pControl.netHandler.lastSendEnterTime && endTime > pControl.netHandler.lastSendEnterTime) {
                // 已经发过进场
            } else {
                pControl.netHandler.sendEnterRequest();
            }
        } else if (startTime > iClientTime) {
            // 未开启
            _ui.count_down_title.text = CLang.Get("street_count_down_start");
            timeValue = startTime - iClientTime;
            _ui.count_down_num.timeNum = CTime.toDurTimeString(timeValue);
            _ui.count_down_num.visible = true;
            _ui.count_down_num2.visible = false;
        } else {
            if (iClientTime < _streetData.settlementTime) {
                _ui.count_down_title.text = CLang.Get("street_result_count_down_start");
                timeValue = _streetData.settlementTime - iClientTime;
                _ui.count_down_num.timeNum = CTime.toDurTimeString(timeValue);
                _ui.count_down_num.visible = true;
                _ui.count_down_num2.visible = false;

            }
        }
        if (_streetData.alreadyStartFight) {
            _ui.embattle_tips.text = CLang.Get("street_embattle_can_not_change");
        } else {
            _ui.embattle_tips.text = CLang.Get("street_embattle_can_change");
        }

    }


    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        if (_isFrist) {
            _isFrist = false;
        }

        // 小红点
        _updateRedPoint();
        _updateFightBtn();
        _updataTastReward();


        this.addToDialog(KOFSysTags.STREET_FIGHTER);

        return true;
    }

    private function _updataTastReward() : void {
        _ui.task_box.visible = false;

        var isCanGetReward:Boolean = true;
        var curValue:int;
        var targetCount:int;
        var taskTypeList:Array = [CStreetFighterRewardData.TYPE_FIGHT_COUNT,
            CStreetFighterRewardData.TYPE_WIN_COUNT,
            CStreetFighterRewardData.TYPE_ALWAYS_WIN_COUNT, CStreetFighterRewardData.TYPE_SCORE];
        var record:StreetFighterReward = CStreetFighterRedPoint.getCanRewardB(_streetData, taskTypeList);
        if (!record) {
            record = CStreetFighterRedPoint.getCanProcessReward(_streetData, taskTypeList);
            isCanGetReward = false;
        }
        if (record) {
            _ui.task_box.dataSource = record;
            _ui.task_box.visible = true;
            targetCount = record.param[0] as int;
            curValue = _streetData.getCurValueByType(record.type);
            curValue = Math.min(curValue, targetCount);
            var targetKey:String = _getTargetLangByTypeB(record.type);
            var curKey:String;
            if (curValue >= targetCount) {
                curKey = "street_reward_score_cur";
            } else {
                curKey = "street_reward_score_cur_not_finish";
            }
            _ui.task_desc_txt.text = CLang.Get(targetKey, {v1:targetCount}) + CLang.Get(curKey, {v1:curValue, v2:targetCount});
            _ui.task_check_box.selected = isCanGetReward;
            _ui.task_get_btn.visible = isCanGetReward;
        }
    }
    private function _getTargetLangByTypeB(type:int) : String {
        if (type == CStreetFighterRewardData.TYPE_FIGHT_COUNT) {
            return "street_fighter_reward_fight_target";
        } else if (type == CStreetFighterRewardData.TYPE_WIN_COUNT) {
            return "street_fighter_reward_win_target";
        } else if (type == CStreetFighterRewardData.TYPE_SCORE) {
            return "street_fighter_reward_score_target";
        } else {
            return "street_fighter_reward_always_win_target";
        }
    }

    private function _updateRedPoint() : void {
        _ui.red_img.visible = false;
        var hasFightReward:Boolean = CStreetFighterRedPoint.hasFightRewardCanGet(_streetData);
        if (hasFightReward) {
            _ui.red_img.visible = true;
        } else {
            var hasScoreReward:Boolean = CStreetFighterRedPoint.hasScoreRewardCanGet(_streetData);
            if (hasScoreReward) {
                _ui.red_img.visible = true;
            }
        }
    }

    private function _updateFightBtn() : void {
        ObjectUtils.gray(_ui.match_btn, false);
        var pControll:CStreetFighterControler = controlList[0] as CStreetFighterControler;
        if (_streetData.isActivityTime) {
            if (_streetData.alreadyStartFight) {
                // 已经开始
                var isNeedShowRefight:Boolean = pControll.needRefight();
                if (isNeedShowRefight) {
                    var isAllDead:Boolean = pControll.isAllDead();
                    if (isAllDead) {
                        _ui.match_btn.visible = false;
                        _ui.refight_btn.visible = true;
                    } else {
                        _ui.match_btn.visible = true;
                        _ui.refight_btn.visible = true;
                    }
                } else {
                    ObjectUtils.gray(_ui.match_btn, false);
                    _ui.refight_btn.visible = false;
                    _ui.match_btn.visible = true;
                }
            } else {
                // 未开始打
                _ui.refight_btn.visible = false;
                _ui.match_btn.visible = true;
            }
        } else {
            // 未开启
            _ui.refight_btn.visible = false;
            _ui.match_btn.visible = true;
            ObjectUtils.gray(_ui.match_btn, true);
        }


        const space:int = 100;
        if (_ui.match_btn.visible && _ui.refight_btn.visible) {
            _ui.refight_btn.x = _ui.width/2 - space/2 - _ui.refight_btn.width;
            _ui.match_btn.x = _ui.width/2 + space/2;
        } else {
            _ui.refight_btn.x = _ui.width/2 - _ui.refight_btn.width/2;
            _ui.match_btn.x = _ui.width/2  - _ui.match_btn.width/2;
        }
    }

    private function _onClickReport() : void {
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EStreetFighterViewEventType.MAIN_REPORT_CLICK));
    }
    private function _onClickShop() : void {
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EStreetFighterViewEventType.MAIN_SHOP_CLICK));
    }
    private function _onClickReward() : void {
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EStreetFighterViewEventType.MAIN_REWARD_CLICK));
    }
    private function _onClickRank() : void {
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EStreetFighterViewEventType.MAIN_RANK_CLICK));
    }
    private function _onClickMatch() : void {
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EStreetFighterViewEventType.MAIN_MATCH));
    }
    private function _onClickRefight() : void {
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EStreetFighterViewEventType.MAIN_REFIGHT_CLICK));
    }
    private function _onClickGetReward() : void {
        var record:StreetFighterReward = _ui.task_box.dataSource as StreetFighterReward;
        if (!record) {
            return ;
        }

        sendEvent( new CViewEvent( CViewEvent.UI_EVENT, EStreetFighterViewEventType.MAIN_TASK_REWARD_GET_CLICK, record) );
    }

    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);
        this.setChildrenData(v, forceInvalid);
    }

    // ====================================event=============================


    //===================================get/set======================================

//    private function get _linksView() : CPeakGameMainLinks { return getChild(0) as CPeakGameMainLinks; }

    [Inline]
    private function get _ui() : StreetFighterUI {
        return rootUI as StreetFighterUI;
    }
    [Inline]
    private function get _streetData() : CStreetFighterData {
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

}
}
