//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/6.
 */
package kof.game.peakGame.view.main {

import kof.game.KOFSysTags;

import kof.game.bootstrap.CNetDelayHandler;

import kof.game.common.CLang;
import kof.game.common.CSystemRuleUtil;

import kof.game.common.view.CRootView;
import kof.game.common.view.event.CViewEvent;
import kof.game.peakGame.CPeakGameSystem;
import kof.game.peakGame.data.CPeakGameData;
import kof.game.peakGame.enum.EPeakGameViewEventType;
import kof.game.peakGame.enum.EPeakGameWndResType;
import kof.game.peakGame.view.CPeakGameLevelItemUtil;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CEmbattleData;
import kof.game.player.data.CEmbattleListData;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.ui.master.PeakGame.PeakGameUI;


public class CPeakGameView extends CRootView {

    public function CPeakGameView() {
        super(PeakGameUI, [CPeakGameMainLinks, CPeakGameMainInfo, CPeakGameMainHeros, CPeakGameLevelChangeEffect], EPeakGameWndResType.PEAK_GAME_MAIN, false);
    }

    protected override function _onCreate() : void {
        _isFrist = true;
        _ui.net_state_txt.text = CLang.Get("common_net_state");
        setTweenData(KOFSysTags.PEAK_GAME_FAIR);
    }
    protected override function _onDispose() : void {

    }
    protected override function _onShow():void {
        _iPlayType = _initialArgs[0];

        this.listEnterFrameEvent = true;
//        _ui.count_down_txt.text = _ui.count_down2_txt.text = "";
//        _ui.count_down_title_txt.visible = false;
//        _ui.count_down_bg_img.visible = false;
        CSystemRuleUtil.setRuleTips(_ui.tips_btn, CLang.Get("peak_rule"));


    }
    protected override function _onShowing() : void {
        var emList:CEmbattleListData = (system as CPeakGameSystem).embattleListData;
        if (!emList) return ;
        var url:String;
        for (var i:int = 0; i < 3; i++) {
            var emData:CEmbattleData = emList.getByPos(i+1);
            if (!emData) {
                continue ;
            }
            var heroData:CPlayerHeroData = _playerData.heroList.getHero(emData.prosession);
            if (!heroData) {
                continue ;
            }
            url = null;
            url = CPlayerPath.getPeakUIHeroFacePath(heroData.prototypeID);
            this.loadBmd(url);
        }
    }
    protected override function _onHide() : void {
        CSystemRuleUtil.setRuleTips(_ui.tips_btn, null);
    }

    protected override function _onEnterFrame(delta:Number) : void {
        if (_data && _peakGameData) {
//            var iClientTime:Number = CTime.getCurrServerTimestamp();
//            if (iClientTime < _peakGameData.seasonStartTime) { // 有问题 , 下来的数据没问题
//                var dataSub:int = Math.abs(CTime.dateSub(iClientTime, _peakGameData.seasonStartTime));
//                if (dataSub > 0) {
//                    // 大于一天不显示
//                    if (_ui.count_down_txt.text.length > 0) {
//                        _ui.count_down_txt.text = "";
//                    }
//                    if (_ui.count_down2_txt.text.length > 0) {
//                        _ui.count_down2_txt.text = "";
//                    }
//                    _ui.count_down_title_txt.visible = false;
//                    _ui.count_down_bg_img.visible = false;
//                } else {
//                    var timeSub:Number = _peakGameData.seasonStartTime - CTime.getCurrServerTimestamp();
//                    _ui.count_down_txt.text = CTime.toDurTimeString(timeSub);
//                    if (_ui.count_down2_txt.text.length > 0) {
//                        _ui.count_down2_txt.text = "";
//                    }
//                    _ui.count_down_title_txt.visible = true;
//                    _ui.count_down_bg_img.visible = true;
//                }
//            } else {
//                if (_ui.count_down_txt.text.length > 0) {
//                    _ui.count_down_txt.text = "";
//                }
//                if (_ui.count_down2_txt.text.length > 0) {
//                    _ui.count_down2_txt.text = "";
//                }
//                _ui.count_down_title_txt.visible = false;
//                _ui.count_down_bg_img.visible = false;
//
//            }

        }
    }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        if (_isFrist) {
            _isFrist = false;
            if (_peakGameData.firstAutoEmbattle == false) {
                sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EPeakGameViewEventType.MAIN_AUTO_SET_BEST_EMBATTLE));
            }
        }

        // 小红点
        var pUI:PeakGameUI = rootUI as PeakGameUI;
        if (pUI) {
            var isFightNotify:Boolean = _peakGameData.dayFightCount < 2;
            var isDailyRewardNotify:Boolean = _peakGameData.rewardData.isDailyCanReward;
            var isWeekRewardNotify:Boolean = _peakGameData.rewardData.isWeekCanReward;

            if (pUI.img_red_fight.visible != isFightNotify) {
                pUI.img_red_fight.visible = isFightNotify;
            }
            if (pUI.img_red_reward.visible != (isDailyRewardNotify || isWeekRewardNotify)) {
                pUI.img_red_reward.visible = isDailyRewardNotify || isWeekRewardNotify;
            }
        }

        if (pUI.multi_score_clip){
            if (_peakGameData.scoreActivityStart) {
                pUI.multi_score_clip.visible = true;
                var multiple:int = _peakGameData.scoreActivityBaseMultiple;
                if (multiple == 2) {
                    pUI.multi_score_clip.index = 0;
                } else if (multiple == 3) {
                    pUI.multi_score_clip.index = 1;
                } else {
                    pUI.multi_score_clip.index = 2;
                }
            } else {
                pUI.multi_score_clip.visible = false;
            }
        }


        this.addToDialog(KOFSysTags.PEAK_GAME_FAIR);

        return true;
    }

    public function updateNetDelay() : void {
        var pPeakGameData:CPeakGameData = _peakGameData;
        if (pPeakGameData && _ui) {
            var delay:int = pPeakGameData.lastNetDelay;
            if( delay >= CNetDelayHandler.NET_DELAY_BAD ){
                _ui.fignal_clip.index = 2;
                _ui.fignal_clip.toolTip = CLang.Get("common_net_delay_bad", {v1:delay});
                _ui.net_state_txt.toolTip = CLang.Get("common_net_delay_bad", {v1:delay});
            }else if( delay >= CNetDelayHandler.NET_DELAY_NORMAL ){
                _ui.fignal_clip.index = 1;
                _ui.fignal_clip.toolTip = CLang.Get("common_net_delay_normal", {v1:delay});
                _ui.net_state_txt.toolTip = CLang.Get("common_net_delay_normal", {v1:delay});
            }else{
                _ui.fignal_clip.index = 0;
                _ui.fignal_clip.toolTip = CLang.Get("common_net_delay_gold", {v1:delay});
                _ui.net_state_txt.toolTip = CLang.Get("common_net_delay_gold", {v1:delay});
            }
        }
    }

    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);
        this.setChildrenData(v, forceInvalid);
    }

    public function playLevelChangeEffect(data:Array) : void {
        _levelChangeEffect.playLevelChangeEffect(data);
    }
    public function showLevelItem() : void {
        if (_peakGameData.peakLevelRecord) {
            var virtualRank:int;
            _peakGameData.rankDataOne.sortVirtual();
            _peakGameData.rankDataMulti.sortVirtual();
            if (_peakGameData.isMaxLevel) {
                virtualRank = _peakGameData.rankDataMulti.getPlayerRanking(_playerData.ID);
            } else {
                virtualRank = -1; // 非拳皇三不显示排名
            }
            CPeakGameLevelItemUtil.setValueBigII(_ui.level_item,
                    _peakGameData.peakLevelRecord.levelId,
                    _peakGameData.peakLevelRecord.subLevelId,
                    _peakGameData.peakLevelRecord.levelName, true, true, virtualRank);
        }
    }
    // ====================================event=============================


    //===================================get/set======================================

    private function get _linksView() : CPeakGameMainLinks { return getChild(0) as CPeakGameMainLinks; }
    private function get _infoView() : CPeakGameMainInfo { return getChild(1) as CPeakGameMainInfo; }
    private function get _heroListView() : CPeakGameMainHeros { return getChild(2) as CPeakGameMainHeros; }
    private function get _levelChangeEffect() : CPeakGameLevelChangeEffect { return getChild(3) as CPeakGameLevelChangeEffect; }

    [Inline]
    private function get _ui() : PeakGameUI {
        return rootUI as PeakGameUI;
    }
    [Inline]
    private function get _peakGameData() : CPeakGameData {
        if (_data && _data.length > 0) {
            return super._data[0] as CPeakGameData;
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
    public function get iPlayType():int {
        return _iPlayType;
    }

    private var _isFrist:Boolean = true;
    private var _iPlayType:int; // EPeakGameWndType.PLAY_TYPE_XXXX; 拳皇大赛或拳皇争霸

}
}
