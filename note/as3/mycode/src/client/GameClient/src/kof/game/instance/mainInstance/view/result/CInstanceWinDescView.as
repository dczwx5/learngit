//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/4/29.
 */
package kof.game.instance.mainInstance.view.result {

import QFLib.Utils.FilterUtil;

import kof.framework.CAppSystem;

import kof.game.common.CLang;
import kof.game.common.CRewardUtil;
import kof.game.common.view.CChildView;
import kof.game.currency.enum.ECurrencyIconURL;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.mainInstance.data.CChapterInstanceData;
import kof.game.instance.mainInstance.data.CInstanceDataCollection;
import kof.game.instance.mainInstance.data.CInstancePassRewardData;
import kof.game.item.data.CRewardListData;
import kof.game.item.view.part.CRewardItemListView;
import kof.ui.instance.InstanceWinDescUI;
import kof.ui.instance.InstanceWinUI;

import morn.core.components.Clip;

import morn.core.components.Component;
import morn.core.components.Label;

import morn.core.handlers.Handler;
import morn.core.utils.ObjectUtils;

public class CInstanceWinDescView extends CChildView {
    public function CInstanceWinDescView() {
        super([CRewardItemListView]);
    }

    protected override function _onCreate() : void {
        _ui.reward_list.cacheAsBitmap = true;
        _ui.reward_list_mask_img.cacheAsBitmap = true;
        _ui.reward_list.mask = _ui.reward_list_mask_img;

        _ui.exp_bar.bar.visible = false;
        _ui.exp_white_bar.alpha = 1;
        _ui.exp_white_bar.bar.filters = FilterUtil.ALL_WHITE_FILTER;
        _ui.exp_white_bar.bar.filters.push(FilterUtil.GreenGlowFilter);
    }
    protected override function _onDispose() : void {
    }
    protected override function _onShow():void {
        _rewardView.isShowCurrency = false;
        _rewardView.repeatValue = 6;
        _rewardView.ui = _ui.reward_list;
        _ui.ok2_btn.label = CLang.Get("common_exit_instance");
        _ui.ok2_btn.clickHandler = new Handler(_onOk);

        this.setNoneData();

        m_iLeftTime = 30;
        schedule(1, _onScheduleHandler);
    }

    private function _onScheduleHandler(delta : Number):void
    {
        _ui.txt_countDown.text = "("+m_iLeftTime + "s后自动关闭)";
        m_iLeftTime--;

        if(m_iLeftTime <= -1)
        {
            parentView.close();
        }
    }

    protected override function _onHide() : void {
        _ui.ok2_btn.clickHandler = null;

        unschedule(_onScheduleHandler);
    }
    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);
        var rewardListData:CRewardListData = data.instanceDataManager.instanceData.lastInstancePassReward ? data.instanceDataManager.instanceData.lastInstancePassReward.rewardList : null;
        _rewardView.setData(rewardListData, forceInvalid);

    }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        var rewardData:CInstancePassRewardData = data.instanceDataManager.instanceData.lastInstancePassReward;
        if (rewardData && data.instanceDataManager.instanceData.lastInstancePassReward.isServerData) {
            var star:int = rewardData.star;
            var level:int = rewardData.level;

            _starConditionTipsList = [
                [CLang.Get("instance_elite_star_cond_1"), rewardData.isStarPassByIndex(0)],
                [CLang.Get("instance_elite_star_cond_2"), rewardData.isStarPassByIndex(1)],
                [CLang.Get("instance_elite_star_cond_3", {v1:instanceData.condStar3TimeLeft}), rewardData.isStarPassByIndex(2)]
            ];

            // 灰
            setCondition(0, true);
            setCondition(1, true);
            setCondition(2, true);

            // 特效没放完前. 星星是暗的
            for (var i:int = 0; i < 3; i++) {
                setStar(i, true);
            }

            _ui.lv_txt.text = CLang.Get("common_level2", {v1:level});
//            if (data.instanceDataManager.playerData.level != data.instanceDataManager.playerData.lastLevel) {
//                // 升级的话就不显示原来的经验条
//                _ui.exp_base_bar.value = 0;
//                _ui.exp_white_bar.value = 0;
//            } else {
//                _ui.exp_base_bar.value = data.instanceDataManager.playerData.lastExp/data.instanceDataManager.playerData.lastTotalExp;
//                _ui.exp_white_bar.value = data.instanceDataManager.playerData.lastExp/data.instanceDataManager.playerData.lastTotalExp; // 开始时, 和之前的经验一样, 后面把宽度设成最终经验的一样
//
//            }
            _ui.exp_base_bar.value = data.instanceDataManager.playerData.lastExp/data.instanceDataManager.playerData.lastTotalExp;
            _ui.exp_white_bar.value = data.instanceDataManager.playerData.lastExp/data.instanceDataManager.playerData.lastTotalExp; // 开始时, 和之前的经验一样, 后面把宽度设成最终经验的一样


            _ui.exp_bar.value = data.instanceDataManager.playerData.teamData.exp/data.instanceDataManager.playerData.nextLevelExpCost;
            _ui.exp_base_bar.label = CLang.Get("common_v1_v2", {v1:data.instanceDataManager.playerData.teamData.exp, v2:data.instanceDataManager.playerData.nextLevelExpCost}); // base在最上, 显示 的值和他表现的进度不是一样的

            var addExp:int = data.instanceDataManager.instanceData.lastInstancePassReward.rewardList.playerExp;

            _ui.exp_add_txt.text = CLang.Get("common_exp_add", {v1:addExp}) ;
            _ui.exp_up_img.x = _ui.exp_add_txt.x + _ui.exp_add_txt.displayWidth + 2;

            var pInstanceSystem:CInstanceSystem = (uiCanvas as CAppSystem).stage.getSystem(CInstanceSystem) as CInstanceSystem;
            _ui.first_pass_img.visible = !pInstanceSystem.instanceManager.fightingInstanceMessage.isPassBefore;


            var playerExp:int = data.instanceDataManager.instanceData.lastInstancePassReward.rewardList.playerExp;
            var heroExp:int = data.instanceDataManager.instanceData.lastInstancePassReward.rewardList.heroExp;
            var gold:Number = data.instanceDataManager.instanceData.lastInstancePassReward.rewardList.gold;
            var bindDiamond:int = data.instanceDataManager.instanceData.lastInstancePassReward.rewardList.bindDiamond;
            var diamond:int = data.instanceDataManager.instanceData.lastInstancePassReward.rewardList.diamond;
//            这里根据实际奖励可能是金币，可能是钻石，可能绑钻3选一都显示在这个位置
//            如果策划手误配置错误，同时存在了两种以上的互斥货币，则优先显示钻石，其次绑钻，最后金币
            if (diamond > 0) {
                _ui.rwd_img_1.skin = ECurrencyIconURL.getIcoUrl("bluediamond");
                _ui.rwd_count_img_1.text = "X" + diamond.toString();
            } else if (bindDiamond > 0) {
                _ui.rwd_img_1.skin = ECurrencyIconURL.getIcoUrl("violetdiamond");
                _ui.rwd_count_img_1.text = "X" + bindDiamond.toString();
            } else {
                _ui.rwd_img_1.skin = ECurrencyIconURL.getIcoUrl("goldcoin");
                _ui.rwd_count_img_1.text = "X" + gold.toString();
            }

            _ui.rwd_img_2.skin = ECurrencyIconURL.getIcoUrl("exp"); // 战队经验
            _ui.rwd_count_img_2.text = "X" + playerExp.toString();
            _ui.rwd_img_3.skin = ECurrencyIconURL.getIcoUrl("roleexp"); // 格斗家经验
            _ui.rwd_count_img_3.text = "X" + heroExp.toString();

            _ui.rwd_img_1.visible = true;
            _ui.rwd_img_2.visible = true;
            _ui.rwd_img_3.visible = true;

            _ui.rwd_count_img_1.visible = true;
            _ui.rwd_count_img_2.visible = true;
            _ui.rwd_count_img_3.visible = true;

        }

        return true;
    }

    public function setStar(idx:int, forceGray:Boolean = false) : void {
        var rewardData:CInstancePassRewardData = data.instanceDataManager.instanceData.lastInstancePassReward;
        if (rewardData && data.instanceDataManager.instanceData.lastInstancePassReward.isServerData) {
            var star : int = rewardData.star;
            if (star >= idx+1 && !forceGray) {
                (_ui["star" + (idx+1) + "_image"] as Clip).index = 0;
            } else {
                (_ui["star" + (idx+1) + "_image"] as Clip).index = 1;
            }
        }
    }
    public function setCondition(idx:int, forceGray:Boolean = false) : void {
        var com:Component = _ui["cond_item" + (idx+1) + "_box"] as Component;
        if (_starConditionTipsList && _starConditionTipsList[idx]) {
            com.dataSource = _starConditionTipsList[idx];
        } else {
            com.dataSource = ["", false];
        }
        _onRenderConditionItem(com, forceGray);
    }

    private function _onRenderConditionItem(com:Component, forceGray:Boolean = false) : void {
        var label:Label = com.getChildByName("desc_star_txt") as Label;
        var passClip:Clip = com.getChildByName("bg_clip") as Clip;
        var bgClip:Clip = com.getChildByName("bg_img") as Clip;
        var datas:Array = com.dataSource as Array;
        var desc:String = datas[0] as String;
        var isShowCond:Boolean = datas[1] as Boolean;
        label.text = desc;
        if (isShowCond && !forceGray) {
            bgClip.index = 0;
            passClip.index = 0;
            ObjectUtils.gray(label, false);
        } else {
            bgClip.index = 1;
            passClip.index = 1;
            ObjectUtils.gray(label, true);
        }
    }
    private function _onOk() : void {
        parentView.close();
    }

    public function get _ui() : InstanceWinDescUI {
        return (rootUI as InstanceWinUI).desc_view;
    }
    public function get _rewardView() : CRewardItemListView { return getChild(0) as CRewardItemListView; }

    private function get data() : CInstanceDataCollection {
        return _data as CInstanceDataCollection;
    }
    private function get instanceData() : CChapterInstanceData {
        return data.curInstanceData;
    }
    public function set visible(v:Boolean) : void {
        _ui.visible = v;
    }
    private var _starConditionTipsList:Array;
    private var m_iLeftTime:int;
}
}
