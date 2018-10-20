//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/4/27.
 */
package kof.game.cultivate.view.cultivateNew {

import flash.events.Event;
import flash.events.MouseEvent;

import kof.framework.CAppSystem;
import kof.game.common.CLang;
import kof.game.common.view.event.CViewEvent;
import kof.game.common.view.rewardTips.CRewardTips;

import kof.game.cultivate.data.CClimpData;
import kof.game.cultivate.data.cultivate.CCultivateData;
import kof.game.common.view.CChildView;
import kof.game.cultivate.data.cultivate.CCultivateLevelData;
import kof.game.cultivate.enum.ECultivateViewEventType;
import kof.game.item.CItemSystem;
import kof.game.player.data.CPlayerData;
import kof.ui.master.cultivate.CultivateNewIIUI;

import morn.core.components.Clip;

import morn.core.components.FrameClip;
import morn.core.components.Image;
import morn.core.handlers.Handler;
import morn.core.utils.ObjectUtils;

// 宝箱进度
public class CCultivateLevelProcessView extends CChildView {
    public function CCultivateLevelProcessView() {
        super ()
    }
    protected override function _onCreate() : void {
        // can not call super._onCreate in this class
        _isFirst = true;

        for (var i:int = 0; i < 5; i++) {
            var rewardImg:Clip = getRewardBoxImg(i);
            var rewardEffect:FrameClip = getRewardEffect(i);
            rewardEffect.autoPlay = false;
            rewardEffect.visible = false;
            rewardEffect.stop();
            rewardEffect.mouseEnabled = false;
        }
    }
    protected override function _onDispose() : void {
        // can not call super._onDispose in this class
    }

    protected override function _onShowing():void {
    }

    protected override function _onShow():void {
        for (var i:int = 0; i < 5; i++) {
            var rewardImg:Clip = getRewardBoxImg(i);
            rewardImg.addEventListener(MouseEvent.CLICK, this["_onClickRewardBox" + (i+1)]);
        }
    }
    protected override function _onHide() : void {
        for (var i:int = 0; i < 5; i++) {
            var rewardImg:Clip = getRewardBoxImg(i);
            rewardImg.removeEventListener(MouseEvent.CLICK, this["_onClickRewardBox" + (i+1)]);
        }
    }

    // ===========update and render
    public virtual override function updateWindow() : Boolean {
        if (false ==  super.updateWindow()) {
            return false;
        }

        var curLevelData:CCultivateLevelData = _climpData.cultivateData.levelList.curLevelData;
        var passCount:int = _climpData.cultivateData.levelList.curOpenLevelIndex - 1;
        var isAllPass:Boolean = curLevelData.passed != 0;
        if (isAllPass) {
            passCount++; // 最后一次也通关了
        }

        _ui.level_process_bar.value = passCount / 15;
        var itemSystem:CItemSystem = (uiCanvas as CAppSystem).stage.getSystem(CItemSystem) as CItemSystem;

        for (var i:int = 0; i < 5; i++) {
            var boxLevel:int = (i+1)*3; // 宝箱对应的关卡index
            var rewardImg:Clip = getRewardBoxImg(i);
            var rewardEffect:FrameClip = getRewardEffect(i);

            // 奖励 tips
            var levelData:CCultivateLevelData = _climpData.cultivateData.levelList.getLevel(boxLevel);
            rewardImg.dataSource = levelData.reward;

            var isGetReward:Boolean = _climpData.cultivateData.otherData.isGetRewardBox(boxLevel);
            var status:int = CRewardTips.REWARD_STATUS_NOT_COMPLETED;
            rewardImg.index = 0;
            if (levelData.passed > 0) {
                if (isGetReward) {
                    status = CRewardTips.REWARD_STATUS_HAS_REWARD;
                    rewardImg.index = 1;
                } else {
                    status = CRewardTips.REWARD_STATUS_CAN_REWARD;
                }
            } else {
                status = CRewardTips.REWARD_STATUS_NOT_COMPLETED;
            }

            var strLevelIndex:String = "common_number_china_" + levelData.layer;
            var titleName:String = CLang.Get("cultivate_title_name", {v1:CLang.Get(strLevelIndex)});
            var tipsHandler:Handler = new Handler(itemSystem.showRewardTips, [rewardImg, [CLang.Get("cultivate_reward_box_tips_desc", {v1:titleName}), status, 1]]);
            rewardImg.toolTip = tipsHandler;

            // 宝箱特效
            if (passCount >= boxLevel) {
                // 已通关
                ObjectUtils.gray(rewardImg, false);

                if (isGetReward) {
                    if (rewardEffect.isPlaying) {
                        rewardEffect.stop();
                        rewardEffect.visible = false;
                    }
                } else {
                    if (!rewardEffect.isPlaying) {
                        rewardEffect.play();
                        rewardEffect.visible = true;
                    }
                }
            } else {
                // 未通关
                ObjectUtils.gray(rewardImg, true);
                if (rewardEffect.isPlaying) {
                    rewardEffect.stop();
                    rewardEffect.visible = false;
                }
            }

        }

        return true;
    }

    private function _onClickRewardBox1(e:Event) : void {
        _onClickRewardBoxB(3);
    }
    private function _onClickRewardBox2(e:Event) : void {
        _onClickRewardBoxB(6);
    }
    private function _onClickRewardBox3(e:Event) : void {
        _onClickRewardBoxB(9);
    }
    private function _onClickRewardBox4(e:Event) : void {
        _onClickRewardBoxB(12);
    }
    private function _onClickRewardBox5(e:Event) : void {
        _onClickRewardBoxB(15);
    }
    private function _onClickRewardBoxB(index:int) : void {
        var levelData:CCultivateLevelData = _climpData.cultivateData.levelList.getLevel(index);
        if (levelData.passed > 0) {
            // pass
            if (!_climpData.cultivateData.otherData.isGetRewardBox(index)) {
                // 可领
                sendEvent(new CViewEvent(CViewEvent.UI_EVENT, ECultivateViewEventType.MAIN_CLICK_REWARD_BOX, index));
            }
        }
    }
    private function getRewardEffect(idx:int) : FrameClip {
        return _ui["reward_box_effect_" + (idx+1)];
    }
    private function getRewardBoxImg(idx:int) : Clip {
        return _ui["reward_box_img_" + (idx+1)];
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

    private var _isFirst:Boolean = true;

}
}