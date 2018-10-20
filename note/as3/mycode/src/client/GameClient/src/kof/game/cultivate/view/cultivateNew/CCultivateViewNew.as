//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/4/11.
 */
package kof.game.cultivate.view.cultivateNew {

import kof.game.cultivate.CCultivateSystem;
import kof.game.cultivate.data.cultivate.CCultivateBuffData;
import kof.game.cultivate.imp.CCultivateUtils;

import flash.events.Event;
import flash.events.MouseEvent;

import kof.game.KOFSysTags;

import kof.game.common.CLang;
import kof.game.common.CSystemRuleUtil;

import kof.game.cultivate.data.CClimpData;
import kof.game.cultivate.data.cultivate.CCultivateData;
import kof.game.cultivate.data.cultivate.CCultivateLevelData;
import kof.game.cultivate.enum.ECultivateWndResType;
import kof.game.cultivate.enum.ECultivateViewEventType;
import kof.game.common.view.CRootView;
import kof.game.common.view.event.CViewEvent;
import kof.game.player.data.CPlayerData;
import kof.ui.master.cultivate.CultivateNewIIUI;

import morn.core.handlers.Handler;
import morn.core.utils.ObjectUtils;

// 修行之路
// 打开界面时, 更新heroData.ExternData
// 关闭界面时, 清空heroData.externData
public class CCultivateViewNew extends CRootView {
    public static const SELECT_LEVEL_CHANGE:String = "select_level_change_event";
    public function CCultivateViewNew() {
        super(CultivateNewIIUI, [CCultivateLevelNew, CCultivateLevelProcessView], ECultivateWndResType.CULTIVATE, false);
    }

    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);
        this.setChildrenData(v, forceInvalid);
    }
    protected override function _onCreate() : void {
        _isFrist = true;
        _ui.win_box.visible = false;
        _ui.resetClip.visible = false;
        _ui.resetClip.stop();

        setTweenData(KOFSysTags.CULTIVATE);

    }
    protected override function _onDispose() : void {
        // can not call super._onDispose in this class
    }
    protected override function _onShow():void {
        // can not call super._onShow in this class
        _ui.shop_btn.clickHandler = new Handler(_onClickShop);
        CSystemRuleUtil.setRuleTips(_ui.tips_btn, CLang.Get("cultivate_rule"));

        _ui.embattle_btn.clickHandler = new Handler(_onClickEmbattle);
        _ui.reset_btn.addEventListener(MouseEvent.CLICK, _onClickReset);
        _ui.fight_btn.clickHandler = new Handler(_onClickFight);
        _ui.buff_box.addEventListener(MouseEvent.CLICK, _onClickChangeBuff);
        addEventListener(CCultivateViewNew.SELECT_LEVEL_CHANGE, _onLevelSelectChange);

        _isPlayingFirstMovie = false;
    }

    private function _onClickChangeBuff(e:Event) : void {
        this.sendEvent(new CViewEvent(CViewEvent.UI_EVENT, ECultivateViewEventType.MAIN_CLICK_CHANGE_BUFF_BTN, []));
    }
    private function _onClickShop() : void {
        this.sendEvent(new CViewEvent(CViewEvent.UI_EVENT, ECultivateViewEventType.MAIN_CLICK_SHOP, []));
    }
//    private function _onClickStrategy() : void {
//        this.sendEvent(new CViewEvent(CViewEvent.UI_EVENT, ECultivateViewEventType.MAIN_CLICK_STRATEGY, []));
//    }
    private function _onClickEmbattle() : void {
        this.sendEvent(new CViewEvent(CViewEvent.UI_EVENT, ECultivateViewEventType.MAIN_CLICK_EMBATTLE, []));
    }
    private function _onClickReset(e:MouseEvent) : void {
        this.sendEvent(new CViewEvent(CViewEvent.UI_EVENT, ECultivateViewEventType.MAIN_CLICK_RESET, []));
    }
    private function _onClickFight() : void {
        var levelData:CCultivateLevelData = null;
        if (levelView.selectLevelInfo) {
            levelData = levelView.selectLevelInfo.levelData;
        }
        this.sendEvent(new CViewEvent(CViewEvent.UI_EVENT, ECultivateViewEventType.FIGHT_CLICK, levelData));
    }
    protected override function _onHide() : void {
        // can not call super._onHide in this class
        _ui.shop_btn.clickHandler = null;
        _ui.tips_btn.toolTip = null;
        _ui.embattle_btn.clickHandler = null;
        _ui.reset_btn.removeEventListener(MouseEvent.CLICK, _onClickReset);
        _ui.fight_btn.clickHandler = null;
        CSystemRuleUtil.setRuleTips(_ui.tips_btn, null);
        removeEventListener(CCultivateViewNew.SELECT_LEVEL_CHANGE, _onLevelSelectChange);
        _ui.buff_box.removeEventListener(MouseEvent.CLICK, _onClickChangeBuff);

    }
    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        if (!_isPlayingFirstMovie) { // 预防在播放首次动画时, 有新的更新触发, 导致表现异常, 重新打开界面, 会奖_isPlaying设为false, 避免播放过程中关闭界面导致界面的东西一直被隐藏
            if (_climpData.cultivateData.otherData.openFlag == false) {
                // 首次打开系统
                _isPlayingFirstMovie = true;
                _climpData.cultivateData.otherData.setOpenFlag(); // 只播放一次
                (system as CCultivateSystem).netHandler.sendOpenFlag();
                levelView.playFirstOpenMovie();

            } else {
                _ui.win_box.visible = true;
            }
        }

        CCultivateUtils.buffViewRender(_climpData, _ui, true);
        // buff tips
        _ui.buff_box.toolTip = null;
        var buffData:CCultivateBuffData = _climpData.cultivateData.otherData.curBuffData;
        if (buffData) {
            var hasBuff:Boolean = buffData.isDataValid();
            if (hasBuff) {
                var isBuffActive:Boolean = _climpData.cultivateData.otherData.currBuffEffect > 0;
                var strActiveState:String;
                if (isBuffActive) {
                    strActiveState = CLang.Get("common_actived");
                } else {
                    strActiveState = CLang.Get("common_unActived");
                }
                _ui.buff_box.toolTip = CLang.Get("cultivate_buff_tips", {v1:buffData.name, v2:strActiveState, v3:buffData.desc, v4:buffData.percent});
            }
        }

        var resetCountLeft:int = _climpData.cultivateData.otherData.resetTimes;
        _ui.txt_resetNum.text = CLang.Get("cultivate_reset", {v1:resetCountLeft, v2:1});

        ObjectUtils.gray(_ui.reset_btn, _climpData.cultivateData.otherData.resetTimes <= 0);
        if (_climpData.cultivateData.otherData.resetTimes > 0 && _climpData.cultivateData.levelList.curLevelData.passed > 0) {
            _ui.resetClip.visible = true;
            _ui.resetClip.play();
        } else {
            _ui.resetClip.visible = false;
            _ui.resetClip.stop();
        }

        this.addToDialog(KOFSysTags.CULTIVATE);
        return true;
    }

    private function _onLevelSelectChange(e:Event) : void {
        _ui.fight_btn.visible = true;

        var levelData:CCultivateLevelData = null;
        if (levelView.selectLevelInfo) {
            levelData = levelView.selectLevelInfo.levelData;
        }
        if (!levelData) {
            return ;
        }

        var culLevelData:CCultivateLevelData = levelData;
        var isPassed:Boolean = culLevelData.passed == 1;
        var isCurFightLevel:Boolean = _cultivateData.levelList.curOpenLevelIndex == culLevelData.layer;
        _ui.fight_btn.visible = (!isPassed) && isCurFightLevel;
    }

    public function set visible(v:Boolean) : void {
        _ui.visible = v;
    }

    public function getSelectLevelData() : CCultivateLevelData {
        var levelData:CCultivateLevelData = null;
        if (levelView.selectLevelInfo) {
            levelData = levelView.selectLevelInfo.levelData;
        }
        return levelData;
    }

//    public function get chatView() : CCultivateChat { return this.getChild(0) as CCultivateChat; }
    public function get levelView() : CCultivateLevelNew { return this.getChild(0) as CCultivateLevelNew; }
    public function get levelProcessView() : CCultivateLevelProcessView { return this.getChild(1) as CCultivateLevelProcessView; }

    public function showResetMovie() : void {
        setAllPass(false);
        levelView.playResetMovie();
    }
    public function showFadeInOut() : void {
        levelView.isShowFadeInOut = true;
    }
    public function setAllPass(v:Boolean) : void {
        levelView.isAllPass = v;
    }

    [Inline]
    public function get _ui() : CultivateNewIIUI {
        return (rootUI as CultivateNewIIUI);
    }
    [Inline]
    private function get _climpData() : CClimpData {
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
    private function get _hasEmbattleData() : Boolean {
        return super._data[2] as Boolean;
    }
    private var _isFrist:Boolean = true;
    private var _isPlayingFirstMovie:Boolean;
}
}
