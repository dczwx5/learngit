//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/3.
 */
package kof.game.instance.mainInstance.view.instanceScenario {

import flash.events.Event;
import flash.events.MouseEvent;

import kof.framework.CAppSystem;
import kof.framework.IDatabase;
import kof.game.common.CLang;
import kof.game.common.CRewardUtil;
import kof.game.common.view.CChildView;
import kof.game.common.view.event.CViewEvent;
import kof.game.common.view.rewardTips.CRewardTips;
import kof.game.instance.mainInstance.data.CChapterData;
import kof.game.instance.mainInstance.data.CInstanceDataCollection;
import kof.game.instance.mainInstance.view.event.EInstanceViewEventType;
import kof.game.item.CItemData;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardData;
import kof.game.item.view.part.CRewardItemListView;
import kof.ui.instance.InstanceScenarioUI;
import morn.core.components.Clip;
import morn.core.components.FrameClip;
import morn.core.components.Image;
import morn.core.components.Label;
import morn.core.handlers.Handler;
import morn.core.utils.ObjectUtils;

public class CInstanceScenarioRewardView extends CChildView {
    public function CInstanceScenarioRewardView() {
    }
    protected override function _onCreate() : void {
        // can not call super._onCreate in this class
            var chaGetClip:FrameClip;
        for (var i:int = 0; i < 3; i++) {
            chaGetClip = _ui["chapter_reward_get_clip" + (i+1)] as FrameClip;
            chaGetClip.visible = false;
            chaGetClip.stop();
        }
    }
    protected override function _onDispose() : void {
        // can not call super._onDispose in this class
    }
    protected override function _onShow():void {
        // can not call super._onShow in this class
        for (var i:int = 0; i < 3; i++) {
            var rewardBtn:Image = _ui["star" + (i + 1) + "_btn"] as Image;
            rewardBtn.addEventListener(MouseEvent.CLICK, this["_onClick" + (i+1)]);
            var effect:FrameClip = _ui["star" + (i+1) + "_effect_clip"] as FrameClip;
            effect.visible = false;

            var rewardClip:FrameClip = _ui["chapter_reward_get_clip" + (i+1)] as FrameClip;
            rewardClip.stop();
            rewardClip.visible = false;

        }
    }

    protected override function _onHide() : void {
        // can not call super._onHide in this class
        for (var i:int = 0; i < 3; i++) {
            var rewardBtn:Image = _ui["star" + (i + 1) + "_btn"] as Image;
            rewardBtn.removeEventListener(MouseEvent.CLICK, this["_onClick" + (i+1)] as Function);
        }
    }
    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        var chapterData:CChapterData = data.curChapterData;

        var starCount:int = chapterData.curStar;
        var totalCount:int = chapterData.totalStar;
        if (totalCount <= 0) totalCount = 1;

        //
        var chapterRewardItemID:int = chapterData.chapterRecord.RewardItemDisplay;
        if (chapterRewardItemID > 0) {
            _ui.chapter_reward_display_box.visible = true;
            var dateBase:IDatabase = system.stage.getSystem(IDatabase) as IDatabase;
            var chapterRewardDisplayData:CItemData = CRewardData.CreateRewardData(chapterRewardItemID, 1, dateBase);
            _ui.chapter_reward_display_item_view.dataSource = chapterRewardDisplayData;
            CRewardItemListView.onRenderItem(system, _ui.chapter_reward_display_item_view, 0, false, false);
        } else {
            _ui.chapter_reward_display_box.visible = false;
        }

        //
        var chaCanGetClip:FrameClip;
//        var chaGetClip:FrameClip;
        var rewardBtn:Image;
        var starTxt:Label;
        for (var i:int = 0; i < 3; i++) {
            starTxt = _ui["star" + (i+1) + "_txt"] as Label;
            rewardBtn = _ui["star" + (i+1) + "_btn"] as Image;
            rewardBtn.url = chapterData.chapterRecord.rewardUrl[i];
            chaCanGetClip = _ui["chapter_reward_can_get_effect" + (i+1)] as FrameClip;
//            chaGetClip = _ui["chapter_reward_get_clip" + (i+1)] as FrameClip;
            rewardBtn.dataSource = CRewardUtil.createByDropPackageID((uiCanvas as CAppSystem).stage, chapterData.reward[i]);
            starTxt.text = chapterData.getStarByIndex(i).toString();
            var status:int = 0; // 0 未达成, 1可领, 2已领

            var effect:FrameClip = _ui["star" + (i+1) + "_effect_clip"] as FrameClip;
//            chaGetClip.visible = false;
//            chaGetClip.stop();
            chaCanGetClip.visible = false;
            chaCanGetClip.stop();

            var canGetReward:Boolean = chapterData.isCanGetReward(i);
            if (canGetReward) { status = CRewardTips.REWARD_STATUS_CAN_REWARD; } else { status = CRewardTips.REWARD_STATUS_NOT_COMPLETED; }
            var hasReward:Boolean = chapterData.isRewarded(i+1);
            if (hasReward) { status = CRewardTips.REWARD_STATUS_HAS_REWARD; }
            if (status == CRewardTips.REWARD_STATUS_NOT_COMPLETED) {
                ObjectUtils.gray(rewardBtn, true);
                effect.visible = false;
                // 章节奖励tips用的是reward_status3_img
                status = CRewardTips.REWARD_STATUS_OTHER_1;
            } else if (status == CRewardTips.REWARD_STATUS_CAN_REWARD) {
                ObjectUtils.gray(rewardBtn, false);
                effect.visible = true;
                chaCanGetClip.visible = true;
                chaCanGetClip.play();
            } else {
                ObjectUtils.gray(rewardBtn, false);
                effect.visible = false;
            }


            var needStar:int = chapterData.getStarByIndex(i);
            var tipsTitle:String = CLang.Get("instance_star_reward_title", {v1:needStar});
            var itemSystem:CItemSystem = system.stage.getSystem(CItemSystem) as CItemSystem;
            rewardBtn.toolTip = new Handler(itemSystem.showRewardTips, [rewardBtn, [tipsTitle, status, 2]]);

        }
        var curStar:int = starCount;
        var totalStar:int = totalCount;
        _ui.starTotal_txt.text = CLang.Get("common_v1_v2", {v1:curStar, v2:totalStar});
        _ui.star_bar.value = starCount/chapterData.getStarByIndex(2);
        return true;
    }

    private function _onClick1(e:Event) : void {
        _onClickB(0);
    }
    private function _onClick2(e:Event) : void {
        _onClickB(1);
    }
    private function _onClick3(e:Event) : void {
        _onClickB(2);
    }
    private function _onClickB(index:int) : void {
        if (data.curChapterData.isRewarded(index+1) == false && data.curChapterData.isCanGetReward(index)) {
            var chaGetClip:FrameClip = _ui["chapter_reward_get_clip" + (index+1)] as FrameClip;
            if (chaGetClip.visible == false) {
                chaGetClip.visible = true;
                chaGetClip.playFromTo(null, null, new Handler(function () : void {
                    chaGetClip.visible = false;
                    chaGetClip.stop();
                }));
                rootView.dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT, EInstanceViewEventType.INSTANCE_GET_CHAPTER_REWARD, [data, data.curChapterData, index]));
            }
        } else {
            if (data.curChapterData.isRewarded(index+1)) {
                uiCanvas.showMsgAlert(CLang.Get("common_have_get_reward"));
            } else {
                uiCanvas.showMsgAlert(CLang.Get("common_cond_not_ok_reward"));
            }
        }
    }
    private function get _ui() : InstanceScenarioUI {
        return rootUI as InstanceScenarioUI;
    }
    private function get data() : CInstanceDataCollection {
        return _data as CInstanceDataCollection;
    }
}
}
